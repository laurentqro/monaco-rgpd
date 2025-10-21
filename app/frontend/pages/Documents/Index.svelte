<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import DocumentList from '@/components/DocumentList.svelte'
  import { Card, CardContent } from '$lib/components/ui/card'
  import { FileText } from '@lucide/svelte'

  let { documents = [] } = $props()
</script>

<AppLayout>
  <div class="flex flex-col gap-6">
    <div>
      <h1 class="text-3xl font-bold tracking-tight">Documents</h1>
      <p class="text-muted-foreground mt-1">
        Gérez et téléchargez vos documents de conformité RGPD
      </p>
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
