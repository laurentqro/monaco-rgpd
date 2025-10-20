<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Button } from '$lib/components/ui/button'

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
          <Button variant="secondary" onclick={impersonateUser}>
            Impersonate
          </Button>
          <Button variant="destructive" onclick={deleteUser}>
            Delete User
          </Button>
        </div>
      </div>

      <!-- User details -->
      <Card class="mb-6">
        <CardContent class="pt-6">
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
        </CardContent>
      </Card>

      <!-- Recent sessions -->
      <Card>
        <CardHeader>
          <CardTitle>Recent Sessions</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="overflow-hidden rounded-lg border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>IP Address</TableHead>
                  <TableHead>User Agent</TableHead>
                  <TableHead>Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {#each sessions as session}
                  <TableRow>
                    <TableCell>{session.ip_address}</TableCell>
                    <TableCell>{session.user_agent}</TableCell>
                    <TableCell>
                      {new Date(session.created_at).toLocaleString()}
                    </TableCell>
                  </TableRow>
                {/each}
              </TableBody>
            </Table>

            {#if sessions.length === 0}
              <div class="text-center py-8 text-gray-500">
                No recent sessions
              </div>
            {/if}
          </div>
        </CardContent>
      </Card>
    </div>
  {/snippet}
</AdminLayout>
