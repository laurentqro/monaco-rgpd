class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: false
      t.string :notification_type
      t.string :title
      t.text :message
      t.datetime :read_at

      t.timestamps
    end
  end
end
