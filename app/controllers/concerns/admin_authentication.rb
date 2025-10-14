module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_admin_session
    helper_method :current_admin, :admin_authenticated?
  end

  private

  def set_current_admin_session
    Current.admin_session = find_admin_session_by_cookie
  end

  def find_admin_session_by_cookie
    AdminSession.find_by(id: cookies.signed[:admin_session_id])
  end

  def current_admin
    Current.admin
  end

  def admin_authenticated?
    current_admin.present?
  end

  def require_admin
    unless admin_authenticated?
      redirect_to new_admin_session_path, alert: "Admin authentication required"
    end
  end

  def start_new_admin_session_for(admin)
    admin_session = admin.admin_sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )

    cookies.signed.permanent[:admin_session_id] = {
      value: admin_session.id,
      httponly: true,
      same_site: :lax
    }
  end

  def terminate_admin_session
    current_admin_session = find_admin_session_by_cookie
    current_admin_session&.destroy
    cookies.delete(:admin_session_id)
  end
end
