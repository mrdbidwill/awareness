require "test_helper"

class Admin::AdminTodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_todo = admin_todos(:one)
    @user = users(:one)
    # User already has permission_id: 1 (admin) from fixtures
    sign_in @user
  end

  test "should get index" do
    get admin_admin_todos_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_admin_todo_url
    assert_response :success
  end

  test "should create admin_todo" do
    assert_difference("AdminTodo.count") do
      post admin_admin_todos_url, params: {
        admin_todo: {
          title: "New Test To Do",
          description: "Test description",
          done: false
        }
      }
    end

    assert_redirected_to admin_admin_todos_url
    assert_equal "To Do created.", flash[:notice]
  end

  test "should not create admin_todo without title" do
    assert_no_difference("AdminTodo.count") do
      post admin_admin_todos_url, params: {
        admin_todo: {
          title: "",
          description: "Test description",
          done: false
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show admin_todo" do
    get admin_admin_todo_url(@admin_todo)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_admin_todo_url(@admin_todo)
    assert_response :success
  end

  test "should update admin_todo" do
    patch admin_admin_todo_url(@admin_todo), params: {
      admin_todo: {
        title: "Updated Title",
        description: @admin_todo.description,
        done: @admin_todo.done
      }
    }
    assert_redirected_to admin_admin_todos_url
    assert_equal "To Do updated.", flash[:notice]
  end

  test "should update admin_todo to mark as done" do
    patch admin_admin_todo_url(@admin_todo), params: {
      admin_todo: {
        title: @admin_todo.title,
        description: @admin_todo.description,
        done: true
      }
    }
    assert_redirected_to admin_admin_todos_url
    assert @admin_todo.reload.done
  end

  test "should not update admin_todo with invalid data" do
    patch admin_admin_todo_url(@admin_todo), params: {
      admin_todo: {
        title: "",
        description: @admin_todo.description,
        done: @admin_todo.done
      }
    }
    assert_response :unprocessable_entity
  end

  test "should destroy admin_todo" do
    assert_difference("AdminTodo.count", -1) do
      delete admin_admin_todo_url(@admin_todo)
    end

    assert_redirected_to admin_admin_todos_url
    assert_equal "To Do deleted.", flash[:notice]
  end

  test "should require authentication" do
    sign_out @user

    get admin_admin_todos_url
    assert_redirected_to new_user_session_url
  end

  test "should assign current_user when creating todo" do
    post admin_admin_todos_url, params: {
      admin_todo: {
        title: "Test Todo",
        description: "Test",
        done: false
      }
    }

    new_todo = AdminTodo.last
    assert_equal @user.id, new_todo.user_id
  end
end
