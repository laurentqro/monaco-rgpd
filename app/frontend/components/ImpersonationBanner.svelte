<script>
  import { router } from '@inertiajs/svelte'

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
    <button
      onclick={stopImpersonating}
      class="px-3 py-1 bg-white text-orange-600 rounded hover:bg-orange-50 font-medium"
    >
      Stop Impersonating
    </button>
  </div>
</div>
