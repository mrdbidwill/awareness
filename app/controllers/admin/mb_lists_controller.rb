class Admin::MbListsController < Admin::ApplicationController
  include Pundit::Authorization

  # GET /mb_lists or /mb_lists.json
  def index
    @mb_lists = policy_scope(MbList)
    respond_to do |format|

      format.html
      format.json { render json: @mb_lists }
    end
  end

  # GET /mb_lists/1 or /mb_lists/1.json
  def show
    @mb_list = MbList.find(params[:id])
    authorize @mb_list
    respond_to do |format|

      format.html
      format.json { render json: @mb_list }
    end
  end


  # GET /mb_lists/new
  def new
    @mb_list = MbList.new
    # Allow access to new action for signed-in users without ownership requirement
    authorize @mb_list, :new?
    respond_to do |format|

      format.html
      format.json { render json: @mb_lists }
    end
  end

  # GET /mb_lists/1/edit
  def edit
    @mb_list = MbList.find(params[:id])
    authorize @mb_list
    respond_to do |format|

      format.html
      format.json { render json: @mb_list }
    end
  end


  # POST /mb_lists or /mb_lists.json
  def create
    @mb_list = MbList.new(mb_list_params)
    authorize @mb_list
    if @mb_list.save
      redirect_to admin_mb_list_url(@mb_list), notice: "MbList was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mb_lists/1 or /mb_lists/1.json
  def update
    @mb_list = MbList.find(params[:id])
    authorize @mb_list
    if @mb_list.update(mb_list_params)
      redirect_to admin_mb_list_url(@mb_list), notice: "MbList was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /mb_lists/1 or /mb_lists/1.json
  def destroy
    @mb_list = MbList.find(params[:id])
    authorize @mb_list
    @mb_list.destroy!
    redirect_to admin_mb_lists_path, notice: "MbList was successfully deleted."
  end


  private
  # Only allow a list of trusted parameters through.
  def mb_list_params
    params.expect(mb_list: [
      :mblist_id, :taxon_name, :authors, :rank_name,
      :year_of_effective_publication, :name_status, :mycobank_number,
      :hyperlink, :classification, :current_name, :synonymy
    ])
  end
end
