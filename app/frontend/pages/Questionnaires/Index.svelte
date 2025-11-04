<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '$lib/components/ui/card'
  import { Badge } from '$lib/components/ui/badge'
  import { ClipboardList, ChevronRight } from '@lucide/svelte'

  let { questionnaires = [] } = $props()

  function startQuestionnaire(questionnaireId) {
    router.post(`/questionnaires/${questionnaireId}/responses`)
  }

  function startChat(questionnaireId) {
    router.post('/conversations', {
      questionnaire_id: questionnaireId
    })
  }
</script>

<AppLayout>
  <div class="flex flex-col gap-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Questionnaires</h1>
        <p class="text-muted-foreground mt-1">
          Évaluez votre conformité RGPD avec nos questionnaires guidés
        </p>
      </div>
    </div>

    {#if questionnaires.length === 0}
      <Card>
        <CardContent class="flex flex-col items-center justify-center py-12">
          <div class="flex size-12 items-center justify-center rounded-full bg-muted mb-4">
            <ClipboardList class="size-6 text-muted-foreground" />
          </div>
          <h3 class="text-lg font-semibold mb-2">Aucun questionnaire disponible</h3>
          <p class="text-sm text-muted-foreground text-center max-w-md">
            Les questionnaires de conformité seront bientôt disponibles pour vous aider
            à évaluer votre niveau de conformité RGPD.
          </p>
        </CardContent>
      </Card>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each questionnaires as questionnaire (questionnaire.id)}
          <Card class="flex flex-col">
            <CardHeader>
              <div class="flex items-start justify-between">
                <div class="flex size-10 items-center justify-center rounded-lg bg-primary/10">
                  <ClipboardList class="size-5 text-primary" />
                </div>
                <Badge variant="secondary">
                  {questionnaire.sections?.length || 0} sections
                </Badge>
              </div>
              <CardTitle class="mt-4">{questionnaire.title}</CardTitle>
              <CardDescription>{questionnaire.description}</CardDescription>
            </CardHeader>
            <CardFooter class="mt-auto flex-col gap-2">
              <Button
                class="w-full"
                onclick={() => startChat(questionnaire.id)}
              >
                💬 Mode conversation
              </Button>
              <Button
                variant="outline"
                class="w-full"
                onclick={() => startQuestionnaire(questionnaire.id)}
              >
                📋 Mode formulaire
                <ChevronRight class="ml-2 size-4" />
              </Button>
            </CardFooter>
          </Card>
        {/each}
      </div>
    {/if}
  </div>
</AppLayout>
