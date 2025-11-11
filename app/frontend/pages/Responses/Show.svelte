<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';
  import * as Card from '$lib/components/ui/card';

  let { response, questionnaire } = $props();
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50">
    <QuestionnaireWizard {questionnaire} {response} />
  </div>
</AppLayout>
