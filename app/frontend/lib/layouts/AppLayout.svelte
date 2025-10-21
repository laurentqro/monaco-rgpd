<script>
  import { page } from '@inertiajs/svelte'
  import { router } from '@inertiajs/svelte'
  import { SidebarProvider, SidebarInset, SidebarTrigger } from '$lib/components/ui/sidebar'
  import { Separator } from '$lib/components/ui/separator'
  import * as Breadcrumb from '$lib/components/ui/breadcrumb'
  import { ChevronRight } from '@lucide/svelte'
  import AppSidebar from '$lib/components/navigation/AppSidebar.svelte'
  import { Toaster } from '$lib/components/ui/sonner'
  import ImpersonationBanner from '$lib/components/ImpersonationBanner.svelte'
  import { generateBreadcrumbs } from '$lib/utils/breadcrumbs'

  let { children } = $props()

  // Get current URL from Inertia page
  const currentUrl = $derived($page.url)

  // Generate breadcrumbs from current URL
  const breadcrumbs = $derived(generateBreadcrumbs(currentUrl))
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
      <Breadcrumb.Root>
        <Breadcrumb.List>
          {#each breadcrumbs as crumb, index (crumb.href || crumb.label)}
            {#if index > 0}
              <Breadcrumb.Separator>
                <ChevronRight class="size-4" />
              </Breadcrumb.Separator>
            {/if}
            <Breadcrumb.Item>
              {#if crumb.href}
                <Breadcrumb.Link onclick={() => router.visit(crumb.href)}>
                  {crumb.label}
                </Breadcrumb.Link>
              {:else}
                <Breadcrumb.Page>{crumb.label}</Breadcrumb.Page>
              {/if}
            </Breadcrumb.Item>
          {/each}
        </Breadcrumb.List>
      </Breadcrumb.Root>
    </header>
    <main class="flex flex-1 flex-col gap-4 p-4">
      {@render children()}
    </main>
  </SidebarInset>
</SidebarProvider>

<Toaster />
