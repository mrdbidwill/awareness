class Admin::CoreCharacterSequencesController < Admin::ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, raise: false
  skip_after_action :verify_authorized, raise: false

  def index
    @fungus_types = FungusType.order(:name)
    @selected_fungus_type_id = params[:fungus_type_id].presence || @fungus_types.first&.id

    @characters = MrCharacter
      .includes(:part, :observation_method)
      .where("JSON_EXTRACT(properties, '$.core') = true")
      .where(fungus_type_id: [nil, @selected_fungus_type_id])
      .where.not(display_option_id: 1)

    seq_map = CoreCharacterSequence
      .where(fungus_type_id: @selected_fungus_type_id)
      .pluck(:mr_character_id, :sequence)
      .to_h

    @characters = @characters.to_a
    @characters = MrCharacter.sort_for_core_display(@characters, keep_part_order: false, fungus_type_id: @selected_fungus_type_id)
    @sequence_map = seq_map
  end

  def update
    updates = (params[:core_sequences] || {}).to_unsafe_h
    fungus_type_id = params[:fungus_type_id]

    CoreCharacterSequence.where(fungus_type_id: fungus_type_id).delete_all

    rows = updates.map do |character_id, seq|
      value = seq.to_s.strip
      next if value.blank?
      { fungus_type_id: fungus_type_id, mr_character_id: character_id, sequence: value.to_i, created_at: Time.current, updated_at: Time.current }
    end.compact

    CoreCharacterSequence.insert_all!(rows) if rows.any?

    redirect_to admin_core_character_sequences_path(fungus_type_id: fungus_type_id),
                notice: "Core character sequence saved.",
                status: :see_other
  end
end
