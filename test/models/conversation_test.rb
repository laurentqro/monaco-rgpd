require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "valid conversation" do
    conversation = Conversation.new(
      questionnaire: questionnaires(:compliance),
      account: accounts(:basic),
      status: :in_progress,
      started_at: Time.current
    )
    assert conversation.valid?
  end

  test "requires questionnaire" do
    conversation = Conversation.new(account: accounts(:basic))
    assert_not conversation.valid?
  end

  test "calculates duration" do
    conversation = conversations(:active)
    conversation.update(completed_at: conversation.started_at + 10.minutes)
    assert_equal 600, conversation.duration
  end

  test "returns nil duration when incomplete" do
    conversation = conversations(:active)
    assert_nil conversation.duration
  end
end
