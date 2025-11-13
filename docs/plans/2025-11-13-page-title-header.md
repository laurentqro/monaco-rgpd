# Page Title Header Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace breadcrumb navigation with a simple page title in the header, and add logout button to the header.

**Architecture:** Update AppLayout component to accept a title prop and display it as an h1 in the header. Add logout button to the right side of the header. Remove h1 elements from individual page components.

**Tech Stack:** Svelte 5, Inertia.js 3.x, shadcn/ui components

---

## Task 1: Update AppLayout Component

**Files:**
- Modify: `app/frontend/lib/layouts/AppLayout.svelte`
- Remove imports: breadcrumb components, ChevronRight, generateBreadcrumbs

**Step 1: Update AppLayout.svelte to accept title prop and add logout button**

Replace the entire file with:

```svelte
<script>
  import { page } from '@inertiajs/svelte'
  import { router } from '@inertiajs/svelte'
  import { SidebarProvider, SidebarInset, SidebarTrigger } from '$lib/components/ui/sidebar'
  import { Separator } from '$lib/components/ui/separator'
  import { Button } from '$lib/components/ui/button'
  import AppSidebar from '$lib/components/navigation/AppSidebar.svelte'
  import { Toaster } from '$lib/components/ui/sonner'
  import ImpersonationBanner from '$lib/components/ImpersonationBanner.svelte'
  import { LogOut } from 'lucide-svelte'

  let { children, title } = $props()

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
```

**Step 2: Verify syntax**

Run: `npm run build`
Expected: Build succeeds without errors

**Step 3: Commit**

```bash
git add app/frontend/lib/layouts/AppLayout.svelte
git commit -m "feat: replace breadcrumbs with page title and add logout button to header"
```

---

## Task 2: Update Questionnaires Index Page

**Files:**
- Modify: `app/frontend/pages/Questionnaires/Index.svelte`

**Step 1: Add title prop and remove h1 from content**

In `app/frontend/pages/Questionnaires/Index.svelte`, change line 22 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Questionnaires">
```

Then remove lines 24-31 (the entire header div with h1 and description):

```svelte
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Questionnaires</h1>
        <p class="text-muted-foreground mt-1">
          Évaluez votre conformité RGPD avec nos questionnaires guidés
        </p>
      </div>
    </div>
```

And add the description as a standalone element after `<div class="flex flex-col gap-6">` (line 23):

```svelte
  <div class="flex flex-col gap-6">
    <p class="text-muted-foreground">
      Évaluez votre conformité RGPD avec nos questionnaires guidés
    </p>
```

**Step 2: Commit**

```bash
git add app/frontend/pages/Questionnaires/Index.svelte
git commit -m "refactor: use AppLayout title prop in Questionnaires index"
```

---

## Task 3: Update Documents Index Page

**Files:**
- Modify: `app/frontend/pages/Documents/Index.svelte`

**Step 1: Add title prop and remove h1 from content**

In `app/frontend/pages/Documents/Index.svelte`, change line 80 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Documents">
```

Then remove lines 82-87 (the header div with h1 and description):

```svelte
    <div>
      <h1 class="text-3xl font-bold tracking-tight">Documents</h1>
      <p class="text-muted-foreground mt-2">
        Générez vos documents de conformité RGPD
      </p>
    </div>
```

And add the description as a standalone element after `<div class="flex flex-col gap-6">` (line 81):

```svelte
  <div class="flex flex-col gap-6">
    <p class="text-muted-foreground">
      Générez vos documents de conformité RGPD
    </p>
```

**Step 2: Commit**

```bash
git add app/frontend/pages/Documents/Index.svelte
git commit -m "refactor: use AppLayout title prop in Documents index"
```

---

## Task 4: Update Dashboard Page

**Files:**
- Modify: `app/frontend/pages/Dashboard/Show.svelte`

**Step 1: Add title prop and remove h1 and logout button from content**

In `app/frontend/pages/Dashboard/Show.svelte`, change line 44 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Tableau de bord de conformité">
```

Then remove lines 47-69 (the entire header with h1 and buttons):

```svelte
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold">Tableau de bord de conformité</h1>
      <div class="flex items-center gap-4">
        {#if latest_assessment && questionnaire_id}
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Nouvelle évaluation
          </Button>
        {/if}
        <Button
          variant="outline"
          onclick={() => router.delete('/session')}
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Déconnexion
        </Button>
      </div>
    </div>
```

Keep only the "Nouvelle évaluation" button and move it right before the first `{#if latest_assessment}` block (around line 72):

```svelte
    {#if latest_assessment && questionnaire_id}
      <div class="mb-6">
        <Button
          onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle évaluation
        </Button>
      </div>
    {/if}

    {#if latest_assessment}
```

**Step 2: Commit**

```bash
git add app/frontend/pages/Dashboard/Show.svelte
git commit -m "refactor: use AppLayout title prop in Dashboard and remove duplicate logout button"
```

---

## Task 5: Update ProcessingActivities Index Page

**Files:**
- Modify: `app/frontend/pages/ProcessingActivities/Index.svelte`

**Step 1: Add title prop and remove h1 from content**

In `app/frontend/pages/ProcessingActivities/Index.svelte`, change line 21 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Registre des traitements">
```

Then remove lines 24-29 (the header div with h1 and description):

```svelte
      <div class="mb-8">
        <h1 class="text-3xl font-bold mb-2">Registre des traitements</h1>
        <p class="text-gray-600">
          Gérez vos activités de traitement conformément à l'article 27 de la Loi n° 1.565 relative à la protection des données personnelles
        </p>
      </div>
```

And add the description as a standalone element after `<div class="max-w-7xl mx-auto px-4 py-8">` (line 23):

```svelte
    <div class="max-w-7xl mx-auto px-4 py-8">
      <p class="text-gray-600 mb-6">
        Gérez vos activités de traitement conformément à l'article 27 de la Loi n° 1.565 relative à la protection des données personnelles
      </p>
```

**Step 2: Commit**

```bash
git add app/frontend/pages/ProcessingActivities/Index.svelte
git commit -m "refactor: use AppLayout title prop in ProcessingActivities index"
```

---

## Task 6: Update ProcessingActivities Show Page

**Files:**
- Modify: `app/frontend/pages/ProcessingActivities/Show.svelte`

**Step 1: Read the file to understand its structure**

Run: `cat app/frontend/pages/ProcessingActivities/Show.svelte | head -30`

**Step 2: Add title prop**

Find the AppLayout opening tag and add the title prop with the activity name.

Change from:
```svelte
<AppLayout>
```

to:
```svelte
<AppLayout title={activity?.name || 'Activité de traitement'}>
```

Remove any h1 element in the content if present.

**Step 3: Commit**

```bash
git add app/frontend/pages/ProcessingActivities/Show.svelte
git commit -m "refactor: use AppLayout title prop in ProcessingActivities show"
```

---

## Task 7: Update Responses Index Page

**Files:**
- Modify: `app/frontend/pages/Responses/Index.svelte`

**Step 1: Add title prop and remove h1 from content**

In `app/frontend/pages/Responses/Index.svelte`, change line 56 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Historique des évaluations">
```

Then remove lines 59-69 (the header div with h1 and back button):

```svelte
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold">Historique des évaluations</h1>
      <Button
        variant="ghost"
        onclick={() => router.visit('/dashboard')}
      >
        <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Retour au tableau de bord
      </Button>
    </div>
```

Optionally keep the back button by moving it before the content, if desired:

```svelte
    <div class="mb-6">
      <Button
        variant="ghost"
        onclick={() => router.visit('/dashboard')}
      >
        <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Retour au tableau de bord
      </Button>
    </div>
```

**Step 2: Commit**

```bash
git add app/frontend/pages/Responses/Index.svelte
git commit -m "refactor: use AppLayout title prop in Responses index"
```

---

## Task 8: Update Responses Show Page

**Files:**
- Modify: `app/frontend/pages/Responses/Show.svelte`

**Step 1: Read the file to understand its structure**

Run: `cat app/frontend/pages/Responses/Show.svelte | head -50`

**Step 2: Add title prop**

Find the AppLayout opening tag and add a suitable title prop (e.g., "Réponse au questionnaire" or use dynamic content if available).

Remove any h1 element in the content if present.

**Step 3: Commit**

```bash
git add app/frontend/pages/Responses/Show.svelte
git commit -m "refactor: use AppLayout title prop in Responses show"
```

---

## Task 9: Update Responses Results Page

**Files:**
- Modify: `app/frontend/pages/Responses/Results.svelte`

**Step 1: Read the file to understand its structure**

Run: `cat app/frontend/pages/Responses/Results.svelte | head -50`

**Step 2: Add title prop**

Find the AppLayout opening tag and add title prop (e.g., "Résultats de conformité").

Remove any h1 element in the content if present.

**Step 3: Commit**

```bash
git add app/frontend/pages/Responses/Results.svelte
git commit -m "refactor: use AppLayout title prop in Responses results"
```

---

## Task 10: Update Questionnaires Show Page

**Files:**
- Modify: `app/frontend/pages/Questionnaires/Show.svelte`

**Step 1: Read the file to understand its structure**

Run: `cat app/frontend/pages/Questionnaires/Show.svelte | head -50`

**Step 2: Add title prop**

Find the AppLayout opening tag and add title prop with questionnaire title if available.

Remove any h1 element in the content if present.

**Step 3: Commit**

```bash
git add app/frontend/pages/Questionnaires/Show.svelte
git commit -m "refactor: use AppLayout title prop in Questionnaires show"
```

---

## Task 11: Update Chat Show Page

**Files:**
- Modify: `app/frontend/pages/Chat/Show.svelte`

**Step 1: Read the file to understand its structure**

Run: `cat app/frontend/pages/Chat/Show.svelte | head -50`

**Step 2: Add title prop**

Find the AppLayout opening tag and add title prop (e.g., "Conversation" or use questionnaire title).

Remove any h1 element in the content if present.

**Step 3: Commit**

```bash
git add app/frontend/pages/Chat/Show.svelte
git commit -m "refactor: use AppLayout title prop in Chat show"
```

---

## Task 12: Update App Page

**Files:**
- Modify: `app/frontend/pages/App.svelte`

**Step 1: Add title prop**

In `app/frontend/pages/App.svelte`, change line 9 from:

```svelte
<AppLayout>
```

to:

```svelte
<AppLayout title="Application">
```

Note: This page doesn't have an h1 to remove, just needs the title prop.

**Step 2: Commit**

```bash
git add app/frontend/pages/App.svelte
git commit -m "refactor: use AppLayout title prop in App page"
```

---

## Task 13: Remove Breadcrumbs Utility

**Files:**
- Delete: `app/frontend/lib/utils/breadcrumbs.js`

**Step 1: Remove the breadcrumbs utility file**

Run:
```bash
git rm app/frontend/lib/utils/breadcrumbs.js
```

**Step 2: Commit**

```bash
git commit -m "refactor: remove unused breadcrumbs utility"
```

---

## Task 14: Verify and Test

**Step 1: Build the frontend**

Run: `npm run build`
Expected: Build completes successfully without errors

**Step 2: Start the development server**

Run: `bin/rails server`

**Step 3: Manual testing checklist**

Visit each page and verify:
- [ ] Dashboard - shows "Tableau de bord de conformité" in header, logout button visible
- [ ] Questionnaires - shows "Questionnaires" in header
- [ ] Documents - shows "Documents" in header
- [ ] Responses Index - shows "Historique des évaluations" in header
- [ ] Processing Activities - shows "Registre des traitements" in header
- [ ] No h1 elements in main content area
- [ ] Logout button works and redirects to sign-in
- [ ] Description text still visible on pages that had it

**Step 4: Run automated tests**

Run: `bin/rails test`
Expected: All tests pass

**Step 5: Final commit if any fixes needed**

If any issues found during testing, fix them and commit:
```bash
git add <files>
git commit -m "fix: address issues found during testing"
```

---

## Completion

When all tasks are complete:
1. Verify all commits are made
2. Build passes without errors
3. All manual tests pass
4. Automated tests pass
5. Ready for code review or merge
