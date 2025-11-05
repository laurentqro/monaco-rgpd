# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_05_165159) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_categories", force: :cascade do |t|
    t.string "category_name", null: false
    t.integer "category_number"
    t.datetime "created_at", null: false
    t.text "detail"
    t.string "location"
    t.integer "order_index"
    t.bigint "processing_activity_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_access_categories_on_order_index"
    t.index ["processing_activity_id"], name: "index_access_categories_on_processing_activity_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "account_type", default: 0, null: false
    t.string "activity_sector"
    t.text "address"
    t.integer "compliance_mode", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "employee_count"
    t.integer "entity_type"
    t.string "jurisdiction", default: "MC", null: false
    t.integer "legal_form", default: 0
    t.jsonb "metadata", default: {}
    t.string "name"
    t.datetime "onboarding_completed_at"
    t.bigint "owner_id"
    t.string "phone"
    t.string "plan_type"
    t.string "rci_number"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["account_type"], name: "index_accounts_on_account_type"
    t.index ["jurisdiction"], name: "index_accounts_on_jurisdiction"
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_sessions", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["admin_id"], name: "index_admin_sessions_on_admin_id"
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "answer_choices", force: :cascade do |t|
    t.text "choice_text", null: false
    t.datetime "created_at", null: false
    t.integer "order_index", null: false
    t.bigint "question_id", null: false
    t.decimal "score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_answer_choices_on_order_index"
    t.index ["question_id"], name: "index_answer_choices_on_question_id"
  end

  create_table "answers", force: :cascade do |t|
    t.boolean "answer_boolean"
    t.bigint "answer_choice_id"
    t.date "answer_date"
    t.decimal "answer_number", precision: 10, scale: 2
    t.integer "answer_rating"
    t.text "answer_text"
    t.decimal "calculated_score", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.bigint "response_id", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_choice_id"], name: "index_answers_on_answer_choice_id"
    t.index ["answer_rating"], name: "index_answers_on_answer_rating"
    t.index ["question_id", "answer_choice_id"], name: "index_answers_on_question_and_choice", where: "(answer_choice_id IS NOT NULL)"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["response_id", "question_id"], name: "index_answers_on_response_id_and_question_id", unique: true
    t.index ["response_id"], name: "index_answers_on_response_id"
    t.check_constraint "(\nCASE\n    WHEN answer_choice_id IS NOT NULL THEN 1\n    ELSE 0\nEND +\nCASE\n    WHEN answer_text IS NOT NULL AND answer_text <> ''::text THEN 1\n    ELSE 0\nEND +\nCASE\n    WHEN answer_rating IS NOT NULL THEN 1\n    ELSE 0\nEND +\nCASE\n    WHEN answer_number IS NOT NULL THEN 1\n    ELSE 0\nEND +\nCASE\n    WHEN answer_date IS NOT NULL THEN 1\n    ELSE 0\nEND +\nCASE\n    WHEN answer_boolean IS NOT NULL THEN 1\n    ELSE 0\nEND) = 1", name: "exactly_one_answer_field"
  end

  create_table "compliance_area_scores", force: :cascade do |t|
    t.bigint "compliance_area_id", null: false
    t.bigint "compliance_assessment_id", null: false
    t.datetime "created_at", null: false
    t.decimal "max_score", precision: 5, scale: 2
    t.decimal "score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["compliance_area_id"], name: "index_compliance_area_scores_on_compliance_area_id"
    t.index ["compliance_assessment_id"], name: "index_compliance_area_scores_on_compliance_assessment_id"
  end

  create_table "compliance_areas", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_compliance_areas_on_code", unique: true
  end

  create_table "compliance_assessments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.decimal "max_possible_score", precision: 5, scale: 2
    t.decimal "overall_score", precision: 5, scale: 2
    t.bigint "response_id", null: false
    t.string "risk_level"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_compliance_assessments_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_compliance_assessments_on_account_id"
    t.index ["response_id"], name: "index_compliance_assessments_on_response_id"
    t.index ["status"], name: "index_compliance_assessments_on_status"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "questionnaire_id", null: false
    t.bigint "response_id"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_conversations_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_conversations_on_account_id"
    t.index ["questionnaire_id"], name: "index_conversations_on_questionnaire_id"
    t.index ["response_id"], name: "index_conversations_on_response_id"
  end

  create_table "data_category_details", force: :cascade do |t|
    t.integer "category_type", null: false
    t.datetime "created_at", null: false
    t.string "data_source"
    t.text "detail"
    t.bigint "processing_activity_id", null: false
    t.string "retention_period"
    t.integer "retention_period_enum"
    t.datetime "updated_at", null: false
    t.index ["processing_activity_id"], name: "index_data_category_details_on_processing_activity_id"
  end

  create_table "document_template_versions", force: :cascade do |t|
    t.text "change_notes"
    t.bigint "changed_by_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "document_template_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version", null: false
    t.index ["document_template_id"], name: "index_document_template_versions_on_document_template_id"
  end

  create_table "document_templates", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "document_type", null: false
    t.boolean "is_active", default: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.index ["document_type"], name: "index_document_templates_on_document_type"
    t.index ["is_active"], name: "index_document_templates_on_is_active"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "document_type", null: false
    t.datetime "generated_at"
    t.bigint "response_id", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_documents_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_documents_on_account_id"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["response_id"], name: "index_documents_on_response_id"
    t.index ["status"], name: "index_documents_on_status"
  end

  create_table "logic_rules", force: :cascade do |t|
    t.integer "action", null: false
    t.integer "condition_type", null: false
    t.jsonb "condition_value", default: {}
    t.datetime "created_at", null: false
    t.text "exit_message"
    t.bigint "source_question_id", null: false
    t.bigint "target_question_id"
    t.bigint "target_section_id"
    t.datetime "updated_at", null: false
    t.index ["source_question_id"], name: "index_logic_rules_on_source_question_id"
    t.index ["target_question_id"], name: "index_logic_rules_on_target_question_id"
    t.index ["target_section_id"], name: "index_logic_rules_on_target_section_id"
  end

  create_table "magic_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "token"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_magic_links_on_token", unique: true
    t.index ["user_id"], name: "index_magic_links_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "extracted_data", default: {}, null: false
    t.bigint "question_id"
    t.integer "role", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["question_id"], name: "index_messages_on_question_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message"
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.string "notification_type"
    t.datetime "read_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "processing_activities", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "data_categories", default: []
    t.jsonb "data_subjects", default: []
    t.text "description"
    t.boolean "has_dpo", default: false
    t.boolean "has_joint_controller", default: false
    t.boolean "has_representative", default: false
    t.boolean "impact_assessment_required", default: false
    t.boolean "inadequate_protection_transfer", default: false
    t.jsonb "individual_rights", default: []
    t.text "information_modalities"
    t.string "name", null: false
    t.boolean "prior_authorization", default: false
    t.boolean "profiling", default: false
    t.bigint "response_id"
    t.jsonb "security_measures", default: []
    t.boolean "sensitive_data", default: false
    t.integer "sensitive_data_justification"
    t.jsonb "sensitive_data_types", default: []
    t.boolean "special_case_article", default: false
    t.string "special_case_reference"
    t.boolean "surveillance_purpose", default: false
    t.integer "transfer_derogation"
    t.jsonb "transfer_destinations", default: []
    t.integer "transfer_safeguard"
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_processing_activities_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_processing_activities_on_account_id"
    t.index ["response_id"], name: "index_processing_activities_on_response_id"
  end

  create_table "processing_purposes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "legal_basis", null: false
    t.integer "order_index", null: false
    t.bigint "processing_activity_id", null: false
    t.text "purpose_detail"
    t.string "purpose_name", null: false
    t.integer "purpose_number", null: false
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_processing_purposes_on_order_index"
    t.index ["processing_activity_id"], name: "index_processing_purposes_on_processing_activity_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "features", default: []
    t.string "name", null: false
    t.string "polar_product_id", null: false
    t.integer "price_amount", null: false
    t.string "price_currency", default: "usd", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["polar_product_id"], name: "index_products_on_polar_product_id", unique: true
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.text "intro_text"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_questionnaires_on_status"
  end

  create_table "questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "help_text"
    t.text "intro_text"
    t.boolean "is_required", default: false
    t.integer "order_index", null: false
    t.text "question_text", null: false
    t.integer "question_type", null: false
    t.bigint "section_id", null: false
    t.jsonb "settings", default: {}
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 5, scale: 2
    t.index ["order_index"], name: "index_questions_on_order_index"
    t.index ["section_id"], name: "index_questions_on_section_id"
  end

  create_table "recipient_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "detail"
    t.string "location"
    t.integer "order_index"
    t.bigint "processing_activity_id", null: false
    t.string "recipient_name", null: false
    t.integer "recipient_number"
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_recipient_categories_on_order_index"
    t.index ["processing_activity_id"], name: "index_recipient_categories_on_processing_activity_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "questionnaire_id", null: false
    t.bigint "respondent_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_responses_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_responses_on_account_id"
    t.index ["questionnaire_id"], name: "index_responses_on_questionnaire_id"
    t.index ["respondent_id"], name: "index_responses_on_respondent_id"
    t.index ["status"], name: "index_responses_on_status"
  end

  create_table "sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "intro_text"
    t.integer "order_index", null: false
    t.bigint "questionnaire_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["order_index"], name: "index_sections_on_order_index"
    t.index ["questionnaire_id"], name: "index_sections_on_questionnaire_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.datetime "ends_at"
    t.string "plan_name"
    t.string "polar_checkout_id"
    t.string "polar_subscription_id"
    t.bigint "product_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
    t.index ["polar_checkout_id"], name: "index_subscriptions_on_polar_checkout_id", unique: true
    t.index ["product_id"], name: "index_subscriptions_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "email_lifecycle_notifications", default: true, null: false
    t.string "name"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "access_categories", "processing_activities"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_sessions", "admins"
  add_foreign_key "answer_choices", "questions"
  add_foreign_key "answers", "answer_choices"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "responses"
  add_foreign_key "compliance_area_scores", "compliance_areas"
  add_foreign_key "compliance_area_scores", "compliance_assessments"
  add_foreign_key "compliance_assessments", "accounts"
  add_foreign_key "compliance_assessments", "responses", on_delete: :cascade
  add_foreign_key "conversations", "accounts"
  add_foreign_key "conversations", "questionnaires"
  add_foreign_key "conversations", "responses"
  add_foreign_key "data_category_details", "processing_activities"
  add_foreign_key "document_template_versions", "document_templates"
  add_foreign_key "documents", "accounts"
  add_foreign_key "documents", "responses"
  add_foreign_key "logic_rules", "questions", column: "source_question_id"
  add_foreign_key "logic_rules", "questions", column: "target_question_id"
  add_foreign_key "logic_rules", "sections", column: "target_section_id"
  add_foreign_key "magic_links", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "questions"
  add_foreign_key "notifications", "users"
  add_foreign_key "processing_activities", "accounts"
  add_foreign_key "processing_activities", "responses"
  add_foreign_key "processing_purposes", "processing_activities"
  add_foreign_key "questions", "sections"
  add_foreign_key "recipient_categories", "processing_activities"
  add_foreign_key "responses", "accounts"
  add_foreign_key "responses", "questionnaires"
  add_foreign_key "responses", "users", column: "respondent_id"
  add_foreign_key "sections", "questionnaires"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "subscriptions", "products"
  add_foreign_key "users", "accounts"
end
