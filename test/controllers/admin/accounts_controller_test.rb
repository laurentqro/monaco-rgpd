require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    @account = accounts(:basic)
    sign_in_as_admin @admin
  end

  test "index requires admin auth" do
    delete admin_session_path
    get admin_accounts_path
    assert_redirected_to new_admin_session_path
  end

  test "index lists all accounts" do
    get admin_accounts_path
    assert_response :success
  end

  test "index includes search" do
    get admin_accounts_path, params: { search: "test" }
    assert_response :success
  end

  test "show displays account details" do
    get admin_account_path(@account)
    assert_response :success
  end

  test "update modifies account" do
    patch admin_account_path(@account), params: {
      account: { name: "Updated Name" }
    }
    assert_redirected_to admin_account_path(@account)
    @account.reload
    assert_equal "Updated Name", @account.name
  end

  test "destroy deletes account" do
    assert_difference "Account.count", -1 do
      delete admin_account_path(@account)
    end
    assert_redirected_to admin_accounts_path
  end
end
