# shadcn-svelte Integration Implementation Plan

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Integrate shadcn-svelte as the complete design system foundation and migrate all existing components to use shadcn-svelte primitives.

**Architecture:** Install shadcn-svelte CLI, configure for Tailwind v4 + Svelte 5, install all core UI components, then systematically migrate existing components in layers (base → composite → layout → pages).

**Tech Stack:** shadcn-svelte, Svelte 5, Tailwind CSS v4, Inertia.js, Rails 8

---

## Task 1: Initialize shadcn-svelte

**Files:**
- Modify: `package.json`
- Create: `components.json`
- Modify: `app/frontend/styles/application.css`
- Create: `app/frontend/lib/utils.ts`

**Step 1: Install shadcn-svelte CLI and dependencies**

Run the initialization command:
```bash
npx shadcn-svelte@latest init
```

When prompted, select:
- TypeScript: Yes
- Style: Default
- Base color: Slate
- Global CSS file: `app/frontend/styles/application.css`
- CSS variables: Yes
- Tailwind config: Use existing
- Components path: `app/frontend/components/ui`
- Utils path: `app/frontend/lib/utils`
- React Server Components: No
- Package manager: npm

**Step 2: Verify generated files**

Check that these files were created/modified:
```bash
ls -la components.json
ls -la app/frontend/lib/utils.ts
cat app/frontend/styles/application.css
```

Expected: `components.json` exists, `utils.ts` created, CSS has shadcn theme variables

**Step 3: Update Tailwind configuration for shadcn**

Since you're using Tailwind v4 with Vite plugin, verify the CSS includes shadcn theme:

Expected in `app/frontend/styles/application.css`:
```css
@import "tailwindcss";

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    /* ... other CSS variables ... */
  }
}
```

**Step 4: Create path alias helper**

The Vite config already has `@` alias, verify it works:

In `vite.config.js`:
```javascript
resolve: {
  alias: {
    '@': '/app/frontend',
    '$lib': '/app/frontend/lib'
  }
}
```

Add `$lib` alias if not present.

**Step 5: Commit initialization**

```bash
git add .
git commit -m "feat: initialize shadcn-svelte with Tailwind v4 config"
```

---

## Task 2: Install Core UI Components

**Files:**
- Create: `app/frontend/components/ui/button.svelte`
- Create: `app/frontend/components/ui/card.svelte`
- Create: `app/frontend/components/ui/input.svelte`
- Create: `app/frontend/components/ui/label.svelte`
- Create: `app/frontend/components/ui/textarea.svelte`
- Create: `app/frontend/components/ui/select.svelte`
- Create: `app/frontend/components/ui/checkbox.svelte`
- Create: `app/frontend/components/ui/badge.svelte`
- Create: `app/frontend/components/ui/separator.svelte`
- Create: `app/frontend/components/ui/alert.svelte`

**Step 1: Install base form components**

```bash
npx shadcn-svelte@latest add button
npx shadcn-svelte@latest add input
npx shadcn-svelte@latest add label
npx shadcn-svelte@latest add textarea
npx shadcn-svelte@latest add checkbox
npx shadcn-svelte@latest add select
```

**Step 2: Install layout and display components**

```bash
npx shadcn-svelte@latest add card
npx shadcn-svelte@latest add badge
npx shadcn-svelte@latest add separator
npx shadcn-svelte@latest add alert
```

**Step 3: Install feedback components**

```bash
npx shadcn-svelte@latest add toast
npx shadcn-svelte@latest add dialog
npx shadcn-svelte@latest add alert-dialog
npx shadcn-svelte@latest add popover
npx shadcn-svelte@latest add tooltip
```

**Step 4: Install navigation components**

```bash
npx shadcn-svelte@latest add dropdown-menu
npx shadcn-svelte@latest add navigation-menu
npx shadcn-svelte@latest add tabs
```

**Step 5: Install data display components**

```bash
npx shadcn-svelte@latest add table
npx shadcn-svelte@latest add accordion
npx shadcn-svelte@latest add progress
```

**Step 6: Verify all components installed**

```bash
ls -la app/frontend/components/ui/
```

Expected: All component files present (button.svelte, card.svelte, etc.)

**Step 7: Commit component installation**

```bash
git add app/frontend/components/ui/
git commit -m "feat: install shadcn-svelte core components"
```

---

## Task 3: Create Component Showcase Page

**Files:**
- Create: `app/frontend/pages/Showcase.svelte`
- Create: `app/controllers/showcase_controller.rb`
- Modify: `config/routes.rb`

**Step 1: Create showcase controller**

Create `app/controllers/showcase_controller.rb`:
```ruby
class ShowcaseController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render inertia: "Showcase"
  end
end
```

**Step 2: Add showcase route**

In `config/routes.rb`, add:
```ruby
get "/showcase", to: "showcase#index" if Rails.env.development?
```

**Step 3: Create showcase page**

Create `app/frontend/pages/Showcase.svelte`:
```svelte
<script>
  import { Button } from '@/components/ui/button';
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
  import { Input } from '@/components/ui/input';
  import { Label } from '@/components/ui/label';
  import { Textarea } from '@/components/ui/textarea';
  import { Checkbox } from '@/components/ui/checkbox';
  import { Badge } from '@/components/ui/badge';
  import { Alert, AlertDescription } from '@/components/ui/alert';
  import { Separator } from '@/components/ui/separator';
</script>

<div class="min-h-screen bg-gray-50 p-8">
  <div class="max-w-7xl mx-auto space-y-8">
    <div>
      <h1 class="text-4xl font-bold mb-2">shadcn-svelte Components</h1>
      <p class="text-gray-600">Component showcase for Monaco RGPD</p>
    </div>

    <Separator />

    <!-- Buttons -->
    <Card>
      <CardHeader>
        <CardTitle>Buttons</CardTitle>
        <CardDescription>Different button variants and sizes</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-4">
          <Button>Default</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="destructive">Destructive</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="link">Link</Button>
        </div>
        <div class="flex flex-wrap gap-4 mt-4">
          <Button size="sm">Small</Button>
          <Button size="default">Default</Button>
          <Button size="lg">Large</Button>
        </div>
      </CardContent>
    </Card>

    <!-- Forms -->
    <Card>
      <CardHeader>
        <CardTitle>Form Inputs</CardTitle>
        <CardDescription>Input fields and form controls</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="space-y-4 max-w-md">
          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input id="email" type="email" placeholder="email@example.com" />
          </div>
          <div class="space-y-2">
            <Label for="message">Message</Label>
            <Textarea id="message" placeholder="Type your message here..." />
          </div>
          <div class="flex items-center space-x-2">
            <Checkbox id="terms" />
            <Label for="terms">Accept terms and conditions</Label>
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- Alerts & Badges -->
    <Card>
      <CardHeader>
        <CardTitle>Alerts & Badges</CardTitle>
        <CardDescription>Feedback and status indicators</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="space-y-4">
          <Alert>
            <AlertDescription>
              This is a default alert message.
            </AlertDescription>
          </Alert>
          <div class="flex gap-2">
            <Badge>Default</Badge>
            <Badge variant="secondary">Secondary</Badge>
            <Badge variant="destructive">Destructive</Badge>
            <Badge variant="outline">Outline</Badge>
          </div>
        </div>
      </CardContent>
    </Card>

  </div>
</div>
```

**Step 4: Test showcase page**

```bash
bin/dev
```

Visit: http://localhost:3000/showcase

Expected: Page displays with all shadcn components styled correctly

**Step 5: Commit showcase page**

```bash
git add app/frontend/pages/Showcase.svelte app/controllers/showcase_controller.rb config/routes.rb
git commit -m "feat: add component showcase page"
```

---

## Task 4: Migrate QuestionCard Component

**Files:**
- Modify: `app/frontend/components/QuestionCard.svelte`

**Step 1: Update imports and button components**

Replace the custom buttons with shadcn Button:

```svelte
<script>
  import { Button } from '@/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
  import { Alert, AlertDescription } from '@/components/ui/alert';
  import { Input } from '@/components/ui/input';
  import { Textarea } from '@/components/ui/textarea';
  import { Checkbox } from '@/components/ui/checkbox';
  import { Label } from '@/components/ui/label';

  let { question, answer = null, onanswer } = $props();

  let selectedValue = $state(answer || {});

  function handleYesNo(choiceText) {
    const choice = question.answer_choices.find(c => c.choice_text === choiceText);
    if (choice) {
      selectedValue = { choice_id: choice.id };
      onanswer(selectedValue);
    }
  }

  function handleSingleChoice(choiceId) {
    selectedValue = { choice_id: choiceId };
    onanswer(selectedValue);
  }

  function handleMultipleChoice(choiceId, checked) {
    const choiceIds = selectedValue.choice_ids || [];
    if (checked) {
      selectedValue = { choice_ids: [...choiceIds, choiceId] };
    } else {
      selectedValue = { choice_ids: choiceIds.filter(id => id !== choiceId) };
    }
    onanswer(selectedValue);
  }

  function handleText(value) {
    selectedValue = { text: value };
    onanswer(selectedValue);
  }
</script>

<Card>
  <CardHeader>
    <CardTitle class="text-2xl">{question.question_text}</CardTitle>
  </CardHeader>
  <CardContent>
    {#if question.help_text}
      <Alert class="mb-6">
        <AlertDescription>{question.help_text}</AlertDescription>
      </Alert>
    {/if}

    <div class="space-y-6">
      {#if question.question_type === 'yes_no'}
        <div class="flex gap-6">
          {#each question.answer_choices as choice (choice.id)}
            <Button
              onclick={() => handleYesNo(choice.choice_text)}
              variant={selectedValue.choice_id === choice.id ? "default" : "outline"}
              class="flex-1 h-16 text-lg {selectedValue.choice_id === choice.id && choice.choice_text === 'Oui' ? 'bg-green-600 hover:bg-green-700' : ''} {selectedValue.choice_id === choice.id && choice.choice_text === 'Non' ? 'bg-red-600 hover:bg-red-700' : ''}"
            >
              {choice.choice_text}
            </Button>
          {/each}
        </div>

      {:else if question.question_type === 'single_choice'}
        <div class="flex flex-col gap-4">
          {#each question.answer_choices as choice (choice.id)}
            <Button
              onclick={() => handleSingleChoice(choice.id)}
              variant={selectedValue.choice_id === choice.id ? "default" : "outline"}
              class="w-full h-auto py-4 px-5 text-left justify-start"
            >
              {choice.choice_text}
            </Button>
          {/each}
        </div>

      {:else if question.question_type === 'multiple_choice'}
        <div class="flex flex-col gap-4">
          {#each question.answer_choices as choice (choice.id)}
            <Label class="flex items-center p-4 rounded-lg border cursor-pointer hover:bg-gray-50">
              <Checkbox
                checked={selectedValue.choice_ids?.includes(choice.id)}
                onCheckedChange={(checked) => handleMultipleChoice(choice.id, checked)}
                class="mr-3"
              />
              <span>{choice.choice_text}</span>
            </Label>
          {/each}
        </div>

      {:else if question.question_type === 'text_short'}
        <Input
          type="text"
          value={selectedValue.text || ''}
          oninput={(e) => handleText(e.target.value)}
          placeholder="Votre réponse..."
        />

      {:else if question.question_type === 'text_long'}
        <Textarea
          value={selectedValue.text || ''}
          oninput={(e) => handleText(e.target.value)}
          rows={5}
          placeholder="Votre réponse..."
        />
      {/if}
    </div>
  </CardContent>
</Card>
```

**Step 2: Test QuestionCard**

```bash
bin/dev
```

Navigate to a questionnaire and verify:
- Cards render correctly
- Buttons have proper styling
- Form inputs work
- Yes/No buttons show green/red when selected

Expected: Component works identically but uses shadcn components

**Step 3: Commit QuestionCard migration**

```bash
git add app/frontend/components/QuestionCard.svelte
git commit -m "feat: migrate QuestionCard to shadcn-svelte components"
```

---

## Task 5: Migrate Dashboard Page

**Files:**
- Modify: `app/frontend/pages/Dashboard/Show.svelte`

**Step 1: Update imports**

Replace custom elements with shadcn components:

```svelte
<script>
  import { Button } from '@/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
  import { Alert, AlertDescription } from '@/components/ui/alert';
  import { Badge } from '@/components/ui/badge';
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';
  import { router, page } from '@inertiajs/svelte';

  let { latest_assessment, latest_response_id, documents, responses, questionnaire_id } = $props();

  let showFlash = $state(!!$page.props.flash?.notice);

  $effect(() => {
    if (showFlash) {
      const timer = setTimeout(() => {
        showFlash = false;
      }, 5000);
      return () => clearTimeout(timer);
    }
  });

  function getRiskLevelColor(riskLevel) {
    const colors = {
      'compliant': 'green',
      'attention_required': 'yellow',
      'non_compliant': 'red'
    };
    return colors[riskLevel] || 'gray';
  }

  function getRiskLevelText(riskLevel) {
    const texts = {
      'compliant': 'Risque faible',
      'attention_required': 'Risque moyen',
      'non_compliant': 'Risque élevé'
    };
    return texts[riskLevel] || 'Inconnu';
  }
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold">Tableau de bord de conformité</h1>
      <div class="flex items-center gap-4">
        {#if latest_assessment && questionnaire_id}
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Nouvelle évaluation
          </Button>
        {/if}
        <Button
          variant="outline"
          onclick={() => router.delete('/session')}
        >
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Déconnexion
        </Button>
      </div>
    </div>

    <!-- Flash Message -->
    {#if showFlash && $page.props.flash?.notice}
      <Alert class="mb-6 border-l-4 border-green-400">
        <div class="flex items-center justify-between">
          <AlertDescription class="text-green-700 font-medium">
            {$page.props.flash.notice}
          </AlertDescription>
          <Button
            variant="ghost"
            size="sm"
            onclick={() => showFlash = false}
            aria-label="Fermer"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Button>
        </div>
      </Alert>
    {/if}

    {#if latest_assessment}
      <ComplianceScoreCard assessment={latest_assessment} responseId={latest_response_id} />

      {#if documents && documents.length > 0}
        <DocumentList {documents} />
      {/if}

    {:else}
      <Card class="text-center p-12">
        <CardHeader>
          <CardTitle class="text-2xl mb-4">Bienvenue sur Monaco RGPD</CardTitle>
        </CardHeader>
        <CardContent>
          <p class="text-gray-600 mb-6">Complétez votre évaluation pour obtenir:</p>
          <ul class="text-left max-w-md mx-auto mb-8 space-y-2">
            <li class="flex items-center">
              <span class="text-green-500 mr-2">✓</span>
              Votre score de conformité
            </li>
            <li class="flex items-center">
              <span class="text-green-500 mr-2">✓</span>
              4 documents essentiels
            </li>
            <li class="flex items-center">
              <span class="text-green-500 mr-2">✓</span>
              Votre registre Article 30
            </li>
          </ul>
          <Button
            onclick={() => router.post(`/questionnaires/${questionnaire_id}/responses`)}
            disabled={!questionnaire_id}
            size="lg"
          >
            Commencer l'évaluation
          </Button>
          <p class="text-sm text-gray-500 mt-4">Temps estimé: 15-20 minutes</p>
        </CardContent>
      </Card>
    {/if}
  </div>
</div>
```

**Step 2: Test dashboard page**

```bash
bin/dev
```

Navigate to dashboard and verify:
- Buttons styled correctly
- Flash message uses Alert component
- Empty state card renders properly

Expected: Dashboard looks identical but uses shadcn

**Step 3: Commit dashboard migration**

```bash
git add app/frontend/pages/Dashboard/Show.svelte
git commit -m "feat: migrate Dashboard to shadcn-svelte components"
```

---

## Task 6: Migrate ComplianceScoreCard Component

**Files:**
- Modify: `app/frontend/components/ComplianceScoreCard.svelte`

**Step 1: Read current ComplianceScoreCard**

```bash
cat app/frontend/components/ComplianceScoreCard.svelte
```

**Step 2: Update to use shadcn Card and Badge**

Replace custom card markup with shadcn components. Import Card, Badge, Button, Progress (if showing score visually).

Example structure:
```svelte
<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
  import { Badge } from '@/components/ui/badge';
  import { Button } from '@/components/ui/button';
  import { Progress } from '@/components/ui/progress';
  import { router } from '@inertiajs/svelte';

  let { assessment, responseId } = $props();
</script>

<Card>
  <CardHeader>
    <CardTitle>Score de Conformité</CardTitle>
    <CardDescription>Votre niveau de conformité RGPD</CardDescription>
  </CardHeader>
  <CardContent>
    <!-- Score display with Progress bar -->
    <!-- Risk level badge -->
    <!-- Action buttons -->
  </CardContent>
</Card>
```

**Step 3: Test compliance score card**

Navigate to dashboard with assessment and verify styling matches shadcn design system.

Expected: Card displays correctly with shadcn styling

**Step 4: Commit ComplianceScoreCard migration**

```bash
git add app/frontend/components/ComplianceScoreCard.svelte
git commit -m "feat: migrate ComplianceScoreCard to shadcn-svelte"
```

---

## Task 7: Migrate DocumentList Component

**Files:**
- Modify: `app/frontend/components/DocumentList.svelte`

**Step 1: Read current DocumentList**

```bash
cat app/frontend/components/DocumentList.svelte
```

**Step 2: Update to use shadcn Card and Button**

Replace with shadcn components:

```svelte
<script>
  import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
  import { Button } from '@/components/ui/button';
  import { Badge } from '@/components/ui/badge';

  let { documents } = $props();
</script>

<Card class="mt-8">
  <CardHeader>
    <CardTitle>Documents générés</CardTitle>
  </CardHeader>
  <CardContent>
    <div class="space-y-4">
      {#each documents as document}
        <div class="flex items-center justify-between p-4 border rounded-lg">
          <div>
            <h3 class="font-medium">{document.title}</h3>
            <p class="text-sm text-gray-600">{document.description}</p>
          </div>
          <Button variant="outline" href={document.download_url}>
            Télécharger
          </Button>
        </div>
      {/each}
    </div>
  </CardContent>
</Card>
```

**Step 3: Test document list**

Verify documents display correctly with shadcn styling.

Expected: Document list renders with cards and buttons

**Step 4: Commit DocumentList migration**

```bash
git add app/frontend/components/DocumentList.svelte
git commit -m "feat: migrate DocumentList to shadcn-svelte"
```

---

## Task 8: Migrate Header Component

**Files:**
- Modify: `app/frontend/components/Header.svelte`
- Modify: `app/frontend/components/UserDropdown.svelte`

**Step 1: Update Header to use shadcn**

```svelte
<script>
  import { page } from '@inertiajs/svelte';
  import { Button } from '@/components/ui/button';
  import UserDropdown from './UserDropdown.svelte';

  const user = $derived($page.props.current_user);
  const account = $derived($page.props.current_account);
</script>

<header class="bg-white border-b">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center h-16">
      <div class="flex items-center">
        <Button variant="link" href="/app" class="text-xl font-bold">
          {account?.name || 'App'}
        </Button>
      </div>

      <div class="flex items-center space-x-4">
        <UserDropdown {user} {account} />
      </div>
    </div>
  </div>
</header>
```

**Step 2: Update UserDropdown to use DropdownMenu**

```svelte
<script>
  import {
    DropdownMenu,
    DropdownMenuTrigger,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuLabel
  } from '@/components/ui/dropdown-menu';
  import { Button } from '@/components/ui/button';
  import { Avatar, AvatarFallback } from '@/components/ui/avatar';
  import { router } from '@inertiajs/svelte';

  let { user, account } = $props();

  function getInitials(name) {
    return name?.split(' ').map(n => n[0]).join('').toUpperCase() || 'U';
  }
</script>

<DropdownMenu>
  <DropdownMenuTrigger asChild let:builder>
    <Button variant="ghost" builders={[builder]} class="relative h-10 w-10 rounded-full">
      <Avatar>
        <AvatarFallback>{getInitials(user?.name)}</AvatarFallback>
      </Avatar>
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent align="end">
    <DropdownMenuLabel>
      <div class="flex flex-col space-y-1">
        <p class="text-sm font-medium">{user?.name}</p>
        <p class="text-xs text-gray-500">{user?.email}</p>
      </div>
    </DropdownMenuLabel>
    <DropdownMenuSeparator />
    <DropdownMenuItem onclick={() => router.visit('/settings/profile')}>
      Profil
    </DropdownMenuItem>
    <DropdownMenuItem onclick={() => router.visit('/settings/account')}>
      Compte
    </DropdownMenuItem>
    <DropdownMenuSeparator />
    <DropdownMenuItem onclick={() => router.delete('/session')}>
      Déconnexion
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

**Step 3: Test header and dropdown**

Navigate through app and test user dropdown menu.

Expected: Dropdown opens, navigation works, styling matches shadcn

**Step 4: Commit header migration**

```bash
git add app/frontend/components/Header.svelte app/frontend/components/UserDropdown.svelte
git commit -m "feat: migrate Header and UserDropdown to shadcn-svelte"
```

---

## Task 9: Migrate Admin Layout Components

**Files:**
- Modify: `app/frontend/components/AdminNav.svelte`
- Modify: `app/frontend/components/AdminLayout.svelte`

**Step 1: Update AdminNav to use NavigationMenu**

```svelte
<script>
  import {
    NavigationMenu,
    NavigationMenuList,
    NavigationMenuItem,
    NavigationMenuLink
  } from '@/components/ui/navigation-menu';
  import { page } from '@inertiajs/svelte';

  const currentPath = $derived($page.url);

  function isActive(path) {
    return currentPath.startsWith(path);
  }
</script>

<nav class="bg-white border-b">
  <div class="max-w-7xl mx-auto px-4">
    <NavigationMenu>
      <NavigationMenuList>
        <NavigationMenuItem>
          <NavigationMenuLink
            href="/admin/dashboard"
            active={isActive('/admin/dashboard')}
          >
            Dashboard
          </NavigationMenuLink>
        </NavigationMenuItem>
        <NavigationMenuItem>
          <NavigationMenuLink
            href="/admin/accounts"
            active={isActive('/admin/accounts')}
          >
            Comptes
          </NavigationMenuLink>
        </NavigationMenuItem>
        <NavigationMenuItem>
          <NavigationMenuLink
            href="/admin/users"
            active={isActive('/admin/users')}
          >
            Utilisateurs
          </NavigationMenuLink>
        </NavigationMenuItem>
        <NavigationMenuItem>
          <NavigationMenuLink
            href="/admin/subscriptions"
            active={isActive('/admin/subscriptions')}
          >
            Abonnements
          </NavigationMenuLink>
        </NavigationMenuItem>
      </NavigationMenuList>
    </NavigationMenu>
  </div>
</nav>
```

**Step 2: Update AdminLayout**

Use shadcn components for layout structure.

**Step 3: Test admin navigation**

Login as admin, navigate through admin pages.

Expected: Navigation works, active states show correctly

**Step 4: Commit admin components**

```bash
git add app/frontend/components/AdminNav.svelte app/frontend/components/AdminLayout.svelte
git commit -m "feat: migrate admin navigation to shadcn-svelte"
```

---

## Task 10: Migrate Settings Layout Components

**Files:**
- Modify: `app/frontend/components/SettingsNav.svelte`
- Modify: `app/frontend/components/SettingsLayout.svelte`

**Step 1: Update SettingsNav with Tabs**

```svelte
<script>
  import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';
  import { page } from '@inertiajs/svelte';
  import { router } from '@inertiajs/svelte';

  const currentPath = $derived($page.url);
</script>

<Tabs value={currentPath} class="w-full">
  <TabsList>
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
```

**Step 2: Test settings navigation**

Navigate through settings pages.

Expected: Tabs work, active state shows current page

**Step 3: Commit settings components**

```bash
git add app/frontend/components/SettingsNav.svelte app/frontend/components/SettingsLayout.svelte
git commit -m "feat: migrate settings navigation to shadcn-svelte"
```

---

## Task 11: Migrate All Settings Pages

**Files:**
- Modify: `app/frontend/pages/settings/Profile.svelte`
- Modify: `app/frontend/pages/settings/Account.svelte`
- Modify: `app/frontend/pages/settings/Billing.svelte`
- Modify: `app/frontend/pages/settings/Team.svelte`
- Modify: `app/frontend/pages/settings/Notifications.svelte`

**Step 1: Migrate Profile page forms**

Update Profile.svelte to use shadcn Form components (Label, Input, Button, Card).

**Step 2: Migrate Account page**

Similar structure with shadcn components.

**Step 3: Migrate Billing page**

Use Card for billing information display, Button for actions.

**Step 4: Migrate Team page**

Use Table component for team member list, Dialog for invite modal.

**Step 5: Migrate Notifications page**

Use Switch components for notification toggles, Card for grouping.

**Step 6: Test all settings pages**

Go through each settings page, test forms, buttons, interactions.

Expected: All pages work with shadcn styling

**Step 7: Commit settings pages**

```bash
git add app/frontend/pages/settings/
git commit -m "feat: migrate all settings pages to shadcn-svelte"
```

---

## Task 12: Migrate All Admin Pages

**Files:**
- Modify: `app/frontend/pages/admin/Dashboard.svelte`
- Modify: `app/frontend/pages/admin/accounts/Index.svelte`
- Modify: `app/frontend/pages/admin/accounts/Show.svelte`
- Modify: `app/frontend/pages/admin/users/Index.svelte`
- Modify: `app/frontend/pages/admin/users/Show.svelte`
- Modify: `app/frontend/pages/admin/admins/Index.svelte`
- Modify: `app/frontend/pages/admin/subscriptions/Index.svelte`

**Step 1: Migrate admin Dashboard**

Use Card, Badge, Table for statistics and data display.

**Step 2: Migrate accounts index and show pages**

Use Table for listing, Card for details, Dialog for actions.

**Step 3: Migrate users index and show pages**

Similar pattern with shadcn Table and Card.

**Step 4: Migrate admins index**

Table for admin list, Dialog for adding admins.

**Step 5: Migrate subscriptions index**

Table with Badge for status indicators.

**Step 6: Test all admin pages**

Navigate through admin section, test all CRUD operations.

Expected: All admin functionality works with shadcn

**Step 7: Commit admin pages**

```bash
git add app/frontend/pages/admin/
git commit -m "feat: migrate all admin pages to shadcn-svelte"
```

---

## Task 13: Migrate Auth Pages

**Files:**
- Modify: `app/frontend/pages/auth/SignIn.svelte`
- Modify: `app/frontend/pages/auth/CheckEmail.svelte`
- Modify: `app/frontend/pages/sessions/new.html.erb` (if exists)

**Step 1: Migrate SignIn page**

```svelte
<script>
  import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card';
  import { Input } from '@/components/ui/input';
  import { Label } from '@/components/ui/label';
  import { Button } from '@/components/ui/button';
  import { Alert, AlertDescription } from '@/components/ui/alert';
  import { router } from '@inertiajs/svelte';

  let { error } = $props();
  let email = $state('');
  let loading = $state(false);

  function handleSubmit() {
    loading = true;
    router.post('/auth/magic_link', { email }, {
      onFinish: () => loading = false
    });
  }
</script>

<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <Card class="w-full max-w-md">
    <CardHeader>
      <CardTitle>Connexion</CardTitle>
      <CardDescription>Entrez votre email pour recevoir un lien de connexion</CardDescription>
    </CardHeader>
    <CardContent>
      {#if error}
        <Alert variant="destructive" class="mb-4">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      {/if}
      <form onsubmit|preventDefault={handleSubmit} class="space-y-4">
        <div class="space-y-2">
          <Label for="email">Email</Label>
          <Input
            id="email"
            type="email"
            bind:value={email}
            placeholder="vous@exemple.com"
            required
          />
        </div>
        <Button type="submit" class="w-full" disabled={loading}>
          {loading ? 'Envoi...' : 'Envoyer le lien'}
        </Button>
      </form>
    </CardContent>
  </Card>
</div>
```

**Step 2: Migrate CheckEmail page**

Similar structure with Card and Alert components.

**Step 3: Test auth flow**

Test magic link signin flow.

Expected: Auth pages work with shadcn styling

**Step 4: Commit auth pages**

```bash
git add app/frontend/pages/auth/
git commit -m "feat: migrate auth pages to shadcn-svelte"
```

---

## Task 14: Migrate Remaining Pages

**Files:**
- Modify: `app/frontend/pages/Home.svelte`
- Modify: `app/frontend/pages/Questionnaires/Show.svelte`
- Modify: `app/frontend/pages/Responses/Show.svelte`
- Modify: `app/frontend/pages/Responses/Index.svelte`
- Modify: `app/frontend/pages/Responses/Results.svelte`

**Step 1: Migrate Home page**

Use Button, Card for landing page elements.

**Step 2: Migrate Questionnaires Show**

Already uses QuestionCard which was migrated. Update any other elements.

**Step 3: Migrate Responses pages**

Use Table for index, Card for show, Progress for results visualization.

**Step 4: Test all pages**

Complete walkthrough of entire application.

Expected: All pages use shadcn consistently

**Step 5: Commit remaining pages**

```bash
git add app/frontend/pages/
git commit -m "feat: migrate remaining pages to shadcn-svelte"
```

---

## Task 15: Add Toast Notifications

**Files:**
- Create: `app/frontend/components/Toaster.svelte`
- Modify: `app/frontend/pages/App.svelte`

**Step 1: Create Toaster component**

```svelte
<script>
  import { Toaster } from '@/components/ui/toast';
</script>

<Toaster />
```

**Step 2: Add Toaster to App.svelte**

Import and place Toaster at root level to show notifications globally.

**Step 3: Replace flash messages with Toast**

Convert flash message handling to use toast notifications instead of inline alerts.

**Step 4: Test toast notifications**

Trigger success/error actions and verify toasts appear.

Expected: Toast notifications work app-wide

**Step 5: Commit toast integration**

```bash
git add app/frontend/components/Toaster.svelte app/frontend/pages/App.svelte
git commit -m "feat: add toast notifications with shadcn-svelte"
```

---

## Task 16: Clean Up Custom Components

**Files:**
- Remove or update any remaining custom UI components

**Step 1: Search for unused custom components**

```bash
find app/frontend/components -name "*.svelte" ! -path "*/ui/*" -type f
```

**Step 2: Verify each component is migrated**

Check that all non-shadcn components are domain-specific (QuestionnaireWizard, etc.) not generic UI.

**Step 3: Remove any obsolete utility classes**

Clean up custom Tailwind utilities that are now handled by shadcn.

**Step 4: Commit cleanup**

```bash
git add .
git commit -m "chore: remove obsolete custom UI components"
```

---

## Task 17: Visual Regression Testing

**Files:**
- Test all pages manually

**Step 1: Test dashboard flow**

- Login
- View dashboard
- Start assessment
- Complete questionnaire
- View results
- Download documents

**Step 2: Test settings flow**

- Profile editing
- Account settings
- Team management
- Billing page
- Notifications

**Step 3: Test admin flow**

- Admin dashboard
- Accounts list/detail
- Users list/detail
- Subscriptions

**Step 4: Test auth flow**

- Sign in
- Magic link
- Sign out

**Step 5: Document any visual issues**

Create list of styling inconsistencies to fix.

**Step 6: Fix identified issues**

Address each visual regression.

**Step 7: Commit fixes**

```bash
git add .
git commit -m "fix: address visual regressions from shadcn migration"
```

---

## Task 18: Accessibility Verification

**Files:**
- All pages

**Step 1: Test keyboard navigation**

Tab through all forms, buttons, dropdowns. Verify focus states.

**Step 2: Test screen reader compatibility**

Use VoiceOver (Mac) or NVDA (Windows) to navigate app.

**Step 3: Check color contrast**

Verify text colors meet WCAG AA standards.

**Step 4: Test with reduced motion**

Verify animations respect `prefers-reduced-motion`.

**Step 5: Fix accessibility issues**

Address any problems found.

**Step 6: Commit accessibility fixes**

```bash
git add .
git commit -m "fix: improve accessibility after shadcn migration"
```

---

## Task 19: Performance Optimization

**Files:**
- `vite.config.js`
- Various component files

**Step 1: Analyze bundle size**

```bash
npm run build
```

Check output for bundle sizes.

**Step 2: Verify tree-shaking**

Ensure unused shadcn components are excluded from bundle.

**Step 3: Optimize imports**

Use named imports consistently:
```javascript
import { Button } from '@/components/ui/button';
```

Not:
```javascript
import Button from '@/components/ui/button';
```

**Step 4: Test build performance**

```bash
npm run build
npm run preview
```

Navigate app in preview mode, check performance.

**Step 5: Commit optimizations**

```bash
git add .
git commit -m "perf: optimize shadcn component imports and bundle"
```

---

## Task 20: Update Documentation

**Files:**
- Create: `docs/ui-components.md`
- Modify: `README.md`

**Step 1: Create UI components guide**

Create `docs/ui-components.md`:

```markdown
# UI Components Guide

This project uses [shadcn-svelte](https://www.shadcn-svelte.com/) for all UI components.

## Available Components

All components are located in `app/frontend/components/ui/`.

### Form Components
- Button
- Input
- Textarea
- Select
- Checkbox
- Label

### Layout Components
- Card
- Separator
- Tabs

### Feedback Components
- Alert
- Toast
- Dialog
- Popover

### Navigation
- Dropdown Menu
- Navigation Menu

### Data Display
- Table
- Badge
- Progress

## Usage

Import components from `@/components/ui/`:

\`\`\`svelte
<script>
  import { Button } from '@/components/ui/button';
  import { Card, CardHeader, CardContent } from '@/components/ui/card';
</script>

<Card>
  <CardHeader>Title</CardHeader>
  <CardContent>
    <Button>Click me</Button>
  </CardContent>
</Card>
\`\`\`

## Component Showcase

Visit `/showcase` in development to see all components.

## Customization

Theme variables are defined in `app/frontend/styles/application.css`.

## Resources

- [shadcn-svelte Documentation](https://www.shadcn-svelte.com/)
- [Component Examples](https://www.shadcn-svelte.com/docs/components)
```

**Step 2: Update README**

Add shadcn-svelte to tech stack in README.md.

**Step 3: Commit documentation**

```bash
git add docs/ui-components.md README.md
git commit -m "docs: add shadcn-svelte component guide"
```

---

## Task 21: Final Testing & Review

**Files:**
- All application files

**Step 1: Run full test suite**

```bash
bin/rails test
```

Expected: All 255 tests pass

**Step 2: Complete user journey test**

Perform end-to-end test of entire application as a user.

**Step 3: Review all commits**

```bash
git log --oneline feature/shadcn-integration
```

Verify commit messages follow conventions.

**Step 4: Create summary of changes**

Document what was changed, components migrated, benefits.

**Step 5: Prepare for code review**

Ensure code is clean, formatted, documented.

**Step 6: Final commit**

```bash
git add .
git commit -m "feat: complete shadcn-svelte integration"
```

---

## Execution Complete

After all tasks are done, the application will have:

✅ shadcn-svelte fully integrated as design system
✅ All components migrated to use shadcn primitives
✅ Consistent styling across entire application
✅ Accessible, keyboard-navigable UI
✅ Toast notifications for feedback
✅ Clean, maintainable component code
✅ Documentation for future development
✅ All tests passing

The migration will be complete and ready for code review and merging.
