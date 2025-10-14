require "test_helper"

class Admin::ImpersonationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    @user = users(:owner)
    sign_in_as_admin @admin
  end

  test "create starts impersonation" do
    post admin_impersonate_user_path(@user)

    assert_redirected_to app_root_path
    assert session[:impersonating_user_id].present?
    assert cookies[:session_id].present?
  end

  test "destroy stops impersonation" do
    # Start impersonation first
    post admin_impersonate_user_path(@user)

    # Stop impersonation
    delete admin_stop_impersonating_path

    assert_redirected_to admin_user_path(@user)
    assert_nil session[:impersonating_user_id]
  end

  test "requires admin auth" do
    delete admin_session_path
    post admin_impersonate_user_path(@user)
    assert_redirected_to new_admin_session_path
  end
end
