class CreateAdminSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_sessions do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
  end
end
