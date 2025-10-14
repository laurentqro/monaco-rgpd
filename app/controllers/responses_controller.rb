class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :complete, :results]

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

    redirect_to dashboard_path, notice: "Évaluation terminée ! Votre score de conformité est en cours de calcul."
  end

  def results
    # Get all answers with their questions and answer choices for display
    answers_with_details = @response.answers.includes(question: [:answer_choices, :section]).map do |answer|
      {
        question_text: answer.question.question_text,
        question_type: answer.question.question_type,
        section_title: answer.question.section.title,
        answer_value: answer.answer_value,
        answer_choices: answer.question.answer_choices.map { |ac| { id: ac.id, choice_text: ac.choice_text } }
      }
    end

    render inertia: "Responses/Results", props: {
      response: response_props(@response),
      assessment: @response.compliance_assessment ? assessment_props(@response.compliance_assessment) : nil,
      documents: @response.documents.ready.map { |d| document_props(d) },
      answers: answers_with_details
    }
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
        overall_score: response.compliance_assessment.overall_score.to_f.round(1),
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

  def assessment_props(assessment)
    {
      overall_score: assessment.overall_score.round(1),
      max_possible_score: assessment.max_possible_score,
      risk_level: assessment.risk_level,
      created_at: assessment.created_at,
      compliance_area_scores: assessment.compliance_area_scores.includes(:compliance_area).map do |cas|
        {
          area_name: cas.compliance_area.name,
          area_code: cas.compliance_area.code,
          score: cas.score.round(1),
          max_score: cas.max_score,
          percentage: cas.percentage
        }
      end
    }
  end

  def document_props(document)
    {
      id: document.id,
      title: document.title,
      document_type: document.document_type,
      status: document.status,
      generated_at: document.generated_at,
      download_url: document.pdf_file.attached? ? rails_blob_path(document.pdf_file, disposition: "attachment") : nil
    }
  end
end
