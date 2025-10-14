class AnswersController < ApplicationController
  before_action :set_response

  def create
    answer = @response.answers.build(answer_params)

    if answer.save
      head :no_content
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  def update
    answer = @response.answers.find(params[:id])

    if answer.update(answer_params)
      head :no_content
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_response
    @response = Current.account.responses.find(params[:response_id])
  end

  def answer_params
    params.require(:answer).permit(:question_id, answer_value: {})
  end
end
