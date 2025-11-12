<script>
  import { Button } from '$lib/components/ui/button';
  import { Badge } from '$lib/components/ui/badge';
  import { router } from '@inertiajs/svelte';

  let { item } = $props();

  const priorityVariants = {
    critical: 'destructive',
    high: 'destructive',
    medium: 'secondary',
    low: 'outline'
  };

  const priorityLabels = {
    critical: 'Critique',
    high: 'Haute',
    medium: 'Moyenne',
    low: 'Basse'
  };

  function markAsCompleted() {
    router.patch(`/action_items/${item.id}`, {
      action_item: { status: 'completed' }
    });
  }

  function dismiss() {
    router.patch(`/action_items/${item.id}`, {
      action_item: { status: 'dismissed' }
    });
  }
</script>

<div class="action-item flex items-start justify-between p-4 border rounded-lg bg-white">
  <div class="flex-1">
    <div class="flex items-center gap-2 mb-2">
      <Badge variant={priorityVariants[item.priority]}>
        {priorityLabels[item.priority]}
      </Badge>
      {#if item.impact_score}
        <span class="text-sm text-gray-500">Impact: +{item.impact_score}%</span>
      {/if}
    </div>

    <h3 class="font-semibold mb-1">{item.title}</h3>
    {#if item.description}
      <p class="text-sm text-gray-600 mb-2">{item.description}</p>
    {/if}

    {#if item.due_at}
      <p class="text-xs text-gray-500">
        Échéance: {new Date(item.due_at).toLocaleDateString('fr-FR')}
      </p>
    {/if}
  </div>

  <div class="flex gap-2 ml-4">
    <Button size="sm" onclick={markAsCompleted}>
      Terminé
    </Button>
    <Button size="sm" variant="ghost" onclick={dismiss}>
      Ignorer
    </Button>
  </div>
</div>
