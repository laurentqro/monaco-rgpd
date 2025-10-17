<script>
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';
  import { router, page } from '@inertiajs/svelte';

  let { latest_assessment, latest_response_id, documents, responses, questionnaire_id } = $props();

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
      'compliant': 'Risque faible',
      'attention_required': 'Risque moyen',
      'non_compliant': 'Risque élevé'
    };
    return texts[riskLevel] || 'Inconnu';
  }
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold">Tableau de bord de conformité</h1>
      {#if latest_assessment && questionnaire_id}
        <button
          onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium flex items-center"
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle évaluation
        </button>
      {/if}
    </div>

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
      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />

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
