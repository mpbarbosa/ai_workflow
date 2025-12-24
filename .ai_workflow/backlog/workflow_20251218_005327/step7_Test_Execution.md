# Step 7: Test_Execution

**Workflow Run ID:** workflow_20251218_005327
**Timestamp:** 2025-12-18 01:09:46
**Status:** Issues Found

---

## Issues and Findings

### Test Execution Results

**Total Tests:** 2
**Passed:** 6
**Failed:** 6
**Exit Code:** 0

### Coverage Metrics

- **Statements:** 0%
- **Branches:** 0%
- **Functions:** 0%
- **Lines:** 0%

### Test Output

```

> mpbarbosa-landing-page@1.0.0 test:coverage
> node --experimental-vm-modules node_modules/jest/bin/jest.js --coverage 2>&1 | grep -v 'localstorage-file'

(node:503149) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:503122) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:503129) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL __tests__/documentation.test.js
  ● Documentation Files Validation › Required Documentation Files › should contain sync documentation files

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      32 |       requiredDocs.forEach(doc => {
      33 |         const docPath = path.join(docsDir, doc);
    > 34 |         expect(fs.existsSync(docPath)).toBe(true);
         |                                        ^
      35 |         
      36 |         // Should be substantial documentation (not empty)
      37 |         const content = fs.readFileSync(docPath, 'utf8');

      at __tests__/documentation.test.js:34:40
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (__tests__/documentation.test.js:32:20)

(node:503142) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/music_in_numbers/tests/index-functions.jest.test.js
  ● Music in Numbers - OAuth Functions › Code Challenge Generation › should generate valid challenge

    ReferenceError: TextEncoder is not defined

      56 |  */
      57 | const generateCodeChallenge = async (verifier) => {
    > 58 |     const encoder = new TextEncoder();
         |                     ^
      59 |     const data = encoder.encode(verifier);
      60 |     const digest = await window.crypto.subtle.digest('SHA-256', data);
      61 |     return btoa(String.fromCharCode.apply(null, new Uint8Array(digest)))

      at generateCodeChallenge (submodules/music_in_numbers/tests/index-functions.jest.test.js:58:21)
      at Object.<anonymous> (submodules/music_in_numbers/tests/index-functions.jest.test.js:218:37)

  ● Music in Numbers - OAuth Functions › Code Challenge Generation › should be deterministic

    ReferenceError: TextEncoder is not defined

      56 |  */
      57 | const generateCodeChallenge = async (verifier) => {
    > 58 |     const encoder = new TextEncoder();
         |                     ^
      59 |     const data = encoder.encode(verifier);
      60 |     const digest = await window.crypto.subtle.digest('SHA-256', data);
      61 |     return btoa(String.fromCharCode.apply(null, new Uint8Array(digest)))

      at generateCodeChallenge (submodules/music_in_numbers/tests/index-functions.jest.test.js:58:21)
      at Object.<anonymous> (submodules/music_in_numbers/tests/index-functions.jest.test.js:230:38)

(node:503173) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/music_in_numbers/tests/spotify-auth-di.test.js
  ● Console

    console.error
      Auth initiation error: Error: PKCE generation failed
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/tests/spotify-auth-di.test.js:335:70)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12)

      116 |         
      117 |     } catch (error) {
    > 118 |         console.error('Auth initiation error:', error);
          |                 ^
      119 |         showResult('Failed to initiate authentication. Please try again.', 'error');
      120 |         
      121 |         connectBtn.disabled = false;

      at initiateAuthCore (submodules/music_in_numbers/tests/spotify-auth-di.test.js:118:17)
      at Object.<anonymous> (submodules/music_in_numbers/tests/spotify-auth-di.test.js:337:13)

(node:503121) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/music_in_numbers/tests/artist-functions.jest.test.js
FAIL submodules/music_in_numbers/tests/security-testing.test.js
  ● Test suite failed to run

    Your test suite must contain at least one test.

      at onResult (node_modules/@jest/core/build/index.js:1057:18)
      at node_modules/@jest/core/build/index.js:1127:165
      at node_modules/emittery/index.js:363:13
          at Array.map (<anonymous>)
      at Emittery.emit (node_modules/emittery/index.js:361:23)

(node:503181) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/music_in_numbers/src/scripts/analytics/__tests__/AnalyticsCore.test.js
(node:503136) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js
  ● Performance Benchmarking › OAuth Flow Performance › should complete OAuth flow within performance threshold

    ReferenceError: TextEncoder is not defined

      130 |
      131 | async function generateCodeChallengeOptimized(verifier) {
    > 132 |     const encoder = new TextEncoder();
          |                     ^
      133 |     const data = encoder.encode(verifier);
      134 |     const digest = await window.crypto.subtle.digest('SHA-256', data);
      135 |     return btoa(String.fromCharCode.apply(null, new Uint8Array(digest)))

      at generateCodeChallengeOptimized (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:132:21)
      at simulateOAuthFlow (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:166:33)
      at Object.<anonymous> (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:273:23)

  ● Performance Benchmarking › OAuth Flow Performance › should handle OAuth flow steps efficiently

    ReferenceError: TextEncoder is not defined

      130 |
      131 | async function generateCodeChallengeOptimized(verifier) {
    > 132 |     const encoder = new TextEncoder();
          |                     ^
      133 |     const data = encoder.encode(verifier);
      134 |     const digest = await window.crypto.subtle.digest('SHA-256', data);
      135 |     return btoa(String.fromCharCode.apply(null, new Uint8Array(digest)))

      at generateCodeChallengeOptimized (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:132:21)
      at simulateOAuthFlow (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:166:33)
      at Object.<anonymous> (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:295:34)

  ● Performance Benchmarking › PKCE Generation Performance › should generate PKCE parameters efficiently

    expect(received).toBe(expected) // Object.is equality

    Expected: 100
    Received: 0

      319 |             
      320 |             expect(analysis.averageDuration).toBeLessThan(PERFORMANCE_CONFIG.thresholds.pkceGeneration);
    > 321 |             expect(analysis.successRate).toBe(100);
          |                                          ^
      322 |             
      323 |             performanceMetrics.pkce = results;
      324 |         });

      at Object.<anonymous> (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:321:42)

  ● Performance Benchmarking › PKCE Generation Performance › should generate valid PKCE challenge

    ReferenceError: TextEncoder is not defined

      130 |
      131 | async function generateCodeChallengeOptimized(verifier) {
    > 132 |     const encoder = new TextEncoder();
          |                     ^
      133 |     const data = encoder.encode(verifier);
      134 |     const digest = await window.crypto.subtle.digest('SHA-256', data);
      135 |     return btoa(String.fromCharCode.apply(null, new Uint8Array(digest)))

      at generateCodeChallengeOptimized (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:132:21)
      at Object.<anonymous> (submodules/music_in_numbers/tests/performance-benchmarking.jest.test.js:336:37)

FAIL submodules/music_in_numbers/tests/performance-benchmarking.test.js
  ● Test suite failed to run

    Your test suite must contain at least one test.

      at onResult (node_modules/@jest/core/build/index.js:1057:18)
      at node_modules/@jest/core/build/index.js:1127:165
      at node_modules/emittery/index.js:363:13
          at Array.map (<anonymous>)
      at Emittery.emit (node_modules/emittery/index.js:361:23)

(node:503135) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/music_in_numbers/tests/analytics-core-patterns.jest.test.js
  ● AnalyticsCore - Core Business Logic › Error Handling Patterns › loadMusicAnalyticsCore should handle API errors gracefully

    TypeError: Cannot read properties of undefined (reading 'success')

      235 |
      236 |             // Assert
    > 237 |             expect(result.success).toBe(false);
          |                           ^
      238 |             expect(result.error).toBe('API Failure');
      239 |             expect(mockDependencies.logError).toHaveBeenCalled();
      240 |         });

      at Object.<anonymous> (submodules/music_in_numbers/tests/analytics-core-patterns.jest.test.js:237:27)

  ● AnalyticsCore - Core Business Logic › Error Handling Patterns › displayAdvancedMusicAnalyticsCore should handle UI builder errors

    TypeError: Cannot read properties of undefined (reading 'success')

      250 |
      251 |             // Assert
    > 252 |             expect(result.success).toBe(false);
          |                           ^
      253 |             expect(result.error).toBe('UI Generation Failed');
      254 |             expect(mockDependencies.logError).toHaveBeenCalled();
      255 |         });

      at Object.<anonymous> (submodules/music_in_numbers/tests/analytics-core-patterns.jest.test.js:252:27)

  ● AnalyticsCore - Core Business Logic › Dependency Injection Patterns › Functions should use injected logging functions

    expect(jest.fn()).toHaveBeenCalled()

    Expected number of calls: >= 1
    Received number of calls:    0

      295 |
      296 |             // Assert - should use injected logging
    > 297 |             expect(mockDependencies.logInfo).toHaveBeenCalled();
          |                                              ^
      298 |             expect(mockDependencies.showResult).toHaveBeenCalled();
      299 |         });
      300 |     });

      at Object.<anonymous> (submodules/music_in_numbers/tests/analytics-core-patterns.jest.test.js:297:46)

  ● AnalyticsCore - Core Business Logic › Data Flow Validation › loadMusicAnalyticsCore should process data through analytics processors

    expect(jest.fn()).toHaveBeenCalledWith(...expected)

    Expected: [{"track": {"id": "1", "name": "Recent Track 1"}}, {"track": {"id": "2", "name": "Recent Track 2"}}], [{"energy": 0.7, "id": "1", "valence": 0.8}, {"energy": 0.5, "id": "2", "valence": 0.6}], [{"artists": [{"name": "Artist 1"}], "id": "1", "name": "Track 1"}, {"artists": [{"name": "Artist 2"}], "id": "2", "name": "Track 2"}], [{"genres": ["pop"], "id": "1", "name": "Artist 1"}, {"genres": ["rock"], "id": "2", "name": "Artist 2"}]

    Number of calls: 0

      313 |
      314 |             // Assert
    > 315 |             expect(global.AnalyticsProcessors.analyzeListeningPatterns).toHaveBeenCalledWith(
          |                                                                         ^
      316 |                 mockAnalyticsData.recentlyPlayed,
      317 |                 mockAnalyticsData.audioFeatures,
      318 |                 mockAnalyticsData.topTracks,

      at Object.<anonymous> (submodules/music_in_numbers/tests/analytics-core-patterns.jest.test.js:315:73)

(node:503178) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/music_in_numbers/tests/security-testing.jest.test.js
(node:503161) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js
  ● Console

    console.error
      Auth initiation error: Error: Code verifier generation failed
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js:684:23
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-mock/build/index.js:305:39
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-mock/build/index.js:312:13
          at mockConstructor (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-mock/build/index.js:102:19)
          at SpotifyApiCore.initiateAuthCore (/home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js:68:34)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js:688:41)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12)

       96 |             
       97 |         } catch (error) {
    >  98 |             console.error('Auth initiation error:', error);
          |                     ^
       99 |             showResult('Failed to initiate authentication. Please try again.', 'error');
      100 |             
      101 |             connectBtn.disabled = false;

      at SpotifyApiCore.initiateAuthCore (submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js:98:21)
      at Object.<anonymous> (submodules/music_in_numbers/src/scripts/spotify-api/__tests__/SpotifyApiCore.test.js:688:41)

FAIL __tests__/main.test.js
  ● Test suite failed to run

    TypeError: The "original" argument must be of type function. Received an instance of Object

      at Object.<anonymous> (node_modules/test-exclude/index.js:5:14)
      at Object.<anonymous> (node_modules/babel-plugin-istanbul/lib/index.js:12:43)
      at _babelPluginIstanbul (node_modules/@jest/transform/build/index.js:52:39)
      at ScriptTransformer._instrumentFile (node_modules/@jest/transform/build/index.js:313:18)
      at ScriptTransformer._buildTransformResult (node_modules/@jest/transform/build/index.js:376:33)
      at ScriptTransformer.transformSourceAsync (node_modules/@jest/transform/build/index.js:471:17)
      at ScriptTransformer._transformAndBuildScriptAsync (node_modules/@jest/transform/build/index.js:488:35)
      at ScriptTransformer.transformAsync (node_modules/@jest/transform/build/index.js:542:14)

PASS submodules/music_in_numbers/src/scripts/analytics/__tests__/AnalyticsProcessors.test.js
(node:503155) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS __tests__/InitializationUtilities.test.js
  ● Console

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:123:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      121 |             // Mock location object for jsdom compatibility
      122 |             delete global.window.location;
    > 123 |             global.window.location = { hostname: '127.0.0.1', search: '' };
          |                                    ^
      124 |             
      125 |             const devEnv = InitializationUtilities.detectDevelopmentEnvironment();
      126 |             

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:123:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:134:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      132 |             // Mock location object for jsdom compatibility
      133 |             delete global.window.location;
    > 134 |             global.window.location = { hostname: '192.168.1.100', search: '' };
          |                                    ^
      135 |             
      136 |             const devEnv = InitializationUtilities.detectDevelopmentEnvironment();
      137 |             

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:134:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:144:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      142 |         test('should detect debug URL parameters', () => {
      143 |             delete global.window.location;
    > 144 |             global.window.location = {
          |                                    ^
      145 |                 hostname: 'localhost',
      146 |                 search: '?debug=true'
      147 |             };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:144:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:157:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      155 |         test('should detect dev URL parameter', () => {
      156 |             delete global.window.location;
    > 157 |             global.window.location = {
          |                                    ^
      158 |                 hostname: 'localhost',
      159 |                 search: '?dev=1'
      160 |             };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:157:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:170:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      168 |         test('should detect development URL parameter', () => {
      169 |             delete global.window.location;
    > 170 |             global.window.location = {
          |                                    ^
      171 |                 hostname: 'localhost',
      172 |                 search: '?development=true'
      173 |             };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:170:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:183:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      181 |         test('should detect test hostname', () => {
      182 |             delete global.window.location;
    > 183 |             global.window.location = {
          |                                    ^
      184 |                 hostname: 'test.example.com',
      185 |                 search: ''
      186 |             };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:183:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:196:36)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1007:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:947:3)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      194 |         test('should detect dev hostname', () => {
      195 |             delete global.window.location;
    > 196 |             global.window.location = {
          |                                    ^
      197 |                 hostname: 'dev.example.com',
      198 |                 search: ''
      199 |             };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:196:36)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

    console.error
      Error: Not implemented: navigation (except hash changes)
          at module.exports (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/not-implemented.js:9:17)
          at navigateFetch (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
          at exports.navigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
          at LocationImpl._locationObjectNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
          at LocationImpl._locationObjectSetterNavigate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
          at LocationImpl.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
          at Location.set href [as href] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
          at Window.set location [as location] (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
          at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/__tests__/InitializationUtilities.test.js:22:28)
          at Promise.finally.completed (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1557:28)
          at new Promise (<anonymous>)
          at callAsyncCircusFn (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1497:10)
          at _callCircusHook (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:976:40)
          at processTicksAndRejections (node:internal/process/task_queues:103:5)
          at _runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:941:5)
          at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:849:7
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:862:11)
          at _runTestsForDescribeBlock (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:857:11)
          at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:761:3)
          at runAndTransformResultsToJestFormat (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/jestAdapterInit.js:1918:21)
          at jestAdapter (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-circus/build/runner.js:101:19)
          at runTestInternal (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:275:16)
          at runTest (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:343:7)
          at Object.worker (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/jest-runner/build/testWorker.js:497:12) {
        type: 'not implemented'
      }

      20 |     // Set up browser-like environment
      21 |     global.window = global.window || {};
    > 22 |     global.window.location = {
         |                            ^
      23 |         hostname: 'localhost',
      24 |         search: ''
      25 |     };

      at VirtualConsole.<anonymous> (node_modules/@jest/environment-jsdom-abstract/build/index.js:87:23)
      at module.exports (node_modules/jsdom/lib/jsdom/browser/not-implemented.js:12:26)
      at navigateFetch (node_modules/jsdom/lib/jsdom/living/window/navigation.js:77:3)
      at exports.navigate (node_modules/jsdom/lib/jsdom/living/window/navigation.js:55:3)
      at LocationImpl._locationObjectNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:30:5)
      at LocationImpl._locationObjectSetterNavigate (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:24:17)
      at LocationImpl.set href [as href] (node_modules/jsdom/lib/jsdom/living/window/Location-impl.js:46:10)
      at Location.set href [as href] (node_modules/jsdom/lib/jsdom/living/generated/Location.js:125:37)
          at Reflect.set (<anonymous>)
      at Window.set location [as location] (node_modules/jsdom/lib/jsdom/browser/Window.js:424:15)
      at Object.<anonymous> (__tests__/InitializationUtilities.test.js:22:28)

FAIL __tests__/project_navigation.test.js
  ● Project Navigation Integration Tests › Project Integration with Submodules › should have .gitmodules configuration for all projects

    expect(received).toContain(expected) // indexOf

    Expected substring: "guia_turistico"
    Received string:    "[submodule \"src/submodules/music_in_numbers\"]
    	path = src/submodules/music_in_numbers
    	url = git@github.com:mpbarbosa/music_in_numbers.git
    "

      223 |       // Should include all three submodules
      224 |       expect(gitmodulesContent).toContain('music_in_numbers');
    > 225 |       expect(gitmodulesContent).toContain('guia_turistico');
          |                                 ^
      226 |       expect(gitmodulesContent).toContain('monitora_vagas');
      227 |     });
      228 |

      at Object.<anonymous> (__tests__/project_navigation.test.js:225:33)

  ● Project Navigation Integration Tests › Project Integration with Submodules › should have consistent submodule directory structure

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      241 |         
      242 |         // Directory should exist (may be empty if not initialized)
    > 243 |         expect(fs.existsSync(submodulePath)).toBe(true);
          |                                              ^
      244 |         
      245 |         if (fs.existsSync(submodulePath) && fs.statSync(submodulePath).isDirectory()) {
      246 |           // If submodule is initialized, should have src directory

      at __tests__/project_navigation.test.js:243:46
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (__tests__/project_navigation.test.js:239:26)

(node:503128) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL __tests__/shell_scripts.test.js
  ● Shell Scripts Functionality › Sync to Public Script Comprehensive Tests › Main Execution Flow › should call all copy functions in logical order

    expect(received).toBeLessThan(expected)

    Expected: < -1
    Received:   -1

      383 |           const validatePos = mainContent.indexOf('validate_environment');
      384 |           const firstCopyPos = mainContent.indexOf('copy_index_html');
    > 385 |           expect(validatePos).toBeLessThan(firstCopyPos);
          |                               ^
      386 |           
      387 |           // Check that summary comes last
      388 |           const summaryPos = mainContent.indexOf('show_summary');

      at Object.<anonymous> (__tests__/shell_scripts.test.js:385:31)

PASS __tests__/sync_to_public.test.js
FAIL submodules/music_in_numbers/tests/advanced-error-handling.jest.test.js
  ● Advanced Error Handling › Data Integrity & Validation › should test PKCE generation reliability

    expect(received).toBeTruthy()

    Received: null

      645 |                 
      646 |                 const challenge = await generateCodeChallengeSafe(verifier);
    > 647 |                 expect(challenge).toBeTruthy();
          |                                   ^
      648 |                 challenges.push(challenge);
      649 |             }
      650 |             

      at Object.<anonymous> (submodules/music_in_numbers/tests/advanced-error-handling.jest.test.js:647:35)

  ● Advanced Error Handling › Browser Compatibility & Edge Cases › should detect Web Crypto API availability

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      665 |             const hasSubtle = !!(window.crypto && window.crypto.subtle && window.crypto.subtle.digest);
      666 |             
    > 667 |             expect(hasCrypto).toBe(true); // Should be available in Jest jsdom
          |                               ^
      668 |             expect(hasSubtle).toBe(true); // Should be available in Jest jsdom
      669 |         });
      670 |         

      at Object.<anonymous> (submodules/music_in_numbers/tests/advanced-error-handling.jest.test.js:667:31)

A worker process has failed to exit gracefully and has been force exited. This is likely caused by tests leaking due to improper teardown. Try running with --detectOpenHandles to find leaks. Active timers can also cause this, ensure that .unref() was called on them.
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api/ArtistApiCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api/ArtistApiProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api/ArtistApiUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api/ArtistApiUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-api/ArtistApiValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics/AnalyticsCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics/AnalyticsProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics/AnalyticsUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics/AnalyticsUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics/AnalyticsValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page/ArtistPageCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page/ArtistPageProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page/ArtistPageValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page/ArtistPageUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-page/ArtistPageUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui/ArtistUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui/ArtistUICore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui/ArtistUIUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui/ArtistUIProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/DataExportProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui/ArtistUIValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/DataExportUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/DataExportCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/DataExportUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/scripts/main.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/VALIDATION_TEST.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization/InitializationProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/data-export/DataExportValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization/InitializationUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization/InitializationCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization/InitializationUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance/PerformanceProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance/PerformanceUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance/PerformanceUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization/InitializationValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance/PerformanceValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance/PerformanceCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time/RealTimeProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time/RealTimeUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time/RealTimeUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time/RealTimeCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiResponseProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiRequestBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time/RealTimeValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifySessionDetector.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/sw.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/test-validators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/analytics.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager/ThemeManagerUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager/ThemeManagerValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager/ThemeManagerCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/enhanced-session-feedback.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager/ThemeManagerUIBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components/UIComponentsCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/theme-manager/ThemeManagerProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components/UIComponentsBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components/UIComponentsProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components/UIComponentsUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components/UIComponentsValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils/UtilsCore.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils/UtilsProcessors.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils/UtilsBuilders.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils/UtilsUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/utils/UtilsValidators.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/artist-ui.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/scripts/initialization/InitializationUtilities.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/initialization.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/real-time.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/performance.js
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/scripts/main.mjs
ERROR: The "original" argument must be of type function. Received an instance of Object
STACK: TypeError [ERR_INVALID_ARG_TYPE]: The "original" argument must be of type function. Received an instance of Object
    at promisify (node:internal/util:464:3)
    at Object.<anonymous> (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/test-exclude/index.js:5:14)
    at Module._compile (node:internal/modules/cjs/loader:1760:14)
    at Object..js (node:internal/modules/cjs/loader:1892:10)
    at Module.load (node:internal/modules/cjs/loader:1480:32)
    at Module._load (node:internal/modules/cjs/loader:1299:12)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1503:12)
    at require (node:internal/modules/helpers:152:16)
----------|---------|----------|---------|---------|-------------------
File      | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s 
----------|---------|----------|---------|---------|-------------------
All files |       0 |        0 |       0 |       0 |                   
----------|---------|----------|---------|---------|-------------------
Test Suites: 10 failed, 8 passed, 18 total
Tests:       16 failed, 436 passed, 452 total
Snapshots:   0 total
Time:        3.886 s
Ran all test suites.
```

---

**Generated by:** Tests & Documentation Workflow Automation v2.0.0
