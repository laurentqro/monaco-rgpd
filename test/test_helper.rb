# SimpleCov must be started BEFORE loading Rails environment
require "simplecov"
SimpleCov.start "rails" do
  # Filter out test files, config, and vendor code
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  # Filter out files that are pure framework boilerplate with no custom logic
  add_filter "app/channels/application_cable"

  # Group application code by type
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Jobs", "app/jobs"
  add_group "Mailers", "app/mailers"
  add_group "Concerns", "app/controllers/concerns"

  # Track coverage percentage
  # minimum_coverage 90  # Uncomment when ready to enforce coverage threshold

  # Enable branch coverage for better insights
  enable_coverage :branch
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::HtmlReporter.new(
    reports_dir: "tmp/test_reports",
    mode: :suite
  )
]

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)  # Disabled for accurate coverage

    # Setup all fixtures in test/fixtures/*.yml
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Helper method to sign in a user for integration tests
    def sign_in_as(user)
      session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
      # Generate signed cookie value using Rails' MessageVerifier with correct secret and salt
      # The salt must match what ActionDispatch::Cookies uses
      secret = Rails.application.key_generator.generate_key("signed cookie")
      verifier = ActiveSupport::MessageVerifier.new(secret)
      signed_value = verifier.generate(session.id)
      cookies[:session_id] = signed_value
    end

    # Helper method to sign in an admin for integration tests
    def sign_in_as_admin(admin)
      admin_session = admin.admin_sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
      secret = Rails.application.key_generator.generate_key("signed cookie")
      verifier = ActiveSupport::MessageVerifier.new(secret)
      signed_value = verifier.generate(admin_session.id)
      cookies[:admin_session_id] = signed_value
    end
  end
end
