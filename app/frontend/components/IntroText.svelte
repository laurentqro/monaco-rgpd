<script>
  import { marked } from 'marked';
  import DOMPurify from 'dompurify';

  let { content = null } = $props();

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
  <div class="intro-text bg-blue-50 border-l-4 border-blue-400 p-4 mb-6 rounded-r">
    <div class="prose prose-sm max-w-none text-gray-700">
      {@html html}
    </div>
  </div>
{/if}

<style>
  /* Ensure prose styles work within our scoped component */
  .intro-text :global(p) {
    margin-bottom: 0.5rem;
  }

  .intro-text :global(p:last-child) {
    margin-bottom: 0;
  }

  .intro-text :global(ul),
  .intro-text :global(ol) {
    margin: 0.5rem 0;
  }

  .intro-text :global(strong) {
    font-weight: 600;
  }

  .intro-text :global(a) {
    color: #2563eb;
    text-decoration: underline;
  }
</style>
