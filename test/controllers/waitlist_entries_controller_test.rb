require "test_helper"

class WaitlistEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_response = responses(:one)
    # Mark response as requiring waitlist
    @question = questions(:one)
    @choice = @question.answer_choices.create!(
      choice_text: "Association",
      order_index: 3,
      score: 0,
      triggers_waitlist: true,
      waitlist_feature_key: "association"
    )
    # Create an answer linking the response to the waitlist-triggering choice
    Answer.create!(
      response: @test_response,
      question: @question,
      answer_choice: @choice
    )
  end

  test "create adds email to waitlist" do
    response_id = @test_response.id
    assert_not_nil response_id, "@test_response.id should not be nil"

    assert_difference "WaitlistEntry.count", 1 do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "test@example.com",
          response_id: response_id
        }
      }
    end

    entry = WaitlistEntry.last
    assert_equal "test@example.com", entry.email
    assert_equal response_id, entry.response_id
    assert_equal [ "association" ], entry.features_needed

    assert_redirected_to root_path
  end

  test "create validates email format" do
    assert_no_difference "WaitlistEntry.count" do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "invalid-email",
          response_id: @test_response.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create requires email" do
    assert_no_difference "WaitlistEntry.count" do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          response_id: @test_response.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "Monaco exit flow creates entry without response" do
    assert_difference "WaitlistEntry.count", 1 do
      post waitlist_entries_path, params: {
        waitlist_entry: {
          email: "monaco@example.com",
          response_id: nil,
          features_needed: [ "geographic_expansion" ]
        }
      }
    end

    entry = WaitlistEntry.last
    assert_equal "monaco@example.com", entry.email
    assert_nil entry.response_id
    assert_equal [ "geographic_expansion" ], entry.features_needed

    assert_redirected_to root_path
  end
end
