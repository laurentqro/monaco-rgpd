<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card';
  import ActionItem from './ActionItem.svelte';

  let { actionItems } = $props();

  const groupedItems = $derived(() => {
    const groups = {
      critical: [],
      high: [],
      medium: [],
      low: []
    };

    actionItems.forEach(item => {
      groups[item.priority].push(item);
    });

    return groups;
  });

  const priorityLabels = {
    critical: 'Critique',
    high: 'Haute priorité',
    medium: 'Priorité moyenne',
    low: 'Priorité basse'
  };
</script>

<Card class="mb-8">
  <CardHeader>
    <CardTitle>Actions à réaliser</CardTitle>
    <CardDescription>
      {actionItems.length} action{actionItems.length > 1 ? 's' : ''} recommandée{actionItems.length > 1 ? 's' : ''}
    </CardDescription>
  </CardHeader>
  <CardContent>
    {#if actionItems.length === 0}
      <p class="text-center text-gray-500 py-8">
        Aucune action en attente. Excellent travail !
      </p>
    {:else}
      <div class="space-y-6">
        {#each Object.entries(groupedItems()) as [priority, items]}
          {#if items.length > 0}
            <div>
              <h3 class="text-sm font-semibold text-gray-700 mb-3">
                {priorityLabels[priority]} ({items.length})
              </h3>
              <div class="space-y-3">
                {#each items as item (item.id)}
                  <ActionItem {item} />
                {/each}
              </div>
            </div>
          {/if}
        {/each}
      </div>
    {/if}
  </CardContent>
</Card>
