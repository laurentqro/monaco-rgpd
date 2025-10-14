<!-- app/frontend/components/UserDropdown.svelte -->
<script>
  import { router, page } from '@inertiajs/svelte'

  let { user, account } = $props()
  let isOpen = $state(false)
  let dropdownRef = $state(null)

  function toggleDropdown() {
    isOpen = !isOpen
  }

  function closeDropdown() {
    isOpen = false
  }

  function signOut() {
    router.delete('/session')
  }

  function handleKeydown(event) {
    if (event.key === 'Escape') {
      closeDropdown()
    }
  }

  function handleClickOutside(event) {
    if (dropdownRef && !dropdownRef.contains(event.target)) {
      closeDropdown()
    }
  }

  $effect(() => {
    if (isOpen) {
      document.addEventListener('click', handleClickOutside)
      document.addEventListener('keydown', handleKeydown)
      return () => {
        document.removeEventListener('click', handleClickOutside)
        document.removeEventListener('keydown', handleKeydown)
      }
    }
  })
</script>

<div class="relative" bind:this={dropdownRef}>
  <button
    onclick={toggleDropdown}
    aria-expanded={isOpen}
    aria-haspopup="true"
    class="flex items-center space-x-3 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 rounded-lg px-3 py-2 hover:bg-gray-100"
  >
    <div class="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-semibold">
      {user?.name?.[0]?.toUpperCase() || user?.email?.[0]?.toUpperCase() || '?'}
    </div>
    <span class="text-sm font-medium text-gray-700">{user?.name || user?.email}</span>
    <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
    </svg>
  </button>

  {#if isOpen}
    <div
      class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-1 z-10 border border-gray-200"
      role="menu"
      aria-orientation="vertical"
    >
      <a
        href="/settings/profile"
        onclick={closeDropdown}
        role="menuitem"
        class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
      >
        Profile
      </a>
      {#if $page.props.is_super_admin}
        <a
          href="/admin"
          onclick={closeDropdown}
          role="menuitem"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
        >
          Admin Panel
        </a>
      {/if}
      <a
        href="/settings/account"
        role="menuitem"
        class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
      >
        Account Settings
      </a>
      <hr class="my-1 border-gray-200" />
      <button
        onclick={signOut}
        role="menuitem"
        class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
      >
        Sign Out
      </button>
    </div>
  {/if}
</div>
