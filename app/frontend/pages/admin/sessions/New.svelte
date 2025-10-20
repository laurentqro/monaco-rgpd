<script>
  import { useForm } from '@inertiajs/svelte'
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Button } from '$lib/components/ui/button'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'

  let { error } = $props()

  const form = useForm({
    email: '',
    password: ''
  })

  function submit(e) {
    e.preventDefault()
    $form.post('/admin/session')
  }
</script>

<div class="min-h-screen bg-gray-100 flex items-center justify-center px-4">
  <div class="max-w-md w-full">
    <Card class="shadow-lg">
      <CardHeader>
        <CardTitle class="text-2xl">Connexion Admin</CardTitle>
      </CardHeader>

      <CardContent>
        {#if error}
          <Alert variant="destructive" class="mb-4">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        {/if}

        <form onsubmit={submit} class="space-y-4">
          <!-- Email -->
          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input
              type="email"
              id="email"
              bind:value={$form.email}
              required
            />
          </div>

          <!-- Password -->
          <div class="space-y-2">
            <Label for="password">Mot de passe</Label>
            <Input
              type="password"
              id="password"
              bind:value={$form.password}
              required
            />
          </div>

          <Button
            type="submit"
            disabled={$form.processing}
            class="w-full"
          >
            {$form.processing ? 'Connexion...' : 'Se connecter'}
          </Button>
        </form>
      </CardContent>
    </Card>
  </div>
</div>
