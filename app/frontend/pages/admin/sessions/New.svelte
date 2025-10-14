<script>
  import { useForm } from '@inertiajs/svelte'

  let { error } = $props()

  const form = useForm({
    email: '',
    password: ''
  })

  function submit(e) {
    e.preventDefault()
    $form.post('/admin/session')
  }
</script>

<div class="min-h-screen bg-gray-100 flex items-center justify-center">
  <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
    <h1 class="text-2xl font-bold text-gray-900 mb-6">Admin Sign In</h1>

    {#if error}
      <div class="mb-4 bg-red-50 border border-red-200 text-red-800 rounded-lg p-3">
        {error}
      </div>
    {/if}

    <form onsubmit={submit}>
      <div class="space-y-4">
        <!-- Email -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
            Email
          </label>
          <input
            type="email"
            id="email"
            bind:value={$form.email}
            required
            class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
            Password
          </label>
          <input
            type="password"
            id="password"
            bind:value={$form.password}
            required
            class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      <div class="mt-6">
        <button
          type="submit"
          disabled={$form.processing}
          class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {$form.processing ? 'Signing in...' : 'Sign In'}
        </button>
      </div>
    </form>
  </div>
</div>
