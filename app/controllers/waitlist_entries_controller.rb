class WaitlistEntriesController < ApplicationController
  allow_unauthenticated_access only: [ :create ]

  def create
    @response = Response.find(params[:waitlist_entry][:response_id])

    @entry = WaitlistEntry.new(
      email: params[:waitlist_entry][:email],
      response: @response,
      features_needed: @response.waitlist_features_needed
    )

    if @entry.save
      redirect_to questionnaire_response_path(@response.questionnaire, @response), notice: "Merci ! Nous vous contacterons dès que cette fonctionnalité sera disponible."
    else
      render json: { errors: @entry.errors }, status: :unprocessable_entity
    end
  end
end
