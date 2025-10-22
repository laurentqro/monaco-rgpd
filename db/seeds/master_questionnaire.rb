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

# ============================================================================
# Section 3: Traitements - Gestion des ressources humaines
# ============================================================================
section3_hr = questionnaire.sections.create!(
  order_index: 3,
  title: "Gestion des ressources humaines",
  description: "Vous avez du personnel ou projetez d'en avoir. En langage RGPD, vous mettez en œuvre un traitement de données personnelles dont la finalité est la gestion des ressources humaines. Pour vous aider, un cadre de référence vous permet de vous assurer de votre conformité. Si vous sortez de ce cadre, un audit personnalisé est nécessaire."
)

# Q1: Raisons de collecte RH
s3q1_hr_purposes = section3_hr.questions.create!(
  order_index: 1,
  question_text: "Pour quelles raisons collectez-vous des données sur vos salariés ? Collectez-vous des données à d'autres fins ?",
  question_type: :yes_no,
  help_text: "Voici les finalités admises dans le cadre de référence:\n\n" \
             "• la gestion administrative des personnels, notamment la procédure d'embauche, de renouvellement et de fin de contrat, le suivi administratif des visites médicales obligatoires des salariés, la gestion des déclarations relatives aux accidents du travail et maladies professionnelles; la tenue et la mise à jour des fiches administratives des salariés, gestion des compétences, le suivi des formations, le suivi des congés et absences, la production d'états statistiques non nominative, etc.\n" \
             "• la gestion des rémunérations et accomplissement des formalités administratives afférentes\n" \
             "• l'organisation du travail (gestion des outils de travail, du calendrier, etc)\n" \
             "• la gestion des carrières et de la mobilité\n" \
             "• la gestion de la tenue des registres obligatoires, rapports avec les instances représentatives du personnel\n" \
             "• la communication interne\n" \
             "• gestion des aides sociales",
  is_required: true,
  weight: 2
)

s3q1_hr_purposes.answer_choices.create!([
  { order_index: 1, choice_text: "Oui (⚠️ susceptible de sortir du cadre de référence)", score: 0 },
  { order_index: 2, choice_text: "Non (✅)", score: 100 }
])

# Q2: Types de données RH
s3q2_hr_data = section3_hr.questions.create!(
  order_index: 2,
  question_text: "Quelles données collectez-vous sur vos salariés ?",
  question_type: :yes_no,
  help_text: "Collectez-vous des données autres que celles listées ci-après ?\n\n" \
             "Données de référence:\n" \
             "• Identité /situation de famille\n" \
             "• Nom, prénom, photographie, sexe, date et lieu de naissance, nationalité, situation de famille, numéro de matricule interne, numéro d'immatriculation délivré par un organisme de sécurité sociale/identité du conjoint et des enfants à charge\n" \
             "• Adresses et coordonnées\n" \
             "• Coordonnées professionnelles et personnelles, coordonnées des personnes à contacter en cas d'urgence\n" \
             "• Formation, diplômes, vie professionnelle\n" \
             "• Nature de l'emploi, poste occupé, fonction ou titre, distinctions honorifiques\n" \
             "• Copies de document officiels\n" \
             "• Pas de copie mais informations l'identification et numéro de la pièce relatives à l'identité, date et lieu de délivrance, date de validité\n" \
             "• Données d'identification électronique identifiant de la personne concernée/ compte utilisateur\n" \
             "• Informations relatives au contrat de travail/ à la carrière/ aux déclarations d'accident et de maladie professionnelles/ aux évaluations/ à la validation des acquis/ aux formations/aux visites médicales/ au permis de conduire/ aux congés",
  is_required: true,
  weight: 2
)

s3q2_hr_data.answer_choices.create!([
  { order_index: 1, choice_text: "Oui (⚠️ susceptible de sortir du cadre de référence)", score: 0 },
  { order_index: 2, choice_text: "Non (✅)", score: 100 }
])

# ============================================================================
# Section 4: DPO (Délégué à la Protection des Données)
# ============================================================================
section4_dpo = questionnaire.sections.create!(
  order_index: 4,
  title: "DPO",
  description: "Voyons si vous êtes tenu par la loi de nommer un DPO.\n\n" \
               "Le Délégué à la Protection des Données (DPO - Data Protection Officer).\n\n" \
               "Le DPO doit être désigné en raison de ses compétences professionnelles et de sa connaissance du droit et des pratiques en matière de protection des données. Il peut être un salarié interne ou un prestataire externe. Enfin, il doit être impliqué de manière appropriée et en temps utile dans toutes les décisions et projets liés à la protection des données, en tenant compte des risques propres aux traitements effectués.\n\n" \
               "Le DPO est chargé d'informer et de conseiller le responsable du traitement, le sous-traitant et leurs employés sur leurs obligations en matière de protection des données. Il veille au respect de la législation et des procédures internes, notamment en matière de répartition des responsabilités, de sensibilisation, de formation et d'audit. Il conseille également sur la réalisation des analyses d'impact, coopère avec l'autorité de protection et sert de point de contact pour toute question relative au traitement des données.\n\n" \
               "Répondez aux questions suivantes pour déterminer s'il vous en faut un:"
)

# Q1: Personne de droit privé avec mission d'intérêt général
s4q1_public_interest = section4_dpo.questions.create!(
  order_index: 1,
  question_text: "Êtes-vous une personne de droit privé investie d'une mission d'intérêt général ou le concessionnaire d'un service public ?",
  question_type: :yes_no,
  is_required: true,
  weight: 3
)

s4q1_public_interest.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q2: Suivi régulier et systématique
s4q2_systematic = section4_dpo.questions.create!(
  order_index: 2,
  question_text: "Vos activités de base consistent-elles en des opérations de traitement qui, du fait de leur nature, de leur portée ou de leurs finalités, exigent un suivi régulier et systématique à grande échelle des personnes concernées ?",
  question_type: :yes_no,
  help_text: "Le terme \"régulier\" doit s'entendre comme:\n" \
             "• continu ou se produisant à intervalles réguliers au cours d'une période donnée; ou\n" \
             "• récurrent ou se répétant à des moments fixes; ou\n" \
             "• ayant lieu de manière constante ou périodique.\n\n" \
             "Le terme \"systématique\" s'entend quant à lui comme:\n" \
             "• se produisant conformément à un système; ou\n" \
             "• préétabli, organisé ou méthodique; ou\n" \
             "• ayant lieu dans le cadre d'un programme général de collecte de données; ou\n" \
             "• effectué dans le cadre d'une stratégie",
  is_required: true,
  weight: 3
)

s4q2_systematic.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])
