require "test_helper"

class UserEmailPreferencesTest < ActiveSupport::TestCase
  test "user has email_lifecycle_notifications enabled by default" do
    user = User.new(email: "test@example.com", account: accounts(:basic))
    assert user.email_lifecycle_notifications
  end

  test "user can opt out of lifecycle emails" do
    user = users(:owner)
    user.update!(email_lifecycle_notifications: false)
    assert_not user.email_lifecycle_notifications
  end
end
