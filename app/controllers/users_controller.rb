class UsersController < ApplicationController
  before_action :set_user
  before_action :authorize_user

  def update
    if @user.update(user_params)
      redirect_to settings_profile_path, notice: "Profile updated successfully"
    else
      render inertia: "settings/Profile", props: {
        user: @user.as_json(only: [:id, :email, :name, :avatar_url, :role]),
        errors: @user.errors.messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    unless @user == current_user
      redirect_to app_root_path, alert: "Unauthorized"
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar_url)
  end
end
