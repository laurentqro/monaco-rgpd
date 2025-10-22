class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :update, :destroy ]

  def index
    users = User.includes(:account).order(created_at: :desc)

    if params[:search].present?
      users = users.where("email ILIKE ? OR name ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%")
    end

    render inertia: "admin/users/Index", props: {
      users: users.as_json(only: [ :id, :email, :name, :role, :created_at ],
        include: { account: { only: [ :id, :name ] } }),
      search: params[:search]
    }
  end

  def show
    render inertia: "admin/users/Show", props: {
      user: @user.as_json(only: [ :id, :email, :name, :role, :avatar_url, :created_at, :updated_at ]),
      account: @user.account.as_json(only: [ :id, :name, :subdomain ]),
      sessions: @user.sessions.order(created_at: :desc).limit(10)
        .as_json(only: [ :id, :ip_address, :user_agent, :created_at ])
    }
  end

  def update
    old_role = @user.role

    if @user.update(user_params)
      # Publish role changed event if role was updated
      if @user.role != old_role
        ActiveSupport::Notifications.instrument(
          "lifecycle.role_changed",
          user: @user,
          old_role: old_role,
          new_role: @user.role
        )
      end

      redirect_to admin_user_path(@user), notice: "User updated"
    else
      redirect_back fallback_location: admin_user_path(@user),
        alert: @user.errors.full_messages.join(", ")
    end
  end

  def destroy
    # Notify user about account deletion
    ActiveSupport::Notifications.instrument(
      "security.account_deletion_requested",
      user: @user
    )

    @user.destroy
    redirect_to admin_users_path, notice: "User deleted"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :avatar_url)
  end
end
