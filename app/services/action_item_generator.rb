class ActionItemGenerator
  def initialize(compliance_assessment)
    @assessment = compliance_assessment
    @account = compliance_assessment.account
  end

  def generate
    return if already_generated?

    @assessment.compliance_area_scores.includes(:compliance_area).each do |area_score|
      next if area_score.percentage >= 80

      create_action_item_for_area(area_score)
    end
  end

  private

  def already_generated?
    ActionItem.exists?(
      actionable: @assessment,
      account: @account,
      source: :assessment
    )
  end

  def create_action_item_for_area(area_score)
    ActionItem.create!(
      account: @account,
      actionable: @assessment,
      source: :assessment,
      priority: determine_priority(area_score.percentage),
      status: :pending,
      action_type: determine_action_type(area_score.compliance_area),
      title: generate_title(area_score.compliance_area, area_score.percentage),
      description: generate_description(area_score.compliance_area, area_score.percentage),
      impact_score: calculate_impact_score(area_score.percentage),
      action_params: { compliance_area_id: area_score.compliance_area.id }
    )
  end

  def determine_priority(percentage)
    case percentage
    when 0...60 then :high
    when 60...80 then :medium
    else :low
    end
  end

  def determine_action_type(compliance_area)
    # For now, default to update_treatment
    # This can be enhanced in future phases
    :update_treatment
  end

  def generate_title(compliance_area, percentage)
    if percentage < 60
      "Améliorer la conformité : #{compliance_area.name}"
    else
      "Optimiser : #{compliance_area.name}"
    end
  end

  def generate_description(compliance_area, percentage)
    score_gap = 100 - percentage
    "Votre score dans le domaine '#{compliance_area.name}' est de #{percentage.round}%. " \
    "Une amélioration de #{score_gap.round}% est nécessaire pour atteindre la conformité optimale."
  end

  def calculate_impact_score(percentage)
    # Impact score is roughly how much improvement is needed
    (100 - percentage).round
  end
end
