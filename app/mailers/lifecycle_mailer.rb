class LifecycleMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM_EMAIL", "noreply@example.com")

  def welcome(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Welcome to Rails SaaS Starter"
    )
  end

  def user_invited(invitee, inviter, organization_name)
    @invitee = invitee
    @inviter = inviter
    @organization_name = organization_name
    mail(
      to: @invitee.email,
      subject: "You've been invited to #{@organization_name}"
    )
  end

  def role_changed(user, old_role, new_role)
    @user = user
    @old_role = old_role
    @new_role = new_role
    mail(
      to: @user.email,
      subject: "Your role has been updated"
    )
  end
end
