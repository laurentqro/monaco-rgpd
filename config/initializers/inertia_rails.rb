# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest

  # Include empty errors hash in all responses (InertiaRails 4.0 compliance)
  config.always_include_errors_hash = true
end
