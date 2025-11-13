<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte';
  import { router } from '@inertiajs/svelte';
  import { Button } from '$lib/components/ui/button';
  import { Input } from '$lib/components/ui/input';
  import { Label } from '$lib/components/ui/label';
  import * as Card from '$lib/components/ui/card';
  import * as Alert from '$lib/components/ui/alert';

  let { response, features_needed, partial_results } = $props();

  let email = $state('');
  let loading = $state(false);
  let error = $state('');

  // Generate human-readable feature descriptions
  const featureDescriptions = {
    association: "un cadre spécifique pour les associations",
    organisme_public: "un cadre spécifique pour les organismes publics",
    profession_liberale: "un cadre spécifique pour les professions libérales",
    video_surveillance: "une analyse personnalisée pour la vidéosurveillance",
    geographic_expansion: "l'expansion géographique"
  };

  const featuresText = features_needed
    .map(f => featureDescriptions[f] || f)
    .join(" et ");

  function handleSubmit(event) {
    event.preventDefault();
    loading = true;
    error = '';

    router.post('/waitlist_entries', {
      waitlist_entry: {
        email,
        response_id: response.id
      }
    }, {
      onFinish: () => loading = false,
      onError: (errors) => {
        error = errors?.email?.[0] || 'Une erreur est survenue. Veuillez réessayer.'
      }
    });
  }

  function handleSkip() {
    router.visit('/dashboard');
  }
</script>

<AppLayout>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <!-- Header -->
      <div class="mb-8">
        <Button
          variant="ghost"
          onclick={() => router.visit('/dashboard')}
          class="mb-4"
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Retour au tableau de bord
        </Button>
        <h1 class="text-3xl font-bold text-gray-900">Votre évaluation partielle RGPD</h1>
      </div>

      <!-- Partial Results Section -->
      <Card.Root class="mb-8">
        <Card.Header>
          <Card.Title class="text-xl">Obligations de base identifiées</Card.Title>
        </Card.Header>
        <Card.Content>
          <ul class="list-disc list-inside space-y-2 mb-6">
            {#each partial_results.basic_obligations as obligation}
              <li class="text-gray-700">{obligation}</li>
            {/each}
          </ul>

          <h3 class="text-lg font-semibold mb-4">Recommandations générales</h3>
          <ul class="list-disc list-inside space-y-2">
            {#each partial_results.recommendations as recommendation}
              <li class="text-gray-700">{recommendation}</li>
            {/each}
          </ul>
        </Card.Content>
      </Card.Root>

      <hr class="my-8 border-gray-200" />

      <!-- Waitlist Section -->
      <Alert.Root class="mb-6 border-amber-300 bg-amber-50">
        <Alert.Title class="text-amber-800 font-semibold text-lg mb-2">
          ⚠️ Évaluation incomplète
        </Alert.Title>
        <Alert.Description class="text-amber-700">
          <p class="mb-2">
            Votre cas nécessite {featuresText} que nous développons actuellement.
          </p>
          <p>
            Laissez votre email pour recevoir votre évaluation complète dès que cette
            fonctionnalité sera disponible.
          </p>
        </Alert.Description>
      </Alert.Root>

      <Card.Root>
        <Card.Header>
          <Card.Title>Recevoir l'évaluation complète</Card.Title>
        </Card.Header>
        <Card.Content>
          <form onsubmit={handleSubmit} class="space-y-4">
            <div>
              <Label for="email">Email</Label>
              <Input
                id="email"
                type="email"
                bind:value={email}
                placeholder="votre@email.com"
                required
                disabled={loading}
                class="mt-1"
              />
              {#if error}
                <p class="mt-2 text-sm text-red-600">{error}</p>
              {/if}
            </div>

            <div class="flex gap-4">
              <Button type="submit" disabled={loading} class="flex-1">
                {loading ? 'Envoi...' : 'Recevoir l\'évaluation complète'}
              </Button>

              <Button
                type="button"
                variant="outline"
                onclick={handleSkip}
                disabled={loading}
              >
                Terminer sans notification
              </Button>
            </div>
          </form>
        </Card.Content>
      </Card.Root>
    </div>
  </div>
</AppLayout>
