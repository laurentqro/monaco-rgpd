<script>
  import QuestionCard from './QuestionCard.svelte';
  import { router } from '@inertiajs/svelte';

  let { questionnaire, response } = $props();

  let currentQuestionIndex = $state(0);
  let answers = $state({});
  let answerIds = $state({}); // Track answer IDs for updates
  let skippedSections = $state(new Set());
  let skippedQuestions = $state(new Set()); // Track questions to skip (for skip_to_question)
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

  // Evaluate logic rules and determine which sections/questions to skip
  function evaluateLogicRules() {
    const newSkippedSections = new Set();
    const newSkippedQuestions = new Set();

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
          } else if (rule.action === 'skip_to_question' && rule.target_question_id) {
            // Find all questions between current and target, mark them as skipped
            const currentQuestionIndex = allQuestions.findIndex(q => q.id === question.id);
            const targetQuestionIndex = allQuestions.findIndex(q => q.id === rule.target_question_id);

            for (let i = currentQuestionIndex + 1; i < targetQuestionIndex; i++) {
              newSkippedQuestions.add(allQuestions[i].id);
            }
          }
        }
      });
    });

    skippedSections = newSkippedSections;
    skippedQuestions = newSkippedQuestions;
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

  // Filter visible questions based on skipped sections and skipped questions
  const visibleQuestions = $derived(
    allQuestions.filter(q => !skippedSections.has(q.sectionId) && !skippedQuestions.has(q.id))
  );

  const currentQuestion = $derived(visibleQuestions[currentQuestionIndex]);
  const progress = $derived(((currentQuestionIndex + 1) / visibleQuestions.length * 100).toFixed(0));
  const isLastQuestion = $derived(currentQuestionIndex === visibleQuestions.length - 1);

  // Get visible sections for subway-line progress
  const visibleSections = $derived(
    questionnaire.sections.filter(s => !skippedSections.has(s.id))
  );

  // Determine current section and completed sections
  const currentSectionId = $derived(currentQuestion?.sectionId);
  const completedSectionIds = $derived.by(() => {
    const completed = new Set();
    for (let i = 0; i < currentQuestionIndex; i++) {
      const q = visibleQuestions[i];
      if (q && answers[q.id]) {
        completed.add(q.sectionId);
      }
    }
    return completed;
  });

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
    <!-- Subway-Line Progress -->
    <div class="mb-8">
      <div class="flex justify-between items-center mb-4">
        <span class="text-sm text-gray-600">{currentQuestion?.sectionTitle}</span>
        <span class="text-sm font-medium">{progress}%</span>
      </div>

      <!-- Section Circles (Subway Line Style) -->
      <div class="relative">
        <div class="flex justify-between items-start">
          {#each visibleSections as section, i}
            {@const isCompleted = completedSectionIds.has(section.id) && currentSectionId !== section.id}
            {@const isCurrent = currentSectionId === section.id}
            {@const isPending = !isCompleted && !isCurrent}

            <div class="flex flex-col items-center flex-1 relative">
              <!-- Connecting Line (except for last section) -->
              {#if i < visibleSections.length - 1}
                <div class="absolute top-4 left-1/2 w-full h-0.5 {isCompleted ? 'bg-blue-600' : 'bg-gray-300'}" style="z-index: 0;"></div>
              {/if}

              <!-- Section Circle -->
              <div class="relative z-10">
                <div class="w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300 {
                  isCompleted ? 'bg-blue-600 text-white' :
                  isCurrent ? 'bg-blue-600 text-white ring-4 ring-blue-200' :
                  'bg-gray-300 text-gray-600'
                }">
                  {#if isCompleted}
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                    </svg>
                  {:else}
                    <span class="text-xs font-semibold">{i + 1}</span>
                  {/if}
                </div>
              </div>

              <!-- Section Title -->
              <div class="mt-2 text-center min-h-[3rem] flex items-start justify-center">
                <span class="text-xs {isCurrent ? 'font-semibold text-blue-600' : 'text-gray-600'} block max-w-[100px] leading-tight">
                  {section.title}
                </span>
              </div>
            </div>
          {/each}
        </div>
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
