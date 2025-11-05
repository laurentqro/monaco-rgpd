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

    # Store overall_score as a percentage (0-100)
    assessment.overall_score = max_score > 0 ? (total_score / max_score * 100) : 0
    assessment.max_possible_score = 100 # Max percentage
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
      choice = answer.answer_choice
      choice && choice.score.present? ? (choice.score * question.weight) : 0
    when "multiple_choice"
      # Multiple choice not yet fully supported with separate fields
      # For now, return 0 or handle in future enhancement
      0
    when "rating_scale"
      rating = answer.answer_rating.to_f
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
