require "test_helper"

class QuestionnaireTest < ActiveSupport::TestCase
  test "should create questionnaire with sections and questions" do
    questionnaire = Questionnaire.create!(
      title: "Test Questionnaire",
      category: "compliance_assessment",
      status: :published
    )

    section = questionnaire.sections.create!(
      title: "Test Section",
      order_index: 1
    )

    question = section.questions.create!(
      question_text: "Test question?",
      question_type: :yes_no,
      order_index: 1,
      is_required: true
    )

    assert_equal 1, questionnaire.sections.count
    assert_equal 1, section.questions.count
    assert_equal "Test question?", question.question_text
  end
end
