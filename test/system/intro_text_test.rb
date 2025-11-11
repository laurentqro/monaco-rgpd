require "application_system_test_case"

class IntroTextTest < ApplicationSystemTestCase
  setup do
    # Use fixtures
    @questionnaire = questionnaires(:compliance)
    @user = users(:owner)
    @account = accounts(:basic)

    # Sign in the user using the test helper
    sign_in_as(@user)
  end

  test "displays questionnaire intro_text at the start of questionnaire wizard" do
    # Create a response
    response = Response.create!(
      questionnaire: @questionnaire,
      respondent: @user,
      account: @account
    )

    # Navigate to the questionnaire wizard
    visit questionnaire_response_path(@questionnaire, response)

    # Check for intro_text presence - questionnaire intro uses plain variant
    assert_selector ".intro-text-plain", text: "Bienvenue"
    assert_selector ".intro-text-plain", text: "Loi n° 1.565"

    # Take screenshot for visual verification
    take_screenshot
  end

  test "displays section intro_text at the beginning of a section" do
    # Create a response
    response = Response.create!(
      questionnaire: @questionnaire,
      respondent: @user,
      account: @account
    )

    # Navigate to the questionnaire wizard (should show section intro on first question of section)
    visit questionnaire_response_path(@questionnaire, response)

    # First need to start the questionnaire
    click_button "Commencer l'évaluation"

    # Look for section intro_text content (uses plain variant)
    assert_selector ".intro-text-plain", text: "pratiques actuelles"

    take_screenshot
  end

  test "displays question intro_text in QuestionCard" do
    # Create a response
    response = Response.create!(
      questionnaire: @questionnaire,
      respondent: @user,
      account: @account
    )

    # Navigate to the questionnaire wizard
    visit questionnaire_response_path(@questionnaire, response)

    # First need to start the questionnaire
    click_button "Commencer l'évaluation"

    # The first question has intro_text about DPO (uses boxed variant, class is "intro-text")
    assert_selector ".intro-text", text: "Délégué à la Protection des Données"

    # Verify the question title is visible
    assert_text "Avez-vous nommé un DPO?"

    # Verify the intro_text appears before the question title
    page_content = page.find("body").text
    intro_index = page_content.index("Délégué à la Protection des Données")
    question_index = page_content.index("Avez-vous nommé un DPO?")

    assert intro_index < question_index, "Intro text should appear before question title"

    take_screenshot
  end

  test "intro_text supports markdown rendering" do
    # Create a response
    response = Response.create!(
      questionnaire: @questionnaire,
      respondent: @user,
      account: @account
    )

    # Navigate to the questionnaire wizard
    visit questionnaire_response_path(@questionnaire, response)

    # Check that markdown bold is rendered on the start screen (uses plain variant)
    within ".intro-text-plain" do
      assert_selector "strong", text: "Loi n° 1.565"
    end

    take_screenshot
  end
end
