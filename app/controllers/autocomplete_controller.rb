# frozen_string_literal: true

class AutocompleteController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized, raise: false

  # GET /autocomplete/genera.json?q=Agar
  def genera
    q = params[:q].to_s.strip
    return render json: [] if q.length < 3

    items = Genus.where("name LIKE ?", "#{sanitize_like(q)}%")
                 .order(:name)
                 .limit(20)
                 .pluck(:id, :name)

    render json: items.map { |id, name| { id: id, name: name } }
  end

  # GET /autocomplete/species.json?q=sessile&mushroom_id=123
  def species
    q = params[:q].to_s.strip
    return render json: [] if q.length < 3

    # Get mushroom's selected genera to filter species
    scope = Species.order(:name)
    if params[:mushroom_id].present?
      mushroom = Mushroom.find_by(id: params[:mushroom_id])
      if mushroom && mushroom.genera.any?
        scope = scope.where(genera_id: mushroom.genera.pluck(:id))
      end
    end

    items = scope.where("species.name LIKE ?", "#{sanitize_like(q)}%")
                 .includes(:genus)
                 .limit(20)
                 .map { |sp| { id: sp.id, name: "#{sp.genus&.name} #{sp.name}".strip } }

    render json: items
  end

  # GET /autocomplete/trees.json?q=oak
  def trees
    query = params[:q].to_s.strip
    results = if query.length >= 3
                Tree
                  .where("name LIKE ?", "%#{Tree.sanitize_sql_like(query)}%")
                  .select(:id, :name)
                  .order(:name)
                  .limit(20)
                  .map { |t| { id: t.id, name: t.name } }
              else
                []
              end
    render json: results
  end

  # GET /autocomplete/plants.json?q=fern
  def plants
    query = params[:q].to_s.strip
    results = if query.length >= 3
                Plant
                  .where("name LIKE ?", "%#{Plant.sanitize_sql_like(query)}%")
                  .select(:id, :name)
                  .order(:name)
                  .limit(20)
                  .map { |p| { id: p.id, name: p.name } }
              else
                []
              end
    render json: results
  end

  # GET /autocomplete/mr_characters.json?q=cap&mushroom_id=1
  def mr_characters
    query = params[:q].to_s.strip.downcase
    mushroom_id = params[:mushroom_id]
    core_only = params[:core_only].to_s != "false"

    results = if query.length >= 3
                # Get mushroom's fungus_type to filter characters
                mushroom = Mushroom.find_by(id: mushroom_id) if mushroom_id.present?

                # Use cached characters for speed, filtered by fungus_type
                if mushroom&.fungus_type_id.present?
                  all_chars = MrCharacter.cached_for_fungus_type(mushroom.fungus_type_id)
                else
                  all_chars = MrCharacter.cached_all_with_associations
                end

                # Filter already-entered characters for this mushroom
                if mushroom_id.present?
                  entered_ids = MrCharacterMushroom
                    .where(mushroom_id: mushroom_id)
                    .pluck(:mr_character_id)
                    .to_set
                  all_chars = all_chars.reject { |c| entered_ids.include?(c.id) }
                end

                # Filter to core characters by default if any exist
                core_chars = nil
                if core_only
                  core_chars = MrCharacter.select_core_for_display(all_chars, fungus_type_id: mushroom&.fungus_type_id)
                  all_chars = core_chars if core_chars.any?
                end

                # Search by name (case-insensitive)
                # Exclude "do not display" characters
                matches = all_chars
                  .select { |c|
                    c.name.downcase.include?(query) &&
                    c.display_option_id != 1 # exclude "do not display"
                  }

                if core_only && core_chars&.any?
                  matches = MrCharacter.sort_for_core_display(matches, keep_part_order: false, fungus_type_id: mushroom&.fungus_type_id)
                end

                matches
                  .first(20)
                  .map { |c|
                    is_color = (c.display_option&.name&.downcase == "color") || c.display_option_id == 6
                    {
                      id: c.id,
                      name: "[#{c.part&.name}] #{c.name.tr('_', ' ')}",
                      part_name: c.part&.name,
                      is_color: is_color
                    }
                  }
              else
                []
              end

    render json: results
  end

  private

  # Escape % and _ for LIKE queries
  def sanitize_like(term)
    term.gsub(/[\\%_]/) { |m| "\\#{m}" }
  end
end
