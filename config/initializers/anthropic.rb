# frozen_string_literal: true

# Official Anthropic SDK configuration
# The SDK will use ENV["ANTHROPIC_API_KEY"] by default, or you can pass api_key to the client
# We store the key in Rails credentials for better security
ENV["ANTHROPIC_API_KEY"] ||= Rails.application.credentials.fetch(:anthropic_api_key)
