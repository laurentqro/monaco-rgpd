class AddProfileFieldsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :address, :text
    add_column :accounts, :phone, :string
    add_column :accounts, :rci_number, :string
    add_column :accounts, :legal_form, :integer, default: 0
  end
end
