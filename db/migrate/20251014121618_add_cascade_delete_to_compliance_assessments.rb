class AddCascadeDeleteToComplianceAssessments < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing foreign key
    remove_foreign_key :compliance_assessments, :responses

    # Add it back with cascade delete
    add_foreign_key :compliance_assessments, :responses, on_delete: :cascade
  end
end
