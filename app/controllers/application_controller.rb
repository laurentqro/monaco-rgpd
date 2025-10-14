class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Share current user and account with all Inertia requests
  inertia_share do
    if authenticated?
      {
        current_user: Current.user&.as_json(only: [:id, :email, :name, :avatar_url, :role]),
        current_account: Current.account&.as_json(only: [:id, :name, :subdomain, :plan_type]),
        authenticated: true,
        is_super_admin: ENV.fetch('SUPER_ADMIN_EMAILS', '').split(',').include?(Current.user&.email),
        impersonating_user: session[:impersonating_user_id] ? Current.user&.as_json(only: [:id, :email, :name]) : nil
      }
    else
      {
        current_user: nil,
        current_account: nil,
        authenticated: false,
        is_super_admin: false,
        impersonating_user: nil
      }
    end
  end
end
