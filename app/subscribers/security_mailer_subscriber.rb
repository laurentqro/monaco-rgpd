class SecurityMailerSubscriber
  class << self
    def subscribe!
      return if @subscribed  # Guard against multiple subscriptions

      ActiveSupport::Notifications.subscribe("security.password_changed") do |_name, _start, _finish, _id, payload|
        handle_password_changed(payload)
      end

      ActiveSupport::Notifications.subscribe("security.suspicious_login") do |_name, _start, _finish, _id, payload|
        handle_suspicious_login(payload)
      end

      ActiveSupport::Notifications.subscribe("security.account_deletion_requested") do |_name, _start, _finish, _id, payload|
        handle_account_deletion_requested(payload)
      end

      @subscribed = true
    end

    private

    def handle_password_changed(payload)
      user = payload[:user]
      return unless user

      SecurityMailer.password_changed(user).deliver_later
    rescue => e
      Rails.logger.error("Failed to send password changed email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def handle_suspicious_login(payload)
      user = payload[:user]
      ip_address = payload[:ip_address]
      user_agent = payload[:user_agent]

      return unless user
      return unless ip_address && user_agent

      SecurityMailer.suspicious_login(user, ip_address, user_agent).deliver_later
    rescue => e
      Rails.logger.error("Failed to send suspicious login email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def handle_account_deletion_requested(payload)
      user = payload[:user]
      return unless user

      SecurityMailer.account_deletion_requested(user).deliver_later
    rescue => e
      Rails.logger.error("Failed to send account deletion requested email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
