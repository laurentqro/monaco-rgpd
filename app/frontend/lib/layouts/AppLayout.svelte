<script>
  import { page } from '@inertiajs/svelte'
  import { router } from '@inertiajs/svelte'
  import { SidebarProvider, SidebarInset, SidebarTrigger } from '$lib/components/ui/sidebar'
  import { Separator } from '$lib/components/ui/separator'
  import { Button } from '$lib/components/ui/button'
  import AppSidebar from '$lib/components/navigation/AppSidebar.svelte'
  import { Toaster } from '$lib/components/ui/sonner'
  import ImpersonationBanner from '$lib/components/ImpersonationBanner.svelte'
  import { LogOut } from '@lucide/svelte'

  let { children, title = 'Application' } = $props()

  // Get current URL from Inertia page
  const currentUrl = $derived($page.url)

  function handleLogout() {
    router.delete('/session')
  }
</script>

{#if $page.props.impersonating_user}
  <ImpersonationBanner user={$page.props.impersonating_user} />
{/if}

<SidebarProvider>
  <AppSidebar currentUrl={currentUrl} />
  <SidebarInset>
    <header class="flex h-16 shrink-0 items-center gap-2 border-b px-4">
      <SidebarTrigger class="-ml-1" />
      <Separator orientation="vertical" class="mr-2 h-4" />
      <h1 class="text-2xl font-semibold tracking-tight">{title}</h1>
      <div class="ml-auto">
        <Button variant="outline" size="sm" onclick={handleLogout}>
          <LogOut class="mr-2 size-4" />
          Déconnexion
        </Button>
      </div>
    </header>
    <main class="flex flex-1 flex-col gap-4 p-4">
      {@render children()}
    </main>
  </SidebarInset>
</SidebarProvider>

<Toaster />
