<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'

  let { users, search = '' } = $props()

  let searchQuery = $state(search)

  function handleSearch() {
    router.get('/admin/users', { search: searchQuery }, { preserveState: true })
  }

  function impersonateUser(userId) {
    if (confirm('Impersonate this user? You will be signed in as them.')) {
      router.post(`/admin/users/${userId}/impersonate`)
    }
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Users</h2>
      </div>

      <!-- Search -->
      <div class="mb-6">
        <form onsubmit={(e) => { e.preventDefault(); handleSearch(); }}>
          <div class="flex gap-2">
            <input
              type="text"
              bind:value={searchQuery}
              placeholder="Search by email or name..."
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

      <!-- Users table -->
      <div class="overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Account</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each users as user}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {user.email}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {user.name || '-'}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {user.account.name}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <span class="px-2 py-1 text-xs rounded-full {
                    user.role === 'owner' ? 'bg-purple-100 text-purple-800' :
                    user.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                    'bg-gray-100 text-gray-800'
                  }">
                    {user.role}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(user.created_at).toLocaleDateString()}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                  <a href="/admin/users/{user.id}" class="text-blue-600 hover:text-blue-900">
                    View
                  </a>
                  <button
                    onclick={() => impersonateUser(user.id)}
                    class="text-orange-600 hover:text-orange-900"
                  >
                    Impersonate
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>

        {#if users.length === 0}
          <div class="text-center py-12 text-gray-500">
            No users found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
