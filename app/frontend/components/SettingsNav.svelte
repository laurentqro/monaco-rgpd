<!-- app/frontend/components/SettingsNav.svelte -->
<script>
  import { Tabs, TabsList, TabsTrigger } from '$lib/components/ui/tabs';
  import { page } from '@inertiajs/svelte';
  import { router } from '@inertiajs/svelte';

  const currentPath = $derived($page.url.split('?')[0].split('#')[0]);
</script>

<Tabs value={currentPath} class="w-full">
  <TabsList class="grid w-full grid-cols-5">
    <TabsTrigger
      value="/settings/profile"
      onclick={() => router.visit('/settings/profile')}
    >
      Profil
    </TabsTrigger>
    <TabsTrigger
      value="/settings/account"
      onclick={() => router.visit('/settings/account')}
    >
      Compte
    </TabsTrigger>
    <TabsTrigger
      value="/settings/billing"
      onclick={() => router.visit('/settings/billing')}
    >
      Facturation
    </TabsTrigger>
    <TabsTrigger
      value="/settings/team"
      onclick={() => router.visit('/settings/team')}
    >
      Équipe
    </TabsTrigger>
    <TabsTrigger
      value="/settings/notifications"
      onclick={() => router.visit('/settings/notifications')}
    >
      Notifications
    </TabsTrigger>
  </TabsList>
</Tabs>
