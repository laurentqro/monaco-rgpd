<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';

  let { questionnaire, response } = $props();
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

      <QuestionnaireWizard {questionnaire} {response} />
    </div>
  </div>
</AppLayout>
