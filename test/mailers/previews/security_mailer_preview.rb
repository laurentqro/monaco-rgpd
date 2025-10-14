# Preview all emails at http://localhost:3000/rails/mailers/security_mailer
class SecurityMailerPreview < ActionMailer::Preview
  def password_changed
    SecurityMailer.password_changed(User.first || User.new(email: "preview@example.com", account: Account.new))
  end

  def suspicious_login
    SecurityMailer.suspicious_login(User.first || User.new(email: "preview@example.com", account: Account.new), "192.168.1.1", "Chrome on MacOS")
  end

  def account_deletion_requested
    SecurityMailer.account_deletion_requested(User.first || User.new(email: "preview@example.com", account: Account.new))
  end
end
