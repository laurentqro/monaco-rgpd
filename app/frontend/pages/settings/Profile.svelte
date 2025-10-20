<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'

  let { user } = $props()

  const form = useForm({
    name: user.name || '',
    email: user.email,
    avatar_url: user.avatar_url || ''
  })

  function submit() {
    $form.patch(`/users/${user.id}`, {
      onSuccess: () => {
        // Success message shown via toast notification from SettingsLayout
      }
    })
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <Card>
      <CardHeader>
        <CardTitle>Paramètres du profil</CardTitle>
        <CardDescription>Gérez vos informations personnelles</CardDescription>
      </CardHeader>
      <CardContent>
        <form onsubmit={submit}>
          <div class="space-y-6">
            <!-- Name -->
            <div class="space-y-2">
              <Label for="name">Nom</Label>
              <Input
                type="text"
                id="name"
                bind:value={$form.name}
              />
              {#if $form.errors.name}
                <p class="text-sm text-destructive">{$form.errors.name}</p>
              {/if}
            </div>

            <!-- Email -->
            <div class="space-y-2">
              <Label for="email">Email</Label>
              <Input
                type="email"
                id="email"
                bind:value={$form.email}
              />
              {#if $form.errors.email}
                <p class="text-sm text-destructive">{$form.errors.email}</p>
              {/if}
            </div>

            <!-- Avatar URL -->
            <div class="space-y-2">
              <Label for="avatar_url">URL de l'avatar</Label>
              <Input
                type="url"
                id="avatar_url"
                bind:value={$form.avatar_url}
                placeholder="https://example.com/avatar.jpg"
              />
              {#if $form.errors.avatar_url}
                <p class="text-sm text-destructive">{$form.errors.avatar_url}</p>
              {/if}
            </div>
          </div>

          <div class="mt-6 flex justify-end">
            <Button
              type="submit"
              disabled={$form.processing}
            >
              {$form.processing ? 'Enregistrement...' : 'Enregistrer les modifications'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  {/snippet}
</SettingsLayout>
