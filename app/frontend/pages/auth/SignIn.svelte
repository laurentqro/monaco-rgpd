<script>
  import { router } from '@inertiajs/svelte'

  let { errors = [] } = $props()

  let email = $state('')
  let name = $state('')
  let accountName = $state('')
  let isSubmitting = $state(false)
  let emailError = $state('')

  function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  function handleSubmit(event) {
    event.preventDefault()

    // Reset errors
    emailError = ''

    // Validate email
    if (!email) {
      emailError = 'Email is required'
      return
    }

    if (!validateEmail(email)) {
      emailError = 'Please enter a valid email address'
      return
    }

    isSubmitting = true

    router.post('/magic_links', {
      email,
      name: name || undefined,
      account_name: accountName || undefined
    }, {
      onFinish: () => {
        isSubmitting = false
      }
    })
  }
</script>

<div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
  <div class="w-full max-w-md">
    <div class="bg-white rounded-lg shadow-xl px-8 py-10">
      <!-- Header -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Rails SaaS Starter
        </h1>
        <p class="text-gray-600">
          Sign in with your email to get started
        </p>
      </div>

      <!-- Error messages -->
      {#if errors && errors.length > 0}
        <div class="mb-6 bg-red-50 border border-red-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">
                {errors.length === 1 ? 'There was an error' : 'There were errors'} with your submission
              </h3>
              <div class="mt-2 text-sm text-red-700">
                <ul class="list-disc list-inside space-y-1">
                  {#each errors as error, i (i)}
                    <li>{error}</li>
                  {/each}
                </ul>
              </div>
            </div>
          </div>
        </div>
      {/if}

      <!-- Form -->
      <form onsubmit={handleSubmit} class="space-y-6">
        <!-- Email field -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
            Email address *
          </label>
          <input
            id="email"
            type="email"
            bind:value={email}
            required
            disabled={isSubmitting}
            class="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100 disabled:cursor-not-allowed transition-colors"
            placeholder="you@example.com"
            aria-describedby={emailError ? "email-error" : undefined}
            aria-invalid={emailError ? "true" : undefined}
          />
          {#if emailError}
            <p id="email-error" class="mt-2 text-sm text-red-600">
              {emailError}
            </p>
          {/if}
        </div>

        <!-- Optional divider -->
        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-200"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-2 bg-white text-gray-500">Optional for new users</span>
          </div>
        </div>

        <!-- Name field -->
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
            Your name
          </label>
          <input
            id="name"
            type="text"
            bind:value={name}
            disabled={isSubmitting}
            class="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100 disabled:cursor-not-allowed transition-colors"
            placeholder="John Doe"
          />
          <p class="mt-1 text-xs text-gray-500">
            Only needed for new accounts
          </p>
        </div>

        <!-- Account name field -->
        <div>
          <label for="account-name" class="block text-sm font-medium text-gray-700 mb-2">
            Account name
          </label>
          <input
            id="account-name"
            type="text"
            bind:value={accountName}
            disabled={isSubmitting}
            class="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100 disabled:cursor-not-allowed transition-colors"
            placeholder="My Company"
          />
          <p class="mt-1 text-xs text-gray-500">
            Only needed for new accounts
          </p>
        </div>

        <!-- Submit button -->
        <button
          type="submit"
          disabled={isSubmitting}
          class="w-full flex justify-center items-center px-4 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-indigo-400 disabled:cursor-not-allowed transition-colors"
        >
          {#if isSubmitting}
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Sending magic link...
          {:else}
            Send magic link
          {/if}
        </button>
      </form>

      <!-- Footer -->
      <div class="mt-6 text-center">
        <p class="text-xs text-gray-500">
          We'll send you a magic link to sign in without a password
        </p>
      </div>
    </div>
  </div>
</div>
