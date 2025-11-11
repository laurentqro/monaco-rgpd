<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';
  import { router } from '@inertiajs/svelte';

  let { questionnaire, response } = $props();

  function startChat() {
    router.post('/conversations', {
      questionnaire_id: questionnaire.id
    });
  }

  function startTraditional() {
    // Already on this page with traditional form
  }
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50 py-12">
    <div class="max-w-4xl mx-auto">
      <div class="mb-8 text-center">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          {questionnaire.title}
        </h1>
        {#if questionnaire.description}
          <p class="text-gray-600">
            {questionnaire.description}
          </p>
        {/if}
      </div>

      <div class="mb-8 flex gap-4 justify-center">
        <button
          onclick={startChat}
          class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center gap-2 cursor-pointer"
        >
          💬 Démarrer en mode conversation
        </button>

        <button
          onclick={startTraditional}
          class="px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 flex items-center gap-2 cursor-pointer"
        >
          📋 Mode formulaire traditionnel
        </button>
      </div>

      <QuestionnaireWizard {questionnaire} {response} />
    </div>
  </div>
</AppLayout>
