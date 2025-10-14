<script>
  import SettingsLayout from '../../components/SettingsLayout.svelte'

  let { subscription, is_owner } = $props()
</script>

<SettingsLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-6">Billing & Subscription</h3>

      {#if !is_owner}
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <p class="text-sm text-yellow-800">
            Only the account owner can manage billing and subscriptions.
          </p>
        </div>
      {/if}

      <div class="bg-white border border-gray-200 rounded-lg p-6">
        <h4 class="text-base font-semibold text-gray-900 mb-4">Current Plan</h4>

        {#if subscription}
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-sm text-gray-600">Status</span>
              <span class="text-sm font-medium text-gray-900 capitalize">{subscription.status}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-sm text-gray-600">Plan</span>
              <span class="text-sm font-medium text-gray-900">{subscription.plan_type || 'Free'}</span>
            </div>
            {#if subscription.current_period_end}
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Renews</span>
                <span class="text-sm font-medium text-gray-900">
                  {new Date(subscription.current_period_end).toLocaleDateString()}
                </span>
              </div>
            {/if}
          </div>
        {:else}
          <p class="text-sm text-gray-600">
            No active subscription. You're currently on the free plan.
          </p>
        {/if}

        {#if is_owner}
          <div class="mt-6 pt-6 border-t border-gray-200">
            <button
              disabled
              class="px-4 py-2 bg-gray-400 text-white rounded-lg cursor-not-allowed"
              title="Polar.sh integration coming soon"
            >
              Manage Subscription
            </button>
          </div>
        {/if}
      </div>

      <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p class="text-sm text-blue-800">
          <strong>Coming soon:</strong> Polar.sh integration for subscription management, invoices, and payment methods.
        </p>
      </div>
    </div>
  {/snippet}
</SettingsLayout>
