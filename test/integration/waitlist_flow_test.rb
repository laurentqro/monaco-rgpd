require "test_helper"

class WaitlistFlowTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:basic)
    @user = users(:owner)
    sign_in_as(@user)

    # Create a test questionnaire with sections and questions
    @questionnaire = Questionnaire.create!(
      title: "Waitlist Test Questionnaire",
      description: "Testing waitlist flows",
      category: "compliance_assessment",
      status: :published
    )

    @section = @questionnaire.sections.create!(
      title: "Organization Info",
      description: "Basic information",
      order_index: 1
    )

    # Create Monaco question
    @monaco_question = @section.questions.create!(
      question_text: "Votre organisation est-elle établie à Monaco ?",
      question_type: :yes_no,
      is_required: true,
      weight: 0,
      order_index: 1
    )

    @monaco_yes = @monaco_question.answer_choices.create!(
      choice_text: "Oui",
      score: 0,
      order_index: 1
    )

    @monaco_no = @monaco_question.answer_choices.create!(
      choice_text: "Non",
      score: 0,
      order_index: 2,
      triggers_waitlist: true,
      waitlist_feature_key: "geographic_expansion"
    )

    # Create organization type question
    @org_question = @section.questions.create!(
      question_text: "Quel type d'organisation êtes-vous ?",
      question_type: :single_choice,
      is_required: true,
      weight: 0,
      order_index: 2
    )

    @org_entreprise = @org_question.answer_choices.create!(
      choice_text: "Entreprise",
      score: 0,
      order_index: 1
    )

    @org_association = @org_question.answer_choices.create!(
      choice_text: "Association",
      score: 0,
      order_index: 2,
      triggers_waitlist: true,
      waitlist_feature_key: "association"
    )

    # Create video surveillance question
    @video_question = @section.questions.create!(
      question_text: "Avez-vous un dispositif de vidéosurveillance ?",
      question_type: :yes_no,
      is_required: true,
      weight: 0,
      order_index: 3
    )

    @video_yes = @video_question.answer_choices.create!(
      choice_text: "Oui",
      score: 0,
      order_index: 1,
      triggers_waitlist: true,
      waitlist_feature_key: "video_surveillance"
    )

    @video_no = @video_question.answer_choices.create!(
      choice_text: "Non",
      score: 0,
      order_index: 2
    )
  end

  test "immediate exit flow for Monaco question" do
    # Navigate to questionnaire
    get questionnaire_path(@questionnaire)
    assert_response :success

    # Manually visit waitlist exit
    get waitlist_exit_questionnaire_path(@questionnaire)
    assert_response :success

    # Create a response for testing
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Setup the response to require waitlist
    response.answers.create!(question: @monaco_question, answer_choice: @monaco_no)

    # Submit email (this part works without JS)
    assert_difference "WaitlistEntry.count", 1 do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "monaco-expansion@example.com",
          response_id: response.id
        }
      }
    end

    entry = WaitlistEntry.last
    assert_includes entry.features_needed, "geographic_expansion"
  end

  test "completion flow for Association" do
    # Create response with Association answer
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    response.answers.create!(question: @org_question, answer_choice: @org_association)

    # View results
    get results_response_path(response)
    assert_response :success

    # Should show waitlist form
    assert response.requires_waitlist?

    # Submit email
    assert_difference "WaitlistEntry.count", 1 do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "association@example.com",
          response_id: response.id
        }
      }
    end

    entry = WaitlistEntry.last
    assert_equal "association@example.com", entry.email
    assert_includes entry.features_needed, "association"
  end

  test "multiple waitlist triggers captured correctly" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Add Association answer
    response.answers.create!(question: @org_question, answer_choice: @org_association)

    # Add video surveillance answer
    response.answers.create!(question: @video_question, answer_choice: @video_yes)

    # Submit waitlist entry
    assert_difference "WaitlistEntry.count", 1 do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "multi@example.com",
          response_id: response.id
        }
      }
    end

    entry = WaitlistEntry.last
    assert_equal 2, entry.features_needed.size
    assert_includes entry.features_needed, "association"
    assert_includes entry.features_needed, "video_surveillance"
  end

  test "waitlist entry validates email format" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    assert_no_difference "WaitlistEntry.count" do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "invalid-email",
          response_id: response.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "waitlist entry requires email" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    assert_no_difference "WaitlistEntry.count" do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          response_id: response.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "response detects when waitlist is required" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Initially no waitlist required
    assert_not response.requires_waitlist?
    assert_equal [], response.waitlist_features_needed

    # Add a waitlist-triggering answer
    response.answers.create!(question: @org_question, answer_choice: @org_association)

    # Reload to get fresh data
    response.reload

    # Now waitlist is required
    assert response.requires_waitlist?
    assert_equal [ "association" ], response.waitlist_features_needed
  end

  test "waitlist features are unique even with duplicate triggers" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Add answer with association feature key
    response.answers.create!(question: @org_question, answer_choice: @org_association)

    # Reload to get fresh data
    response.reload

    # Should only have one instance of "association" even if multiple triggers exist
    assert_equal 1, response.waitlist_features_needed.count("association")
    assert_equal [ "association" ], response.waitlist_features_needed
  end

  test "waitlist entry captures all triggered features from response" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Add multiple waitlist-triggering answers
    response.answers.create!(question: @org_question, answer_choice: @org_association)
    response.answers.create!(question: @video_question, answer_choice: @video_yes)

    # Verify features are detected
    assert_equal 2, response.waitlist_features_needed.size

    # Submit waitlist entry
    post waitlist_entries_path, params: {
      waitlist_entry: {
        email: "complete@example.com",
        response_id: response.id
      }
    }

    entry = WaitlistEntry.last
    assert_equal response.waitlist_features_needed.sort, entry.features_needed.sort
  end

  test "non-waitlist answers do not trigger waitlist requirement" do
    response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Add non-waitlist-triggering answers
    response.answers.create!(question: @monaco_question, answer_choice: @monaco_yes)
    response.answers.create!(question: @org_question, answer_choice: @org_entreprise)
    response.answers.create!(question: @video_question, answer_choice: @video_no)

    # Reload to get fresh data
    response.reload

    # Should not require waitlist
    assert_not response.requires_waitlist?
    assert_equal [], response.waitlist_features_needed
  end
end
