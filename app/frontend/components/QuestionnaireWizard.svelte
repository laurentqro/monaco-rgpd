<script>
  import QuestionCard from './QuestionCard.svelte';
  import IntroText from './IntroText.svelte';
  import { router } from '@inertiajs/svelte';
  import { Button } from '$lib/components/ui/button';
  import { Alert, AlertDescription } from '$lib/components/ui/alert';
  import { Progress } from '$lib/components/ui/progress';

  let { questionnaire, response } = $props();

  let currentQuestionIndex = $state(0);
  let answers = $state({});
  let answerIds = $state({}); // Track answer IDs for updates
  let skippedSections = $state(new Set());
  let skippedQuestions = $state(new Set()); // Track questions to skip (for skip_to_question)
  let shouldExit = $state(false);
  let exitMessage = $state('');
  let exitTriggerQuestionId = $state(null); // Track which question triggered the exit

  // Track if the questionnaire has been started
  // If there are existing answers, they've already started
  let hasStarted = $state(false);
  let shouldCalculateResumePosition = $state(false);

  // Load existing answers from response
  // Backend now sends answers with answer_value in the format we expect
  if (response.answers) {
    response.answers.forEach(answer => {
      answers[answer.question_id] = answer.answer_value;
      answerIds[answer.question_id] = answer.id;
    });

    // If there are answers, they've already started
    if (response.answers.length > 0) {
      hasStarted = true;
      shouldCalculateResumePosition = true;
    }
  }

  function startQuestionnaire() {
    hasStarted = true;
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
            // Trigger exit and track which question caused it
            shouldExit = true;
            exitMessage = rule.exit_message || "Ce questionnaire n'est pas applicable à votre situation.";
            exitTriggerQuestionId = question.id;
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
  const currentSection = $derived(
    questionnaire.sections.find(s => s.id === currentSectionId)
  );
  const isFirstQuestionOfSection = $derived.by(() => {
    if (currentQuestionIndex === 0) return true;
    const prevQuestion = visibleQuestions[currentQuestionIndex - 1];
    return prevQuestion?.sectionId !== currentSectionId;
  });
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

  // Calculate resume position when component mounts with existing answers
  $effect(() => {
    if (shouldCalculateResumePosition && visibleQuestions.length > 0) {
      // Evaluate logic rules first to get accurate visible questions
      evaluateLogicRules();

      // Find first unanswered question
      const firstUnansweredIndex = visibleQuestions.findIndex(q => !answers[q.id]);

      if (firstUnansweredIndex !== -1) {
        currentQuestionIndex = firstUnansweredIndex;
      } else {
        // All answered - resume at last question
        currentQuestionIndex = visibleQuestions.length - 1;
      }

      // Only do this once
      shouldCalculateResumePosition = false;
    }
  });

  // Transform answerValue object to match backend's separate field schema
  function transformAnswerForBackend(answerValue) {
    // answerValue can be:
    // { choice_id: 123 } → { answer_choice_id: 123 }
    // { text: "..." } → { answer_text: "..." }
    // { choice_ids: [...] } → not yet supported in backend

    if (answerValue.choice_id !== undefined) {
      return { answer_choice_id: answerValue.choice_id };
    } else if (answerValue.text !== undefined) {
      return { answer_text: answerValue.text };
    } else if (answerValue.choice_ids !== undefined) {
      // Multiple choice not yet supported in separate fields schema
      // For now, just return empty - this needs backend support
      console.warn('Multiple choice not yet supported with separate fields');
      return {};
    }
    return {};
  }

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

      // Transform answer value to backend format
      const backendAnswerData = transformAnswerForBackend(answerValue);

      const responseData = await fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          answer: {
            question_id: questionId,
            ...backendAnswerData
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

  function goBackFromExit() {
    // Find the question that triggered the exit
    const exitQuestionIndex = visibleQuestions.findIndex(q => q.id === exitTriggerQuestionId);

    if (exitQuestionIndex !== -1) {
      // Navigate back to that question
      currentQuestionIndex = exitQuestionIndex;
    }

    // Reset exit state
    shouldExit = false;
    exitMessage = '';
    exitTriggerQuestionId = null;
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
    <Alert class="border-l-4 border-yellow-400 bg-yellow-50">
      <svg class="h-5 w-5 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
      <div>
        <h3 class="text-lg font-medium text-yellow-800 mb-2">
          Questionnaire non applicable
        </h3>
        <AlertDescription class="text-sm text-yellow-700 mb-4">
          {exitMessage}
        </AlertDescription>
        <div class="flex gap-3">
          <Button
            onclick={goBackFromExit}
            variant="outline"
            class="border-yellow-600 text-yellow-700 hover:bg-yellow-100"
          >
            ← Revenir à la question
          </Button>
          <Button
            onclick={() => router.visit('/dashboard')}
            class="bg-yellow-600 text-white hover:bg-yellow-700"
          >
            Retour au tableau de bord
          </Button>
        </div>
      </div>
    </Alert>
  {:else if !hasStarted}
    <!-- Start Screen -->
    <div class="py-12">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">
        {questionnaire.title}
      </h1>

      {#if questionnaire.intro_text}
        <div class="mb-8">
          <IntroText content={questionnaire.intro_text} variant="plain" />
        </div>
      {/if}

      <Button
        onclick={startQuestionnaire}
        class="bg-blue-600 hover:bg-blue-700 text-lg px-8 py-6 h-auto"
        size="lg"
      >
        Commencer l'évaluation
      </Button>
    </div>
  {:else}
    <!-- Subway-Line Progress -->
    <div class="mb-8">
      <!-- Donut Chart for Progress - Centered -->
      <div class="flex flex-col items-center mb-6">
        <div class="relative inline-flex items-center justify-center">
          <svg class="w-20 h-20 transform -rotate-90">
            <!-- Background circle -->
            <circle
              cx="40"
              cy="40"
              r="36"
              stroke="currentColor"
              stroke-width="6"
              fill="none"
              class="text-gray-200"
            />
            <!-- Progress circle -->
            <circle
              cx="40"
              cy="40"
              r="36"
              stroke="currentColor"
              stroke-width="6"
              fill="none"
              stroke-linecap="round"
              class="text-blue-600 transition-all duration-300"
              style="stroke-dasharray: {36 * 2 * Math.PI}; stroke-dashoffset: {36 * 2 * Math.PI * (1 - progress / 100)};"
            />
          </svg>
          <!-- Percentage Text in Center - Perfectly Centered -->
          <div class="absolute inset-0 flex items-center justify-center">
            <span class="text-base font-bold text-gray-700" data-testid="progress-percentage">{progress}%</span>
          </div>
        </div>
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

    <!-- Questionnaire Intro Text is now shown on start screen, not here -->

    <!-- Section Intro Text -->
    {#if isFirstQuestionOfSection && currentSection?.intro_text}
      <IntroText content={currentSection.intro_text} variant="plain" />
    {/if}

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
      <Button
        onclick={previousQuestion}
        disabled={currentQuestionIndex === 0}
        variant="outline"
      >
        ← Précédent
      </Button>

      {#if isLastQuestion}
        <Button
          onclick={completeQuestionnaire}
          class="bg-green-600 hover:bg-green-700"
        >
          Terminer l'évaluation
        </Button>
      {:else}
        <Button
          onclick={() => {
            if (!isLastQuestion && answers[currentQuestion.id]) {
              currentQuestionIndex++;
            }
          }}
          disabled={!answers[currentQuestion.id]}
        >
          Suivant →
        </Button>
      {/if}
    </div>
  {/if}
</div>
