<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import { Badge } from '$lib/components/ui/badge';
  import { router } from '@inertiajs/svelte';

  let { questionnaireId, latestAssessment, processingActivitiesCount = 0 } = $props();

  // Calculate percentage from raw score (same as ComplianceScoreCard)
  const scorePercentage = $derived(
    latestAssessment
      ? (latestAssessment.overall_score / latestAssessment.max_possible_score * 100).toFixed(0)
      : null
  );

  function startNewAssessment() {
    router.post(`/questionnaires/${questionnaireId}/responses`);
  }

  function navigateToDocuments() {
    router.visit('/documents');
  }

  function navigateToTreatments() {
    router.visit('/registre-traitements');
  }
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>Actions rapides</CardTitle>
  </CardHeader>
  <CardContent>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <!-- Assessments -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          Évaluations
        </h3>
        {#if latestAssessment}
          <p class="text-sm text-gray-600 mb-3">
            Dernière évaluation: {new Date(latestAssessment.created_at).toLocaleDateString('fr-FR')}
          </p>
          <Badge variant="secondary" class="mb-3">
            Score actuel: {scorePercentage}%
          </Badge>
        {/if}
        <Button onclick={startNewAssessment} class="w-full" disabled={!questionnaireId}>
          Nouvelle évaluation
        </Button>
      </div>

      <!-- Documents -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Documents
        </h3>
        <p class="text-sm text-gray-600 mb-3">
          Générez vos documents de conformité
        </p>
        <Button onclick={navigateToDocuments} variant="outline" class="w-full">
          Gérer les documents
        </Button>
      </div>

      <!-- Processing Activities -->
      <div class="border rounded-lg p-4">
        <h3 class="font-semibold mb-2 flex items-center">
          <svg class="w-5 h-5 mr-2 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
          </svg>
          Registre des traitements
        </h3>
        <p class="text-sm text-gray-600 mb-3">
          {processingActivitiesCount} traitement{processingActivitiesCount > 1 ? 's' : ''} actif{processingActivitiesCount > 1 ? 's' : ''}
        </p>
        <Button onclick={navigateToTreatments} variant="outline" class="w-full">
          Voir les traitements
        </Button>
      </div>
    </div>
  </CardContent>
</Card>
