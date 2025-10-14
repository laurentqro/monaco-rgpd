require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    sign_in_as @user
  end

  test "should get show" do
    get dashboard_url
    assert_response :success
  end
end
