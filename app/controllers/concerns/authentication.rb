module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user, :current_account
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }

        # Check for suspicious login (new IP address)
        check_suspicious_login(user, request.remote_ip, request.user_agent)
      end
    end

    def check_suspicious_login(user, current_ip, user_agent)
      # Get IPs from sessions in the last 30 days (excluding the current session by checking earlier than now)
      # We need to reload to get an accurate count since we just created a session
      recent_ips = user.sessions
                      .where("created_at < ?", Time.current)
                      .where("created_at > ?", 30.days.ago)
                      .pluck(:ip_address)
                      .uniq

      # Remove the current IP to see if there are OTHER previous sessions
      previous_ips = recent_ips - [ current_ip ]

      # If user has previous sessions from other IPs (meaning this is a new IP), publish event
      if previous_ips.any?
        ActiveSupport::Notifications.instrument(
          "security.suspicious_login",
          user: user,
          ip_address: current_ip,
          user_agent: user_agent
        )
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end

    def current_user
      Current.user
    end

    def current_account
      Current.account
    end
end
