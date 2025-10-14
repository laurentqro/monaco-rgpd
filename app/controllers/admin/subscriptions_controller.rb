class Admin::SubscriptionsController < Admin::BaseController
  def index
    subscriptions = Subscription.includes(:account).order(created_at: :desc)

    if params[:status].present?
      subscriptions = subscriptions.where(status: params[:status])
    end

    render inertia: "admin/subscriptions/Index", props: {
      subscriptions: subscriptions.as_json(
        only: [:id, :status, :plan_type, :current_period_end, :created_at],
        include: { account: { only: [:id, :name] } }
      ),
      status: params[:status]
    }
  end
end
