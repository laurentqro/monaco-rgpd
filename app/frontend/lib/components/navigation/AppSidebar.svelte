<script>
  import { page } from '@inertiajs/svelte'
  import { router } from '@inertiajs/svelte'
  import * as Sidebar from '$lib/components/ui/sidebar'
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu'
  import { Separator } from '$lib/components/ui/separator'
  import {
    LayoutDashboard,
    ClipboardList,
    FolderOpen,
    FileText,
    Settings,
    User,
    Building,
    LogOut,
    ChevronDown,
    ChevronUp
  } from '@lucide/svelte'
  import { mainNavigation, secondaryNavigation, userMenuItems } from '$lib/config/navigation'

  let { currentUrl = $bindable('') } = $props()

  // Icon component map
  const iconMap = {
    LayoutDashboard,
    ClipboardList,
    FolderOpen,
    FileText,
    Settings,
    User,
    Building,
    LogOut,
  }

  function isActive(url) {
    return currentUrl.startsWith(url)
  }

  function handleNavigation(url) {
    router.visit(url)
  }

  function handleSignOut() {
    router.delete('/session')
  }

  // Get current user from Inertia shared props
  const currentUser = $derived($page.props.current_user)
  const currentAccount = $derived($page.props.current_account)
</script>

<Sidebar.Sidebar>
  <Sidebar.SidebarHeader>
    <div class="flex items-center gap-2 px-2 py-2">
      <div class="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
        <span class="font-bold">M</span>
      </div>
      <div class="flex flex-col gap-0.5">
        <span class="font-semibold text-sm">Monaco RGPD</span>
        {#if currentAccount?.name}
          <span class="text-xs text-muted-foreground">{currentAccount.name}</span>
        {/if}
      </div>
    </div>
  </Sidebar.SidebarHeader>

  <Sidebar.SidebarContent>
    <Sidebar.SidebarGroup>
      <Sidebar.SidebarGroupContent>
        <Sidebar.SidebarMenu>
          {#each mainNavigation as item (item.url)}
            {@const IconComponent = iconMap[item.icon]}
            <Sidebar.SidebarMenuItem>
              <Sidebar.SidebarMenuButton
                onclick={() => handleNavigation(item.url)}
                isActive={isActive(item.url)}
              >
                {#if IconComponent}
                  <IconComponent class="size-4" />
                {/if}
                <span>{item.title}</span>
              </Sidebar.SidebarMenuButton>
            </Sidebar.SidebarMenuItem>
          {/each}
        </Sidebar.SidebarMenu>
      </Sidebar.SidebarGroupContent>
    </Sidebar.SidebarGroup>

    <Sidebar.SidebarGroup class="mt-auto">
      <Sidebar.SidebarGroupContent>
        <Sidebar.SidebarMenu>
          {#each secondaryNavigation as item (item.url)}
            {@const IconComponent = iconMap[item.icon]}
            <Sidebar.SidebarMenuItem>
              <Sidebar.SidebarMenuButton
                onclick={() => handleNavigation(item.url)}
                isActive={isActive(item.url)}
              >
                {#if IconComponent}
                  <IconComponent class="size-4" />
                {/if}
                <span>{item.title}</span>
              </Sidebar.SidebarMenuButton>
            </Sidebar.SidebarMenuItem>
          {/each}
        </Sidebar.SidebarMenu>
      </Sidebar.SidebarGroupContent>
    </Sidebar.SidebarGroup>
  </Sidebar.SidebarContent>

  <Sidebar.SidebarFooter>
    <Sidebar.SidebarMenu>
      <Sidebar.SidebarMenuItem>
        <DropdownMenu.Root>
          <DropdownMenu.Trigger>
            {#snippet children({ props })}
              <Sidebar.SidebarMenuButton {...props}>
                <div class="flex items-center gap-2 flex-1">
                  <div class="flex size-8 items-center justify-center rounded-full bg-primary text-primary-foreground">
                    <User class="size-4" />
                  </div>
                  <div class="flex flex-col gap-0.5 flex-1 text-left">
                    {#if currentUser?.name}
                      <span class="text-sm font-medium">{currentUser.name}</span>
                    {/if}
                    {#if currentUser?.email}
                      <span class="text-xs text-muted-foreground">{currentUser.email}</span>
                    {/if}
                  </div>
                </div>
                <ChevronUp class="ml-auto size-4" />
              </Sidebar.SidebarMenuButton>
            {/snippet}
          </DropdownMenu.Trigger>
          <DropdownMenu.Content side="top" class="w-56">
            <DropdownMenu.Item onclick={() => handleNavigation('/settings/profile')}>
              <User class="mr-2 size-4" />
              <span>Profil</span>
            </DropdownMenu.Item>
            <DropdownMenu.Item onclick={() => handleNavigation('/settings/account')}>
              <Building class="mr-2 size-4" />
              <span>Mon compte</span>
            </DropdownMenu.Item>
            <DropdownMenu.Separator />
            <DropdownMenu.Item onclick={handleSignOut}>
              <LogOut class="mr-2 size-4" />
              <span>Se déconnecter</span>
            </DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </Sidebar.SidebarMenuItem>
    </Sidebar.SidebarMenu>
  </Sidebar.SidebarFooter>
</Sidebar.Sidebar>
