# frozen_string_literal: true

require "test_helper"

class ProcessingActivityGeneratorTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:basic)
    @questionnaire = questionnaires(:master)
    @respondent = users(:owner)

    # Create a fresh response for testing
    @response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @respondent,
      status: :completed,
      started_at: 1.hour.ago,
      completed_at: Time.current
    )
  end

  test "generates employee admin processing activity when user answers yes to has personnel" do
    # Find the "has personnel" question
    personnel_question = questions(:has_personnel)
    yes_choice = answer_choices(:has_personnel_yes)

    # Create answer: Yes to personnel question
    @response.answers.create!(
      question: personnel_question,
      answer_choice: yes_choice
    )

    # Generate processing activities
    generator = ProcessingActivityGenerator.new(@response)

    assert_difference -> { @account.processing_activities.count }, 1 do
      generator.generate_from_questionnaire
    end

    activity = @account.processing_activities.last
    assert_equal "Gestion administrative des salariés", activity.name
    assert_equal @response.id, activity.response_id
    assert_equal 14, activity.processing_purposes.count
    assert_equal 7, activity.data_category_details.count
    assert_equal 4, activity.access_categories.count
    assert_equal 6, activity.recipient_categories.count
    assert_equal false, activity.surveillance_purpose
    assert_equal false, activity.sensitive_data
  end

  test "does not generate activity when user answers no to has personnel" do
    personnel_question = questions(:has_personnel)
    no_choice = answer_choices(:has_personnel_no)

    @response.answers.create!(
      question: personnel_question,
      answer_choice: no_choice
    )

    generator = ProcessingActivityGenerator.new(@response)

    assert_no_difference -> { @account.processing_activities.count } do
      generator.generate_from_questionnaire
    end
  end

  test "does not generate activity when question is not answered" do
    # No answer created for personnel question

    generator = ProcessingActivityGenerator.new(@response)

    assert_no_difference -> { @account.processing_activities.count } do
      generator.generate_from_questionnaire
    end
  end

  test "generates professional email processing activity when user answers yes to has email" do
    email_question = questions(:has_email)
    yes_choice = answer_choices(:has_email_yes)

    @response.answers.create!(
      question: email_question,
      answer_choice: yes_choice
    )

    generator = ProcessingActivityGenerator.new(@response)

    assert_difference -> { @account.processing_activities.count }, 1 do
      generator.generate_from_questionnaire
    end

    activity = @account.processing_activities.last
    assert_equal "Gestion de la messagerie professionnelle", activity.name
    assert_equal @response.id, activity.response_id
    assert_equal 8, activity.processing_purposes.count
    assert_equal 5, activity.data_category_details.count
    assert_equal 3, activity.access_categories.count
    assert_equal 1, activity.recipient_categories.count
    assert_equal false, activity.surveillance_purpose
    assert_equal false, activity.sensitive_data
    assert_equal false, activity.inadequate_protection_transfer
  end

  test "generates telephony processing activity when user answers yes to has telephony" do
    telephony_question = questions(:has_telephony)
    yes_choice = answer_choices(:has_telephony_yes)

    @response.answers.create!(
      question: telephony_question,
      answer_choice: yes_choice
    )

    generator = ProcessingActivityGenerator.new(@response)

    assert_difference -> { @account.processing_activities.count }, 1 do
      generator.generate_from_questionnaire
    end

    activity = @account.processing_activities.last
    assert_equal "Gestion de la téléphonie fixe et mobile", activity.name
    assert_equal @response.id, activity.response_id
    assert_equal 7, activity.processing_purposes.count
    assert_equal 4, activity.data_category_details.count
    assert_equal 3, activity.access_categories.count
    assert_equal 1, activity.recipient_categories.count
    assert_equal false, activity.surveillance_purpose
    assert_equal false, activity.sensitive_data
  end

  test "generates website showcase processing activity when user answers yes to has website" do
    website_question = questions(:has_website)
    yes_choice = answer_choices(:has_website_yes)

    @response.answers.create!(
      question: website_question,
      answer_choice: yes_choice
    )

    generator = ProcessingActivityGenerator.new(@response)

    assert_difference -> { @account.processing_activities.count }, 1 do
      generator.generate_from_questionnaire
    end

    activity = @account.processing_activities.last
    assert_equal "Gestion d'un site Internet vitrine de la société", activity.name
    assert_equal @response.id, activity.response_id
    assert_equal 5, activity.processing_purposes.count
    assert_equal 6, activity.data_category_details.count
    assert_equal 3, activity.access_categories.count
    assert_equal 1, activity.recipient_categories.count
    assert_equal false, activity.surveillance_purpose
    assert_equal false, activity.sensitive_data
    assert_equal true, activity.inadequate_protection_transfer
  end

  test "generates multiple activities for multiple yes answers" do
    personnel_question = questions(:has_personnel)
    email_question = questions(:has_email)
    telephony_question = questions(:has_telephony)
    website_question = questions(:has_website)

    @response.answers.create!(
      question: personnel_question,
      answer_choice: answer_choices(:has_personnel_yes)
    )
    @response.answers.create!(
      question: email_question,
      answer_choice: answer_choices(:has_email_yes)
    )
    @response.answers.create!(
      question: telephony_question,
      answer_choice: answer_choices(:has_telephony_yes)
    )
    @response.answers.create!(
      question: website_question,
      answer_choice: answer_choices(:has_website_yes)
    )

    generator = ProcessingActivityGenerator.new(@response)

    assert_difference -> { @account.processing_activities.count }, 4 do
      generator.generate_from_questionnaire
    end

    activity_names = @account.processing_activities.pluck(:name)
    assert_includes activity_names, "Gestion administrative des salariés"
    assert_includes activity_names, "Gestion de la messagerie professionnelle"
    assert_includes activity_names, "Gestion de la téléphonie fixe et mobile"
    assert_includes activity_names, "Gestion d'un site Internet vitrine de la société"
  end

  test "security measures are stored as hashes with reference documents" do
    email_question = questions(:has_email)
    yes_choice = answer_choices(:has_email_yes)

    @response.answers.create!(
      question: email_question,
      answer_choice: yes_choice
    )

    generator = ProcessingActivityGenerator.new(@response)
    generator.generate_from_questionnaire

    activity = @account.processing_activities.last
    assert activity.security_measures.is_a?(Array)
    assert activity.security_measures.all? { |m| m.is_a?(Hash) }
    assert activity.security_measures.all? { |m| m.key?("measure") && m.key?("reference_documents") }

    first_measure = activity.security_measures.first
    assert_equal "Serveur situé dans une baie informatique sécurisée", first_measure["measure"]
    assert_equal "Politique de sécurité + schéma d'architecture sécurisée", first_measure["reference_documents"]
  end

  test "does not duplicate activities if called multiple times" do
    personnel_question = questions(:has_personnel)
    yes_choice = answer_choices(:has_personnel_yes)

    @response.answers.create!(
      question: personnel_question,
      answer_choice: yes_choice
    )

    generator = ProcessingActivityGenerator.new(@response)

    # First generation
    assert_difference -> { @account.processing_activities.count }, 1 do
      generator.generate_from_questionnaire
    end

    # Second generation should not create duplicates
    assert_no_difference -> { @account.processing_activities.count } do
      generator.generate_from_questionnaire
    end
  end
end
