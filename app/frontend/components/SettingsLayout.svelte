<!-- app/frontend/components/SettingsLayout.svelte -->
<script>
  import Header from './Header.svelte'
  import SettingsNav from './SettingsNav.svelte'

  let { children } = $props()
</script>

<div class="min-h-screen bg-gray-50">
  <Header />

  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="lg:grid lg:grid-cols-12 lg:gap-x-8">
      <!-- Sidebar -->
      <aside class="py-6 px-2 sm:px-6 lg:col-span-3 lg:py-0 lg:px-0">
        <nav class="space-y-1">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Settings</h2>
          <SettingsNav />
        </nav>
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
