class LifecycleMailerSubscriber
  class << self
    def subscribe!
      return if @subscribed  # Guard against multiple subscriptions

      ActiveSupport::Notifications.subscribe("lifecycle.welcome") do |_name, _start, _finish, _id, payload|
        handle_welcome(payload)
      end

      ActiveSupport::Notifications.subscribe("lifecycle.user_invited") do |_name, _start, _finish, _id, payload|
        handle_user_invited(payload)
      end

      ActiveSupport::Notifications.subscribe("lifecycle.role_changed") do |_name, _start, _finish, _id, payload|
        handle_role_changed(payload)
      end

      @subscribed = true
    end

    private

    def handle_welcome(payload)
      user = payload[:user]
      return unless user
      return unless user.email_lifecycle_notifications?

      LifecycleMailer.welcome(user).deliver_later
    rescue => e
      Rails.logger.error("Failed to send welcome email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def handle_user_invited(payload)
      invitee = payload[:invitee]
      inviter = payload[:inviter]
      organization_name = payload[:organization_name]

      return unless invitee
      return unless invitee.email_lifecycle_notifications?
      return unless inviter && organization_name

      LifecycleMailer.user_invited(invitee, inviter, organization_name).deliver_later
    rescue => e
      Rails.logger.error("Failed to send user invited email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def handle_role_changed(payload)
      user = payload[:user]
      old_role = payload[:old_role]
      new_role = payload[:new_role]

      return unless user
      return unless user.email_lifecycle_notifications?
      return unless old_role && new_role

      LifecycleMailer.role_changed(user, old_role, new_role).deliver_later
    rescue => e
      Rails.logger.error("Failed to send role changed email: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
