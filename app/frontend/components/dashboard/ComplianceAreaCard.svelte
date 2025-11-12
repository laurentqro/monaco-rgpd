<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Badge } from '$lib/components/ui/badge';

  let { areaScore, expanded = $bindable(false) } = $props();

  const riskLevelColors = {
    compliant: 'bg-green-100 border-green-300',
    attention_required: 'bg-yellow-100 border-yellow-300',
    non_compliant: 'bg-red-100 border-red-300'
  };

  const riskLevelBadges = {
    compliant: 'default',
    attention_required: 'secondary',
    non_compliant: 'destructive'
  };

  const riskLevelLabels = {
    compliant: 'Conforme',
    attention_required: 'Attention requise',
    non_compliant: 'Non conforme'
  };

  const areaIcons = {
    'lawfulness': '⚖️',
    'transparency': '📢',
    'rights': '👤',
    'security': '🔒',
    'transfers': '🌍',
    'documentation': '📄',
    'breach': '🚨'
  };

  function toggleExpanded() {
    expanded = !expanded;
  }
</script>

<Card class="cursor-pointer hover:shadow-md transition-shadow {riskLevelColors[areaScore.risk_level]}" onclick={toggleExpanded}>
  <CardHeader>
    <div class="flex items-start justify-between">
      <div class="flex items-center gap-2">
        <span class="text-2xl">{areaIcons[areaScore.area_code] || '📊'}</span>
        <div>
          <CardTitle class="text-lg">{areaScore.area_name}</CardTitle>
        </div>
      </div>
      <div class="text-right">
        <div class="text-3xl font-bold mb-1">{areaScore.percentage.toFixed(0)}%</div>
        <Badge variant={riskLevelBadges[areaScore.risk_level]}>
          {riskLevelLabels[areaScore.risk_level]}
        </Badge>
      </div>
    </div>
  </CardHeader>

  {#if expanded}
    <CardContent>
      <div class="border-t pt-4">
        <p class="text-sm text-gray-600 mb-3">
          Score: {areaScore.score.toFixed(1)} / {areaScore.max_score}
        </p>

        {#if areaScore.percentage < 80}
          <div class="bg-blue-50 border border-blue-200 rounded p-3">
            <p class="text-sm font-semibold mb-1">💡 Amélioration recommandée</p>
            <p class="text-sm text-gray-700">
              {#if areaScore.percentage < 60}
                Ce domaine nécessite une attention prioritaire. Consultez les actions recommandées ci-dessus.
              {:else}
                Quelques optimisations permettraient d'atteindre la conformité optimale.
              {/if}
            </p>
          </div>
        {:else}
          <div class="bg-green-50 border border-green-200 rounded p-3">
            <p class="text-sm font-semibold mb-1">✅ Excellent travail!</p>
            <p class="text-sm text-gray-700">
              Vous êtes conforme dans ce domaine. Continuez à maintenir ces bonnes pratiques.
            </p>
          </div>
        {/if}
      </div>
    </CardContent>
  {/if}
</Card>
