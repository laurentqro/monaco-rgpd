require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "valid notification" do
    notification = Notification.new(
      user: users(:owner),
      notifiable: subscriptions(:active),
      notification_type: "subscription_updated",
      title: "Subscription Updated",
      message: "Your subscription has been updated"
    )
    assert notification.valid?
  end

  test "requires user" do
    notification = Notification.new(
      notifiable: subscriptions(:active),
      notification_type: "test",
      title: "Test"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:user], "must exist"
  end

  test "requires notification_type" do
    notification = Notification.new(
      user: users(:owner),
      title: "Test"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:notification_type], "can't be blank"
  end

  test "requires title" do
    notification = Notification.new(
      user: users(:owner),
      notification_type: "test"
    )
    assert_not notification.valid?
    assert_includes notification.errors[:title], "can't be blank"
  end

  test "belongs to user" do
    notification = notifications(:unread)
    assert_respond_to notification, :user
    assert_instance_of User, notification.user
  end

  test "belongs to notifiable polymorphically" do
    notification = notifications(:unread)
    assert_respond_to notification, :notifiable
  end

  test "read? returns true when read_at is set" do
    notification = notifications(:read)
    assert notification.read?
  end

  test "read? returns false when read_at is nil" do
    notification = notifications(:unread)
    assert_not notification.read?
  end

  test "unread scope returns only unread notifications" do
    unread_count = Notification.unread.count
    assert unread_count > 0
    Notification.unread.each do |notification|
      assert_not notification.read?
    end
  end

  test "mark_as_read! sets read_at" do
    notification = notifications(:unread)
    notification.mark_as_read!
    assert_not_nil notification.read_at
    assert notification.read?
  end
end
