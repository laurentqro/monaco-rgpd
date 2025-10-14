class MagicLinkMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_EMAIL", "noreply@example.com")

  def send_link(user, magic_link)
    @user = user
    @magic_link = magic_link
    @verification_url = verify_magic_link_url(token: @magic_link.token)

    mail(
      to: @user.email,
      subject: "Sign in to Rails SaaS Starter"
    )
  end
end
