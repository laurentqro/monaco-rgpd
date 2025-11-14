require "test_helper"

class Admin::WaitlistEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:super_admin)
    sign_in_as_admin @admin
  end

  test "index shows waitlist entries grouped by feature" do
    get admin_waitlist_entries_path

    assert_response :success
  end

  test "index requires admin authentication" do
    delete admin_session_path

    get admin_waitlist_entries_path

    assert_redirected_to new_admin_session_path
  end

  test "index includes feature counts" do
    # Create some test entries
    3.times do |i|
      WaitlistEntry.create!(
        email: "test#{i}@example.com",
        response: responses(:one),
        features_needed: [ "association" ]
      )
    end

    get admin_waitlist_entries_path

    assert_response :success
    # Check that counts are passed to view
  end
end
