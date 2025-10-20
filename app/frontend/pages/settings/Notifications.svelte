<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
  import { Alert, AlertDescription } from '$lib/components/ui/alert'
  import { Label } from '$lib/components/ui/label'
  import { Switch } from '$lib/components/ui/switch'
  import { Separator } from '$lib/components/ui/separator'

  let { user } = $props()

  const form = useForm({
    user: {
      email_lifecycle_notifications: user.email_lifecycle_notifications
    }
  })

  function handleToggle(checked) {
    $form.user.email_lifecycle_notifications = checked
    $form.patch('/settings/notifications', {
      preserveScroll: true,
      onSuccess: () => {
        // Flash message will be handled by the server
      }
    })
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <Card>
      <CardHeader>
        <CardTitle>Notifications par email</CardTitle>
        <CardDescription>Gérez vos préférences de notifications</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="space-y-6">
          <!-- Security Emails Section -->
          <div class="space-y-3">
            <div>
              <h4 class="text-base font-semibold mb-2">Notifications de sécurité</h4>
              <p class="text-sm text-muted-foreground">
                Les emails de sécurité sont toujours envoyés pour protéger votre compte. Cela inclut les notifications concernant les changements de mot de passe, les connexions suspectes et les demandes de suppression de compte.
              </p>
            </div>
            <Alert>
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path>
              </svg>
              <AlertDescription>
                Toujours activé pour votre sécurité
              </AlertDescription>
            </Alert>
          </div>

          <Separator />

          <!-- Lifecycle Emails Section -->
          <div class="space-y-4">
            <div>
              <h4 class="text-base font-semibold mb-2">Notifications d'activité du compte</h4>
              <p class="text-sm text-muted-foreground">
                Recevez des emails concernant l'activité de votre compte tels que les messages de bienvenue, les invitations et les changements de rôle.
              </p>
            </div>

            <div class="flex items-start space-x-4 rounded-lg border p-4">
              <Switch
                checked={$form.user.email_lifecycle_notifications}
                onCheckedChange={handleToggle}
                disabled={$form.processing}
                id="lifecycle-notifications"
              />
              <div class="flex-1 space-y-1">
                <Label
                  for="lifecycle-notifications"
                  class="text-sm font-medium cursor-pointer"
                >
                  M'envoyer les notifications d'activité du compte
                </Label>
                <div class="text-sm text-muted-foreground space-y-2">
                  <p>Cela inclut :</p>
                  <ul class="list-disc list-inside space-y-1 ml-2">
                    <li>Emails de bienvenue</li>
                    <li>Invitations d'équipe</li>
                    <li>Changements de rôle</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  {/snippet}
</SettingsLayout>
