# Simplified Monaco RGPD Master Questionnaire for MVP
# This is a starter questionnaire - your lawyer will refine the questions

questionnaire = Questionnaire.find_or_create_by!(title: "Évaluation RGPD Monaco") do |q|
  q.description = "Évaluation de conformité à la Loi n° 1.565"
  q.category = "compliance_assessment"
  q.status = :published
end

# Section 1: Informations générales
section1 = questionnaire.sections.find_or_create_by!(order_index: 1) do |s|
  s.title = "Informations générales"
  s.description = "Informations de base sur votre organisation"
end

monaco_question = section1.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Votre organisation est-elle basée à Monaco?"
  q.question_type = :yes_no
  q.help_text = "Cette plateforme est actuellement réservée aux entités basées à Monaco."
  q.is_required = true
  q.weight = 0 # Not scored, just a gate
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Add exit logic rule: if not based in Monaco, exit questionnaire
no_choice = monaco_question.answer_choices.find_by(choice_text: "Non")
if monaco_question && no_choice
  monaco_question.logic_rules.find_or_create_by!(
    condition_type: :equals,
    condition_value: no_choice.id.to_s,
    action: :exit_questionnaire,
    exit_message: "Cette plateforme est actuellement réservée aux organisations basées à Monaco. Si votre organisation n'est pas basée à Monaco, vous ne pouvez pas utiliser ce questionnaire pour le moment."
  )
end

section1.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Quel est le type de votre entité?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Entreprise")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Association")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "ONG")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "Administration publique")
end

section1.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Combien d'employés/collaborateurs compte votre organisation?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "0 (travailleur indépendant)")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "1-5")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "6-10")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "11-50")
  q.answer_choices.find_or_create_by!(order_index: 5, choice_text: "50+")
end

# Add logic rule to employee count question to skip employee section if no employees
employee_count_question = section1.questions.find_by(order_index: 3)
solo_choice = employee_count_question.answer_choices.find_by(choice_text: "0 (travailleur indépendant)")

# Section 2: Données des employés (will be skipped if no employees)
section_employees = questionnaire.sections.find_or_create_by!(order_index: 2) do |s|
  s.title = "Données des employés"
  s.description = "Comment traitez-vous les données de vos employés?"
end

section_employees.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Avez-vous informé vos employés de leurs droits concernant leurs données personnelles?"
  q.question_type = :yes_no
  q.help_text = "Article 13, Loi n° 1.565 - Information des employés"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

section_employees.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Les données des employés sont-elles sécurisées et accessibles uniquement aux RH?"
  q.question_type = :single_choice
  q.help_text = "Article 32, Loi n° 1.565 - Sécurité des données RH"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, totalement sécurisées", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

# Section 3: Collecte et traitement des données
section3 = questionnaire.sections.find_or_create_by!(order_index: 3) do |s|
  s.title = "Collecte et traitement des données"
  s.description = "Quelles données collectez-vous et comment?"
end

# Create logic rule: if employee count is 0, skip employee section
if employee_count_question && solo_choice
  employee_count_question.logic_rules.find_or_create_by!(
    condition_type: :equals,
    condition_value: solo_choice.id.to_s,
    action: :skip_to_section,
    target_section_id: section3.id
  )
end

section3.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Collectez-vous des données personnelles de clients?"
  q.question_type = :yes_no
  q.help_text = "Données personnelles: nom, email, adresse, téléphone, etc."
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

section3.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Avez-vous une politique de confidentialité publiée et à jour?"
  q.question_type = :single_choice
  q.help_text = "Article 13, Loi n° 1.565"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, publiée et à jour", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Oui, mais obsolète", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

section3.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Disposez-vous d'un registre des traitements (Article 30)?"
  q.question_type = :single_choice
  q.help_text = "Le registre des traitements est obligatoire pour la plupart des organisations"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, complet et à jour", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Oui, mais incomplet", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

# Section 4: Droits des personnes
section4 = questionnaire.sections.find_or_create_by!(order_index: 4) do |s|
  s.title = "Droits des personnes"
  s.description = "Comment respectez-vous les droits des personnes concernées?"
end

section4.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Avez-vous une procédure pour traiter les demandes d'accès aux données?"
  q.question_type = :yes_no
  q.help_text = "Article 15, Loi n° 1.565 - Droit d'accès"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

section4.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Les personnes peuvent-elles facilement exercer leurs droits (rectification, effacement, opposition)?"
  q.question_type = :single_choice
  q.help_text = "Articles 16-21, Loi n° 1.565"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, procédure claire", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

# Section 5: Sécurité des données
section5 = questionnaire.sections.find_or_create_by!(order_index: 5) do |s|
  s.title = "Sécurité des données"
  s.description = "Quelles mesures de sécurité avez-vous mises en place?"
end

section5.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Utilisez-vous le chiffrement pour protéger les données sensibles?"
  q.question_type = :single_choice
  q.help_text = "Article 32, Loi n° 1.565 - Sécurité des traitements"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, systématiquement", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

section5.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Effectuez-vous des sauvegardes régulières des données?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

section5.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Limitez-vous l'accès aux données personnelles aux seules personnes autorisées?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Section 6: Relations avec les tiers
section6 = questionnaire.sections.find_or_create_by!(order_index: 6) do |s|
  s.title = "Relations avec les tiers"
  s.description = "Comment gérez-vous les relations avec vos sous-traitants?"
end

section6.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Faites-vous appel à des sous-traitants qui traitent des données personnelles?"
  q.question_type = :yes_no
  q.help_text = "Ex: hébergeur, service de paiement, comptable"
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

section6.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Avez-vous signé des accords de sous-traitance (DPA) avec vos prestataires?"
  q.question_type = :single_choice
  q.help_text = "Article 28, Loi n° 1.565"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, avec tous", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

puts "✓ Created master questionnaire with #{questionnaire.sections.count} sections and #{questionnaire.questions.count} questions"
