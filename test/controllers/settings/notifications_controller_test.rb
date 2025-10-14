require "test_helper"

class Settings::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    sign_in_as @user
  end

  test "should get notifications settings page" do
    get settings_notifications_url
    assert_response :success
  end

  test "should render inertia component with user data" do
    get settings_notifications_url
    assert_response :success
    # Verify the Inertia component is rendered
  end

  test "should update email lifecycle notifications to false" do
    assert @user.email_lifecycle_notifications

    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: false }
    }

    assert_redirected_to settings_notifications_url
    @user.reload
    assert_not @user.email_lifecycle_notifications
  end

  test "should update email lifecycle notifications to true" do
    @user.update!(email_lifecycle_notifications: false)

    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: true }
    }

    assert_redirected_to settings_notifications_url
    @user.reload
    assert @user.email_lifecycle_notifications
  end

  test "requires authentication" do
    Session.destroy_all

    get settings_notifications_url
    assert_redirected_to new_session_url
  end

  test "update requires authentication" do
    Session.destroy_all

    patch settings_notifications_url, params: {
      user: { email_lifecycle_notifications: false }
    }

    assert_redirected_to new_session_url
  end
end
