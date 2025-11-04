<script>
  import { Button } from '$lib/components/ui/button';
  import { Check } from 'lucide-svelte';

  let { suggestedButtons, onSelect, disabled = false } = $props();

  let selectedChoiceId = $state(null);

  function handleClick(button) {
    if (disabled || selectedChoiceId) return;

    selectedChoiceId = button.choice_id;
    onSelect(button);
  }
</script>

<div class="flex flex-col gap-2 mt-3">
  {#each suggestedButtons.buttons as button (button.choice_id)}
    <Button
      onclick={() => handleClick(button)}
      variant={selectedChoiceId === button.choice_id ? "default" : "outline"}
      disabled={disabled || (selectedChoiceId && selectedChoiceId !== button.choice_id)}
      class="w-full justify-start text-left h-auto py-3 px-4 transition-all {
        selectedChoiceId === button.choice_id && button.label === 'Oui'
          ? 'bg-green-600 hover:bg-green-700'
          : ''
      } {
        selectedChoiceId === button.choice_id && button.label === 'Non'
          ? 'bg-red-600 hover:bg-red-700'
          : ''
      }"
    >
      <span class="flex items-center gap-2 w-full">
        {button.label}
        {#if selectedChoiceId === button.choice_id}
          <Check class="ml-auto h-5 w-5" />
        {/if}
      </span>
    </Button>
  {/each}
</div>

<style>
  /* Ensure disabled buttons are visually muted */
  :global(button:disabled) {
    opacity: 0.5;
    cursor: not-allowed;
  }
</style>
