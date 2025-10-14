require "test_helper"

class Admin::AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    sign_in_as_admin @admin
  end

  test "index requires admin auth" do
    delete admin_session_path
    get admin_admins_path
    assert_redirected_to new_admin_session_path
  end

  test "index lists all admins" do
    get admin_admins_path
    assert_response :success
  end

  test "create creates new admin" do
    assert_difference "Admin.count", 1 do
      post admin_admins_path, params: {
        admin: {
          email: "newadmin@example.com",
          name: "New Admin",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to admin_admins_path
  end

  test "destroy deletes admin" do
    other_admin = Admin.create!(
      email: "other@example.com",
      name: "Other",
      password: "password123"
    )

    assert_difference "Admin.count", -1 do
      delete admin_admin_path(other_admin)
    end
    assert_redirected_to admin_admins_path
  end

  test "cannot delete self" do
    assert_no_difference "Admin.count" do
      delete admin_admin_path(@admin)
    end
    assert_redirected_to admin_admins_path
  end
end
