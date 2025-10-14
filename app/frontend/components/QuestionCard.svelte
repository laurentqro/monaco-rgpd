<script>
  let { question, answer = null, onanswer } = $props();

  let selectedValue = $state(answer || {});

  function handleYesNo(choiceText) {
    // Find the answer choice ID that matches the text
    const choice = question.answer_choices.find(c => c.choice_text === choiceText);
    if (choice) {
      selectedValue = { choice_id: choice.id };
      onanswer(selectedValue);
    }
  }

  function handleSingleChoice(choiceId) {
    selectedValue = { choice_id: choiceId };
    onanswer(selectedValue);
  }

  function handleMultipleChoice(choiceId, checked) {
    const choiceIds = selectedValue.choice_ids || [];
    if (checked) {
      selectedValue = { choice_ids: [...choiceIds, choiceId] };
    } else {
      selectedValue = { choice_ids: choiceIds.filter(id => id !== choiceId) };
    }
    onanswer(selectedValue);
  }

  function handleText(value) {
    selectedValue = { text: value };
    onanswer(selectedValue);
  }
</script>

<div class="bg-white rounded-lg shadow-lg p-8">
  <h2 class="text-2xl font-bold mb-4">{question.question_text}</h2>

  {#if question.help_text}
    <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6">
      <p class="text-sm text-blue-700">{question.help_text}</p>
    </div>
  {/if}

  <div class="space-y-6">
    {#if question.question_type === 'yes_no'}
      <div class="flex gap-6">
        {#each question.answer_choices as choice (choice.id)}
          <button
            onclick={() => handleYesNo(choice.choice_text)}
            class="flex-1 py-4 px-8 rounded-lg border-2 transition-all font-medium text-lg {selectedValue.choice_id === choice.id ? (choice.choice_text === 'Oui' ? 'border-green-500 bg-green-50 text-green-700' : 'border-red-500 bg-red-50 text-red-700') : 'border-gray-300 hover:border-gray-400'}"
          >
            {choice.choice_text}
          </button>
        {/each}
      </div>

    {:else if question.question_type === 'single_choice'}
      <div class="space-y-3">
        {#each question.answer_choices as choice (choice.id)}
          <button
            onclick={() => handleSingleChoice(choice.id)}
            class="w-full text-left py-4 px-5 rounded-lg border-2 transition-all {selectedValue.choice_id === choice.id ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}"
          >
            {choice.choice_text}
          </button>
        {/each}
      </div>

    {:else if question.question_type === 'multiple_choice'}
      <div class="space-y-3">
        {#each question.answer_choices as choice (choice.id)}
          <label class="flex items-center py-4 px-5 rounded-lg border-2 border-gray-300 hover:border-gray-400 cursor-pointer transition-all">
            <input
              type="checkbox"
              checked={selectedValue.choice_ids?.includes(choice.id)}
              onchange={(e) => handleMultipleChoice(choice.id, e.target.checked)}
              class="mr-3 h-5 w-5 text-blue-600"
            />
            <span>{choice.choice_text}</span>
          </label>
        {/each}
      </div>

    {:else if question.question_type === 'text_short'}
      <input
        type="text"
        value={selectedValue.text || ''}
        oninput={(e) => handleText(e.target.value)}
        class="w-full py-3 px-4 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none"
        placeholder="Votre réponse..."
      />

    {:else if question.question_type === 'text_long'}
      <textarea
        value={selectedValue.text || ''}
        oninput={(e) => handleText(e.target.value)}
        rows="5"
        class="w-full py-3 px-4 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none"
        placeholder="Votre réponse..."
      ></textarea>
    {/if}
  </div>
</div>
