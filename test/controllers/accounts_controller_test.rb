require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @owner = users(:owner)
    @admin = users(:admin)
    @member = users(:member)
  end

  test "update requires authentication" do
    patch account_path, params: { account: { name: "New Name" } }
    assert_redirected_to new_session_path
  end

  test "owner can update account" do
    sign_in_as @owner
    patch account_path, params: { account: { name: "New Account Name" } }
    assert_redirected_to settings_account_path
    @account.reload
    assert_equal "New Account Name", @account.name
  end

  test "admin can update account" do
    sign_in_as @admin
    patch account_path, params: { account: { name: "Admin Changed" } }
    assert_redirected_to settings_account_path
    @account.reload
    assert_equal "Admin Changed", @account.name
  end

  test "member cannot update account" do
    sign_in_as @member
    patch account_path, params: { account: { name: "Hacked" } }
    assert_redirected_to app_root_path
    @account.reload
    assert_not_equal "Hacked", @account.name
  end

  test "update with invalid subdomain" do
    sign_in_as @owner
    patch account_path, params: { account: { subdomain: "Invalid Subdomain!" } }
    assert_response :unprocessable_entity
  end

  test "cannot update to duplicate subdomain" do
    other_account = accounts(:premium)
    sign_in_as @owner
    patch account_path, params: { account: { subdomain: other_account.subdomain } }
    assert_response :unprocessable_entity
  end

  test "complete_profile updates account fields" do
    sign_in_as @owner

    patch complete_profile_account_path, params: {
      account: {
        address: "12 Avenue des Spélugues, 98000 Monaco",
        phone: "+377 93 15 26 00",
        rci_number: "12S34567",
        legal_form: "sarl"
      }
    }

    assert_response :success
    @account.reload
    assert_equal "12 Avenue des Spélugues, 98000 Monaco", @account.address
    assert_equal "+377 93 15 26 00", @account.phone
    assert_equal "12S34567", @account.rci_number
    assert_equal "sarl", @account.legal_form
  end

  test "complete_profile requires authentication" do
    patch complete_profile_account_path, params: { account: { address: "Test" } }

    assert_redirected_to new_session_path
  end

  test "complete_profile allows partial updates" do
    sign_in_as @owner

    patch complete_profile_account_path, params: {
      account: {
        address: "12 Avenue des Spélugues",
        phone: "+377 93 15 26 00"
      }
    }

    assert_response :success
    @account.reload
    assert_equal "12 Avenue des Spélugues", @account.address
    assert_equal "+377 93 15 26 00", @account.phone
  end
end
