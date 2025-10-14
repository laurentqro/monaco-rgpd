require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      email: "test@example.com",
      name: "Test User",
      account: accounts(:basic)
    )
    assert user.valid?
  end

  test "requires email" do
    user = User.new(name: "Test", account: accounts(:basic))
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires account" do
    user = User.new(email: "test@example.com", name: "Test")
    assert_not user.valid?
    assert_includes user.errors[:account], "must exist"
  end

  test "email must be unique" do
    User.create!(email: "test@example.com", name: "First", account: accounts(:basic))
    user = User.new(email: "test@example.com", name: "Second", account: accounts(:basic))
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email format validation" do
    user = User.new(email: "invalid", name: "Test", account: accounts(:basic))
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "belongs to account" do
    user = users(:owner)
    assert_respond_to user, :account
    assert_instance_of Account, user.account
  end

  test "has many magic links" do
    user = users(:owner)
    assert_respond_to user, :magic_links
  end

  test "has many sessions" do
    user = users(:owner)
    assert_respond_to user, :sessions
  end

  test "default role is member" do
    user = User.create!(email: "newmember@example.com", name: "New Member", account: accounts(:basic))
    assert user.member?
  end

  test "can be admin" do
    user = users(:admin)
    assert user.admin?
  end

  test "can be owner" do
    user = users(:owner)
    assert user.owner?
  end

  test "admin? returns true for admin and owner" do
    assert users(:admin).admin?
    assert users(:owner).admin?
  end

  test "admin? returns false for member" do
    user = User.create!(email: "testmember@example.com", name: "Test Member", account: accounts(:basic), role: :member)
    assert_not user.admin?
  end
end
