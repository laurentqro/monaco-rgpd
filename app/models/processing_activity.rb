class ProcessingActivity < ApplicationRecord
  belongs_to :account
  belongs_to :response, optional: true

  has_many :processing_purposes, dependent: :destroy
  has_many :data_category_details, dependent: :destroy
  has_many :access_categories, dependent: :destroy
  has_many :recipient_categories, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :processing_purposes, allow_destroy: true
  accepts_nested_attributes_for :data_category_details, allow_destroy: true
  accepts_nested_attributes_for :access_categories, allow_destroy: true
  accepts_nested_attributes_for :recipient_categories, allow_destroy: true
end
