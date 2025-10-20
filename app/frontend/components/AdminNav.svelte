<script>
  import {
    NavigationMenuRoot,
    NavigationMenuList,
    NavigationMenuItem,
    NavigationMenuLink
  } from '$lib/components/ui/navigation-menu';
  import { page } from '@inertiajs/svelte'

  const currentPath = $derived($page.url.split('?')[0].split('#')[0])

  const navItems = [
    { name: 'Dashboard', path: '/admin' },
    { name: 'Accounts', path: '/admin/accounts' },
    { name: 'Users', path: '/admin/users' },
    { name: 'Subscriptions', path: '/admin/subscriptions' },
    { name: 'Admins', path: '/admin/admins' }
  ]

  function isActive(path) {
    return currentPath === path
  }
</script>

<NavigationMenuRoot class="w-full">
  <NavigationMenuList class="flex-col items-stretch space-x-0 space-y-1">
    {#each navItems as item}
      <NavigationMenuItem class="w-full">
        <NavigationMenuLink
          href={item.path}
          active={isActive(item.path)}
          class="flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors w-full {
            isActive(item.path)
              ? 'bg-blue-50 text-blue-700'
              : 'text-gray-700 hover:bg-gray-100'
          }"
        >
          <span class="truncate">{item.name}</span>
        </NavigationMenuLink>
      </NavigationMenuItem>
    {/each}
  </NavigationMenuList>
</NavigationMenuRoot>
