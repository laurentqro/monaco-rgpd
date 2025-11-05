require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  test "creates answer with answer_choice" do
    question = questions(:one)
    choice = question.answer_choices.first

    answer = Answer.create!(
      response: responses(:one),
      question: question,
      answer_choice: choice,
      calculated_score: 100.0
    )

    assert_equal choice, answer.answer_choice
    assert_equal choice.choice_text, answer.answer_choice_text
  end

  test "creates answer with answer_text" do
    question = questions(:one)

    answer = Answer.create!(
      response: responses(:one),
      question: question,
      answer_text: "Sample text response",
      calculated_score: 50.0
    )

    assert_equal "Sample text response", answer.answer_text
  end

  test "requires at least one answer field" do
    answer = Answer.new(
      response: responses(:one),
      question: questions(:one)
    )

    assert_not answer.valid?
    assert_includes answer.errors[:base], "At least one answer field must be present"
  end

  test "prevents multiple answer fields" do
    answer = Answer.new(
      response: responses(:one),
      question: questions(:one),
      answer_text: "text",
      answer_rating: 5
    )

    assert_not answer.valid?
    assert_includes answer.errors[:base], "Only one answer field can be set"
  end
end
