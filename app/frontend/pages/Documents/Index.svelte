<script>
  import AppLayout from '$lib/layouts/AppLayout.svelte'
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '$lib/components/ui/card'

  let { documents = [] } = $props()
</script>

<AppLayout>
  <div class="flex flex-col gap-4">
    <div>
      <h1 class="text-3xl font-bold">Documents</h1>
      <p class="text-muted-foreground">
        Générez et gérez vos documents de conformité RGPD
      </p>
    </div>

    <Card>
      <CardHeader>
        <CardTitle>Vos documents</CardTitle>
        <CardDescription>
          Aucun document généré pour le moment
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
