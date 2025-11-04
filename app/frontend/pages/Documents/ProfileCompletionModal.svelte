<script>
  import { useForm } from '@inertiajs/svelte'
  import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '$lib/components/ui/dialog'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Textarea } from '$lib/components/ui/textarea'
  import { Select, SelectContent, SelectItem, SelectTrigger } from '$lib/components/ui/select'

  let { open = $bindable(false), oncompleted, oncancel } = $props()

  const form = useForm({
    address: '',
    phone: '',
    rci_number: '',
    legal_form: ''
  })

  const legalForms = [
    { value: 'sarl', label: 'Société à Responsabilité Limitée (SARL)' },
    { value: 'sam', label: 'Société Anonyme Monégasque (SAM)' },
    { value: 'snc', label: 'Société en Nom Collectif (SNC)' },
    { value: 'scs', label: 'Société en Commandite Simple (SCS)' },
    { value: 'sca', label: 'Société en Commandite par Actions (SCA)' },
    { value: 'surl', label: 'Société Unipersonnelle à Responsabilité Limitée (SURL)' },
    { value: 'sima', label: 'Société d\'Innovation Monégasque par Actions (SIMA)' },
    { value: 'ei', label: 'Entreprise Individuelle' },
    { value: 'sci', label: 'Société Civile Immobilière (SCI)' }
  ]

  function handleSubmit(event) {
    event.preventDefault()
    $form.patch('/account/complete_profile', {
      onSuccess: () => {
        oncompleted?.()
      },
      onError: (errors) => {
        console.error('Profile completion failed:', errors)
      }
    })
  }

  function handleCancel() {
    oncancel?.()
  }

  let selectedLegalForm = $state({ value: '', label: 'Sélectionnez une forme juridique' })

  function handleLegalFormChange(selected) {
    if (selected) {
      selectedLegalForm = selected
      $form.legal_form = selected.value
    }
  }
</script>

<Dialog bind:open>
  <DialogContent class="sm:max-w-[500px]">
    <DialogHeader>
      <DialogTitle>Complétez votre profil</DialogTitle>
      <DialogDescription>
        Ces informations sont nécessaires pour générer vos documents de conformité.
      </DialogDescription>
    </DialogHeader>

    <form onsubmit={handleSubmit} class="space-y-4">
      <div class="space-y-2">
        <Label for="address">Adresse complète</Label>
        <Textarea
          id="address"
          bind:value={$form.address}
          placeholder="12 Avenue des Spélugues&#10;98000 Monaco"
          rows="3"
          required
        />
        {#if $form.errors.address}
          <p class="text-sm text-destructive">{$form.errors.address}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="phone">Téléphone</Label>
        <Input
          id="phone"
          type="tel"
          bind:value={$form.phone}
          placeholder="+377 93 15 26 00"
          required
        />
        {#if $form.errors.phone}
          <p class="text-sm text-destructive">{$form.errors.phone}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="rci_number">Numéro RCI</Label>
        <Input
          id="rci_number"
          bind:value={$form.rci_number}
          placeholder="12S34567"
          required
        />
        <p class="text-xs text-muted-foreground">
          Répertoire du Commerce et de l'Industrie de Monaco
        </p>
        {#if $form.errors.rci_number}
          <p class="text-sm text-destructive">{$form.errors.rci_number}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="legal_form">Forme juridique</Label>
        <Select selected={selectedLegalForm} onSelectedChange={handleLegalFormChange} multiple={false}>
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

      <div class="flex justify-end gap-3 pt-4">
        <Button type="button" variant="outline" onclick={handleCancel}>
          Annuler
        </Button>
        <Button type="submit" disabled={$form.processing}>
          {$form.processing ? 'Enregistrement...' : 'Enregistrer et générer'}
        </Button>
      </div>
    </form>
  </DialogContent>
</Dialog>
