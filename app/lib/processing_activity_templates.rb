# frozen_string_literal: true

# ProcessingActivityTemplates
# APDP-approved templates for common processing activities
module ProcessingActivityTemplates
  def self.employee_admin
    {
      name: "Gestion administrative des salariés",
      description: "Traitement des données personnelles des salariés conformément au cadre de référence de l'APDP",
      surveillance_purpose: false,
      sensitive_data: false,
      profiling: false,
      impact_assessment_required: false,
      inadequate_protection_transfer: false,
      data_subjects: [ "Salariés" ],
      individual_rights: [
        "Droit d'accès",
        "Droit de rectification",
        "Droit à l'effacement",
        "Droit d'opposition",
        "Droit à la limitation"
      ],
      security_measures: [
        {
          measure: "Serveur situé dans une baie informatique sécurisée",
          reference_documents: "Politique de sécurité + schéma d'architecture sécurisée"
        },
        {
          measure: "Traçabilité des accès",
          reference_documents: "Politique de sécurité"
        },
        {
          measure: "Identifiant et mot de passe propres à chaque personne habilitée à avoir accès au traitement",
          reference_documents: "Politique de sécurité + liste des personnes habilitées à avoir accès"
        }
      ],
      information_modalities: "Charte informatique, Règlement intérieur",

      processing_purposes_attributes: [
        {
          purpose_number: 1,
          order_index: 1,
          purpose_name: "Gestion de la procédure d'embauche",
          purpose_detail: "Gestion de la procédure d'embauche, des renouvellements et des fins de contrat",
          legal_basis: ProcessingPurpose.legal_bases[:contract]
        },
        {
          purpose_number: 2,
          order_index: 2,
          purpose_name: "Suivi administratif des visites médicales",
          purpose_detail: "Suivi administratif des visites médicales obligatoires des salariés",
          legal_basis: ProcessingPurpose.legal_bases[:legal_obligation]
        },
        {
          purpose_number: 3,
          order_index: 3,
          purpose_name: "Gestion des déclarations d'accident",
          purpose_detail: "Gestion des déclarations d'accident du travail et de maladie professionnelle",
          legal_basis: ProcessingPurpose.legal_bases[:legal_obligation]
        },
        {
          purpose_number: 4,
          order_index: 4,
          purpose_name: "Établissement de la fiche administrative",
          purpose_detail: "Établissement et mise à jour de la fiche administrative du salarié et de sa fiche de poste",
          legal_basis: ProcessingPurpose.legal_bases[:contract]
        },
        {
          purpose_number: 5,
          order_index: 5,
          purpose_name: "Gestion des compétences",
          purpose_detail: "Gestion des compétences et des évaluations professionnelles du salarié",
          legal_basis: ProcessingPurpose.legal_bases[:contract]
        },
        {
          purpose_number: 6,
          order_index: 6,
          purpose_name: "Suivi des formations",
          purpose_detail: "Suivi des formations",
          legal_basis: ProcessingPurpose.legal_bases[:contract]
        },
        {
          purpose_number: 7,
          order_index: 7,
          purpose_name: "Gestion des congés et absences",
          purpose_detail: "Gestion et suivi des congés et des absences du personnel",
          legal_basis: ProcessingPurpose.legal_bases[:legal_obligation]
        },
        {
          purpose_number: 8,
          order_index: 8,
          purpose_name: "Établissement de listes de salariés",
          purpose_detail: "Établissement de listes de salariés permettant de répondre à des besoins de gestion administrative ou à des obligations légales ou règlementaires",
          legal_basis: ProcessingPurpose.legal_bases[:legal_obligation]
        },
        {
          purpose_number: 9,
          order_index: 9,
          purpose_name: "États statistiques",
          purpose_detail: "Établissement d'états statistiques non nominatifs",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 10,
          order_index: 10,
          purpose_name: "Gestion des dotations individuelles",
          purpose_detail: "Gestion des dotations individuelles en fournitures, équipements, véhicules et cartes de paiement",
          legal_basis: ProcessingPurpose.legal_bases[:contract]
        },
        {
          purpose_number: 11,
          order_index: 11,
          purpose_name: "Gestion des annuaires internes",
          purpose_detail: "Gestion des annuaires internes et des organigrammes",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 12,
          order_index: 12,
          purpose_name: "Gestion des trombinoscopes",
          purpose_detail: "Gestion des trombinoscopes, sous réserve du consentement exprès de la personne concernée quant à l'utilisation de sa photographie",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 13,
          order_index: 13,
          purpose_name: "Gestion de l'intranet",
          purpose_detail: "Gestion de l'intranet",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 14,
          order_index: 14,
          purpose_name: "Gestion des habilitations informatiques",
          purpose_detail: "Gestion des habilitations informatiques",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        }
      ],

      data_category_details_attributes: [
        {
          category_type: DataCategoryDetail.category_types[:identity_family],
          detail: "Nom, prénom, photographie, sexe, date et lieu de naissance, nationalité, situation de famille, numéro de matricule interne, numéro d'immatriculation délivré par un organisme de sécurité sociale, identité du conjoint et des enfants à charge",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:contact_info],
          detail: "Coordonnées professionnelles et personnelles, coordonnées des personnes à contacter en cas d'urgence",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:education_professional],
          detail: "Nature de l'emploi, poste occupé, fonction ou titre, distinctions honorifiques",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:official_documents],
          detail: "Pas de copie mais informations relatives à l'identification et numéro de la pièce d'identité, date et lieu de délivrance, date de validité",
          retention_period: "Tant que la personne est en poste",
          data_source: "Personnes concernées + Service RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Identifiant de la personne concernée/compte utilisateur",
          retention_period: "3 mois après le départ du salarié",
          data_source: "Service informatique"
        },
        {
          category_type: DataCategoryDetail.category_types[:education_professional],
          detail: "Informations relatives au contrat de travail, à la carrière, aux déclarations d'accident et de maladie professionnelles, aux évaluations, à la validation des acquis, aux formations, aux visites médicales, au permis de conduire, aux congés",
          retention_period: "Tant que la personne est en poste",
          data_source: "Service RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
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

  def self.professional_email
    {
      name: "Gestion de la messagerie professionnelle",
      description: "Traitement des données de messagerie électronique professionnelle conformément au cadre de référence de l'APDP",
      surveillance_purpose: false,
      sensitive_data: false,
      profiling: false,
      impact_assessment_required: false,
      inadequate_protection_transfer: false,
      data_subjects: [ "Salariés", "Destinataires et expéditeurs" ],
      individual_rights: [
        "Droit d'accès",
        "Droit de rectification",
        "Droit à l'effacement",
        "Droit à la limitation",
        "Droit d'opposition"
      ],
      security_measures: [
        {
          measure: "Serveur situé dans une baie informatique sécurisée",
          reference_documents: "Politique de sécurité + schéma d'architecture sécurisée"
        },
        {
          measure: "Traçabilité des accès",
          reference_documents: "Politique de sécurité"
        },
        {
          measure: "Identifiant et mot de passe propres à chaque personne habilitée à avoir accès au traitement",
          reference_documents: "Politique de sécurité + liste des personnes habilitées à avoir accès"
        }
      ],
      information_modalities: "Charte informatique, Règlement intérieur, Message en bas de tous les e-mails sortants",

      processing_purposes_attributes: [
        {
          purpose_number: 1,
          order_index: 1,
          purpose_name: "Échange de messages électroniques",
          purpose_detail: "L'échange de messages électroniques en interne ou avec l'extérieur",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 2,
          order_index: 2,
          purpose_name: "Historisation des messages",
          purpose_detail: "L'historisation des messages électroniques entrants et sortants",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 3,
          order_index: 3,
          purpose_name: "Gestion des contacts",
          purpose_detail: "La gestion des contacts de la messagerie électronique",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 4,
          order_index: 4,
          purpose_name: "Gestion des dossiers",
          purpose_detail: "La gestion des dossiers de la messagerie et des messages archivés",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 5,
          order_index: 5,
          purpose_name: "Fichiers journaux",
          purpose_detail: "L'établissement et la lecture de fichiers journaux",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 6,
          order_index: 6,
          purpose_name: "Gestion des habilitations",
          purpose_detail: "La gestion des habilitations d'accès à la messagerie",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 7,
          order_index: 7,
          purpose_name: "Gestion de l'agenda",
          purpose_detail: "La gestion de l'agenda",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 8,
          order_index: 8,
          purpose_name: "Établissement de preuves",
          purpose_detail: "L'établissement de preuves en cas de litige avec un client/employé (en cas de contestation d'un ordre par exemple)",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        }
      ],

      data_category_details_attributes: [
        {
          category_type: DataCategoryDetail.category_types[:identity_family],
          detail: "Nom, prénom, identifiant",
          retention_period: "3 mois maximum après le départ de l'utilisateur",
          data_source: "Fichier RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Adresse de messagerie électronique",
          retention_period: "3 mois maximum après le départ de l'utilisateur",
          data_source: "Service informatique"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Messages",
          retention_period: "Politique d'archivage",
          data_source: "Personnes concernées"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Journalisation des accès / fichiers journaux",
          retention_period: "De 3 mois à 1 an",
          data_source: "Système de messagerie"
        },
        {
          category_type: DataCategoryDetail.category_types[:contact_info],
          detail: "Gestion des contacts",
          retention_period: "Tant que la personne est un contact",
          data_source: "Personnes concernées"
        }
      ],

      access_categories_attributes: [
        {
          category_number: 1,
          order_index: 1,
          category_name: "Salariés",
          detail: "Salariés",
          location: "Monaco"
        },
        {
          category_number: 2,
          order_index: 2,
          category_name: "Responsable informatique",
          detail: "Responsable informatique",
          location: "Monaco"
        },
        {
          category_number: 3,
          order_index: 3,
          category_name: "Prestataire de maintenance",
          detail: "Prestataire de maintenance",
          location: "Monaco"
        }
      ],

      recipient_categories_attributes: [
        {
          recipient_number: 1,
          order_index: 1,
          recipient_name: "N/A",
          detail: "N/A",
          location: "N/A"
        }
      ]
    }
  end

  def self.telephony
    {
      name: "Gestion de la téléphonie fixe et mobile",
      description: "Traitement des données de téléphonie fixe et mobile conformément au cadre de référence de l'APDP",
      surveillance_purpose: false,
      sensitive_data: false,
      profiling: false,
      impact_assessment_required: false,
      inadequate_protection_transfer: false,
      data_subjects: [ "Salariés" ],
      individual_rights: [
        "Droit d'accès",
        "Droit de rectification",
        "Droit à l'effacement",
        "Droit d'opposition",
        "Droit à la limitation"
      ],
      security_measures: [
        {
          measure: "Serveur situé dans une baie informatique sécurisée",
          reference_documents: "Politique de sécurité + schéma d'architecture sécurisée"
        },
        {
          measure: "Traçabilité des accès",
          reference_documents: "Politique de sécurité"
        },
        {
          measure: "Identifiant et mot de passe propres à chaque personne habilitée à avoir accès au traitement",
          reference_documents: "Politique de sécurité + liste des personnes habilitées à avoir accès"
        }
      ],
      information_modalities: "Charte informatique, Règlement intérieur",

      processing_purposes_attributes: [
        {
          purpose_number: 1,
          order_index: 1,
          purpose_name: "Gestion du matériel téléphonique",
          purpose_detail: "Gestion du matériel téléphonique",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 2,
          order_index: 2,
          purpose_name: "Maintenance du parc téléphonique",
          purpose_detail: "Maintenance du parc téléphonique",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 3,
          order_index: 3,
          purpose_name: "Gestion de l'annuaire téléphonique",
          purpose_detail: "Gestion de l'annuaire téléphonique interne",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 4,
          order_index: 4,
          purpose_name: "Gestion des messageries téléphoniques",
          purpose_detail: "Gestion des messageries téléphoniques internes",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 5,
          order_index: 5,
          purpose_name: "Gestion des dépenses téléphoniques",
          purpose_detail: "Gestion des dépenses liées à l'utilisation professionnelle des services de téléphonie (établissement et édition des relevés téléphoniques, calcul des coûts) à titre privé",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 6,
          order_index: 6,
          purpose_name: "Remboursement des services privés",
          purpose_detail: "Remboursement des services de téléphonie utilisés à titre privé par les employés",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 7,
          order_index: 7,
          purpose_name: "Statistiques anonymes",
          purpose_detail: "Etablissement de statistiques anonymes",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        }
      ],

      data_category_details_attributes: [
        {
          category_type: DataCategoryDetail.category_types[:identity_family],
          detail: "Nom, prénom, numéro de matricule interne",
          retention_period: "Tant que la personne est en poste",
          data_source: "Fichier RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:contact_info],
          detail: "Numéro de ligne ou de poste, adresse email professionnelle",
          retention_period: "Tant que la personne est en poste",
          data_source: "Fichier RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:education_professional],
          detail: "Fonction, service",
          retention_period: "Tant que la personne est en poste",
          data_source: "Fichier RH"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Informations relatives à l'utilisation des services de téléphonie",
          retention_period: "1 an",
          data_source: "Dispositif téléphonique"
        }
      ],

      access_categories_attributes: [
        {
          category_number: 1,
          order_index: 1,
          category_name: "Service comptable",
          detail: "Service comptable",
          location: "Monaco"
        },
        {
          category_number: 2,
          order_index: 2,
          category_name: "Service informatique",
          detail: "Service informatique",
          location: "Monaco"
        },
        {
          category_number: 3,
          order_index: 3,
          category_name: "Prestataire de maintenance",
          detail: "Prestataire de maintenance",
          location: "Monaco"
        }
      ],

      recipient_categories_attributes: [
        {
          recipient_number: 1,
          order_index: 1,
          recipient_name: "N/A",
          detail: "N/A",
          location: "N/A"
        }
      ]
    }
  end

  def self.website_showcase
    {
      name: "Gestion d'un site Internet vitrine de la société",
      description: "Traitement des données personnelles relatives à la gestion d'un site Internet vitrine conformément au cadre de référence de l'APDP",
      surveillance_purpose: false,
      sensitive_data: false,
      profiling: false,
      impact_assessment_required: false,
      inadequate_protection_transfer: true,
      data_subjects: [ "Salariés", "Internautes" ],
      individual_rights: [
        "Droit d'accès",
        "Droit de rectification",
        "Droit d'opposition",
        "Droit à l'effacement",
        "Droit à la limitation"
      ],
      security_measures: [
        {
          measure: "Serveur situé dans une baie informatique sécurisée",
          reference_documents: "Schéma des flux de données, Schéma de l'architecture technique sécurisée, Liste des personnes habilitées à avoir accès"
        },
        {
          measure: "Traçabilité des accès",
          reference_documents: "Schéma des flux de données, Schéma de l'architecture technique sécurisée, Liste des personnes habilitées à avoir accès"
        },
        {
          measure: "Identifiant et mot de passe propres à chaque personne habilitée à avoir accès au traitement",
          reference_documents: "Schéma des flux de données, Schéma de l'architecture technique sécurisée, Liste des personnes habilitées à avoir accès"
        }
      ],
      information_modalities: "Politique de confidentialité accessible sur le site, Mention sur la lettre d'information, Note interne",

      processing_purposes_attributes: [
        {
          purpose_number: 1,
          order_index: 1,
          purpose_name: "Présenter la société et les équipes",
          purpose_detail: "Présenter la société et les équipes",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 2,
          order_index: 2,
          purpose_name: "Présenter les produits",
          purpose_detail: "Présenter les produits",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 3,
          order_index: 3,
          purpose_name: "Formulaire de contact",
          purpose_detail: "Mettre à disposition des internautes un formulaire de contact",
          legal_basis: ProcessingPurpose.legal_bases[:legitimate_interest]
        },
        {
          purpose_number: 4,
          order_index: 4,
          purpose_name: "Newsletter",
          purpose_detail: "Proposer l'inscription à une lettre d'information (« newsletter »)",
          legal_basis: ProcessingPurpose.legal_bases[:consent]
        },
        {
          purpose_number: 5,
          order_index: 5,
          purpose_name: "Analyse d'audience",
          purpose_detail: "Analyser l'audience du site",
          legal_basis: ProcessingPurpose.legal_bases[:consent]
        }
      ],

      data_category_details_attributes: [
        {
          category_type: DataCategoryDetail.category_types[:identity_family],
          detail: "Nom, prénoms, photo (uniquement pour les salariés avec leur consentement)",
          retention_period: "Tant que la personne est en poste/temps de traitement de la demande/de l'inscription",
          data_source: "Service des Ressources Humaines + personnes concernées"
        },
        {
          category_type: DataCategoryDetail.category_types[:contact_info],
          detail: "Numéro de téléphone professionnel, adresse e-mail professionnelle ou personnelle",
          retention_period: "Tant que la personne est en poste/temps de traitement de la demande/de l'inscription",
          data_source: "Service des Ressources Humaines + personnes concernées"
        },
        {
          category_type: DataCategoryDetail.category_types[:education_professional],
          detail: "Raison sociale, titre, formation suivie, langue(s) parlée(s)",
          retention_period: "Tant que la personne est en poste/temps de traitement de la demande",
          data_source: "Service des Ressources Humaines + personnes concernées"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Identifiant et mot de passe",
          retention_period: "Tant que la personne est en poste",
          data_source: "Service informatique pour l'identifiant + personnes concernées pour le mot de passe"
        },
        {
          category_type: DataCategoryDetail.category_types[:temporal_info],
          detail: "Logs de connexion",
          retention_period: "De 3 mois à 1 an",
          data_source: "Site Internet"
        },
        {
          category_type: DataCategoryDetail.category_types[:electronic_id],
          detail: "Cookies",
          retention_period: "13 mois maximum",
          data_source: "Site Internet"
        }
      ],

      access_categories_attributes: [
        {
          category_number: 1,
          order_index: 1,
          category_name: "Direction",
          detail: "Direction",
          location: "Monaco"
        },
        {
          category_number: 2,
          order_index: 2,
          category_name: "Service informatique",
          detail: "Service informatique",
          location: "Monaco"
        },
        {
          category_number: 3,
          order_index: 3,
          category_name: "Prestataire de maintenance",
          detail: "Prestataire de maintenance",
          location: "Monaco"
        }
      ],

      recipient_categories_attributes: [
        {
          recipient_number: 1,
          order_index: 1,
          recipient_name: "Prestataire en charge de l'hébergement",
          detail: "Prestataire en charge de l'hébergement",
          location: "Monaco"
        }
      ]
    }
  end

  # Map of question text to template methods
  QUESTION_TEMPLATE_MAP = {
    "Avez-vous du personnel ?" => :employee_admin,
    "Vos employés disposent-ils d'une adresse email professionnelle ?" => :professional_email,
    "Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?" => :telephony,
    "Avez-vous un site internet ?" => :website_showcase
  }.freeze

  def self.all_templates
    {
      employee_admin: employee_admin,
      professional_email: professional_email,
      telephony: telephony,
      website_showcase: website_showcase
    }
  end
end
