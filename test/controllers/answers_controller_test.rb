require "test_helper"

class AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
    @response = responses(:one)
  end

  test "should create answer" do
    question = questions(:one)
    assert_difference("Answer.count") do
      post response_answers_url(@response), params: {
        answer: {
          question_id: question.id,
          answer_text: "Test answer"
        }
      }
    end
    assert_response :created

    # Verify the response includes the answer ID
    json_response = JSON.parse(response.body)
    assert json_response["id"].present?
  end

  test "should update answer" do
    answer = Answer.create!(
      response: @response,
      question: questions(:one),
      answer_text: "Original answer"
    )

    patch response_answer_url(@response, answer), params: {
      answer: {
        answer_text: "Updated answer"
      }
    }
    assert_response :no_content
    answer.reload
    assert_equal "Updated answer", answer.answer_text
  end
end
