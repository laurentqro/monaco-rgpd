# frozen_string_literal: true

# ProcessingActivityTemplates
# APDP-approved templates for common processing activities
module ProcessingActivityTemplates

  # Legal basis enums for ProcessingPurpose
  LEGAL_BASIS = {
    explicit_consent: 0,
    legal_obligation: 1,
    legitimate_interest: 2,
    consent: 3,
    public_interest: 4
  }.freeze

  # Data category enums for DataCategoryDetail (from model)
  CATEGORY_TYPES = {
    identity_family: 0,
    contact_info: 1,
    education_professional: 2,
    financial: 3,
    official_documents: 4,
    lifestyle_consumption: 5,
    electronic_id: 6,
    criminal_records: 7,
    temporal_info: 8,
    location_data: 9,
    biometric_genetic: 10
  }.freeze

  def self.employee_admin
    {
      name: "Gestion administrative des salariés",
      description: "Traitement des données personnelles des salariés conformément au cadre de référence de l'APDP",
      surveillance_purpose: false,
      sensitive_data: false,
      profiling: false,
      impact_assessment_required: false,
      inadequate_protection_transfer: false,
      data_subjects: ["Salariés"],
      individual_rights: [
        "Droit d'accès",
        "Droit de rectification",
        "Droit à l'effacement",
        "Droit d'opposition",
        "Droit à la limitation"
      ],
      security_measures: [
        "Serveur situé dans une baie informatique sécurisée",
        "Traçabilité des accès",
        "Identifiant et mot de passe propres à chaque personne habilitée"
      ],
      information_modalities: "Charte informatique, Règlement intérieur",

      processing_purposes_attributes: [
        {
          purpose_number: 1,
          order_index: 1,
          purpose_name: "Gestion de la procédure d'embauche",
          purpose_detail: "Gestion de la procédure d'embauche, des renouvellements et des fins de contrat",
          legal_basis: LEGAL_BASIS[:contract_execution]
        },
        {
          purpose_number: 2,
          order_index: 2,
          purpose_name: "Suivi administratif des visites médicales",
          purpose_detail: "Suivi administratif des visites médicales obligatoires des salariés",
          legal_basis: LEGAL_BASIS[:legal_obligation]
        },
        {
          purpose_number: 3,
          order_index: 3,
          purpose_name: "Gestion des déclarations d'accident",
          purpose_detail: "Gestion des déclarations d'accident du travail et de maladie professionnelle",
          legal_basis: LEGAL_BASIS[:legal_obligation]
        },
        {
          purpose_number: 4,
          order_index: 4,
          purpose_name: "Établissement de la fiche administrative",
          purpose_detail: "Établissement et mise à jour de la fiche administrative du salarié et de sa fiche de poste",
          legal_basis: LEGAL_BASIS[:contract_execution]
        },
        {
          purpose_number: 5,
          order_index: 5,
          purpose_name: "Gestion des compétences",
          purpose_detail: "Gestion des compétences et des évaluations professionnelles du salarié",
          legal_basis: LEGAL_BASIS[:contract_execution]
        },
        {
          purpose_number: 6,
          order_index: 6,
          purpose_name: "Suivi des formations",
          purpose_detail: "Suivi des formations",
          legal_basis: LEGAL_BASIS[:contract_execution]
        },
        {
          purpose_number: 7,
          order_index: 7,
          purpose_name: "Gestion des congés et absences",
          purpose_detail: "Gestion et suivi des congés et des absences du personnel",
          legal_basis: LEGAL_BASIS[:legal_obligation]
        },
        {
          purpose_number: 8,
          order_index: 8,
          purpose_name: "Établissement de listes de salariés",
          purpose_detail: "Établissement de listes de salariés permettant de répondre à des besoins de gestion administrative ou à des obligations légales ou règlementaires",
          legal_basis: LEGAL_BASIS[:legal_obligation]
        },
        {
          purpose_number: 9,
          order_index: 9,
          purpose_name: "États statistiques",
          purpose_detail: "Établissement d'états statistiques non nominatifs",
          legal_basis: LEGAL_BASIS[:legitimate_interest]
        },
        {
          purpose_number: 10,
          order_index: 10,
          purpose_name: "Gestion des dotations individuelles",
          purpose_detail: "Gestion des dotations individuelles en fournitures, équipements, véhicules et cartes de paiement",
          legal_basis: LEGAL_BASIS[:contract_execution]
        },
        {
          purpose_number: 11,
          order_index: 11,
          purpose_name: "Gestion des annuaires internes",
          purpose_detail: "Gestion des annuaires internes et des organigrammes",
          legal_basis: LEGAL_BASIS[:legitimate_interest]
        },
        {
          purpose_number: 12,
          order_index: 12,
          purpose_name: "Gestion des trombinoscopes",
          purpose_detail: "Gestion des trombinoscopes, sous réserve du consentement exprès de la personne concernée quant à l'utilisation de sa photographie",
          legal_basis: LEGAL_BASIS[:legitimate_interest]
        },
        {
          purpose_number: 13,
          order_index: 13,
          purpose_name: "Gestion de l'intranet",
          purpose_detail: "Gestion de l'intranet",
          legal_basis: LEGAL_BASIS[:legitimate_interest]
        },
        {
          purpose_number: 14,
          order_index: 14,
          purpose_name: "Gestion des habilitations informatiques",
          purpose_detail: "Gestion des habilitations informatiques",
          legal_basis: LEGAL_BASIS[:legitimate_interest]
        }
      ],

      data_category_details_attributes: [
        {
          category_type: CATEGORY_TYPES[:identity_family],
          detail: "Nom, prénom, photographie, sexe, date et lieu de naissance, nationalité, situation de famille, numéro de matricule interne, numéro d'immatriculation délivré par un organisme de sécurité sociale, identité du conjoint et des enfants à charge",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: CATEGORY_TYPES[:contact_info],
          detail: "Coordonnées professionnelles et personnelles, coordonnées des personnes à contacter en cas d'urgence",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: CATEGORY_TYPES[:education_professional],
          detail: "Nature de l'emploi, poste occupé, fonction ou titre, distinctions honorifiques",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: CATEGORY_TYPES[:official_documents],
          detail: "Pas de copie mais informations relatives à l'identification et numéro de la pièce d'identité, date et lieu de délivrance, date de validité",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: CATEGORY_TYPES[:electronic_id],
          detail: "Identifiant de la personne concernée/compte utilisateur",
          retention_period: "3 mois après le départ du salarié",
          data_source: "Service informatique"
        },
        {
          category_type: CATEGORY_TYPES[:education_professional],
          detail: "Informations relatives au contrat de travail, à la carrière, aux déclarations d'accident et de maladie professionnelles, aux évaluations, à la validation des acquis, aux formations, aux visites médicales, au permis de conduire, aux congés",
          retention_period: "Tant que la personne est en poste",
          data_source: "Service RH"
        },
        {
          category_type: CATEGORY_TYPES[:electronic_id],
          detail: "Données de connexion",
          retention_period: "De 3 mois à 1 an",
          data_source: "Système d'Information"
        }
      ],

      access_categories_attributes: [
        {
          category_number: 1,
          order_index: 1,
          category_name: "Service RH",
          detail: "Service RH",
          location: "Monaco"
        },
        {
          category_number: 2,
          order_index: 2,
          category_name: "Supérieurs hiérarchiques",
          detail: "Supérieurs hiérarchiques",
          location: "Monaco"
        },
        {
          category_number: 3,
          order_index: 3,
          category_name: "Service informatique",
          detail: "Service informatique",
          location: "Monaco"
        },
        {
          category_number: 4,
          order_index: 4,
          category_name: "Prestataire de maintenance",
          detail: "Prestataire de maintenance",
          location: "Monaco"
        }
      ],

      recipient_categories_attributes: [
        {
          recipient_number: 1,
          order_index: 1,
          recipient_name: "La direction du travail",
          detail: "La direction du travail",
          location: "Monaco"
        },
        {
          recipient_number: 2,
          order_index: 2,
          recipient_name: "L'office de la Médecine du Travail",
          detail: "L'office de la Médecine du Travail",
          location: "Monaco"
        },
        {
          recipient_number: 3,
          order_index: 3,
          recipient_name: "Les organismes sociaux",
          detail: "Les organismes sociaux",
          location: "Monaco/France/Italie"
        },
        {
          recipient_number: 4,
          order_index: 4,
          recipient_name: "Les organismes d'assurance",
          detail: "Les organismes d'assurance",
          location: "Monaco/France/Italie"
        },
        {
          recipient_number: 5,
          order_index: 5,
          recipient_name: "Les organismes de formation professionnelle",
          detail: "Les organismes de formation professionnelle",
          location: "Monaco/France"
        },
        {
          recipient_number: 6,
          order_index: 6,
          recipient_name: "Les agences de voyage",
          detail: "Les agences de voyage",
          location: "Monaco/France"
        }
      ]
    }
  end

  # Map of question text to template methods
  QUESTION_TEMPLATE_MAP = {
    "Avez-vous du personnel ?" => :employee_admin
    # Add more mappings as we create more templates
  }.freeze

  def self.all_templates
    {
      employee_admin: employee_admin
    }
  end
end
