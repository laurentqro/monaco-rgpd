<script>
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'
  import { Badge } from '$lib/components/ui/badge'
  import { Separator } from '$lib/components/ui/separator'

  let { subscription, is_owner } = $props()
</script>

<SettingsLayout>
  {#snippet children()}
    <Card>
      <CardHeader>
        <CardTitle>Facturation et abonnement</CardTitle>
        <CardDescription>Gérez votre abonnement et vos informations de facturation</CardDescription>
      </CardHeader>
      <CardContent>
        {#if !is_owner}
          <Alert class="mb-6">
            <AlertDescription>
              Seul le propriétaire du compte peut gérer la facturation et les abonnements.
            </AlertDescription>
          </Alert>
        {/if}

        <Card>
          <CardHeader>
            <CardTitle class="text-base">Plan actuel</CardTitle>
          </CardHeader>
          <CardContent>
            {#if subscription}
              <div class="space-y-3">
                <div class="flex justify-between items-center">
                  <span class="text-sm text-muted-foreground">Statut</span>
                  <Badge variant={subscription.status === 'active' ? 'default' : 'secondary'}>
                    {subscription.status}
                  </Badge>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-muted-foreground">Plan</span>
                  <span class="text-sm font-medium">{subscription.plan_type || 'Gratuit'}</span>
                </div>
                {#if subscription.current_period_end}
                  <div class="flex justify-between items-center">
                    <span class="text-sm text-muted-foreground">Renouvellement</span>
                    <span class="text-sm font-medium">
                      {new Date(subscription.current_period_end).toLocaleDateString('fr-FR')}
                    </span>
                  </div>
                {/if}
              </div>
            {:else}
              <p class="text-sm text-muted-foreground">
                Aucun abonnement actif. Vous utilisez actuellement le plan gratuit.
              </p>
            {/if}

            {#if is_owner}
              <Separator class="my-6" />
              <Button
                disabled
                variant="outline"
                class="w-full"
              >
                Gérer l'abonnement
              </Button>
              <p class="text-xs text-muted-foreground text-center mt-2">
                Intégration Polar.sh à venir
              </p>
            {/if}
          </CardContent>
        </Card>

        <Alert class="mt-6">
          <AlertDescription>
            <strong>Bientôt disponible :</strong> Intégration Polar.sh pour la gestion des abonnements, factures et moyens de paiement.
          </AlertDescription>
        </Alert>
      </CardContent>
    </Card>
  {/snippet}
</SettingsLayout>
