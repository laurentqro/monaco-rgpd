require "test_helper"

class SecurityEventsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = accounts(:basic)
  end

  test "suspicious login event is published when login from new IP" do
    # Create a session from a known IP
    @user.sessions.create!(user_agent: "Chrome", ip_address: "192.168.1.1")

    event_published = false
    captured_payload = nil

    ActiveSupport::Notifications.subscribe("security.suspicious_login") do |_name, _start, _finish, _id, payload|
      event_published = true
      captured_payload = payload
    end

    # Simulate magic link verification from different IP - this should trigger suspicious login
    magic_link = @user.magic_links.new
    magic_link.generate_token
    magic_link.save!

    get verify_magic_link_path(token: magic_link.token), headers: { "REMOTE_ADDR" => "10.0.0.1" }

    assert event_published, "Expected security.suspicious_login event to be published"
    assert_equal @user.id, captured_payload[:user].id
    assert_equal "10.0.0.1", captured_payload[:ip_address]
  end

  test "suspicious login event is not published when login from known IP" do
    # Create a session from a known IP
    @user.sessions.create!(user_agent: "Chrome", ip_address: "192.168.1.1", created_at: 2.days.ago)

    event_published = false

    ActiveSupport::Notifications.subscribe("security.suspicious_login") do |_name, _start, _finish, _id, payload|
      event_published = true
    end

    # Simulate magic link verification from same IP - should NOT trigger suspicious login
    magic_link = @user.magic_links.new
    magic_link.generate_token
    magic_link.save!

    get verify_magic_link_path(token: magic_link.token), headers: { "REMOTE_ADDR" => "192.168.1.1" }

    assert_not event_published, "Expected security.suspicious_login event NOT to be published for known IP"
  end

  test "account deletion event is published when account is destroyed" do
    sign_in_as_admin admins(:super_admin)
    target_account = accounts(:premium)
    target_users = target_account.users.to_a

    events_published = []

    ActiveSupport::Notifications.subscribe("security.account_deletion_requested") do |_name, _start, _finish, _id, payload|
      events_published << payload[:user]
    end

    delete admin_account_path(target_account)

    # All users in the account should receive deletion notification
    assert events_published.size > 0, "Expected account deletion events to be published"
  end

  test "user deletion event is published when user is destroyed by admin" do
    sign_in_as_admin admins(:super_admin)
    target_user = users(:admin)

    event_published = false
    captured_payload = nil

    ActiveSupport::Notifications.subscribe("security.account_deletion_requested") do |_name, _start, _finish, _id, payload|
      event_published = true
      captured_payload = payload
    end

    delete admin_user_path(target_user)

    assert event_published, "Expected security.account_deletion_requested event to be published"
    assert_equal target_user.id, captured_payload[:user].id
  end
end
