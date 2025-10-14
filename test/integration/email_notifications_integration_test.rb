require "test_helper"

class EmailNotificationsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @collaborator = users(:member)

    # Clear any previous subscriptions to ensure clean state
    ActiveSupport::Notifications.notifier.listeners_for("security.password_changed").clear
    ActiveSupport::Notifications.notifier.listeners_for("security.suspicious_login").clear
    ActiveSupport::Notifications.notifier.listeners_for("security.account_deletion_requested").clear
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.welcome").clear
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.user_invited").clear
    ActiveSupport::Notifications.notifier.listeners_for("lifecycle.role_changed").clear

    # Subscribe the subscribers
    SecurityMailerSubscriber.subscribe!
    LifecycleMailerSubscriber.subscribe!
  end

  # Security Email Tests - These should ALWAYS send regardless of preferences

  test "password change triggers email regardless of preferences being disabled" do
    @user.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "security.password_changed",
        user: @user
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "security.password_changed",
        user: @user
      )
    end

    assert_emails 1
  end

  test "suspicious login triggers email regardless of preferences" do
    @user.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: "192.168.1.1",
        user_agent: "Chrome on MacOS"
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: "192.168.1.1",
        user_agent: "Chrome on MacOS"
      )
    end

    assert_emails 1
  end

  test "account deletion triggers email regardless of preferences" do
    @user.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "security.account_deletion_requested",
        user: @user
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "security.account_deletion_requested",
        user: @user
      )
    end

    assert_emails 1
  end

  # Lifecycle Email Tests - These should respect user preferences

  test "welcome email sends when user has lifecycle emails enabled" do
    @user.update!(email_lifecycle_notifications: true)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.welcome",
        user: @user
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.welcome",
        user: @user
      )
    end

    assert_emails 1
  end

  test "welcome email does not send when user has lifecycle emails disabled" do
    @user.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.welcome",
        user: @user
      )
    end

    # Verify no email is delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.welcome",
        user: @user
      )
    end

    assert_no_emails
  end

  test "user invited email sends when invitee has lifecycle emails enabled" do
    @collaborator.update!(email_lifecycle_notifications: true)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.user_invited",
        invitee: @collaborator,
        inviter: @user,
        organization_name: "TestCo"
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.user_invited",
        invitee: @collaborator,
        inviter: @user,
        organization_name: "TestCo"
      )
    end

    assert_emails 1
  end

  test "user invited email does not send when invitee has lifecycle emails disabled" do
    @collaborator.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.user_invited",
        invitee: @collaborator,
        inviter: @user,
        organization_name: "TestCo"
      )
    end

    # Verify no email is delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.user_invited",
        invitee: @collaborator,
        inviter: @user,
        organization_name: "TestCo"
      )
    end

    assert_no_emails
  end

  test "role changed email sends when user has lifecycle emails enabled" do
    @user.update!(email_lifecycle_notifications: true)

    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    # Verify the email is actually delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    assert_emails 1
  end

  test "role changed email does not send when user has lifecycle emails disabled" do
    @user.update!(email_lifecycle_notifications: false)

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    # Verify no email is delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    assert_no_emails
  end

  # Settings Page Integration Tests

  test "user can disable lifecycle emails via settings page and emails stop sending" do
    sign_in_as @user
    @user.update!(email_lifecycle_notifications: true)

    # Disable lifecycle emails via settings page
    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: false }
    }

    assert_redirected_to settings_notifications_url
    @user.reload
    assert_not @user.email_lifecycle_notifications, "Lifecycle notifications should be disabled"

    # Verify lifecycle emails are no longer sent
    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
    end

    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
    end

    assert_no_emails
  end

  test "user can enable lifecycle emails via settings page and emails start sending" do
    sign_in_as @user
    @user.update!(email_lifecycle_notifications: false)

    # Enable lifecycle emails via settings page
    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: true }
    }

    assert_redirected_to settings_notifications_url
    @user.reload
    assert @user.email_lifecycle_notifications, "Lifecycle notifications should be enabled"

    # Verify lifecycle emails are now sent
    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
    end

    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
    end

    assert_emails 1
  end

  test "security emails continue to send even when lifecycle emails are disabled via settings" do
    sign_in_as @user
    @user.update!(email_lifecycle_notifications: true)

    # Disable lifecycle emails
    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: false }
    }

    @user.reload
    assert_not @user.email_lifecycle_notifications

    # Verify security emails still send
    assert_enqueued_emails 1 do
      ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
    end

    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
    end

    assert_emails 1
  end

  # Edge Cases

  test "does not send emails when user is nil" do
    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument("security.password_changed", user: nil)
    end

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: nil)
    end
  end

  test "does not send user invited email when invitee is nil" do
    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.user_invited",
        invitee: nil,
        inviter: @user,
        organization_name: "TestCo"
      )
    end
  end

  test "does not send suspicious login email when ip_address or user_agent is missing" do
    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: nil,
        user_agent: "Chrome"
      )
    end

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: "192.168.1.1",
        user_agent: nil
      )
    end
  end

  test "does not send role changed email when role information is missing" do
    @user.update!(email_lifecycle_notifications: true)

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: nil,
        new_role: "admin"
      )
    end

    assert_enqueued_emails 0 do
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: nil
      )
    end
  end

  test "multiple events can be processed and delivered correctly" do
    @user.update!(email_lifecycle_notifications: true)

    # Enqueue multiple different emails
    assert_enqueued_emails 4 do
      ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: "192.168.1.1",
        user_agent: "Chrome"
      )
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    # Verify all emails are delivered
    perform_enqueued_jobs do
      ActiveSupport::Notifications.instrument("security.password_changed", user: @user)
      ActiveSupport::Notifications.instrument("lifecycle.welcome", user: @user)
      ActiveSupport::Notifications.instrument(
        "security.suspicious_login",
        user: @user,
        ip_address: "192.168.1.1",
        user_agent: "Chrome"
      )
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: "member",
        new_role: "admin"
      )
    end

    assert_emails 4
  end
end
