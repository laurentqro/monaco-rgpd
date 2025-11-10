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

  test "generates multiple activities for multiple yes answers" do
    # This will be relevant when we add more templates
    skip "Not yet implemented - need more templates"
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
