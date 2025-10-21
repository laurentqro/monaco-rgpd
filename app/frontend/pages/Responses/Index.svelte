<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import { router } from '@inertiajs/svelte';
  import { Button } from '$lib/components/ui/button';
  import * as Card from '$lib/components/ui/card';
  import * as Table from '$lib/components/ui/table';
  import { Badge } from '$lib/components/ui/badge';

  let { responses } = $props();

  function getStatusText(status) {
    const texts = {
      'in_progress': 'En cours',
      'completed': 'Terminée',
      'draft': 'Brouillon'
    };
    return texts[status] || status;
  }

  function getStatusVariant(status) {
    const variants = {
      'in_progress': 'default',
      'completed': 'success',
      'draft': 'secondary'
    };
    return variants[status] || 'secondary';
  }

  function getRiskLevelText(riskLevel) {
    const texts = {
      'compliant': 'Risque faible',
      'attention_required': 'Risque moyen',
      'non_compliant': 'Risque élevé'
    };
    return texts[riskLevel] || 'Inconnu';
  }

  function getRiskLevelColorClass(riskLevel) {
    // Use complete Tailwind classes for JIT compiler
    return riskLevel === 'compliant' ? 'text-green-600' :
           riskLevel === 'attention_required' ? 'text-yellow-600' :
           riskLevel === 'non_compliant' ? 'text-red-600' :
           'text-gray-600';
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

<AppLayout>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold">Historique des évaluations</h1>
      <Button
        variant="ghost"
        onclick={() => router.visit('/dashboard')}
      >
        <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Retour au tableau de bord
      </Button>
    </div>

    {#if responses.length === 0}
      <Card.Root>
        <Card.Content class="p-12 text-center">
          <p class="text-gray-600 mb-4">Aucune évaluation trouvée</p>
          <Button
            onclick={() => router.visit('/dashboard')}
          >
            Commencer une évaluation
          </Button>
        </Card.Content>
      </Card.Root>
    {:else}
      <Card.Root>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Questionnaire</Table.Head>
                <Table.Head>Statut</Table.Head>
                <Table.Head>Score</Table.Head>
                <Table.Head>Date de création</Table.Head>
                <Table.Head>Date de complétion</Table.Head>
                <Table.Head class="text-right">Actions</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each responses as response (response.id)}
                <Table.Row>
                  <Table.Cell class="font-medium">
                    {response.questionnaire.title}
                  </Table.Cell>
                  <Table.Cell>
                    <Badge variant={getStatusVariant(response.status)}>
                      {getStatusText(response.status)}
                    </Badge>
                  </Table.Cell>
                  <Table.Cell>
                    {#if response.compliance_assessment}
                      <div class="flex items-center gap-2">
                        <span class="text-2xl font-bold {getRiskLevelColorClass(response.compliance_assessment.risk_level)}">
                          {Number(response.compliance_assessment.overall_score).toFixed(1)}%
                        </span>
                        <span class="text-xs text-gray-500">
                          {getRiskLevelText(response.compliance_assessment.risk_level)}
                        </span>
                      </div>
                    {:else if response.status === 'completed'}
                      <span class="text-sm text-gray-500">Calcul en cours...</span>
                    {:else}
                      <span class="text-sm text-gray-400">-</span>
                    {/if}
                  </Table.Cell>
                  <Table.Cell class="text-gray-500">
                    {formatDate(response.started_at)}
                  </Table.Cell>
                  <Table.Cell class="text-gray-500">
                    {formatDate(response.completed_at)}
                  </Table.Cell>
                  <Table.Cell class="text-right">
                    {#if response.status === 'completed' && response.compliance_assessment}
                      <Button
                        variant="link"
                        href="/responses/{response.id}/results"
                        class="mr-2"
                      >
                        Voir les résultats
                      </Button>
                    {/if}
                    {#if response.status === 'in_progress'}
                      <Button
                        variant="link"
                        href="/questionnaires/{response.questionnaire.id}/responses/{response.id}"
                      >
                        Continuer
                      </Button>
                    {/if}
                  </Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>
    {/if}
    </div>
  </div>
</AppLayout>
