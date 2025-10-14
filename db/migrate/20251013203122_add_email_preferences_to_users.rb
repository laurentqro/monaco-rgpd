class AddEmailPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_lifecycle_notifications, :boolean, default: true, null: false
  end
end
