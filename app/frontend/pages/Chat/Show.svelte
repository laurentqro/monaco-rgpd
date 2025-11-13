<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import ChatInterface from '../../components/chat/ChatInterface.svelte';

  let { conversation, questionnaire } = $props();
</script>

<AppLayout title={questionnaire?.title || 'Conversation'}>
  <div class="min-h-screen bg-gray-50">
    <ChatInterface {conversation} {questionnaire} />
  </div>
</AppLayout>
