require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "Current.user delegates to session.user" do
    user = users(:owner)
    session = user.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")

    Current.session = session
    assert_equal user, Current.user
  end

  test "Current.user returns nil when session is nil" do
    Current.session = nil
    assert_nil Current.user
  end

  test "Current.account delegates to user.account" do
    user = users(:owner)
    account = accounts(:basic)
    session = user.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")

    Current.session = session
    assert_equal account, Current.account
  end

  test "Current.account returns nil when user is nil" do
    Current.session = nil
    assert_nil Current.account
  end

  test "Current.admin returns nil when admin_session is nil" do
    Current.admin_session = nil
    assert_nil Current.admin
  end

  test "Current.admin delegates to admin_session.admin" do
    admin = admins(:super_admin)
    admin_session = admin_sessions(:one)
    Current.admin_session = admin_session
    assert_equal admin, Current.admin
  end
end
