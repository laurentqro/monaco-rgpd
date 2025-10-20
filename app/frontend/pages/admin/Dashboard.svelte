<script>
  import { Card, CardHeader, CardTitle, CardContent } from '$lib/components/ui/card';
  import { Badge } from '$lib/components/ui/badge';

  let { stats } = $props()
</script>

<div class="px-4 py-5 sm:p-6">
  <h2 class="text-lg font-semibold text-gray-900 mb-6">Dashboard</h2>

  <!-- Stats cards -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <Card class="bg-blue-50 border-blue-100">
      <CardContent class="pt-6">
        <div class="text-sm font-medium text-blue-600">Total Accounts</div>
        <div class="mt-2 text-3xl font-bold text-blue-900">{stats.total_accounts}</div>
      </CardContent>
    </Card>

    <Card class="bg-green-50 border-green-100">
      <CardContent class="pt-6">
        <div class="text-sm font-medium text-green-600">Total Users</div>
        <div class="mt-2 text-3xl font-bold text-green-900">{stats.total_users}</div>
      </CardContent>
    </Card>

    <Card class="bg-purple-50 border-purple-100">
      <CardContent class="pt-6">
        <div class="text-sm font-medium text-purple-600">Active Subscriptions</div>
        <div class="mt-2 text-3xl font-bold text-purple-900">{stats.active_subscriptions}</div>
      </CardContent>
    </Card>
  </div>

  <!-- Quick actions -->
  <div>
    <h3 class="text-base font-semibold text-gray-900 mb-4">Quick Actions</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <Card class="hover:bg-gray-50 transition-colors">
        <a href="/admin/accounts" class="block">
          <CardContent class="flex items-center justify-between p-4">
            <span class="font-medium text-gray-900">Manage Accounts</span>
            <span class="text-gray-400">→</span>
          </CardContent>
        </a>
      </Card>

      <Card class="hover:bg-gray-50 transition-colors">
        <a href="/admin/users" class="block">
          <CardContent class="flex items-center justify-between p-4">
            <span class="font-medium text-gray-900">Manage Users</span>
            <span class="text-gray-400">→</span>
          </CardContent>
        </a>
      </Card>

      <Card class="hover:bg-gray-50 transition-colors">
        <a href="/admin/subscriptions" class="block">
          <CardContent class="flex items-center justify-between p-4">
            <span class="font-medium text-gray-900">View Subscriptions</span>
            <span class="text-gray-400">→</span>
          </CardContent>
        </a>
      </Card>

      <Card class="hover:bg-gray-50 transition-colors">
        <a href="/admin/admins" class="block">
          <CardContent class="flex items-center justify-between p-4">
            <span class="font-medium text-gray-900">Manage Admins</span>
            <span class="text-gray-400">→</span>
          </CardContent>
        </a>
      </Card>
    </div>
  </div>
</div>
