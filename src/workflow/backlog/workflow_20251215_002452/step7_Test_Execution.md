# Step 7: Test_Execution

**Workflow Run ID:** workflow_20251215_002452
**Timestamp:** 2025-12-15 00:41:37
**Status:** Issues Found

---

## Issues and Findings

### Test Execution Results

**Total Tests:** 3
**Passed:** 8
**Failed:** 5
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

(node:364423) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
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

(node:364392) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:364424) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:364406) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js
  ● Core Modules Integration › should import GeoPosition from core module

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      17 | describe('Core Modules Integration', () => {
      18 |     test('should import GeoPosition from core module', async () => {
    > 19 |         const { GeoPosition } = await import('../src/core/GeoPosition.js');
         |                                 ^
      20 |         expect(GeoPosition).toBeDefined();
      21 |         expect(typeof GeoPosition).toBe('function');
      22 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:19:33)

  ● Core Modules Integration › should import ObserverSubject from core module

    Cannot find module '../src/core/ObserverSubject.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      23 |
      24 |     test('should import ObserverSubject from core module', async () => {
    > 25 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
         |                                              ^
      26 |         expect(ObserverSubject).toBeDefined();
      27 |         expect(typeof ObserverSubject).toBe('function');
      28 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:25:46)

  ● Core Modules Integration › should import PositionManager from core module

    Cannot find module '../src/core/PositionManager.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      29 |
      30 |     test('should import PositionManager from core module', async () => {
    > 31 |         const { default: PositionManager } = await import('../src/core/PositionManager.js');
         |                                              ^
      32 |         expect(PositionManager).toBeDefined();
      33 |         expect(typeof PositionManager).toBe('function');
      34 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:31:46)

  ● Core Modules Integration › should create immutable GeoPosition

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      35 |
      36 |     test('should create immutable GeoPosition', async () => {
    > 37 |         const { default: GeoPosition } = await import('../src/core/GeoPosition.js');
         |                                          ^
      38 |
      39 |         const mockPosition = {
      40 |             coords: {

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:37:42)

  ● Core Modules Integration › should create and use ObserverSubject

    Cannot find module '../src/core/ObserverSubject.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      62 |
      63 |     test('should create and use ObserverSubject', async () => {
    > 64 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
         |                                              ^
      65 |
      66 |         const subject = new ObserverSubject();
      67 |         let notified = false;

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:64:46)

  ● Core Modules Integration › should create PositionManager singleton

    Cannot find module '../src/core/PositionManager.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      82 |
      83 |     test('should create PositionManager singleton', async () => {
    > 84 |         const { default: PositionManager } = await import('../src/core/PositionManager.js');
         |                                              ^
      85 |
      86 |         const manager1 = PositionManager.getInstance();
      87 |         const manager2 = PositionManager.getInstance();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:84:46)

  ● Core Modules Integration › should export classes from guia.js

    Cannot find module '../src/guia.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      93 |
      94 |     test('should export classes from guia.js', async () => {
    > 95 |         const guia = await import('../src/guia.js');
         |                      ^
      96 |
      97 |         expect(guia.GeoPosition).toBeDefined();
      98 |         expect(guia.ObserverSubject).toBeDefined();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:95:22)

  ● Core Modules Integration › core classes should work together

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      101 |
      102 |     test('core classes should work together', async () => {
    > 103 |         const { default: GeoPosition } = await import('../src/core/GeoPosition.js');
          |                                          ^
      104 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
      105 |
      106 |         const subject = new ObserverSubject();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:103:42)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js
  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechMunicipio when MunicipioChanged event occurs

    TypeError: Cannot add property buildTextToSpeechMunicipio, object is not extensible

      257 |
      258 |             // Spy on the buildTextToSpeechMunicipio method
    > 259 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechMunicipio');
          |                                   ^
      260 |
      261 |             const currentAddress = new BrazilianStandardAddress();
      262 |             currentAddress.municipio = 'Campinas';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:259:35)

  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechBairro when BairroChanged event occurs

    TypeError: Cannot add property buildTextToSpeechBairro, object is not extensible

      283 |             }
      284 |
    > 285 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechBairro');
          |                                   ^
      286 |
      287 |             const currentAddress = new BrazilianStandardAddress();
      288 |             currentAddress.bairro = 'Jardins';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:285:35)

  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechLogradouro when LogradouroChanged event occurs

    TypeError: Cannot add property buildTextToSpeechLogradouro, object is not extensible

      299 |             }
      300 |
    > 301 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechLogradouro');
          |                                   ^
      302 |
      303 |             const currentAddress = new BrazilianStandardAddress();
      304 |             currentAddress.logradouro = 'Avenida Paulista';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:301:35)

(node:364394) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/AddressDataExtractor.test.js
  ● AddressDataExtractor - MP Barbosa Travel Guide (v0.4.1-alpha) › Extractor Initialization › should initialize with default Brazilian settings

    expect(received).toBe(expected) // Object.is equality

    Expected: "Brasil"
    Received: undefined

      91 |             const extractor = new AddressDataExtractor();
      92 |
    > 93 |             expect(extractor.defaultCountry).toBe('Brasil');
         |                                              ^
      94 |             expect(extractor.timeout).toBe(3000);
      95 |             expect(extractor.validPlaceClasses).toContain('amenity');
      96 |             expect(extractor.validPlaceClasses).toContain('building');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/AddressDataExtractor.test.js:93:46)

(node:364412) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:364400) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js
  ● PositionManager - MP Barbosa Travel Guide (v0.8.5-alpha) › Position Data Management (Brazilian Context) › should handle position updates with time and distance thresholds

    expect(received).toBe(expected) // Object.is equality

    Expected: "boolean"
    Received: "undefined"

      250 |
      251 |             // The implementation should consider both time and distance thresholds
    > 252 |             expect(typeof updated).toBe('boolean');
          |                                    ^
      253 |         });
      254 |     });
      255 |

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js:252:36)

  ● PositionManager - MP Barbosa Travel Guide (v0.8.5-alpha) › Observer Pattern Implementation › should handle invalid observer subscription gracefully

    expect(received).toBe(expected) // Object.is equality

    Expected: 0
    Received: 1

      310 |                 // Test object without update method
      311 |                 instance.subscribe({ name: 'invalid' });
    > 312 |                 expect(instance.observers.length).toBe(initialLength);
          |                                                   ^
      313 |             } else {
      314 |                 // Test defensive programming concepts
      315 |                 expect(null).toBeNull();

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js:312:51)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/GeoPosition.immutability.test.js
  ● GeoPosition - Referential Transparency Tests › Immutability - No Setters › should not have accuracy setter

    TypeError: Cannot assign to read only property 'accuracy' of object '[object Object]'

      287 |
      288 |             // Attempt to set accuracy (should not have setter)
    > 289 |             geoPosition.accuracy = 50;
          |                                  ^
      290 |
      291 |             // In a pure implementation without setters, the property assignment
      292 |             // will simply overwrite the property value directly

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/GeoPosition.immutability.test.js:289:34)

(node:364441) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
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

(node:364455) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js
  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Brazilian Location Processing › should handle Portuguese place names with accents

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      124 |
      125 |                 portuguesePlaces.forEach(place => {
    > 126 |                     expect(/[ãáçéíóú]/i.test(place)).toBe(true);
          |                                                      ^
      127 |                 });
      128 |                 return;
      129 |             }

      at submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:126:54
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:125:34)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should create ReferencePlace for shop/car_repair

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      176 |             });
      177 |
    > 178 |             expect(refPlace.typeName).toBe('car_repair');
          |                                       ^
      179 |             expect(refPlace.name).toBe('Oficina');
      180 |             // FIXED: Updated expected description to match actual format "Oficina Mecânica Oficina" -> "Oficina Mecânica Oficina"
      181 |             expect(refPlace.description).toBe('Oficina Mecânica Oficina');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:178:39)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should handle empty name in reference place

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      205 |             });
      206 |
    > 207 |             expect(refPlace.typeName).toBe('car_repair');
          |                                       ^
      208 |             expect(refPlace.name).toBeDefined();
      209 |
      210 |             // Should handle empty name gracefully

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:207:39)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should support Brazilian automotive terminology

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      246 |
      247 |             expect(brazilianCarShop.name).toContain('Brasil');
    > 248 |             expect(brazilianCarShop.typeName).toBe('car_repair');
          |                                               ^
      249 |
      250 |             if (brazilianCarShop.tags) {
      251 |                 expect(brazilianCarShop.tags['addr:country']).toBe('BR');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:248:47)

(node:364452) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
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

(node:364391) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/Chronometer.test.js
  ● Console

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

    console.log
      Initializing Chronometer...

      at new log (submodules/guia_turistico/src/libs/guia_js/src/timing/Chronometer.js:62:11)

PASS submodules/music_in_numbers/src/scripts/analytics/__tests__/AnalyticsProcessors.test.js
(node:364430) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
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

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/patterns/Immutability.test.js
  ● Console

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.159Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [2025-12-15T03:41:33.173Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 0',
            numero: null,
            complemento: null,
            bairro: 'Bairro 0',
            municipio: 'Cidade 0',
            uf: 'UF0',
            siglaUF: null,
            cep: '00000',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 1
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.191Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 1',
            numero: null,
            complemento: null,
            bairro: 'Bairro 1',
            municipio: 'Cidade 1',
            uf: 'UF1',
            siglaUF: null,
            cep: '00001',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 2
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.191Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 2',
            numero: null,
            complemento: null,
            bairro: 'Bairro 2',
            municipio: 'Cidade 2',
            uf: 'UF2',
            siglaUF: null,
            cep: '00002',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 3
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.192Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 3',
            numero: null,
            complemento: null,
            bairro: 'Bairro 3',
            municipio: 'Cidade 3',
            uf: 'UF3',
            siglaUF: null,
            cep: '00003',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 4
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.193Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 4',
            numero: null,
            complemento: null,
            bairro: 'Bairro 4',
            municipio: 'Cidade 4',
            uf: 'UF4',
            siglaUF: null,
            cep: '00004',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 5
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.193Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 5',
            numero: null,
            complemento: null,
            bairro: 'Bairro 5',
            municipio: 'Cidade 5',
            uf: 'UF5',
            siglaUF: null,
            cep: '00005',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 6
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.194Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 6',
            numero: null,
            complemento: null,
            bairro: 'Bairro 6',
            municipio: 'Cidade 6',
            uf: 'UF6',
            siglaUF: null,
            cep: '00006',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 7
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.194Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 7',
            numero: null,
            complemento: null,
            bairro: 'Bairro 7',
            municipio: 'Cidade 7',
            uf: 'UF7',
            siglaUF: null,
            cep: '00007',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 8
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.195Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 8',
            numero: null,
            complemento: null,
            bairro: 'Bairro 8',
            municipio: 'Cidade 8',
            uf: 'UF8',
            siglaUF: null,
            cep: '00008',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 9
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.196Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 9',
            numero: null,
            complemento: null,
            bairro: 'Bairro 9',
            municipio: 'Cidade 9',
            uf: 'UF9',
            siglaUF: null,
            cep: '00009',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 10
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.196Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 10',
            numero: null,
            complemento: null,
            bairro: 'Bairro 10',
            municipio: 'Cidade 10',
            uf: 'UF10',
            siglaUF: null,
            cep: '000010',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 11
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.197Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 11',
            numero: null,
            complemento: null,
            bairro: 'Bairro 11',
            municipio: 'Cidade 11',
            uf: 'UF11',
            siglaUF: null,
            cep: '000011',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 12
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.197Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 12',
            numero: null,
            complemento: null,
            bairro: 'Bairro 12',
            municipio: 'Cidade 12',
            uf: 'UF12',
            siglaUF: null,
            cep: '000012',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 13
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.198Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 13',
            numero: null,
            complemento: null,
            bairro: 'Bairro 13',
            municipio: 'Cidade 13',
            uf: 'UF13',
            siglaUF: null,
            cep: '000013',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 14
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.204Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 14',
            numero: null,
            complemento: null,
            bairro: 'Bairro 14',
            municipio: 'Cidade 14',
            uf: 'UF14',
            siglaUF: null,
            cep: '000014',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 15
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.205Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 15',
            numero: null,
            complemento: null,
            bairro: 'Bairro 15',
            municipio: 'Cidade 15',
            uf: 'UF15',
            siglaUF: null,
            cep: '000015',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 16
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.205Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 16',
            numero: null,
            complemento: null,
            bairro: 'Bairro 16',
            municipio: 'Cidade 16',
            uf: 'UF16',
            siglaUF: null,
            cep: '000016',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 17
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.206Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 17',
            numero: null,
            complemento: null,
            bairro: 'Bairro 17',
            municipio: 'Cidade 17',
            uf: 'UF17',
            siglaUF: null,
            cep: '000017',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 18
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.207Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 18',
            numero: null,
            complemento: null,
            bairro: 'Bairro 18',
            municipio: 'Cidade 18',
            uf: 'UF18',
            siglaUF: null,
            cep: '000018',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 19
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.207Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 19',
            numero: null,
            complemento: null,
            bairro: 'Bairro 19',
            municipio: 'Cidade 19',
            uf: 'UF19',
            siglaUF: null,
            cep: '000019',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 20
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.208Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 20',
            numero: null,
            complemento: null,
            bairro: 'Bairro 20',
            municipio: 'Cidade 20',
            uf: 'UF20',
            siglaUF: null,
            cep: '000020',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 21
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.208Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 21',
            numero: null,
            complemento: null,
            bairro: 'Bairro 21',
            municipio: 'Cidade 21',
            uf: 'UF21',
            siglaUF: null,
            cep: '000021',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 22
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.209Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 22',
            numero: null,
            complemento: null,
            bairro: 'Bairro 22',
            municipio: 'Cidade 22',
            uf: 'UF22',
            siglaUF: null,
            cep: '000022',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 23
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.209Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 23',
            numero: null,
            complemento: null,
            bairro: 'Bairro 23',
            municipio: 'Cidade 23',
            uf: 'UF23',
            siglaUF: null,
            cep: '000023',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 24
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.210Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 24',
            numero: null,
            complemento: null,
            bairro: 'Bairro 24',
            municipio: 'Cidade 24',
            uf: 'UF24',
            siglaUF: null,
            cep: '000024',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 25
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.210Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 25',
            numero: null,
            complemento: null,
            bairro: 'Bairro 25',
            municipio: 'Cidade 25',
            uf: 'UF25',
            siglaUF: null,
            cep: '000025',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 26
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.211Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 26',
            numero: null,
            complemento: null,
            bairro: 'Bairro 26',
            municipio: 'Cidade 26',
            uf: 'UF26',
            siglaUF: null,
            cep: '000026',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 27
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.211Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 27',
            numero: null,
            complemento: null,
            bairro: 'Bairro 27',
            municipio: 'Cidade 27',
            uf: 'UF27',
            siglaUF: null,
            cep: '000027',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 28
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.211Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 28',
            numero: null,
            complemento: null,
            bairro: 'Bairro 28',
            municipio: 'Cidade 28',
            uf: 'UF28',
            siglaUF: null,
            cep: '000028',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 29
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.212Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 29',
            numero: null,
            complemento: null,
            bairro: 'Bairro 29',
            municipio: 'Cidade 29',
            uf: 'UF29',
            siglaUF: null,
            cep: '000029',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 30
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.212Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 30',
            numero: null,
            complemento: null,
            bairro: 'Bairro 30',
            municipio: 'Cidade 30',
            uf: 'UF30',
            siglaUF: null,
            cep: '000030',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 31
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.212Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 31',
            numero: null,
            complemento: null,
            bairro: 'Bairro 31',
            municipio: 'Cidade 31',
            uf: 'UF31',
            siglaUF: null,
            cep: '000031',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 32
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.213Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 32',
            numero: null,
            complemento: null,
            bairro: 'Bairro 32',
            municipio: 'Cidade 32',
            uf: 'UF32',
            siglaUF: null,
            cep: '000032',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 33
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.213Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 33',
            numero: null,
            complemento: null,
            bairro: 'Bairro 33',
            municipio: 'Cidade 33',
            uf: 'UF33',
            siglaUF: null,
            cep: '000033',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 34
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.214Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 34',
            numero: null,
            complemento: null,
            bairro: 'Bairro 34',
            municipio: 'Cidade 34',
            uf: 'UF34',
            siglaUF: null,
            cep: '000034',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 35
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.214Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 35',
            numero: null,
            complemento: null,
            bairro: 'Bairro 35',
            municipio: 'Cidade 35',
            uf: 'UF35',
            siglaUF: null,
            cep: '000035',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 36
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.214Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 36',
            numero: null,
            complemento: null,
            bairro: 'Bairro 36',
            municipio: 'Cidade 36',
            uf: 'UF36',
            siglaUF: null,
            cep: '000036',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 37
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.215Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 37',
            numero: null,
            complemento: null,
            bairro: 'Bairro 37',
            municipio: 'Cidade 37',
            uf: 'UF37',
            siglaUF: null,
            cep: '000037',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 38
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.215Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 38',
            numero: null,
            complemento: null,
            bairro: 'Bairro 38',
            municipio: 'Cidade 38',
            uf: 'UF38',
            siglaUF: null,
            cep: '000038',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 39
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.215Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 39',
            numero: null,
            complemento: null,
            bairro: 'Bairro 39',
            municipio: 'Cidade 39',
            uf: 'UF39',
            siglaUF: null,
            cep: '000039',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 40
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.216Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 40',
            numero: null,
            complemento: null,
            bairro: 'Bairro 40',
            municipio: 'Cidade 40',
            uf: 'UF40',
            siglaUF: null,
            cep: '000040',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 41
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.216Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 41',
            numero: null,
            complemento: null,
            bairro: 'Bairro 41',
            municipio: 'Cidade 41',
            uf: 'UF41',
            siglaUF: null,
            cep: '000041',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 42
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.217Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 42',
            numero: null,
            complemento: null,
            bairro: 'Bairro 42',
            municipio: 'Cidade 42',
            uf: 'UF42',
            siglaUF: null,
            cep: '000042',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 43
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.217Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 43',
            numero: null,
            complemento: null,
            bairro: 'Bairro 43',
            municipio: 'Cidade 43',
            uf: 'UF43',
            siglaUF: null,
            cep: '000043',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 44
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.217Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 44',
            numero: null,
            complemento: null,
            bairro: 'Bairro 44',
            municipio: 'Cidade 44',
            uf: 'UF44',
            siglaUF: null,
            cep: '000044',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 45
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.218Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 45',
            numero: null,
            complemento: null,
            bairro: 'Bairro 45',
            municipio: 'Cidade 45',
            uf: 'UF45',
            siglaUF: null,
            cep: '000045',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 46
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.218Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 46',
            numero: null,
            complemento: null,
            bairro: 'Bairro 46',
            municipio: 'Cidade 46',
            uf: 'UF46',
            siglaUF: null,
            cep: '000046',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 47
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.219Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 47',
            numero: null,
            complemento: null,
            bairro: 'Bairro 47',
            municipio: 'Cidade 47',
            uf: 'UF47',
            siglaUF: null,
            cep: '000047',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 48
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.220Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 48',
            numero: null,
            complemento: null,
            bairro: 'Bairro 48',
            municipio: 'Cidade 48',
            uf: 'UF48',
            siglaUF: null,
            cep: '000048',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 49
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.220Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 49',
            numero: null,
            complemento: null,
            bairro: 'Bairro 49',
            municipio: 'Cidade 49',
            uf: 'UF49',
            siglaUF: null,
            cep: '000049',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 50
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.221Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 50',
            numero: null,
            complemento: null,
            bairro: 'Bairro 50',
            municipio: 'Cidade 50',
            uf: 'UF50',
            siglaUF: null,
            cep: '000050',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 38
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.221Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 51',
            numero: null,
            complemento: null,
            bairro: 'Bairro 51',
            municipio: 'Cidade 51',
            uf: 'UF51',
            siglaUF: null,
            cep: '000051',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 39
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.222Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 52',
            numero: null,
            complemento: null,
            bairro: 'Bairro 52',
            municipio: 'Cidade 52',
            uf: 'UF52',
            siglaUF: null,
            cep: '000052',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 40
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.222Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 53',
            numero: null,
            complemento: null,
            bairro: 'Bairro 53',
            municipio: 'Cidade 53',
            uf: 'UF53',
            siglaUF: null,
            cep: '000053',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 41
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.223Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 54',
            numero: null,
            complemento: null,
            bairro: 'Bairro 54',
            municipio: 'Cidade 54',
            uf: 'UF54',
            siglaUF: null,
            cep: '000054',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 42
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.224Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 55',
            numero: null,
            complemento: null,
            bairro: 'Bairro 55',
            municipio: 'Cidade 55',
            uf: 'UF55',
            siglaUF: null,
            cep: '000055',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 43
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.224Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 56',
            numero: null,
            complemento: null,
            bairro: 'Bairro 56',
            municipio: 'Cidade 56',
            uf: 'UF56',
            siglaUF: null,
            cep: '000056',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 44
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.225Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 57',
            numero: null,
            complemento: null,
            bairro: 'Bairro 57',
            municipio: 'Cidade 57',
            uf: 'UF57',
            siglaUF: null,
            cep: '000057',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 45
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.225Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 58',
            numero: null,
            complemento: null,
            bairro: 'Bairro 58',
            municipio: 'Cidade 58',
            uf: 'UF58',
            siglaUF: null,
            cep: '000058',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 46
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.226Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua 59',
            numero: null,
            complemento: null,
            bairro: 'Bairro 59',
            municipio: 'Cidade 59',
            uf: 'UF59',
            siglaUF: null,
            cep: '000059',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 47
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.228Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua Teste 1',
            numero: null,
            complemento: null,
            bairro: 'Bairro 1',
            municipio: 'Cidade 1',
            uf: 'SP',
            siglaUF: 'SP',
            cep: '00000-001',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 1
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.228Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua Teste 2',
            numero: null,
            complemento: null,
            bairro: 'Bairro 2',
            municipio: 'Cidade 2',
            uf: 'RJ',
            siglaUF: 'RJ',
            cep: '00000-002',
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 2
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

PASS submodules/music_in_numbers/tests/security-testing.jest.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/integration/data-modules.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/GeoPosition.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/ui/BairroDisplay.test.js
PASS submodules/music_in_numbers/src/scripts/analytics/__tests__/AnalyticsCore.test.js
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

PASS __tests__/main.test.js
(node:364393) ExperimentalWarning: VM Modules is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
FAIL __tests__/project_navigation.test.js
  ● Project Navigation Integration Tests › Project Integration with Submodules › should have .gitmodules configuration for all projects

    expect(received).toContain(expected) // indexOf

    Expected substring: "monitora_vagas"
    Received string:    "[submodule \"src/submodules/music_in_numbers\"]
    	path = src/submodules/music_in_numbers
    	url = git@github.com:mpbarbosa/music_in_numbers.git
    [submodule \"src/submodules/guia_turistico\"]
    	path = src/submodules/guia_turistico
    	url = git@github.com:mpbarbosa/guia_turistico.git
    "

      224 |       expect(gitmodulesContent).toContain('music_in_numbers');
      225 |       expect(gitmodulesContent).toContain('guia_turistico');
    > 226 |       expect(gitmodulesContent).toContain('monitora_vagas');
          |                                 ^
      227 |     });
      228 |
      229 |     test('should have consistent submodule directory structure', () => {

      at Object.<anonymous> (__tests__/project_navigation.test.js:226:33)

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

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/e2e/CompleteGeolocationWorkflow.e2e.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/features/FullAddressSpeechInterval.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/ImmediateAddressFlow.test.js
PASS submodules/music_in_numbers/tests/artist-functions.jest.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/services/GeolocationService.helpers.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/external/guia_ibge.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioSpeechPriority.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/e2e/ErrorHandlingRecovery.e2e.test.js
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

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/e2e/MultiComponentIntegration.e2e.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/integration/service-modules.test.js
  ● Console

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.773Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [2025-12-15T03:41:33.776Z] +++ (100) (ObserverSubject) Notifying observers with args: []

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.780Z] +++ (101) (ObserverSubject) Notifying observer: { update: [Function: update] }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/features/SpeechPriority.test.js
  ● Console

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.784Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [2025-12-15T03:41:33.796Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Rua das Flores',
            numero: '123',
            complemento: null,
            bairro: 'Centro',
            municipio: 'São Paulo',
            uf: 'SP',
            siglaUF: 'SP',
            cep: null,
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 1
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.809Z] +++ (100) (ObserverSubject) Notifying observers with args: [
        {
          type: 'addressUpdated',
          address: BrazilianStandardAddress {
            logradouro: 'Avenida Copacabana',
            numero: '456',
            complemento: null,
            bairro: 'Copacabana',
            municipio: 'Rio de Janeiro',
            uf: 'RJ',
            siglaUF: 'RJ',
            cep: null,
            pais: 'Brasil',
            referencePlace: [ReferencePlace]
          },
          cacheSize: 2
        }
      ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/services/GeolocationService.raceCondition.test.js
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechSynthesisManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechQueue.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/CurrentPosition.test.js
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechItem.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/services/GeolocationService.injection.test.js
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SingletonStatusManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HtmlText.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/ReferencePlace.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLPositionDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLReferencePlaceDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HtmlSpeechSynthesisDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/DisplayerFactory.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/utils/utils.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/e2e/AddressChangeAndSpeech.e2e.test.js
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLAddressDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/managers/WebGeocodingManagerMunicipio.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/managers/WebGeocodingManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/ui/DisplayerFactory.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SingletonStatusManager.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechItem.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechQueue.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechSynthesisManager.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HTMLReferencePlaceDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HTMLAddressDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HtmlSpeechSynthesisDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/utils/DeviceDetection.test.js
  ● Console

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.043Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.088Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.130Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.181Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.221Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.272Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.316Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.362Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.410Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.453Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.495Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.535Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [2025-12-15T03:41:33.578Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.616Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.658Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.700Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.745Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [2025-12-15T03:41:33.800Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [Device Detection] Type: Mobile/Tablet

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: medium, bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.842Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.885Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.warn
      (guia.js) Failed to load ibira.js: Cannot find module 'https://cdn.jsdelivr.net/gh/mpbarbosa/ibira.js/src/ibira.js' from 'submodules/guia_turistico/src/libs/guia_js/src/guia.js'

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeDetection.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/LocationChangeImmediateSpeech.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/SpeechSynthesisManager.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/integration/GeoPositionPositionManager.integration.test.js
FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/ChangeDetectionCoordinator.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/DisplayerFactory.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/AddressDataExtractor-module.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/external/OSMAddressTranslation.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/tests/WebGeocodingManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/sidra/sidra.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/spotify-auth-di.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/security-testing.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/performance-benchmarking.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/BairroChangeDetection.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/ReverseGeocoder.test.js
  ● Console

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.976Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

PASS submodules/guia_turistico/src/libs/guia_js/__tests__/e2e/BrazilianAddressProcessing.e2e.test.js
PASS submodules/guia_turistico/src/libs/guia_js/__tests__/unit/ObserverSubject.test.js
  ● Console

    console.warn
      (guia.js) Failed to load ibira.js: Node.js environment detected - using fallback

      68 |
      69 | const warn = (message, ...params) => {
    > 70 | 	console.warn(message, ...params);
         | 	        ^
      71 | 	if (typeof document !== "undefined") {
      72 | 		const logContainer = document.getElementById("bottom-scroll-textarea");
      73 | 		if (logContainer) {

      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:70:10)
      at warn (submodules/guia_turistico/src/libs/guia_js/src/guia.js:101:9)
      at submodules/guia_turistico/src/libs/guia_js/src/guia.js:115:2

    console.log
      [Device Detection] Type: Desktop/Laptop

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:151:10)

    console.log
      [Device Detection] Rejecting accuracy levels: bad, very bad

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:152:10)

    console.log
      [2025-12-15T03:41:33.982Z] Guia.js version: 0.8.7-alpha

      at log (submodules/guia_turistico/src/libs/guia_js/src/guia.js:59:10)

    console.log
      [2025-12-15T03:41:33.992Z] +++ (100) (ObserverSubject) Notifying observers with args: [ 'arg1', 'arg2', 'arg3' ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.995Z] +++ (101) (ObserverSubject) Notifying observer: {
        update: [Function: mockConstructor] {
          _isMockFunction: true,
          getMockImplementation: [Function (anonymous)],
          mock: [Getter/Setter],
          mockClear: [Function (anonymous)],
          mockReset: [Function (anonymous)],
          mockRestore: [Function (anonymous)],
          mockReturnValueOnce: [Function (anonymous)],
          mockResolvedValueOnce: [Function (anonymous)],
          mockRejectedValueOnce: [Function (anonymous)],
          mockReturnValue: [Function (anonymous)],
          mockResolvedValue: [Function (anonymous)],
          mockRejectedValue: [Function (anonymous)],
          mockImplementationOnce: [Function (anonymous)],
          withImplementation: [Function: bound withImplementation],
          mockImplementation: [Function (anonymous)],
          mockReturnThis: [Function (anonymous)],
          mockName: [Function (anonymous)],
          getMockName: [Function (anonymous)],
          Symbol(Symbol.dispose): [Function (anonymous)]
        }
      }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

    console.log
      [2025-12-15T03:41:33.996Z] +++ (101) (ObserverSubject) Notifying observer: {
        update: [Function: mockConstructor] {
          _isMockFunction: true,
          getMockImplementation: [Function (anonymous)],
          mock: [Getter/Setter],
          mockClear: [Function (anonymous)],
          mockReset: [Function (anonymous)],
          mockRestore: [Function (anonymous)],
          mockReturnValueOnce: [Function (anonymous)],
          mockResolvedValueOnce: [Function (anonymous)],
          mockRejectedValueOnce: [Function (anonymous)],
          mockReturnValue: [Function (anonymous)],
          mockResolvedValue: [Function (anonymous)],
          mockRejectedValue: [Function (anonymous)],
          mockImplementationOnce: [Function (anonymous)],
          withImplementation: [Function: bound withImplementation],
          mockImplementation: [Function (anonymous)],
          mockReturnThis: [Function (anonymous)],
          mockName: [Function (anonymous)],
          getMockName: [Function (anonymous)],
          Symbol(Symbol.dispose): [Function (anonymous)]
        }
      }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

    console.log
      [2025-12-15T03:41:33.997Z] +++ (100) (ObserverSubject) Notifying observers with args: []

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:33.998Z] +++ (101) (ObserverSubject) Notifying observer: {
        update: [Function: mockConstructor] {
          _isMockFunction: true,
          getMockImplementation: [Function (anonymous)],
          mock: [Getter/Setter],
          mockClear: [Function (anonymous)],
          mockReset: [Function (anonymous)],
          mockRestore: [Function (anonymous)],
          mockReturnValueOnce: [Function (anonymous)],
          mockResolvedValueOnce: [Function (anonymous)],
          mockRejectedValueOnce: [Function (anonymous)],
          mockReturnValue: [Function (anonymous)],
          mockResolvedValue: [Function (anonymous)],
          mockRejectedValue: [Function (anonymous)],
          mockImplementationOnce: [Function (anonymous)],
          withImplementation: [Function: bound withImplementation],
          mockImplementation: [Function (anonymous)],
          mockReturnThis: [Function (anonymous)],
          mockName: [Function (anonymous)],
          getMockName: [Function (anonymous)],
          Symbol(Symbol.dispose): [Function (anonymous)]
        }
      }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

    console.log
      [2025-12-15T03:41:33.999Z] +++ (100) (ObserverSubject) Notifying observers with args: [ 'data' ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:34.000Z] +++ (100) (ObserverSubject) Notifying observers with args: [ 'data' ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:34.001Z] +++ (101) (ObserverSubject) Notifying observer: {
        update: [Function: mockConstructor] {
          _isMockFunction: true,
          getMockImplementation: [Function (anonymous)],
          mock: [Getter/Setter],
          mockClear: [Function (anonymous)],
          mockReset: [Function (anonymous)],
          mockRestore: [Function (anonymous)],
          mockReturnValueOnce: [Function (anonymous)],
          mockResolvedValueOnce: [Function (anonymous)],
          mockRejectedValueOnce: [Function (anonymous)],
          mockReturnValue: [Function (anonymous)],
          mockResolvedValue: [Function (anonymous)],
          mockRejectedValue: [Function (anonymous)],
          mockImplementationOnce: [Function (anonymous)],
          withImplementation: [Function: bound withImplementation],
          mockImplementation: [Function (anonymous)],
          mockReturnThis: [Function (anonymous)],
          mockName: [Function (anonymous)],
          getMockName: [Function (anonymous)],
          Symbol(Symbol.dispose): [Function (anonymous)]
        }
      }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

    console.log
      [2025-12-15T03:41:34.003Z] +++ (100) (ObserverSubject) Notifying observers with args: [ 'object-data' ]

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)

    console.log
      [2025-12-15T03:41:34.003Z] +++ (101) (ObserverSubject) Notifying observer: {
        update: [Function: mockConstructor] {
          _isMockFunction: true,
          getMockImplementation: [Function (anonymous)],
          mock: [Getter/Setter],
          mockClear: [Function (anonymous)],
          mockReset: [Function (anonymous)],
          mockRestore: [Function (anonymous)],
          mockReturnValueOnce: [Function (anonymous)],
          mockResolvedValueOnce: [Function (anonymous)],
          mockRejectedValueOnce: [Function (anonymous)],
          mockReturnValue: [Function (anonymous)],
          mockResolvedValue: [Function (anonymous)],
          mockRejectedValue: [Function (anonymous)],
          mockImplementationOnce: [Function (anonymous)],
          withImplementation: [Function: bound withImplementation],
          mockImplementation: [Function (anonymous)],
          mockReturnThis: [Function (anonymous)],
          mockName: [Function (anonymous)],
          getMockName: [Function (anonymous)],
          Symbol(Symbol.dispose): [Function (anonymous)]
        }
      }

      at log (submodules/guia_turistico/src/libs/guia_js/src/utils/logger.js:38:10)
          at Array.forEach (<anonymous>)

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
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components.js
ERROR: /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components.js: Identifier 'enableVirtualScrolling' has already been declared. (552:9)

  550 |
  551 | // Virtual scrolling implementation for track lists
> 552 | function enableVirtualScrolling(container, items, renderFunction) {
      |          ^
  553 |     if (!container || !items.length) return;
  554 |
  555 |     const virtualScroller = new VirtualScroller(container, 70, 3);
STACK: SyntaxError: /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/ui-components.js: Identifier 'enableVirtualScrolling' has already been declared. (552:9)

  550 |
  551 | // Virtual scrolling implementation for track lists
> 552 | function enableVirtualScrolling(container, items, renderFunction) {
      |          ^
  553 |     if (!container || !items.length) return;
  554 |
  555 |     const virtualScroller = new VirtualScroller(container, 70, 3);
    at constructor (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:367:19)
    at Parser.raise (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:6624:19)
    at ScopeHandler.checkRedeclarationInScope (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:1646:19)
    at ScopeHandler.declareName (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:1612:12)
    at Parser.registerFunctionStatementId (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13542:16)
    at Parser.parseFunction (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13526:12)
    at Parser.parseFunctionStatement (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13201:17)
    at Parser.parseStatementContent (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12867:21)
    at Parser.parseStatementLike (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12843:17)
    at Parser.parseModuleItem (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12820:17)
    at Parser.parseBlockOrModuleBlockBody (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13392:36)
    at Parser.parseBlockBody (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13385:10)
    at Parser.parseProgram (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12698:10)
    at Parser.parseTopLevel (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12688:25)
    at Parser.parse (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:14568:25)
    at parse (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:14602:38)
    at parser (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/parser/index.js:41:34)
    at parser.next (<anonymous>)
    at normalizeFile (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transformation/normalize-file.js:64:37)
    at normalizeFile.next (<anonymous>)
    at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transformation/index.js:22:50)
    at run.next (<anonymous>)
    at transform (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transform.js:22:33)
    at transform.next (<anonymous>)
    at evaluateSync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/gensync/index.js:251:28)
    at sync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/gensync/index.js:89:14)
    at stopHiding - secret - don't use this - v1 (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/errors/rewrite-stack-trace.js:47:12)
    at transformSync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transform.js:42:76)
    at ScriptTransformer._instrumentFile (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:301:46)
    at ScriptTransformer._buildTransformResult (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:376:33)
    at ScriptTransformer.transformSourceAsync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:471:17)
    at process.processTicksAndRejections (node:internal/process/task_queues:103:5)
    at async generateEmptyCoverage (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/reporters/build/CoverageWorker.js:92:9)
Failed to collect coverage from /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiCore.js
ERROR: /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiCore.js: Unexpected reserved word 'static'. (320:4)

  318 |      * @param {Function} dependencies.getRedirectUri - Function to get redirect URI
  319 |      */
> 320 |     static async exchangeCodeForTokenCore(dependencies) {
      |     ^
  321 |         const {
  322 |             getElement,
  323 |             getStorageItem,
STACK: SyntaxError: /home/mpb/Documents/GitHub/mpbarbosa_site/src/submodules/music_in_numbers/src/scripts/spotify-api/SpotifyApiCore.js: Unexpected reserved word 'static'. (320:4)

  318 |      * @param {Function} dependencies.getRedirectUri - Function to get redirect URI
  319 |      */
> 320 |     static async exchangeCodeForTokenCore(dependencies) {
      |     ^
  321 |         const {
  322 |             getElement,
  323 |             getStorageItem,
    at constructor (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:367:19)
    at Parser.raise (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:6624:19)
    at Parser.checkReservedWord (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12305:12)
    at Parser.parseIdentifierName (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12285:12)
    at Parser.parseIdentifier (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12255:23)
    at Parser.parseExprAtom (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:11482:27)
    at Parser.parseExprSubscripts (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:11145:23)
    at Parser.parseUpdate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:11130:21)
    at Parser.parseMaybeUnary (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:11110:23)
    at Parser.parseMaybeUnaryOrPrivate (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10963:61)
    at Parser.parseExprOps (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10968:23)
    at Parser.parseMaybeConditional (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10945:23)
    at Parser.parseMaybeAssign (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10895:21)
    at Parser.parseExpressionBase (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10848:23)
    at /home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10844:39
    at Parser.allowInAnd (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12495:16)
    at Parser.parseExpression (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:10844:17)
    at Parser.parseStatementContent (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12971:23)
    at Parser.parseStatementLike (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12843:17)
    at Parser.parseModuleItem (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12820:17)
    at Parser.parseBlockOrModuleBlockBody (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13392:36)
    at Parser.parseBlockBody (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:13385:10)
    at Parser.parseProgram (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12698:10)
    at Parser.parseTopLevel (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:12688:25)
    at Parser.parse (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:14568:25)
    at parse (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/parser/lib/index.js:14602:38)
    at parser (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/parser/index.js:41:34)
    at parser.next (<anonymous>)
    at normalizeFile (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transformation/normalize-file.js:64:37)
    at normalizeFile.next (<anonymous>)
    at run (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transformation/index.js:22:50)
    at run.next (<anonymous>)
    at transform (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transform.js:22:33)
    at transform.next (<anonymous>)
    at evaluateSync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/gensync/index.js:251:28)
    at sync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/gensync/index.js:89:14)
    at stopHiding - secret - don't use this - v1 (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/errors/rewrite-stack-trace.js:47:12)
    at transformSync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@babel/core/lib/transform.js:42:76)
    at ScriptTransformer._instrumentFile (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:301:46)
    at ScriptTransformer._buildTransformResult (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:376:33)
    at ScriptTransformer.transformSourceAsync (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/transform/build/index.js:471:17)
    at process.processTicksAndRejections (node:internal/process/task_queues:103:5)
    at async generateEmptyCoverage (/home/mpb/Documents/GitHub/mpbarbosa_site/src/node_modules/@jest/reporters/build/CoverageWorker.js:92:9)
-------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------------------------------
File                                                         | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
-------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------------------------------
All files                                                    |    5.26 |     3.75 |    4.68 |    5.29 |
 scripts                                                     |   56.75 |    58.33 |      60 |   56.75 |
  main.js                                                    |       0 |        0 |       0 |       0 | 4-23
  main.mjs                                                   |    91.3 |       70 |     100 |    91.3 | 49-50
 scripts/initialization                                      |       0 |        0 |       0 |       0 |
  InitializationUtilities.js                                 |       0 |        0 |       0 |       0 | 33-761
 submodules/guia_turistico/src/libs/guia_js/src              |   68.26 |    34.09 |      40 |   68.62 |
  guia.js                                                    |   67.96 |    34.09 |   35.71 |   68.31 | 62-63,72-74,94-99,105-110,139,272-360
  guia_ibge.js                                               |     100 |      100 |     100 |     100 |
 submodules/guia_turistico/src/libs/guia_js/src/config       |     100 |      100 |     100 |     100 |
  defaults.js                                                |     100 |      100 |     100 |     100 |
 submodules/guia_turistico/src/libs/guia_js/src/coordination |    2.12 |        0 |       0 |    2.12 |
  WebGeocodingManager.js                                     |    2.12 |        0 |       0 |    2.12 | 204-926
 submodules/guia_turistico/src/libs/guia_js/src/core         |   84.21 |    85.07 |   77.77 |   84.07 |
  GeoPosition.js                                             |   96.29 |    94.44 |      80 |   96.29 | 98
  ObserverSubject.js                                         |     100 |     87.5 |     100 |     100 | 190
  PositionManager.js                                         |   73.84 |    80.48 |   58.82 |   73.84 | 71,80,270-290,351-352,363-365,402-408
 submodules/guia_turistico/src/libs/guia_js/src/data         |   49.22 |    57.42 |   27.53 |   49.37 |
  AddressCache.js                                            |   43.92 |    36.52 |   26.74 |    43.6 | 100,131,173,178,246-310,329-447,459,465,473,497-583,641-652,689-694,705-709,720-724,751-790,803,816-842,855,873-1107,1115
  AddressDataExtractor.js                                    |   22.72 |      100 |   12.82 |   22.72 | 65,81-137,153-161,188,197-238
  AddressExtractor.js                                        |   95.65 |    93.75 |      75 |   95.65 | 136
  BrazilianStandardAddress.js                                |   81.81 |       50 |   83.33 |      90 | 79,101
  ReferencePlace.js                                          |      75 |    85.18 |   66.66 |      75 | 115-137
 submodules/guia_turistico/src/libs/guia_js/src/html         |   17.32 |     14.7 |    12.5 |   17.02 |
  DisplayerFactory.js                                        |   33.33 |       50 |       0 |   33.33 | 71-160,166
  HTMLAddressDisplayer.js                                    |    5.12 |     6.66 |       0 |    5.12 | 60-232
  HTMLPositionDisplayer.js                                   |       5 |     3.84 |       0 |       5 | 52-231
  HTMLReferencePlaceDisplayer.js                             |    4.65 |      5.4 |       0 |    4.65 | 59-227
  HtmlSpeechSynthesisDisplayer.js                            |      29 |    27.55 |   26.31 |   28.46 | 158,162,166,331-357,386-389,395-398,405-406,411-412,417-418,424-427,433-436,443-516,620-786
  HtmlText.js                                                |       0 |        0 |       0 |       0 | 58-126
 submodules/guia_turistico/src/libs/guia_js/src/services     |   27.22 |    22.58 |    25.8 |   27.91 |
  ChangeDetectionCoordinator.js                              |   18.96 |     12.5 |   18.18 |      20 | 49-245,273,301-309,345-363
  GeolocationService.js                                      |      25 |    17.02 |   22.72 |   25.55 | 52-68,82-89,112-119,140-143,173,310-548,568
  ReverseGeocoder.js                                         |   40.38 |    36.66 |   38.88 |   40.38 | 100-102,129-139,156,216-384
 submodules/guia_turistico/src/libs/guia_js/src/speech       |   18.75 |    19.64 |    12.5 |    19.1 |
  SpeechItem.js                                              |   13.33 |    15.38 |       0 |   13.33 | 80-174
  SpeechQueue.js                                             |    9.87 |    20.45 |    4.34 |   10.12 | 72,76,80,132-495
  SpeechSynthesisManager.js                                  |   23.29 |    19.81 |   18.42 |   23.69 | 162,170,213-252,264-265,278,326,332,341-346,354-355,358-359,398-778,816,835-1038
 submodules/guia_turistico/src/libs/guia_js/src/status       |   11.11 |    14.28 |       0 |   11.11 |
  SingletonStatusManager.js                                  |   11.11 |    14.28 |       0 |   11.11 | 86-296
 submodules/guia_turistico/src/libs/guia_js/src/timing       |     100 |    97.43 |     100 |     100 |
  Chronometer.js                                             |     100 |    97.43 |     100 |     100 | 125
 submodules/guia_turistico/src/libs/guia_js/src/utils        |   91.17 |    95.65 |    62.5 |   96.77 |
  device.js                                                  |     100 |    95.65 |     100 |     100 | 88
  distance.js                                                |   84.61 |      100 |   33.33 |     100 |
  logger.js                                                  |    87.5 |      100 |      75 |   85.71 | 70
 submodules/music_in_numbers/src                             |       0 |        0 |       0 |       0 |
  sw.js                                                      |       0 |        0 |       0 |       0 | 4-349
 submodules/music_in_numbers/src/scripts                     |       0 |        0 |       0 |       0 |
  analytics.js                                               |       0 |        0 |       0 |       0 | 15-280
  artist-api.js                                              |       0 |        0 |       0 |       0 | 41-250
  artist-page.js                                             |       0 |        0 |       0 |       0 | 48-291
  artist-ui.js                                               |       0 |        0 |       0 |       0 | 44-453
  data-export.js                                             |       0 |        0 |       0 |       0 | 14-961
  initialization.js                                          |       0 |        0 |       0 |       0 | 32-404
  performance.js                                             |       0 |        0 |       0 |       0 | 17-794
  real-time.js                                               |       0 |        0 |       0 |       0 | 19-274
  spotify-api.js                                             |       0 |        0 |       0 |       0 | 5-1855
  theme-manager.js                                           |       0 |        0 |       0 |       0 | 6-380
  utils.js                                                   |       0 |        0 |       0 |       0 | 14-368
 submodules/music_in_numbers/src/scripts/analytics           |       0 |        0 |       0 |       0 |
  AnalyticsCore.js                                           |       0 |        0 |       0 |       0 | 32-523
  AnalyticsProcessors.js                                     |       0 |        0 |       0 |       0 | 26-482
  AnalyticsUIBuilders.js                                     |       0 |        0 |       0 |       0 | 26-526
  AnalyticsUtilities.js                                      |       0 |        0 |       0 |       0 | 29-425
  AnalyticsValidators.js                                     |       0 |        0 |       0 |       0 | 26-470
 submodules/music_in_numbers/src/scripts/artist-api          |       0 |        0 |       0 |       0 |
  ArtistApiCore.js                                           |       0 |        0 |       0 |       0 | 40-431
  ArtistApiProcessors.js                                     |       0 |        0 |       0 |       0 | 37-386
  ArtistApiUIBuilders.js                                     |       0 |        0 |       0 |       0 | 38-475
  ArtistApiUtilities.js                                      |       0 |        0 |       0 |       0 | 38-641
  ArtistApiValidators.js                                     |       0 |        0 |       0 |       0 | 37-289
 submodules/music_in_numbers/src/scripts/artist-page         |       0 |        0 |       0 |       0 |
  ArtistPageCore.js                                          |       0 |        0 |       0 |       0 | 53-588
  ArtistPageProcessors.js                                    |       0 |        0 |       0 |       0 | 39-475
  ArtistPageUIBuilders.js                                    |       0 |        0 |       0 |       0 | 44-536
  ArtistPageUtilities.js                                     |       0 |        0 |       0 |       0 | 43-659
  ArtistPageValidators.js                                    |       0 |        0 |       0 |       0 | 39-391
 submodules/music_in_numbers/src/scripts/artist-ui           |       0 |        0 |       0 |       0 |
  ArtistUIBuilders.js                                        |       0 |        0 |       0 |       0 | 46-603
  ArtistUICore.js                                            |       0 |        0 |       0 |       0 | 39-731
  ArtistUIProcessors.js                                      |       0 |        0 |       0 |       0 | 39-581
  ArtistUIUtilities.js                                       |       0 |        0 |       0 |       0 | 42-1187
  ArtistUIValidators.js                                      |       0 |        0 |       0 |       0 | 40-569
 submodules/music_in_numbers/src/scripts/data-export         |       0 |        0 |       0 |       0 |
  DataExportCore.js                                          |       0 |        0 |       0 |       0 | 24-961
  DataExportProcessors.js                                    |       0 |        0 |       0 |       0 | 24-450
  DataExportUIBuilders.js                                    |       0 |        0 |       0 |       0 | 23-489
  DataExportUtilities.js                                     |       0 |        0 |       0 |       0 | 22-691
  DataExportValidators.js                                    |       0 |        0 |       0 |       0 | 23-381
  VALIDATION_TEST.js                                         |       0 |        0 |       0 |       0 | 16-371
 submodules/music_in_numbers/src/scripts/initialization      |       0 |        0 |       0 |       0 |
  InitializationCore.js                                      |       0 |        0 |       0 |       0 | 22-597
  InitializationProcessors.js                                |       0 |        0 |       0 |       0 | 19-390
  InitializationUIBuilders.js                                |       0 |        0 |       0 |       0 | 19-523
  InitializationUtilities.js                                 |       0 |        0 |       0 |       0 | 33-761
  InitializationValidators.js                                |       0 |        0 |       0 |       0 | 19-298
 submodules/music_in_numbers/src/scripts/performance         |       0 |        0 |       0 |       0 |
  PerformanceCore.js                                         |       0 |        0 |       0 |       0 | 32-765
  PerformanceProcessors.js                                   |       0 |        0 |       0 |       0 | 32-584
  PerformanceUIBuilders.js                                   |       0 |        0 |       0 |       0 | 32-734
  PerformanceUtilities.js                                    |       0 |        0 |       0 |       0 | 32-622
  PerformanceValidators.js                                   |       0 |        0 |       0 |       0 | 32-546
 submodules/music_in_numbers/src/scripts/real-time           |       0 |        0 |       0 |       0 |
  RealTimeCore.js                                            |       0 |        0 |       0 |       0 | 31-342
  RealTimeProcessors.js                                      |       0 |        0 |       0 |       0 | 25-294
  RealTimeUIBuilders.js                                      |       0 |        0 |       0 |       0 | 24-244
  RealTimeUtilities.js                                       |       0 |        0 |       0 |       0 | 31-374
  RealTimeValidators.js                                      |       0 |        0 |       0 |       0 | 25-273
 submodules/music_in_numbers/src/scripts/spotify-api         |       0 |        0 |       0 |       0 |
  SpotifyApiRequestBuilders.js                               |       0 |        0 |       0 |       0 | 9-235
  SpotifyApiResponseProcessors.js                            |       0 |        0 |       0 |       0 | 17-173
  SpotifyApiUtilities.js                                     |       0 |        0 |       0 |       0 | 31-334
  SpotifyApiValidators.js                                    |       0 |        0 |       0 |       0 | 16-415
  SpotifySessionDetector.js                                  |       0 |        0 |       0 |       0 | 28-481
  enhanced-session-feedback.js                               |       0 |        0 |       0 |       0 | 13-217
  test-validators.js                                         |       0 |        0 |     100 |       0 | 9-62
 submodules/music_in_numbers/src/scripts/theme-manager       |       0 |        0 |       0 |       0 |
  ThemeManagerCore.js                                        |       0 |        0 |       0 |       0 | 26-555
  ThemeManagerProcessors.js                                  |       0 |        0 |       0 |       0 | 20-306
  ThemeManagerUIBuilders.js                                  |       0 |        0 |       0 |       0 | 22-419
  ThemeManagerUtilities.js                                   |       0 |        0 |       0 |       0 | 20-507
  ThemeManagerValidators.js                                  |       0 |        0 |       0 |       0 | 20-251
 submodules/music_in_numbers/src/scripts/ui-components       |       0 |        0 |       0 |       0 |
  UIComponentsBuilders.js                                    |       0 |        0 |       0 |       0 | 22-608
  UIComponentsCore.js                                        |       0 |        0 |       0 |       0 | 32-590
  UIComponentsProcessors.js                                  |       0 |        0 |       0 |       0 | 23-386
  UIComponentsUtilities.js                                   |       0 |        0 |       0 |       0 | 21-628
  UIComponentsValidators.js                                  |       0 |        0 |       0 |       0 | 21-367
 submodules/music_in_numbers/src/scripts/utils               |       0 |        0 |       0 |       0 |
  UtilsBuilders.js                                           |       0 |        0 |       0 |       0 | 19-305
  UtilsCore.js                                               |       0 |        0 |       0 |       0 | 23-395
  UtilsProcessors.js                                         |       0 |        0 |       0 |       0 | 18-305
  UtilsUtilities.js                                          |       0 |        0 |       0 |       0 | 18-398
  UtilsValidators.js                                         |       0 |        0 |       0 |       0 | 17-247
-------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------------------------------
Summary of all failing tests
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

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js
  ● Core Modules Integration › should import GeoPosition from core module

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      17 | describe('Core Modules Integration', () => {
      18 |     test('should import GeoPosition from core module', async () => {
    > 19 |         const { GeoPosition } = await import('../src/core/GeoPosition.js');
         |                                 ^
      20 |         expect(GeoPosition).toBeDefined();
      21 |         expect(typeof GeoPosition).toBe('function');
      22 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:19:33)

  ● Core Modules Integration › should import ObserverSubject from core module

    Cannot find module '../src/core/ObserverSubject.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      23 |
      24 |     test('should import ObserverSubject from core module', async () => {
    > 25 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
         |                                              ^
      26 |         expect(ObserverSubject).toBeDefined();
      27 |         expect(typeof ObserverSubject).toBe('function');
      28 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:25:46)

  ● Core Modules Integration › should import PositionManager from core module

    Cannot find module '../src/core/PositionManager.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      29 |
      30 |     test('should import PositionManager from core module', async () => {
    > 31 |         const { default: PositionManager } = await import('../src/core/PositionManager.js');
         |                                              ^
      32 |         expect(PositionManager).toBeDefined();
      33 |         expect(typeof PositionManager).toBe('function');
      34 |     });

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:31:46)

  ● Core Modules Integration › should create immutable GeoPosition

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      35 |
      36 |     test('should create immutable GeoPosition', async () => {
    > 37 |         const { default: GeoPosition } = await import('../src/core/GeoPosition.js');
         |                                          ^
      38 |
      39 |         const mockPosition = {
      40 |             coords: {

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:37:42)

  ● Core Modules Integration › should create and use ObserverSubject

    Cannot find module '../src/core/ObserverSubject.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      62 |
      63 |     test('should create and use ObserverSubject', async () => {
    > 64 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
         |                                              ^
      65 |
      66 |         const subject = new ObserverSubject();
      67 |         let notified = false;

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:64:46)

  ● Core Modules Integration › should create PositionManager singleton

    Cannot find module '../src/core/PositionManager.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      82 |
      83 |     test('should create PositionManager singleton', async () => {
    > 84 |         const { default: PositionManager } = await import('../src/core/PositionManager.js');
         |                                              ^
      85 |
      86 |         const manager1 = PositionManager.getInstance();
      87 |         const manager2 = PositionManager.getInstance();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:84:46)

  ● Core Modules Integration › should export classes from guia.js

    Cannot find module '../src/guia.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      93 |
      94 |     test('should export classes from guia.js', async () => {
    > 95 |         const guia = await import('../src/guia.js');
         |                      ^
      96 |
      97 |         expect(guia.GeoPosition).toBeDefined();
      98 |         expect(guia.ObserverSubject).toBeDefined();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:95:22)

  ● Core Modules Integration › core classes should work together

    Cannot find module '../src/core/GeoPosition.js' from 'submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js'

      101 |
      102 |     test('core classes should work together', async () => {
    > 103 |         const { default: GeoPosition } = await import('../src/core/GeoPosition.js');
          |                                          ^
      104 |         const { default: ObserverSubject } = await import('../src/core/ObserverSubject.js');
      105 |
      106 |         const subject = new ObserverSubject();

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:863:11)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/integration/core-modules.test.js:103:42)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js
  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechMunicipio when MunicipioChanged event occurs

    TypeError: Cannot add property buildTextToSpeechMunicipio, object is not extensible

      257 |
      258 |             // Spy on the buildTextToSpeechMunicipio method
    > 259 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechMunicipio');
          |                                   ^
      260 |
      261 |             const currentAddress = new BrazilianStandardAddress();
      262 |             currentAddress.municipio = 'Campinas';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:259:35)

  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechBairro when BairroChanged event occurs

    TypeError: Cannot add property buildTextToSpeechBairro, object is not extensible

      283 |             }
      284 |
    > 285 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechBairro');
          |                                   ^
      286 |
      287 |             const currentAddress = new BrazilianStandardAddress();
      288 |             currentAddress.bairro = 'Jardins';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:285:35)

  ● Municipality Change Text Announcements (Issue #218) › Integration with update method › should call buildTextToSpeechLogradouro when LogradouroChanged event occurs

    TypeError: Cannot add property buildTextToSpeechLogradouro, object is not extensible

      299 |             }
      300 |
    > 301 |             const buildSpy = jest.spyOn(speechDisplayer, 'buildTextToSpeechLogradouro');
          |                                   ^
      302 |
      303 |             const currentAddress = new BrazilianStandardAddress();
      304 |             currentAddress.logradouro = 'Avenida Paulista';

      at ModuleMocker.spyOn (node_modules/jest-mock/build/index.js:628:27)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeText.test.js:301:35)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/AddressDataExtractor.test.js
  ● AddressDataExtractor - MP Barbosa Travel Guide (v0.4.1-alpha) › Extractor Initialization › should initialize with default Brazilian settings

    expect(received).toBe(expected) // Object.is equality

    Expected: "Brasil"
    Received: undefined

      91 |             const extractor = new AddressDataExtractor();
      92 |
    > 93 |             expect(extractor.defaultCountry).toBe('Brasil');
         |                                              ^
      94 |             expect(extractor.timeout).toBe(3000);
      95 |             expect(extractor.validPlaceClasses).toContain('amenity');
      96 |             expect(extractor.validPlaceClasses).toContain('building');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/AddressDataExtractor.test.js:93:46)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js
  ● PositionManager - MP Barbosa Travel Guide (v0.8.5-alpha) › Position Data Management (Brazilian Context) › should handle position updates with time and distance thresholds

    expect(received).toBe(expected) // Object.is equality

    Expected: "boolean"
    Received: "undefined"

      250 |
      251 |             // The implementation should consider both time and distance thresholds
    > 252 |             expect(typeof updated).toBe('boolean');
          |                                    ^
      253 |         });
      254 |     });
      255 |

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js:252:36)

  ● PositionManager - MP Barbosa Travel Guide (v0.8.5-alpha) › Observer Pattern Implementation › should handle invalid observer subscription gracefully

    expect(received).toBe(expected) // Object.is equality

    Expected: 0
    Received: 1

      310 |                 // Test object without update method
      311 |                 instance.subscribe({ name: 'invalid' });
    > 312 |                 expect(instance.observers.length).toBe(initialLength);
          |                                                   ^
      313 |             } else {
      314 |                 // Test defensive programming concepts
      315 |                 expect(null).toBeNull();

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/PositionManager.test.js:312:51)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/GeoPosition.immutability.test.js
  ● GeoPosition - Referential Transparency Tests › Immutability - No Setters › should not have accuracy setter

    TypeError: Cannot assign to read only property 'accuracy' of object '[object Object]'

      287 |
      288 |             // Attempt to set accuracy (should not have setter)
    > 289 |             geoPosition.accuracy = 50;
          |                                  ^
      290 |
      291 |             // In a pure implementation without setters, the property assignment
      292 |             // will simply overwrite the property value directly

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/unit/GeoPosition.immutability.test.js:289:34)

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

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js
  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Brazilian Location Processing › should handle Portuguese place names with accents

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      124 |
      125 |                 portuguesePlaces.forEach(place => {
    > 126 |                     expect(/[ãáçéíóú]/i.test(place)).toBe(true);
          |                                                      ^
      127 |                 });
      128 |                 return;
      129 |             }

      at submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:126:54
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:125:34)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should create ReferencePlace for shop/car_repair

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      176 |             });
      177 |
    > 178 |             expect(refPlace.typeName).toBe('car_repair');
          |                                       ^
      179 |             expect(refPlace.name).toBe('Oficina');
      180 |             // FIXED: Updated expected description to match actual format "Oficina Mecânica Oficina" -> "Oficina Mecânica Oficina"
      181 |             expect(refPlace.description).toBe('Oficina Mecânica Oficina');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:178:39)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should handle empty name in reference place

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      205 |             });
      206 |
    > 207 |             expect(refPlace.typeName).toBe('car_repair');
          |                                       ^
      208 |             expect(refPlace.name).toBeDefined();
      209 |
      210 |             // Should handle empty name gracefully

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:207:39)

  ● Nominatim JSON Format Tests - MP Barbosa Travel Guide (v0.4.1-alpha) › Reference Place - shop/car_repair › should support Brazilian automotive terminology

    expect(received).toBe(expected) // Object.is equality

    Expected: "car_repair"
    Received: null

      246 |
      247 |             expect(brazilianCarShop.name).toContain('Brasil');
    > 248 |             expect(brazilianCarShop.typeName).toBe('car_repair');
          |                                               ^
      249 |
      250 |             if (brazilianCarShop.tags) {
      251 |                 expect(brazilianCarShop.tags['addr:country']).toBe('BR');

      at Object.<anonymous> (submodules/guia_turistico/src/libs/guia_js/__tests__/external/NominatimJSONFormat.test.js:248:47)

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

FAIL __tests__/project_navigation.test.js
  ● Project Navigation Integration Tests › Project Integration with Submodules › should have .gitmodules configuration for all projects

    expect(received).toContain(expected) // indexOf

    Expected substring: "monitora_vagas"
    Received string:    "[submodule \"src/submodules/music_in_numbers\"]
    	path = src/submodules/music_in_numbers
    	url = git@github.com:mpbarbosa/music_in_numbers.git
    [submodule \"src/submodules/guia_turistico\"]
    	path = src/submodules/guia_turistico
    	url = git@github.com:mpbarbosa/guia_turistico.git
    "

      224 |       expect(gitmodulesContent).toContain('music_in_numbers');
      225 |       expect(gitmodulesContent).toContain('guia_turistico');
    > 226 |       expect(gitmodulesContent).toContain('monitora_vagas');
          |                                 ^
      227 |     });
      228 |
      229 |     test('should have consistent submodule directory structure', () => {

      at Object.<anonymous> (__tests__/project_navigation.test.js:226:33)

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

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechSynthesisManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechQueue.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SpeechItem.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/SingletonStatusManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HtmlText.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/ReferencePlace.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLPositionDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLReferencePlaceDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HtmlSpeechSynthesisDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/DisplayerFactory.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/utils/utils.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/unit/HTMLAddressDisplayer.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/managers/WebGeocodingManagerMunicipio.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/managers/WebGeocodingManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/ui/DisplayerFactory.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SingletonStatusManager.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechItem.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechQueue.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/SpeechSynthesisManager.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HTMLReferencePlaceDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HTMLAddressDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/HtmlSpeechSynthesisDisplayer.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/MunicipioChangeDetection.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/LocationChangeImmediateSpeech.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/ChangeDetectionCoordinator.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/DisplayerFactory.integration.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/integration/AddressDataExtractor-module.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/external/OSMAddressTranslation.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/tests/WebGeocodingManager.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/sidra/sidra.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/spotify-auth-di.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/security-testing.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/music_in_numbers/tests/performance-benchmarking.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

FAIL submodules/guia_turistico/src/libs/guia_js/__tests__/features/BairroChangeDetection.test.js
  ● Test suite failed to run

    ReferenceError: require is not defined in ES module scope, you can use import instead
    This file is being treated as an ES module because it has a '.js' file extension and '/home/mpb/Documents/GitHub/mpbarbosa_site/src/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.

      10 |  */
      11 |
    > 12 | const JSDOMEnvironment = require('jest-environment-jsdom').default;
         |                          ^
      13 |
      14 | class CustomJSDOMEnvironment extends JSDOMEnvironment {
      15 |     constructor(config, context) {

      at file:/home/mpb/Documents/GitHub/mpbarbosa_site/src/jest-environment-jsdom-no-warnings.js:12:26
      at Object.newLoader (node_modules/pirates/lib/index.js:134:7)
      at ScriptTransformer.requireAndTranspileModule (node_modules/@jest/transform/build/index.js:618:66)

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


Test Suites: 47 failed, 33 passed, 80 total
Tests:       35 failed, 918 passed, 953 total
Snapshots:   0 total
Time:        5.111 s
Ran all test suites.
```

---

**Generated by:** Tests & Documentation Workflow Automation v2.0.0
