<!-- app/frontend/pages/settings/Account.svelte -->
<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Textarea } from '$lib/components/ui/textarea'
  import { Select, SelectContent, SelectItem, SelectTrigger } from '$lib/components/ui/select'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'

  let { account, is_admin } = $props()

  const form = useForm({
    name: account.name,
    subdomain: account.subdomain,
    address: account.address || '',
    phone: account.phone || '',
    rci_number: account.rci_number || '',
    legal_form: account.legal_form || ''
  })

  const legalForms = [
    { value: 'sarl', label: 'Société à Responsabilité Limitée (SARL)' },
    { value: 'sam', label: 'Société Anonyme Monégasque (SAM)' },
    { value: 'snc', label: 'Société en Nom Collectif (SNC)' },
    { value: 'scs', label: 'Société en Commandite Simple (SCS)' },
    { value: 'sca', label: 'Société en Commandite par Actions (SCA)' },
    { value: 'surl', label: 'Société Unipersonnelle à Responsabilité Limitée (SURL)' },
    { value: 'sima', label: 'Société d\'Innovation Monégasque par Actions (SIMA)' },
    { value: 'ei', label: 'Entreprise Individuelle (EI)' },
    { value: 'sci', label: 'Société Civile Immobilière (SCI)' }
  ]

  let selectedLegalForm = $state(
    legalForms.find(f => f.value === account.legal_form) ||
    { value: '', label: 'Sélectionnez une forme juridique' }
  )

  function handleLegalFormChange(selected) {
    if (selected) {
      selectedLegalForm = selected
      $form.legal_form = selected.value
    }
  }

  function submit(event) {
    event.preventDefault()
    $form.patch('/account', {
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

            <!-- Address -->
            <div class="space-y-2">
              <Label for="address">Adresse complète</Label>
              <Textarea
                id="address"
                bind:value={$form.address}
                placeholder="12 Avenue des Spélugues&#10;98000 Monaco"
                rows="3"
                disabled={!is_admin}
              />
              {#if $form.errors.address}
                <p class="text-sm text-destructive">{$form.errors.address}</p>
              {/if}
              <p class="text-xs text-muted-foreground">
                Adresse complète de votre établissement (requise pour la génération de documents)
              </p>
            </div>

            <!-- Phone -->
            <div class="space-y-2">
              <Label for="phone">Téléphone</Label>
              <Input
                type="tel"
                id="phone"
                bind:value={$form.phone}
                placeholder="+377 93 15 26 00"
                disabled={!is_admin}
              />
              {#if $form.errors.phone}
                <p class="text-sm text-destructive">{$form.errors.phone}</p>
              {/if}
            </div>

            <!-- RCI Number -->
            <div class="space-y-2">
              <Label for="rci_number">Numéro RCI</Label>
              <Input
                type="text"
                id="rci_number"
                bind:value={$form.rci_number}
                placeholder="12S34567"
                disabled={!is_admin}
              />
              {#if $form.errors.rci_number}
                <p class="text-sm text-destructive">{$form.errors.rci_number}</p>
              {/if}
              <p class="text-xs text-muted-foreground">
                Répertoire du Commerce et de l'Industrie de Monaco
              </p>
            </div>

            <!-- Legal Form -->
            <div class="space-y-2">
              <Label for="legal_form">Forme juridique</Label>
              <Select
                selected={selectedLegalForm}
                onSelectedChange={handleLegalFormChange}
                disabled={!is_admin}
                multiple={false}
              >
                <SelectTrigger>
                  {selectedLegalForm.label}
                </SelectTrigger>
                <SelectContent>
                  {#each legalForms as legalForm}
                    <SelectItem value={legalForm.value} label={legalForm.label} />
                  {/each}
                </SelectContent>
              </Select>
              {#if $form.errors.legal_form}
                <p class="text-sm text-destructive">{$form.errors.legal_form}</p>
              {/if}
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
