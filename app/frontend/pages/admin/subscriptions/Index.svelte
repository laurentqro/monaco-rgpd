<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { router } from '@inertiajs/svelte'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Badge } from '$lib/components/ui/badge'
  import { Button } from '$lib/components/ui/button'

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
        <Button
          variant={!status ? 'default' : 'outline'}
          onclick={() => filterByStatus('')}
        >
          All
        </Button>
        <Button
          variant={status === 'active' ? 'default' : 'outline'}
          onclick={() => filterByStatus('active')}
        >
          Active
        </Button>
        <Button
          variant={status === 'trialing' ? 'default' : 'outline'}
          onclick={() => filterByStatus('trialing')}
        >
          Trialing
        </Button>
        <Button
          variant={status === 'past_due' ? 'default' : 'outline'}
          onclick={() => filterByStatus('past_due')}
        >
          Past Due
        </Button>
      </div>

      <!-- Subscriptions table -->
      <div class="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Account</TableHead>
              <TableHead>Plan</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Period End</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each subscriptions as subscription}
              <TableRow>
                <TableCell class="font-medium">
                  <a href="/admin/accounts/{subscription.account.id}" class="text-blue-600 hover:text-blue-900">
                    {subscription.account.name}
                  </a>
                </TableCell>
                <TableCell>
                  {subscription.plan_type}
                </TableCell>
                <TableCell>
                  <Badge variant={
                    subscription.status === 'active' ? 'default' :
                    subscription.status === 'trialing' ? 'secondary' :
                    subscription.status === 'past_due' ? 'destructive' :
                    'outline'
                  }>
                    {subscription.status}
                  </Badge>
                </TableCell>
                <TableCell>
                  {subscription.current_period_end ? new Date(subscription.current_period_end).toLocaleDateString() : '-'}
                </TableCell>
                <TableCell>
                  {new Date(subscription.created_at).toLocaleDateString()}
                </TableCell>
                <TableCell class="text-right">
                  <a href="/admin/accounts/{subscription.account.id}" class="text-blue-600 hover:text-blue-900">
                    View Account
                  </a>
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>

        {#if subscriptions.length === 0}
          <div class="text-center py-12 text-gray-500">
            No subscriptions found
          </div>
        {/if}
      </div>
    </div>
  {/snippet}
</AdminLayout>
