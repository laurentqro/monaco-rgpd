<script>
  import { page, router } from '@inertiajs/svelte'
  import AdminNav from './AdminNav.svelte'

  let { children } = $props()

  const admin = $derived($page.props.current_admin)
  const impersonating = $derived($page.props.impersonating_user)

  function signOut() {
    router.delete('/admin/session')
  }

  function stopImpersonating() {
    router.delete('/admin/impersonations')
  }
</script>

<div class="min-h-screen bg-gray-50">
  <!-- Impersonation banner -->
  {#if impersonating}
    <div class="bg-orange-600 text-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 flex justify-between items-center">
        <span class="font-medium">
          ⚠️ Impersonating: {impersonating.email}
        </span>
        <button
          onclick={stopImpersonating}
          class="px-3 py-1 bg-white text-orange-600 rounded hover:bg-orange-50"
        >
          Stop Impersonating
        </button>
      </div>
    </div>
  {/if}

  <!-- Header -->
  <header class="bg-white shadow">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <h1 class="text-xl font-bold text-gray-900">Admin Panel</h1>

        <div class="flex items-center space-x-4">
          <span class="text-sm text-gray-700">{admin?.name}</span>
          <button
            onclick={signOut}
            class="text-sm text-gray-700 hover:text-gray-900"
          >
            Sign Out
          </button>
        </div>
      </div>
    </div>
  </header>

  <!-- Main content -->
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="lg:grid lg:grid-cols-12 lg:gap-x-8">
      <!-- Sidebar -->
      <aside class="py-6 px-2 sm:px-6 lg:col-span-3 lg:py-0 lg:px-0">
        <AdminNav />
      </aside>

      <!-- Main content -->
      <main class="lg:col-span-9">
        <div class="bg-white shadow rounded-lg">
          {@render children()}
        </div>
      </main>
    </div>
  </div>
</div>
