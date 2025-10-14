<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'

  let { account, users, subscription } = $props()

  function deleteAccount() {
    if (confirm(`Delete account "${account.name}"? This will delete all associated users and data.`)) {
      router.delete(`/admin/accounts/${account.id}`)
    }
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">{account.name}</h2>
        <button
          onclick={deleteAccount}
          class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Delete Account
        </button>
      </div>

      <!-- Account details -->
      <div class="bg-gray-50 rounded-lg p-4 mb-6">
        <dl class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <dt class="text-sm font-medium text-gray-500">Subdomain</dt>
            <dd class="mt-1 text-sm text-gray-900">{account.subdomain}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Plan</dt>
            <dd class="mt-1 text-sm text-gray-900">{account.plan_type || 'Free'}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Subscribed</dt>
            <dd class="mt-1 text-sm text-gray-900">{account.subscribed ? 'Yes' : 'No'}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Created</dt>
            <dd class="mt-1 text-sm text-gray-900">{new Date(account.created_at).toLocaleDateString()}</dd>
          </div>
        </dl>
      </div>

      <!-- Subscription -->
      {#if subscription}
        <div class="mb-6">
          <h3 class="text-base font-semibold text-gray-900 mb-3">Subscription</h3>
          <div class="bg-gray-50 rounded-lg p-4">
            <dl class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <dt class="text-sm font-medium text-gray-500">Status</dt>
                <dd class="mt-1 text-sm text-gray-900 capitalize">{subscription.status}</dd>
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500">Plan</dt>
                <dd class="mt-1 text-sm text-gray-900">{subscription.plan_type}</dd>
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500">Period End</dt>
                <dd class="mt-1 text-sm text-gray-900">
                  {new Date(subscription.current_period_end).toLocaleDateString()}
                </dd>
              </div>
            </dl>
          </div>
        </div>
      {/if}

      <!-- Users -->
      <div>
        <h3 class="text-base font-semibold text-gray-900 mb-3">Users ({users.length})</h3>
        <div class="overflow-hidden rounded-lg border border-gray-200">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              {#each users as user}
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.email}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.name || '-'}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 capitalize">{user.role}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                    <a href="/admin/users/{user.id}" class="text-blue-600 hover:text-blue-900">
                      View
                    </a>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  {/snippet}
</AdminLayout>
