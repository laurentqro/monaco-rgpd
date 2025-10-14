class SessionsController < ApplicationController
  allow_unauthenticated_access only: :new

  def new
    # Redirect authenticated users to app
    if authenticated?
      redirect_to app_root_path
    else
      render inertia: "auth/SignIn"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out successfully"
  end
end
