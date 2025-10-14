require "test_helper"

class QuestionnaireBranchingTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    sign_in_as(@user)

    # Create a test questionnaire with branching logic
    @questionnaire = Questionnaire.create!(
      title: "Test Questionnaire with Branching",
      description: "Test",
      category: "compliance_assessment",
      status: :published
    )

    @section1 = @questionnaire.sections.create!(
      title: "General Info",
      description: "Basic questions",
      order_index: 1
    )

    @employee_question = @section1.questions.create!(
      question_text: "How many employees?",
      question_type: :single_choice,
      is_required: true,
      weight: 0,
      order_index: 1
    )

    @zero_choice = @employee_question.answer_choices.create!(
      choice_text: "0",
      score: 0,
      order_index: 1
    )

    @one_plus_choice = @employee_question.answer_choices.create!(
      choice_text: "1+",
      score: 0,
      order_index: 2
    )

    @section2 = @questionnaire.sections.create!(
      title: "Employee Questions",
      description: "For companies with employees",
      order_index: 2
    )

    @section2.questions.create!(
      question_text: "Employee data question?",
      question_type: :yes_no,
      is_required: true,
      weight: 1,
      order_index: 1
    )

    @section3 = @questionnaire.sections.create!(
      title: "Data Collection",
      description: "For all companies",
      order_index: 3
    )

    # Create logic rule: if employees = 0, skip to section 3
    @logic_rule = @employee_question.logic_rules.create!(
      condition_type: :equals,
      condition_value: @zero_choice.id.to_s,
      action: :skip_to_section,
      target_section_id: @section3.id
    )
  end

  test "logic rules are included in questionnaire props" do
    get questionnaire_path(@questionnaire)

    assert_response :success
    assert_equal 1, @employee_question.logic_rules.count, "Should have one logic rule"

    logic_rule = @employee_question.logic_rules.first
    assert_equal "equals", logic_rule.condition_type
    assert_equal "skip_to_section", logic_rule.action
    assert_equal @section3.id, logic_rule.target_section_id
  end

  test "logic rule configuration is correct for skipping employee section" do
    assert_equal @zero_choice.id.to_s, @logic_rule.condition_value, "Logic rule should reference the zero choice ID"
    assert_equal @section3.id, @logic_rule.target_section_id, "Should skip to section 3"
    assert_equal "skip_to_section", @logic_rule.action
  end

  test "exit_questionnaire action terminates questionnaire with message" do
    # Create exit logic rule
    exit_question = @section1.questions.create!(
      question_text: "Are you based in Monaco?",
      question_type: :yes_no,
      is_required: true,
      weight: 0,
      order_index: 2
    )

    yes_choice = exit_question.answer_choices.create!(
      choice_text: "Yes",
      score: 0,
      order_index: 1
    )

    no_choice = exit_question.answer_choices.create!(
      choice_text: "No",
      score: 0,
      order_index: 2
    )

    exit_rule = exit_question.logic_rules.create!(
      condition_type: :equals,
      condition_value: no_choice.id.to_s,
      action: :exit_questionnaire,
      exit_message: "This questionnaire is only for Monaco-based organizations."
    )

    assert_equal "exit_questionnaire", exit_rule.action
    assert_equal "This questionnaire is only for Monaco-based organizations.", exit_rule.exit_message
    assert_nil exit_rule.target_section_id, "Exit rules don't need a target section"
  end
end
