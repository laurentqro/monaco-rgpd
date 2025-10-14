class RecipientCategory < ApplicationRecord
  belongs_to :processing_activity

  validates :recipient_name, presence: true

  default_scope { order(order_index: :asc) }
end
