# Start simplecov if testing on CirclCI
if ENV['CIRCLE_ARTIFACTS']
  # Initialize simplecov code coverage gem
  require 'simplecov'
  SimpleCov.start 'rails'
end

# Core Rails minitest initialization
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Initialize minitest reporters gem
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include ApplicationHelper

  # Returns true if a test user is logged in.
  def logged_in?
    !session[:user_id].nil?
  end

  # Log in as a particular user.
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # Log in as a particular user.
  def log_in_as(user, password: 'password', remember_me: '1')
    post log_in_path, params: { session: { email: user.email, password: password, remember_me: remember_me } }
  end
end
