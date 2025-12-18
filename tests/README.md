# Tests Directory

Comprehensive test suite for AI Workflow Automation system.

## Structure

```
tests/
├── unit/                      # Unit tests for individual modules
│   ├── test_ai_cache_EXAMPLE.sh
│   ├── test_batch_operations.sh
│   ├── test_enhancements.sh
│   └── test_tech_stack.sh
├── integration/               # Integration tests for workflow components
│   ├── test_adaptive_checks.sh
│   ├── test_file_operations.sh
│   ├── test_modules.sh
│   ├── test_orchestrator.sh
│   └── test_session_manager.sh
├── fixtures/                  # Test fixtures and mock data
└── run_all_tests.sh          # Master test runner
```

## Running Tests

### Run All Tests

```bash
./tests/run_all_tests.sh
```

### Run Specific Test Suites

```bash
# Unit tests only
./tests/run_all_tests.sh --unit

# Integration tests only
./tests/run_all_tests.sh --integration
```

### Run Individual Tests

```bash
# Run a specific unit test
./tests/unit/test_tech_stack.sh

# Run a specific integration test
./tests/integration/test_modules.sh
```

### Advanced Options

```bash
# Stop on first failure
./tests/run_all_tests.sh --fail-fast

# Verbose output
./tests/run_all_tests.sh --verbose

# Help
./tests/run_all_tests.sh --help
```

## Test Categories

### Unit Tests

Test individual library modules in isolation:

- **test_ai_cache_EXAMPLE.sh** - AI response caching functionality
- **test_batch_operations.sh** - Batch operation utilities
- **test_enhancements.sh** - Enhancement module tests
- **test_tech_stack.sh** - Technology stack detection

### Integration Tests

Test workflow components and their interactions:

- **test_adaptive_checks.sh** - Adaptive validation system
- **test_file_operations.sh** - File operation integration
- **test_modules.sh** - Module loading and integration
- **test_orchestrator.sh** - Workflow orchestration
- **test_session_manager.sh** - Session management

## Writing Tests

### Test File Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Test setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Source module under test
source "${PROJECT_ROOT}/src/workflow/lib/MODULE_NAME.sh"

# Test functions
test_function_name() {
    # Arrange
    local input="test_value"
    
    # Act
    local result=$(function_to_test "${input}")
    
    # Assert
    if [[ "${result}" == "expected_value" ]]; then
        echo "✓ Test passed"
        return 0
    else
        echo "✗ Test failed: expected 'expected_value', got '${result}'"
        return 1
    fi
}

# Run tests
test_function_name

echo "All tests passed!"
```

### Best Practices

1. **Isolation** - Each test should be independent
2. **Clear Names** - Use descriptive test function names
3. **Arrange-Act-Assert** - Follow the AAA pattern
4. **Cleanup** - Clean up test artifacts
5. **Fast Execution** - Keep tests fast and focused
6. **Deterministic** - Tests should produce consistent results

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run Tests
  run: |
    cd tests
    ./run_all_tests.sh
```

### Pre-commit Hook Example

```bash
#!/bin/bash
# .git/hooks/pre-commit
cd tests
./run_all_tests.sh --fail-fast
```

## Test Coverage

Current test coverage:

- **Unit Tests**: 4 test files
- **Integration Tests**: 5 test files
- **Total Test Files**: 9

## Troubleshooting

### Test Fails Locally But Passes in CI

- Check for environment-specific dependencies
- Verify file permissions
- Ensure all test fixtures are committed

### Slow Test Execution

- Review test isolation
- Check for unnecessary external calls
- Consider mocking external dependencies

### Intermittent Failures

- Look for race conditions
- Check for timing dependencies
- Verify test cleanup procedures

## Contributing

When adding new functionality:

1. Write tests first (TDD)
2. Place unit tests in `tests/unit/`
3. Place integration tests in `tests/integration/`
4. Follow naming convention: `test_*.sh`
5. Make test files executable: `chmod +x test_file.sh`
6. Run full test suite before submitting PR

## Support

For test-related questions or issues:

- Review existing test files for examples
- Check project documentation in `docs/`
- Refer to workflow automation guides

---

**Last Updated**: 2025-12-18  
**Test Framework Version**: 1.0.0
