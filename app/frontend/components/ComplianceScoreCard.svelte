<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import { Badge } from '$lib/components/ui/badge';
  import { Button } from '$lib/components/ui/button';
  import { Progress } from '$lib/components/ui/progress';

  let { assessment, responseId } = $props();

  const percentage = $derived((assessment.overall_score / assessment.max_possible_score * 100).toFixed(0));

  const riskLevelText = $derived({
    'compliant': 'Risque faible',
    'attention_required': 'Risque moyen',
    'non_compliant': 'Risque élevé'
  }[assessment.risk_level] || 'Inconnu');

  const badgeVariant = $derived({
    'compliant': 'default',
    'attention_required': 'secondary',
    'non_compliant': 'destructive'
  }[assessment.risk_level] || 'secondary');

  // Use complete Tailwind classes for JIT compiler
  const scoreColorClass = $derived(
    assessment.risk_level === 'compliant' ? 'text-green-600' :
    assessment.risk_level === 'attention_required' ? 'text-yellow-600' :
    assessment.risk_level === 'non_compliant' ? 'text-red-600' :
    'text-gray-600'
  );
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>Score de Conformité</CardTitle>
    <CardDescription>Votre niveau de conformité RGPD</CardDescription>
  </CardHeader>
  <CardContent>
    <div class="flex items-center justify-between">
      <div class="flex-1">
        <h2 class="text-lg font-medium text-gray-600 mb-2">Score global</h2>
        <div class="flex items-baseline space-x-3">
          <span class="text-5xl font-bold {scoreColorClass}">{percentage}%</span>
          <span class="text-xl text-gray-500">/ 100%</span>
        </div>

        <!-- Progress bar visualization -->
        <div class="mt-4 mb-3">
          <Progress value={Number(percentage)} class="h-3" />
        </div>

        <div class="mt-3 flex items-center gap-2">
          <span class="text-lg">Niveau de risque:</span>
          <Badge variant={badgeVariant} class="text-sm font-bold">
            {riskLevelText}
          </Badge>
        </div>

        <p class="mt-2 text-sm text-gray-500">
          Dernière évaluation: {new Date(assessment.created_at).toLocaleDateString('fr-FR')}
        </p>
      </div>

      <div class="flex flex-col space-y-2">
        <Button href="/responses/{responseId}/results" class="font-medium">
          Voir les détails
        </Button>
        <Button href="/responses" variant="outline" class="font-medium">
          Historique des évaluations
        </Button>
      </div>
    </div>
  </CardContent>
</Card>
