# Page Title Header Design

**Date:** 2025-11-13
**Status:** Approved

## Overview

Replace breadcrumb navigation with a simple page title in the header, and add a logout button to the header.

## Problem

Current implementation shows breadcrumb navigation (e.g., "Accueil > Questionnaires") which adds visual clutter. Each page also has its own h1 element in the content area, creating redundancy.

## Solution

### AppLayout Changes

**Header structure:**
- Left side: SidebarTrigger + Separator + Page Title (h1)
- Right side: Logout button

**Implementation details:**
- Accept a required `title` prop (string)
- Display title as h1 element in the header
- Add logout button that calls `router.delete('/session')`
- Remove breadcrumb imports and logic
- Remove `generateBreadcrumbs` utility

### Page-level Changes

For each page using AppLayout:
- Remove existing h1 element and wrapper div
- Pass `title` prop to AppLayout
- Keep description/subtitle text in main content area (not in header)

**Example transformation:**

Before:
```svelte
<AppLayout>
  <div class="flex flex-col gap-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Questionnaires</h1>
        <p class="text-muted-foreground mt-1">Description...</p>
      </div>
    </div>
    <!-- content -->
  </div>
</AppLayout>
```

After:
```svelte
<AppLayout title="Questionnaires">
  <div class="flex flex-col gap-6">
    <div>
      <p class="text-muted-foreground">Description...</p>
    </div>
    <!-- content -->
  </div>
</AppLayout>
```

### Cleanup

**Files to remove:**
- `app/frontend/lib/utils/breadcrumbs.js`

**Files to update:**
- `app/frontend/lib/layouts/AppLayout.svelte`
- All page components using AppLayout (~28 files)

### Edge Cases

- Auth pages without h1: Add title prop
- Dashboard logout button: Remove (now in header)
- Logout button styling: Outline variant with icon for consistency

## Benefits

- Simpler, cleaner header
- Single source of truth for page titles
- Consistent logout button placement
- Less duplication (no h1 in both header and content)
- Easier to maintain page titles
