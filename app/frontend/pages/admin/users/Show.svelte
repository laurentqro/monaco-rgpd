<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'

  let { user, account, sessions } = $props()

  function deleteUser() {
    if (confirm(`Delete user "${user.email}"?`)) {
      router.delete(`/admin/users/${user.id}`)
    }
  }

  function impersonateUser() {
    if (confirm('Impersonate this user? You will be signed in as them.')) {
      router.post(`/admin/users/${user.id}/impersonate`)
    }
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">{user.email}</h2>
        <div class="space-x-2">
          <button
            onclick={impersonateUser}
            class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700"
          >
            Impersonate
          </button>
          <button
            onclick={deleteUser}
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            Delete User
          </button>
        </div>
      </div>

      <!-- User details -->
      <div class="bg-gray-50 rounded-lg p-4 mb-6">
        <dl class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <dt class="text-sm font-medium text-gray-500">Name</dt>
            <dd class="mt-1 text-sm text-gray-900">{user.name || '-'}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Role</dt>
            <dd class="mt-1 text-sm text-gray-900 capitalize">{user.role}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Account</dt>
            <dd class="mt-1 text-sm">
              <a href="/admin/accounts/{account.id}" class="text-blue-600 hover:text-blue-900">
                {account.name}
              </a>
            </dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">Created</dt>
            <dd class="mt-1 text-sm text-gray-900">{new Date(user.created_at).toLocaleDateString()}</dd>
          </div>
        </dl>
      </div>

      <!-- Recent sessions -->
      <div>
        <h3 class="text-base font-semibold text-gray-900 mb-3">Recent Sessions</h3>
        <div class="overflow-hidden rounded-lg border border-gray-200">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">IP Address</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User Agent</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              {#each sessions as session}
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{session.ip_address}</td>
                  <td class="px-6 py-4 text-sm text-gray-500">{session.user_agent}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(session.created_at).toLocaleString()}
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>

          {#if sessions.length === 0}
            <div class="text-center py-8 text-gray-500">
              No recent sessions
            </div>
          {/if}
        </div>
      </div>
    </div>
  {/snippet}
</AdminLayout>
