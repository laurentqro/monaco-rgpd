class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.string :plan_type
      t.datetime :onboarding_completed_at
      t.bigint :owner_id

      t.timestamps
    end
    add_index :accounts, :subdomain, unique: true
  end
end
