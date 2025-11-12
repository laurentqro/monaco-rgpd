require "test_helper"

class ActionItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as(@user)

    @action_item = ActionItem.create!(
      account: @account,
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :high,
      status: :pending,
      action_type: :update_treatment,
      title: "Test action item"
    )
  end

  test "update sets action item to completed" do
    patch action_item_path(@action_item), params: {
      action_item: { status: "completed" }
    }

    assert_redirected_to dashboard_path
    @action_item.reload
    assert_equal "completed", @action_item.status
  end

  test "update can dismiss action item" do
    patch action_item_path(@action_item), params: {
      action_item: { status: "dismissed" }
    }

    @action_item.reload
    assert_equal "dismissed", @action_item.status
  end

  test "update can snooze action item" do
    snooze_until = 3.days.from_now
    patch action_item_path(@action_item), params: {
      action_item: { snoozed_until: snooze_until }
    }

    @action_item.reload
    assert_in_delta snooze_until.to_i, @action_item.snoozed_until.to_i, 2
  end

  test "cannot update another account's action item" do
    other_account = accounts(:premium)
    other_item = ActionItem.create!(
      account: other_account,
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :medium,
      status: :pending,
      action_type: :generate_document,
      title: "Other account item"
    )

    patch action_item_path(other_item), params: {
      action_item: { status: "completed" }
    }

    assert_response :not_found
  end

  test "requires authentication" do
    delete session_path

    patch action_item_path(@action_item), params: {
      action_item: { status: "completed" }
    }

    assert_redirected_to new_session_path
  end
end
