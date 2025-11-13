# Monaco RGPD Master Questionnaire - Updated Structure
# Full replacement strategy for clean state

# Destroy existing questionnaire and all associated data
existing = Questionnaire.find_by(title: "Évaluation RGPD Monaco")
if existing
  puts "Destroying existing questionnaire..."
  existing.destroy
end

# Create fresh questionnaire
questionnaire_intro = <<~MARKDOWN
  Bienvenue dans l'évaluation de conformité RGPD pour Monaco.

  Cette évaluation vous guidera à travers les exigences de la **Loi n° 1.565**
  relative à la protection des données à caractère personnel et vous aidera à:

  * Identifier vos obligations légales
  * Évaluer votre niveau de conformité actuel
  * Recevoir des recommandations personnalisées

  *Durée estimée: 15-20 minutes*
  *Toutes les questions sont obligatoires.*
MARKDOWN

questionnaire = Questionnaire.create!(
  title: "Évaluation RGPD Monaco",
  description: "Évaluation de conformité à la Loi n° 1.565",
  category: "compliance_assessment",
  status: :published,
  intro_text: questionnaire_intro
)

puts "Created questionnaire: #{questionnaire.title}"

# ============================================================================
# Section 1: Qualification de l'utilisateur
# ============================================================================
section1_intro = <<~MARKDOWN
  Pour déterminer si vous êtes concerné par la loi n° 1.565, nous devons d'abord
  qualifier la situation de votre organisation.
MARKDOWN

section1 = questionnaire.sections.create!(
  order_index: 1,
  title: "Qualification",
  description: "Informations sur votre organisation et son éligibilité",
  intro_text: section1_intro
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
  { order_index: 4, choice_text: "Profession libérale", score: 0 }
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
section3_intro = <<~MARKDOWN
  Vous avez du personnel ou projetez d'en avoir. En langage RGPD, vous mettez en œuvre un traitement de données personnelles dont la finalité est la gestion des ressources humaines.

  Pour vous aider, un cadre de référence vous permet de vous assurer de votre conformité.

  Si vous sortez de ce cadre, un audit personnalisé est nécessaire.
MARKDOWN

section3_hr = questionnaire.sections.create!(
  order_index: 3,
  title: "Gestion des ressources humaines",
  intro_text: section3_intro
)

# Q1: Raisons de collecte RH
s3q1_intro = <<~MARKDOWN
  Voici les finalités admises dans le cadre de référence:

  * la gestion administrative des personnels, notamment la procédure d'embauche, de renouvellement et de fin de contrat, le suivi administratif des visites médicales obligatoires des salariés, la gestion des déclarations relatives aux accidents du travail et maladies professionnelles; la tenue et la mise à jour des fiches administratives des salariés, gestion des compétences, le suivi des formations, le suivi des congés et absences, la production d'états statistiques non nominatifs, etc.
  * la gestion des rémunérations et accomplissement des formalités administratives afférentes
  * l'organisation du travail (gestion des outils de travail, du calendrier, etc)
  * la gestion des carrières et de la mobilité
  * la gestion de la tenue des registres obligatoires, rapports avec les instances représentatives du personnel
  * la communication interne
  * gestion des aides sociales
MARKDOWN

s3q1_hr_purposes = section3_hr.questions.create!(
  order_index: 1,
  question_text: "Collectez-vous des données à d'autres fins que celles listées ci-dessus ?",
  question_type: :yes_no,
  intro_text: s3q1_intro,
  is_required: true,
  weight: 2
)

s3q1_hr_purposes.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q2: Types de données RH
s3q2_intro = <<~MARKDOWN
  Voici les données de référence:

  * Identité / situation de famille,
  * Nom, prénom, photographie, sexe, date et lieu de naissance, nationalité, situation de famille, numéro de matricule interne, numéro d'immatriculation délivré par un organisme de sécurité sociale, identité du conjoint et des enfants à charge,
  * Adresses et coordonnées,
  * Coordonnées professionnelles et personnelles, coordonnées des personnes à contacter en cas d'urgence
  * Formation, diplômes, vie professionnelle,
  * Nature de l'emploi, poste occupé, fonction ou titre, distinctions honorifiques,
  * Copies de documents officiels,
  * Pas de copie mais informations sur l'identification et numéro de la pièce relatives à l'identité, date et lieu de délivrance, date de validité,
  * Données d'identification électronique identifiant de la personne concernée / compte utilisateur,

  * Informations relatives:
    * au contrat de travail,
    * à la carrière,
    * aux déclarations d'accidents et de maladies professionnelles,
    * aux évaluations,
    *  à la validation des acquis,
    * aux formations,
    * aux visites médicales,
    * au permis de conduire,
    * aux congés.
MARKDOWN

s3q2_hr_data = section3_hr.questions.create!(
  order_index: 2,
  question_text: "Collectez-vous des données autres que celles listées ci-dessus ?",
  question_type: :yes_no,
  intro_text: s3q2_intro,
  is_required: true,
  weight: 2
)

s3q2_hr_data.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# ============================================================================
# Section 4: DPO (Délégué à la Protection des Données)
# ============================================================================
section4_intro = <<~MARKDOWN
  Le Délégué à la Protection des Données (DPO) doit être désigné en raison de ses compétences professionnelles et de sa connaissance du droit et des pratiques en matière de protection des données. Il peut être un salarié interne ou un prestataire externe. Enfin, il doit être impliqué de manière appropriée et en temps utile dans toutes les décisions et projets liés à la protection des données, en tenant compte des risques propres aux traitements effectués.

  Le DPO est chargé d'informer et de conseiller le responsable du traitement, le sous-traitant et leurs employés sur leurs obligations en matière de protection des données. Il veille au respect de la législation et des procédures internes, notamment en matière de répartition des responsabilités, de sensibilisation, de formation et d'audit. Il conseille également sur la réalisation des analyses d'impact, coopère avec l'autorité de protection et sert de point de contact pour toute question relative au traitement des données.

  Répondez aux questions de cette section afin de déterminer si vous êtes tenus par la loi de nommer un DPO.
MARKDOWN

section4_description = <<~MARKDOWN
  Voyons si vous êtes tenu par la loi de nommer un DPO.

  Le Délégué à la Protection des Données (DPO - Data Protection Officer).

  Le DPO doit être désigné en raison de ses compétences professionnelles et de sa connaissance du droit et des pratiques en matière de protection des données. Il peut être un salarié interne ou un prestataire externe. Enfin, il doit être impliqué de manière appropriée et en temps utile dans toutes les décisions et projets liés à la protection des données, en tenant compte des risques propres aux traitements effectués.

  Le DPO est chargé d'informer et de conseiller le responsable du traitement, le sous-traitant et leurs employés sur leurs obligations en matière de protection des données. Il veille au respect de la législation et des procédures internes, notamment en matière de répartition des responsabilités, de sensibilisation, de formation et d'audit. Il conseille également sur la réalisation des analyses d'impact, coopère avec l'autorité de protection et sert de point de contact pour toute question relative au traitement des données.

  Répondez aux questions suivantes pour déterminer s'il vous en faut un:
MARKDOWN

section4_dpo = questionnaire.sections.create!(
  order_index: 4,
  title: "Avez-vous besoin de nommer un Délégué à la Protection des Données (DPO) ?",
  description: section4_description,
  intro_text: section4_intro
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
s4q2_help_text = <<~MARKDOWN
  Le terme **"régulier"** doit s'entendre comme:

  * continu ou se produisant à intervalles réguliers au cours d'une période donnée; ou
  * récurrent ou se répétant à des moments fixes; ou
  * ayant lieu de manière constante ou périodique.

  Le terme **"systématique"** s'entend quant à lui comme:

  * se produisant conformément à un système; ou
  * préétabli, organisé ou méthodique; ou
  * ayant lieu dans le cadre d'un programme général de collecte de données; ou
  * effectué dans le cadre d'une stratégie
MARKDOWN

s4q2_systematic = section4_dpo.questions.create!(
  order_index: 2,
  question_text: "Vos activités de base consistent-elles en des opérations de traitement qui, du fait de leur nature, de leur portée ou de leurs finalités, exigent un suivi régulier et systématique à grande échelle des personnes concernées ?",
  question_type: :yes_no,
  help_text: s4q2_help_text,
  is_required: true,
  weight: 3
)

s4q2_systematic.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# ============================================================================
# Section 5: Relations avec les sous-traitants
# ============================================================================
section5_subcontractors = questionnaire.sections.create!(
  order_index: 5,
  title: "Relations avec les sous-traitants",
  description: "Comment gérez-vous les relations avec vos sous-traitants?"
)

# Q1: Sous-traitants
s5q1_help_text = <<~MARKDOWN
  Un sous-traitant est la personne physique ou morale, l'autorité publique, le service ou tout autre organisme qui traite des données à caractère personnel pour le compte du responsable du traitement.

  **Exemples:**
  * Un hébergeur internet qui stocke les données personnelles d'une entreprise cliente est un sous-traitant. Le responsable de traitement est l'entreprise cliente qui décide de l'usage des données, tandis que l'hébergeur exécute le traitement pour son compte.
  * Une agence de marketing qui accède aux données clients d'une entreprise pour réaliser une campagne publicitaire sur instruction de cette entreprise est un sous-traitant.

  **Note:**
  Le sous-traitant doit présenter les garanties suffisantes quant à la mise en œuvre de mesures techniques et organisationnelles appropriées de manière à assurer la protection des données personnelles et le respect des droits des personnes concernées.
MARKDOWN

s5q1_subcontractors = section5_subcontractors.questions.create!(
  order_index: 1,
  question_text: "Faites-vous appel à des sous-traitants qui traitent des données personnelles ?",
  question_type: :yes_no,
  help_text: s5q1_help_text,
  is_required: true,
  weight: 0
)

s5q1_subcontractors.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# ============================================================================
# Section 6: Analyse d'impact
# ============================================================================
section6_dpia = questionnaire.sections.create!(
  order_index: 6,
  title: "Analyse d'impact",
  description: "Analyse d'impact"
)

# Q1: Profilage
s6q1_help_text = <<~MARKDOWN
  **Exemple 1:** Une banque utilise un algorithme qui analyse automatiquement les habitudes d'achat, revenus et comportements financiers pour établir un score de crédit personnalisé.
  **Exemple 2:** Une plateforme de streaming analyse systématiquement les préférences de visionnage, temps d'écoute et interactions pour créer des profils de recommandation personnalisés.
MARKDOWN

s6q1_profiling = section6_dpia.questions.create!(
  order_index: 1,
  question_text: "Procédez-vous à une évaluation systématique et approfondie d'aspects personnels (*profilage*)?",
  question_type: :yes_no,
  help_text: s6q1_help_text,
  is_required: true,
  weight: 0
)

s6q1_profiling.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q2: Décisions automatisées
s6q2_help_text = <<~MARKDOWN
  **Exemple 1:** Un système de recrutement qui rejette automatiquement des candidatures sur la base d'une analyse algorithmique sans intervention humaine.
  **Exemple 2:** Une assurance qui refuse automatiquement une couverture santé en analysant les données médicales via intelligence artificielle.
MARKDOWN

s6q2_automated = section6_dpia.questions.create!(
  order_index: 2,
  question_text: "Prenez-vous des décisions automatisées ayant des effets juridiques ou significatifs pour les personnes concernées ?",
  question_type: :yes_no,
  help_text: s6q2_help_text,
  is_required: true,
  weight: 0
)

s6q2_automated.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q3: Surveillance systématique
s6q3_help_text = <<~MARKDOWN
  **Exemple 1:** Installation de caméras de vidéosurveillance avec reconnaissance faciale dans les espaces publics pour suivre les déplacements des citoyens.
  **Exemple 2:** Mise en place d'un système de géolocalisation permanente des véhicules de fonction pour surveiller les trajets et comportements des employés.
MARKDOWN

s6q3_surveillance = section6_dpia.questions.create!(
  order_index: 3,
  question_text: "Procédez-vous à une surveillance systématique des personnes concernées ?",
  question_type: :yes_no,
  help_text: s6q3_help_text,
  is_required: true,
  weight: 0
)

s6q3_surveillance.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q4: Données sensibles
s6q4_help_text = <<~MARKDOWN
  **Exemple 1:** Collecte et traitement de dossiers médicaux complets dans une application de téléconsultation incluant antécédents, traitements et pathologies.
  **Exemple 2:** Base de données RH contenant les informations sur l'appartenance syndicale et les opinions politiques des salariés.
MARKDOWN

s6q4_sensitive = section6_dpia.questions.create!(
  order_index: 4,
  question_text: "Traitez-vous des données sensibles ?",
  question_type: :yes_no,
  help_text: s6q4_help_text,
  is_required: true,
  weight: 0
)

s6q4_sensitive.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q5: Croisement de données
s6q5_help_text = <<~MARKDOWN
  **Exemple 1:** Combinaison des données clients (achats, localisation GPS, réseaux sociaux) avec des données externes (revenus, situation familiale) pour du marketing ciblé.
  **Exemple 2:** Croisement des données de vidéosurveillance avec les bases de données de police criminelle et les fichiers d'identité pour identification automatique.
MARKDOWN

s6q5_crossdata = section6_dpia.questions.create!(
  order_index: 5,
  question_text: "Faites-vous un croisement ou combinaison d'ensembles de données ?",
  question_type: :yes_no,
  help_text: s6q5_help_text,
  is_required: true,
  weight: 0
)

s6q5_crossdata.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q6: Personnes vulnérables
s6q6_help_text = <<~MARKDOWN
  **Exemple 1:** Application mobile destinée aux mineurs collectant leurs données de géolocalisation, contacts et habitudes de navigation.
  **Exemple 2:** Système de gestion des données personnelles de patients atteints de troubles mentaux ou de personnes âgées dépendantes.
MARKDOWN

s6q6_vulnerable = section6_dpia.questions.create!(
  order_index: 6,
  question_text: "Traitez-vous des données concernant des personnes vulnérables ?",
  question_type: :yes_no,
  help_text: s6q6_help_text,
  is_required: true,
  weight: 0
)

s6q6_vulnerable.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q7: Technologies innovantes
s6q7_help_text = <<~MARKDOWN
  **Exemple 1:** Déploiement d'un système de reconnaissance faciale par intelligence artificielle pour contrôler l'accès à un immeuble.
  **Exemple 2:** Mise en place d'objets connectés (IoT) pour surveiller en temps réel la santé des employés sur leur lieu de travail.
MARKDOWN

s6q7_innovative = section6_dpia.questions.create!(
  order_index: 7,
  question_text: "Utilisez-vous des technologies innovantes ou nouvelles ?",
  question_type: :yes_no,
  help_text: s6q7_help_text,
  is_required: true,
  weight: 0
)

s6q7_innovative.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# Q8: Empêchement d'exercice de droits
s6q8_help_text = <<~MARKDOWN
  **Exemple 1:** Système automatisé bloquant définitivement l'accès à un service bancaire en ligne suite à un comportement détecté comme suspect, sans possibilité de recours.
  **Exemple 2:** Plateforme qui suspend automatiquement un compte utilisateur sur la base d'une analyse comportementale, privant la personne de ses droits contractuels.
MARKDOWN

s6q8_rights = section6_dpia.questions.create!(
  order_index: 8,
  question_text: "Effectuez-vous un traitement empêchant l'exercice d'un droit ou l'accès à un service ?",
  question_type: :yes_no,
  help_text: s6q8_help_text,
  is_required: true,
  weight: 0
)

s6q8_rights.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  { order_index: 2, choice_text: "Non", score: 100 }
])

# ============================================================================
# Logic Rules Configuration
# ============================================================================
# All logic rules are defined here after all questions exist
# This ensures all question/section IDs are available for targeting

puts "\nConfiguring logic rules..."

# Rule 1: S1Q1 - Exit if not in Monaco
s1q1_no = s1q1_monaco.answer_choices.find_by(choice_text: "Non")
s1q1_monaco.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q1_no.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Nous ne couvrons que Monaco pour le moment, mais laissez votre email et on vous contactera quand nous couvrirons d'autres pays que Monaco."
)

# Rule 2: S1Q2 - Exit if Association
s1q2_association = s1q2_org_type.answer_choices.find_by(choice_text: "Association")
s1q2_org_type.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q2_association.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Conseil personnalisé"
)

# Rule 3: S1Q2 - Exit if Organisme public
s1q2_public = s1q2_org_type.answer_choices.find_by(choice_text: "Organisme public")
s1q2_org_type.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q2_public.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Conseil personnalisé"
)

# Rule 4: S1Q2 - Exit if Profession libérale
s1q2_liberal = s1q2_org_type.answer_choices.find_by(choice_text: "Profession libérale")
s1q2_org_type.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q2_liberal.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Conseil personnalisé"
)

# Rule 5: S1Q2 - Exit if Personne physique
s1q2_individual = s1q2_org_type.answer_choices.find_by(choice_text: "Personne physique agissant dans un cadre domestique")
s1q2_org_type.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q2_individual.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Non assujetti"
)

# Rule 6: S1Q4 - Exit if no personal data
s1q4_no = s1q4_personal_data.answer_choices.find_by(choice_text: "Non")
s1q4_personal_data.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q4_no.id.to_s,
  action: :exit_questionnaire,
  exit_message: "Si vous ne traitez pas de données personnelles, vous n'êtes pas concerné par les obligations RGPD pour le moment."
)

# Rule 7: S2Q1 - Skip Section 3 if no personnel
s2q1_no = s2q1_personnel.answer_choices.find_by(choice_text: "Non")
s2q1_personnel.logic_rules.create!(
  condition_type: :equals,
  condition_value: s2q1_no.id.to_s,
  action: :skip_to_section,
  target_section_id: section4_dpo.id
)

# Rule 8: S2Q2 - Exit if video surveillance (needs custom handling)
s2q2_yes = s2q2_video.answer_choices.find_by(choice_text: "Oui")
s2q2_video.logic_rules.create!(
  condition_type: :equals,
  condition_value: s2q2_yes.id.to_s,
  action: :exit_questionnaire,
  exit_message: "La vidéosurveillance nécessite une analyse personnalisée. Merci de nous contacter."
)

# Rule 9: S2Q7 - Skip to after website questions if no website
s2q7_no = s2q7_website.answer_choices.find_by(choice_text: "Non")
s2q7_website.logic_rules.create!(
  condition_type: :equals,
  condition_value: s2q7_no.id.to_s,
  action: :skip_to_section,
  target_section_id: section3_hr.id
)

puts "\n✓ Created master questionnaire with #{questionnaire.sections.count} sections"
puts "  - Section 1: #{section1.title} (#{section1.questions.count} questions)"
puts "  - Section 2: #{section2.title} (#{section2.questions.count} questions)"
puts "  - Section 3: #{section3_hr.title} (#{section3_hr.questions.count} questions)"
puts "  - Section 4: #{section4_dpo.title} (#{section4_dpo.questions.count} questions)"
puts "  - Section 5: #{section5_subcontractors.title} (#{section5_subcontractors.questions.count} questions)"
puts "  - Section 6: #{section6_dpia.title} (#{section6_dpia.questions.count} questions)"
puts "  - Total questions: #{questionnaire.questions.count}"
puts "  - Total logic rules: #{LogicRule.where(source_question_id: questionnaire.questions.pluck(:id)).count}"
