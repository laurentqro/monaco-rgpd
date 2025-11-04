<script>
  import ChatInterface from '../../components/chat/ChatInterface.svelte';

  let { conversation, questionnaire } = $props();
</script>

<div class="min-h-screen bg-gray-50">
  <ChatInterface {conversation} {questionnaire} />
</div>
