class CreateProcessingActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :processing_activities do |t|
      t.references :account, null: false, foreign_key: true
      t.references :response, foreign_key: true
      t.string :name, null: false
      t.text :description

      # Organization structure
      t.boolean :has_representative, default: false
      t.boolean :has_dpo, default: false
      t.boolean :has_joint_controller, default: false

      # Purpose & surveillance
      t.boolean :surveillance_purpose, default: false

      # Data subjects
      t.jsonb :data_subjects, default: []

      # Sensitive data
      t.boolean :sensitive_data, default: false
      t.jsonb :sensitive_data_types, default: []
      t.integer :sensitive_data_justification

      # Non-sensitive data categories
      t.jsonb :data_categories, default: []

      # Individual rights
      t.jsonb :individual_rights, default: []

      # Security
      t.jsonb :security_measures, default: []

      # Transfers
      t.boolean :inadequate_protection_transfer, default: false
      t.jsonb :transfer_destinations, default: []
      t.integer :transfer_safeguard
      t.integer :transfer_derogation

      # Information
      t.text :information_modalities

      # Risk assessment
      t.boolean :impact_assessment_required, default: false
      t.boolean :profiling, default: false

      # Special cases
      t.boolean :special_case_article, default: false
      t.string :special_case_reference
      t.boolean :prior_authorization, default: false

      t.timestamps
    end

    create_table :processing_purposes do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :purpose_number, null: false
      t.string :purpose_name, null: false
      t.text :purpose_detail
      t.integer :legal_basis, null: false
      t.integer :order_index, null: false

      t.timestamps
    end

    create_table :data_category_details do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :category_type, null: false
      t.text :detail
      t.string :retention_period
      t.integer :retention_period_enum
      t.string :data_source

      t.timestamps
    end

    create_table :access_categories do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :category_number
      t.string :category_name, null: false
      t.text :detail
      t.string :location
      t.integer :order_index

      t.timestamps
    end

    create_table :recipient_categories do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :recipient_number
      t.string :recipient_name, null: false
      t.text :detail
      t.string :location
      t.integer :order_index

      t.timestamps
    end

    add_index :processing_activities, [:account_id, :created_at]
    add_index :processing_purposes, :order_index
    add_index :access_categories, :order_index
    add_index :recipient_categories, :order_index
  end
end
