<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import * as Card from '$lib/components/ui/card'
  import { Button } from '$lib/components/ui/button'

  let { activities = [] } = $props()

  function formatDate(dateString) {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold mb-2">Registre des traitements</h1>
        <p class="text-gray-600">
          Gérez vos activités de traitement conformément à l'article 27 de la Loi n° 1.565 relative à la protection des données personnelles
        </p>
      </div>

      {#if activities.length === 0}
        <Card.Root>
          <Card.Header>
            <Card.Title>Aucune activité de traitement</Card.Title>
            <Card.Description>
              Les activités de traitement sont générées automatiquement lorsque vous complétez le questionnaire.
            </Card.Description>
          </Card.Header>
          <Card.Content>
            <Button onclick={() => router.visit('/dashboard')}>
              Commencer une évaluation
            </Button>
          </Card.Content>
        </Card.Root>
      {:else}
        <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {#each activities as activity (activity.id)}
            <Card.Root class="hover:shadow-lg transition-shadow cursor-pointer" onclick={() => router.visit(`/registre-traitements/${activity.id}`)}>
              <Card.Header>
                <Card.Title class="text-xl">{activity.name}</Card.Title>
                <Card.Description class="text-sm">
                  Créé le {formatDate(activity.created_at)}
                </Card.Description>
              </Card.Header>
              <Card.Content>
                <p class="text-sm text-gray-600 mb-4">{activity.description}</p>
                <div class="flex items-center gap-2 text-sm text-gray-500">
                  <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                  </svg>
                  <span>{activity.purposes_count} finalité{activity.purposes_count > 1 ? 's' : ''}</span>
                </div>
              </Card.Content>
            </Card.Root>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</AppLayout>
