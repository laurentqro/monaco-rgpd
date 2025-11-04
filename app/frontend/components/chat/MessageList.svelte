<script>
  import { onMount, tick } from 'svelte';
  import { marked } from 'marked';
  import DOMPurify from 'dompurify';

  let { messages, isSending = false } = $props();

  let scrollContainer = $state(null);

  // Configure marked for clean output
  marked.setOptions({
    breaks: true,       // Convert \n to <br>
    gfm: true,          // GitHub Flavored Markdown
    headerIds: false,   // Don't generate header IDs
    mangle: false       // Don't mangle email addresses
  });

  function renderMessage(content, role) {
    // Only parse markdown for assistant messages
    if (role === 'assistant') {
      return DOMPurify.sanitize(marked.parse(content));
    }
    // User messages are plain text
    return content;
  }

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
          {#if message.role === 'assistant'}
            {@html renderMessage(message.content, message.role)}
          {:else}
            {message.content}
          {/if}
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

<style>
  /* Style markdown content in assistant messages */
  .prose :global(ul),
  .prose :global(ol) {
    margin: 0.5rem 0;
    padding-left: 1.5rem;
  }

  .prose :global(ul) {
    list-style-type: disc;
  }

  .prose :global(ol) {
    list-style-type: decimal;
  }

  .prose :global(li) {
    margin-bottom: 0.25rem;
  }

  .prose :global(p) {
    margin-bottom: 0.5rem;
  }

  .prose :global(p:last-child) {
    margin-bottom: 0;
  }

  .prose :global(strong) {
    font-weight: 600;
  }

  .prose :global(em) {
    font-style: italic;
  }

  .prose :global(code) {
    background-color: rgba(0, 0, 0, 0.05);
    padding: 0.125rem 0.25rem;
    border-radius: 0.25rem;
    font-size: 0.875em;
  }

  /* Invert colors for user messages */
  .prose-invert :global(code) {
    background-color: rgba(255, 255, 255, 0.2);
  }
</style>
