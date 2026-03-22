# frozen_string_literal: true

# Base class for all service objects in the application.
# Services encapsulate business logic that doesn't belong in models or controllers.
#
# Usage:
#   class MyService < ApplicationService
#     def initialize(user:, params:)
#       @user = user
#       @params = params
#     end
#
#     def call
#       # Business logic here
#       Result.success(data)
#     rescue => e
#       Result.failure(e.message)
#     end
#   end
#
#   result = MyService.call(user: current_user, params: params)
#   if result.success?
#     result.data
#   else
#     result.error
#   end
class ApplicationService
  # Class method that instantiates and calls the service
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end

  # Instance method to be implemented by subclasses
  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  # Result object for service responses
  class Result
    attr_reader :data, :error

    def initialize(success:, data: nil, error: nil)
      @success = success
      @data = data
      @error = error
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def self.success(data = nil)
      new(success: true, data: data)
    end

    def self.failure(error, data: nil)
      new(success: false, error: error, data: data)
    end
  end
end
