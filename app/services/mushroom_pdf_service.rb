# frozen_string_literal: true

# Service to generate PDF exports of mushroom data including images and characters
class MushroomPdfService
  require 'prawn'
  require 'prawn/table'

  def initialize(mushrooms)
    @mushrooms = Array(mushrooms)
  end

  def generate
    Prawn::Document.new(page_size: 'LETTER', margin: 40) do |pdf|
      @mushrooms.each_with_index do |mushroom, index|
        # Add page break between mushrooms (except for first one)
        pdf.start_new_page if index > 0

        render_mushroom(pdf, mushroom)
      end
    end
  end

  private

  # Sanitize text to be compatible with Windows-1252 encoding
  # Replace incompatible characters with safe alternatives
  def sanitize_for_pdf(text)
    return '' if text.nil?

    text.to_s
        .encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?')
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  end

  def render_mushroom(pdf, mushroom)
    # Title
    pdf.font_size(20) do
      pdf.text sanitize_for_pdf(mushroom.name), style: :bold, color: '333333'
    end
    pdf.move_down 10

    # Basic Information
    render_basic_info(pdf, mushroom)
    pdf.move_down 15

    # Images Section
    if mushroom.image_mushrooms.any? { |im| im.image_file.attached? }
      render_images(pdf, mushroom)
      pdf.move_down 15
    end

    # Characters Section
    if mushroom.mr_character_mushrooms.any?
      render_characters(pdf, mushroom)
    end

    # Trees and Plants
    render_associations(pdf, mushroom)
  end

  def render_basic_info(pdf, mushroom)
    pdf.font_size(10) do
      info_data = []

      info_data << ['Fungus Type:', sanitize_for_pdf(mushroom.fungus_type&.name || 'N/A')]
      info_data << ['Location:', sanitize_for_pdf(location_text(mushroom))]
      info_data << ['Date Found:', sanitize_for_pdf(mushroom.collection_date&.strftime('%B %d, %Y') || 'N/A')]
      info_data << ['Description:', sanitize_for_pdf(mushroom.description.presence || 'N/A')] if mushroom.description.present?
      info_data << ['Comments:', sanitize_for_pdf(mushroom.comments.presence || 'N/A')] if mushroom.comments.present?
      info_data << ['Personal Notes:', sanitize_for_pdf(mushroom.personal_notes.presence || 'N/A')] if mushroom.personal_notes.present?

      # Taxonomy
      if mushroom.genera.any?
        genera_names = mushroom.genera.map(&:name).join(', ')
        info_data << ['Genera:', sanitize_for_pdf(genera_names)]
      end
      if mushroom.species.any?
        species_names = mushroom.species.map(&:name).join(', ')
        info_data << ['Species:', sanitize_for_pdf(species_names)]
      end

      pdf.table(info_data,
                cell_style: { borders: [], padding: [2, 5, 2, 5] },
                column_widths: [100, 400]) do |table|
        table.columns(0).font_style = :bold
      end
    end
  end

  def render_images(pdf, mushroom)
    pdf.font_size(14) do
      pdf.text 'Images', style: :bold, color: '555555'
    end
    pdf.move_down 5

    images = mushroom.image_mushrooms.select { |im| im.image_file.attached? }

    # Display fewer, smaller images to keep PDF generation stable on limited resources
    # Smaller variants reduce processing time and download size during export.
    max_images = 4
    max_dimensions = [400, 400]

    images.first(max_images).each_slice(2) do |row_images|
      image_data = []

      row_images.each do |image_mushroom|
        begin
          # Use a resized variant when possible to reduce memory/CPU during PDF generation.
          # Fall back to the original blob if variant processing fails in production.
          if image_mushroom.image_file.variable?
            variant = image_mushroom.image_file.variant(resize_to_limit: max_dimensions).processed
            variant.open do |file|
              # Add image with max width/height
              img_cell = pdf.make_cell(
                image: file.path,
                fit: [120, 120],
                position: :center,
                vposition: :center
              )
              image_data << img_cell
            end
          else
            image_mushroom.image_file.open do |file|
              # Add image with max width/height
              img_cell = pdf.make_cell(
                image: file.path,
                fit: [120, 120],
                position: :center,
                vposition: :center
              )
              image_data << img_cell
            end
          end
        rescue => e
          begin
            image_mushroom.image_file.open do |file|
              # Add image with max width/height
              img_cell = pdf.make_cell(
                image: file.path,
                fit: [120, 120],
                position: :center,
                vposition: :center
              )
              image_data << img_cell
            end
          rescue => fallback_error
            # Add image with max width/height
            # If image fails to load, add placeholder text
            image_data << pdf.make_cell(content: '[Image unavailable]',
                                         align: :center,
                                         valign: :center,
                                         height: 120,
                                         width: 120)
            Rails.logger.error(
              "PDF image error for ImageMushroom##{image_mushroom.id}: #{e.class} #{e.message}; "\
              "fallback_error=#{fallback_error.class} #{fallback_error.message}"
            )
          end
        end
      end

      # Fill remaining cells in row if less than 2 images
      while image_data.length < 2
        image_data << pdf.make_cell(content: '', borders: [])
      end

      pdf.table([image_data], cell_style: { padding: 5, align: :center })
      pdf.move_down 5
    end

    if images.count > max_images
      pdf.font_size(8) do
        pdf.text "(Showing #{max_images} of #{images.count} images)", color: '999999'
      end
    end
  end

  def render_characters(pdf, mushroom)
    pdf.font_size(14) do
      pdf.text 'Characters', style: :bold, color: '555555'
    end
    pdf.move_down 5

    character_rows = mushroom.mr_character_mushrooms.to_a
    character_rows.sort_by! do |rc|
      [
        rc.mr_character&.part&.name.to_s,
        rc.mr_character&.name.to_s
      ]
    end

    grouped = character_rows.group_by { |rc| rc.mr_character&.part&.name || 'Other' }

    grouped.each do |part_name, rows|
      pdf.font_size(12) do
        pdf.text sanitize_for_pdf(part_name), style: :bold, color: '666666'
      end
      pdf.move_down 3

      table_data = rows.map do |rc|
        [
          sanitize_for_pdf(rc.mr_character&.name || 'Unknown'),
          sanitize_for_pdf(format_character_value(rc))
        ]
      end

      pdf.font_size(9) do
        pdf.table(table_data,
                  cell_style: { borders: [:bottom], border_color: 'DDDDDD', padding: [3, 5, 3, 5] },
                  column_widths: [200, 300]) do |table|
          table.columns(0).font_style = :bold
        end
      end
      pdf.move_down 8
    end
  end

  def render_associations(pdf, mushroom)
    associations = []

    if mushroom.trees.any?
      tree_names = mushroom.trees.sort_by(&:name).map(&:name).join(', ')
      associations << ['Associated Trees:', sanitize_for_pdf(tree_names)]
    end

    if mushroom.plants.any?
      plant_names = mushroom.plants.sort_by(&:name).map(&:name).join(', ')
      associations << ['Associated Plants:', sanitize_for_pdf(plant_names)]
    end

    if associations.any?
      pdf.move_down 10
      pdf.font_size(10) do
        pdf.table(associations,
                  cell_style: { borders: [], padding: [2, 5, 2, 5] },
                  column_widths: [120, 380]) do |table|
          table.columns(0).font_style = :bold
        end
      end
    end
  end

  def location_text(mushroom)
    parts = []
    parts << mushroom.city if mushroom.city.present?
    parts << mushroom.county if mushroom.county.present?
    parts << mushroom.state&.name if mushroom.state
    parts << mushroom.country&.name if mushroom.country
    parts.any? ? parts.join(', ') : 'N/A'
  end

  def format_character_value(rc)
    c = rc.mr_character
    display_opt_name = c&.display_option&.name

    result = case display_opt_name
    when 'color'
      colors = rc.ordered_colors
      if colors.any?
        colors.map.with_index do |color, index|
          label = index == 0 ? "PRIMARY: " : ""
          "#{label}#{color.latin_name} (#{color.common_name})"
        end.join("; ")
      else
        "No colors"
      end
    when 'radio', 'drop-down'
      lookup_item = LookupItem.find_by(id: rc.character_value.to_i)
      lookup_item&.name || rc.character_value
    when 'boolean_yes_no'
      rc.character_value.to_s.downcase == 'true' ? 'Yes' : 'No'
    when 'boolean_true_false'
      rc.character_value.to_s.downcase == 'true' ? 'True' : 'False'
    when 'boolean_present_absent'
      rc.character_value.to_s.downcase == 'true' ? 'Present' : 'Absent'
    when 'checkbox'
      rc.character_value.to_s.downcase == 'true' ? 'Yes' : 'No'
    else
      rc.character_value
    end

    result.to_s
  end
end
