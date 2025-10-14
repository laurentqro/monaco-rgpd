class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :polar_subscription_id
      t.string :status
      t.string :plan_name
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :cancelled_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
