<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { useForm, router } from '@inertiajs/svelte'

  let { admins } = $props()

  let showForm = $state(false)

  const form = useForm({
    email: '',
    name: '',
    password: '',
    password_confirmation: ''
  })

  function submit(e) {
    e.preventDefault()
    $form.post('/admin/admins', {
      onSuccess: () => {
        showForm = false
        $form.reset()
      }
    })
  }

  function deleteAdmin(adminId) {
    if (confirm('Delete this admin?')) {
      router.delete(`/admin/admins/${adminId}`)
    }
  }
</script>

<AdminLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900">Admins</h2>
        <button
          onclick={() => showForm = !showForm}
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          {showForm ? 'Cancel' : 'Add Admin'}
        </button>
      </div>

      <!-- Add admin form -->
      {#if showForm}
        <div class="mb-6 bg-gray-50 rounded-lg p-4">
          <h3 class="text-base font-semibold text-gray-900 mb-4">Create New Admin</h3>
          <form onsubmit={submit}>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  type="email"
                  id="email"
                  bind:value={$form.email}
                  required
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <input
                  type="text"
                  id="name"
                  bind:value={$form.name}
                  required
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input
                  type="password"
                  id="password"
                  bind:value={$form.password}
                  required
                  minlength="8"
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">
                  Confirm Password
                </label>
                <input
                  type="password"
                  id="password_confirmation"
                  bind:value={$form.password_confirmation}
                  required
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
            </div>
            <button
              type="submit"
              disabled={$form.processing}
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {$form.processing ? 'Creating...' : 'Create Admin'}
            </button>
          </form>
        </div>
      {/if}

      <!-- Admins table -->
      <div class="overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each admins as admin}
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{admin.email}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{admin.name}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(admin.created_at).toLocaleDateString()}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button
                    onclick={() => deleteAdmin(admin.id)}
                    class="text-red-600 hover:text-red-900"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/snippet}
</AdminLayout>
