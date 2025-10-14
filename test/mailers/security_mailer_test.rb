require "test_helper"

class SecurityMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:owner)
  end

  test "password_changed email" do
    email = SecurityMailer.password_changed(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@example.com"], email.from
    assert_equal [@user.email], email.to
    assert_equal "Your password was changed", email.subject
    assert_match "password was recently changed", email.body.encoded
  end

  test "suspicious_login email" do
    email = SecurityMailer.suspicious_login(@user, "192.168.1.1", "Chrome on MacOS")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "New login to your account", email.subject
    assert_match "192.168.1.1", email.body.encoded
    assert_match "Chrome on MacOS", email.body.encoded
  end

  test "account_deletion_requested email" do
    email = SecurityMailer.account_deletion_requested(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "Account deletion requested", email.subject
    assert_match "account deletion has been requested", email.body.encoded
  end
end
