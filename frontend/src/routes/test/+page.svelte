<script lang="ts">
  import { invoke } from '@tauri-apps/api/core';
  import { onMount } from 'svelte';

  // Tests results
  let testResults = $state<{ [key: string]: { status: 'pending' | 'success' | 'error' | 'running', result?: string, duration?: number } }>({});
  
  // Form states
  let greetName = $state('Test User');
  let mathA = $state(15);
  let mathB = $state(25);
  let jsonInput = $state('{"name": "test", "value": 42}');

  // Test functions
  async function runTest(testName: string, testFn: () => Promise<any>) {
    testResults[testName] = { status: 'running' };
    const startTime = Date.now();
    
    try {
      const result = await testFn();
      const duration = Date.now() - startTime;
      testResults[testName] = { 
        status: 'success', 
        result: typeof result === 'string' ? result : JSON.stringify(result),
        duration 
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      testResults[testName] = { 
        status: 'error', 
        result: error instanceof Error ? error.message : String(error),
        duration 
      };
    }
  }

  async function testBasicOperation() {
    await runTest('basic', () => invoke('test_basic_operation'));
  }

  async function testMathOperation() {
    await runTest('math', () => invoke('test_math_operation', { a: mathA, b: mathB }));
  }

  async function testAsyncDelay() {
    await runTest('async', () => invoke('test_async_delay'));
  }

  async function testErrorHandling() {
    await runTest('error', async () => {
      try {
        await invoke('test_error_handling');
        throw new Error('Expected an error, but the command succeeded.');
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        // This test is supposed to fail on the Rust side; if we caught the expected error,
        // the UI test should be considered a success.
        if (message.includes('Erreur de test volontaire')) return message;
        throw new Error(`Unexpected error: ${message}`);
      }
    });
  }

  async function testGreet() {
    await runTest('greet', () => invoke('greet', { name: greetName }));
  }

  async function testSystemInfo() {
    await runTest('systemInfo', () => invoke('get_system_info'));
  }


  async function testFileOperations() {
    await runTest('fileOps', () => invoke('test_file_operations'));
  }

  async function testJsonParsing() {
    await runTest('jsonParsing', () => invoke('test_json_parsing', { jsonStr: jsonInput }));
  }

  async function testNetworkSimulation() {
    await runTest('networkSim', () => invoke('test_network_simulation'));
  }

  async function testMemoryUsage() {
    await runTest('memoryUsage', () => invoke('test_memory_usage'));
  }

  async function runAllTests() {
    testResults = {};
    await testBasicOperation();
    await testMathOperation();
    await testGreet();
    await testSystemInfo();
    await testFileOperations();
    await testJsonParsing();
    await testNetworkSimulation();
    await testMemoryUsage();
    await testAsyncDelay();
    await testErrorHandling();
  }

  function getStatusColor(status: string) {
    switch (status) {
      case 'success': return 'text-green-600 dark:text-green-400';
      case 'error': return 'text-red-600 dark:text-red-400';
      case 'running': return 'text-blue-600 dark:text-blue-400';
      default: return 'text-gray-600 dark:text-gray-400';
    }
  }

  function getStatusIcon(status: string) {
    switch (status) {
      case 'success': return '✅';
      case 'error': return '❌';
      case 'running': return '⏳';
      default: return '⚪';
    }
  }

  // Initialize tests on mount
  onMount(() => {
    testResults = {
      basic: { status: 'pending' },
      math: { status: 'pending' },
      greet: { status: 'pending' },
      systemInfo: { status: 'pending' },
      fileOps: { status: 'pending' },
      jsonParsing: { status: 'pending' },
      networkSim: { status: 'pending' },
      memoryUsage: { status: 'pending' },
      async: { status: 'pending' },
      error: { status: 'pending' }
    };
  });
</script>

<svelte:head>
  <title>Test Suite - Tauri + SvelteKit</title>
</svelte:head>

<div class="p-6">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-3xl font-bold mb-8 text-center">🔧 Complete Test Suite</h1>
    
    <!-- Quick actions -->
    <div class="mb-8 text-center">
      <button
        onclick={runAllTests}
        class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200 mr-4"
      >
        🚀 Run All Tests
      </button>
      <button
        onclick={() => testResults = {}}
        class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200"
      >
        🗑️ Clear Results
      </button>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
      
      <!-- Basic tests -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">🧪 Basic Tests</h2>
        
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">Basic Operation</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.basic?.status || 'pending')}>
                {getStatusIcon(testResults.basic?.status || 'pending')}
              </span>
              <button
                onclick={testBasicOperation}
                class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <div class="flex items-center space-x-2">
              <span class="font-medium">Math:</span>
              <input bind:value={mathA} type="number" class="w-16 px-2 py-1 rounded border dark:bg-gray-600" />
              <span>+</span>
              <input bind:value={mathB} type="number" class="w-16 px-2 py-1 rounded border dark:bg-gray-600" />
            </div>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.math?.status || 'pending')}>
                {getStatusIcon(testResults.math?.status || 'pending')}
              </span>
              <button
                onclick={testMathOperation}
                class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <div class="flex items-center space-x-2">
              <span class="font-medium">Greeting:</span>
              <input bind:value={greetName} class="px-2 py-1 rounded border dark:bg-gray-600" />
            </div>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.greet?.status || 'pending')}>
                {getStatusIcon(testResults.greet?.status || 'pending')}
              </span>
              <button
                onclick={testGreet}
                class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- System Tests -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">🖥️ System Tests</h2>
        
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">System Information</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.systemInfo?.status || 'pending')}>
                {getStatusIcon(testResults.systemInfo?.status || 'pending')}
              </span>
              <button
                onclick={testSystemInfo}
                class="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- I/O & Performance Tests -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">💾 I/O & Performance Tests</h2>
        
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">File Operations</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.fileOps?.status || 'pending')}>
                {getStatusIcon(testResults.fileOps?.status || 'pending')}
              </span>
              <button
                onclick={testFileOperations}
                class="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>

          <div class="p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <div class="flex items-center justify-between mb-2">
              <span class="font-medium">JSON Parsing</span>
              <div class="flex items-center space-x-2">
                <span class={getStatusColor(testResults.jsonParsing?.status || 'pending')}>
                  {getStatusIcon(testResults.jsonParsing?.status || 'pending')}
                </span>
                <button
                  onclick={testJsonParsing}
                  class="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded text-sm"
                >
                  Test
                </button>
              </div>
            </div>
            <textarea
              bind:value={jsonInput}
              class="w-full p-2 text-xs bg-white dark:bg-gray-600 border rounded resize-none"
              rows="2"
              placeholder="JSON to test"
            ></textarea>
          </div>

          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">Network Simulation</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.networkSim?.status || 'pending')}>
                {getStatusIcon(testResults.networkSim?.status || 'pending')}
              </span>
              <button
                onclick={testNetworkSimulation}
                class="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">Memory Test (1MB)</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.memoryUsage?.status || 'pending')}>
                {getStatusIcon(testResults.memoryUsage?.status || 'pending')}
              </span>
              <button
                onclick={testMemoryUsage}
                class="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Advanced Tests -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">⚡ Advanced Tests</h2>
        
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">Async Operation (1s)</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.async?.status || 'pending')}>
                {getStatusIcon(testResults.async?.status || 'pending')}
              </span>
              <button
                onclick={testAsyncDelay}
                class="bg-purple-500 hover:bg-purple-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded">
            <span class="font-medium">Error Handling</span>
            <div class="flex items-center space-x-2">
              <span class={getStatusColor(testResults.error?.status || 'pending')}>
                {getStatusIcon(testResults.error?.status || 'pending')}
              </span>
              <button
                onclick={testErrorHandling}
                class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm"
              >
                Test
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Results -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">📊 Test Results</h2>
        
        <div class="space-y-3 max-h-80 overflow-y-auto">
          {#each Object.entries(testResults) as [testName, result]}
            <div class="p-3 bg-gray-50 dark:bg-gray-700 rounded">
              <div class="flex items-center justify-between mb-1">
                <span class="font-medium capitalize">{testName}</span>
                <div class="flex items-center space-x-2">
                  <span class={getStatusColor(result.status)}>
                    {getStatusIcon(result.status)}
                  </span>
                  {#if result.duration !== undefined}
                    <span class="text-xs text-gray-500">({result.duration}ms)</span>
                  {/if}
                </div>
              </div>
              {#if result.result}
                <div class="text-sm bg-gray-100 dark:bg-gray-600 p-2 rounded mt-2 break-all">
                  {result.result}
                </div>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    </div>

    <!-- Footer with stats -->
    <div class="mt-8 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
      <div class="flex justify-between items-center text-sm">
        <span>Tests: {Object.keys(testResults).length}</span>
        <span class="text-green-600">
          Passed: {Object.values(testResults).filter(r => r.status === 'success').length}
        </span>
        <span class="text-red-600">
          Failed: {Object.values(testResults).filter(r => r.status === 'error').length}  
        </span>
        <span class="text-blue-600">
          Running: {Object.values(testResults).filter(r => r.status === 'running').length}
        </span>
      </div>
    </div>
  </div>
</div>