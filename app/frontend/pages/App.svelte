<!-- app/frontend/pages/App.svelte -->
<script>
  import { page } from '@inertiajs/svelte'
  import Header from '../components/Header.svelte'
  import ImpersonationBanner from '../components/ImpersonationBanner.svelte'
  import Toaster from '../components/Toaster.svelte'

  const user = $derived($page.props.current_user)
  const account = $derived($page.props.current_account)
  const impersonating = $derived($page.props.impersonating_user)
</script>

<div class="min-h-screen bg-gray-50">
  {#if impersonating}
    <ImpersonationBanner user={impersonating} />
  {/if}

  <Header />

  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-xl font-semibold text-gray-800 mb-4">
        {account?.name}
      </h2>
      <p class="text-gray-600">
        Your main application content goes here.
      </p>
    </div>
  </main>
</div>

<Toaster />
