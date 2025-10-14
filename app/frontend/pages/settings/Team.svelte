<script>
  import SettingsLayout from '../../components/SettingsLayout.svelte'

  let { members, is_admin } = $props()
</script>

<SettingsLayout>
  {#snippet children()}
    <div class="px-4 py-5 sm:p-6">
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-lg font-semibold text-gray-900">Team Members</h3>
        {#if is_admin}
          <button
            disabled
            class="px-4 py-2 bg-gray-400 text-white rounded-lg cursor-not-allowed"
            title="Team invitations coming soon"
          >
            Invite Member
          </button>
        {/if}
      </div>

      <div class="bg-white overflow-hidden">
        <ul class="divide-y divide-gray-200">
          {#each members as member}
            <li class="px-4 py-4 flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-semibold">
                  {member.name?.[0]?.toUpperCase() || member.email?.[0]?.toUpperCase()}
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">
                    {member.name || member.email}
                  </p>
                  <p class="text-sm text-gray-500">{member.email}</p>
                </div>
              </div>
              <div class="flex items-center space-x-4">
                <span class="px-3 py-1 text-xs font-medium rounded-full {
                  member.role === 'owner' ? 'bg-purple-100 text-purple-800' :
                  member.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                  'bg-gray-100 text-gray-800'
                }">
                  {member.role}
                </span>
                {#if is_admin && member.role !== 'owner'}
                  <button
                    disabled
                    class="text-sm text-gray-400 cursor-not-allowed"
                    title="Team management coming soon"
                  >
                    Manage
                  </button>
                {/if}
              </div>
            </li>
          {/each}
        </ul>
      </div>

      <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p class="text-sm text-blue-800">
          <strong>Coming soon:</strong> Invite team members, manage roles, and remove users.
        </p>
      </div>
    </div>
  {/snippet}
</SettingsLayout>
