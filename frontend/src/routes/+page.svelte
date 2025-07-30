<script lang="ts">
  import { invoke } from '@tauri-apps/api/core';
  import { onMount } from 'svelte';

  let systemInfo: any = null;
  let isLoading = false;
  let error = '';

  async function fetchSystemInfo() {
    try {
      isLoading = true;
      error = '';
      systemInfo = await invoke('get_system_info');
    } catch (err) {
      error = `Error: ${err}`;
      console.error('Error invoking get_system_info:', err);
    } finally {
      isLoading = false;
    }
  }

  onMount(() => {
    fetchSystemInfo();
  });
</script>

<svelte:head>
  <title>Tauri + SvelteKit Boilerplate</title>
</svelte:head>

<div class="px-4 py-6 sm:px-0">
  <div class="border-4 border-dashed border-gray-200 dark:border-gray-700 rounded-lg p-8">
    <div class="text-center">
      <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-4">
        Tauri + SvelteKit + Tailwind
      </h1>
      <p class="text-lg text-gray-600 dark:text-gray-300 mb-8">
        Production-ready boilerplate with Rust ↔ Frontend communication
      </p>

      <div class="max-w-md mx-auto">
        <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6 mb-6">
          <h2 class="text-xl font-semibold mb-4">Example: System Information</h2>
          
          <button
            onclick={fetchSystemInfo}
            disabled={isLoading}
            class="w-full bg-primary-600 hover:bg-primary-700 disabled:opacity-50 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200"
          >
            {isLoading ? 'Loading...' : 'Get System Info'}
          </button>

          {#if error}
            <div class="mt-4 p-3 bg-red-100 dark:bg-red-900/20 border border-red-400 dark:border-red-700 text-red-700 dark:text-red-400 rounded">
              {error}
            </div>
          {/if}

          {#if systemInfo}
            <div class="mt-4">
              <h3 class="font-medium mb-2">System detected:</h3>
              <div class="space-y-1">
                <div class="text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">
                  OS: {systemInfo.os}
                </div>
                <div class="text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">
                  Architecture: {systemInfo.arch}
                </div>
                <div class="text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">
                  Version: {systemInfo.version}
                </div>
              </div>
            </div>
          {/if}
        </div>

        <div class="text-sm text-gray-500 dark:text-gray-400 space-y-2">
          <p>✅ Dark mode working</p>
          <p>✅ Rust ↔ Frontend communication</p>
          <p>✅ Tailwind CSS configured</p>
          <p>✅ Clean project structure</p>
          
          <div class="pt-4">
            <a href="/test" class="inline-flex items-center px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-medium rounded-lg transition-colors duration-200">
              🔧 Complete Test Suite
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>