# Monaco RGPD Master Questionnaire - Updated Structure
# Full replacement strategy for clean state

# Destroy existing questionnaire and all associated data
existing = Questionnaire.find_by(title: "Évaluation RGPD Monaco")
if existing
  puts "Destroying existing questionnaire..."
  existing.destroy
end

# Create fresh questionnaire
questionnaire = Questionnaire.create!(
  title: "Évaluation RGPD Monaco",
  description: "Évaluation de conformité à la Loi n° 1.565",
  category: "compliance_assessment",
  status: :published
)

puts "Created questionnaire: #{questionnaire.title}"

# ============================================================================
# Section 1: Qualification de l'utilisateur
# ============================================================================
section1 = questionnaire.sections.create!(
  order_index: 1,
  title: "Qualification de l'utilisateur",
  description: "Informations sur votre organisation et son éligibilité"
)

# Q1: Organisation établie à Monaco?
s1q1_monaco = section1.questions.create!(
  order_index: 1,
  question_text: "Votre organisation est-elle établie à Monaco ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s1q1_monaco.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q2: Qui êtes-vous?
s1q2_org_type = section1.questions.create!(
  order_index: 2,
  question_text: "Qui êtes-vous ?",
  question_type: :single_choice,
  is_required: true,
  weight: 0
)

s1q2_org_type.answer_choices.create!([
  { order_index: 1, choice_text: "Entreprise (nom personnel, SARL, SASU, SNC, SAM, etc.)", score: 0 },
  { order_index: 2, choice_text: "Association", score: 0 },
  { order_index: 3, choice_text: "Organisme public", score: 0 },
  { order_index: 4, choice_text: "Profession libérale", score: 0 },
  { order_index: 5, choice_text: "Personne physique agissant dans un cadre domestique", score: 0 }
])

# Q3: Taille de l'organisation
s1q3_org_size = section1.questions.create!(
  order_index: 3,
  question_text: "Quelle est la taille de votre organisation ?",
  question_type: :single_choice,
  is_required: true,
  weight: 0
)

s1q3_org_size.answer_choices.create!([
  { order_index: 1, choice_text: "0", score: 0 },
  { order_index: 2, choice_text: "1-5", score: 0 },
  { order_index: 3, choice_text: "6-10", score: 0 },
  { order_index: 4, choice_text: "11-50", score: 0 },
  { order_index: 5, choice_text: "50+", score: 0 }
])

# Q4: Traitez-vous des données personnelles?
s1q4_personal_data = section1.questions.create!(
  order_index: 4,
  question_text: "Traitez-vous des données personnelles ?",
  question_type: :yes_no,
  help_text: "Voici quelques exemples de données personnelles:\n\n" \
             "• Identité : nom, prénom, numéro de sécurité sociale, adresse IP, identifiant en ligne\n" \
             "• Caractéristiques physiques/physiologiques : photo, empreintes digitales, ADN\n" \
             "• Informations professionnelles : poste, salaire, évaluations\n" \
             "• Données de localisation : adresse, géolocalisation (GPS)\n" \
             "• Habitudes/comportements : historique de navigation, achats, centres d'intérêt\n" \
             "• Données sensibles : origine ethnique, opinions politiques, religion, santé, orientation sexuelle, données biométriques ou génétiques",
  is_required: true,
  weight: 0
)

s1q4_personal_data.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])
