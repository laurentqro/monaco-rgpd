class Admin::BaseController < ApplicationController
  include AdminAuthentication

  before_action :require_admin
  before_action :set_current_user_session_if_impersonating

  # Don't require user authentication for admin area
  skip_before_action :require_authentication, raise: false

  layout "admin"

  inertia_share do
    if admin_authenticated?
      {
        current_admin: current_admin.as_json(only: [ :id, :email, :name ]),
        impersonating_user: Current.user&.as_json(only: [ :id, :email, :name ])
      }
    else
      {}
    end
  end

  private

  def set_current_user_session_if_impersonating
    if session[:impersonating_user_id] && cookies.signed[:session_id]
      Current.session = Session.find_by(id: cookies.signed[:session_id])
    end
  end
end
