class Admin::AccountsController < Admin::BaseController
  before_action :set_account, only: [:show, :update, :destroy]

  def index
    accounts = Account.all.order(created_at: :desc)

    if params[:search].present?
      accounts = accounts.where("name ILIKE ? OR subdomain ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%")
    end

    render inertia: "admin/accounts/Index", props: {
      accounts: accounts.as_json(only: [:id, :name, :subdomain, :plan_type, :created_at],
        methods: [:subscribed?],
        include: { users: { only: [:id] } }),
      search: params[:search]
    }
  end

  def show
    render inertia: "admin/accounts/Show", props: {
      account: @account.as_json(only: [:id, :name, :subdomain, :plan_type, :created_at, :updated_at],
        methods: [:subscribed?, :onboarding_completed?]),
      users: @account.users.as_json(only: [:id, :email, :name, :role, :created_at]),
      subscription: @account.active_subscription&.as_json(only: [:id, :status, :plan_type, :current_period_end])
    }
  end

  def update
    if @account.update(account_params)
      redirect_to admin_account_path(@account), notice: "Account updated"
    else
      redirect_back fallback_location: admin_account_path(@account),
        alert: @account.errors.full_messages.join(", ")
    end
  end

  def destroy
    # Notify all users in the account before deletion
    @account.users.each do |user|
      ActiveSupport::Notifications.instrument(
        "security.account_deletion_requested",
        user: user
      )
    end

    @account.destroy
    redirect_to admin_accounts_path, notice: "Account deleted"
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :subdomain, :plan_type)
  end
end
