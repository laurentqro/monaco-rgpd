<script>
  import { router } from '@inertiajs/svelte'

  let { email } = $props()

  function backToSignIn() {
    router.visit('/session/new')
  }
</script>

<div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
  <div class="w-full max-w-md">
    <div class="bg-white rounded-lg shadow-xl px-8 py-10">
      <!-- Success icon -->
      <div class="flex justify-center mb-6">
        <div class="rounded-full bg-green-100 p-3">
          <svg class="w-16 h-16 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 19v-8.93a2 2 0 01.89-1.664l7-4.666a2 2 0 012.22 0l7 4.666A2 2 0 0121 10.07V19M3 19a2 2 0 002 2h14a2 2 0 002-2M3 19l6.75-4.5M21 19l-6.75-4.5M3 10l6.75 4.5M21 10l-6.75 4.5m0 0l-1.14.76a2 2 0 01-2.22 0l-1.14-.76" />
          </svg>
        </div>
      </div>

      <!-- Header -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Check your email
        </h1>
        <p class="text-gray-600">
          We've sent a magic link to
        </p>
        <p class="text-lg font-semibold text-indigo-600 mt-2">
          {email}
        </p>
      </div>

      <!-- Instructions -->
      <div class="bg-blue-50 border border-blue-200 rounded-md p-4 mb-6">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-blue-800">
              What to do next
            </h3>
            <div class="mt-2 text-sm text-blue-700">
              <ol class="list-decimal list-inside space-y-1">
                <li>Open your email inbox</li>
                <li>Find the email from MonacoRGPD</li>
                <li>Click the magic link in the email</li>
                <li>You'll be automatically signed in</li>
              </ol>
            </div>
          </div>
        </div>
      </div>

      <!-- Additional info -->
      <div class="space-y-4">
        <div class="bg-gray-50 rounded-md p-4">
          <h3 class="text-sm font-medium text-gray-900 mb-2">
            Didn't receive the email?
          </h3>
          <ul class="text-sm text-gray-600 space-y-1">
            <li class="flex items-start">
              <span class="mr-2">•</span>
              <span>Check your spam or junk folder</span>
            </li>
            <li class="flex items-start">
              <span class="mr-2">•</span>
              <span>Make sure you entered the correct email address</span>
            </li>
            <li class="flex items-start">
              <span class="mr-2">•</span>
              <span>Wait a few minutes - it might take a moment to arrive</span>
            </li>
          </ul>
        </div>

        <!-- Back to sign in -->
        <button
          onclick={backToSignIn}
          class="w-full px-4 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors"
        >
          Back to sign in
        </button>
      </div>

      <!-- Footer note -->
      <div class="mt-6 text-center">
        <p class="text-xs text-gray-500">
          The magic link will expire in 15 minutes for security reasons
        </p>
      </div>
    </div>
  </div>
</div>
