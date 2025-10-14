class Document < ApplicationRecord
  belongs_to :account
  belongs_to :response
  has_one_attached :pdf_file

  enum :document_type, {
    privacy_policy: 0,
    processing_register: 1,
    consent_form: 2,
    employee_notice: 3
  }, prefix: true

  enum :status, {
    generating: 0,
    ready: 1,
    failed: 2
  }, prefix: true

  validates :title, presence: true
  validates :document_type, presence: true
  validates :status, presence: true

  scope :for_account, ->(account) { where(account: account) }
  scope :ready, -> { where(status: :ready) }
end
