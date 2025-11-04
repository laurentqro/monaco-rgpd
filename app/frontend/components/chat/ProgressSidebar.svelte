<script>
  let { questionnaire, conversation } = $props();

  // Calculate progress based on answered questions
  let answeredQuestions = $derived(
    new Set(conversation.messages
      .filter(m => m.extracted_data?.answers)
      .flatMap(m => m.extracted_data.answers.map(a => a.question_id))
    )
  );

  let totalQuestions = $derived(
    questionnaire.sections?.reduce((sum, section) =>
      sum + (section.questions?.length || 0), 0
    ) || 0
  );

  let progress = $derived(
    totalQuestions > 0 ? (answeredQuestions.size / totalQuestions) * 100 : 0
  );
</script>

<aside class="w-80 bg-white border-l p-6">
  <h2 class="text-lg font-semibold mb-4">Progression</h2>

  <div class="mb-6">
    <div class="flex justify-between text-sm mb-2">
      <span class="text-gray-600">Questions répondues</span>
      <span class="font-medium">{answeredQuestions.size} / {totalQuestions}</span>
    </div>
    <div class="w-full bg-gray-200 rounded-full h-2">
      <div
        class="bg-blue-600 h-2 rounded-full transition-all duration-300"
        style="width: {progress}%"
      ></div>
    </div>
  </div>

  <div class="space-y-4">
    {#each questionnaire.sections || [] as section}
      <div>
        <h3 class="font-medium text-sm mb-2">{section.title}</h3>
        <div class="space-y-1">
          {#each section.questions || [] as question}
            <div class="flex items-center gap-2">
              {#if answeredQuestions.has(question.id)}
                <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
              {:else}
                <svg class="w-4 h-4 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16z" clip-rule="evenodd" />
                </svg>
              {/if}
              <span class="text-xs text-gray-600 line-clamp-1">{question.question_text}</span>
            </div>
          {/each}
        </div>
      </div>
    {/each}
  </div>
</aside>
