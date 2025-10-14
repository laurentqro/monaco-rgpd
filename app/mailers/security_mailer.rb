class SecurityMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_EMAIL", "noreply@example.com")

  def password_changed(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Your password was changed"
    )
  end

  def suspicious_login(user, ip_address, user_agent)
    @user = user
    @ip_address = ip_address
    @user_agent = user_agent
    mail(
      to: @user.email,
      subject: "New login to your account"
    )
  end

  def account_deletion_requested(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Account deletion requested"
    )
  end
end
