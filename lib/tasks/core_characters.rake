# frozen_string_literal: true

namespace :mr_characters do
  desc "Bootstrap core characters from existing mushroom usage (dry-run unless APPLY=true)"
  task bootstrap_core_from_usage: :environment do
    bool = ActiveModel::Type::Boolean.new

    min_usage = ENV.fetch("MIN_USAGE", "3").to_i
    min_percent_raw = ENV.fetch("MIN_PERCENT", "40").to_f
    min_ratio = min_percent_raw > 1 ? (min_percent_raw / 100.0) : min_percent_raw
    limit = ENV.fetch("LIMIT", "60").to_i
    fungus_type_id = ENV["FUNGUS_TYPE_ID"].presence&.to_i
    include_templates = bool.cast(ENV.fetch("INCLUDE_TEMPLATES", "false"))
    apply_changes = bool.cast(ENV.fetch("APPLY", "false"))
    reset_sequence = bool.cast(ENV.fetch("RESET_SEQUENCE", "false"))

    fungus_types = if fungus_type_id.present?
      FungusType.where(id: fungus_type_id)
    else
      FungusType.order(:name)
    end

    if fungus_types.empty?
      puts "No matching fungus types found."
      puts "Check FUNGUS_TYPE_ID=#{fungus_type_id.inspect}."
      next
    end

    puts "Bootstrapping core characters from usage"
    puts "mode=#{apply_changes ? 'APPLY' : 'DRY-RUN'} min_usage=#{min_usage} min_percent=#{(min_ratio * 100).round(1)} limit=#{limit} include_templates=#{include_templates} reset_sequence=#{reset_sequence}"
    puts "-" * 80

    fungus_types.each do |fungus_type|
      mushroom_scope = Mushroom.where(fungus_type_id: fungus_type.id)
      mushroom_scope = mushroom_scope.where(is_template: false) unless include_templates
      total_mushrooms = mushroom_scope.count

      puts "#{fungus_type.name} (id=#{fungus_type.id}) mushrooms=#{total_mushrooms}"
      if total_mushrooms.zero?
        puts "  skipped (no mushrooms to analyze)"
        puts
        next
      end

      usage_counts = MrCharacterMushroom
        .joins(:mushroom, :mr_character)
        .where(mushrooms: { id: mushroom_scope.select(:id) })
        .where("mr_characters.display_option_id <> 1")
        .where("mr_characters.fungus_type_id IS NULL OR mr_characters.fungus_type_id = ?", fungus_type.id)
        .group(:mr_character_id)
        .count("DISTINCT mr_character_mushrooms.mushroom_id")

      selected_counts = usage_counts.select do |_character_id, used_count|
        used_count >= min_usage && (used_count.to_f / total_mushrooms) >= min_ratio
      end

      if selected_counts.empty?
        puts "  no candidates met thresholds"
        puts
        next
      end

      characters_by_id = MrCharacter.includes(:part).where(id: selected_counts.keys).index_by(&:id)
      ranked = selected_counts.map do |character_id, used_count|
        character = characters_by_id[character_id]
        next unless character

        coverage = ((used_count.to_f / total_mushrooms) * 100).round(1)
        [character, used_count, coverage]
      end.compact

      ranked.sort_by! { |(character, used_count, _coverage)| [-used_count, character.part&.name.to_s, character.name.to_s] }
      ranked = ranked.first(limit) if limit.positive?

      candidate_ids = ranked.map { |(character, _used_count, _coverage)| character.id }

      puts "  candidate core chars=#{candidate_ids.size}"
      ranked.first(10).each do |(character, used_count, coverage)|
        puts "    - #{character.id}: #{character.name} (#{used_count}/#{total_mushrooms}, #{coverage}%)"
      end

      unless apply_changes
        puts "  dry-run only (set APPLY=true to persist)"
        puts
        next
      end

      ActiveRecord::Base.transaction do
        if reset_sequence
          deleted_rows = CoreCharacterSequence.where(fungus_type_id: fungus_type.id).delete_all
          puts "  reset existing sequence rows=#{deleted_rows}"
        end

        core_marked = 0
        MrCharacter.where(id: candidate_ids).find_each do |character|
          next if character.core?

          character.core = true
          character.save!
          core_marked += 1
        end

        existing_ids = CoreCharacterSequence.where(fungus_type_id: fungus_type.id).pluck(:mr_character_id)
        next_sequence = CoreCharacterSequence.where(fungus_type_id: fungus_type.id).maximum(:sequence).to_i + 1

        rows = []
        (candidate_ids - existing_ids).each do |character_id|
          rows << {
            fungus_type_id: fungus_type.id,
            mr_character_id: character_id,
            sequence: next_sequence,
            created_at: Time.current,
            updated_at: Time.current
          }
          next_sequence += 1
        end

        CoreCharacterSequence.insert_all!(rows) if rows.any?
        puts "  applied core_marked=#{core_marked} sequence_added=#{rows.size}"
      end

      puts
    end

    puts "Bootstrap complete."
  end
end
