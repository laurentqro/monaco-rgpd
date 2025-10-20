<script>
  import { router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button';

  let { user } = $props()

  function stopImpersonating() {
    router.delete('/admin/impersonations')
  }
</script>

<div class="bg-orange-600 text-white">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 flex justify-between items-center">
    <span class="font-medium">
      ⚠️ Admin Impersonating: {user.email}
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
