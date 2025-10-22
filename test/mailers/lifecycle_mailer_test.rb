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

    assert_equal [ "noreply@example.com" ], email.from
    assert_equal [ @user.email ], email.to
    assert_match "Bienvenue sur MonacoRGPD!", email.body.encoded
  end

  test "user_invited email" do
    inviter = users(:owner)
    invitee = users(:member)

    email = LifecycleMailer.user_invited(invitee, inviter, "TestCo")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ invitee.email ], email.to
    assert_match "invité à rejoindre TestCo", email.text_part.body.decoded
  end

  test "role_changed email" do
    email = LifecycleMailer.role_changed(@user, "admin", "member")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_match "Votre rôle a été mis à jour", email.text_part.body.decoded
  end
end
