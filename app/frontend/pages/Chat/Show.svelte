<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import ChatInterface from '../../components/chat/ChatInterface.svelte';

  let { conversation, questionnaire } = $props();
</script>

<AppLayout title={questionnaire?.title || 'Conversation'}>
  <ChatInterface {conversation} {questionnaire} />
</AppLayout>
