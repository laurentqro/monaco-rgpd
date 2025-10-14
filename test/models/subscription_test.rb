require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "valid subscription" do
    subscription = Subscription.new(
      account: accounts(:basic),
      polar_subscription_id: "sub_123",
      status: "active",
      plan_name: "Pro Plan"
    )
    assert subscription.valid?
  end

  test "requires account" do
    subscription = Subscription.new(
      polar_subscription_id: "sub_123",
      status: "active"
    )
    assert_not subscription.valid?
    assert_includes subscription.errors[:account], "doit être rempli"
  end

  test "requires polar_subscription_id" do
    subscription = Subscription.new(
      account: accounts(:basic),
      status: "active"
    )
    assert_not subscription.valid?
    assert_includes subscription.errors[:polar_subscription_id], "doit être rempli"
  end

  test "requires status" do
    subscription = Subscription.new(
      account: accounts(:basic),
      polar_subscription_id: "sub_123"
    )
    assert_not subscription.valid?
    assert_includes subscription.errors[:status], "doit être rempli"
  end

  test "belongs to account" do
    subscription = subscriptions(:active)
    assert_respond_to subscription, :account
    assert_instance_of Account, subscription.account
  end

  test "active? returns true for active status" do
    subscription = subscriptions(:active)
    assert subscription.active?
  end

  test "active? returns false for cancelled status" do
    subscription = subscriptions(:cancelled)
    assert_not subscription.active?
  end

  test "cancelled? returns true when cancelled_at is set" do
    subscription = subscriptions(:cancelled)
    assert subscription.cancelled?
  end

  test "cancelled? returns false when cancelled_at is nil" do
    subscription = subscriptions(:active)
    assert_not subscription.cancelled?
  end

  test "trial? returns true for trialing status" do
    subscription = Subscription.create!(
      account: accounts(:basic),
      polar_subscription_id: "sub_trial",
      status: "trialing",
      plan_name: "Trial"
    )
    assert subscription.trial?
  end

  test "trial? returns false for active status" do
    subscription = subscriptions(:active)
    assert_not subscription.trial?
  end

  test "past_due? returns true for past_due status" do
    subscription = Subscription.create!(
      account: accounts(:basic),
      polar_subscription_id: "sub_past_due",
      status: "past_due",
      plan_name: "Pro"
    )
    assert subscription.past_due?
  end
end
