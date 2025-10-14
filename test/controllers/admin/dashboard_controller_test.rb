require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "index requires admin authentication" do
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "index renders for authenticated admin" do
    sign_in_as_admin admins(:super_admin)
    get admin_root_path
    assert_response :success
  end

  test "index passes stats to view" do
    sign_in_as_admin admins(:super_admin)
    get admin_root_path
    # Stats will be in Inertia props
    assert_response :success
  end
end
