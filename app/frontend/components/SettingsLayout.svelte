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
  <div class="flex gap-6">
    <!-- Sidebar -->
    <aside class="w-64 shrink-0">
      <h2 class="text-lg font-semibold mb-4">Settings</h2>
      <SettingsNav />
    </aside>

    <!-- Main content -->
    <main class="flex-1 min-w-0">
      <div class="bg-card shadow-sm rounded-lg border p-6">
        {@render children()}
      </div>
    </main>
  </div>
</AppLayout>
