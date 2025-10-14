<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'

  let { subscriptions, status = '' } = $props()

  function filterByStatus(newStatus) {
    router.get('/admin/subscriptions', { status: newStatus }, { preserveState: true })
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Subscriptions</h2>
      </div>

      <!-- Status filter -->
      <div class="mb-6 flex gap-2">
        <button
          onclick={() => filterByStatus('')}
          class="px-4 py-2 rounded-lg {!status ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}"
        >
          All
        </button>
        <button
          onclick={() => filterByStatus('active')}
          class="px-4 py-2 rounded-lg {status === 'active' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}"
        >
          Active
        </button>
        <button
          onclick={() => filterByStatus('trialing')}
          class="px-4 py-2 rounded-lg {status === 'trialing' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}"
        >
          Trialing
        </button>
        <button
          onclick={() => filterByStatus('past_due')}
          class="px-4 py-2 rounded-lg {status === 'past_due' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}"
        >
          Past Due
        </button>
      </div>

      <!-- Subscriptions table -->
      <div class="overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Account</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Plan</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Period End</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each subscriptions as subscription}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  <a href="/admin/accounts/{subscription.account.id}" class="text-blue-600 hover:text-blue-900">
                    {subscription.account.name}
                  </a>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {subscription.plan_type}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  <span class="px-2 py-1 text-xs rounded-full {
                    subscription.status === 'active' ? 'bg-green-100 text-green-800' :
                    subscription.status === 'trialing' ? 'bg-blue-100 text-blue-800' :
                    subscription.status === 'past_due' ? 'bg-red-100 text-red-800' :
                    'bg-gray-100 text-gray-800'
                  }">
                    {subscription.status}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {subscription.current_period_end ? new Date(subscription.current_period_end).toLocaleDateString() : '-'}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(subscription.created_at).toLocaleDateString()}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <a href="/admin/accounts/{subscription.account.id}" class="text-blue-600 hover:text-blue-900">
                    View Account
                  </a>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>

        {#if subscriptions.length === 0}
          <div class="text-center py-12 text-gray-500">
            No subscriptions found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
