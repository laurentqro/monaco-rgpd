class Admin::DashboardController < Admin::BaseController
  def index
    render inertia: "admin/Dashboard", props: {
      stats: {
        total_accounts: Account.count,
        total_users: User.count,
        active_subscriptions: Subscription.where(status: "active").count
      }
    }
  end
end
