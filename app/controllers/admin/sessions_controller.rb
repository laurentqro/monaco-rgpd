class Admin::SessionsController < Admin::BaseController
  skip_before_action :require_admin, only: [:new, :create]

  def new
    render inertia: "admin/sessions/New"
  end

  def create
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      start_new_admin_session_for(admin)
      redirect_to admin_root_path, notice: "Signed in as admin"
    else
      render inertia: "admin/sessions/New", props: {
        error: "Invalid email or password"
      }, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_admin_session
    redirect_to new_admin_session_path, notice: "Signed out"
  end
end
