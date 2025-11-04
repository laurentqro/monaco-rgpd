require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  test "should create response for account" do
    account = accounts(:basic)
    questionnaire = questionnaires(:compliance)
    user = users(:owner)

    response = Response.create!(
      account: account,
      questionnaire: questionnaire,
      respondent: user,
      status: :in_progress
    )

    assert_equal account, response.account
    assert_equal "in_progress", response.status
  end

  test "should create answers for response" do
    response = responses(:one)
    question = questions(:one)

    answer = response.answers.create!(
      question: question,
      answer_value: { value: "Oui" },
      calculated_score: 100.0
    )

    assert_equal response, answer.response
    assert_equal "Oui", answer.answer_value["value"]
  end

  test "can have a conversation" do
    response = responses(:one)
    conversation = Conversation.create!(
      response: response,
      questionnaire: response.questionnaire,
      account: response.account,
      status: :completed,
      started_at: 1.hour.ago
    )
    assert_equal conversation, response.conversation
  end
end
