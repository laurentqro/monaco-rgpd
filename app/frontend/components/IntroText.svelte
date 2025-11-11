<script>
  import { marked } from 'marked';
  import DOMPurify from 'dompurify';

  let { content = null, variant = 'boxed' } = $props();

  // Configure marked for safe rendering
  marked.setOptions({
    breaks: true,      // Convert \n to <br>
    gfm: true,         // GitHub flavored markdown
    headerIds: false,  // Don't generate header IDs
    mangle: false      // Don't mangle email addresses
  });

  const html = $derived(
    content ? DOMPurify.sanitize(marked.parse(content)) : ''
  );
</script>

{#if content}
  {#if variant === 'plain'}
    <div class="intro-text-plain text-sm text-gray-700 mb-6 text-center">
      {@html html}
    </div>
  {:else}
    <div class="intro-text bg-blue-50 border-l-4 border-blue-400 p-4 mb-6 rounded-r text-center">
      <div class="text-sm text-gray-700">
        {@html html}
      </div>
    </div>
  {/if}
{/if}

<style>
  /* Ensure consistent styling for markdown content in both variants */
  .intro-text :global(p),
  .intro-text-plain :global(p) {
    margin-bottom: 0.5rem;
    font-size: 0.875rem; /* text-sm */
    line-height: 1.25rem;
  }

  .intro-text :global(p:last-child),
  .intro-text-plain :global(p:last-child) {
    margin-bottom: 0;
  }

  .intro-text :global(ul),
  .intro-text :global(ol),
  .intro-text-plain :global(ul),
  .intro-text-plain :global(ol) {
    margin: 0.5rem 0;
    padding-left: 1.5rem;
    font-size: 0.875rem; /* text-sm */
    line-height: 1.25rem;
  }

  .intro-text :global(ul),
  .intro-text-plain :global(ul) {
    list-style-type: disc;
  }

  .intro-text :global(ol),
  .intro-text-plain :global(ol) {
    list-style-type: decimal;
  }

  .intro-text :global(li),
  .intro-text-plain :global(li) {
    margin-bottom: 0.25rem;
  }

  .intro-text :global(strong),
  .intro-text-plain :global(strong) {
    font-weight: 600;
  }

  .intro-text :global(a),
  .intro-text-plain :global(a) {
    color: #2563eb;
    text-decoration: underline;
  }
</style>
