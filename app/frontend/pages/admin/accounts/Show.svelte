<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Button } from '$lib/components/ui/button'

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
        <Button variant="destructive" onclick={deleteAccount}>
          Delete Account
        </Button>
      </div>

      <!-- Account details -->
      <Card class="mb-6">
        <CardContent class="pt-6">
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
        </CardContent>
      </Card>

      <!-- Subscription -->
      {#if subscription}
        <Card class="mb-6">
          <CardHeader>
            <CardTitle>Subscription</CardTitle>
          </CardHeader>
          <CardContent>
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
          </CardContent>
        </Card>
      {/if}

      <!-- Users -->
      <Card>
        <CardHeader>
          <CardTitle>Users ({users.length})</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="overflow-hidden rounded-lg border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Email</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead class="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {#each users as user}
                  <TableRow>
                    <TableCell>{user.email}</TableCell>
                    <TableCell>{user.name || '-'}</TableCell>
                    <TableCell class="capitalize">{user.role}</TableCell>
                    <TableCell class="text-right">
                      <a href="/admin/users/{user.id}" class="text-blue-600 hover:text-blue-900">
                        View
                      </a>
                    </TableCell>
                  </TableRow>
                {/each}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  {/snippet}
</AdminLayout>
