require "test_helper"

class EventSubscribersTest < ActiveSupport::TestCase
  test "security events are subscribed" do
    listeners = ActiveSupport::Notifications.notifier.listeners_for("security.password_changed")
    assert listeners.any?, "Expected security.password_changed to have subscribers"
  end

  test "lifecycle events are subscribed" do
    listeners = ActiveSupport::Notifications.notifier.listeners_for("lifecycle.welcome")
    assert listeners.any?, "Expected lifecycle.welcome to have subscribers"
  end
end
