<script>
  import MessageList from './MessageList.svelte';
  import ChatInput from './ChatInput.svelte';
  import ProgressSidebar from './ProgressSidebar.svelte';
  import { router } from '@inertiajs/svelte';

  let { conversation, questionnaire } = $props();

  let messages = $state(conversation.messages || []);
  let isSending = $state(false);

  async function handleSendMessage(content) {
    if (isSending) return;

    isSending = true;

    // Optimistically add user message
    const userMessage = {
      role: 'user',
      content: content,
      created_at: new Date().toISOString()
    };
    messages = [...messages, userMessage];

    try {
      const response = await fetch(`/conversations/${conversation.id}/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ message: { content } })
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Received AI response:', data);

      // Add assistant response
      messages = [...messages, data.message];

      // Check if conversation complete
      if (data.next_action === 'complete') {
        // Redirect to results
        router.visit(`/responses/${conversation.response_id}/results`);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      alert(`Erreur: ${error.message}`);
      // Remove optimistic message
      messages = messages.slice(0, -1);
    } finally {
      isSending = false;
    }
  }
</script>

<div class="flex h-screen">
  <div class="flex-1 flex flex-col">
    <header class="bg-white border-b px-6 py-4">
      <h1 class="text-2xl font-bold text-gray-900">
        {questionnaire.title}
      </h1>
      <p class="text-sm text-gray-600">{questionnaire.description}</p>
    </header>

    <MessageList {messages} {isSending} />

    <ChatInput
      onSend={handleSendMessage}
      disabled={isSending}
    />
  </div>

  <ProgressSidebar {questionnaire} {conversation} />
</div>
