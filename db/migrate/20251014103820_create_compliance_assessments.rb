class CreateComplianceAssessments < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_areas do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps
    end

    create_table :compliance_assessments do |t|
      t.references :response, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.decimal :overall_score, precision: 5, scale: 2
      t.decimal :max_possible_score, precision: 5, scale: 2
      t.string :risk_level
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    create_table :compliance_area_scores do |t|
      t.references :compliance_assessment, null: false, foreign_key: true
      t.references :compliance_area, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2
      t.decimal :max_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :compliance_areas, :code, unique: true
    add_index :compliance_assessments, :status
    add_index :compliance_assessments, [ :account_id, :created_at ]
  end
end
