<script>
  import QuestionCard from './QuestionCard.svelte';
  import { router } from '@inertiajs/svelte';

  let { questionnaire, response } = $props();

  let currentQuestionIndex = $state(0);
  let answers = $state({});
  let answerIds = $state({}); // Track answer IDs for updates
  let skippedSections = $state(new Set());
  let shouldExit = $state(false);
  let exitMessage = $state('');

  // Load existing answers from response
  if (response.answers) {
    response.answers.forEach(answer => {
      answers[answer.question_id] = answer.answer_value;
      answerIds[answer.question_id] = answer.id;
    });
  }

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
        const conditionMet = checkCondition(answer, rule.condition_type, rule.condition_value);

        if (conditionMet) {
          if (rule.action === 'exit_questionnaire') {
            // Trigger exit
            shouldExit = true;
            exitMessage = rule.exit_message || "Ce questionnaire n'est pas applicable à votre situation.";
          } else if (rule.action === 'skip_to_section' && rule.target_section_id) {
            // Find all sections between current and target, mark them as skipped
            const currentSectionIndex = questionnaire.sections.findIndex(s => s.id === question.sectionId);
            const targetSectionIndex = questionnaire.sections.findIndex(s => s.id === rule.target_section_id);

            for (let i = currentSectionIndex + 1; i < targetSectionIndex; i++) {
              newSkippedSections.add(questionnaire.sections[i].id);
            }
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
      const answerId = answerIds[questionId];
      let url, method;

      if (answerId) {
        // Update existing answer
        url = `/responses/${response.id}/answers/${answerId}`;
        method = 'PUT';
      } else {
        // Create new answer
        url = `/responses/${response.id}/answers`;
        method = 'POST';
      }

      const responseData = await fetch(url, {
        method: method,
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

      // If this was a create, store the answer ID for future updates
      if (method === 'POST' && responseData.ok) {
        const data = await responseData.json();
        if (data.id) {
          answerIds[questionId] = data.id;
        }
      }

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
  {#if shouldExit}
    <!-- Exit Message -->
    <div class="bg-yellow-50 border-l-4 border-yellow-400 p-6 rounded-lg">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <svg class="h-6 w-6 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <div class="ml-4 flex-1">
          <h3 class="text-lg font-medium text-yellow-800">
            Questionnaire non applicable
          </h3>
          <div class="mt-2 text-sm text-yellow-700">
            <p>{exitMessage}</p>
          </div>
          <div class="mt-4">
            <button
              onclick={() => router.visit('/dashboard')}
              class="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700"
            >
              Retour au tableau de bord
            </button>
          </div>
        </div>
      </div>
    </div>
  {:else}
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
  {/if}
</div>
