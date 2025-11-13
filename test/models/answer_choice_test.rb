require "test_helper"

class AnswerChoiceTest < ActiveSupport::TestCase
  test "can mark answer choice as waitlist trigger" do
    choice = answer_choices(:yes_choice)
    choice.update!(
      triggers_waitlist: true,
      waitlist_feature_key: "association"
    )

    assert choice.triggers_waitlist?
    assert_equal "association", choice.waitlist_feature_key
  end

  test "waitlist trigger defaults to false" do
    choice = AnswerChoice.create!(
      question: questions(:one),
      choice_text: "Test",
      order_index: 1,
      score: 0
    )

    assert_not choice.triggers_waitlist?
    assert_nil choice.waitlist_feature_key
  end
end
