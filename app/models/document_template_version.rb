class DocumentTemplateVersion < ApplicationRecord
  belongs_to :document_template

  validates :content, presence: true
  validates :version, presence: true
end
