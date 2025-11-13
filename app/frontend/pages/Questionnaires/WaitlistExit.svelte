<script>
  import { router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'

  let { questionnaire } = $props()
  let email = $state('')
  let loading = $state(false)

  function handleSubmit(e) {
    e.preventDefault()
    loading = true
    router.post('/waitlist_entries', {
      waitlist_entry: {
        email,
        questionnaire_response_id: null
      }
    }, {
      onFinish: () => loading = false
    })
  }

  function handleSkip() {
    router.visit('/')
  }
</script>

<div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
  <div class="max-w-md w-full space-y-8 text-center">
    <div>
      <h1 class="text-2xl font-bold text-gray-900">
        Nous ne couvrons pas encore les organisations hors de Monaco
      </h1>

      <p class="mt-4 text-gray-600">
        Nous prévoyons d'étendre nos services à d'autres pays.
        Laissez-nous votre email pour être notifié lors de notre expansion géographique.
      </p>
    </div>

    <form onsubmit={handleSubmit} class="mt-8 space-y-6">
      <div class="text-left">
        <Label for="email">Email</Label>
        <Input
          id="email"
          type="email"
          bind:value={email}
          placeholder="votre@email.com"
          required
          disabled={loading}
        />
      </div>

      <div class="flex gap-4">
        <Button type="submit" disabled={loading} class="flex-1">
          {loading ? 'Envoi...' : 'Me notifier'}
        </Button>

        <Button
          type="button"
          variant="ghost"
          onclick={handleSkip}
          disabled={loading}
        >
          Non merci
        </Button>
      </div>
    </form>

    <p class="text-sm text-gray-500">
      Note: Votre session ne sera pas sauvegardée.
    </p>
  </div>
</div>
