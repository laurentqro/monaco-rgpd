<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card'

  let { activities = [] } = $props()
</script>

<AppLayout>
  <div class="flex flex-col gap-4">
    <div>
      <h1 class="text-3xl font-bold">Registre des traitements</h1>
      <p class="text-muted-foreground">
        Gérez vos activités de traitement conformément à l'article 27 de la Loi n° 1.565 relative à la protection des données personnelles
      </p>
    </div>

    <Card>
      <CardHeader>
        <CardTitle>Vos activités de traitement</CardTitle>
        <CardDescription>
          Aucune activité de traitement enregistrée pour le moment
        </CardDescription>
      </CardHeader>
      <CardContent>
        <p class="text-sm text-muted-foreground">
          Cette fonctionnalité sera disponible prochainement.
        </p>
      </CardContent>
    </Card>
  </div>
</AppLayout>
