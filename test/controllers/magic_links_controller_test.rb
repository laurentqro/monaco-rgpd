require "test_helper"

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  test "create with existing user sends magic link" do
    user = users(:owner)

    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      post magic_links_path, params: { email: user.email }
    end

    assert_response :success
  end

  test "create with new email creates user and account, sends link" do
    assert_difference "User.count", 1 do
      assert_difference "Account.count", 1 do
        # Now sends 2 emails: magic link + welcome email
        assert_enqueued_jobs 2, only: ActionMailer::MailDeliveryJob do
          post magic_links_path, params: {
            email: "newuser@example.com",
            name: "New User",
            account_name: "New Account"
          }
        end
      end
    end

    assert_response :success
  end

  test "verify with valid token creates session and redirects" do
    link = magic_links(:valid)

    get verify_magic_link_path(token: link.token)

    assert_redirected_to app_root_path
    assert link.reload.used?

    # Verify a session cookie was set
    assert_not_nil cookies[:session_id]

    # Verify session was created for the correct user
    assert_equal 1, link.user.sessions.count
    assert_equal link.user_id, link.user.sessions.last.user_id
  end

  test "verify with expired token shows error" do
    link = MagicLink.create!(
      user: users(:owner),
      token: "expired",
      expires_at: 1.hour.ago
    )

    get verify_magic_link_path(token: link.token)

    assert_redirected_to new_session_path
    assert_equal "This magic link has expired", flash[:alert]
    assert_nil cookies[:session_id]
  end

  test "verify with invalid token shows error" do
    get verify_magic_link_path(token: "invalid")

    assert_redirected_to new_session_path
    assert_equal "Invalid magic link", flash[:alert]
    assert_nil cookies[:session_id]
  end
end
