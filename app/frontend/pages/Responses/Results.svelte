<script>
  import { router } from '@inertiajs/svelte';

  let { response, assessment, documents } = $props();

  function getRiskLevelColor(riskLevel) {
    const colors = {
      'compliant': 'green',
      'attention_required': 'yellow',
      'non_compliant': 'red'
    };
    return colors[riskLevel] || 'gray';
  }

  function getRiskLevelText(riskLevel) {
    const texts = {
      'compliant': 'Conforme',
      'attention_required': 'Attention requise',
      'non_compliant': 'Non-conforme'
    };
    return texts[riskLevel] || 'Inconnu';
  }

  function getDocumentTypeLabel(type) {
    const labels = {
      'privacy_policy': 'Politique de confidentialité',
      'processing_register': 'Registre des traitements (Article 30)',
      'consent_form': 'Formulaire de consentement',
      'employee_notice': 'Notice employés'
    };
    return labels[type] || type;
  }

  function getDocumentIcon(type) {
    if (type === 'processing_register') {
      return '📋'; // Registry icon
    }
    return '📄';
  }

  const isCalculating = !assessment;
  const processingRegister = documents?.find(d => d.document_type === 'processing_register');
  const otherDocuments = documents?.filter(d => d.document_type !== 'processing_register') || [];
</script>

<div class="min-h-screen bg-gray-50 py-12">
  <div class="max-w-4xl mx-auto px-4">
    <!-- Header -->
    <div class="text-center mb-12">
      <div class="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
        <svg class="w-8 h-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
      </div>
      <h1 class="text-3xl font-bold text-gray-900 mb-2">
        Évaluation terminée !
      </h1>
      <p class="text-gray-600">
        Merci d'avoir complété l'évaluation RGPD Monaco
      </p>
    </div>

    {#if isCalculating}
      <!-- Calculating State -->
      <div class="bg-white rounded-lg shadow-md p-8 mb-8">
        <div class="flex items-center justify-center mb-4">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
        <p class="text-center text-gray-600">
          Calcul de votre score de conformité en cours...
        </p>
      </div>
    {:else}
      <!-- Compliance Score Card -->
      <div class="bg-white rounded-lg shadow-md p-8 mb-8">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Votre score de conformité</h2>

        <div class="flex items-center justify-between mb-6">
          <div>
            <div class="text-5xl font-bold text-{getRiskLevelColor(assessment.risk_level)}-600">
              {assessment.overall_score.toFixed(1)}%
            </div>
            <div class="mt-2 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-{getRiskLevelColor(assessment.risk_level)}-100 text-{getRiskLevelColor(assessment.risk_level)}-800">
              {getRiskLevelText(assessment.risk_level)}
            </div>
          </div>

          <div class="text-right">
            <div class="text-gray-600 text-sm">Score maximum</div>
            <div class="text-2xl font-semibold text-gray-900">{assessment.max_possible_score}</div>
          </div>
        </div>

        <!-- Compliance Areas -->
        {#if assessment.compliance_area_scores && assessment.compliance_area_scores.length > 0}
          <div class="border-t pt-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Conformité par domaine</h3>
            <div class="space-y-4">
              {#each assessment.compliance_area_scores as area}
                <div>
                  <div class="flex justify-between items-center mb-2">
                    <span class="text-sm font-medium text-gray-700">{area.area_name}</span>
                    <span class="text-sm font-bold text-gray-900">{area.percentage}%</span>
                  </div>
                  <div class="w-full bg-gray-200 rounded-full h-3">
                    <div
                      class="h-3 rounded-full {area.percentage >= 85 ? 'bg-green-500' : area.percentage >= 60 ? 'bg-yellow-500' : 'bg-red-500'}"
                      style="width: {area.percentage}%"
                    ></div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        {/if}
      </div>
    {/if}

    <!-- Article 30 Registry (Processing Register) -->
    {#if processingRegister}
      <div class="bg-blue-50 border-l-4 border-blue-400 rounded-lg shadow-md p-8 mb-8">
        <div class="flex items-start">
          <div class="text-4xl mr-4">📋</div>
          <div class="flex-1">
            <h2 class="text-xl font-bold text-gray-900 mb-2">
              Registre des traitements (Article 30)
            </h2>
            <p class="text-gray-700 mb-4">
              Votre registre des activités de traitement est obligatoire selon la Loi n° 1.565.
            </p>

            {#if processingRegister.status === 'generating'}
              <div class="flex items-center text-blue-600">
                <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600 mr-2"></div>
                <span>Génération en cours...</span>
              </div>
            {:else if processingRegister.status === 'ready'}
              <a
                href={processingRegister.download_url}
                class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
              >
                <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Télécharger le registre
              </a>
            {:else}
              <div class="text-red-600">
                Erreur lors de la génération
              </div>
            {/if}
          </div>
        </div>
      </div>
    {/if}

    <!-- Other Documents -->
    {#if otherDocuments.length > 0}
      <div class="bg-white rounded-lg shadow-md p-8 mb-8">
        <h2 class="text-xl font-bold text-gray-900 mb-6">Vos documents essentiels</h2>
        <div class="grid gap-4">
          {#each otherDocuments as doc}
            <div class="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
              <div class="flex items-center">
                <span class="text-3xl mr-4">{getDocumentIcon(doc.document_type)}</span>
                <div>
                  <h3 class="font-semibold text-gray-900">{getDocumentTypeLabel(doc.document_type)}</h3>
                  <p class="text-sm text-gray-600">{doc.title}</p>
                </div>
              </div>

              <div>
                {#if doc.status === 'generating'}
                  <div class="flex items-center text-gray-600">
                    <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-gray-600 mr-2"></div>
                    <span class="text-sm">Génération...</span>
                  </div>
                {:else if doc.status === 'ready'}
                  <a
                    href={doc.download_url}
                    class="inline-flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 font-medium"
                  >
                    <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                    Télécharger
                  </a>
                {:else}
                  <span class="text-red-600 text-sm">Erreur</span>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      </div>
    {/if}

    <!-- Actions -->
    <div class="flex justify-center space-x-4">
      <button
        onclick={() => router.visit('/dashboard')}
        class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
      >
        Retour au tableau de bord
      </button>
    </div>
  </div>
</div>
