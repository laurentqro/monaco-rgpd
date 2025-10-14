require "test_helper"

class AdminSessionTest < ActiveSupport::TestCase
  test "valid admin session" do
    session = AdminSession.new(
      admin: admins(:super_admin),
      user_agent: "Test Browser",
      ip_address: "127.0.0.1"
    )
    assert session.valid?
  end

  test "requires admin" do
    session = AdminSession.new(user_agent: "Test", ip_address: "127.0.0.1")
    assert_not session.valid?
  end

  test "belongs to admin" do
    session = admin_sessions(:one)
    assert_instance_of Admin, session.admin
  end
end
