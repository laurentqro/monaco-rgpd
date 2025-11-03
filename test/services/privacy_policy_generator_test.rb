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
end
