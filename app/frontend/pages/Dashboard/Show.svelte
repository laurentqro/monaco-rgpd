<script>
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';

  let { latest_assessment, documents, responses } = $props();

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
        <a
          href="/questionnaires/1"
          class="inline-block px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
        >
          Commencer l'évaluation
        </a>
        <p class="text-sm text-gray-500 mt-4">Temps estimé: 15-20 minutes</p>
      </div>
    {/if}
  </div>
</div>
