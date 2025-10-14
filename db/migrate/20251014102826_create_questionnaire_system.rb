class CreateQuestionnaireSystem < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaires do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.integer :status, default: 0, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :sections do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :order_index, null: false

      t.timestamps
    end

    create_table :questions do |t|
      t.references :section, null: false, foreign_key: true
      t.text :question_text, null: false
      t.integer :question_type, null: false
      t.text :help_text
      t.integer :order_index, null: false
      t.boolean :is_required, default: false
      t.jsonb :settings, default: {}
      t.decimal :weight, precision: 5, scale: 2

      t.timestamps
    end

    create_table :answer_choices do |t|
      t.references :question, null: false, foreign_key: true
      t.text :choice_text, null: false
      t.integer :order_index, null: false
      t.decimal :score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :logic_rules do |t|
      t.references :source_question, null: false, foreign_key: { to_table: :questions }
      t.references :target_section, foreign_key: { to_table: :sections }
      t.integer :condition_type, null: false
      t.jsonb :condition_value, default: {}
      t.integer :action, null: false

      t.timestamps
    end

    add_index :questionnaires, :status
    add_index :sections, :order_index
    add_index :questions, :order_index
    add_index :answer_choices, :order_index
  end
end
