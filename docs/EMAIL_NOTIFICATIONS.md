# Email Notifications

## Overview

The email notification system is an event-driven architecture that sends transactional emails based on user actions and system events. It uses ActiveSupport::Notifications as the event bus to decouple event publishers from email delivery.

## Architecture

### Event-Driven Design

```
Controller/Model → Publish Event → Subscriber → Mailer → Email Queue → Delivery
```

**Key Benefits:**
- Decoupled: Event publishers don't need to know about email delivery
- Testable: Events can be tested independently from mailers
- Flexible: New subscribers can be added without modifying existing code
- Async: Emails are delivered via background jobs (deliver_later)

### Components

1. **Event Publishers**: Controllers or models that publish events using `ActiveSupport::Notifications.instrument`
2. **Subscribers**: Listen for specific events and trigger appropriate mailers
3. **Mailers**: Generate email content (HTML and text versions)
4. **Templates**: ERB views for email content
5. **User Preferences**: Database column controlling lifecycle email delivery

## Event Types

### Security Events (Always Sent)

Security emails are critical notifications that **cannot be disabled** by users. They are always sent regardless of user preferences.

| Event Name | Triggered When | Mailer Method |
|------------|----------------|---------------|
| `security.password_changed` | User changes their password | `SecurityMailer.password_changed` |
| `security.suspicious_login` | Login detected from new IP address | `SecurityMailer.suspicious_login` |
| `security.account_deletion_requested` | User requests account deletion | `SecurityMailer.account_deletion_requested` |

**Example Usage:**
```ruby
# After password update in controller
ActiveSupport::Notifications.instrument(
  "security.password_changed",
  user: current_user
)
```

### Lifecycle Events (User-Controlled)

Lifecycle emails are informational notifications that **respect user preferences**. Users can opt out via Settings.

| Event Name | Triggered When | Mailer Method |
|------------|----------------|---------------|
| `lifecycle.welcome` | New user account created | `LifecycleMailer.welcome` |
| `lifecycle.user_invited` | User invited to an organization | `LifecycleMailer.user_invited` |
| `lifecycle.role_changed` | User's role updated in organization | `LifecycleMailer.role_changed` |

**Example Usage:**
```ruby
# After user creation
ActiveSupport::Notifications.instrument(
  "lifecycle.welcome",
  user: @user
)

# After role update
ActiveSupport::Notifications.instrument(
  "lifecycle.role_changed",
  user: @user,
  old_role: "member",
  new_role: "admin"
)
```

## Publishing Events from Code

### Basic Event Publishing

Use `ActiveSupport::Notifications.instrument` to publish events:

```ruby
ActiveSupport::Notifications.instrument(
  "event.namespace",
  key1: value1,
  key2: value2
)
```

### Where to Publish Events

**Controllers** - Most common location for event publishing:
```ruby
class UsersController < ApplicationController
  def update
    if @user.update(user_params)
      # Publish event after successful update
      ActiveSupport::Notifications.instrument(
        "security.password_changed",
        user: @user
      ) if user_params.key?(:password)

      redirect_to @user
    else
      render :edit
    end
  end
end
```

**Models** - For model-level events:
```ruby
class User < ApplicationRecord
  after_commit :publish_welcome_event, on: :create

  private

  def publish_welcome_event
    ActiveSupport::Notifications.instrument(
      "lifecycle.welcome",
      user: self
    )
  end
end
```

**Service Objects** - For complex business logic:
```ruby
class CreateAccountService
  def call(params)
    user = User.create!(params)

    ActiveSupport::Notifications.instrument(
      "lifecycle.welcome",
      user: user
    )

    user
  end
end
```

## Adding New Email Types

Follow these steps to add a new email notification:

### 1. Decide Email Category

**Security Email** (always sent):
- Critical account security events
- Cannot be disabled by users
- Use `SecurityMailer`

**Lifecycle Email** (user preference):
- Informational account updates
- Can be disabled by users
- Use `LifecycleMailer`

### 2. Add Mailer Method

Edit `app/mailers/security_mailer.rb` or `app/mailers/lifecycle_mailer.rb`:

```ruby
class SecurityMailer < ApplicationMailer
  def new_email_type(user, additional_param)
    @user = user
    @additional_param = additional_param

    mail(
      to: @user.email,
      subject: "Your Subject Here"
    )
  end
end
```

### 3. Create Email Templates

Create both HTML and text versions:

**HTML** - `app/views/security_mailer/new_email_type.html.erb`:
```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body style="font-family: system-ui, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <h1 style="color: #2563eb; margin-bottom: 20px;">Email Title</h1>

  <p>Hi <%= @user.email %>,</p>

  <p>Your email content here.</p>

  <p style="color: #666; font-size: 14px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
    This is a security notification and cannot be disabled.
  </p>
</body>
</html>
```

**Text** - `app/views/security_mailer/new_email_type.text.erb`:
```erb
Email Title

Hi <%= @user.email %>,

Your email content here.

---
This is a security notification and cannot be disabled.
```

### 4. Add Subscriber Handler

Edit `app/subscribers/security_mailer_subscriber.rb` or `app/subscribers/lifecycle_mailer_subscriber.rb`:

```ruby
class SecurityMailerSubscriber
  class << self
    def subscribe!
      return if @subscribed

      # Add your new event subscription
      ActiveSupport::Notifications.subscribe("security.new_event_type") do |_name, _start, _finish, _id, payload|
        handle_new_event_type(payload)
      end

      # ... existing subscriptions ...

      @subscribed = true
    end

    private

    def handle_new_event_type(payload)
      user = payload[:user]
      additional_param = payload[:additional_param]

      return unless user
      return unless additional_param  # Validate required params

      SecurityMailer.new_email_type(user, additional_param).deliver_later
    rescue => e
      Rails.logger.error("Failed to send new email type: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
```

For lifecycle emails, add preference check:
```ruby
def handle_new_event_type(payload)
  user = payload[:user]
  return unless user
  return unless user.email_lifecycle_notifications?  # Check preference

  LifecycleMailer.new_email_type(user).deliver_later
end
```

### 5. Add Mailer Preview

Add to `test/mailers/previews/security_mailer_preview.rb`:

```ruby
class SecurityMailerPreview < ActionMailer::Preview
  def new_email_type
    SecurityMailer.new_email_type(User.first, "example_param")
  end
end
```

### 6. Write Tests

Create tests in `test/mailers/security_mailer_test.rb`:

```ruby
test "new_email_type email" do
  user = users(:owner)
  email = SecurityMailer.new_email_type(user, "example_param")

  assert_emails 1 do
    email.deliver_now
  end

  assert_equal [user.email], email.to
  assert_equal "Your Subject Here", email.subject
  assert_match "example_param", email.body.encoded
end
```

Add subscriber test in `test/subscribers/security_mailer_subscriber_test.rb`:

```ruby
test "sends new email type on security.new_event_type event" do
  assert_emails 1 do
    ActiveSupport::Notifications.instrument(
      "security.new_event_type",
      user: @user,
      additional_param: "example"
    )
  end
end
```

### 7. Publish Events

Add event publishing to appropriate controllers/models:

```ruby
class SomeController < ApplicationController
  def action
    # ... your logic ...

    ActiveSupport::Notifications.instrument(
      "security.new_event_type",
      user: current_user,
      additional_param: "value"
    )
  end
end
```

## User Preferences

### Database Schema

Users have an `email_lifecycle_notifications` boolean column:

```ruby
# db/schema.rb
t.boolean "email_lifecycle_notifications", default: true, null: false
```

- **Default**: `true` (users receive lifecycle emails by default)
- **Security emails**: Always sent regardless of this setting
- **Lifecycle emails**: Only sent when `true`

### Settings Page

Users can manage their email preferences at:
- **URL**: `/settings/notifications`
- **Controller**: `Settings::NotificationsController`
- **View**: `app/frontend/pages/settings/Notifications.svelte`

The settings page displays:
1. **Security Notifications** - Always enabled (read-only)
2. **Account Activity Notifications** - Toggle to enable/disable lifecycle emails

### Checking Preferences in Code

Lifecycle subscribers automatically check the preference:

```ruby
def handle_welcome(payload)
  user = payload[:user]
  return unless user
  return unless user.email_lifecycle_notifications?  # ← Preference check

  LifecycleMailer.welcome(user).deliver_later
end
```

## Email Previews

### Accessing Previews

Visit in development mode:
```
http://localhost:3000/rails/mailers
```

This displays all available email previews with live rendering.

### Preview Files

Previews are located in `test/mailers/previews/`:
- `security_mailer_preview.rb` - Security email previews
- `lifecycle_mailer_preview.rb` - Lifecycle email previews

### Creating Previews

```ruby
# test/mailers/previews/security_mailer_preview.rb
class SecurityMailerPreview < ActionMailer::Preview
  def password_changed
    SecurityMailer.password_changed(User.first)
  end

  def suspicious_login
    SecurityMailer.suspicious_login(
      User.first,
      "192.168.1.1",
      "Chrome on MacOS"
    )
  end
end
```

Previews use the first user from your database. Ensure you have seed data.

## Testing

### Running Email Tests

```bash
# All mailer tests
rails test test/mailers/

# Specific mailer
rails test test/mailers/security_mailer_test.rb

# All subscriber tests
rails test test/subscribers/

# Integration tests
rails test test/integration/email_notifications_integration_test.rb
```

### Test Helpers

Use these helpers in tests:

```ruby
# Assert email was sent
assert_emails 1 do
  SecurityMailer.password_changed(user).deliver_now
end

# Assert no emails sent
assert_no_emails do
  # code that shouldn't send email
end

# Process background jobs
perform_enqueued_jobs do
  ActiveSupport::Notifications.instrument("event.name", user: user)
end
```

### Testing Event Publishing

Test that events are published correctly:

```ruby
test "password update publishes security.password_changed event" do
  event_published = false

  ActiveSupport::Notifications.subscribe("security.password_changed") do |_name, _start, _finish, _id, payload|
    event_published = true
    assert_equal @user.id, payload[:user].id
  end

  patch user_url(@user), params: {
    user: {
      password: "newpassword",
      password_confirmation: "newpassword"
    }
  }

  assert event_published, "Expected security.password_changed event to be published"
end
```

### Testing Preference Behavior

Test that lifecycle emails respect preferences:

```ruby
test "welcome email respects user preferences" do
  user = users(:owner)

  # Enabled - should send
  user.update!(email_lifecycle_notifications: true)
  assert_emails 1 do
    ActiveSupport::Notifications.instrument("lifecycle.welcome", user: user)
    perform_enqueued_jobs
  end

  # Disabled - should not send
  user.update!(email_lifecycle_notifications: false)
  assert_no_emails do
    ActiveSupport::Notifications.instrument("lifecycle.welcome", user: user)
    perform_enqueued_jobs
  end
end
```

## Troubleshooting

### Emails Not Sending

1. **Check if event is being published**:
   ```ruby
   # Add temporary logging
   ActiveSupport::Notifications.subscribe(/.*/) do |name, start, finish, id, payload|
     Rails.logger.info "Event: #{name}, Payload: #{payload.inspect}"
   end
   ```

2. **Verify subscriber is initialized**:
   - Check `config/initializers/event_subscribers.rb`
   - Restart Rails server after changes

3. **Check background job queue**:
   ```bash
   # In Rails console
   Delayed::Job.all  # or whatever queue you're using
   ```

4. **Check logs for errors**:
   ```bash
   tail -f log/development.log | grep -i "email\|mailer"
   ```

### Lifecycle Emails Not Respecting Preferences

1. **Verify database column exists**:
   ```bash
   rails dbconsole
   \d users
   # Should show email_lifecycle_notifications column
   ```

2. **Check subscriber implementation**:
   - Ensure `user.email_lifecycle_notifications?` is checked
   - Located in `app/subscribers/lifecycle_mailer_subscriber.rb`

3. **Test preference in console**:
   ```ruby
   user = User.first
   user.email_lifecycle_notifications = false
   user.save!
   user.email_lifecycle_notifications? # Should return false
   ```

### Email Templates Not Rendering

1. **Verify both HTML and text versions exist**:
   ```bash
   ls app/views/security_mailer/
   # Should show both .html.erb and .text.erb files
   ```

2. **Check for ERB syntax errors**:
   - Templates must have valid ERB syntax
   - Instance variables must be defined in mailer method

3. **Preview emails in browser**:
   - Visit `/rails/mailers` in development
   - Check for rendering errors

### Testing Issues

1. **Subscribers firing multiple times**:
   - Clear listeners in test setup:
     ```ruby
     setup do
       ActiveSupport::Notifications.notifier
         .listeners_for("security.password_changed").clear
       SecurityMailerSubscriber.subscribe!
     end
     ```

2. **Background jobs not processing in tests**:
   - Add to test helper:
     ```ruby
     ActiveJob::Base.queue_adapter = :test
     include ActiveJob::TestHelper
     ```

3. **Emails not being counted**:
   - Use `perform_enqueued_jobs` wrapper:
     ```ruby
     assert_emails 1 do
       perform_enqueued_jobs do
         # code that queues email
       end
     end
     ```

## Configuration

### Email Delivery Settings

Configure in `config/environments/*.rb`:

```ruby
# Development - Log emails
config.action_mailer.delivery_method = :log

# Production - Send via SMTP (e.g., Resend)
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV["SMTP_ADDRESS"],
  port: ENV["SMTP_PORT"],
  authentication: :plain,
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"]
}
```

### Default From Address

Set in mailers:

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@example.com")
end
```

### Background Job Queue

Emails are sent via `deliver_later` which uses your configured job backend:

```ruby
# config/application.rb
config.active_job.queue_adapter = :solid_queue  # or :sidekiq, :delayed_job, etc.
```

## Best Practices

### Do's

- Always publish events after the database transaction completes
- Use both HTML and text email templates
- Write tests for both mailers and subscribers
- Include error handling in subscribers (already implemented)
- Use descriptive event names with namespaces (e.g., `security.*`, `lifecycle.*`)
- Check for required parameters in subscriber handlers
- Use `deliver_later` for async delivery

### Don'ts

- Don't send emails directly from controllers (use events instead)
- Don't forget to add mailer previews
- Don't publish events before database changes are persisted
- Don't skip the text email template (required for email clients)
- Don't add business logic to mailers (keep them simple)
- Don't forget to test event publishing in integration tests

## Examples

### Complete Example: Adding "Email Verified" Notification

1. **Add mailer method**:
```ruby
# app/mailers/security_mailer.rb
def email_verified(user)
  @user = user
  mail(to: @user.email, subject: "Email address verified")
end
```

2. **Create templates**:
```erb
<!-- app/views/security_mailer/email_verified.html.erb -->
<p>Hi <%= @user.email %>,</p>
<p>Your email address has been successfully verified.</p>
```

```erb
# app/views/security_mailer/email_verified.text.erb
Hi <%= @user.email %>,

Your email address has been successfully verified.
```

3. **Add subscriber**:
```ruby
# app/subscribers/security_mailer_subscriber.rb
ActiveSupport::Notifications.subscribe("security.email_verified") do |_name, _start, _finish, _id, payload|
  handle_email_verified(payload)
end

def handle_email_verified(payload)
  user = payload[:user]
  return unless user
  SecurityMailer.email_verified(user).deliver_later
end
```

4. **Publish event**:
```ruby
# app/controllers/email_verifications_controller.rb
def verify
  current_user.update!(email_verified: true)

  ActiveSupport::Notifications.instrument(
    "security.email_verified",
    user: current_user
  )

  redirect_to dashboard_path, notice: "Email verified!"
end
```

5. **Test it**:
```ruby
test "email verification sends notification" do
  assert_emails 1 do
    ActiveSupport::Notifications.instrument(
      "security.email_verified",
      user: users(:owner)
    )
    perform_enqueued_jobs
  end
end
```

## Related Files

### Core Files
- `app/mailers/security_mailer.rb` - Security email definitions
- `app/mailers/lifecycle_mailer.rb` - Lifecycle email definitions
- `app/subscribers/security_mailer_subscriber.rb` - Security event handlers
- `app/subscribers/lifecycle_mailer_subscriber.rb` - Lifecycle event handlers
- `config/initializers/event_subscribers.rb` - Subscriber initialization

### Views
- `app/views/security_mailer/` - Security email templates
- `app/views/lifecycle_mailer/` - Lifecycle email templates

### Settings
- `app/controllers/settings/notifications_controller.rb` - Preferences controller
- `app/frontend/pages/settings/Notifications.svelte` - Settings UI

### Tests
- `test/mailers/security_mailer_test.rb`
- `test/mailers/lifecycle_mailer_test.rb`
- `test/subscribers/security_mailer_subscriber_test.rb`
- `test/subscribers/lifecycle_mailer_subscriber_test.rb`
- `test/integration/email_notifications_integration_test.rb`
- `test/mailers/previews/` - Email preview definitions

## Further Reading

- [ActiveSupport::Notifications Guide](https://guides.rubyonrails.org/active_support_instrumentation.html)
- [Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Active Job Basics](https://guides.rubyonrails.org/active_job_basics.html)
