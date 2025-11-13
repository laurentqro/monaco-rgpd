<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Badge } from '$lib/components/ui/badge'

  let { entries, feature_counts } = $props()

  const featureNames = {
    association: "Association",
    organisme_public: "Organisme public",
    profession_liberale: "Profession libérale",
    video_surveillance: "Vidéosurveillance",
    geographic_expansion: "Expansion géographique"
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Liste d'attente - Vue d'ensemble</h2>
      </div>

      <!-- Feature Demand Dashboard -->
      <div class="bg-white rounded-lg border mb-6 p-6">
        <h3 class="text-base font-semibold mb-4">Demande par fonctionnalité</h3>

        <div class="space-y-3">
          {#each Object.entries(feature_counts) as [key, count]}
            <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
              <span class="font-medium">{featureNames[key] || key}</span>
              <span class="text-2xl font-bold text-blue-600">{count}</span>
            </div>
          {/each}

          {#if Object.keys(feature_counts).length === 0}
            <div class="text-center py-4 text-gray-500">
              Aucune demande pour le moment
            </div>
          {/if}
        </div>
      </div>

      <!-- Recent Entries -->
      <div class="bg-white rounded-lg border p-6">
        <h3 class="text-base font-semibold mb-4">Dernières inscriptions</h3>

        <div class="overflow-hidden rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Email</TableHead>
                <TableHead>Fonctionnalités</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Statut</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {#each entries as entry}
                <TableRow>
                  <TableCell class="font-medium">
                    {entry.email}
                  </TableCell>
                  <TableCell>
                    {#each entry.features_needed as feature}
                      <Badge variant="secondary" class="mr-1">
                        {featureNames[feature] || feature}
                      </Badge>
                    {/each}
                  </TableCell>
                  <TableCell>
                    {new Date(entry.created_at).toLocaleDateString('fr-FR')}
                  </TableCell>
                  <TableCell>
                    {#if entry.notified}
                      <span class="text-green-600 text-sm">✓ Notifié</span>
                    {:else}
                      <span class="text-gray-400 text-sm">En attente</span>
                    {/if}
                  </TableCell>
                </TableRow>
              {/each}
            </TableBody>
          </Table>

          {#if entries.length === 0}
            <div class="text-center py-12 text-gray-500">
              Aucune inscription pour le moment
            </div>
          {/if}
        </div>
      </div>
    </div>
  {/snippet}
</AdminLayout>
