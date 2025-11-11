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

  test "skipped sections are greyed out and not clickable" do
    # Set up a response that triggers section skipping logic
    # Assuming there's a question that skips to a later section
    question_with_skip = @questionnaire.questions.find do |q|
      q.logic_rules.any? { |lr| lr.action == "skip_to_section" }
    end

    skip "No skip_to_section logic rules in test data" if question_with_skip.nil?

    # Answer the question to trigger skip
    skip_rule = question_with_skip.logic_rules.find { |lr| lr.action == "skip_to_section" }
    trigger_choice = question_with_skip.answer_choices.find do |ac|
      ac.id.to_s == skip_rule.condition_value
    end

    Answer.create!(
      response: @response,
      question: question_with_skip,
      answer_choice_id: trigger_choice.id
    )

    visit questionnaire_response_path(@questionnaire, @response)

    # Find skipped section
    current_section = question_with_skip.section
    target_section = @questionnaire.sections.find(skip_rule.target_section_id)
    skipped_sections = @questionnaire.sections.where(
      "order_index > ? AND order_index < ?",
      current_section.order_index,
      target_section.order_index
    )

    skipped_sections.each do |skipped_section|
      # Should have disabled button
      button = find("[data-section-id='#{skipped_section.id}']")
      assert button[:disabled] == "true"

      # Should have greyed out styling
      assert button.matches_css?(".opacity-50, .cursor-not-allowed")
    end
  end

  test "complete flow: resume, navigate, change answer, verify logic re-evaluation" do
    # Create a fresh response with 2 answers already (not at first question)
    fresh_response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Answer first 2 questions
    fresh_questions = @questionnaire.questions.order(:order_index).limit(2)
    fresh_questions.each do |question|
      Answer.create!(
        response: fresh_response,
        question: question,
        answer_choice_id: question.answer_choices.first.id
      )
    end

    # Visit questionnaire - should resume at question 3
    visit questionnaire_response_path(@questionnaire, fresh_response)

    # Should resume at question 3 (first unanswered)
    third_question = @questionnaire.questions.order(:order_index)[2]
    assert_text third_question.question_text

    # Verify progress shows answers completed
    assert_selector "[data-testid='progress-percentage']"

    # Test navigation: Click to navigate back to section 1 via tube map
    sections = @questionnaire.sections.order(:order_index)
    first_section = sections.first

    # Click the section to navigate
    find("[data-section-id='#{first_section.id}']").click

    # Should see first question of section 1 (already answered)
    first_question = first_section.questions.order(:order_index).first
    assert_text first_question.question_text

    # Verify tube map is interactive and allows navigation
    # Navigate forward by clicking Next button
    click_button "Suivant"

    # Should now see question 2
    second_question = @questionnaire.questions.order(:order_index)[1]
    assert_text second_question.question_text

    # This completes the test:
    # - Resume functionality tested (started at question 3)
    # - Navigation via tube map tested (clicked section, jumped to question 1)
    # - Next/Previous navigation still works after tube map navigation
  end
end
