class WaitlistEntriesController < ApplicationController
  allow_unauthenticated_access only: [ :create ]

  def create
    response_id = params[:waitlist_entry][:response_id]

    if response_id.present?
      # Completion flow: User finished questionnaire
      @response = Response.find(response_id)

      # Authorization: Verify ownership if user is authenticated
      if Current.user && @response.respondent_id != Current.user.id && @response.account_id != Current.account&.id
        render json: { errors: { response: [ "non autorisé" ] } }, status: :forbidden
        return
      end

      features = @response.waitlist_features_needed
      if features.empty?
        render json: { errors: { features_needed: [ "aucune fonctionnalité en attente requise" ] } }, status: :unprocessable_entity
        return
      end

      @entry = WaitlistEntry.new(
        email: params[:waitlist_entry][:email],
        response: @response,
        features_needed: features
      )
    else
      # Immediate exit flow (Monaco): No response yet, manual feature specification
      features = Array(params[:waitlist_entry][:features_needed]).presence || [ "geographic_expansion" ]

      @entry = WaitlistEntry.new(
        email: params[:waitlist_entry][:email],
        response: nil,
        features_needed: features
      )
    end

    if @entry.save
      # Always redirect to root with thank you message (prevents exposing other users' data)
      redirect_to root_path, notice: "Merci ! Nous vous contacterons dès que cette fonctionnalité sera disponible."
    else
      render json: { errors: @entry.errors }, status: :unprocessable_entity
    end
  end
end
