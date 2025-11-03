<script>
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Input } from '$lib/components/ui/input';
  import { Textarea } from '$lib/components/ui/textarea';
  import { Checkbox } from '$lib/components/ui/checkbox';
  import { Label } from '$lib/components/ui/label';
  import IntroText from './IntroText.svelte';
  import HelpPopover from './HelpPopover.svelte';

  let { question, answer = null, onanswer } = $props();

  let selectedValue = $state(answer || {});

  function handleYesNo(choiceText) {
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

<Card>
  <CardHeader>
    <IntroText content={question.intro_text} />
    <CardTitle id="question-title-{question.id}" class="text-2xl flex items-center">
      <span>{question.question_text}</span>
      {#if question.help_text}
        <HelpPopover content={question.help_text} />
      {/if}
    </CardTitle>
  </CardHeader>
  <CardContent>

    <div class="space-y-6">
      {#if question.question_type === 'yes_no'}
        <div class="flex gap-6" role="radiogroup" aria-labelledby="question-title-{question.id}">
          {#each question.answer_choices as choice (choice.id)}
            <Button
              onclick={() => handleYesNo(choice.choice_text)}
              variant={selectedValue.choice_id === choice.id ? "default" : "outline"}
              class="flex-1 h-16 text-lg {selectedValue.choice_id === choice.id && choice.choice_text === 'Oui' ? 'bg-green-600 hover:bg-green-700' : ''} {selectedValue.choice_id === choice.id && choice.choice_text === 'Non' ? 'bg-red-600 hover:bg-red-700' : ''}"
              role="radio"
              aria-checked={selectedValue.choice_id === choice.id}
            >
              {choice.choice_text}
            </Button>
          {/each}
        </div>

      {:else if question.question_type === 'single_choice'}
        <div class="flex flex-col gap-4" role="radiogroup" aria-labelledby="question-title-{question.id}">
          {#each question.answer_choices as choice (choice.id)}
            <Button
              onclick={() => handleSingleChoice(choice.id)}
              variant={selectedValue.choice_id === choice.id ? "default" : "outline"}
              class="w-full h-auto py-4 px-5 text-left justify-start"
              role="radio"
              aria-checked={selectedValue.choice_id === choice.id}
            >
              {choice.choice_text}
            </Button>
          {/each}
        </div>

      {:else if question.question_type === 'multiple_choice'}
        <div class="flex flex-col gap-4" role="group" aria-labelledby="question-title-{question.id}">
          {#each question.answer_choices as choice (choice.id)}
            <Label for="choice-{choice.id}" class="flex items-center p-4 rounded-lg border cursor-pointer hover:bg-gray-50">
              <Checkbox
                id="choice-{choice.id}"
                checked={selectedValue.choice_ids?.includes(choice.id)}
                onCheckedChange={(checked) => handleMultipleChoice(choice.id, checked)}
                class="mr-3"
              />
              <span>{choice.choice_text}</span>
            </Label>
          {/each}
        </div>

      {:else if question.question_type === 'text_short'}
        <div class="space-y-2">
          <Label for="answer-{question.id}">Votre réponse</Label>
          <Input
            id="answer-{question.id}"
            type="text"
            value={selectedValue.text || ''}
            oninput={(e) => handleText(e.target.value)}
            placeholder="Votre réponse..."
          />
        </div>

      {:else if question.question_type === 'text_long'}
        <div class="space-y-2">
          <Label for="answer-{question.id}">Votre réponse</Label>
          <Textarea
            id="answer-{question.id}"
            value={selectedValue.text || ''}
            oninput={(e) => handleText(e.target.value)}
            rows={5}
            placeholder="Votre réponse..."
          />
        </div>
      {/if}
    </div>
  </CardContent>
</Card>
