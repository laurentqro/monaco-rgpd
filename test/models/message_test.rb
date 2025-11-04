require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "valid message" do
    message = Message.new(
      conversation: conversations(:active),
      role: :user,
      content: "Yes, we have a DPO"
    )
    assert message.valid?
  end

  test "requires conversation" do
    message = Message.new(role: :user, content: "test")
    assert_not message.valid?
  end

  test "requires role" do
    message = Message.new(conversation: conversations(:active), content: "test")
    assert_not message.valid?
  end

  test "checks if extracted answers exist" do
    message = messages(:with_extraction)
    assert message.extracted_answers?
  end
end
