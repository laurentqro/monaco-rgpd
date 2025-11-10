# frozen_string_literal: true

module ProcessingActivitiesHelper
  def legal_basis_text(legal_basis)
    case legal_basis
    when "contract_execution"
      "Exécution d'un contrat ou mesures pré-contractuelles"
    when "legal_obligation"
      "Respect d'une obligation légale à laquelle est soumis le responsable du traitement"
    when "legitimate_interest"
      "Réalisation d'un intérêt légitime poursuivi par le responsable du traitement"
    when "consent"
      "Consentement de la personne concernée"
    when "public_interest"
      "Mission d'intérêt public"
    else
      legal_basis.to_s.humanize
    end
  end

  def category_type_text(category_type)
    case category_type
    when "identity_family"
      "Identité/situation de famille"
    when "contact_info"
      "Adresses et coordonnées"
    when "education_professional"
      "Formation, diplômes, vie professionnelle"
    when "official_documents"
      "Copies de documents officiels"
    when "electronic_id"
      "Données d'identification électronique"
    when "financial"
      "Données financières"
    else
      "Autre(s)"
    end
  end
end
