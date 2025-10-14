<script>
  import { useForm } from '@inertiajs/svelte'
  import SettingsLayout from '../../components/SettingsLayout.svelte'

  let { user } = $props()

  const form = useForm({
    user: {
      email_lifecycle_notifications: user.email_lifecycle_notifications
    }
  })

  function handleToggle() {
    $form.patch('/settings/notifications', {
      preserveScroll: true,
      onSuccess: () => {
        // Flash message will be handled by the server
      }
    })
  }
</script>

<SettingsLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-6">Email Notifications</h3>

      <div class="space-y-6">
        <!-- Security Emails Section -->
        <div>
          <h4 class="text-base font-semibold text-gray-900 mb-3">Security Notifications</h4>
          <p class="text-sm text-gray-600 mb-4">
            Security emails are always sent to protect your account. These include notifications about password changes, suspicious logins, and account deletion requests.
          </p>
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-start">
              <svg class="w-5 h-5 text-blue-600 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path>
              </svg>
              <span class="text-sm text-blue-800 font-medium">Always enabled for your security</span>
            </div>
          </div>
        </div>

        <!-- Lifecycle Emails Section -->
        <div class="pt-6 border-t border-gray-200">
          <h4 class="text-base font-semibold text-gray-900 mb-3">Account Activity Notifications</h4>
          <p class="text-sm text-gray-600 mb-4">
            Receive emails about account activity such as welcome messages, invitations, and role changes.
          </p>

          <label class="flex items-start space-x-3 cursor-pointer">
            <input
              type="checkbox"
              bind:checked={$form.user.email_lifecycle_notifications}
              on:change={handleToggle}
              disabled={$form.processing}
              class="mt-1 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-2 focus:ring-blue-500 disabled:opacity-50"
            />
            <div class="flex-1">
              <span class="text-sm font-medium text-gray-900">
                Send me account activity notifications
              </span>
              <div class="mt-3 text-sm text-gray-500">
                <p class="mb-2">This includes:</p>
                <ul class="list-disc list-inside space-y-1 ml-2">
                  <li>Welcome emails</li>
                  <li>Team invitations</li>
                  <li>Role changes</li>
                </ul>
              </div>
            </div>
          </label>
        </div>
      </div>
    </div>
  {/snippet}
</SettingsLayout>
