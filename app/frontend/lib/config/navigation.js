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
    title: 'Registre des traitements',
    url: '/registre-traitements',
    icon: 'FolderOpen',
  },
  {
    title: 'Documents',
    url: '/documents',
    icon: 'FileText',
  },
]

export const secondaryNavigation = [
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
    url: '/session',
    icon: 'LogOut',
  },
]
