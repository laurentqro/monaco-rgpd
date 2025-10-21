<script>
  import { page } from '@inertiajs/svelte'
  import { SidebarProvider, SidebarInset, SidebarTrigger } from '$lib/components/ui/sidebar'
  import { Separator } from '$lib/components/ui/separator'
  import AppSidebar from '$lib/components/navigation/AppSidebar.svelte'
  import { Toaster } from '$lib/components/ui/sonner'
  import ImpersonationBanner from '$lib/components/ImpersonationBanner.svelte'

  let { children } = $props()

  // Get current URL from Inertia page
  const currentUrl = $derived($page.url)
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
      <div class="flex items-center gap-2 flex-1">
        <!-- Breadcrumbs or page title can go here -->
      </div>
    </header>
    <main class="flex flex-1 flex-col gap-4 p-4">
      {@render children()}
    </main>
  </SidebarInset>
</SidebarProvider>

<Toaster />
