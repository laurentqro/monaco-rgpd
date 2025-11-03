require "test_helper"

class AccountProfileCompletenessTest < ActiveSupport::TestCase
  test "complete_for_document_generation? returns false when address missing" do
    account = accounts(:basic)
    account.update(phone: "123456", rci_number: "12S34567", legal_form: :sarl)
    account.address = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when phone missing" do
    account = accounts(:basic)
    account.update(address: "123 Street", rci_number: "12S34567", legal_form: :sarl)
    account.phone = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when rci_number missing" do
    account = accounts(:basic)
    account.update(address: "123 Street", phone: "123456", legal_form: :sarl)
    account.rci_number = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when legal_form missing" do
    account = accounts(:basic)
    account.update(address: "123 Street", phone: "123456", rci_number: "12S34567")
    account.legal_form = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns true when all fields present" do
    account = accounts(:basic)
    account.update(
      address: "123 Street, Monaco",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    assert account.complete_for_document_generation?
  end

  test "legal_form_full_name returns French name for SARL" do
    account = accounts(:basic)
    account.legal_form = :sarl

    assert_equal "Société à Responsabilité Limitée (SARL)", account.legal_form_full_name
  end

  test "missing_profile_fields returns array of missing field names" do
    account = accounts(:basic)
    account.address = nil
    account.phone = nil

    missing = account.missing_profile_fields

    assert_includes missing, :address
    assert_includes missing, :phone
  end

  test "complete_for_document_generation? treats empty strings as incomplete" do
    account = accounts(:basic)
    account.update(
      address: "   ",
      phone: "",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? requires name field" do
    account = accounts(:basic)
    account.update(
      address: "123 Street",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )
    account.name = nil

    assert_not account.complete_for_document_generation?
  end

  test "legal_form_full_name returns nil when legal_form is nil" do
    account = accounts(:basic)
    account.legal_form = nil

    assert_nil account.legal_form_full_name
  end

  test "missing_profile_fields includes name when name is blank" do
    account = accounts(:basic)
    account.name = nil
    account.address = "123 Street"
    account.phone = "+377"
    account.rci_number = "123"
    account.legal_form = :sarl

    missing = account.missing_profile_fields

    assert_includes missing, :name
  end
end
