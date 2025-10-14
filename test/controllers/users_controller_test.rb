require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    sign_in_as @user
  end

  test "update requires authentication" do
    Session.destroy_all
    patch user_path(@user), params: { user: { name: "New Name" } }
    assert_redirected_to new_session_path
  end

  test "update own profile successfully" do
    patch user_path(@user), params: { user: { name: "New Name" } }
    assert_redirected_to settings_profile_path
    @user.reload
    assert_equal "New Name", @user.name
  end

  test "update with valid email" do
    new_email = "newemail@example.com"
    patch user_path(@user), params: { user: { email: new_email } }
    assert_redirected_to settings_profile_path
    @user.reload
    assert_equal new_email, @user.email
  end

  test "update with invalid email" do
    patch user_path(@user), params: { user: { email: "invalid" } }
    assert_response :unprocessable_entity
  end

  test "cannot update another user's profile" do
    other_user = users(:admin)
    patch user_path(other_user), params: { user: { name: "Hacked" } }
    assert_redirected_to app_root_path
    other_user.reload
    assert_not_equal "Hacked", other_user.name
  end

  test "cannot change role via update" do
    original_role = @user.role
    patch user_path(@user), params: { user: { role: "admin" } }
    @user.reload
    assert_equal original_role, @user.role
  end
end
