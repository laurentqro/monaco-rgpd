<script>
  import { onMount, tick } from 'svelte';

  let { messages, isSending = false } = $props();

  let scrollContainer = $state(null);

  async function scrollToBottom() {
    await tick();
    if (scrollContainer) {
      scrollContainer.scrollTop = scrollContainer.scrollHeight;
    }
  }

  $effect(() => {
    if (messages) {
      scrollToBottom();
    }
  });
</script>

<div
  bind:this={scrollContainer}
  class="flex-1 overflow-y-auto p-6 space-y-4"
>
  {#each messages as message (message.id || message.created_at)}
    <div class="flex {message.role === 'user' ? 'justify-end' : 'justify-start'}">
      <div
        class="max-w-2xl rounded-lg px-4 py-3 {message.role === 'user'
          ? 'bg-blue-600 text-white'
          : 'bg-white border border-gray-200 text-gray-900'}"
      >
        <div class="prose prose-sm max-w-none {message.role === 'user' ? 'prose-invert' : ''}">
          {message.content}
        </div>
      </div>
    </div>
  {/each}

  {#if isSending}
    <div class="flex justify-start">
      <div class="bg-white border border-gray-200 rounded-lg px-4 py-3">
        <div class="flex space-x-2">
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0ms"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 150ms"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 300ms"></div>
        </div>
      </div>
    </div>
  {/if}
</div>
