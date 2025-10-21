<!-- app/frontend/components/SettingsNav.svelte -->
<script>
  import { page } from '@inertiajs/svelte';
  import { router } from '@inertiajs/svelte';
  import { cn } from '$lib/utils';

  const currentPath = $derived($page.url.split('?')[0].split('#')[0]);

  const navItems = [
    { path: '/settings/profile', label: 'Profil' },
    { path: '/settings/account', label: 'Compte' },
    { path: '/settings/billing', label: 'Facturation' },
    { path: '/settings/team', label: 'Équipe' },
    { path: '/settings/notifications', label: 'Notifications' },
  ];

  function isActive(path) {
    return currentPath === path;
  }
</script>

<nav class="flex flex-col gap-1">
  {#each navItems as item (item.path)}
    <button
      onclick={() => router.visit(item.path)}
      class={cn(
        "flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors",
        isActive(item.path)
          ? "bg-primary text-primary-foreground"
          : "text-muted-foreground hover:bg-muted hover:text-foreground"
      )}
    >
      {item.label}
    </button>
  {/each}
</nav>
