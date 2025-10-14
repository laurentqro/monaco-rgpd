require "test_helper"

class SecurityMailerSubscriberTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  # Use class-level setup to initialize subscriber once
  def self.startup
    # Clear any existing listeners before setting up
    ActiveSupport::Notifications.notifier.listeners_for("security.password_changed").clear
    ActiveSupport::Notifications.notifier.listeners_for("security.suspicious_login").clear
    ActiveSupport::Notifications.notifier.listeners_for("security.account_deletion_requested").clear

    # Subscribe once for all tests
    SecurityMailerSubscriber.subscribe!
  end

  setup do
    @user = users(:owner)
  end

  test "sends password changed email on security.password_changed event" do
    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
      end
    end
  end

  test "sends suspicious login email on security.suspicious_login event" do
    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument(
          "security.suspicious_login",
          user: @user,
          ip_address: "192.168.1.1",
          user_agent: "Chrome on MacOS"
        )
      end
    end
  end

  test "sends account deletion email on security.account_deletion_requested event" do
    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument("security.account_deletion_requested", user: @user)
      end
    end
  end

  test "ignores events with missing user" do
    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument("security.password_changed", user: nil)
      end
    end
  end

  test "ignores suspicious login events with missing ip_address" do
    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument(
          "security.suspicious_login",
          user: @user,
          ip_address: nil,
          user_agent: "Chrome on MacOS"
        )
      end
    end
  end

  test "ignores suspicious login events with missing user_agent" do
    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument(
          "security.suspicious_login",
          user: @user,
          ip_address: "192.168.1.1",
          user_agent: nil
        )
      end
    end
  end

  test "prevents duplicate subscriptions" do
    # Get initial listener counts
    initial_password_count = ActiveSupport::Notifications.notifier.listeners_for("security.password_changed").size
    initial_suspicious_count = ActiveSupport::Notifications.notifier.listeners_for("security.suspicious_login").size
    initial_deletion_count = ActiveSupport::Notifications.notifier.listeners_for("security.account_deletion_requested").size

    # Try to subscribe again (should be ignored due to guard)
    SecurityMailerSubscriber.subscribe!

    # Listener counts should remain the same
    assert_equal initial_password_count, ActiveSupport::Notifications.notifier.listeners_for("security.password_changed").size
    assert_equal initial_suspicious_count, ActiveSupport::Notifications.notifier.listeners_for("security.suspicious_login").size
    assert_equal initial_deletion_count, ActiveSupport::Notifications.notifier.listeners_for("security.account_deletion_requested").size

    # Verify we still only send one email per event
    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
      end
    end
  end
end

# Initialize subscriber before running tests
SecurityMailerSubscriberTest.startup
