<script>
  import { router } from '@inertiajs/svelte'
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Button } from '$lib/components/ui/button'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'
  import { Separator } from '$lib/components/ui/separator'

  let { errors = [] } = $props()

  let email = $state('')
  let name = $state('')
  let accountName = $state('')
  let isSubmitting = $state(false)
  let emailError = $state('')

  function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  function handleSubmit(event) {
    event.preventDefault()

    // Reset errors
    emailError = ''

    // Validate email
    if (!email) {
      emailError = 'Email is required'
      return
    }

    if (!validateEmail(email)) {
      emailError = 'Please enter a valid email address'
      return
    }

    isSubmitting = true

    router.post('/magic_links', {
      email,
      name: name || undefined,
      account_name: accountName || undefined
    }, {
      onFinish: () => {
        isSubmitting = false
      }
    })
  }
</script>

<div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
  <div class="w-full max-w-md">
    <Card class="shadow-xl">
      <CardHeader class="text-center">
        <CardTitle class="text-3xl">MonacoRGPD</CardTitle>
        <CardDescription>Connectez-vous avec votre email pour commencer</CardDescription>
      </CardHeader>

      <CardContent>
        <!-- Error messages -->
        {#if errors && errors.length > 0}
          <Alert variant="destructive" class="mb-6">
            <AlertDescription>
              <div class="space-y-1">
                <p class="font-medium">
                  {errors.length === 1 ? 'Une erreur est survenue' : 'Des erreurs sont survenues'} :
                </p>
                <ul class="list-disc list-inside space-y-1 mt-2">
                  {#each errors as error, i (i)}
                    <li>{error}</li>
                  {/each}
                </ul>
              </div>
            </AlertDescription>
          </Alert>
        {/if}

        <!-- Form -->
        <form onsubmit={handleSubmit} class="space-y-6">
          <!-- Email field -->
          <div class="space-y-2">
            <Label for="email">Adresse email *</Label>
            <Input
              id="email"
              type="email"
              bind:value={email}
              required
              disabled={isSubmitting}
              placeholder="vous@exemple.com"
              aria-describedby={emailError ? "email-error" : undefined}
              aria-invalid={emailError ? "true" : undefined}
            />
            {#if emailError}
              <p id="email-error" class="text-sm text-destructive">
                {emailError}
              </p>
            {/if}
          </div>

          <!-- Optional divider -->
          <div class="relative flex items-center">
            <Separator class="flex-1" />
            <span class="px-2 text-sm text-muted-foreground">Optionnel pour les nouveaux utilisateurs</span>
            <Separator class="flex-1" />
          </div>

          <!-- Name field -->
          <div class="space-y-2">
            <Label for="name">Votre nom</Label>
            <Input
              id="name"
              type="text"
              bind:value={name}
              disabled={isSubmitting}
              placeholder="Jean Dupont"
            />
            <p class="text-xs text-muted-foreground">
              Nécessaire uniquement pour les nouveaux comptes
            </p>
          </div>

          <!-- Account name field -->
          <div class="space-y-2">
            <Label for="account-name">Nom du compte</Label>
            <Input
              id="account-name"
              type="text"
              bind:value={accountName}
              disabled={isSubmitting}
              placeholder="Mon Entreprise"
            />
            <p class="text-xs text-muted-foreground">
              Nécessaire uniquement pour les nouveaux comptes
            </p>
          </div>

          <!-- Submit button -->
          <Button
            type="submit"
            disabled={isSubmitting}
            class="w-full"
          >
            {#if isSubmitting}
              <svg class="animate-spin -ml-1 mr-3 h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Envoi du lien magique...
            {:else}
              Envoyer le lien magique
            {/if}
          </Button>
        </form>

        <!-- Footer -->
        <div class="mt-6 text-center">
          <p class="text-xs text-muted-foreground">
            Nous vous enverrons un lien magique pour vous connecter sans mot de passe
          </p>
        </div>
      </CardContent>
    </Card>
  </div>
</div>
