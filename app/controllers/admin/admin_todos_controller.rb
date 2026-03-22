# frozen_string_literal: true

module Admin
  class AdminTodosController < Admin::ApplicationController
    before_action :set_admin_todo, only: %i[show edit update destroy]

    # GET /admin/admin_todos
    def index
      authorize AdminTodo
      @admin_todos = policy_scope(AdminTodo)
                       .includes(:user)
                       .recent
                       .page(params[:page])
                       .per(50)
    end

    # GET /admin/admin_todos/:id
    def show
      authorize @admin_todo
    end

    # GET /admin/admin_todos/new
    def new
      @admin_todo = AdminTodo.new
      authorize @admin_todo
    end

    # POST /admin/admin_todos
    def create
      @admin_todo = AdminTodo.new(admin_todo_params)
      @admin_todo.user = current_user
      authorize @admin_todo

      if @admin_todo.save
        redirect_to admin_admin_todos_path, notice: "To Do created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/admin_todos/:id/edit
    def edit
      authorize @admin_todo
    end

    # PATCH/PUT /admin/admin_todos/:id
    def update
      authorize @admin_todo

      if @admin_todo.update(admin_todo_params)
        redirect_to admin_admin_todos_path, notice: "To Do updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/admin_todos/:id
    def destroy
      authorize @admin_todo
      @admin_todo.destroy
      redirect_to admin_admin_todos_path, notice: "To Do deleted."
    end

    private

    def set_admin_todo
      @admin_todo = AdminTodo.includes(:user).find(params[:id])
    end

    def admin_todo_params
      params.require(:admin_todo).permit(
        :title,
        :description,
        :done
      )
    end
  end
end
