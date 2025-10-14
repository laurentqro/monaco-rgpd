<script>
  import QuestionCard from './QuestionCard.svelte';
  import { router } from '@inertiajs/svelte';

  let { questionnaire, response } = $props();

  let currentQuestionIndex = $state(0);
  let answers = $state({});
  let skippedSections = $state(new Set());

  // Flatten all questions from all sections with section info
  const allQuestions = questionnaire.sections.flatMap(s =>
    s.questions.map(q => ({ ...q, sectionId: s.id, sectionTitle: s.title }))
  );

  // Evaluate logic rules and determine which sections to skip
  function evaluateLogicRules() {
    const newSkippedSections = new Set();

    allQuestions.forEach(question => {
      const answer = answers[question.id];
      if (!answer) return;

      question.logic_rules?.forEach(rule => {
        const shouldSkip = checkCondition(answer, rule.condition_type, rule.condition_value);

        if (shouldSkip && rule.action === 'skip_to_section' && rule.target_section_id) {
          // Find all sections between current and target, mark them as skipped
          const currentSectionIndex = questionnaire.sections.findIndex(s => s.id === question.sectionId);
          const targetSectionIndex = questionnaire.sections.findIndex(s => s.id === rule.target_section_id);

          for (let i = currentSectionIndex + 1; i < targetSectionIndex; i++) {
            newSkippedSections.add(questionnaire.sections[i].id);
          }
        }
      });
    });

    skippedSections = newSkippedSections;
  }

  function checkCondition(answer, conditionType, conditionValue) {
    // Extract the actual value from answer object
    let actualValue = answer;
    if (typeof answer === 'object') {
      actualValue = answer.choice_id || answer.text || answer.rating || answer.choice_ids;
    }

    switch (conditionType) {
      case 'equals':
        return String(actualValue) === String(conditionValue);
      case 'not_equals':
        return String(actualValue) !== String(conditionValue);
      case 'contains':
        return Array.isArray(actualValue)
          ? actualValue.includes(conditionValue)
          : String(actualValue).includes(conditionValue);
      case 'greater_than':
        return Number(actualValue) > Number(conditionValue);
      case 'less_than':
        return Number(actualValue) < Number(conditionValue);
      default:
        return false;
    }
  }

  // Filter visible questions based on skipped sections
  const visibleQuestions = $derived(
    allQuestions.filter(q => !skippedSections.has(q.sectionId))
  );

  const currentQuestion = $derived(visibleQuestions[currentQuestionIndex]);
  const progress = $derived(((currentQuestionIndex + 1) / visibleQuestions.length * 100).toFixed(0));
  const isLastQuestion = $derived(currentQuestionIndex === visibleQuestions.length - 1);

  async function handleAnswer(questionId, answerValue) {
    // Update local state
    answers[questionId] = answerValue;

    // Re-evaluate logic rules to update visible questions
    evaluateLogicRules();

    // Save answer to backend
    try {
      await fetch(`/responses/${response.id}/answers`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          answer: {
            question_id: questionId,
            answer_value: answerValue
          }
        })
      });

      // Auto-advance to next question
      if (!isLastQuestion) {
        currentQuestionIndex++;
      }
    } catch (error) {
      console.error('Error saving answer:', error);
    }
  }

  function previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
    }
  }

  async function completeQuestionnaire() {
    try {
      await fetch(`/responses/${response.id}/complete`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      });

      // Redirect to dashboard
      router.visit('/dashboard');
    } catch (error) {
      console.error('Error completing questionnaire:', error);
    }
  }
</script>

<div class="max-w-2xl mx-auto p-6">
  <!-- Progress Bar -->
  <div class="mb-8">
    <div class="flex justify-between items-center mb-2">
      <span class="text-sm text-gray-600">{currentQuestion?.sectionTitle}</span>
      <span class="text-sm font-medium">{progress}%</span>
    </div>
    <div class="w-full bg-gray-200 rounded-full h-2">
      <div
        class="bg-blue-600 h-2 rounded-full transition-all duration-300"
        style="width: {progress}%"
      ></div>
    </div>
  </div>

  <!-- Question Card -->
  {#if currentQuestion}
    <QuestionCard
      question={currentQuestion}
      answer={answers[currentQuestion.id]}
      onanswer={(answerValue) => handleAnswer(currentQuestion.id, answerValue)}
    />
  {/if}

  <!-- Navigation -->
  <div class="flex justify-between mt-8">
    <button
      onclick={previousQuestion}
      disabled={currentQuestionIndex === 0}
      class="px-4 py-2 text-gray-700 bg-gray-100 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
    >
      ← Précédent
    </button>

    {#if isLastQuestion}
      <button
        onclick={completeQuestionnaire}
        class="px-6 py-2 text-white bg-green-600 rounded hover:bg-green-700"
      >
        Terminer l'évaluation
      </button>
    {:else}
      <button
        onclick={() => {
          if (!isLastQuestion && answers[currentQuestion.id]) {
            currentQuestionIndex++;
          }
        }}
        disabled={!answers[currentQuestion.id]}
        class="px-4 py-2 text-white bg-blue-600 rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Suivant →
      </button>
    {/if}
  </div>
</div>
