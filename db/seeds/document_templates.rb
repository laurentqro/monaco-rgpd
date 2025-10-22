# Initial document templates for Monaco RGPD
# These are simplified starter templates - your lawyer will refine them

templates_data = [
  {
    document_type: :privacy_policy,
    title: "Politique de confidentialité",
    content: <<~LIQUID
      # POLITIQUE DE CONFIDENTIALITÉ

      ## {{ account.name }}

      **Dernière mise à jour:** {{ "now" | date: "%d/%m/%Y" }}

      ### 1. Responsable du traitement

      {{ account.name }}, {{ account.entity_type }}, situé à Monaco.

      ### 2. Données collectées

      Nous collectons et traitons les catégories de données personnelles suivantes :

      {% for activity in processing_activities %}
      - {{ activity.name }}
      {% endfor %}

      ### 3. Bases juridiques

      Les traitements de données personnelles sont fondés sur les bases juridiques prévues par la Loi n° 1.565.

      ### 4. Vos droits

      Conformément aux articles 15 à 22 de la Loi n° 1.565, vous disposez des droits suivants :
      - Droit d'accès à vos données
      - Droit de rectification
      - Droit à l'effacement
      - Droit d'opposition
      - Droit à la limitation du traitement
      - Droit à la portabilité

      Pour exercer vos droits, contactez-nous à : [adresse email]

      ### 5. Conservation des données

      Vos données sont conservées pendant les durées suivantes :
      {% for activity in processing_activities %}
      - {{ activity.name }}: {{ activity.retention_periods | join: ", " }}
      {% endfor %}

      ### 6. Sécurité

      Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données.

      ### 7. Contact

      Pour toute question concernant cette politique, contactez-nous à : [coordonnées]

      ---

      Document généré par Monaco RGPD - Conforme à la Loi n° 1.565
    LIQUID
  },
  {
    document_type: :processing_register,
    title: "Registre des traitements (Article 27)",
    content: <<~LIQUID
      # REGISTRE DES TRAITEMENTS
      # Article 27 - Loi n° 1.565

      **Organisation:** {{ account.name }}
      **Type:** {{ account.entity_type }}
      **Date:** {{ "now" | date: "%d/%m/%Y" }}

      ---

      {% for activity in processing_activities %}
      ## Activité {{ forloop.index }}: {{ activity.name }}

      **Finalités:**
      {% for purpose in activity.purposes %}
      - {{ purpose }}
      {% endfor %}

      **Catégories de données:**
      {% for category in activity.data_categories %}
      - {{ category }}
      {% endfor %}

      **Durées de conservation:**
      {% for period in activity.retention_periods %}
      - {{ period }}
      {% endfor %}

      ---

      {% endfor %}

      Document généré par Monaco RGPD - Conforme à la Loi n° 1.565
    LIQUID
  },
  {
    document_type: :consent_form,
    title: "Formulaire de consentement",
    content: <<~LIQUID
      # FORMULAIRE DE CONSENTEMENT

      **{{ account.name }}**

      Nous collectons vos données personnelles afin de [finalité].

      Conformément à la Loi n° 1.565, nous vous informons que :

      - Vos données seront utilisées pour [finalités]
      - Elles seront conservées pendant [durée]
      - Vous pouvez retirer votre consentement à tout moment
      - Vous disposez d'un droit d'accès, de rectification et d'effacement

      **Consentement:**

      ☐ J'accepte que {{ account.name }} collecte et traite mes données personnelles conformément à cette politique.

      Date: ________________
      Signature: ________________

      ---

      Document généré par Monaco RGPD
    LIQUID
  },
  {
    document_type: :employee_notice,
    title: "Notice d'information employés",
    content: <<~LIQUID
      # NOTICE D'INFORMATION - EMPLOYÉS

      **{{ account.name }}**

      Conformément à la Loi n° 1.565, nous vous informons des traitements de données personnelles vous concernant.

      ### Données collectées

      Dans le cadre de votre emploi, nous collectons et traitons les données suivantes :
      - Identité et coordonnées
      - Données relatives au contrat de travail
      - Données de paie
      - Formation et compétences

      ### Finalités

      Ces données sont traitées pour :
      - Gestion administrative du personnel
      - Gestion de la paie
      - Gestion des formations

      ### Vos droits

      Vous disposez des droits suivants :
      - Droit d'accès
      - Droit de rectification
      - Droit à l'effacement
      - Droit d'opposition
      - Droit à la limitation

      Pour exercer vos droits : [coordonnées RH]

      ### Conservation

      Vos données sont conservées pendant la durée de votre emploi et conformément aux obligations légales de conservation.

      ---

      Document généré par Monaco RGPD
    LIQUID
  }
]

templates_data.each do |template_data|
  DocumentTemplate.find_or_create_by!(document_type: template_data[:document_type]) do |template|
    template.title = template_data[:title]
    template.content = template_data[:content]
    template.version = 1
    template.is_active = true
  end
end

puts "✓ Created #{DocumentTemplate.count} document templates"
