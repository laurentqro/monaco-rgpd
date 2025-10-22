class SettingsController < ApplicationController
  def profile
    render inertia: "settings/Profile", props: {
      user: current_user.as_json(only: [ :id, :email, :name, :avatar_url, :role ])
    }
  end

  def account
    render inertia: "settings/Account", props: {
      account: current_account.as_json(only: [ :id, :name, :subdomain, :plan_type ]),
      is_admin: current_user.admin?
    }
  end

  def team
    members = current_account.users.order(created_at: :asc)
    render inertia: "settings/Team", props: {
      members: members.as_json(only: [ :id, :email, :name, :role, :created_at ]),
      is_admin: current_user.admin?
    }
  end

  def billing
    subscription = current_account.active_subscription
    render inertia: "settings/Billing", props: {
      subscription: subscription&.as_json(only: [ :id, :status, :plan_type, :current_period_end ]),
      is_owner: current_user.role == "owner"
    }
  end
end
