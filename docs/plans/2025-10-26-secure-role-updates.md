# Secure Role Updates Implementation Plan

> **STATUS**: ⚠️ **PARKED FOR MVP** - Must implement before production (see docs/PRODUCTION-READINESS.md)

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Implement secure role update mechanism with proper authorization checks to prevent privilege escalation

**Architecture:** Dedicated controller action with role-based authorization (owners can change any role, admins cannot promote to owner), frontend UI in Inertia.js admin panel, comprehensive security tests

**Tech Stack:** Rails 8, Inertia.js, Minitest

**Decision Date**: 2025-11-03
**Reason**: Parked during MVP phase to focus on core features. Currently accepting risk with limited beta users.
**Deadline**: Must complete before general production release

---

## Task 1: Authorization Policy for Role Changes

**Files:**
- Create: `app/policies/role_change_policy.rb`
- Test: `test/policies/role_change_policy_test.rb`

**Step 1: Write the failing test**

Create `test/policies/role_change_policy_test.rb`:

```ruby
require "test_helper"

class RoleChangePolicyTest < ActiveSupport::TestCase
  test "owner can change any user to any role" do
    owner = users(:owner)
    target = users(:member)

    assert RoleChangePolicy.allowed?(owner, target, :owner)
    assert RoleChangePolicy.allowed?(owner, target, :admin)
    assert RoleChangePolicy.allowed?(owner, target, :member)
  end

  test "admin can promote member to admin" do
    admin = users(:admin)
    member = users(:member)

    assert RoleChangePolicy.allowed?(admin, member, :admin)
  end

  test "admin cannot promote anyone to owner" do
    admin = users(:admin)
    member = users(:member)

    assert_not RoleChangePolicy.allowed?(admin, member, :owner)
  end

  test "admin cannot demote owner" do
    admin = users(:admin)
    owner = users(:owner)

    assert_not RoleChangePolicy.allowed?(admin, owner, :member)
  end

  test "member cannot change any roles" do
    member = users(:member)
    other_member = users(:another_member)

    assert_not RoleChangePolicy.allowed?(member, other_member, :admin)
  end

  test "cannot demote yourself if you're the only owner" do
    owner = users(:owner)

    # Ensure this is the only owner in the account
    owner.account.users.where(role: :owner).where.not(id: owner.id).destroy_all

    assert_not RoleChangePolicy.allowed?(owner, owner, :admin)
    assert_not RoleChangePolicy.allowed?(owner, owner, :member)
  end

  test "can demote yourself if there are other owners" do
    owner = users(:owner)
    other_owner = users(:another_owner)

    assert_equal owner.account_id, other_owner.account_id

    assert RoleChangePolicy.allowed?(owner, owner, :admin)
  end
end
```

**Step 2: Add test fixtures**

Update `test/fixtures/users.yml` to add missing test users:

```yaml
admin:
  email: admin@example.com
  name: Admin User
  role: 1
  account: default

another_member:
  email: another@example.com
  name: Another Member
  role: 0
  account: default

another_owner:
  email: another_owner@example.com
  name: Another Owner
  role: 2
  account: default
```

**Step 3: Run test to verify it fails**

Run: `bin/rails test test/policies/role_change_policy_test.rb -v`

Expected: FAIL with "uninitialized constant RoleChangePolicy"

**Step 4: Write minimal implementation**

Create `app/policies/role_change_policy.rb`:

```ruby
class RoleChangePolicy
  # Check if actor can change target's role to new_role
  def self.allowed?(actor, target, new_role)
    return false unless actor.admin?

    new_role = new_role.to_s

    # Owner can do anything
    return true if actor.role == "owner"

    # Admin rules
    if actor.role == "admin"
      # Cannot promote to owner
      return false if new_role == "owner"

      # Cannot modify owners
      return false if target.role == "owner"

      # Can promote members to admin
      return true
    end

    # Check if trying to demote yourself as the last owner
    if actor.id == target.id && actor.role == "owner"
      other_owners_count = actor.account.users
        .where(role: User.roles[:owner])
        .where.not(id: actor.id)
        .count

      return false if other_owners_count == 0 && new_role != "owner"
    end

    false
  end
end
```

**Step 5: Run test to verify it passes**

Run: `bin/rails test test/policies/role_change_policy_test.rb -v`

Expected: PASS (7 tests)

**Step 6: Commit**

```bash
git add app/policies/role_change_policy.rb test/policies/role_change_policy_test.rb test/fixtures/users.yml
git commit -m "feat: add role change authorization policy"
```

---

## Task 2: Controller Action for Role Updates

**Files:**
- Modify: `app/controllers/admin/users_controller.rb:48-59`
- Modify: `config/routes.rb` (find admin users routes)
- Test: `test/controllers/admin/users_controller_test.rb`

**Step 1: Write the failing tests**

Add to `test/controllers/admin/users_controller_test.rb` before the final `end`:

```ruby
  test "update_role changes user role when authorized" do
    owner_user = users(:owner)
    member_user = users(:member)

    patch update_role_admin_user_path(member_user), params: {
      role: "admin"
    }

    assert_redirected_to admin_user_path(member_user)
    member_user.reload
    assert_equal "admin", member_user.role
    assert_match /role updated/i, flash[:notice]
  end

  test "update_role rejects unauthorized role changes" do
    # Sign in as admin (not owner)
    delete admin_session_path
    admin_user = users(:admin)
    sign_in_as_admin admins(:regular_admin)

    owner_user = users(:owner)

    patch update_role_admin_user_path(owner_user), params: {
      role: "member"
    }

    assert_redirected_to admin_user_path(owner_user)
    owner_user.reload
    assert_equal "owner", owner_user.role
    assert_match /not authorized/i, flash[:alert]
  end

  test "update_role publishes role changed event" do
    member_user = users(:member)

    events = []
    ActiveSupport::Notifications.subscribe("lifecycle.role_changed") do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end

    patch update_role_admin_user_path(member_user), params: {
      role: "admin"
    }

    assert_equal 1, events.count
    assert_equal member_user.id, events.first.payload[:user].id
    assert_equal "member", events.first.payload[:old_role]
    assert_equal "admin", events.first.payload[:new_role]
  end

  test "update_role prevents last owner demotion" do
    owner_user = users(:owner)

    # Ensure this is the only owner
    owner_user.account.users.where(role: :owner).where.not(id: owner_user.id).destroy_all

    patch update_role_admin_user_path(owner_user), params: {
      role: "admin"
    }

    assert_redirected_to admin_user_path(owner_user)
    owner_user.reload
    assert_equal "owner", owner_user.role
    assert_match /not authorized/i, flash[:alert]
  end
```

**Step 2: Add admin fixture**

Update `test/fixtures/admins.yml` to add regular_admin if needed:

```yaml
regular_admin:
  email: regular@admin.com
  password_digest: <%= BCrypt::Password.create('password') %>
```

**Step 3: Run test to verify it fails**

Run: `bin/rails test test/controllers/admin/users_controller_test.rb::test_update_role_changes_user_role_when_authorized -v`

Expected: FAIL with "undefined method `update_role_admin_user_path'"

**Step 4: Add route**

Find the admin users resources in `config/routes.rb` (should be around line 10-20 in the admin namespace) and modify:

```ruby
namespace :admin do
  resources :users, only: [ :index, :show, :update, :destroy ] do
    member do
      patch :update_role
    end
  end
  # ... other routes
end
```

**Step 5: Run test again**

Run: `bin/rails test test/controllers/admin/users_controller_test.rb::test_update_role_changes_user_role_when_authorized -v`

Expected: FAIL with "The action 'update_role' could not be found"

**Step 6: Implement controller action**

Add to `app/controllers/admin/users_controller.rb` after the `update` action (around line 47):

```ruby
  def update_role
    new_role = params[:role]

    unless RoleChangePolicy.allowed?(current_admin, @user, new_role)
      redirect_to admin_user_path(@user),
        alert: "You are not authorized to change this user's role"
      return
    end

    old_role = @user.role

    if @user.update(role: new_role)
      # Publish role changed event
      ActiveSupport::Notifications.instrument(
        "lifecycle.role_changed",
        user: @user,
        old_role: old_role,
        new_role: @user.role
      )

      redirect_to admin_user_path(@user), notice: "User role updated"
    else
      redirect_back fallback_location: admin_user_path(@user),
        alert: @user.errors.full_messages.join(", ")
    end
  end
```

**Step 7: Update before_action**

Modify the before_action at the top of `app/controllers/admin/users_controller.rb` (line 2):

```ruby
before_action :set_user, only: [ :show, :update, :update_role, :destroy ]
```

**Step 8: Run tests to verify they pass**

Run: `bin/rails test test/controllers/admin/users_controller_test.rb -v`

Expected: PASS (all tests including 4 new ones)

**Step 9: Commit**

```bash
git add app/controllers/admin/users_controller.rb config/routes.rb test/controllers/admin/users_controller_test.rb test/fixtures/admins.yml
git commit -m "feat: add secure role update controller action"
```

---

## Task 3: Frontend UI for Role Changes

**Files:**
- Check: `app/javascript/pages/admin/users/Show.svelte` (or .tsx if React)
- Create component for role selector
- Modify show page to include role change UI

**Step 1: Identify frontend framework**

Run: `ls app/javascript/pages/admin/users/`

Expected: Show.svelte or Show.tsx or Show.jsx

**Step 2: Read current show page structure**

Read the file to understand current structure and props.

**Step 3: Create role selector component (if Svelte)**

Create `app/javascript/components/admin/RoleSelector.svelte`:

```svelte
<script>
  import { router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button'
  import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
  } from '$lib/components/ui/select'

  export let user
  export let canChangeRole = false

  const roles = [
    { value: 'member', label: 'Member' },
    { value: 'admin', label: 'Admin' },
    { value: 'owner', label: 'Owner' }
  ]

  let selectedRole = user.role
  let isUpdating = false

  function handleRoleChange() {
    if (selectedRole === user.role) return

    isUpdating = true
    router.patch(`/admin/users/${user.id}/update_role`, {
      role: selectedRole
    }, {
      preserveScroll: true,
      onFinish: () => { isUpdating = false }
    })
  }
</script>

<div class="space-y-4">
  <div class="flex items-center gap-4">
    <div class="flex-1">
      <label for="role-select" class="block text-sm font-medium mb-2">
        User Role
      </label>
      <Select bind:value={selectedRole} disabled={!canChangeRole || isUpdating}>
        <SelectTrigger id="role-select" class="w-full">
          <SelectValue placeholder="Select role" />
        </SelectTrigger>
        <SelectContent>
          {#each roles as role}
            <SelectItem value={role.value}>{role.label}</SelectItem>
          {/each}
        </SelectContent>
      </Select>
    </div>

    {#if canChangeRole && selectedRole !== user.role}
      <Button
        on:click={handleRoleChange}
        disabled={isUpdating}
        class="mt-6"
      >
        {isUpdating ? 'Updating...' : 'Update Role'}
      </Button>
    {/if}
  </div>

  {#if !canChangeRole}
    <p class="text-sm text-muted-foreground">
      You don't have permission to change this user's role
    </p>
  {/if}
</div>
```

**Step 4: Update show page to include role selector**

Modify `app/javascript/pages/admin/users/Show.svelte` to import and use the component:

```svelte
<script>
  import RoleSelector from '$lib/components/admin/RoleSelector.svelte'

  export let user
  export let account
  export let sessions
  export let canChangeRole = true  // This will come from backend

  // ... rest of existing code
</script>

<!-- Add in the appropriate section of the template -->
<section>
  <h2>Role Management</h2>
  <RoleSelector {user} {canChangeRole} />
</section>
```

**Step 5: Update controller to pass canChangeRole prop**

Modify `app/controllers/admin/users_controller.rb` show action (around line 19-26):

```ruby
  def show
    # Check if current admin can change this user's role
    can_change_role = User.roles.keys.any? { |role|
      RoleChangePolicy.allowed?(current_admin, @user, role)
    }

    render inertia: "admin/users/Show", props: {
      user: @user.as_json(only: [ :id, :email, :name, :role, :avatar_url, :created_at, :updated_at ]),
      account: @user.account.as_json(only: [ :id, :name, :subdomain ]),
      sessions: @user.sessions.order(created_at: :desc).limit(10)
        .as_json(only: [ :id, :ip_address, :user_agent, :created_at ]),
      canChangeRole: can_change_role
    }
  end
```

**Step 6: Manual testing**

Start the server and verify:
1. Navigate to an admin user show page
2. See role selector component
3. Change a role and verify it updates
4. Verify authorization messages appear correctly

Run: `bin/rails server`

**Step 7: Commit**

```bash
git add app/javascript/components/admin/RoleSelector.svelte app/javascript/pages/admin/users/Show.svelte app/controllers/admin/users_controller.rb
git commit -m "feat: add role change UI to admin user show page"
```

---

## Task 4: System Tests for Role Change Flow

**Files:**
- Create: `test/system/admin/role_changes_test.rb`

**Step 1: Write system test**

Create `test/system/admin/role_changes_test.rb`:

```ruby
require "application_system_test_case"

class Admin::RoleChangesTest < ApplicationSystemTestCase
  setup do
    @admin = admins(:super_admin)
    @member = users(:member)
    sign_in_as_admin @admin
  end

  test "owner can change member to admin" do
    visit admin_user_path(@member)

    # Wait for page to load
    assert_selector "h1", text: @member.email

    # Find and change role selector
    select "Admin", from: "role-select"
    click_button "Update Role"

    # Verify success message
    assert_text "User role updated"

    # Verify role changed
    @member.reload
    assert_equal "admin", @member.role
  end

  test "shows authorization message when cannot change role" do
    # Sign in as admin (not owner)
    delete admin_session_path
    admin = admins(:regular_admin)
    sign_in_as_admin admin

    owner = users(:owner)
    visit admin_user_path(owner)

    # Should see message about no permission
    assert_text "don't have permission"
    assert_no_button "Update Role"
  end
end
```

**Step 2: Run test to verify behavior**

Run: `bin/rails test:system test/system/admin/role_changes_test.rb -v`

Expected: PASS (2 tests)

**Step 3: Commit**

```bash
git add test/system/admin/role_changes_test.rb
git commit -m "test: add system tests for role change flow"
```

---

## Task 5: Security Documentation

**Files:**
- Create: `docs/features/role-management.md`

**Step 1: Write documentation**

Create `docs/features/role-management.md`:

```markdown
# Role Management

## Overview

The application has three user roles with escalating privileges:
- **Member** (0): Basic user access
- **Admin** (1): Can manage users but cannot create owners
- **Owner** (2): Full account control

## Security Model

### Authorization Rules

Role changes are governed by `RoleChangePolicy` with these rules:

1. **Owners can:**
   - Change any user to any role
   - Demote themselves if there's at least one other owner

2. **Admins can:**
   - Promote members to admin
   - Cannot promote anyone to owner
   - Cannot modify owners

3. **Members cannot:**
   - Change any roles

4. **Protection:**
   - Cannot demote the last owner in an account
   - Prevents privilege escalation attacks
   - Uses dedicated controller action (not mass assignment)

### Implementation

**Controller:** `Admin::UsersController#update_role`
- Dedicated action for role changes only
- Explicit authorization check before update
- Publishes `lifecycle.role_changed` event

**Policy:** `RoleChangePolicy.allowed?(actor, target, new_role)`
- Centralized authorization logic
- Returns boolean for authorization decision

**Frontend:** `RoleSelector.svelte`
- Only shows UI if user has permission
- Prevents unauthorized requests at UI level

## Usage

### Changing a User's Role

1. Navigate to Admin > Users
2. Click on user to view details
3. Use Role Selector dropdown
4. Click "Update Role"

### Monitoring Role Changes

Role changes publish lifecycle events:

```ruby
ActiveSupport::Notifications.subscribe("lifecycle.role_changed") do |name, start, finish, id, payload|
  user = payload[:user]
  old_role = payload[:old_role]
  new_role = payload[:new_role]

  # Log, notify, audit, etc.
end
```

## Security Considerations

1. **Mass Assignment Protection:** Role not included in general user params
2. **Authorization:** Checked on every request, not just UI
3. **Last Owner Protection:** Prevents account lockout
4. **Audit Trail:** Events published for monitoring
5. **Frontend Validation:** Secondary defense (backend is source of truth)

## Testing

- Policy tests: `test/policies/role_change_policy_test.rb`
- Controller tests: `test/controllers/admin/users_controller_test.rb`
- System tests: `test/system/admin/role_changes_test.rb`

Run all role-related tests:
```bash
bin/rails test test/policies/role_change_policy_test.rb
bin/rails test test/controllers/admin/users_controller_test.rb
bin/rails test:system test/system/admin/role_changes_test.rb
```
```

**Step 2: Commit**

```bash
git add docs/features/role-management.md
git commit -m "docs: add role management security documentation"
```

---

## Verification Steps

After completing all tasks, verify the implementation:

1. **Run all tests:**
   ```bash
   bin/rails test
   bin/rails test:system
   ```

2. **Run Brakeman security scan:**
   ```bash
   brakeman -q
   ```
   Expected: No warnings

3. **Manual security testing:**
   - Try to change role via direct PATCH request as non-owner
   - Verify last owner cannot demote themselves
   - Verify admin cannot create owners

4. **Check event publishing:**
   ```bash
   bin/rails console
   > ActiveSupport::Notifications.subscribe("lifecycle.role_changed") { |*args| pp args }
   > # Change a role via UI
   ```

---

## Notes

- This implementation assumes Svelte frontend. Adjust Task 3 if using React/Vue
- The policy can be extended to support more granular permissions
- Consider adding role change history table for audit trail
- Event subscribers can be added for email notifications, logging, etc.
