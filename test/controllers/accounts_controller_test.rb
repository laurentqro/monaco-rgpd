require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @owner = users(:owner)
    @admin = users(:admin)
    @member = users(:member)
  end

  test "update requires authentication" do
    patch account_path(@account), params: { account: { name: "New Name" } }
    assert_redirected_to new_session_path
  end

  test "owner can update account" do
    sign_in_as @owner
    patch account_path(@account), params: { account: { name: "New Account Name" } }
    assert_redirected_to settings_account_path
    @account.reload
    assert_equal "New Account Name", @account.name
  end

  test "admin can update account" do
    sign_in_as @admin
    patch account_path(@account), params: { account: { name: "Admin Changed" } }
    assert_redirected_to settings_account_path
    @account.reload
    assert_equal "Admin Changed", @account.name
  end

  test "member cannot update account" do
    sign_in_as @member
    patch account_path(@account), params: { account: { name: "Hacked" } }
    assert_redirected_to app_root_path
    @account.reload
    assert_not_equal "Hacked", @account.name
  end

  test "update with invalid subdomain" do
    sign_in_as @owner
    patch account_path(@account), params: { account: { subdomain: "Invalid Subdomain!" } }
    assert_response :unprocessable_entity
  end

  test "cannot update to duplicate subdomain" do
    other_account = accounts(:premium)
    sign_in_as @owner
    patch account_path(@account), params: { account: { subdomain: other_account.subdomain } }
    assert_response :unprocessable_entity
  end
end
