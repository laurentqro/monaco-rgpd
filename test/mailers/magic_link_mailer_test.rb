require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "send_link email" do
    user = users(:owner)
    magic_link = magic_links(:valid)

    email = MagicLinkMailer.send_link(user, magic_link)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [user.email], email.to
    assert_match "Sign in", email.subject
    assert_match magic_link.token, email.body.encoded
  end
end
