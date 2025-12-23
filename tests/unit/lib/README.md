# Library Module Unit Tests

This directory contains unit tests for the workflow library modules located in `src/workflow/lib/`.

## Test Organization

All library module tests follow the naming convention `test_<module_name>.sh` and are organized here for proper separation of concerns.

## Test Files

### Core Module Tests

| Test File | Module Under Test | Description | Tests |
|-----------|------------------|-------------|-------|
| `test_third_party_exclusion.sh` | `third_party_exclusion.sh` | Third-party file exclusion patterns | 44 |
| `test_ai_cache.sh` | `ai_cache.sh` | AI response caching system | Multiple |
| `test_workflow_optimization.sh` | `workflow_optimization.sh` | Smart execution & parallel processing | Multiple |

### AI & Project Configuration Tests

| Test File | Module Under Test | Description |
|-----------|------------------|-------------|
| `test_ai_helpers_phase4.sh` | `ai_helpers.sh` | AI integration phase 4 features |
| `test_project_kind_config.sh` | `project_kind_config.sh` | Project kind configuration |
| `test_project_kind_detection.sh` | `project_kind_detection.sh` | Auto-detection of project types |
| `test_project_kind_integration.sh` | Multiple | Project kind integration tests |
| `test_project_kind_prompts.sh` | `ai_helpers.yaml` | AI prompt generation for project kinds |
| `test_project_kind_validation.sh` | `project_kind_config.sh` | Project kind validation |
| `test_get_project_kind.sh` | `project_kind_detection.sh` | Project kind getter functions |

### Tech Stack & Step Adaptation Tests

| Test File | Module Under Test | Description |
|-----------|------------------|-------------|
| `test_tech_stack_phase3.sh` | `tech_stack.sh` | Tech stack detection phase 3 |
| `test_step_adaptation.sh` | `step_adaptation.sh` | Step adaptation to project types |

### Performance & Optimization Tests

| Test File | Module Under Test | Description |
|-----------|------------------|-------------|
| `test_impact_calibration.sh` | `change_detection.sh` | Impact analysis calibration |
| `test_impact_fix.sh` | `change_detection.sh` | Impact detection fixes |
| `test_parallel_tracks.sh` | `workflow_optimization.sh` | Parallel execution tracking |

### Phase Integration Tests

| Test File | Module Under Test | Description |
|-----------|------------------|-------------|
| `test_phase5_enhancements.sh` | Multiple | Phase 5 feature integration |
| `test_phase5_final_steps.sh` | Multiple | Phase 5 final validation |

## Running Tests

### Run All Library Tests

```bash
# From project root
for test in tests/unit/lib/test_*.sh; do
  echo "Running: $(basename $test)"
  bash "$test"
done
```

### Run Specific Test

```bash
# Run third-party exclusion tests
bash tests/unit/lib/test_third_party_exclusion.sh

# Run AI cache tests
bash tests/unit/lib/test_ai_cache.sh

# Run workflow optimization tests
bash tests/unit/lib/test_workflow_optimization.sh
```

### Run via Test Runner

```bash
# Run all unit tests (includes these library tests)
./tests/test_runner.sh --unit

# Run with verbose output
./tests/test_runner.sh --unit --verbose
```

## Test Structure

Each test file follows this structure:

```bash
#!/bin/bash
set -uo pipefail

# Source the module being tested
source "$(dirname "$0")/../../../src/workflow/lib/module_name.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_equals() { ... }
assert_contains() { ... }
assert_true() { ... }

# Test functions
test_feature_1() {
    # Test implementation
    assert_equals "expected" "actual" "Test description"
}

# Main test runner
main() {
    echo "Testing: Module Name"
    test_feature_1
    test_feature_2
    
    # Report results
    echo "Tests: $TESTS_RUN | Passed: $TESTS_PASSED | Failed: $TESTS_FAILED"
    [[ $TESTS_FAILED -eq 0 ]] && exit 0 || exit 1
}

main "$@"
```

## Adding New Tests

When creating a new library module, add its test here:

1. **Create test file:**
   ```bash
   touch tests/unit/lib/test_my_module.sh
   chmod +x tests/unit/lib/test_my_module.sh
   ```

2. **Follow the standard structure** (see above)

3. **Source the module correctly:**
   ```bash
   source "$(dirname "$0")/../../../src/workflow/lib/my_module.sh"
   ```

4. **Update this README** with the new test

5. **Run the test:**
   ```bash
   bash tests/unit/lib/test_my_module.sh
   ```

## CI/CD Integration

These tests are automatically run by the GitHub Actions workflow:

- **Workflow:** `.github/workflows/validate-tests.yml`
- **Trigger:** Pull requests and pushes to main/develop
- **Step:** "Run library module tests"

The workflow specifically calls out important tests:
- `test_third_party_exclusion.sh` (newly implemented)
- `test_ai_cache.sh`
- `test_workflow_optimization.sh`

## Test Coverage

| Category | Test Files | Status |
|----------|-----------|--------|
| Core Modules | 3 | ✅ Active |
| AI & Config | 7 | ✅ Active |
| Tech Stack | 2 | ✅ Active |
| Performance | 3 | ✅ Active |
| Phase Integration | 2 | ✅ Active |
| **Total** | **17** | **✅ Active** |

## Path Updates

**Note:** Test files were moved from `src/workflow/lib/` to `tests/unit/lib/` on 2025-12-23 for better organization.

If any scripts reference the old paths, they need to be updated:

**Old path:**
```bash
bash src/workflow/lib/test_third_party_exclusion.sh
```

**New path:**
```bash
bash tests/unit/lib/test_third_party_exclusion.sh
```

## Related Documentation

- **Main Test README:** `tests/README.md`
- **Test Runner:** `tests/test_runner.sh`
- **GitHub Workflow:** `.github/workflows/validate-tests.yml`
- **Workflow Documentation:** `.github/workflows/README.md`

---

**Last Updated:** 2025-12-23  
**Total Tests:** 17 files  
**Location:** `tests/unit/lib/`
