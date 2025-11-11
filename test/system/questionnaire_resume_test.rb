require "application_system_test_case"

class QuestionnaireResumeTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    @questionnaire = questionnaires(:master)
    sign_in_as(@user)

    # Create a response with some answers already
    @response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Answer first 3 questions
    @questions = @questionnaire.questions.order(:order_index).limit(3)
    @questions.each do |question|
      Answer.create!(
        response: @response,
        question: question,
        answer_choice_id: question.answer_choices.first.id
      )
    end

    # Fourth question should be the resume point
    @all_questions = @questionnaire.questions.order(:order_index)
    @fourth_question = @all_questions[3]
  end

  test "resumes at first unanswered question when returning to in-progress questionnaire" do
    visit questionnaire_response_path(@questionnaire, @response)

    # Should NOT see question 1
    refute_text @all_questions.first.question_text

    # Should see question 4 (first unanswered)
    assert_text @fourth_question.question_text

    # Progress should show 3 of N questions completed
    assert_selector "[data-testid='progress-percentage']", text: /\d+%/
  end

  test "resumes at last question when all questions answered but status is in_progress" do
    # Answer remaining questions (first 3 already answered in setup)
    all_questions = @questionnaire.questions.order(:order_index)
    remaining_questions = all_questions.drop(3)
    remaining_questions.each do |question|
      Answer.create!(
        response: @response,
        question: question,
        answer_choice_id: question.answer_choices.first.id
      )
    end

    visit questionnaire_response_path(@questionnaire, @response)

    # Should see last question
    assert_text all_questions.last.question_text

    # Progress should show 100%
    assert_selector "[data-testid='progress-percentage']", text: "100%"
  end

  test "clicking section in tube map navigates to first question of that section" do
    visit questionnaire_response_path(@questionnaire, @response)

    # Get sections
    sections = @questionnaire.sections.order(:order_index)
    first_section = sections.first
    second_section = sections.second

    # Should start at first unanswered question (question 4)
    assert_text @fourth_question.question_text

    # Click first section in tube map
    find("[data-section-id='#{first_section.id}']").click

    # Should navigate to first question of first section
    first_question_of_section = first_section.questions.order(:order_index).first
    assert_text first_question_of_section.question_text
  end
end
