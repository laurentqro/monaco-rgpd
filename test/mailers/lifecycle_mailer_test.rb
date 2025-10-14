require "test_helper"

class LifecycleMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:owner)
  end

  test "welcome email" do
    email = LifecycleMailer.welcome(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@example.com"], email.from
    assert_equal [@user.email], email.to
    assert_equal "Welcome to Rails SaaS Starter", email.subject
    assert_match "Welcome", email.body.encoded
  end

  test "user_invited email" do
    inviter = users(:owner)
    invitee = users(:member)

    email = LifecycleMailer.user_invited(invitee, inviter, "TestCo")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [invitee.email], email.to
    assert_equal "You've been invited to TestCo", email.subject
    assert_match inviter.email, email.body.encoded
    assert_match "TestCo", email.body.encoded
  end

  test "role_changed email" do
    email = LifecycleMailer.role_changed(@user, "admin", "member")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "Your role has been updated", email.subject
    assert_match "admin", email.body.encoded
    assert_match "member", email.body.encoded
  end
end
