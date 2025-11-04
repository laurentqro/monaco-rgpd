<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { toast } from 'svelte-sonner'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { FileText } from '@lucide/svelte'
  import ProfileCompletionModal from './ProfileCompletionModal.svelte'

  let { available_documents = [], account_complete = false } = $props()

  let showProfileModal = $state(false)
  let pendingDocumentType = $state(null)

  function handleGenerateDocument(docType) {
    if (!account_complete) {
      pendingDocumentType = docType
      showProfileModal = true
      return
    }

    generateDocument(docType)
  }

  async function generateDocument(docType) {
    try {
      const response = await fetch(`/documents/${docType}`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
          'Accept': 'application/pdf'
        }
      })

      if (!response.ok) {
        const error = await response.json()

        if (error.error === 'incomplete_profile') {
          showProfileModal = true
        } else if (error.error === 'no_completed_questionnaire') {
          toast.error('Veuillez compléter le questionnaire avant de générer des documents.')
        } else {
          toast.error('Une erreur est survenue lors de la génération du document.')
        }
        return
      }

      // Handle successful PDF download
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url

      // Extract filename from Content-Disposition header or use default
      const contentDisposition = response.headers.get('Content-Disposition')
      const filename = contentDisposition?.match(/filename="(.+)"/)?.[1] || 'document.pdf'
      a.download = filename

      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)

      toast.success('Document généré avec succès')
    } catch (error) {
      console.error('Download error:', error)
      toast.error('Une erreur est survenue lors du téléchargement.')
    }
  }

  function onProfileCompleted() {
    showProfileModal = false
    account_complete = true
    if (pendingDocumentType) {
      generateDocument(pendingDocumentType)
      pendingDocumentType = null
    }
  }
</script>

<AppLayout>
  <div class="flex flex-col gap-6">
    <div>
      <h1 class="text-3xl font-bold tracking-tight">Documents</h1>
      <p class="text-muted-foreground mt-2">
        Générez vos documents de conformité RGPD
      </p>
    </div>

    {#if available_documents.length === 0}
      <Card>
        <CardContent class="flex flex-col items-center justify-center py-12">
          <div class="flex size-12 items-center justify-center rounded-full bg-muted mb-4">
            <FileText class="size-6 text-muted-foreground" />
          </div>
          <h3 class="text-lg font-semibold mb-2">Aucun document disponible</h3>
          <p class="text-sm text-muted-foreground text-center max-w-md">
            Complétez le questionnaire pour générer vos documents de conformité.
          </p>
        </CardContent>
      </Card>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each available_documents as doc}
          <Card class="hover:shadow-lg transition-shadow cursor-pointer"
                onclick={() => handleGenerateDocument(doc.type)}>
            <CardHeader>
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                  </svg>
                </div>
                <CardTitle class="text-lg">{doc.title}</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              <CardDescription>{doc.description}</CardDescription>
              <Button variant="outline" class="mt-4 w-full">
                Télécharger le PDF
              </Button>
            </CardContent>
          </Card>
        {/each}
      </div>
    {/if}
  </div>

  <ProfileCompletionModal
    bind:open={showProfileModal}
    oncompleted={onProfileCompleted}
    oncancel={() => showProfileModal = false}
  />
</AppLayout>
