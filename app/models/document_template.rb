class DocumentTemplate < ApplicationRecord
  has_many :document_template_versions, dependent: :destroy

  enum :document_type, {
    privacy_policy: 0,
    processing_register: 1,
    consent_form: 2,
    employee_notice: 3
  }, prefix: true

  validates :title, presence: true
  validates :content, presence: true
  validates :document_type, presence: true
  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(is_active: true) }

  # Create version snapshot before updating
  before_update :create_version_snapshot, if: :content_changed?

  def render(context)
    template = Liquid::Template.parse(content)
    template.render(context)
  end

  private

  def create_version_snapshot
    document_template_versions.create!(
      content: content_was,
      version: version_was,
      changed_by_id: created_by_id
    )
    self.version += 1
  end
end
