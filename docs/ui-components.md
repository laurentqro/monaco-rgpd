# UI Components Guide

This project uses [shadcn-svelte](https://www.shadcn-svelte.com/) as the complete design system foundation. All UI components are built on top of shadcn-svelte primitives with Tailwind CSS v4 styling.

## Overview

shadcn-svelte provides accessible, customizable components built with:
- **bits-ui** - Headless component primitives with full ARIA support
- **Tailwind CSS v4** - Utility-first styling with OKLCH color space
- **Svelte 5** - Modern reactivity with runes ($state, $derived, $props)

## Available Components

All components are located in `app/frontend/lib/components/ui/`.

### Form Components

- **Button** - Primary, secondary, destructive, outline, ghost, and link variants
- **Input** - Text inputs with validation states
- **Textarea** - Multi-line text inputs
- **Select** - Dropdown select with keyboard navigation
- **Checkbox** - Checkbox with indeterminate state support
- **Label** - Form labels with proper association

### Layout Components

- **Card** - Content containers with header, content, and footer sections
- **Separator** - Visual dividers between content
- **Tabs** - Tabbed navigation with keyboard support

### Feedback Components

- **Alert** - Informational messages (default, destructive variants)
- **Toast** - Temporary notifications with auto-dismiss
- **Dialog** - Modal dialogs with focus trapping
- **Alert Dialog** - Confirmation dialogs for destructive actions
- **Popover** - Contextual overlays
- **Tooltip** - Hover tooltips

### Navigation Components

- **Dropdown Menu** - Contextual menus with keyboard navigation
- **Navigation Menu** - Main navigation with active states
- **Breadcrumb** - Hierarchical navigation trail

### Data Display Components

- **Table** - Data tables with sorting and selection
- **Badge** - Status indicators and tags
- **Progress** - Progress bars and loading indicators
- **Avatar** - User avatars with fallbacks
- **Accordion** - Collapsible content sections

## Usage

Import components from `$lib/components/ui/`:

```svelte
<script>
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Input } from '$lib/components/ui/input';
  import { Label } from '$lib/components/ui/label';
</script>

<Card>
  <CardHeader>
    <CardTitle>Sign In</CardTitle>
  </CardHeader>
  <CardContent>
    <div class="space-y-4">
      <div class="space-y-2">
        <Label for="email">Email</Label>
        <Input id="email" type="email" placeholder="you@example.com" />
      </div>
      <Button class="w-full">Sign In</Button>
    </div>
  </CardContent>
</Card>
```

## Component Patterns

### Named Imports

Always use named imports with destructuring for optimal tree-shaking:

```svelte
// ✅ Good - enables tree-shaking
import { Button } from '$lib/components/ui/button';
import { Card, CardHeader, CardContent } from '$lib/components/ui/card';

// ❌ Avoid - may include unused code
import * as ButtonComponents from '$lib/components/ui/button';
```

### Namespace Imports

For components with many sub-components, namespace imports can improve readability:

```svelte
<script>
  import * as Card from '$lib/components/ui/card';
  import * as Table from '$lib/components/ui/table';
</script>

<Card.Root>
  <Card.Header>
    <Card.Title>Data Table</Card.Title>
  </Card.Header>
  <Card.Content>
    <Table.Root>
      <Table.Header>
        <!-- ... -->
      </Table.Header>
    </Table.Root>
  </Card.Content>
</Card.Root>
```

### Custom Styling

Components accept Tailwind classes via the `class` prop:

```svelte
<Button class="bg-green-600 hover:bg-green-700">
  Custom Button
</Button>

<Card class="border-l-4 border-blue-500">
  <!-- Highlighted card -->
</Card>
```

### Variants

Most components include variant props for different styles:

```svelte
<Button variant="default">Default</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="destructive">Destructive</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>

<Button size="sm">Small</Button>
<Button size="default">Default</Button>
<Button size="lg">Large</Button>
```

## Component Showcase

Visit `/showcase` in development mode to see all components in action:

```bash
bin/dev
# Navigate to http://localhost:3000/showcase
```

## Customization

### Theme Variables

Theme colors are defined in `app/frontend/styles/application.css` using OKLCH color space:

```css
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.129 0.042 264.695);
  --primary: oklch(0.208 0.042 265.755);
  --primary-foreground: oklch(0.984 0.003 247.858);
  /* ... */
}
```

To customize colors, modify the CSS variables while maintaining WCAG AA contrast ratios.

### Dark Mode

Dark mode styles are included and respect system preferences:

```css
.dark {
  --background: oklch(0.129 0.042 264.695);
  --foreground: oklch(0.984 0.003 247.858);
  /* ... */
}
```

Toggle dark mode by adding the `dark` class to the `<html>` element.

### Border Radius

Global border radius is controlled by the `--radius` variable:

```css
:root {
  --radius: 0.625rem; /* 10px */
}
```

## Accessibility

All shadcn-svelte components are built with accessibility as a priority:

- ✅ **Keyboard Navigation** - Full keyboard support (Tab, Arrow keys, Enter, Escape)
- ✅ **Screen Readers** - Proper ARIA attributes and semantic HTML
- ✅ **Focus Management** - Visible focus indicators and focus trapping in modals
- ✅ **Color Contrast** - WCAG 2.1 AA compliant color ratios
- ✅ **Motion Preferences** - Respects `prefers-reduced-motion`

See `docs/accessibility-audit.md` for comprehensive accessibility documentation.

## Adding New Components

To add a new shadcn-svelte component:

```bash
npx shadcn-svelte@latest add [component-name]
```

Example:
```bash
npx shadcn-svelte@latest add slider
npx shadcn-svelte@latest add switch
npx shadcn-svelte@latest add radio-group
```

Components will be added to `app/frontend/lib/components/ui/`.

## Resources

- [shadcn-svelte Documentation](https://www.shadcn-svelte.com/)
- [Component Examples](https://www.shadcn-svelte.com/docs/components)
- [bits-ui Documentation](https://www.bits-ui.com/docs)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [Svelte 5 Documentation](https://svelte-5-preview.vercel.app/docs)

## Migration Notes

All custom UI components have been migrated to shadcn-svelte:

- ✅ Custom buttons → shadcn Button
- ✅ Custom cards → shadcn Card
- ✅ Custom forms → shadcn Input/Label/Textarea
- ✅ Custom alerts → shadcn Alert
- ✅ Custom dropdowns → shadcn Dropdown Menu
- ✅ Custom tables → shadcn Table

Domain-specific components (QuestionCard, QuestionnaireWizard, etc.) now use shadcn primitives internally.
