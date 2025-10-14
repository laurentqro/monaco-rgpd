require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "valid account" do
    account = Account.new(
      name: "Test Account",
      subdomain: "test-account"
    )
    assert account.valid?
  end

  test "requires name" do
    account = Account.new(subdomain: "test")
    assert_not account.valid?
    assert_includes account.errors[:name], "can't be blank"
  end

  test "requires subdomain" do
    account = Account.new(name: "Test")
    assert_not account.valid?
    assert_includes account.errors[:subdomain], "can't be blank"
  end

  test "subdomain must be unique" do
    Account.create!(name: "First", subdomain: "test")
    account = Account.new(name: "Second", subdomain: "test")
    assert_not account.valid?
    assert_includes account.errors[:subdomain], "has already been taken"
  end

  test "subdomain format validation" do
    account = Account.new(name: "Test", subdomain: "Test Account!")
    assert_not account.valid?
    assert_includes account.errors[:subdomain], "only allows lowercase letters, numbers, and hyphens"
  end

  test "has many users" do
    account = accounts(:basic)
    assert_respond_to account, :users
  end

  test "has many subscriptions" do
    account = accounts(:basic)
    assert_respond_to account, :subscriptions
  end

  test "has one active subscription" do
    account = accounts(:basic)
    assert_respond_to account, :active_subscription
  end

  test "belongs to owner" do
    account = accounts(:basic)
    assert_respond_to account, :owner
    assert_instance_of User, account.owner
  end

  test "subscribed? returns true with active subscription" do
    account = accounts(:basic)
    assert account.subscribed?
  end

  test "subscribed? returns false without active subscription" do
    account = Account.create!(name: "Free", subdomain: "free")
    assert_not account.subscribed?
  end

  test "onboarding_completed? returns true when completed" do
    account = accounts(:basic)
    account.update!(onboarding_completed_at: Time.current)
    assert account.onboarding_completed?
  end

  test "onboarding_completed? returns false when not completed" do
    account = Account.create!(name: "New", subdomain: "new")
    assert_not account.onboarding_completed?
  end

  # Monaco RGPD Tests
  test "should have valid account_type" do
    account = accounts(:basic)
    account.account_type = :solopreneur
    assert account.valid?
  end

  test "should have valid entity_type" do
    account = accounts(:basic)
    account.entity_type = :company
    assert account.valid?
  end

  test "should default to simple compliance_mode for solopreneur" do
    account = Account.create!(
      name: "Test Solopreneur",
      subdomain: "test-solo",
      account_type: :solopreneur
    )
    assert_equal "simple", account.compliance_mode
  end

  test "should require jurisdiction" do
    account = Account.new(name: "Test", subdomain: "test")
    account.jurisdiction = nil
    assert_not account.valid?
  end
end
