class ProcessingPurpose < ApplicationRecord
  belongs_to :processing_activity

  enum :legal_basis, {
    consent: 0,
    legal_obligation: 1,
    contract: 2,
    vital_interest: 3,
    public_interest: 4,
    legitimate_interest: 5
  }, prefix: true

  validates :purpose_name, presence: true
  validates :legal_basis, presence: true
  validates :purpose_number, presence: true
  validates :order_index, presence: true

  default_scope { order(order_index: :asc) }
end
