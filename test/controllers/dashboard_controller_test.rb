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

  test "dashboard includes action items" do
    user = users(:owner)
    sign_in_as(user)

    # Create action items for this account
    ActionItem.create!(
      account: user.account,
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :high,
      status: :pending,
      action_type: :update_treatment,
      title: "High priority item"
    )

    ActionItem.create!(
      account: user.account,
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :low,
      status: :pending,
      action_type: :generate_document,
      title: "Low priority item"
    )

    get dashboard_path

    assert_response :success

    # Extract props from the rendered Inertia response
    # Inertia stores props in the response, we can access via the page object
    assert_match /action_items/, response.body, "Response should contain action_items data"
    assert_match /High priority item/, response.body, "Response should contain high priority item"
    assert_match /Low priority item/, response.body, "Response should contain low priority item"
  end
end
