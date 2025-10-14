class Admin::AdminsController < Admin::BaseController
  def index
    render inertia: "admin/admins/Index", props: {
      admins: Admin.order(created_at: :desc).as_json(only: [:id, :email, :name, :created_at])
    }
  end

  def create
    admin = Admin.new(admin_params)

    if admin.save
      redirect_to admin_admins_path, notice: "Admin created successfully"
    else
      redirect_back fallback_location: admin_admins_path,
        alert: admin.errors.full_messages.join(", ")
    end
  end

  def destroy
    admin = Admin.find(params[:id])

    if admin == current_admin
      redirect_to admin_admins_path, alert: "Cannot delete yourself"
      return
    end

    admin.destroy
    redirect_to admin_admins_path, notice: "Admin deleted"
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :name, :password, :password_confirmation)
  end
end
