class AccountsController < ApplicationController
  before_action :require_admin_for_update, only: [:update]

  def update
    if Current.account.update(account_params)
      redirect_to settings_account_path, notice: "Account updated successfully"
    else
      render inertia: "settings/Account", props: {
        account: Current.account.as_json(only: [ :id, :name, :subdomain, :plan_type ]),
        is_admin: current_user.admin?,
        errors: Current.account.errors.messages
      }, status: :unprocessable_entity
    end
  end

  # Complete account profile with required fields for document generation
  # Users can only update their own account profile
  def complete_profile
    if Current.account.update(profile_params)
      render json: { success: true }
    else
      render json: {
        errors: Current.account.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def require_admin_for_update
    unless current_user.admin?
      redirect_to app_root_path, alert: "Unauthorized"
    end
  end

  def account_params
    params.require(:account).permit(:name, :subdomain)
  end

  # Whitelist profile completion fields (address, phone, RCI, legal form)
  def profile_params
    params.require(:account).permit(:address, :phone, :rci_number, :legal_form)
  end
end
