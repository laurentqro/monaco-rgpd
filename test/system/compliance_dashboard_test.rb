require "application_system_test_case"

class ComplianceDashboardTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    @account = @user.account

    # Create a completed response with assessment
    @response = Response.create!(
      questionnaire: questionnaires(:published),
      account: @account,
      respondent: @user,
      status: :completed
    )

    @assessment = ComplianceAssessment.create!(
      response: @response,
      account: @account,
      overall_score: 65,
      max_possible_score: 100,
      status: :completed
    )

    # Create area scores
    ComplianceAreaScore.create!(
      compliance_assessment: @assessment,
      compliance_area: compliance_areas(:data_security),
      score: 45,
      max_score: 100
    )

    ComplianceAreaScore.create!(
      compliance_assessment: @assessment,
      compliance_area: compliance_areas(:legal_basis),
      score: 85,
      max_score: 100
    )

    # Generate action items
    ActionItemGenerator.new(@assessment).generate

    sign_in_as(@user)
  end

  test "displays action items inbox" do
    skip "Requires Selenium setup"
    visit dashboard_path

    assert_selector "h2", text: "Actions à réaliser"
    assert_selector ".action-item", count: 1  # Only data_security is below 80%
  end

  test "can mark action item as completed" do
    skip "Requires Selenium setup"
    visit dashboard_path

    within(".action-item") do
      click_button "Terminé"
    end

    assert_text "Action mise à jour"
    assert_no_selector ".action-item"
  end

  test "displays quick actions panel" do
    skip "Requires Selenium setup"
    visit dashboard_path

    assert_selector "h2", text: "Actions rapides"
    assert_button "Nouvelle évaluation"
    assert_button "Gérer les documents"
    assert_button "Voir les traitements"
  end

  test "displays compliance health snapshot" do
    skip "Requires Selenium setup"
    visit dashboard_path

    assert_selector "h2", text: "État de conformité par domaine"
    assert_text "Data Security"  # Area name
    assert_text "45%"  # Low score
    assert_text "Legal Basis"
    assert_text "85%"  # High score
  end

  test "can expand compliance area card" do
    skip "Requires Selenium setup"
    visit dashboard_path

    # Click on Data Security card
    within("div", text: "Data Security") do
      click_on  # Click anywhere on card
    end

    # Should show expanded content
    assert_text "Amélioration recommandée"
    assert_text "attention prioritaire"
  end

  test "compliance area cards show correct risk levels" do
    skip "Requires Selenium setup"
    visit dashboard_path

    # Data Security (45%) should be non-compliant (red)
    within("div", text: "Data Security") do
      assert_selector ".bg-red-100"
    end

    # Legal Basis (85%) should be compliant (green)
    within("div", text: "Legal Basis") do
      assert_selector ".bg-green-100"
    end
  end
end
