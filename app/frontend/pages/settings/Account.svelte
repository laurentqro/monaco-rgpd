<!-- app/frontend/pages/settings/Account.svelte -->
<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'

  let { account, is_admin } = $props()

  const form = useForm({
    name: account.name,
    subdomain: account.subdomain
  })

  function submit() {
    $form.patch(`/accounts/${account.id}`, {
      onSuccess: () => {
        // Success message handled by flash
      }
    })
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-6">Account Settings</h3>

      {#if !is_admin}
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <p class="text-sm text-yellow-800">
            Only account administrators can modify these settings.
          </p>
        </div>
      {/if}

      <form onsubmit={submit}>
        <div class="space-y-6">
          <!-- Account Name -->
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
              Account Name
            </label>
            <input
              type="text"
              id="name"
              bind:value={$form.name}
              disabled={!is_admin}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
            {#if $form.errors.name}
              <p class="mt-1 text-sm text-red-600">{$form.errors.name}</p>
            {/if}
          </div>

          <!-- Subdomain -->
          <div>
            <label for="subdomain" class="block text-sm font-medium text-gray-700 mb-1">
              Subdomain
            </label>
            <div class="mt-1 flex rounded-md shadow-sm">
              <input
                type="text"
                id="subdomain"
                bind:value={$form.subdomain}
                disabled={!is_admin}
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
            </div>
            {#if $form.errors.subdomain}
              <p class="mt-1 text-sm text-red-600">{$form.errors.subdomain}</p>
            {/if}
            <p class="mt-1 text-xs text-gray-500">
              Used for custom domains and API access
            </p>
          </div>

          <!-- Plan Type (read-only) -->
          <div>
            <div class="block text-sm font-medium text-gray-700 mb-1">
              Current Plan
            </div>
            <div class="mt-1 px-3 py-2 bg-gray-50 border border-gray-300 rounded-md text-sm text-gray-700">
              {account.plan_type || 'Free'}
            </div>
            <p class="mt-1 text-xs text-gray-500">
              Manage your subscription in <a href="/settings/billing" class="text-blue-600 hover:underline">Billing</a>
            </p>
          </div>
        </div>

        {#if is_admin}
          <div class="mt-6 flex justify-end">
            <button
              type="submit"
              disabled={$form.processing}
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {$form.processing ? 'Saving...' : 'Save Changes'}
            </button>
          </div>
        {/if}
      </form>
    </div>
  {/snippet}
</SettingsLayout>
