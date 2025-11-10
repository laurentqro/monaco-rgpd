class RemoveUnusedEnumColumnsFromProcessingActivities < ActiveRecord::Migration[8.1]
  def change
    remove_column :processing_activities, :sensitive_data_justification, :integer
    remove_column :processing_activities, :transfer_safeguard, :integer
    remove_column :processing_activities, :transfer_derogation, :integer
  end
end
