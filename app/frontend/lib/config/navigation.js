/**
 * Main navigation configuration for Monaco RGPD
 * Used by AppLayout sidebar
 */

export const mainNavigation = [
  {
    title: 'Tableau de bord',
    url: '/dashboard',
    icon: 'LayoutDashboard',
  },
  {
    title: 'Questionnaires',
    url: '/questionnaires',
    icon: 'ClipboardList',
  },
  {
    title: 'Registre Article 30',
    url: '/processing-activities',
    icon: 'FolderOpen',
  },
  {
    title: 'Documents',
    url: '/documents',
    icon: 'FileText',
  },
  {
    title: 'Paramètres',
    url: '/settings',
    icon: 'Settings',
  },
]

/**
 * User menu items (shown in user dropdown at bottom of sidebar)
 */
export const userMenuItems = [
  {
    title: 'Profil',
    url: '/settings/profile',
    icon: 'User',
  },
  {
    title: 'Mon compte',
    url: '/settings/account',
    icon: 'Building',
  },
  {
    title: 'Se déconnecter',
    url: '/auth/sign-out',
    icon: 'LogOut',
  },
]
