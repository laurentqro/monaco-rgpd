<!-- app/frontend/components/UserDropdown.svelte -->
<script>
  import {
    DropdownMenu,
    DropdownMenuTrigger,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuLabel
  } from '$lib/components/ui/dropdown-menu';
  import { Button } from '$lib/components/ui/button';
  import { Avatar, AvatarFallback } from '$lib/components/ui/avatar';
  import { router, page } from '@inertiajs/svelte';

  let { user, account } = $props();

  function getInitials(name) {
    return name?.split(' ').map(n => n[0]).join('').toUpperCase() || 'U';
  }
</script>

<DropdownMenu>
  <DropdownMenuTrigger asChild let:builder>
    <Button variant="ghost" builders={[builder]} class="relative h-10 w-10 rounded-full">
      <Avatar>
        <AvatarFallback>{getInitials(user?.name || user?.email)}</AvatarFallback>
      </Avatar>
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent align="end">
    <DropdownMenuLabel>
      <div class="flex flex-col space-y-1">
        <p class="text-sm font-medium">{user?.name || user?.email}</p>
        <p class="text-xs text-gray-500">{user?.email}</p>
      </div>
    </DropdownMenuLabel>
    <DropdownMenuSeparator />
    <DropdownMenuItem onclick={() => router.visit('/settings/profile')}>
      Profil
    </DropdownMenuItem>
    {#if $page.props.is_super_admin}
      <DropdownMenuItem onclick={() => router.visit('/admin')}>
        Admin Panel
      </DropdownMenuItem>
    {/if}
    <DropdownMenuItem onclick={() => router.visit('/settings/account')}>
      Paramètres du compte
    </DropdownMenuItem>
    <DropdownMenuSeparator />
    <DropdownMenuItem onclick={() => router.delete('/session')}>
      Déconnexion
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
