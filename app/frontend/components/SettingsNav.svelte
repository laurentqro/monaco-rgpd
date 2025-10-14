<!-- app/frontend/components/SettingsNav.svelte -->
<script>
  import { page } from '@inertiajs/svelte'

  const currentPath = $derived($page.url.split('?')[0].split('#')[0])

  const navItems = [
    { name: 'Profile', path: '/settings/profile', icon: 'user' },
    { name: 'Account', path: '/settings/account', icon: 'building' },
    { name: 'Team', path: '/settings/team', icon: 'users' },
    { name: 'Billing', path: '/settings/billing', icon: 'credit-card' },
    { name: 'Notifications', path: '/settings/notifications', icon: 'bell' }
  ]

  function isActive(path) {
    return currentPath === path
  }
</script>

<nav class="space-y-1">
  {#each navItems as item}
    <a
      href={item.path}
      class="flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors {
        isActive(item.path)
          ? 'bg-blue-50 text-blue-700'
          : 'text-gray-700 hover:bg-gray-100'
      }"
    >
      <span class="truncate">{item.name}</span>
    </a>
  {/each}
</nav>
