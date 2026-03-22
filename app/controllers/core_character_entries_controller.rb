class CoreCharacterEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mushroom
  before_action :authorize_mushroom!

  def show
    core_only = params[:core_only].to_s != "false"
    return redirect_to(edit_mushroom_path(@mushroom, core_only: false)) unless core_only

    @core_characters = core_characters_for(@mushroom)
    if @core_characters.empty?
      redirect_to edit_mushroom_path(@mushroom, core_only: false),
                  alert: "No core characters defined. Showing all instead.",
                  status: :see_other
      return
    end

    focus_character_id = params[:focus_character_id].presence
    if focus_character_id
      found_index = @core_characters.index { |c| c.id.to_s == focus_character_id.to_s }
      @index = found_index || 0
    else
      @index = params[:index].to_i
      @index = 0 if @index.negative?
      @index = [@index, @core_characters.length - 1].min
    end

    @character = @core_characters[@index]
    @total = @core_characters.length
    @return_to = params[:return_to].presence
    @stay_url = mushroom_core_character_entry_path(
      @mushroom,
      index: @index,
      core_only: true,
      return_to: @return_to
    )
    @done_url = @return_to.presence || edit_mushroom_path(@mushroom, core_only: true)

    @character_mushroom = MrCharacterMushroom.find_by(
      mushroom_id: @mushroom.id,
      mr_character_id: @character.id
    )
  end

  private

  def set_mushroom
    @mushroom = Mushroom.includes(
      :fungus_type,
      mr_character_mushrooms: { mr_character: [:part, :display_option, :source_data] }
    ).find(params[:mushroom_id])
  end

  def authorize_mushroom!
    authorize @mushroom, :update?
  end

  def core_characters_for(mushroom)
    scope = if mushroom.fungus_type_id.present?
              MrCharacter.for_fungus_type(mushroom.fungus_type_id)
            else
              MrCharacter.all
            end

    chars = scope.includes(:part, :observation_method, :display_option, :source_data, :lookup_items)
      .where("JSON_EXTRACT(properties, '$.core') = true")
      .where.not(display_option_id: 1)
      .to_a

    core_chars = MrCharacter.select_core_for_display(chars, fungus_type_id: mushroom.fungus_type_id)
    MrCharacter.sort_for_core_display(core_chars, keep_part_order: false, fungus_type_id: mushroom.fungus_type_id)
  end
end
