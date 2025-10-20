<!-- app/frontend/pages/settings/Account.svelte -->
<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'

  let { account, is_admin } = $props()

  const form = useForm({
    name: account.name,
    subdomain: account.subdomain
  })

  function submit() {
    $form.patch(`/accounts/${account.id}`, {
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
        <CardTitle>Paramètres du compte</CardTitle>
        <CardDescription>Gérez les informations de votre compte</CardDescription>
      </CardHeader>
      <CardContent>
        {#if !is_admin}
          <Alert class="mb-6">
            <AlertDescription>
              Seuls les administrateurs du compte peuvent modifier ces paramètres.
            </AlertDescription>
          </Alert>
        {/if}

        <form onsubmit={submit}>
          <div class="space-y-6">
            <!-- Account Name -->
            <div class="space-y-2">
              <Label for="name">Nom du compte</Label>
              <Input
                type="text"
                id="name"
                bind:value={$form.name}
                disabled={!is_admin}
              />
              {#if $form.errors.name}
                <p class="text-sm text-destructive">{$form.errors.name}</p>
              {/if}
            </div>

            <!-- Subdomain -->
            <div class="space-y-2">
              <Label for="subdomain">Sous-domaine</Label>
              <Input
                type="text"
                id="subdomain"
                bind:value={$form.subdomain}
                disabled={!is_admin}
              />
              {#if $form.errors.subdomain}
                <p class="text-sm text-destructive">{$form.errors.subdomain}</p>
              {/if}
              <p class="text-xs text-muted-foreground">
                Utilisé pour les domaines personnalisés et l'accès API
              </p>
            </div>

            <!-- Plan Type (read-only) -->
            <div class="space-y-2">
              <Label>Plan actuel</Label>
              <div class="px-3 py-2 bg-muted border rounded-md text-sm">
                {account.plan_type || 'Gratuit'}
              </div>
              <p class="text-xs text-muted-foreground">
                Gérez votre abonnement dans <a href="/settings/billing" class="text-primary hover:underline">Facturation</a>
              </p>
            </div>
          </div>

          {#if is_admin}
            <div class="mt-6 flex justify-end">
              <Button
                type="submit"
                disabled={$form.processing}
              >
                {$form.processing ? 'Enregistrement...' : 'Enregistrer les modifications'}
              </Button>
            </div>
          {/if}
        </form>
      </CardContent>
    </Card>
  {/snippet}
</SettingsLayout>
