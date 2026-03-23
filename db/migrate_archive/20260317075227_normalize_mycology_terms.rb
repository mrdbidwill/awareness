# frozen_string_literal: true

class NormalizeMycologyTerms < ActiveRecord::Migration[8.0]
  class MrCharacter < ActiveRecord::Base
    self.table_name = "mr_characters"
  end

  class LookupItem < ActiveRecord::Base
    self.table_name = "lookup_items"
  end

  class Part < ActiveRecord::Base
    self.table_name = "parts"
  end

  def up
    say_with_time "Normalizing mycology terms in mr_characters, lookup_items, and parts" do
      [MrCharacter, LookupItem, Part].each do |model|
        model.find_each do |record|
          attrs = {}
          %i[name description comments].each do |attr|
            next unless record.respond_to?(attr)

            value = record.public_send(attr)
            next if value.blank?

            normalized = normalize_terms(value)
            attrs[attr] = normalized if normalized != value
          end

          next if attrs.empty?

          attrs[:updated_at] = Time.current if record.respond_to?(:updated_at)
          record.update_columns(attrs)
        end
      end

      normalize_part_names
      cleanup_lookup_items
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Term normalization is not reversible"
  end

  private

  def normalize_terms(text)
    replacements.each do |from, to|
      regex = /(?<![A-Za-z])#{Regexp.escape(from)}(?![A-Za-z])/i
      text = text.gsub(regex) { |match| replace_case(match, to) }
    end
    text
  end

  def replace_case(original, replacement)
    if original == original.upcase
      replacement.upcase
    elsif original == original.downcase
      replacement.downcase
    elsif original[0] == original[0].upcase && original[1..] == original[1..].downcase
      replacement.capitalize
    else
      replacement
    end
  end

  def replacements
    [
      ["lamellaes", "gills"],
      ["lamellae", "gills"],
      ["lamella", "gill"],
      ["stipes", "stems"],
      ["stipe", "stem"],
      ["pileuses", "caps"],
      ["pilei", "caps"],
      ["pileus", "cap"],
    ]
  end

  def normalize_part_names
    now = Time.current
    Part.where(name: "Cap - Cap").update_all(name: "Cap", updated_at: now)
    Part.where(name: "Gills - Gills").update_all(name: "Gills", updated_at: now)
    Part.where(name: "Stem - Stem").update_all(name: "Stem", updated_at: now)
  end

  def cleanup_lookup_items
    now = Time.current
    LookupItem.where(name: "Gill - Gills").update_all(name: "Gills", updated_at: now)
    LookupItem.where("description LIKE ?", "%stem (stem)%")
              .update_all(["description = REPLACE(description, 'stem (stem)', 'stem'), updated_at = ?", now])
  end
end
