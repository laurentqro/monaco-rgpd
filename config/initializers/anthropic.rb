# frozen_string_literal: true

# Official Anthropic SDK configuration
# The SDK will use ENV["ANTHROPIC_API_KEY"] by default, or you can pass api_key to the client
# We store the key in Rails credentials for better security

# Only set if not already in ENV and credentials are available
# This allows asset precompilation to work without credentials
if ENV["ANTHROPIC_API_KEY"].blank?
  api_key = Rails.application.credentials.dig(:anthropic_api_key)
  ENV["ANTHROPIC_API_KEY"] = api_key if api_key.present?
end
