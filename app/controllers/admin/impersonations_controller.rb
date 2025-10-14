class Admin::ImpersonationsController < Admin::BaseController
  def create
    user = User.find(params[:id])

    # Create a user session for impersonation
    user_session = user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )

    # Store impersonation flag in Rails session
    session[:impersonating_user_id] = user.id

    # Set user session cookie
    cookies.signed.permanent[:session_id] = {
      value: user_session.id,
      httponly: true,
      same_site: :lax
    }

    redirect_to app_root_path, notice: "Now impersonating #{user.email}"
  end

  def destroy
    # Store the user ID before clearing the session
    impersonated_user_id = session[:impersonating_user_id]

    # Clear impersonation flag from Rails session
    session.delete(:impersonating_user_id)

    # Destroy user session using Session model
    if cookies.signed[:session_id]
      Session.find_by(id: cookies.signed[:session_id])&.destroy
      cookies.delete(:session_id)
    end

    # Redirect back to the user's admin page if available, otherwise to users list
    if impersonated_user_id
      redirect_to admin_user_path(impersonated_user_id), notice: "Stopped impersonating"
    else
      redirect_to admin_users_path, notice: "Stopped impersonating"
    end
  end
end
