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
        # Only sends magic link email on creation (welcome email sent on first login)
        assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
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

  test "verify sends welcome email on first login only" do
    # Subscribe the subscriber to handle the event
    LifecycleMailerSubscriber.subscribe!

    # Create new user who hasn't been welcomed yet
    user = User.create!(
      email: "firsttime@example.com",
      name: "First Timer",
      account: accounts(:basic),
      welcomed_at: nil
    )

    link = MagicLink.create!(
      user: user,
      token: "first_login_token",
      expires_at: 1.hour.from_now
    )

    # First login should trigger welcome email
    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      get verify_magic_link_path(token: link.token)
    end

    assert_redirected_to app_root_path
    assert_not_nil user.reload.welcomed_at

    # Create second magic link for same user
    link2 = MagicLink.create!(
      user: user,
      token: "second_login_token",
      expires_at: 1.hour.from_now
    )

    # Second login should NOT trigger welcome email
    assert_enqueued_jobs 0, only: ActionMailer::MailDeliveryJob do
      get verify_magic_link_path(token: link2.token)
    end
  end
end
