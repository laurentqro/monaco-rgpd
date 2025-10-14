<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'

  let { user } = $props()

  const form = useForm({
    name: user.name || '',
    email: user.email,
    avatar_url: user.avatar_url || ''
  })

  function submit() {
    $form.patch(`/users/${user.id}`, {
      onSuccess: () => {
        // Success message handled by flash
      }
    })
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-6">Profile Settings</h3>

      <form onsubmit={submit}>
        <div class="space-y-6">
          <!-- Name -->
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
              Name
            </label>
            <input
              type="text"
              id="name"
              bind:value={$form.name}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
            />
            {#if $form.errors.name}
              <p class="mt-1 text-sm text-red-600">{$form.errors.name}</p>
            {/if}
          </div>

          <!-- Email -->
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
              Email
            </label>
            <input
              type="email"
              id="email"
              bind:value={$form.email}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
            />
            {#if $form.errors.email}
              <p class="mt-1 text-sm text-red-600">{$form.errors.email}</p>
            {/if}
          </div>

          <!-- Avatar URL -->
          <div>
            <label for="avatar_url" class="block text-sm font-medium text-gray-700 mb-1">
              Avatar URL
            </label>
            <input
              type="url"
              id="avatar_url"
              bind:value={$form.avatar_url}
              placeholder="https://example.com/avatar.jpg"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
            />
            {#if $form.errors.avatar_url}
              <p class="mt-1 text-sm text-red-600">{$form.errors.avatar_url}</p>
            {/if}
          </div>
        </div>

        <div class="mt-6 flex justify-end">
          <button
            type="submit"
            disabled={$form.processing}
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {$form.processing ? 'Saving...' : 'Save Changes'}
          </button>
        </div>
      </form>
    </div>
  {/snippet}
</SettingsLayout>
