class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :complete]

  def index
    responses = Current.account.responses
      .includes(:questionnaire, :compliance_assessment)
      .order(created_at: :desc)

    render inertia: "Responses/Index", props: {
      responses: responses.map { |r| response_props(r) }
    }
  end

  def create
    questionnaire = Questionnaire.published.find(params[:questionnaire_id])

    response = Current.account.responses.build(
      questionnaire: questionnaire,
      respondent: Current.user,
      status: :in_progress
    )

    if response.save
      redirect_to questionnaire_response_path(questionnaire, response)
    else
      redirect_back fallback_location: root_path, alert: response.errors.full_messages.join(", ")
    end
  end

  def show
    render inertia: "Responses/Show", props: {
      response: response_props(@response),
      questionnaire: questionnaire_props(@response.questionnaire)
    }
  end

  def update
    if @response.update(response_params)
      head :no_content
    else
      render json: { errors: @response.errors }, status: :unprocessable_entity
    end
  end

  def complete
    @response.update!(
      status: :completed,
      completed_at: Time.current
    )

    # Trigger compliance assessment calculation
    CalculateComplianceScoreJob.perform_later(@response.id)

    redirect_to dashboard_path, notice: "Évaluation complétée avec succès"
  end

  private

  def set_response
    @response = Current.account.responses.find(params[:id])
  end

  def response_params
    params.require(:response).permit(:status)
  end

  def response_props(response)
    {
      id: response.id,
      status: response.status,
      started_at: response.started_at,
      completed_at: response.completed_at,
      questionnaire: {
        id: response.questionnaire.id,
        title: response.questionnaire.title
      },
      compliance_assessment: response.compliance_assessment ? {
        overall_score: response.compliance_assessment.overall_score,
        risk_level: response.compliance_assessment.risk_level
      } : nil,
      answers: response.answers.includes(:question).map { |a| answer_props(a) }
    }
  end

  def answer_props(answer)
    {
      id: answer.id,
      question_id: answer.question_id,
      answer_value: answer.answer_value
    }
  end

  def questionnaire_props(questionnaire)
    # Reuse from QuestionnairesController
    QuestionnairesController.new.send(:questionnaire_props, questionnaire)
  end
end
