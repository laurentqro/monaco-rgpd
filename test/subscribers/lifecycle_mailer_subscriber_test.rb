require "test_helper"

class LifecycleMailerSubscriberTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  # Use class-level setup to initialize subscriber once
  def self.startup
    # Clear any existing listeners before setting up
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.welcome").clear
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.user_invited").clear
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.role_changed").clear

    # Subscribe once for all tests
    LifecycleMailerSubscriber.subscribe!
  end

  setup do
    @user = users(:owner)
  end

  test "sends welcome email when user has lifecycle emails enabled" do
    @user.update!(email_lifecycle_notifications: true)

    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
      end
    end
  end

  test "does not send welcome email when user has lifecycle emails disabled" do
    @user.update!(email_lifecycle_notifications: false)

    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
      end
    end
  end

  test "sends user invited email when invitee has lifecycle emails enabled" do
    invitee = users(:member)
    inviter = @user
    invitee.update!(email_lifecycle_notifications: true)

    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument(
          "lifecycle.user_invited",
          invitee: invitee,
          inviter: inviter,
          organization_name: "TestCo"
        )
      end
    end
  end

  test "does not send user invited email when invitee has lifecycle emails disabled" do
    invitee = users(:member)
    inviter = @user
    invitee.update!(email_lifecycle_notifications: false)

    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument(
          "lifecycle.user_invited",
          invitee: invitee,
          inviter: inviter,
          organization_name: "TestCo"
        )
      end
    end
  end

  test "sends role changed email when user has lifecycle emails enabled" do
    @user.update!(email_lifecycle_notifications: true)

    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument(
          "lifecycle.role_changed",
          user: @user,
          old_role: "admin",
          new_role: "member"
        )
      end
    end
  end

  test "does not send role changed email when user has lifecycle emails disabled" do
    @user.update!(email_lifecycle_notifications: false)

    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument(
          "lifecycle.role_changed",
          user: @user,
          old_role: "admin",
          new_role: "member"
        )
      end
    end
  end

  test "ignores events with missing user" do
    perform_enqueued_jobs do
      assert_no_emails do
        ActiveSupport::Notifications.instrument("lifecycle.welcome", user: nil)
      end
    end
  end

  test "prevents duplicate subscriptions" do
    # Get initial listener counts
    initial_welcome_count = ActiveSupport::Notifications.notifier.listeners_for("lifecycle.welcome").size
    initial_invited_count = ActiveSupport::Notifications.notifier.listeners_for("lifecycle.user_invited").size
    initial_role_count = ActiveSupport::Notifications.notifier.listeners_for("lifecycle.role_changed").size

    # Try to subscribe again (should be ignored due to guard)
    LifecycleMailerSubscriber.subscribe!

    # Listener counts should remain the same
    assert_equal initial_welcome_count, ActiveSupport::Notifications.notifier.listeners_for("lifecycle.welcome").size
    assert_equal initial_invited_count, ActiveSupport::Notifications.notifier.listeners_for("lifecycle.user_invited").size
    assert_equal initial_role_count, ActiveSupport::Notifications.notifier.listeners_for("lifecycle.role_changed").size

    # Verify we still only send one email per event
    @user.update!(email_lifecycle_notifications: true)
    perform_enqueued_jobs do
      assert_emails 1 do
        ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
      end
    end
  end
end

# Initialize subscriber before running tests
LifecycleMailerSubscriberTest.startup
