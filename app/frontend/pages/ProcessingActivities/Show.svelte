<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import * as Card from '$lib/components/ui/card'
  import * as Table from '$lib/components/ui/table'
  import { Button } from '$lib/components/ui/button'
  import { Badge } from '$lib/components/ui/badge'

  let { activity } = $props()

  function downloadPDF() {
    window.location.href = `/registre-traitements/${activity.id}.pdf`
  }
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50">
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
          <h1 class="text-3xl font-bold mb-2">{activity.name}</h1>
          <p class="text-gray-600">{activity.description}</p>
        </div>
        <Button onclick={downloadPDF}>
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Télécharger en PDF
        </Button>
      </div>

      <!-- Finalités -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Finalité(s)</Card.Title>
        </Card.Header>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Finalité(s)</Table.Head>
                <Table.Head>Détail</Table.Head>
                <Table.Head>Base(s) juridique(s)</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each activity.processing_purposes as purpose}
                <Table.Row>
                  <Table.Cell class="font-medium">Finalité {purpose.purpose_number}</Table.Cell>
                  <Table.Cell>{purpose.purpose_detail}</Table.Cell>
                  <Table.Cell>{purpose.legal_basis_text}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>

      <!-- Metadata sections -->
      <Card.Root class="mb-6">
        <Card.Content class="p-6">
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
        </Card.Content>
      </Card.Root>

      <!-- Data Categories -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Autre(s)) catégorie(s) de données</Card.Title>
        </Card.Header>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>(Autre(s)) catégorie(s) de données</Table.Head>
                <Table.Head>Détail</Table.Head>
                <Table.Head>Durée(s) de conservation</Table.Head>
                <Table.Head>Source(s)</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each activity.data_category_details as category}
                <Table.Row>
                  <Table.Cell class="font-medium">{category.category_type_text}</Table.Cell>
                  <Table.Cell>{category.detail}</Table.Cell>
                  <Table.Cell>{category.retention_period}</Table.Cell>
                  <Table.Cell>{category.data_source}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>

      <!-- Access Categories -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Catégorie(s) de personnes ayant accès aux données</Card.Title>
        </Card.Header>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Catégorie(s) de personnes ayant accès aux données</Table.Head>
                <Table.Head>Détail</Table.Head>
                <Table.Head>Localisation des personnes</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each activity.access_categories as category}
                <Table.Row>
                  <Table.Cell class="font-medium">Catégorie {category.category_number}</Table.Cell>
                  <Table.Cell>{category.detail}</Table.Cell>
                  <Table.Cell>{category.location}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>

      <!-- Recipient Categories -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Catégorie(s) de personnes habilitées à recevoir communication des données</Card.Title>
        </Card.Header>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Catégorie(s) de personnes habilitées à recevoir communication des données</Table.Head>
                <Table.Head>Détail</Table.Head>
                <Table.Head>Localisation des personnes</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each activity.recipient_categories as recipient}
                <Table.Row>
                  <Table.Cell class="font-medium">Destinataire {recipient.recipient_number}</Table.Cell>
                  <Table.Cell>{recipient.detail}</Table.Cell>
                  <Table.Cell>{recipient.location}</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>

      <!-- Security -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Sécurité</Card.Title>
        </Card.Header>
        <Card.Content class="p-0">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Sécurité</Table.Head>
                <Table.Head>Référence(s) documents</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each activity.security_measures as measure}
                <Table.Row>
                  <Table.Cell>{measure}</Table.Cell>
                  <Table.Cell>Politique de sécurité</Table.Cell>
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>

      <!-- Final Information -->
      <Card.Root class="mb-6">
        <Card.Header>
          <Card.Title>Informations complémentaires</Card.Title>
        </Card.Header>
        <Card.Content>
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
                  {#each activity.individual_rights as right}
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
        </Card.Content>
      </Card.Root>
    </div>
  </div>
</AppLayout>
