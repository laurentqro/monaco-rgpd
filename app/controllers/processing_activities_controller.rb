class ProcessingActivitiesController < ApplicationController
  include ProcessingActivitiesHelper

  before_action :set_processing_activity, only: [:show]

  def index
    @processing_activities = Current.account
      .processing_activities
      .where.not(response_id: nil) # Only show template-generated activities
      .order(created_at: :desc)

    render inertia: "ProcessingActivities/Index", props: {
      activities: @processing_activities.map do |activity|
        {
          id: activity.id,
          name: activity.name,
          description: activity.description,
          created_at: activity.created_at,
          purposes_count: activity.processing_purposes.count
        }
      end
    }
  end

  def show
    respond_to do |format|
      format.html do
        render inertia: "ProcessingActivities/Show", props: {
          activity: serialize_activity(@processing_activity)
        }
      end

      format.pdf do
        render_pdf
      end
    end
  end

  private

  def set_processing_activity
    @processing_activity = Current.account
      .processing_activities
      .includes(:processing_purposes, :data_category_details,
                :access_categories, :recipient_categories)
      .find(params[:id])
  end

  def serialize_activity(activity)
    {
      id: activity.id,
      name: activity.name,
      description: activity.description,
      surveillance_purpose: activity.surveillance_purpose,
      sensitive_data: activity.sensitive_data,
      profiling: activity.profiling,
      impact_assessment_required: activity.impact_assessment_required,
      inadequate_protection_transfer: activity.inadequate_protection_transfer,
      data_subjects: activity.data_subjects,
      individual_rights: activity.individual_rights,
      security_measures: activity.security_measures,
      information_modalities: activity.information_modalities,
      processing_purposes: activity.processing_purposes.order(:order_index).map do |purpose|
        {
          purpose_number: purpose.purpose_number,
          purpose_name: purpose.purpose_name,
          purpose_detail: purpose.purpose_detail,
          legal_basis: purpose.legal_basis,
          legal_basis_text: legal_basis_text(purpose.legal_basis)
        }
      end,
      data_category_details: activity.data_category_details.map do |category|
        {
          category_type: category.category_type,
          category_type_text: category_type_text(category.category_type),
          detail: category.detail,
          retention_period: category.retention_period,
          data_source: category.data_source
        }
      end,
      access_categories: activity.access_categories.order(:order_index).map do |category|
        {
          category_number: category.category_number,
          category_name: category.category_name,
          detail: category.detail,
          location: category.location
        }
      end,
      recipient_categories: activity.recipient_categories.order(:order_index).map do |recipient|
        {
          recipient_number: recipient.recipient_number,
          recipient_name: recipient.recipient_name,
          detail: recipient.detail,
          location: recipient.location
        }
      end
    }
  end

  def render_pdf
    html = ApplicationController.renderer.render(
      template: "processing_activities/show",
      layout: "pdf",
      assigns: { processing_activity: @processing_activity },
      helpers: [ProcessingActivitiesHelper]
    )

    pdf = Grover.new(html,
      format: "A4",
      margin: {
        top: "1cm",
        right: "1cm",
        bottom: "1cm",
        left: "1cm"
      },
      display_url: request.base_url
    ).to_pdf

    send_data pdf,
              filename: "#{@processing_activity.name}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
