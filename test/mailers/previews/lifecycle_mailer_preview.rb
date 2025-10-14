# Preview all emails at http://localhost:3000/rails/mailers/lifecycle_mailer
class LifecycleMailerPreview < ActionMailer::Preview
  def welcome
    LifecycleMailer.welcome(User.first || User.new(email: "preview@example.com", account: Account.new))
  end

  def user_invited
    inviter = User.first || User.new(email: "inviter@example.com", account: Account.new)
    invitee = User.second || User.new(email: "invitee@example.com", account: Account.new)
    LifecycleMailer.user_invited(invitee, inviter, "Acme Corp")
  end

  def role_changed
    LifecycleMailer.role_changed(User.first || User.new(email: "preview@example.com", account: Account.new), "admin", "member")
  end
end
