<!-- app/frontend/pages/App.svelte -->
<script>
  import { page } from '@inertiajs/svelte'
  import AppLayout from '$lib/layouts/AppLayout.svelte'

  const account = $derived($page.props.current_account)
</script>

<AppLayout title="Application">
  <div class="max-w-7xl mx-auto">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-xl font-semibold text-gray-800 mb-4">
        {account?.name}
      </h2>
      <p class="text-gray-600">
        Your main application content goes here.
      </p>
    </div>
  </div>
</AppLayout>
