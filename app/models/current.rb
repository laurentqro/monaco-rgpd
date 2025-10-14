class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :admin_session

  delegate :user, to: :session, allow_nil: true
  delegate :account, to: :user, allow_nil: true
  delegate :admin, to: :admin_session, allow_nil: true
end
