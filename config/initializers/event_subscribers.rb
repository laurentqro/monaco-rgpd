# Initialize event subscribers for email notifications
Rails.application.config.after_initialize do
  # Security event subscribers (always send emails)
  SecurityMailerSubscriber.subscribe!

  # Lifecycle event subscribers (respect user preferences)
  LifecycleMailerSubscriber.subscribe!
end
