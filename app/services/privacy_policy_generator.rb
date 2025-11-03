class PrivacyPolicyGenerator
  class AccountIncompleteError < StandardError; end

  def initialize(account, response)
    @account = account
    @response = response
  end

  def generate
    validate_account_completeness!

    # Will implement in next task
    nil
  end

  private

  def validate_account_completeness!
    unless @account.complete_for_document_generation?
      missing = @account.missing_profile_fields.join(", ")
      raise AccountIncompleteError, "Missing required fields: #{missing}"
    end
  end
end
