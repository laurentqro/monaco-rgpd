<script>
  import { Popover, PopoverTrigger, PopoverContent } from '$lib/components/ui/popover';
  import { marked } from 'marked';
  import DOMPurify from 'dompurify';

  let { content } = $props();

  // Configure marked for safe rendering
  marked.setOptions({
    breaks: true,
    gfm: true,
    headerIds: false,
    mangle: false
  });

  const helpHtml = $derived(
    content ? DOMPurify.sanitize(marked.parse(content)) : ''
  );
</script>

<Popover>
  <PopoverTrigger class="inline-flex items-center justify-center rounded-full w-5 h-5 text-amber-600 hover:bg-amber-100 transition-colors ml-2">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM8.94 6.94a.75.75 0 11-1.061-1.061 3 3 0 112.871 5.026v.345a.75.75 0 01-1.5 0v-.5c0-.72.57-1.172 1.081-1.287A1.5 1.5 0 108.94 6.94zM10 15a1 1 0 100-2 1 1 0 000 2z" clip-rule="evenodd" />
    </svg>
  </PopoverTrigger>
  <PopoverContent class="bg-amber-50 border-amber-200 w-80 max-w-[calc(100vw-2rem)]" align="start">
    <div class="text-sm text-amber-900 help-content">
      {@html helpHtml}
    </div>
  </PopoverContent>
</Popover>

<style>
  /* Style markdown content in help popover */
  .help-content :global(p) {
    margin-bottom: 0.5rem;
    line-height: 1.5;
  }

  .help-content :global(p:last-child) {
    margin-bottom: 0;
  }

  .help-content :global(ul),
  .help-content :global(ol) {
    margin: 0.5rem 0;
    padding-left: 1.5rem;
    line-height: 1.5;
  }

  .help-content :global(ul) {
    list-style-type: disc;
  }

  .help-content :global(ol) {
    list-style-type: decimal;
  }

  .help-content :global(li) {
    margin-bottom: 0.25rem;
  }

  .help-content :global(strong) {
    font-weight: 600;
  }

  .help-content :global(a) {
    color: #d97706;
    text-decoration: underline;
  }
</style>
