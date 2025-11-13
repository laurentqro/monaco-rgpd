<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import * as Table from '$lib/components/ui/table'
  import { Button } from '$lib/components/ui/button'
  import { Badge } from '$lib/components/ui/badge'

  let { activity } = $props()

  function downloadPDF() {
    window.location.href = `/registre-traitements/${activity.id}.pdf`
  }
</script>

<AppLayout title={activity?.name || 'Activité de traitement'}>
  <div class="min-h-screen bg-muted">
    <div class="max-w-7xl mx-auto px-4 py-8">
      <!-- Header with back button -->
      <div class="mb-8 flex justify-between items-start">
        <div>
          <Button
            variant="ghost"
            onclick={() => router.visit('/registre-traitements')}
            class="mb-4"
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            Retour à la liste
          </Button>
          <p class="text-muted-foreground">{activity.description}</p>
        </div>
        <Button onclick={downloadPDF}>
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Télécharger en PDF
        </Button>
      </div>

      <!-- Finalités -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Finalité(s)</h2>
        <div class="border border-border rounded-lg overflow-hidden">
          <Table.Root>
            <Table.Header>
              <Table.Row class="bg-muted hover:bg-muted">
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Finalité(s)</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Détail</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-border whitespace-normal">Base(s) juridique(s)</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body class="bg-background">
              {#each activity.processing_purposes as purpose (purpose.purpose_number)}
                <Table.Row>
                  <Table.Cell class="font-medium border-r border-border whitespace-normal">Finalité {purpose.purpose_number}</Table.Cell>
                  <Table.Cell class="border-r border-border whitespace-normal">{purpose.purpose_detail}</Table.Cell>
                  <Table.Cell class="whitespace-normal">{purpose.legal_basis_text}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>

      <!-- Metadata sections -->
      <div class="mb-8 bg-background border border-border rounded-lg p-6">
        <div class="space-y-4">
          <div class="flex border-b pb-4">
            <div class="flex-1 font-semibold">Le traitement est-il mis en œuvre à des fins de surveillance ?</div>
            <div class="flex-1">
              <Badge variant={activity.surveillance_purpose ? "destructive" : "secondary"}>
                {activity.surveillance_purpose ? "OUI" : "NON"}
              </Badge>
            </div>
          </div>

          <div class="flex border-b pb-4">
            <div class="flex-1 font-semibold">Catégorie(s) de personnes concernées</div>
            <div class="flex-1">{activity.data_subjects.join(', ')}</div>
          </div>

          <div class="flex pb-4">
            <div class="flex-1 font-semibold">Collectez-vous des données sensibles ?</div>
            <div class="flex-1">
              <Badge variant={activity.sensitive_data ? "destructive" : "secondary"}>
                {activity.sensitive_data ? "OUI" : "NON"}
              </Badge>
            </div>
          </div>
        </div>
      </div>

      <!-- Data Categories -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Autres catégories de données</h2>
        <div class="border border-border rounded-lg overflow-hidden">
          <Table.Root>
            <Table.Header>
              <Table.Row class="bg-muted hover:bg-muted">
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Catégories de données</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Détail</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Durée(s) de conservation</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-border whitespace-normal">Source(s)</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body class="bg-background">
              {#each activity.data_category_details as category, i (i)}
                <Table.Row>
                  <Table.Cell class="font-medium border-r border-border whitespace-normal">{category.category_type_text}</Table.Cell>
                  <Table.Cell class="border-r border-border whitespace-normal">{category.detail}</Table.Cell>
                  <Table.Cell class="border-r border-border whitespace-normal">{category.retention_period}</Table.Cell>
                  <Table.Cell class="whitespace-normal">{category.data_source}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>

      <!-- Access Categories -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Catégories de personnes ayant accès aux données</h2>
        <div class="border border-border rounded-lg overflow-hidden">
          <Table.Root>
            <Table.Header>
              <Table.Row class="bg-muted hover:bg-muted">
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Catégories de personnes ayant accès aux données</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Détail</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-border whitespace-normal">Localisation des personnes</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body class="bg-background">
              {#each activity.access_categories as category (category.category_number)}
                <Table.Row>
                  <Table.Cell class="font-medium border-r border-border whitespace-normal">Catégorie {category.category_number}</Table.Cell>
                  <Table.Cell class="border-r border-border whitespace-normal">{category.detail}</Table.Cell>
                  <Table.Cell class="whitespace-normal">{category.location}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>

      <!-- Recipient Categories -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Catégorie(s) de personnes habilitées à recevoir communication des données</h2>
        <div class="border border-border rounded-lg overflow-hidden">
          <Table.Root>
            <Table.Header>
              <Table.Row class="bg-muted hover:bg-muted">
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Catégorie(s) de personnes habilitées à recevoir communication des données</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Détail</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-border whitespace-normal">Localisation des personnes</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body class="bg-background">
              {#each activity.recipient_categories as recipient (recipient.recipient_number)}
                <Table.Row>
                  <Table.Cell class="font-medium border-r border-border whitespace-normal">Destinataire {recipient.recipient_number}</Table.Cell>
                  <Table.Cell class="border-r border-border whitespace-normal">{recipient.detail}</Table.Cell>
                  <Table.Cell class="whitespace-normal">{recipient.location}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>

      <!-- Security -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Sécurité</h2>
        <div class="border border-border rounded-lg overflow-hidden">
          <Table.Root>
            <Table.Header>
              <Table.Row class="bg-muted hover:bg-muted">
                <Table.Head class="font-bold text-foreground border-b border-r border-border whitespace-normal">Sécurité</Table.Head>
                <Table.Head class="font-bold text-foreground border-b border-border whitespace-normal">Référence(s) documents</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body class="bg-background">
              {#each activity.security_measures as securityMeasure, i (i)}
                <Table.Row>
                  <Table.Cell class="border-r border-border whitespace-normal">
                    {typeof securityMeasure === 'string' ? securityMeasure : securityMeasure.measure}
                  </Table.Cell>
                  <Table.Cell class="whitespace-normal">
                    {typeof securityMeasure === 'string' ? 'Politique de sécurité' : securityMeasure.reference_documents}
                  </Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>

      <!-- Final Information -->
      <div class="mb-8">
        <h2 class="text-xl font-bold mb-4">Informations complémentaires</h2>
        <div class="bg-background border border-border rounded-lg p-6">
          <div class="space-y-4">
            <div class="flex border-b pb-4">
              <div class="flex-1 font-semibold">Transfert de données vers un pays ne disposant pas d'un niveau de protection adéquat</div>
              <div class="flex-1">
                <Badge variant={activity.inadequate_protection_transfer ? "destructive" : "secondary"}>
                  {activity.inadequate_protection_transfer ? "OUI" : "NON"}
                </Badge>
              </div>
            </div>

            <div class="flex border-b pb-4">
              <div class="flex-1 font-semibold">Modalité(s) d'information préalable des personnes concernées</div>
              <div class="flex-1">{activity.information_modalities}</div>
            </div>

            <div class="flex border-b pb-4">
              <div class="flex-1 font-semibold">Droits des personnes concernées</div>
              <div class="flex-1">
                <ul class="list-disc list-inside">
                  {#each activity.individual_rights as right, i (i)}
                    <li>{right}</li>
                  {/each}
                </ul>
              </div>
            </div>

            <div class="flex border-b pb-4">
              <div class="flex-1 font-semibold">Profilage (uniquement traitements de l'article 64)</div>
              <div class="flex-1">
                <Badge variant={activity.profiling ? "destructive" : "secondary"}>
                  {activity.profiling ? "OUI" : "NON"}
                </Badge>
              </div>
            </div>

            <div class="flex">
              <div class="flex-1 font-semibold">Avez-vous effectué une analyse d'impact ?</div>
              <div class="flex-1">
                <Badge variant={activity.impact_assessment_required ? "default" : "secondary"}>
                  {activity.impact_assessment_required ? "OUI" : "NON"}
                </Badge>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</AppLayout>
