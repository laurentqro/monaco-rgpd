class AddMonacoRgpdFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :account_type, :integer, default: 0, null: false
    add_column :accounts, :compliance_mode, :integer, default: 0, null: false
    add_column :accounts, :entity_type, :integer
    add_column :accounts, :jurisdiction, :string, default: "MC", null: false
    add_column :accounts, :activity_sector, :string
    add_column :accounts, :employee_count, :integer
    add_column :accounts, :metadata, :jsonb, default: {}

    add_index :accounts, :account_type
    add_index :accounts, :jurisdiction
  end
end
