<!-- app/frontend/components/SettingsLayout.svelte -->
<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import SettingsNav from './SettingsNav.svelte'
  import { page } from '@inertiajs/svelte';
  import { toast } from 'svelte-sonner';

  let { children } = $props()

  // Show toast notifications for flash messages
  $effect(() => {
    if ($page.props.flash?.notice) {
      toast.success($page.props.flash.notice);
    }
    if ($page.props.flash?.alert) {
      toast.error($page.props.flash.alert);
    }
  });
</script>

<AppLayout>
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
</AppLayout>
