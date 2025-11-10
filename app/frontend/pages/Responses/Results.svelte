<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import { router } from '@inertiajs/svelte';
  import DocumentList from '../../components/DocumentList.svelte';
  import { Button } from '$lib/components/ui/button';
  import * as Card from '$lib/components/ui/card';
  import { Progress } from '$lib/components/ui/progress';
  import { Badge } from '$lib/components/ui/badge';

  let { response, assessment, documents, answers } = $props();

  function getAnswerDisplay(answer) {
    const { question_type, answer_value, answer_choices } = answer;

    switch (question_type) {
      case 'yes_no':
      case 'single_choice':
        const choiceId = answer_value?.choice_id;
        if (choiceId) {
          const choice = answer_choices.find(ac => ac.id === choiceId);
          return choice ? choice.choice_text : '-';
        }
        return '-';

      case 'multiple_choice':
        const choiceIds = answer_value?.choice_ids || [];
        const selectedChoices = answer_choices.filter(ac => choiceIds.includes(ac.id));
        return selectedChoices.map(c => c.choice_text).join(', ') || '-';

      case 'text_short':
      case 'text_long':
        return answer_value?.text || '-';

      case 'rating_scale':
        return answer_value?.rating ? `${answer_value.rating} / 5` : '-';

      default:
        return '-';
    }
  }

  // Group answers by section
  const answersBySection = $derived(() => {
    const sections = {};
    answers.forEach(answer => {
      if (!sections[answer.section_title]) {
        sections[answer.section_title] = [];
      }
      sections[answer.section_title].push(answer);
    });
    return sections;
  });
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-5xl mx-auto px-4">
    <!-- Header -->
    <div class="mb-8">
      <Button
        variant="ghost"
        onclick={() => router.visit('/dashboard')}
        class="mb-4"
      >
        <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Retour au tableau de bord
      </Button>
      <h1 class="text-3xl font-bold text-gray-900">Détails de l'évaluation</h1>
      <p class="text-gray-600 mt-2">
        {response.questionnaire.title} • Complétée le {new Date(response.completed_at).toLocaleDateString('fr-FR', { year: 'numeric', month: 'long', day: 'numeric' })}
      </p>
    </div>

    <!-- Score Summary Card with Progress -->
    {#if assessment}
      <Card.Root class="mb-8">
        <Card.Content class="p-6">
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h2 class="text-lg font-medium text-gray-600 mb-3">Score de conformité</h2>
              <div class="flex items-baseline space-x-2 mb-4">
                <span class="text-3xl font-bold text-blue-600">{Number(assessment.overall_score).toFixed(1)}%</span>
                <span class="text-gray-500">/ 100%</span>
              </div>
              <Progress value={assessment.overall_score} class="h-3" />
            </div>
            {#if documents && documents.length > 0}
              <Button
                variant="secondary"
                onclick={() => document.querySelector('#documents')?.scrollIntoView({ behavior: 'smooth' })}
                class="ml-6"
              >
                Voir les documents ({documents.length})
              </Button>
            {/if}
          </div>
        </Card.Content>
      </Card.Root>
    {/if}

    <!-- Answers by Section -->
    <div class="space-y-6">
      {#each Object.entries(answersBySection()) as [sectionTitle, sectionAnswers]}
        <Card.Root>
          <Card.Header>
            <Card.Title class="text-xl">{sectionTitle}</Card.Title>
          </Card.Header>
          <Card.Content class="space-y-6">
            {#each sectionAnswers as answer, index}
              <div class="pb-6 {index < sectionAnswers.length - 1 ? 'border-b border-gray-200' : ''}">
                <h3 class="font-medium text-gray-900 mb-2">
                  {answer.question_text}
                </h3>
                <div class="pl-4 py-2 bg-gray-50 rounded-lg">
                  <p class="text-gray-700">{getAnswerDisplay(answer)}</p>
                </div>
              </div>
            {/each}
          </Card.Content>
        </Card.Root>
      {/each}
    </div>

    <!-- Documents Section -->
    {#if documents && documents.length > 0}
      <div id="documents" class="mt-8">
        <DocumentList {documents} />
      </div>
    {/if}
    </div>
  </div>
</AppLayout>
