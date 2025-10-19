<script>
  import AdminLayout from '../../../components/AdminLayout.svelte'
  import { useForm, router } from '@inertiajs/svelte'
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '$lib/components/ui/table'
  import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '$lib/components/ui/dialog'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Button } from '$lib/components/ui/button'

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
        <Dialog bind:open={showForm}>
          <DialogTrigger asChild let:builder>
            <Button builders={[builder]}>Add Admin</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Create New Admin</DialogTitle>
            </DialogHeader>
            <form onsubmit={submit} class="space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label for="email">Email</Label>
                  <Input
                    type="email"
                    id="email"
                    bind:value={$form.email}
                    required
                  />
                </div>
                <div class="space-y-2">
                  <Label for="name">Name</Label>
                  <Input
                    type="text"
                    id="name"
                    bind:value={$form.name}
                    required
                  />
                </div>
                <div class="space-y-2">
                  <Label for="password">Password</Label>
                  <Input
                    type="password"
                    id="password"
                    bind:value={$form.password}
                    required
                    minlength="8"
                  />
                </div>
                <div class="space-y-2">
                  <Label for="password_confirmation">Confirm Password</Label>
                  <Input
                    type="password"
                    id="password_confirmation"
                    bind:value={$form.password_confirmation}
                    required
                  />
                </div>
              </div>
              <Button
                type="submit"
                disabled={$form.processing}
                class="w-full"
              >
                {$form.processing ? 'Creating...' : 'Create Admin'}
              </Button>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <!-- Admins table -->
      <div class="overflow-hidden rounded-lg border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Email</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each admins as admin}
              <TableRow>
                <TableCell class="font-medium">{admin.email}</TableCell>
                <TableCell>{admin.name}</TableCell>
                <TableCell>
                  {new Date(admin.created_at).toLocaleDateString()}
                </TableCell>
                <TableCell class="text-right">
                  <Button
                    variant="ghost"
                    onclick={() => deleteAdmin(admin.id)}
                    class="text-red-600 hover:text-red-900"
                  >
                    Delete
                  </Button>
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>
      </div>
    </div>
  {/snippet}
</AdminLayout>
