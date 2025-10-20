<script>
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';
  import * as Card from '$lib/components/ui/card';

  let { response, questionnaire } = $props();
</script>

<div class="min-h-screen bg-gray-50 py-12">
  <QuestionnaireWizard {questionnaire} {response} />
</div>
