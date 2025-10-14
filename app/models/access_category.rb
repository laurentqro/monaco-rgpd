class AccessCategory < ApplicationRecord
  belongs_to :processing_activity

  validates :category_name, presence: true

  default_scope { order(order_index: :asc) }
end
