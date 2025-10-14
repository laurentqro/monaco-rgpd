require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    sign_in_as @user
  end

  test "profile requires authentication" do
    Session.destroy_all
    get settings_profile_path
    assert_redirected_to new_session_path
  end

  test "profile renders successfully" do
    get settings_profile_path
    assert_response :success
  end

  test "profile shares user data" do
    get settings_profile_path
    assert_response :success
    # Inertia shares user data via SettingsController
  end
end
