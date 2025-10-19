<script>
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Alert, AlertDescription } from '$lib/components/ui/alert';
  import { Badge } from '$lib/components/ui/badge';
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';
  import { router, page } from '@inertiajs/svelte';

  let { latest_assessment, latest_response_id, documents, responses, questionnaire_id } = $props();

  let showFlash = $state(!!$page.props.flash?.notice);

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
      <div class="flex items-center gap-4">
        {#if latest_assessment && questionnaire_id}
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Nouvelle évaluation
          </Button>
        {/if}
        <Button
          variant="outline"
          onclick={() => router.delete('/session')}
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Déconnexion
        </Button>
      </div>
    </div>

    <!-- Flash Message -->
    {#if showFlash && $page.props.flash?.notice}
      <Alert class="mb-6 border-l-4 border-green-400">
        <div class="flex items-center justify-between">
          <AlertDescription class="text-green-700 font-medium">
            {$page.props.flash.notice}
          </AlertDescription>
          <Button
            variant="ghost"
            size="sm"
            onclick={() => showFlash = false}
            aria-label="Fermer"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Button>
        </div>
      </Alert>
    {/if}

    {#if latest_assessment}
      <!-- Score Card -->
      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />

      <!-- Documents -->
      {#if documents && documents.length > 0}
        <DocumentList {documents} />
      {/if}

    {:else}
      <Card class="text-center p-12">
        <CardHeader>
          <CardTitle class="text-2xl mb-4">Bienvenue sur Monaco RGPD</CardTitle>
        </CardHeader>
        <CardContent>
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
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
            disabled={!questionnaire_id}
            size="lg"
          >
            Commencer l'évaluation
          </Button>
          <p class="text-sm text-gray-500 mt-4">Temps estimé: 15-20 minutes</p>
        </CardContent>
      </Card>
    {/if}
  </div>
</div>
