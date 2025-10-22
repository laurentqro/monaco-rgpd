require "test_helper"

class ProcessingActivityTest < ActiveSupport::TestCase
  test "should create processing activity with nested structures" do
    account = accounts(:basic)

    activity = ProcessingActivity.create!(
      account: account,
      name: "Gestion administrative des salariés",
      has_dpo: true,
      surveillance_purpose: false,
      data_subjects: [ "employees" ],
      sensitive_data: false
    )

    purpose = activity.processing_purposes.create!(
      purpose_number: 1,
      purpose_name: "Gestion de la procédure d'embauche",
      legal_basis: :contract,
      order_index: 1
    )

    data_category = activity.data_category_details.create!(
      category_type: :identity_family,
      detail: "Nom, prénom, date de naissance",
      retention_period: "Tant que la personne est en poste",
      data_source: "Personnes concernées + Service RH"
    )

    assert_equal 1, activity.processing_purposes.count
    assert_equal 1, activity.data_category_details.count
  end
end
