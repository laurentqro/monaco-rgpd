class AccountsController < ApplicationController
  before_action :set_account
  before_action :require_admin

  def update
    if @account.update(account_params)
      redirect_to settings_account_path, notice: "Account updated successfully"
    else
      render inertia: "settings/Account", props: {
        account: @account.as_json(only: [ :id, :name, :subdomain, :plan_type ]),
        is_admin: current_user.admin?,
        errors: @account.errors.messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def require_admin
    unless @account == current_account && current_user.admin?
      redirect_to app_root_path, alert: "Unauthorized"
    end
  end

  def account_params
    params.require(:account).permit(:name, :subdomain)
  end
end
