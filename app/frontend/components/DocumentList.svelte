<script>
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

<div class="bg-white rounded-lg shadow-md p-6">
  <h2 class="text-xl font-bold mb-4">Vos documents</h2>
  <div class="space-y-3">
    {#each documents as document (document.id)}
      <div class="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
        <div class="flex items-center space-x-3">
          <span class="text-2xl">{documentTypeIcons[document.document_type] || '📄'}</span>
          <div>
            <p class="font-medium">{documentTypeNames[document.document_type] || document.document_type}</p>
            <p class="text-sm text-gray-500">
              Généré le {new Date(document.generated_at).toLocaleDateString('fr-FR')}
            </p>
          </div>
        </div>
        <a
          href={document.download_url}
          class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm font-medium"
        >
          Télécharger
        </a>
      </div>
    {/each}
  </div>
</div>
