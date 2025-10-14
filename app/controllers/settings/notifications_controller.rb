module Settings
  class NotificationsController < ApplicationController
    def show
      render inertia: "settings/Notifications", props: {
        user: {
          email_lifecycle_notifications: current_user.email_lifecycle_notifications
        }
      }
    end

    def update
      if current_user.update(user_params)
        redirect_to settings_notifications_url, notice: "Email preferences updated successfully"
      else
        redirect_to settings_notifications_url, alert: "Failed to update email preferences"
      end
    end

    private

    def user_params
      params.require(:user).permit(:email_lifecycle_notifications)
    end
  end
end
