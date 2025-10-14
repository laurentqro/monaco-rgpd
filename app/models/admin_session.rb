class AdminSession < ApplicationRecord
  belongs_to :admin

  validates :admin, presence: true
end
