<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'

  let { accounts, search = '' } = $props()

  let searchQuery = $state(search)

  function handleSearch() {
    router.get('/admin/accounts', { search: searchQuery }, { preserveState: true })
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Accounts</h2>
      </div>

      <!-- Search -->
      <div class="mb-6">
        <form onsubmit={(e) => { e.preventDefault(); handleSearch(); }}>
          <div class="flex gap-2">
            <input
              type="text"
              bind:value={searchQuery}
              placeholder="Search by name or subdomain..."
              class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Search
            </button>
          </div>
        </form>
      </div>

      <!-- Accounts list -->
      <div class="overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Subdomain</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Plan</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Users</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each accounts as account}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {account.name}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {account.subdomain}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {account.plan_type || 'Free'}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {account.users.length}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(account.created_at).toLocaleDateString()}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <a href="/admin/accounts/{account.id}" class="text-blue-600 hover:text-blue-900">
                    View
                  </a>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>

        {#if accounts.length === 0}
          <div class="text-center py-12 text-gray-500">
            No accounts found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
