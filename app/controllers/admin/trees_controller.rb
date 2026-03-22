class Admin::TreesController < Admin::ApplicationController
  before_action :set_tree, only: %i[show edit update destroy]

  # GET /trees
  def index
    authorize Tree
    @trees = policy_scope(Tree.order(:name))
  end

  # GET /trees/1
  def show
    authorize @tree
  end

  # GET /trees/new
  def new
    @tree = Tree.new
    authorize @tree
  end

  # POST /trees
  def create
    @tree = Tree.new(tree_params)
    authorize @tree
    if @tree.save
      redirect_to admin_tree_path(@tree), notice: "Tree was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /trees/1/edit
  def edit
    authorize @tree
  end

  # PATCH/PUT /trees/1
  def update
    authorize @tree
    if @tree.update(tree_params)
      redirect_to admin_tree_path(@tree), notice: "Tree was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trees/1
  def destroy
    authorize @tree
    @tree.destroy!
    redirect_to admin_trees_path, notice: "Tree was successfully deleted."
  end

  private

  def set_tree
    @tree = Tree.includes(:mushroom_trees).find(params.expect(:id))
  end

  def tree_params
    params.expect(tree: [:name, :description, :comments, :source])
  end
end
