# Module Development Guide

**Version**: 1.0.0  
**Last Updated**: 2026-02-10  
**Audience**: Developers creating new workflow modules

This guide provides comprehensive instructions for creating, testing, and integrating new modules into the AI Workflow Automation system.

## Table of Contents

- [Quick Start](#quick-start)
- [Module Types](#module-types)
- [Module Structure](#module-structure)
- [Development Workflow](#development-workflow)
- [Best Practices](#best-practices)
- [Testing Guidelines](#testing-guidelines)
- [Integration Steps](#integration-steps)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

---

## Quick Start

### Creating a Library Module

```bash
# 1. Create the module file
cat > src/workflow/lib/my_feature.sh << 'EOF'
#!/usr/bin/env bash
# Module: my_feature.sh
# Purpose: Brief description of module functionality
# Dependencies: List any required modules

set -euo pipefail

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/colors.sh"

# Module functions go here
function my_function() {
    local param1="$1"
    local param2="${2:-default_value}"
    
    # Function implementation
    print_info "Processing: $param1"
    
    return 0
}

# Export functions
export -f my_function
EOF

# 2. Make it executable
chmod +x src/workflow/lib/my_feature.sh

# 3. Create tests
cat > src/workflow/lib/test_my_feature.sh << 'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/my_feature.sh"

function test_my_function() {
    if my_function "test_value"; then
        echo "✅ test_my_function passed"
        return 0
    else
        echo "❌ test_my_function failed"
        return 1
    fi
}

# Run tests
test_my_function
EOF

chmod +x src/workflow/lib/test_my_feature.sh

# 4. Test it
./src/workflow/lib/test_my_feature.sh
```

### Creating a Step Module

```bash
# 1. Create step script in steps/ directory
cat > src/workflow/steps/my_new_step.sh << 'EOF'
#!/usr/bin/env bash
# Step: my_new_step
# Description: What this step does
# Dependencies: List step prerequisites

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"
source "${SCRIPT_DIR}/../lib/config.sh"

function validate_step() {
    # Pre-execution validation
    print_info "Validating my_new_step..."
    
    # Check prerequisites
    if [[ ! -f "some_required_file" ]]; then
        print_error "Required file missing"
        return 1
    fi
    
    return 0
}

function execute_step() {
    print_header "Executing: My New Step"
    
    # Step implementation
    print_info "Processing..."
    
    # Save results
    local output_file="${BACKLOG_DIR}/my_new_step_results.md"
    cat > "$output_file" << 'REPORT'
# My New Step Results

## Summary
Step completed successfully

## Details
- Item 1
- Item 2
REPORT
    
    print_success "Step completed"
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if validate_step; then
        execute_step
    else
        print_error "Validation failed"
        exit 1
    fi
fi
EOF

chmod +x src/workflow/steps/my_new_step.sh

# 2. Add step configuration to .workflow_core/config/workflow_steps.yaml
cat >> .workflow_core/config/workflow_steps.yaml << 'EOF'
- id: my_new_step
  name: "My New Step"
  file: my_new_step.sh
  category: validation
  dependencies: []
  stage: 1
  description: "What this step does"
EOF

# 3. Test the step
./src/workflow/steps/my_new_step.sh
```

---

## Module Types

### 1. Library Modules (`src/workflow/lib/`)

**Purpose**: Reusable functions and utilities

**Characteristics**:
- Pure functions when possible
- No direct side effects
- Exported functions via `export -f`
- Comprehensive parameter validation

**Examples**:
- `ai_helpers.sh` - AI integration functions
- `change_detection.sh` - File change analysis
- `metrics.sh` - Performance metrics collection
- `utils.sh` - Common utilities

### 2. Step Modules (`src/workflow/steps/`)

**Purpose**: Individual workflow execution steps

**Required Functions**:
- `validate_step()` - Pre-execution checks
- `execute_step()` - Main step logic

**Characteristics**:
- Self-contained execution
- Clear success/failure indicators
- Report generation
- Checkpoint support

**Examples**:
- `documentation_updates.sh` - Step 2: Documentation updates
- `test_execution.sh` - Step 3: Test execution
- `code_quality.sh` - Step 5: Code quality checks

### 3. Orchestrator Modules (`src/workflow/orchestrators/`)

**Purpose**: Coordinate multiple steps

**Characteristics**:
- Manage step dependencies
- Handle parallel execution
- Coordinate resource sharing

**Examples**:
- `pre_flight.sh` - Pre-flight checks
- `validation.sh` - Validation orchestration
- `quality.sh` - Quality checks
- `finalization.sh` - Final processing

---

## Module Structure

### Standard Header

Every module should start with:

```bash
#!/usr/bin/env bash
# Module: module_name.sh
# Purpose: Brief description (1-2 lines)
# Version: 1.0.0
# Dependencies: List required modules
# Author: Your name (optional)

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script directory resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies (minimal, explicit)
source "${SCRIPT_DIR}/utils.sh"
```

### Function Structure

```bash
# Function: function_name
# Description: What the function does
# Parameters:
#   $1 - parameter_name: Description
#   $2 - optional_param: Description (default: value)
# Returns:
#   0 - Success
#   1 - Error
# Output:
#   Writes to stdout/stderr as needed
function function_name() {
    local param1="${1:?Parameter 1 required}"
    local param2="${2:-default_value}"
    
    # Validate inputs
    if [[ -z "$param1" ]]; then
        print_error "param1 cannot be empty"
        return 1
    fi
    
    # Function logic
    print_info "Processing $param1..."
    
    # Error handling
    if ! some_command; then
        print_error "some_command failed"
        return 1
    fi
    
    # Success
    print_success "Completed"
    return 0
}

# Export if meant to be used by other modules
export -f function_name
```

### Configuration Section

```bash
# Configuration constants
readonly DEFAULT_TIMEOUT=180
readonly MAX_RETRIES=3
readonly CACHE_TTL=86400  # 24 hours

# Feature flags
ENABLE_CACHING="${ENABLE_CACHING:-true}"
DEBUG_MODE="${DEBUG:-false}"
```

### Error Handling

```bash
# Trap errors
trap 'error_handler $? $LINENO' ERR

function error_handler() {
    local exit_code=$1
    local line_number=$2
    print_error "Error on line $line_number: Exit code $exit_code"
    # Cleanup
    cleanup_resources
}

function cleanup_resources() {
    # Clean up temporary files, processes, etc.
    rm -f /tmp/temp_file_*
}
```

---

## Development Workflow

### 1. Planning Phase

**Define Requirements**:
- What problem does this module solve?
- What are the inputs and outputs?
- What are the dependencies?
- What error conditions should be handled?

**Design API**:
```bash
# Public functions (exported)
function public_function() { ... }
export -f public_function

# Private functions (internal only)
function _private_helper() { ... }
```

### 2. Implementation Phase

**Step-by-step**:

1. **Create module file**
   ```bash
   touch src/workflow/lib/my_module.sh
   chmod +x src/workflow/lib/my_module.sh
   ```

2. **Add header and structure**
   ```bash
   # Add shebang, set options, documentation
   ```

3. **Implement core functions**
   ```bash
   # Start with the main public API
   ```

4. **Add helper functions**
   ```bash
   # Internal utilities as needed
   ```

5. **Add error handling**
   ```bash
   # Trap, validation, cleanup
   ```

### 3. Testing Phase

**Create test file**:
```bash
cat > src/workflow/lib/test_my_module.sh << 'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/my_module.sh"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
function run_test() {
    local test_name="$1"
    if "$test_name"; then
        echo "✅ $test_name passed"
        ((TESTS_PASSED++))
    else
        echo "❌ $test_name failed"
        ((TESTS_FAILED++))
    fi
}

# Test cases
function test_basic_functionality() {
    local result
    result=$(my_function "test_input")
    [[ "$result" == "expected_output" ]]
}

function test_error_handling() {
    if my_function ""; then
        return 1  # Should have failed
    else
        return 0  # Correctly handled error
    fi
}

function test_edge_cases() {
    my_function "special-chars-!@#$%"
}

# Run all tests
run_test "test_basic_functionality"
run_test "test_error_handling"
run_test "test_edge_cases"

# Report
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
EOF

chmod +x src/workflow/lib/test_my_module.sh
```

**Run tests**:
```bash
./src/workflow/lib/test_my_module.sh
```

### 4. Integration Phase

**Update dependencies**:
```bash
# Update dependency_graph.sh if needed
vim src/workflow/lib/dependency_graph.sh
```

**Document the module**:
```bash
# Add to MODULE_API_REFERENCE.md
# Add examples to API_EXAMPLES.md
```

**Update version**:
```bash
# Update CHANGELOG.md with new module
# Update PROJECT_REFERENCE.md module inventory
```

---

## Best Practices

### Code Quality

1. **Naming Conventions**
   ```bash
   # Variables: UPPER_CASE for constants, lower_case for variables
   readonly MAX_ATTEMPTS=3
   local current_attempt=1
   
   # Functions: verb_noun pattern
   function parse_config() { ... }
   function validate_input() { ... }
   
   # Private functions: leading underscore
   function _internal_helper() { ... }
   ```

2. **Parameter Validation**
   ```bash
   function my_function() {
       # Required parameter with error message
       local required="${1:?ERROR: Required parameter missing}"
       
       # Optional parameter with default
       local optional="${2:-default_value}"
       
       # Validate format
       if [[ ! "$required" =~ ^[a-zA-Z0-9_]+$ ]]; then
           print_error "Invalid format: $required"
           return 1
       fi
   }
   ```

3. **Error Handling**
   ```bash
   function safe_operation() {
       # Check preconditions
       if [[ ! -f "$INPUT_FILE" ]]; then
           print_error "Input file not found: $INPUT_FILE"
           return 1
       fi
       
       # Try operation with error handling
       if ! some_command "$INPUT_FILE"; then
           print_error "Command failed"
           cleanup_partial_results
           return 1
       fi
       
       # Verify postconditions
       if [[ ! -f "$OUTPUT_FILE" ]]; then
           print_error "Output not created"
           return 1
       fi
       
       return 0
   }
   ```

4. **Logging**
   ```bash
   function verbose_operation() {
       [[ "$VERBOSE" == "true" ]] && print_info "Starting operation..."
       
       # Operation
       local result
       result=$(process_data)
       
       [[ "$DEBUG" == "true" ]] && echo "DEBUG: result=$result"
       
       print_success "Operation completed"
   }
   ```

### Performance

1. **Minimize Subshells**
   ```bash
   # ❌ Slow: Creates subshell
   files=$(find . -name "*.sh")
   
   # ✅ Fast: Use mapfile/readarray
   mapfile -t files < <(find . -name "*.sh")
   ```

2. **Use Built-ins**
   ```bash
   # ❌ External command
   basename "$filepath"
   
   # ✅ Parameter expansion
   "${filepath##*/}"
   ```

3. **Cache Expensive Operations**
   ```bash
   function get_expensive_data() {
       local cache_file="/tmp/cache_$$"
       
       if [[ -f "$cache_file" ]]; then
           cat "$cache_file"
           return 0
       fi
       
       # Expensive operation
       local data
       data=$(expensive_computation)
       
       # Cache result
       echo "$data" > "$cache_file"
       echo "$data"
   }
   ```

### Maintainability

1. **Single Responsibility**
   ```bash
   # ❌ Does too much
   function process_and_validate_and_save() { ... }
   
   # ✅ Separate concerns
   function process_data() { ... }
   function validate_data() { ... }
   function save_data() { ... }
   ```

2. **DRY (Don't Repeat Yourself)**
   ```bash
   # ❌ Repeated logic
   if [[ ! -f "file1.txt" ]]; then
       print_error "file1.txt not found"
       return 1
   fi
   if [[ ! -f "file2.txt" ]]; then
       print_error "file2.txt not found"
       return 1
   fi
   
   # ✅ Extract to function
   function require_file() {
       local file="$1"
       if [[ ! -f "$file" ]]; then
           print_error "$file not found"
           return 1
       fi
   }
   
   require_file "file1.txt" || return 1
   require_file "file2.txt" || return 1
   ```

3. **Clear Dependencies**
   ```bash
   # Document dependencies at top of file
   # Dependencies:
   #   - utils.sh: print_* functions
   #   - config.sh: PROJECT_ROOT, BACKLOG_DIR
   #   - External: jq, git
   
   # Check external dependencies
   function check_dependencies() {
       local missing=()
       
       command -v jq >/dev/null 2>&1 || missing+=("jq")
       command -v git >/dev/null 2>&1 || missing+=("git")
       
       if [[ ${#missing[@]} -gt 0 ]]; then
           print_error "Missing dependencies: ${missing[*]}"
           return 1
       fi
   }
   ```

---

## Testing Guidelines

### Unit Testing

**Test Structure**:
```bash
#!/usr/bin/env bash
# Test: test_my_module.sh
# Purpose: Unit tests for my_module.sh

set -euo pipefail

# Source module under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/my_module.sh"

# Test utilities
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        echo "   Expected: $expected"
        echo "   Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    ((TESTS_RUN++))
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test cases
function test_function_returns_correct_value() {
    local result
    result=$(my_function "input")
    assert_equals "expected" "$result" "my_function returns correct value"
}

function test_function_handles_empty_input() {
    if my_function ""; then
        echo "❌ FAIL: Should reject empty input"
        ((TESTS_FAILED++))
        return 1
    else
        echo "✅ PASS: Correctly rejects empty input"
        ((TESTS_PASSED++))
        return 0
    fi
}

function test_function_handles_special_characters() {
    local result
    result=$(my_function "test-!@#")
    assert_equals "expected-!@#" "$result" "Handles special chars"
}

# Run tests
echo "Running unit tests for my_module.sh"
echo "======================================"

test_function_returns_correct_value
test_function_handles_empty_input
test_function_handles_special_characters

# Report
echo ""
echo "======================================"
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "======================================"

# Exit with appropriate code
[[ $TESTS_FAILED -eq 0 ]]
```

### Integration Testing

**Test Workflow Integration**:
```bash
#!/usr/bin/env bash
# Integration test: Test module in real workflow

set -euo pipefail

echo "Integration Test: my_module in workflow context"

# Setup test environment
TEST_DIR="/tmp/test_$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize test project
git init
echo "# Test Project" > README.md
git add README.md
git commit -m "Initial commit"

# Run workflow with module
if /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
    --steps my_new_step \
    --dry-run; then
    echo "✅ Integration test passed"
    rm -rf "$TEST_DIR"
    exit 0
else
    echo "❌ Integration test failed"
    rm -rf "$TEST_DIR"
    exit 1
fi
```

### Test Coverage Goals

- **Library Modules**: 80%+ function coverage
- **Step Modules**: 100% of validate_step and execute_step
- **Edge Cases**: Empty inputs, special characters, large datasets
- **Error Paths**: All error conditions tested
- **Integration**: Module works in complete workflow

---

## Integration Steps

### 1. Add to Dependency Graph

Edit `src/workflow/lib/dependency_graph.sh`:

```bash
# Add module dependencies
declare -gA MODULE_DEPENDENCIES=(
    ["my_module"]="utils colors config"
    # ... other modules
)
```

### 2. Update Configuration

If your module adds new workflow steps, update `.workflow_core/config/workflow_steps.yaml`:

```yaml
- id: my_new_step
  name: "My New Step"
  file: my_new_step.sh
  category: validation  # preprocessing, validation, testing, quality, finalization
  dependencies: [documentation_updates]  # Step IDs this depends on
  stage: 1  # 1=core, 2=extended, 3=finalization
  description: "Brief description"
  ai_persona: "documentation_specialist"  # Optional AI persona
  parallel_group: null  # Or group number for parallel execution
```

### 3. Document the Module

**Add to MODULE_API_REFERENCE.md**:
```markdown
### my_module.sh
**Purpose**: Brief description

**Functions**:

#### `my_function(param1, param2)`
Description of what it does

**Parameters**:
- `param1`: Description
- `param2`: Description (optional, default: value)

**Returns**: 
- 0 on success
- 1 on failure

**Example**:
\`\`\`bash
source lib/my_module.sh
my_function "value1" "value2"
\`\`\`

**Dependencies**: utils.sh, config.sh
```

**Add to API_EXAMPLES.md**:
```markdown
### My Module Example

\`\`\`bash
#!/bin/bash
source "$(dirname "$0")/lib/my_module.sh"

# Usage example
my_function "input_data"
\`\`\`
```

### 4. Update Project Documentation

**Update PROJECT_REFERENCE.md**:
- Add to module inventory
- Update module count
- Add to feature list if applicable

**Update CHANGELOG.md**:
```markdown
## [Unreleased]

### Added
- New module `my_module.sh` for [functionality]
- New step "My New Step" for [purpose]
```

---

## Common Patterns

### Pattern 1: Configuration Loading

```bash
function load_module_config() {
    local config_file="${1:-.workflow-config.yaml}"
    
    # Check if config exists
    if [[ ! -f "$config_file" ]]; then
        print_warning "Config file not found, using defaults"
        return 0
    fi
    
    # Load with jq (if available)
    if command -v jq >/dev/null 2>&1; then
        MY_CONFIG=$(jq -r '.my_module.setting' "$config_file" 2>/dev/null || echo "default")
    else
        # Fallback: grep/sed
        MY_CONFIG=$(grep "setting:" "$config_file" | sed 's/.*: //' || echo "default")
    fi
    
    print_info "Loaded config: MY_CONFIG=$MY_CONFIG"
}
```

### Pattern 2: File Processing

```bash
function process_files() {
    local pattern="${1:-*.txt}"
    local action="${2:-process}"
    
    local processed=0
    local failed=0
    
    # Find files
    mapfile -t files < <(find . -name "$pattern" -type f)
    
    print_info "Found ${#files[@]} files matching $pattern"
    
    # Process each file
    for file in "${files[@]}"; do
        print_info "Processing: $file"
        
        if "$action" "$file"; then
            ((processed++))
        else
            print_error "Failed: $file"
            ((failed++))
        fi
    done
    
    # Report
    print_success "Processed: $processed, Failed: $failed"
    [[ $failed -eq 0 ]]
}
```

### Pattern 3: Caching

```bash
function with_cache() {
    local cache_key="$1"
    local cache_ttl="${2:-3600}"  # 1 hour default
    local cache_dir="${CACHE_DIR:-.cache}"
    local cache_file="${cache_dir}/${cache_key}.cache"
    
    # Create cache directory
    mkdir -p "$cache_dir"
    
    # Check cache validity
    if [[ -f "$cache_file" ]]; then
        local cache_age
        cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file")))
        
        if [[ $cache_age -lt $cache_ttl ]]; then
            print_info "Cache hit: $cache_key"
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Cache miss - compute and store
    print_info "Cache miss: $cache_key"
    local result
    result=$(expensive_operation)
    echo "$result" > "$cache_file"
    echo "$result"
}
```

### Pattern 4: Parallel Processing

```bash
function parallel_process() {
    local -a items=("$@")
    local max_parallel=4
    local active=0
    
    for item in "${items[@]}"; do
        # Wait if at max parallel
        while [[ $active -ge $max_parallel ]]; do
            wait -n
            ((active--))
        done
        
        # Start background process
        (
            process_item "$item"
        ) &
        ((active++))
    done
    
    # Wait for all to complete
    wait
}
```

### Pattern 5: Progress Reporting

```bash
function with_progress() {
    local total="$1"
    local current=0
    
    while IFS= read -r item; do
        ((current++))
        local percent=$((current * 100 / total))
        printf "\rProgress: [%-50s] %d%%" \
            "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
            "$percent"
        
        process_item "$item"
    done
    
    echo ""  # New line after progress bar
}
```

---

## Troubleshooting

### Common Issues

#### Issue 1: Module Not Found

**Symptoms**: `bash: my_module.sh: No such file or directory`

**Solution**:
```bash
# Use absolute path or SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/my_module.sh"
```

#### Issue 2: Function Not Exported

**Symptoms**: `bash: my_function: command not found` when called from another module

**Solution**:
```bash
# Export the function
function my_function() { ... }
export -f my_function
```

#### Issue 3: Variable Scope Issues

**Symptoms**: Variables not accessible or have unexpected values

**Solution**:
```bash
# Use local for function variables
function my_function() {
    local my_var="value"  # Not global
    
    # Explicitly declare global if needed
    declare -g GLOBAL_VAR="value"
}
```

#### Issue 4: Trap Conflicts

**Symptoms**: Error handlers not firing or conflicting

**Solution**:
```bash
# Chain traps instead of replacing
trap 'cleanup; previous_trap' EXIT
```

---

## Examples

### Example 1: Simple Utility Module

**File**: `src/workflow/lib/string_utils.sh`

```bash
#!/usr/bin/env bash
# Module: string_utils.sh
# Purpose: String manipulation utilities

set -euo pipefail

function trim() {
    local var="$1"
    # Remove leading whitespace
    var="${var#"${var%%[![:space:]]*}"}"
    # Remove trailing whitespace
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

function to_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

function to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

function slugify() {
    local text="$1"
    text=$(to_lower "$text")
    text="${text//[^a-z0-9]/-}"
    text="${text//--/-}"
    echo "$text"
}

export -f trim to_upper to_lower slugify
```

### Example 2: Data Processing Module

**File**: `src/workflow/lib/json_processor.sh`

```bash
#!/usr/bin/env bash
# Module: json_processor.sh
# Purpose: JSON processing utilities

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

function json_get() {
    local file="$1"
    local key="$2"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq not installed"
        return 1
    fi
    
    jq -r "$key" "$file"
}

function json_set() {
    local file="$1"
    local key="$2"
    local value="$3"
    
    local tmp_file="${file}.tmp"
    
    if jq "$key = \"$value\"" "$file" > "$tmp_file"; then
        mv "$tmp_file" "$file"
        return 0
    else
        rm -f "$tmp_file"
        return 1
    fi
}

export -f json_get json_set
```

### Example 3: Complete Step Module

**File**: `src/workflow/steps/security_scan.sh`

```bash
#!/usr/bin/env bash
# Step: security_scan
# Description: Run security vulnerability scanning
# Dependencies: Code quality analysis

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"
source "${SCRIPT_DIR}/../lib/config.sh"
source "${SCRIPT_DIR}/../lib/ai_helpers.sh"

function validate_step() {
    print_info "Validating security scan prerequisites..."
    
    # Check for security scanning tools
    local tools_available=false
    
    if command -v npm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
        print_info "Found npm, will use npm audit"
        tools_available=true
    fi
    
    if command -v pip >/dev/null 2>&1; then
        if pip show safety >/dev/null 2>&1; then
            print_info "Found safety, will scan Python dependencies"
            tools_available=true
        fi
    fi
    
    if [[ "$tools_available" == "false" ]]; then
        print_warning "No security scanning tools available"
        return 0  # Don't fail, just skip
    fi
    
    return 0
}

function execute_step() {
    print_header "Step: Security Vulnerability Scan"
    
    local output_file="${BACKLOG_DIR}/security_scan_results.md"
    local issues_found=false
    
    # Initialize report
    cat > "$output_file" << 'EOF'
# Security Scan Results

## Summary
Security vulnerability scan completed.

## Scans Performed

EOF
    
    # Scan npm dependencies
    if command -v npm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
        print_info "Scanning npm dependencies..."
        
        if npm audit --json > /tmp/npm_audit.json 2>&1; then
            local vulnerabilities
            vulnerabilities=$(jq '.metadata.vulnerabilities.total' /tmp/npm_audit.json)
            
            echo "### NPM Dependencies" >> "$output_file"
            echo "- Total vulnerabilities: $vulnerabilities" >> "$output_file"
            
            if [[ "$vulnerabilities" -gt 0 ]]; then
                issues_found=true
                jq -r '.advisories | to_entries[] | "- [\(.value.severity)] \(.value.title)"' \
                    /tmp/npm_audit.json >> "$output_file"
            fi
        fi
    fi
    
    # Scan Python dependencies
    if command -v pip >/dev/null 2>&1 && pip show safety >/dev/null 2>&1; then
        print_info "Scanning Python dependencies..."
        
        echo "" >> "$output_file"
        echo "### Python Dependencies" >> "$output_file"
        
        if safety check --json > /tmp/safety_check.json 2>&1; then
            echo "- No vulnerabilities found" >> "$output_file"
        else
            issues_found=true
            jq -r '.[] | "- [\(.severity)] \(.advisory)"' \
                /tmp/safety_check.json >> "$output_file"
        fi
    fi
    
    # AI Analysis if issues found
    if [[ "$issues_found" == "true" ]] && check_copilot_available; then
        print_info "Requesting AI security analysis..."
        
        ai_call "security_analyst" \
            "Review the security vulnerabilities found and provide recommendations" \
            "${BACKLOG_DIR}/security_recommendations.md"
    fi
    
    # Cleanup
    rm -f /tmp/npm_audit.json /tmp/safety_check.json
    
    if [[ "$issues_found" == "true" ]]; then
        print_warning "Security vulnerabilities found - review report"
    else
        print_success "No security vulnerabilities detected"
    fi
    
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if validate_step; then
        execute_step
    else
        print_error "Validation failed"
        exit 1
    fi
fi
```

---

## Next Steps

After creating your module:

1. **Test Thoroughly**
   ```bash
   ./src/workflow/lib/test_my_module.sh
   ```

2. **Document**
   - Update MODULE_API_REFERENCE.md
   - Add examples to API_EXAMPLES.md
   - Update CHANGELOG.md

3. **Integrate**
   - Add to dependency graph
   - Update workflow configuration
   - Test in complete workflow

4. **Review**
   - Code review by maintainers
   - Performance testing
   - Integration testing

5. **Deploy**
   - Merge to main branch
   - Update version numbers
   - Update documentation

---

## Resources

- [Module API Reference](MODULE_API_REFERENCE.md) - Complete API documentation
- [API Examples](API_EXAMPLES.md) - Code examples
- [Architecture Overview](ARCHITECTURE_OVERVIEW.md) - System architecture
- [Testing Best Practices](TESTING_BEST_PRACTICES.md) - Testing guidelines
- [Project Reference](PROJECT_REFERENCE.md) - Complete project documentation

---

**Questions or Issues?**

- GitHub Issues: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- Email: mpbarbosa@gmail.com

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
