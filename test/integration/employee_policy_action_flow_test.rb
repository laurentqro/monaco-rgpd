require "test_helper"

class EmployeePolicyActionFlowTest < ActiveSupport::TestCase
  # T014: Integration test for end-to-end flow
  test "completing questionnaire with employees creates action item with correct attributes" do
    account = accounts(:basic)
    response = responses(:master_response)
    question = questions(:has_personnel)
    yes_choice = answer_choices(:has_personnel_yes)

    # Start with no action items
    initial_count = ActionItem.count

    # Answer employee question with "Oui"
    answer = nil
    assert_difference "ActionItem.count", 1 do
      answer = Answer.create!(
        response: response,
        question: question,
        answer_choice: yes_choice
      )
    end

    # Verify action item created with correct attributes
    action_item = ActionItem.last
    assert_equal account, action_item.account, "Action item should belong to the account"
    assert_equal response, action_item.actionable, "Action item should be linked to response"
    assert_equal "Envoyer politique de confidentialité à vos salariés", action_item.title
    assert_equal "assessment", action_item.source
    assert_equal "high", action_item.priority
    assert_equal "pending", action_item.status
    assert_includes action_item.description, "Loi n° 1.565", "Description should mention Monaco Law"

    # Verify idempotency - answering again doesn't create duplicate
    assert_no_difference "ActionItem.count" do
      answer.touch # Trigger update callback
    end
  end

  test "answering Non to employee question does not create action item" do
    response = responses(:master_response)
    question = questions(:has_personnel)
    no_choice = answer_choices(:has_personnel_no)

    # Answer employee question with "Non"
    assert_no_difference "ActionItem.count" do
      Answer.create!(
        response: response,
        question: question,
        answer_choice: no_choice
      )
    end
  end

  test "changing answer from Non to Oui creates action item" do
    response = responses(:master_response)
    question = questions(:has_personnel)
    no_choice = answer_choices(:has_personnel_no)
    yes_choice = answer_choices(:has_personnel_yes)

    # First answer "Non" - no action item
    answer = Answer.create!(
      response: response,
      question: question,
      answer_choice: no_choice
    )

    assert_equal 0, ActionItem.where(account: response.account, actionable: response).count

    # Change answer to "Oui" - action item should be created
    assert_difference "ActionItem.count", 1 do
      answer.update!(answer_choice: yes_choice)
    end

    action_item = ActionItem.last
    assert_equal "Envoyer politique de confidentialité à vos salariés", action_item.title
  end
end
