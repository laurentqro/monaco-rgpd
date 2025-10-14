require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "valid admin" do
    admin = Admin.new(
      email: "admin@example.com",
      name: "Admin User",
      password: "password123",
      password_confirmation: "password123"
    )
    assert admin.valid?
  end

  test "requires email" do
    admin = Admin.new(name: "Admin", password: "password123")
    assert_not admin.valid?
    assert_includes admin.errors[:email], "doit être rempli"
  end

  test "requires valid email format" do
    admin = Admin.new(email: "invalid", password: "password123")
    assert_not admin.valid?
  end

  test "email must be unique" do
    existing = admins(:super_admin)
    admin = Admin.new(email: existing.email, password: "password123")
    assert_not admin.valid?
    assert_includes admin.errors[:email], "n'est pas disponible"
  end

  test "requires password" do
    admin = Admin.new(email: "admin@example.com")
    assert_not admin.valid?
  end

  test "password must be at least 8 characters" do
    admin = Admin.new(email: "admin@example.com", password: "short")
    assert_not admin.valid?
  end

  test "has many admin sessions" do
    admin = admins(:super_admin)
    assert_respond_to admin, :admin_sessions
  end

  test "authenticates with correct password" do
    admin = admins(:super_admin)
    assert admin.authenticate("password123")
  end

  test "does not authenticate with wrong password" do
    admin = admins(:super_admin)
    assert_not admin.authenticate("wrong")
  end
end
