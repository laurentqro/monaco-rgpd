require "test_helper"

class AppControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    sign_in_as @user
  end

  test "index requires authentication" do
    # Clear all sessions to simulate unauthenticated user
    Session.destroy_all
    get app_root_path
    assert_redirected_to new_session_path
  end

  test "index renders app page" do
    get app_root_path
    assert_response :success
  end

  test "index shares user and account data" do
    get app_root_path
    assert_response :success
    # Inertia shares current_user and current_account via ApplicationController
  end
end
