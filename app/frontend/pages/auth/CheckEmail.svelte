<script>
  import { router } from '@inertiajs/svelte'
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card'
  import { Button } from '$lib/components/ui/button'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'

  let { email } = $props()

  function backToSignIn() {
    router.visit('/session/new')
  }
</script>

<div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
  <div class="w-full max-w-md">
    <Card class="shadow-xl">
      <!-- Success icon -->
      <div class="flex justify-center pt-6">
        <div class="rounded-full bg-green-100 p-3">
          <svg class="w-16 h-16 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 19v-8.93a2 2 0 01.89-1.664l7-4.666a2 2 0 012.22 0l7 4.666A2 2 0 0121 10.07V19M3 19a2 2 0 002 2h14a2 2 0 002-2M3 19l6.75-4.5M21 19l-6.75-4.5M3 10l6.75 4.5M21 10l-6.75 4.5m0 0l-1.14.76a2 2 0 01-2.22 0l-1.14-.76" />
          </svg>
        </div>
      </div>

      <CardHeader class="text-center">
        <CardTitle class="text-3xl">Vérifiez votre email</CardTitle>
        <CardDescription class="space-y-2">
          <p>Nous avons envoyé un lien magique à</p>
          <p class="text-lg font-semibold text-primary">
            {email}
          </p>
        </CardDescription>
      </CardHeader>

      <CardContent class="space-y-4">
        <!-- Instructions -->
        <Alert>
          <AlertDescription>
            <h3 class="font-medium mb-2">Que faire ensuite</h3>
            <ol class="list-decimal list-inside space-y-1 text-sm">
              <li>Ouvrez votre boîte de réception</li>
              <li>Trouvez l'email de MonacoRGPD</li>
              <li>Cliquez sur le lien magique dans l'email</li>
              <li>Vous serez automatiquement connecté</li>
            </ol>
          </AlertDescription>
        </Alert>

        <!-- Additional info -->
        <Alert variant="default">
          <AlertDescription>
            <h3 class="font-medium mb-2">Vous n'avez pas reçu l'email ?</h3>
            <ul class="text-sm space-y-1">
              <li class="flex items-start">
                <span class="mr-2">•</span>
                <span>Vérifiez votre dossier spam ou courrier indésirable</span>
              </li>
              <li class="flex items-start">
                <span class="mr-2">•</span>
                <span>Assurez-vous d'avoir entré la bonne adresse email</span>
              </li>
              <li class="flex items-start">
                <span class="mr-2">•</span>
                <span>Attendez quelques minutes - cela peut prendre un moment</span>
              </li>
            </ul>
          </AlertDescription>
        </Alert>

        <!-- Back to sign in -->
        <Button
          variant="outline"
          onclick={backToSignIn}
          class="w-full"
        >
          Retour à la connexion
        </Button>

        <!-- Footer note -->
        <p class="text-xs text-center text-muted-foreground">
          Le lien magique expirera dans 15 minutes pour des raisons de sécurité
        </p>
      </CardContent>
    </Card>
  </div>
</div>
