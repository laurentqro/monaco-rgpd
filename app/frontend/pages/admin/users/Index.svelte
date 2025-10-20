<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Input } from '$lib/components/ui/input'
  import { Button } from '$lib/components/ui/button'
  import { Badge } from '$lib/components/ui/badge'

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
            <Input
              type="text"
              bind:value={searchQuery}
              placeholder="Search by email or name..."
              class="flex-1"
            />
            <Button type="submit">
              Search
            </Button>
          </div>
        </form>
      </div>

      <!-- Users table -->
      <div class="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Email</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Account</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each users as user}
              <TableRow>
                <TableCell class="font-medium">
                  {user.email}
                </TableCell>
                <TableCell>
                  {user.name || '-'}
                </TableCell>
                <TableCell>
                  {user.account.name}
                </TableCell>
                <TableCell>
                  <Badge variant={
                    user.role === 'owner' ? 'default' :
                    user.role === 'admin' ? 'secondary' :
                    'outline'
                  }>
                    {user.role}
                  </Badge>
                </TableCell>
                <TableCell>
                  {new Date(user.created_at).toLocaleDateString()}
                </TableCell>
                <TableCell class="text-right space-x-2">
                  <a href="/admin/users/{user.id}" class="text-blue-600 hover:text-blue-900">
                    View
                  </a>
                  <button
                    onclick={() => impersonateUser(user.id)}
                    class="text-orange-600 hover:text-orange-900"
                  >
                    Impersonate
                  </button>
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>

        {#if users.length === 0}
          <div class="text-center py-12 text-gray-500">
            No users found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
