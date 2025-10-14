<script>
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';

  let { response, questionnaire } = $props();
</script>

<div class="min-h-screen bg-gray-50 py-12">
  <QuestionnaireWizard {questionnaire} {response} />
</div>
