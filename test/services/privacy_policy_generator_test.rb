require "test_helper"

class PrivacyPolicyGeneratorTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:basic)
    @account.update(
      address: "12 Avenue des Spélugues, 98000 Monaco",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    @response = responses(:one)
  end

  test "raises AccountIncompleteError when account missing fields" do
    @account.address = nil

    generator = PrivacyPolicyGenerator.new(@account, @response)

    assert_raises(PrivacyPolicyGenerator::AccountIncompleteError) do
      generator.generate
    end
  end

  test "initializes with account and response" do
    generator = PrivacyPolicyGenerator.new(@account, @response)

    assert_not_nil generator
  end

  test "includes hr_administration section when has employees" do
    # Use fixture with "Avez-vous du personnel ?" = "Oui"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :hr_administration
  end

  test "includes email_management section when has professional email" do
    # Use fixture with email = "Oui"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :email_management
  end

  test "excludes telephony section when no telephony" do
    # Use fixture with telephony = "Non"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_not_includes sections, :telephony
  end

  test "always includes base sections" do
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :base
  end
end
