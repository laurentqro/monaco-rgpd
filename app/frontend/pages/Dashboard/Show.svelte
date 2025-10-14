<script>
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';
  import { router, page } from '@inertiajs/svelte';

  let { latest_assessment, documents, responses, questionnaire_id } = $props();

  // Flash message state
  let showFlash = $state(!!$page.props.flash?.notice);

  // Auto-hide flash after 5 seconds
  $effect(() => {
    if (showFlash) {
      const timer = setTimeout(() => {
        showFlash = false;
      }, 5000);
      return () => clearTimeout(timer);
    }
  });

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
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-8">Tableau de bord de conformité</h1>

    <!-- Flash Message -->
    {#if showFlash && $page.props.flash?.notice}
      <div class="mb-6 bg-green-50 border-l-4 border-green-400 p-4 rounded-lg shadow-md">
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <svg class="w-6 h-6 text-green-400 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p class="text-green-700 font-medium">{$page.props.flash.notice}</p>
          </div>
          <button
            onclick={() => showFlash = false}
            class="text-green-400 hover:text-green-600"
            aria-label="Fermer"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    {/if}

    {#if latest_assessment}
      <!-- Score Card -->
      <ComplianceScoreCard assessment={latest_assessment} />

      <!-- Compliance Areas Breakdown -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-8">
        <h2 class="text-xl font-bold mb-4">Conformité par domaine</h2>
        <div class="space-y-4">
          {#each latest_assessment.compliance_area_scores as area (area.area_name)}
            <div>
              <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-medium">{area.area_name}</span>
                <span class="text-sm font-bold">{area.percentage}%</span>
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

      <!-- Documents -->
      {#if documents && documents.length > 0}
        <DocumentList {documents} />
      {/if}

    {:else}
      <!-- Empty State -->
      <div class="bg-white rounded-lg shadow-md p-12 text-center">
        <h2 class="text-2xl font-bold mb-4">Bienvenue sur Monaco RGPD</h2>
        <p class="text-gray-600 mb-6">Complétez votre évaluation pour obtenir:</p>
        <ul class="text-left max-w-md mx-auto mb-8 space-y-2">
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            Votre score de conformité
          </li>
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            4 documents essentiels
          </li>
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            Votre registre Article 30
          </li>
        </ul>
        <button
          onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          disabled={!questionnaire_id}
          class="px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Commencer l'évaluation
        </button>
        <p class="text-sm text-gray-500 mt-4">Temps estimé: 15-20 minutes</p>
      </div>
    {/if}
  </div>
</div>
