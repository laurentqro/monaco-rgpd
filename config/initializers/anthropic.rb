# frozen_string_literal: true

Anthropic.configure do |config|
  config.access_token = Rails.application.credentials.fetch(:anthropic_api_key)
end
