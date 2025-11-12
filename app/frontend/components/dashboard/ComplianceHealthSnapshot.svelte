<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import ComplianceAreaCard from './ComplianceAreaCard.svelte';

  let { assessment } = $props();

  let expandedAreas = $state({});
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>État de conformité par domaine</CardTitle>
    <CardDescription>
      Cliquez sur un domaine pour voir les détails
    </CardDescription>
  </CardHeader>
  <CardContent>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each assessment.compliance_area_scores as areaScore (areaScore.id)}
        <ComplianceAreaCard
          {areaScore}
          bind:expanded={expandedAreas[areaScore.id]}
        />
      {/each}
    </div>
  </CardContent>
</Card>
