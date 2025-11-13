require "test_helper"

class WaitlistEntryTest < ActiveSupport::TestCase
  test "valid waitlist entry" do
    entry = WaitlistEntry.new(
      email: "test@example.com",
      response: responses(:one),
      features_needed: [ "association" ]
    )

    assert entry.valid?
  end

  test "requires email" do
    entry = WaitlistEntry.new(
      response: responses(:one),
      features_needed: [ "association" ]
    )

    assert_not entry.valid?
    assert_includes entry.errors[:email], "doit être rempli"
  end

  test "requires response" do
    entry = WaitlistEntry.new(
      email: "test@example.com",
      features_needed: [ "association" ]
    )

    assert_not entry.valid?
    assert_includes entry.errors[:response], "doit exister"
  end

  test "validates email format" do
    entry = WaitlistEntry.new(
      email: "invalid-email",
      response: responses(:one),
      features_needed: [ "association" ]
    )

    assert_not entry.valid?
    assert_includes entry.errors[:email], "n'est pas valide"
  end

  test "features_needed defaults to empty array" do
    entry = WaitlistEntry.create!(
      email: "test@example.com",
      response: responses(:one)
    )

    assert_equal [], entry.features_needed
  end

  test "belongs to response" do
    entry = waitlist_entries(:one)
    assert_instance_of Response, entry.response
  end
end
