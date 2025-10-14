require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders sign in page" do
    get new_admin_session_path
    assert_response :success
  end

  test "create with valid credentials creates session and redirects" do
    admin = admins(:super_admin)

    post admin_session_path, params: {
      email: admin.email,
      password: "password123"
    }

    assert_redirected_to admin_root_path
    assert cookies[:admin_session_id].present?
  end

  test "create with invalid email shows error" do
    post admin_session_path, params: {
      email: "wrong@example.com",
      password: "password123"
    }

    assert_response :unprocessable_entity
  end

  test "create with invalid password shows error" do
    admin = admins(:super_admin)

    post admin_session_path, params: {
      email: admin.email,
      password: "wrong"
    }

    assert_response :unprocessable_entity
  end

  test "destroy signs out admin and redirects" do
    admin = admins(:super_admin)
    sign_in_as_admin admin

    delete admin_session_path

    assert_redirected_to new_admin_session_path
    assert cookies[:admin_session_id].blank?
  end
end
