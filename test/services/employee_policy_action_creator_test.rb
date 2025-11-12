require "test_helper"

class EmployeePolicyActionCreatorTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:basic)
    @response = responses(:master_response)
    @employee_question = questions(:has_personnel)
  end

  # T004: Test creates action item when answer is Oui to employee question
  test "creates action item when answer is Oui to employee question" do
    answer = Answer.new(
      response: @response,
      question: @employee_question,
      answer_choice: answer_choices(:has_personnel_yes)
    )

    assert_difference "ActionItem.count", 1 do
      EmployeePolicyActionCreator.new(answer).call
    end

    action_item = ActionItem.last
    assert_equal @account, action_item.account
    assert_equal @response, action_item.actionable
    assert_equal "Envoyer politique de confidentialité à vos salariés", action_item.title
    assert_equal "assessment", action_item.source
    assert_equal "high", action_item.priority
  end

  # T005: Test does not create duplicate action items
  test "does not create duplicate action items" do
    answer = Answer.new(
      response: @response,
      question: @employee_question,
      answer_choice: answer_choices(:has_personnel_yes)
    )

    EmployeePolicyActionCreator.new(answer).call

    assert_no_difference "ActionItem.count" do
      EmployeePolicyActionCreator.new(answer).call
    end
  end

  # T006: Test does not create action item for non-employee question
  test "does not create action item for non-employee question" do
    other_question = questions(:one)
    other_answer = Answer.new(
      response: @response,
      question: other_question,
      answer_choice: answer_choices(:yes_choice)
    )

    assert_no_difference "ActionItem.count" do
      EmployeePolicyActionCreator.new(other_answer).call
    end
  end
end
