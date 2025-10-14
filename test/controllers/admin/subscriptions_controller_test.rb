require "test_helper"

class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    sign_in_as_admin @admin
  end

  test "index requires admin auth" do
    delete admin_session_path
    get admin_subscriptions_path
    assert_redirected_to new_admin_session_path
  end

  test "index lists all subscriptions" do
    get admin_subscriptions_path
    assert_response :success
  end

  test "index filters by status" do
    get admin_subscriptions_path, params: { status: "active" }
    assert_response :success
  end
end
