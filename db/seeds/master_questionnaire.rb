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

section1.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Votre organisation est-elle basée à Monaco?"
  q.question_type = :yes_no
  q.help_text = "Cette plateforme est actuellement réservée aux entités basées à Monaco."
  q.is_required = true
  q.weight = 0 # Not scored, just a gate
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
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

# Section 2: Collecte et traitement des données
section2 = questionnaire.sections.find_or_create_by!(order_index: 2) do |s|
  s.title = "Collecte et traitement des données"
  s.description = "Quelles données collectez-vous et comment?"
end

section2.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Collectez-vous des données personnelles de clients?"
  q.question_type = :yes_no
  q.help_text = "Données personnelles: nom, email, adresse, téléphone, etc."
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

section2.questions.find_or_create_by!(order_index: 2) do |q|
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

section2.questions.find_or_create_by!(order_index: 3) do |q|
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

# Section 3: Droits des personnes
section3 = questionnaire.sections.find_or_create_by!(order_index: 3) do |s|
  s.title = "Droits des personnes"
  s.description = "Comment respectez-vous les droits des personnes concernées?"
end

section3.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Avez-vous une procédure pour traiter les demandes d'accès aux données?"
  q.question_type = :yes_no
  q.help_text = "Article 15, Loi n° 1.565 - Droit d'accès"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

section3.questions.find_or_create_by!(order_index: 2) do |q|
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

# Section 4: Sécurité des données
section4 = questionnaire.sections.find_or_create_by!(order_index: 4) do |s|
  s.title = "Sécurité des données"
  s.description = "Quelles mesures de sécurité avez-vous mises en place?"
end

section4.questions.find_or_create_by!(order_index: 1) do |q|
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

section4.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Effectuez-vous des sauvegardes régulières des données?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

section4.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Limitez-vous l'accès aux données personnelles aux seules personnes autorisées?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 0)
end

# Section 5: Relations avec les tiers
section5 = questionnaire.sections.find_or_create_by!(order_index: 5) do |s|
  s.title = "Relations avec les tiers"
  s.description = "Comment gérez-vous les relations avec vos sous-traitants?"
end

section5.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Faites-vous appel à des sous-traitants qui traitent des données personnelles?"
  q.question_type = :yes_no
  q.help_text = "Ex: hébergeur, service de paiement, comptable"
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Non", score: 100)
end

section5.questions.find_or_create_by!(order_index: 2) do |q|
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
