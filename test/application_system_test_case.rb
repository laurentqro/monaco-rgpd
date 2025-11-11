require "test_helper"
require "capybara/rails"
require "capybara/minitest"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Use the sign_in_as helper from test_helper but adapted for system tests
  def sign_in_as(user)
    session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    # For system tests, we need to set the cookie through Capybara
    # First visit a public page to establish domain context (required by Selenium)
    visit new_session_path
    # Now set the signed session cookie
    page.driver.browser.manage.add_cookie(
      name: "session_id",
      value: sign_cookie(session.id)
    )
  end

  private

  def sign_cookie(value)
    secret = Rails.application.key_generator.generate_key("signed cookie")
    verifier = ActiveSupport::MessageVerifier.new(secret)
    verifier.generate(value)
  end
end
