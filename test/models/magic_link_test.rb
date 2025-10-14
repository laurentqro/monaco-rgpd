require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  test "valid magic link" do
    link = MagicLink.new(
      user: users(:owner),
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 15.minutes.from_now
    )
    assert link.valid?
  end

  test "requires user" do
    link = MagicLink.new(token: "token", expires_at: 15.minutes.from_now)
    assert_not link.valid?
    assert_includes link.errors[:user], "must exist"
  end

  test "requires token" do
    link = MagicLink.new(user: users(:owner), expires_at: 15.minutes.from_now)
    assert_not link.valid?
    assert_includes link.errors[:token], "can't be blank"
  end

  test "requires expires_at" do
    link = MagicLink.new(user: users(:owner), token: "token")
    assert_not link.valid?
    assert_includes link.errors[:expires_at], "can't be blank"
  end

  test "token must be unique" do
    MagicLink.create!(user: users(:owner), token: "unique", expires_at: 15.minutes.from_now)
    link = MagicLink.new(user: users(:owner), token: "unique", expires_at: 15.minutes.from_now)
    assert_not link.valid?
    assert_includes link.errors[:token], "has already been taken"
  end

  test "belongs to user" do
    link = magic_links(:valid)
    assert_respond_to link, :user
    assert_instance_of User, link.user
  end

  test "generate_token sets token and expires_at" do
    link = MagicLink.new(user: users(:owner))
    link.generate_token
    assert_not_nil link.token
    assert_not_nil link.expires_at
    assert link.expires_at > Time.current
    assert link.expires_at < 20.minutes.from_now
  end

  test "expired? returns true after expiration" do
    link = MagicLink.create!(
      user: users(:owner),
      token: "expired",
      expires_at: 1.hour.ago
    )
    assert link.expired?
  end

  test "expired? returns false before expiration" do
    link = magic_links(:valid)
    assert_not link.expired?
  end

  test "used? returns true when used_at is set" do
    link = magic_links(:valid)
    link.update!(used_at: Time.current)
    assert link.used?
  end

  test "used? returns false when used_at is nil" do
    link = magic_links(:valid)
    assert_not link.used?
  end

  test "valid_for_use? returns true for unused, non-expired link" do
    link = magic_links(:valid)
    assert link.valid_for_use?
  end

  test "valid_for_use? returns false for expired link" do
    link = MagicLink.create!(
      user: users(:owner),
      token: "expired",
      expires_at: 1.hour.ago
    )
    assert_not link.valid_for_use?
  end

  test "valid_for_use? returns false for used link" do
    link = magic_links(:valid)
    link.update!(used_at: Time.current)
    assert_not link.valid_for_use?
  end

  test "mark_as_used! sets used_at" do
    link = magic_links(:valid)
    link.mark_as_used!
    assert_not_nil link.used_at
    assert link.used?
  end
end
