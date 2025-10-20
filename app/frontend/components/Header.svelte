<!-- app/frontend/components/Header.svelte -->
<script>
  import { page } from '@inertiajs/svelte';
  import { Button } from '$lib/components/ui/button';
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
