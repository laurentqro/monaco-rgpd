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
      answer_text: "Oui",
      calculated_score: 100.0
    )

    assert_equal response, answer.response
    assert_equal "Oui", answer.answer_text
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

  test "automatically generates processing activities when marked as completed" do
    account = accounts(:basic)
    questionnaire = questionnaires(:master)
    user = users(:owner)

    # Create response in progress
    response = Response.create!(
      account: account,
      questionnaire: questionnaire,
      respondent: user,
      status: :in_progress,
      started_at: 1.hour.ago
    )

    # Add answer: Yes to personnel question
    personnel_question = questions(:has_personnel)
    yes_choice = answer_choices(:has_personnel_yes)
    response.answers.create!(
      question: personnel_question,
      answer_choice: yes_choice
    )

    # Mark as completed - should trigger processing activity generation
    assert_difference -> { account.processing_activities.count }, 1 do
      response.update!(status: :completed, completed_at: Time.current)
    end

    # Verify the processing activity was created correctly
    activity = account.processing_activities.last
    assert_equal "Gestion administrative des salariés", activity.name
    assert_equal response.id, activity.response_id
  end

  test "does not generate processing activities when updating other fields" do
    response = responses(:completed_response)

    assert_no_difference -> { response.account.processing_activities.count } do
      response.update!(started_at: 2.hours.ago)
    end
  end

  test "does not generate processing activities when already completed" do
    account = accounts(:basic)
    questionnaire = questionnaires(:master)
    user = users(:owner)

    # Create already completed response
    response = Response.create!(
      account: account,
      questionnaire: questionnaire,
      respondent: user,
      status: :completed,
      started_at: 1.hour.ago,
      completed_at: Time.current
    )

    # Add answer after completion
    personnel_question = questions(:has_personnel)
    yes_choice = answer_choices(:has_personnel_yes)
    response.answers.create!(
      question: personnel_question,
      answer_choice: yes_choice
    )

    # Updating completed response should not trigger generation again
    assert_no_difference -> { account.processing_activities.count } do
      response.touch # Trigger update without changing status
    end
  end
end
