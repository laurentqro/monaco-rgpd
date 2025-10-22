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

# ============================================================================
# Section 2: Cartographie des traitements
# ============================================================================
section2 = questionnaire.sections.create!(
  order_index: 2,
  title: "Cartographie des traitements",
  description: "Identification des principaux traitements de données"
)

# Q1: Avez-vous du personnel?
s2q1_personnel = section2.questions.create!(
  order_index: 1,
  question_text: "Avez-vous du personnel ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q1_personnel.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q2: Vidéosurveillance
s2q2_video = section2.questions.create!(
  order_index: 2,
  question_text: "Avez-vous un dispositif de vidéosurveillance dans les locaux ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q2_video.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q3: Email professionnel
s2q3_email = section2.questions.create!(
  order_index: 3,
  question_text: "Vos employés disposent-ils d'une adresse email professionnelle ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q3_email.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q4: Ligne directe
s2q4_phone = section2.questions.create!(
  order_index: 4,
  question_text: "Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q4_phone.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q5: Accès aux locaux
s2q5_access = section2.questions.create!(
  order_index: 5,
  question_text: "Le personnel accède aux locaux par :",
  question_type: :single_choice,
  is_required: true,
  weight: 0
)

s2q5_access.answer_choices.create!([
  { order_index: 1, choice_text: "Un badge", score: 0 },
  { order_index: 2, choice_text: "Une clé", score: 0 },
  { order_index: 3, choice_text: "Un dispositif biométrique", score: 0 }
])

# Q6: Délégués du personnel
s2q6_delegates = section2.questions.create!(
  order_index: 6,
  question_text: "Avez-vous des délégués du personnel ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q6_delegates.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q7: Site internet
s2q7_website = section2.questions.create!(
  order_index: 7,
  question_text: "Avez-vous un site internet ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q7_website.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])

# Q8: Type de site
s2q8_site_type = section2.questions.create!(
  order_index: 8,
  question_text: "Quel type de site ?",
  question_type: :single_choice,
  is_required: true,
  weight: 0
)

s2q8_site_type.answer_choices.create!([
  { order_index: 1, choice_text: "Site vitrine", score: 0 },
  { order_index: 2, choice_text: "Site de vente en ligne", score: 0 }
])

# Q9: Informations personnel sur site
s2q9_personnel_info = section2.questions.create!(
  order_index: 9,
  question_text: "Votre site présente-t-il des informations relatives au personnel ?",
  question_type: :yes_no,
  is_required: true,
  weight: 0
)

s2q9_personnel_info.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 0 }
])
