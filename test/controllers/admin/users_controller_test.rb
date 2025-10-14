require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    @user = users(:owner)
    sign_in_as_admin @admin
  end

  test "index requires admin auth" do
    delete admin_session_path
    get admin_users_path
    assert_redirected_to new_admin_session_path
  end

  test "index lists all users" do
    get admin_users_path
    assert_response :success
  end

  test "index includes search" do
    get admin_users_path, params: { search: "test" }
    assert_response :success
  end

  test "show displays user details" do
    get admin_user_path(@user)
    assert_response :success
  end

  test "update modifies user" do
    patch admin_user_path(@user), params: {
      user: { name: "Updated Name" }
    }
    assert_redirected_to admin_user_path(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
  end

  test "destroy deletes user" do
    assert_difference "User.count", -1 do
      delete admin_user_path(@user)
    end
    assert_redirected_to admin_users_path
  end
end
