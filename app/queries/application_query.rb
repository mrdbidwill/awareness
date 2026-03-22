# frozen_string_literal: true

# Base class for all query objects in the application.
# Query objects encapsulate complex ActiveRecord queries and scoping logic.
#
# Usage:
#   class MyQuery < ApplicationQuery
#     def initialize(scope = MyModel.all)
#       @scope = scope
#     end
#
#     def search(term)
#       @scope = @scope.where("name LIKE ?", "%#{term}%")
#       self
#     end
#
#     def recent
#       @scope = @scope.where("created_at > ?", 1.week.ago)
#       self
#     end
#
#     def results
#       @scope
#     end
#   end
#
#   results = MyQuery.new(policy_scope(MyModel))
#               .search(params[:q])
#               .recent
#               .results
class ApplicationQuery
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  # Return the final scope
  def results
    @scope
  end

  # Alias for results
  def to_a
    results.to_a
  end

  # Delegate common methods to the scope
  delegate :count, :any?, :empty?, :first, :last, :pluck, to: :results
end
