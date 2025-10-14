<script>
  import { router } from '@inertiajs/svelte';

  let { responses } = $props();

  function getStatusText(status) {
    const texts = {
      'in_progress': 'En cours',
      'completed': 'Terminée',
      'draft': 'Brouillon'
    };
    return texts[status] || status;
  }

  function getStatusColor(status) {
    const colors = {
      'in_progress': 'blue',
      'completed': 'green',
      'draft': 'gray'
    };
    return colors[status] || 'gray';
  }

  function getRiskLevelText(riskLevel) {
    const texts = {
      'compliant': 'Risque faible',
      'attention_required': 'Risque moyen',
      'non_compliant': 'Risque élevé'
    };
    return texts[riskLevel] || 'Inconnu';
  }

  function getRiskLevelColor(riskLevel) {
    const colors = {
      'compliant': 'green',
      'attention_required': 'yellow',
      'non_compliant': 'red'
    };
    return colors[riskLevel] || 'gray';
  }

  function formatDate(dateString) {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold">Historique des évaluations</h1>
      <button
        onclick={() => router.visit('/dashboard')}
        class="px-4 py-2 text-gray-600 hover:text-gray-900"
      >
        ← Retour au tableau de bord
      </button>
    </div>

    {#if responses.length === 0}
      <div class="bg-white rounded-lg shadow-md p-12 text-center">
        <p class="text-gray-600 mb-4">Aucune évaluation trouvée</p>
        <button
          onclick={() => router.visit('/dashboard')}
          class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
        >
          Commencer une évaluation
        </button>
      </div>
    {:else}
      <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Questionnaire
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Statut
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Score
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date de création
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date de complétion
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each responses as response (response.id)}
              <tr class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">
                    {response.questionnaire.title}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-{getStatusColor(response.status)}-100 text-{getStatusColor(response.status)}-800">
                    {getStatusText(response.status)}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  {#if response.compliance_assessment}
                    <div class="flex items-center">
                      <span class="text-2xl font-bold text-{getRiskLevelColor(response.compliance_assessment.risk_level)}-600">
                        {Number(response.compliance_assessment.overall_score).toFixed(1)}%
                      </span>
                      <span class="ml-2 text-xs text-gray-500">
                        {getRiskLevelText(response.compliance_assessment.risk_level)}
                      </span>
                    </div>
                  {:else if response.status === 'completed'}
                    <span class="text-sm text-gray-500">Calcul en cours...</span>
                  {:else}
                    <span class="text-sm text-gray-400">-</span>
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {formatDate(response.started_at)}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {formatDate(response.completed_at)}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  {#if response.status === 'completed' && response.compliance_assessment}
                    <a
                      href="/responses/{response.id}/results"
                      class="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      Voir les résultats
                    </a>
                  {/if}
                  {#if response.status === 'in_progress'}
                    <a
                      href="/questionnaires/{response.questionnaire.id}/responses/{response.id}"
                      class="text-blue-600 hover:text-blue-900"
                    >
                      Continuer
                    </a>
                  {/if}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</div>
