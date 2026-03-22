class Admin::DisplayOptionsController < Admin::ApplicationController
  include Pundit::Authorization
  # GET /display_options
  def index
    @display_options = policy_scope(DisplayOption)
    respond_to do |format|
      format.html
      format.json { render json: @display_options }
    end
  end

  # GET /display_options/1
  def show
    @display_option = authorize DisplayOption.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @display_option }
    end
  end

  # GET /display_options/new
  def new
    @display_option = DisplayOption.new
    # Allow access to new action for signed-in users without ownership requirement
    authorize @display_option, :new?
    respond_to do |format|
      format.html
      format.json { render json: @display_options }
    end
  end

  # GET /display_options/1/edit
  def edit
    @display_option = authorize DisplayOption.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @display_options }
      end
  end

  # POST /display_options
  def create
    @display_option = DisplayOption.new(display_option_params)
    authorize @display_option
    if @display_option.save
      redirect_to admin_display_option_url(@display_option), notice: "Display option was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /display_options/1
  def update
    @display_option = authorize DisplayOption.find(params[:id])
    if @display_option.update(display_option_params)
      redirect_to admin_display_option_url(@display_option), notice: "Display option was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /display_options/1
  def destroy
    @display_option = authorize DisplayOption.find(params[:id])
    @display_option.destroy!
    redirect_to admin_display_options_url, notice: "Display option was successfully deleted."
  end

  private

  def display_option_params
    params.expect(display_option: [:name, :description, :comments])
  end
end