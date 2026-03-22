# test/models/admin_todo_test.rb
require "test_helper"

class AdminTodoTest < ActiveSupport::TestCase
  def setup
    @admin_todo = admin_todos(:one)
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    assert @admin_todo.valid?
  end

  test "should require title" do
    todo = AdminTodo.new(user: @user, done: false)
    assert_not todo.valid?
    assert_includes todo.errors.full_messages, "Title Title cannot be blank."
  end

  test "should require user" do
    todo = AdminTodo.new(title: "Test", done: false)
    assert_not todo.valid?
    assert_includes todo.errors[:user], "must exist"
  end

  test "should have default done value of false" do
    todo = AdminTodo.create!(title: "Test", user: @user)
    assert_equal false, todo.done
  end

  test "should allow optional description" do
    todo = AdminTodo.new(title: "Test", user: @user, description: nil)
    assert todo.valid?
  end

  test "should belong to user" do
    assert_respond_to @admin_todo, :user
    assert_instance_of User, @admin_todo.user
  end

  test "should have pending scope" do
    assert_respond_to AdminTodo, :pending
    pending_todos = AdminTodo.pending
    assert_includes pending_todos, admin_todos(:one)
    assert_not_includes pending_todos, admin_todos(:two)
  end

  test "should have completed scope" do
    assert_respond_to AdminTodo, :completed
    completed_todos = AdminTodo.completed
    assert_includes completed_todos, admin_todos(:two)
    assert_not_includes completed_todos, admin_todos(:one)
  end

  test "should have recent scope" do
    assert_respond_to AdminTodo, :recent
    recent_todos = AdminTodo.recent.to_a
    # Recent scope should order by done (false first) then created_at desc
    assert_equal false, recent_todos.first.done
  end

  test "mark_as_done! should set done to true" do
    todo = admin_todos(:one)
    assert_equal false, todo.done
    todo.mark_as_done!
    assert_equal true, todo.reload.done
  end

  test "mark_as_pending! should set done to false" do
    todo = admin_todos(:two)
    assert_equal true, todo.done
    todo.mark_as_pending!
    assert_equal false, todo.reload.done
  end

  test "should have timestamps" do
    assert_not_nil @admin_todo.created_at
    assert_not_nil @admin_todo.updated_at
  end
end
