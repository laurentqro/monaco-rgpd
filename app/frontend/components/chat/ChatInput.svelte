<script>
  let { onSend, disabled = false } = $props();

  let inputValue = $state('');

  function handleSubmit() {
    if (inputValue.trim() && !disabled) {
      onSend(inputValue.trim());
      inputValue = '';
    }
  }

  function handleKeydown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  }
</script>

<div class="border-t bg-white p-4">
  <div class="flex gap-2">
    <textarea
      bind:value={inputValue}
      onkeydown={handleKeydown}
      placeholder="Tapez votre réponse..."
      {disabled}
      rows="1"
      class="flex-1 resize-none rounded-lg border border-gray-300 px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50"
    ></textarea>

    <button
      onclick={handleSubmit}
      disabled={disabled || !inputValue.trim()}
      class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
    >
      Envoyer
    </button>
  </div>
</div>
