<script>
  let { assessment, responseId } = $props();

  const percentage = $derived((assessment.overall_score / assessment.max_possible_score * 100).toFixed(0));

  const riskLevelColor = $derived({
    'compliant': 'green',
    'attention_required': 'yellow',
    'non_compliant': 'red'
  }[assessment.risk_level] || 'gray');

  const riskLevelText = $derived({
    'compliant': 'Risque faible',
    'attention_required': 'Risque moyen',
    'non_compliant': 'Risque élevé'
  }[assessment.risk_level] || 'Inconnu');
</script>

<div class="bg-white rounded-lg shadow-md p-8 mb-8">
  <div class="flex items-center justify-between">
    <div class="flex-1">
      <h2 class="text-lg font-medium text-gray-600 mb-2">Score global</h2>
      <div class="flex items-baseline space-x-3">
        <span class="text-5xl font-bold text-{riskLevelColor}-600">{percentage}%</span>
        <span class="text-xl text-gray-500">/ 100%</span>
      </div>
      <p class="mt-3 text-lg">
        Niveau de risque: <span class="font-bold text-{riskLevelColor}-600">{riskLevelText}</span>
      </p>
      <p class="mt-2 text-sm text-gray-500">
        Dernière évaluation: {new Date(assessment.created_at).toLocaleDateString('fr-FR')}
      </p>
    </div>

    <div class="flex flex-col space-y-2">
      <a
        href="/responses/{responseId}/results"
        class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium text-center"
      >
        Voir les détails
      </a>
      <a
        href="/responses"
        class="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 font-medium text-center"
      >
        Historique des évaluations
      </a>
    </div>
  </div>
</div>
