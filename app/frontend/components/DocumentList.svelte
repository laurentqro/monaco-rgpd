<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import { Badge } from '$lib/components/ui/badge';

  let { documents } = $props();

  const documentTypeIcons = {
    privacy_policy: '📄',
    processing_register: '📋',
    consent_form: '✍️',
    employee_notice: '👥'
  };

  const documentTypeNames = {
    privacy_policy: 'Politique de confidentialité',
    processing_register: 'Registre des traitements',
    consent_form: 'Formulaires de consentement',
    employee_notice: 'Notice employés'
  };
</script>

<Card class="mt-8">
  <CardHeader>
    <CardTitle>Vos documents</CardTitle>
  </CardHeader>
  <CardContent>
    <div class="space-y-3">
      {#each documents as document (document.id)}
        <div class="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50">
          <div class="flex items-center space-x-3">
            <span class="text-2xl">{documentTypeIcons[document.document_type] || '📄'}</span>
            <div>
              <p class="font-medium">{documentTypeNames[document.document_type] || document.document_type}</p>
              <p class="text-sm text-muted-foreground">
                Généré le {new Date(document.generated_at).toLocaleDateString('fr-FR')}
              </p>
            </div>
          </div>
          {#if document.status === 'generating'}
            <div class="flex items-center text-muted-foreground">
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-current mr-2"></div>
              <span class="text-sm">Génération...</span>
            </div>
          {:else if document.status === 'failed'}
            <Badge variant="destructive">Erreur</Badge>
          {:else if document.download_url}
            <Button variant="default" size="sm" href={document.download_url}>
              Télécharger
            </Button>
          {:else}
            <Badge variant="secondary">Indisponible</Badge>
          {/if}
        </div>
      {/each}
    </div>
  </CardContent>
</Card>
