<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Input } from '$lib/components/ui/input'
  import { Button } from '$lib/components/ui/button'

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
            <Input
              type="text"
              bind:value={searchQuery}
              placeholder="Search by name or subdomain..."
              class="flex-1"
            />
            <Button type="submit">
              Search
            </Button>
          </div>
        </form>
      </div>

      <!-- Accounts list -->
      <div class="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Subdomain</TableHead>
              <TableHead>Plan</TableHead>
              <TableHead>Users</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each accounts as account}
              <TableRow>
                <TableCell class="font-medium">
                  {account.name}
                </TableCell>
                <TableCell>
                  {account.subdomain}
                </TableCell>
                <TableCell>
                  {account.plan_type || 'Free'}
                </TableCell>
                <TableCell>
                  {account.users.length}
                </TableCell>
                <TableCell>
                  {new Date(account.created_at).toLocaleDateString()}
                </TableCell>
                <TableCell class="text-right">
                  <a href="/admin/accounts/{account.id}" class="text-blue-600 hover:text-blue-900">
                    View
                  </a>
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>

        {#if accounts.length === 0}
          <div class="text-center py-12 text-gray-500">
            No accounts found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
