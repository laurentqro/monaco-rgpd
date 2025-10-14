class CreateDocumentsAndTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :document_templates do |t|
      t.integer :document_type, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :version, default: 1, null: false
      t.boolean :is_active, default: false
      t.bigint :created_by_id

      t.timestamps
    end

    create_table :document_template_versions do |t|
      t.references :document_template, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :version, null: false
      t.bigint :changed_by_id
      t.text :change_notes

      t.timestamps
    end

    create_table :documents do |t|
      t.references :account, null: false, foreign_key: true
      t.references :response, null: false, foreign_key: true
      t.integer :document_type, null: false
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.datetime :generated_at

      t.timestamps
    end

    add_index :document_templates, :document_type
    add_index :document_templates, :is_active
    add_index :documents, :document_type
    add_index :documents, :status
    add_index :documents, [:account_id, :created_at]
  end
end
