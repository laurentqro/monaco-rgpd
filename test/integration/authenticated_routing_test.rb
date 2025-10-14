require "test_helper"

class AuthenticatedRoutingTest < ActionDispatch::IntegrationTest
  test "unauthenticated root shows sign in page" do
    get "/"
    assert_response :success
  end

  test "authenticated root redirects to app" do
    user = users(:owner)
    sign_in_as user
    get "/"
    assert_redirected_to app_root_path
  end

  test "settings root redirects to profile" do
    user = users(:owner)
    sign_in_as user
    get "/settings"
    assert_redirected_to settings_profile_path
  end

  test "unauthenticated app access redirects to sign in" do
    get app_root_path
    assert_redirected_to new_session_path
  end

  test "unauthenticated settings access redirects to sign in" do
    get settings_profile_path
    assert_redirected_to new_session_path
  end
end
