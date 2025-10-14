class ComplianceScorer
  def initialize(response)
    @response = response
    @account = response.account
  end

  def calculate
    assessment = @response.build_compliance_assessment(
      account: @account,
      status: :draft
    )

    # Calculate overall score
    total_score = 0
    max_score = 0

    @response.answers.includes(question: :answer_choices).each do |answer|
      question = answer.question
      next unless question.weight.present?

      question_score = calculate_question_score(answer, question)
      max_question_score = question.weight * 100

      total_score += question_score
      max_score += max_question_score
    end

    assessment.overall_score = total_score
    assessment.max_possible_score = max_score
    assessment.status = :completed
    assessment.save!

    # Calculate area scores
    calculate_area_scores(assessment)

    assessment
  end

  private

  def calculate_question_score(answer, question)
    case question.question_type
    when "yes_no", "single_choice"
      choice = question.answer_choices.find_by(id: answer.answer_value["choice_id"])
      choice ? (choice.score * question.weight) : 0
    when "multiple_choice"
      choice_ids = answer.answer_value["choice_ids"] || []
      choices = question.answer_choices.where(id: choice_ids)
      avg_score = choices.any? ? (choices.sum(&:score) / choices.count) : 0
      avg_score * question.weight
    when "rating_scale"
      rating = answer.answer_value["rating"].to_f
      max_rating = question.settings["max_rating"] || 5
      (rating / max_rating * 100) * question.weight
    else
      0
    end
  end

  def calculate_area_scores(assessment)
    # For MVP, we'll create a simplified version
    # Group questions by section and calculate scores per section
    # This maps to compliance areas

    compliance_areas = ComplianceArea.all

    compliance_areas.each do |area|
      # Find questions related to this area (by section or tags)
      # Calculate score for this area
      # For now, simplified: equal distribution

      area_score = assessment.overall_score / compliance_areas.count
      area_max_score = assessment.max_possible_score / compliance_areas.count

      assessment.compliance_area_scores.create!(
        compliance_area: area,
        score: area_score,
        max_score: area_max_score
      )
    end
  end
end
