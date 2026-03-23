# frozen_string_literal: true

# app/helpers/application_helper.rb
module ApplicationHelper
  # Include Pundit methods for use in views
  include Pundit::Authorization

  # Returns the list of rendered templates/partials collected for this request
  def rendered_views_debug
    Array(Thread.current[:rendered_views]).uniq
  end
end
