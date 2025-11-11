require "test_helper"

class LifecycleEventsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    @account = accounts(:basic)
  end

  test "welcome event is published when new user is created via magic link" do
    event_published = false
    user_from_event = nil

    ActiveSupport::Notifications.subscribe("lifecycle.welcome") do |_name, _start, _finish, _id, payload|
      event_published = true
      user_from_event = payload[:user]
    end

    # Create magic link for new user (this triggers user creation)
    post magic_links_path, params: {
      email: "newuser@example.com",
      name: "New User",
      account_name: "New Account"
    }

    # Get the magic link token that was created
    magic_link = MagicLink.find_by(user: User.find_by(email: "newuser@example.com"))
    assert_not_nil magic_link, "Magic link should be created"

    # Verify the magic link (this triggers the welcome event on first login)
    get verify_magic_link_path(token: magic_link.token)

    assert event_published, "Expected lifecycle.welcome event to be published"
    assert_not_nil user_from_event
    assert_equal "newuser@example.com", user_from_event.email
  end

  test "role changed event is published when user role is updated" do
    sign_in_as_admin @admin
    target_user = users(:member)
    original_role = target_user.role

    event_published = false
    captured_old_role = nil
    captured_new_role = nil

    ActiveSupport::Notifications.subscribe("lifecycle.role_changed") do |_name, _start, _finish, _id, payload|
      event_published = true
      captured_old_role = payload[:old_role]
      captured_new_role = payload[:new_role]
    end

    # Update user role via admin interface
    patch admin_user_path(target_user), params: { user: { role: "admin" } }

    assert event_published, "Expected lifecycle.role_changed event to be published"
    assert_equal original_role, captured_old_role
    assert_equal "admin", captured_new_role
  end

  test "role changed event is not published when role stays the same" do
    sign_in_as_admin @admin
    target_user = users(:admin)
    current_role = target_user.role

    event_published = false

    ActiveSupport::Notifications.subscribe("lifecycle.role_changed") do |_name, _start, _finish, _id, payload|
      event_published = true
    end

    # Update user with same role
    patch admin_user_path(target_user), params: { user: { name: "Different Name" } }

    assert_not event_published, "Expected lifecycle.role_changed event NOT to be published when role unchanged"
  end
end
