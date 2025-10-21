/**
 * Generate breadcrumbs from the current URL path
 * @param {string} url - Current URL path
 * @returns {Array} Array of breadcrumb objects with label and href
 */
export function generateBreadcrumbs(url) {
  // Route label mapping
  const routeLabels = {
    'dashboard': 'Tableau de bord',
    'questionnaires': 'Questionnaires',
    'processing-activities': 'Registre Article 30',
    'documents': 'Documents',
    'responses': 'Réponses',
    'settings': 'Paramètres',
    'profile': 'Profil',
    'account': 'Compte',
    'team': 'Équipe',
    'billing': 'Facturation',
    'notifications': 'Notifications',
    'results': 'Résultats',
  }

  // Always start with home
  const breadcrumbs = [
    { label: 'Accueil', href: '/dashboard' }
  ]

  // Parse URL path
  const segments = url.split('/').filter(Boolean)

  // Build breadcrumbs from segments
  let currentPath = ''
  segments.forEach((segment, index) => {
    currentPath += `/${segment}`

    // Get label from mapping or use segment as fallback
    const label = routeLabels[segment] || segment.charAt(0).toUpperCase() + segment.slice(1)

    // Don't add href to last segment (current page)
    const isLast = index === segments.length - 1

    breadcrumbs.push({
      label,
      href: isLast ? undefined : currentPath
    })
  })

  return breadcrumbs
}
