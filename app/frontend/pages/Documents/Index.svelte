<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import DocumentList from '@/components/DocumentList.svelte'
  import { Card, CardContent } from '$lib/components/ui/card'
  import { Badge } from '$lib/components/ui/badge'
  import { FileText } from '@lucide/svelte'

  let { documents = [], latest_assessment = null } = $props()
</script>

<AppLayout>
  <div class="flex flex-col gap-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Documents</h1>
        <p class="text-muted-foreground mt-1">
          Documents générés depuis votre dernière évaluation
        </p>
      </div>
      {#if latest_assessment}
        <div class="flex items-center gap-2">
          <span class="text-sm text-muted-foreground">Score de conformité:</span>
          <Badge variant="secondary" class="text-base">
            {latest_assessment.overall_score}%
          </Badge>
        </div>
      {/if}
    </div>

    {#if documents.length === 0}
      <Card>
        <CardContent class="flex flex-col items-center justify-center py-12">
          <div class="flex size-12 items-center justify-center rounded-full bg-muted mb-4">
            <FileText class="size-6 text-muted-foreground" />
          </div>
          <h3 class="text-lg font-semibold mb-2">Aucun document disponible</h3>
          <p class="text-sm text-muted-foreground text-center max-w-md">
            Les documents seront générés automatiquement après avoir complété
            votre évaluation de conformité.
          </p>
        </CardContent>
      </Card>
    {:else}
      <DocumentList {documents} />
    {/if}
  </div>
</AppLayout>
