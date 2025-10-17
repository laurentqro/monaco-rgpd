# Monaco RGPD Master Questionnaire - Rewritten structure
# Based on updated requirements for comprehensive RGPD assessment

questionnaire = Questionnaire.find_or_create_by!(title: "Évaluation RGPD Monaco") do |q|
  q.description = "Évaluation de conformité à la Loi n° 1.565"
  q.category = "compliance_assessment"
  q.status = :published
end

# ============================================================================
# Section 1: Qualification de l'utilisateur
# ============================================================================
section1 = questionnaire.sections.find_or_create_by!(order_index: 1) do |s|
  s.title = "Qualification de l'utilisateur"
  s.description = "Informations sur votre organisation et son éligibilité"
end

# Q1: Organisation établie à Monaco?
monaco_question = section1.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Votre organisation est-elle établie à Monaco ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Q2: Qui êtes-vous?
org_type_question = section1.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Qui êtes-vous ?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Entreprise")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Association")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Organisme public")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "Profession libérale")
  q.answer_choices.find_or_create_by!(order_index: 5, choice_text: "Personne physique")
end

# Q3: Taille de l'organisation
org_size_question = section1.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Quelle est la taille de votre organisation ?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "0")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "1-5")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "6-10")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "11-50")
  q.answer_choices.find_or_create_by!(order_index: 5, choice_text: "50+")
end

# Q4: Traitez-vous des données personnelles?
personal_data_question = section1.questions.find_or_create_by!(order_index: 4) do |q|
  q.question_text = "Traitez-vous des données personnelles ?"
  q.question_type = :yes_no
  q.help_text = "Par exemple:\n\n• Identité : nom, prénom, numéro de sécurité sociale, adresse IP, identifiant en ligne\n• Caractéristiques physiques/physiologiques : photo, empreintes digitales, ADN\n• Informations professionnelles : poste, salaire, évaluations\n• Données de localisation : adresse, géolocalisation (GPS)\n• Habitudes/comportements : historique de navigation, achats, centres d'intérêt\n• Données sensibles : origine ethnique, opinions politiques, religion, santé, orientation sexuelle, données biométriques ou génétiques"
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# ============================================================================
# Section 2: Cartographie des traitements
# ============================================================================
section2 = questionnaire.sections.find_or_create_by!(order_index: 2) do |s|
  s.title = "Cartographie des traitements"
  s.description = "Identification des principaux traitements de données"
end

# Q1: Avez-vous du personnel?
has_personnel_question = section2.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Avez-vous du personnel ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# ============================================================================
# Section 3: Gestion des ressources humaines
# ============================================================================
section3_hr = questionnaire.sections.find_or_create_by!(order_index: 3) do |s|
  s.title = "Gestion des ressources humaines"
  s.description = "Questions relatives au traitement des données RH"
end

# ============================================================================
# Section 4: Mise en œuvre des droits des personnes (DPO)
# ============================================================================
section4_dpo = questionnaire.sections.find_or_create_by!(order_index: 4) do |s|
  s.title = "Mise en œuvre des droits"
  s.description = "Délégué à la Protection des Données (DPO - Data Protection Officer)"
end

# Q1: Emails professionnels?
has_email_question = section3_hr.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Vos employés disposent-ils d'une adresse email professionnelle ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 1
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Q1.1: Messagerie - Surveillance
email_surveillance_question = section3_hr.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Le traitement est-il mis en œuvre à des fins de surveillance ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q1.2: Messagerie - Données sensibles
email_sensitive_question = section3_hr.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Collectez-vous des données sensibles ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q2: Ligne directe?
has_phone_question = section3_hr.questions.find_or_create_by!(order_index: 4) do |q|
  q.question_text = "Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 1
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Q2.1: Téléphonie - Surveillance
phone_surveillance_question = section3_hr.questions.find_or_create_by!(order_index: 5) do |q|
  q.question_text = "Le traitement est-il mis en œuvre à des fins de surveillance ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q2.2: Téléphonie - Données sensibles
phone_sensitive_question = section3_hr.questions.find_or_create_by!(order_index: 6) do |q|
  q.question_text = "Collectez-vous des données sensibles ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q3: Accès aux locaux
access_method_question = section3_hr.questions.find_or_create_by!(order_index: 7) do |q|
  q.question_text = "Le personnel accède aux locaux par :"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 1
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Un badge", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Une clé", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Un dispositif biométrique", score: 50)
end

# Q4: Délégués du personnel?
has_delegates_question = section3_hr.questions.find_or_create_by!(order_index: 8) do |q|
  q.question_text = "Avez-vous des délégués du personnel ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 1
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Q4.1: Délégués - Surveillance
delegates_surveillance_question = section3_hr.questions.find_or_create_by!(order_index: 9) do |q|
  q.question_text = "Le traitement est-il mis en œuvre à des fins de surveillance ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q4.2: Délégués - Données sensibles
delegates_sensitive_question = section3_hr.questions.find_or_create_by!(order_index: 10) do |q|
  q.question_text = "Collectez-vous des données sensibles ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q5: Finalités de collecte (multiple choice)
hr_purposes_question = section3_hr.questions.find_or_create_by!(order_index: 11) do |q|
  q.question_text = "À quelles fins collectez-vous des données relatives aux ressources humaines ?"
  q.question_type = :multiple_choice
  q.help_text = "Sélectionnez toutes les options qui s'appliquent"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(
    order_index: 1,
    choice_text: "La gestion administrative des personnels"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 2,
    choice_text: "La gestion des rémunérations et accomplissement des formalités administratives afférentes"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 3,
    choice_text: "L'organisation du travail (gestion des outils de travail, du calendrier, etc)"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 4,
    choice_text: "La gestion des carrières et de la mobilité"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 5,
    choice_text: "La gestion de la tenue des registres obligatoires, rapports avec les instances représentatives du personnel"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 6,
    choice_text: "La communication interne"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 7,
    choice_text: "Gestion des aides sociales"
  )
  q.answer_choices.find_or_create_by!(
    order_index: 8,
    choice_text: "Autre"
  )
end

# Q6: Données autres que listées?
other_data_question = section3_hr.questions.find_or_create_by!(order_index: 12) do |q|
  q.question_text = "Traitez-vous des données autres que celles listées ci-après ?"
  q.question_type = :yes_no
  q.help_text = "Données de référence :\n• Identité /situation de famille\n• Nom, prénom, photographie, sexe, date et lieu de naissance, nationalité, situation de famille, numéro de matricule interne, numéro d'immatriculation délivré par un organisme de sécurité sociale/identité du conjoint et des enfants à charge\n• Adresses et coordonnées\n• Coordonnées professionnelles et personnelles, coordonnées des personnes à contacter en cas d'urgence\n• Formation, diplômes, vie professionnelle\n• Nature de l'emploi, poste occupé, fonction ou titre, distinctions honorifiques\n• Copies de document officiels\n• Pas de copie mais informations l'identification et numéro de la pièce relatives à l'identité, date et lieu de délivrance, date de validité\n• Données d'identification électronique identifiant de la personne concernée/ compte utilisateur\n• Informations relatives au contrat de travail/ à la carrière/ aux déclarations d'accident et de maladie professionnelles/ aux évaluations/ à la validation des acquis/ aux formations/aux visites médicales/ au permis de conduire/ aux congés"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(
    order_index: 1,
    choice_text: "Oui",
    score: 0
  )
  q.answer_choices.find_or_create_by!(
    order_index: 2,
    choice_text: "Non",
    score: 100
  )
end

# Q7: Données de connexion?
connection_data_question = section3_hr.questions.find_or_create_by!(order_index: 13) do |q|
  q.question_text = "Collectez-vous des données de connexion ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(
    order_index: 1,
    choice_text: "Oui",
    score: 0
  )
  q.answer_choices.find_or_create_by!(
    order_index: 2,
    choice_text: "Non",
    score: 100
  )
end

# Q1: Personne de droit privé avec mission d'intérêt général?
public_interest_question = section4_dpo.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Êtes-vous une personne de droit privé investie d'une mission d'intérêt général, ou concessionnaire d'un service public ?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# Q2: Activités de base nécessitant suivi régulier?
systematic_monitoring_question = section4_dpo.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Vos activités de base consistent-elles en des opérations de traitement qui, du fait de leur nature, de leur portée ou de leurs finalités, exigent un suivi régulier et systématique à grande échelle des personnes concernées ?"
  q.question_type = :yes_no
  q.help_text = "Le terme \"régulier\" doit s'entendre comme:\n• continu ou se produisant à intervalles réguliers au cours d'une période donnée; ou\n• récurrent ou se répétant à des moments fixes; ou\n• ayant lieu de manière constante ou périodique.\n\nLe terme \"systématique\" s'entend quant à lui comme:\n• se produisant conformément à un système; ou\n• préétabli, organisé ou méthodique; ou\n• ayant lieu dans le cadre d'un programme général de collecte de données; ou\n• effectué dans le cadre d'une stratégie"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

# ============================================================================
# Section 5: Exercice des droits des personnes concernées
# ============================================================================
section5_rights = questionnaire.sections.find_or_create_by!(order_index: 5) do |s|
  s.title = "Exercice des droits"
  s.description = "Point de contact pour l'exercice des droits"
end

# Q1: Point de contact (text fields combined into one question with structured response)
contact_question = section5_rights.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Quel est le point de contact pour exercer ces droits ?"
  q.question_type = :text_long
  q.help_text = "Veuillez fournir les informations suivantes :\n• Prénom\n• Nom\n• Email\n• Numéro de téléphone"
  q.is_required = true
  q.weight = 3
end

# ============================================================================
# Logic Rules Configuration
# ============================================================================
# All logic rules are defined here after all questions are created
# This ensures all question IDs are available for targeting

# Rule 1: Exit if not in Monaco
monaco_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: monaco_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :exit_questionnaire,
  exit_message: "Nous ne couvrons que Monaco pour le moment, mais laissez votre email et on vous contactera quand nous couvrirons d'autres pays que Monaco."
)

# Rule 2: Exit if no personal data processing
personal_data_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: personal_data_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :exit_questionnaire,
  exit_message: "Si vous ne traitez pas de données personnelles, vous n'êtes pas concerné par les obligations RGPD pour le moment."
)

# Rule 3: Skip HR section if no personnel
has_personnel_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_personnel_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_section,
  target_section_id: section4_dpo.id
)

# Rule 4: Skip email subsection if no professional email
has_email_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_email_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: has_phone_question.id
)

# Rule 5: Skip phone subsection if no direct line
has_phone_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_phone_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: access_method_question.id
)

# Rule 6: Skip delegates subsection if no delegates
has_delegates_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_delegates_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: hr_purposes_question.id
)

puts "✓ Created master questionnaire with #{questionnaire.sections.count} sections and #{questionnaire.questions.count} questions"
puts "  - Section 1: Qualification de l'utilisateur (#{section1.questions.count} questions)"
puts "  - Section 2: Cartographie des traitements (#{section2.questions.count} question)"
puts "  - Section 3: Gestion des ressources humaines (#{section3_hr.questions.count} questions)"
puts "  - Section 4: Mise en œuvre des droits (#{section4_dpo.questions.count} questions)"
puts "  - Section 5: Exercice des droits (#{section5_rights.questions.count} question)"
