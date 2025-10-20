<script>
  import { page, router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardContent } from '$lib/components/ui/card'
  import AdminNav from './AdminNav.svelte'
  import { toast } from 'svelte-sonner';

  let { children } = $props()

  const admin = $derived($page.props.current_admin)
  const impersonating = $derived($page.props.impersonating_user)

  // Show toast notifications for flash messages
  $effect(() => {
    if ($page.props.flash?.notice) {
      toast.success($page.props.flash.notice);
    }
    if ($page.props.flash?.alert) {
      toast.error($page.props.flash.alert);
    }
  });

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
        <Button
          onclick={stopImpersonating}
          variant="secondary"
          size="sm"
          class="bg-white text-orange-600 hover:bg-orange-50"
        >
          Stop Impersonating
        </Button>
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
          <Button
            onclick={signOut}
            variant="ghost"
            size="sm"
          >
            Sign Out
          </Button>
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
        <Card>
          <CardContent class="p-6">
            {@render children()}
          </CardContent>
        </Card>
      </main>
    </div>
  </div>
</div>
