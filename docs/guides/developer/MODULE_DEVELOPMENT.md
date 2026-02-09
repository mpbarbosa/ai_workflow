# Module Development Guide

**Version**: v3.0.0  
**Last Updated**: 2026-01-31  
**Audience**: Developers extending the AI Workflow Automation system

This comprehensive guide walks you through creating new step modules, library modules, and orchestrators for the AI Workflow Automation system.

## Table of Contents

- [Overview](#overview)
- [Module Types](#module-types)
- [Architecture Principles](#architecture-principles)
- [Creating a Step Module](#creating-a-step-module)
- [Creating a Library Module](#creating-a-library-module)
- [Creating an Orchestrator](#creating-an-orchestrator)
- [Submodule Architecture](#submodule-architecture)
- [Testing Your Module](#testing-your-module)
- [Integration Patterns](#integration-patterns)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

---

## Overview

The AI Workflow Automation system is built on a modular architecture with three primary module types:

1. **Step Modules** (18 total) - Workflow execution steps (e.g., documentation analysis, test execution)
2. **Library Modules** (62 total) - Reusable utility functions (e.g., AI helpers, git cache, metrics)
3. **Orchestrators** (4 total) - Phase coordination modules (e.g., validation, quality)

### System Architecture

```
execute_tests_docs_workflow.sh (Main Orchestrator)
├── orchestrators/
│   ├── pre_flight.sh          → Steps 0a, 0b, 00
│   ├── validation_orchestrator.sh → Steps 01-04
│   ├── quality_orchestrator.sh    → Steps 08-09
│   └── finalization_orchestrator.sh → Steps 10-12
│
├── steps/
│   ├── step_00_analyze.sh
│   ├── step_01_documentation.sh
│   ├── step_01_lib/           → Submodules for complex steps
│   │   ├── cache.sh
│   │   ├── validation.sh
│   │   ├── file_operations.sh
│   │   └── ai_integration.sh
│   ├── step_02_consistency.sh
│   └── ... (15 more steps)
│
└── lib/
    ├── ai_helpers.sh
    ├── git_cache.sh
    ├── metrics.sh
    └── ... (59 more library modules)
```

---

## Module Types

### Step Modules

**Purpose**: Execute specific workflow validation or analysis tasks  
**Location**: `src/workflow/steps/`  
**Naming**: `step_XX_name.sh` (XX = 00-15, 0a, 0b)  
**Size**: 150-300 lines (simple), 300-800 lines (complex with submodules)

**Key Functions**:
- `stepXX_<action>()` - Main execution function
- No required interface (orchestrator calls directly)

**Examples**:
- `step_00_analyze.sh` - Pre-analysis and change detection
- `step_07_test_exec.sh` - Test execution and results capture
- `step_12_markdown_lint.sh` - Markdown quality validation

### Library Modules

**Purpose**: Provide reusable utility functions across steps  
**Location**: `src/workflow/lib/`  
**Naming**: `descriptive_name.sh` (e.g., `ai_helpers.sh`, `metrics.sh`)  
**Size**: 100-500 lines (focused modules), 500-1500 lines (complex modules)

**Key Characteristics**:
- Pure functions where possible
- No side effects (except I/O modules)
- Stateless or minimal state
- Well-documented APIs

**Examples**:
- `ai_helpers.sh` - AI integration (762 lines)
- `git_cache.sh` - Git state caching (250 lines)
- `change_detection.sh` - File change analysis (400 lines)

### Orchestrators

**Purpose**: Coordinate multiple related steps into phases  
**Location**: `src/workflow/orchestrators/`  
**Naming**: `<phase>_orchestrator.sh` or `<phase>.sh`  
**Size**: 80-230 lines

**Key Functions**:
- `run_<phase>_phase()` - Main orchestration function
- Returns combined exit codes from steps

**Examples**:
- `pre_flight.sh` - Pre-flight checks (Steps 0a, 0b, 00)
- `validation_orchestrator.sh` - Validation phase (Steps 01-04)
- `quality_orchestrator.sh` - Quality phase (Steps 08-09)

---

## Architecture Principles

### 1. Single Responsibility Principle

Each module should have **one clear purpose**:

```bash
# ✅ GOOD: Focused module
# git_cache.sh - Manages git state caching only

# ❌ BAD: Multiple responsibilities
# git_and_file_operations.sh - Does too many things
```

### 2. Dependency Injection

Modules should receive dependencies, not hardcode them:

```bash
# ✅ GOOD: Dependency injection
analyze_files() {
    local files="$1"
    local analysis_func="$2"
    
    for file in $files; do
        "$analysis_func" "$file"
    done
}

# ❌ BAD: Hardcoded dependency
analyze_files() {
    local files="$1"
    
    for file in $files; do
        hardcoded_analysis "$file"  # Can't be tested or swapped
    done
}
```

### 3. Error Handling

Every function must handle errors gracefully:

```bash
# ✅ GOOD: Proper error handling
process_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    if ! validate_file "$file"; then
        print_error "File validation failed: $file"
        return 2
    fi
    
    # ... process file
    return 0
}

# ❌ BAD: No error handling
process_file() {
    local file="$1"
    cat "$file" | process  # No validation, fails silently
}
```

### 4. State Management

Minimize mutable state; prefer pure functions:

```bash
# ✅ GOOD: Pure function (no side effects)
calculate_metrics() {
    local start_time="$1"
    local end_time="$2"
    
    local duration=$((end_time - start_time))
    echo "$duration"
}

# ❌ BAD: Mutates global state
calculate_metrics() {
    DURATION=$((END_TIME - START_TIME))  # Global mutation
}
```

### 5. Configuration as Code

Use configuration files, not hardcoded values:

```bash
# ✅ GOOD: Configuration-driven
get_test_command() {
    local config_file=".workflow-config.yaml"
    
    if [[ -f "$config_file" ]]; then
        yq eval '.tech_stack.test_command' "$config_file" 2>/dev/null || echo "npm test"
    else
        echo "npm test"
    fi
}

# ❌ BAD: Hardcoded
get_test_command() {
    echo "npm test"  # Inflexible
}
```

---

## Creating a Step Module

### Step 1: Plan Your Step

Before writing code, define:

1. **Purpose**: What does this step validate or analyze?
2. **Dependencies**: What library modules does it need?
3. **Inputs**: What data does it require? (git state, config files, etc.)
4. **Outputs**: What artifacts does it produce? (reports, metrics, etc.)
5. **Relevance**: When should this step run? (always, conditionally, by project kind)
6. **Duration**: Expected execution time

**Example Plan**:

```
Step 16: API Contract Validation
Purpose: Validate API endpoints match OpenAPI specification
Dependencies: ai_helpers.sh, git_cache.sh, metrics.sh
Inputs: OpenAPI spec (openapi.yaml), API code (src/api/)
Outputs: Backlog report, validation metrics
Relevance: Only for nodejs_api and python_api projects
Duration: ~3-5 minutes
```

### Step 2: Create Step File

Create the step file with proper structure:

```bash
# File: src/workflow/steps/step_16_api_validation.sh
#!/bin/bash
set -euo pipefail

################################################################################
# Step 16: API Contract Validation
# Purpose: Validate API endpoints match OpenAPI specification
# Part of: Tests & Documentation Workflow Automation v3.0.0
# Version: 1.0.0
################################################################################

# Module version information
readonly STEP16_VERSION="1.0.0"
readonly STEP16_VERSION_MAJOR=1
readonly STEP16_VERSION_MINOR=0
readonly STEP16_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP16_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP16_DIR}/../lib"

# Source required library modules
source "${WORKFLOW_LIB_DIR}/ai_helpers.sh"
source "${WORKFLOW_LIB_DIR}/git_cache.sh"
source "${WORKFLOW_LIB_DIR}/metrics.sh"
source "${WORKFLOW_LIB_DIR}/colors.sh"
source "${WORKFLOW_LIB_DIR}/utils.sh"

# Main step function - validates API contracts
# Returns: 0 for success, 1 for failure
step16_api_validation() {
    print_step "16" "API Contract Validation"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Start step metrics
    start_step_metrics "16" "api_validation"
    
    # Check relevance - only run for API projects
    if ! is_api_project; then
        print_info "Skipping: Not an API project"
        end_step_metrics "16" "skipped"
        return 0
    fi
    
    local validation_issues=0
    local validation_report="${BACKLOG_DIR}/step_16_api_validation.md"
    
    # Create report header
    cat > "$validation_report" << EOF
# Step 16: API Contract Validation

**Status**: In Progress  
**Started**: $(date '+%Y-%m-%d %H:%M:%S')

---

## Overview

Validates that API implementation matches OpenAPI specification.

---

EOF
    
    # Phase 1: Find OpenAPI specification
    print_info "Phase 1: Locating OpenAPI specification..."
    
    local spec_file
    spec_file=$(find_openapi_spec)
    
    if [[ -z "$spec_file" ]]; then
        print_error "No OpenAPI specification found"
        ((validation_issues++))
        echo "❌ **Error**: No OpenAPI specification found" >> "$validation_report"
        
        save_step_summary "16" "API_Validation" "❌ FAIL" "No OpenAPI spec found"
        WORKFLOW_STATUS[step16]="❌ FAIL - No spec"
        end_step_metrics "16" "failed"
        return 1
    fi
    
    print_success "Found OpenAPI spec: $spec_file"
    echo "✅ Found specification: \`$spec_file\`" >> "$validation_report"
    
    # Phase 2: Validate spec syntax
    print_info "Phase 2: Validating OpenAPI spec syntax..."
    
    if ! validate_openapi_spec "$spec_file"; then
        print_error "OpenAPI spec has syntax errors"
        ((validation_issues++))
        echo "❌ **Error**: Spec syntax validation failed" >> "$validation_report"
    else
        print_success "Spec syntax valid"
        echo "✅ Specification syntax valid" >> "$validation_report"
    fi
    
    # Phase 3: Extract endpoints from spec
    print_info "Phase 3: Extracting API endpoints..."
    
    local endpoints
    endpoints=$(extract_endpoints_from_spec "$spec_file")
    
    local endpoint_count
    endpoint_count=$(echo "$endpoints" | wc -l)
    
    print_info "Found $endpoint_count API endpoints"
    echo "" >> "$validation_report"
    echo "## Endpoints Found: $endpoint_count" >> "$validation_report"
    echo "" >> "$validation_report"
    echo "\`\`\`" >> "$validation_report"
    echo "$endpoints" >> "$validation_report"
    echo "\`\`\`" >> "$validation_report"
    
    # Phase 4: Validate endpoints exist in code
    print_info "Phase 4: Validating endpoint implementations..."
    
    local missing_endpoints=0
    
    while IFS= read -r endpoint; do
        if ! validate_endpoint_exists "$endpoint"; then
            print_warning "Missing implementation: $endpoint"
            ((missing_endpoints++))
            ((validation_issues++))
        fi
    done <<< "$endpoints"
    
    if [[ $missing_endpoints -eq 0 ]]; then
        print_success "All endpoints implemented"
        echo "" >> "$validation_report"
        echo "✅ All endpoints have implementations" >> "$validation_report"
    else
        print_error "Found $missing_endpoints missing endpoint implementations"
        echo "" >> "$validation_report"
        echo "❌ **Error**: $missing_endpoints endpoints not implemented" >> "$validation_report"
    fi
    
    # Phase 5: AI-powered contract review (if available)
    if check_copilot_available; then
        print_info "Phase 5: AI-powered contract analysis..."
        
        local ai_analysis
        ai_analysis=$(analyze_api_contract_with_ai "$spec_file" "$endpoints")
        
        echo "" >> "$validation_report"
        echo "## AI Analysis" >> "$validation_report"
        echo "" >> "$validation_report"
        echo "$ai_analysis" >> "$validation_report"
    fi
    
    # Finalize report
    {
        echo ""
        echo "---"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Endpoints**: $endpoint_count"
        echo "- **Missing Implementations**: $missing_endpoints"
        echo "- **Validation Issues**: $validation_issues"
        echo ""
        echo "**Status**: $(if [[ $validation_issues -eq 0 ]]; then echo "✅ PASS"; else echo "❌ FAIL"; fi)"
        echo "**Completed**: $(date '+%Y-%m-%d %H:%M:%S')"
    } >> "$validation_report"
    
    # Save step summary
    if [[ $validation_issues -eq 0 ]]; then
        save_step_summary "16" "API_Validation" "✅ PASS" "$endpoint_count endpoints validated"
        WORKFLOW_STATUS[step16]="✅ PASS"
        end_step_metrics "16" "success"
        print_success "Step 16: API validation passed"
        return 0
    else
        save_step_summary "16" "API_Validation" "❌ FAIL" "$validation_issues issues found"
        WORKFLOW_STATUS[step16]="❌ FAIL"
        end_step_metrics "16" "failed"
        print_error "Step 16: API validation failed"
        return 1
    fi
}

# Helper function: Check if project is API type
is_api_project() {
    local project_kind="${PROJECT_KIND:-unknown}"
    
    case "$project_kind" in
        nodejs_api|python_api|rest_api|graphql_api)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Helper function: Find OpenAPI specification file
find_openapi_spec() {
    # Check common locations
    local spec_locations=(
        "openapi.yaml"
        "openapi.yml"
        "api-spec.yaml"
        "docs/openapi.yaml"
        "spec/openapi.yaml"
    )
    
    for location in "${spec_locations[@]}"; do
        if [[ -f "$PROJECT_ROOT/$location" ]]; then
            echo "$location"
            return 0
        fi
    done
    
    # Search recursively (max depth 3)
    find . -maxdepth 3 -name "openapi.y*ml" -type f 2>/dev/null | head -1
}

# Helper function: Validate OpenAPI spec syntax
validate_openapi_spec() {
    local spec_file="$1"
    
    # Use openapi-generator-cli or swagger-cli if available
    if command -v openapi-generator-cli &> /dev/null; then
        openapi-generator-cli validate -i "$spec_file" &> /dev/null
        return $?
    elif command -v swagger-cli &> /dev/null; then
        swagger-cli validate "$spec_file" &> /dev/null
        return $?
    else
        # Fallback: Basic YAML validation
        yq eval '.' "$spec_file" &> /dev/null
        return $?
    fi
}

# Helper function: Extract endpoints from spec
extract_endpoints_from_spec() {
    local spec_file="$1"
    
    # Extract paths from OpenAPI spec
    yq eval '.paths | keys | .[]' "$spec_file" 2>/dev/null || echo ""
}

# Helper function: Validate endpoint exists in code
validate_endpoint_exists() {
    local endpoint="$1"
    
    # Convert endpoint to regex pattern
    # /users/{id} -> /users/[^/]+
    local pattern="${endpoint//\{[^}]*\}/[^/]+}"
    
    # Search for endpoint in source code
    grep -rE "['\"](GET|POST|PUT|DELETE|PATCH).*$pattern['\"]" src/ 2>/dev/null | grep -v node_modules > /dev/null
    return $?
}

# Helper function: AI-powered contract analysis
analyze_api_contract_with_ai() {
    local spec_file="$1"
    local endpoints="$2"
    
    local prompt_file
    prompt_file=$(mktemp)
    TEMP_FILES+=("$prompt_file")
    
    cat > "$prompt_file" << EOF
You are an API Contract Specialist.

# Task
Analyze the OpenAPI specification and provide recommendations.

# OpenAPI Spec
$(cat "$spec_file")

# Detected Endpoints
$endpoints

# Analysis Request
Provide:
1. **Contract Quality**: Rate the API contract quality (1-10)
2. **Missing Specifications**: Identify undocumented aspects
3. **Best Practices**: Suggest improvements based on RESTful/OpenAPI standards
4. **Security Concerns**: Note any security-related issues

Keep analysis concise (200-300 words).
EOF
    
    # Call AI helper
    ai_call "code_reviewer" "$(cat "$prompt_file")" || echo "AI analysis unavailable"
}

# Export main function for orchestrator
export -f step16_api_validation
```

**Key Elements**:

1. **Header Comment** - Documents purpose, version, part of workflow
2. **Version Constants** - Semantic versioning (MAJOR.MINOR.PATCH)
3. **Module Sourcing** - Load required library dependencies
4. **Main Function** - `stepXX_<action>()` naming convention
5. **Phases** - Break complex logic into numbered phases
6. **Error Handling** - Check conditions, return proper exit codes
7. **Metrics** - Start/end step metrics for performance tracking
8. **Reports** - Generate markdown reports in backlog directory
9. **AI Integration** - Optional AI-powered analysis
10. **Status Updates** - Update workflow status array and save summary

### Step 3: Add Step Metadata

Create metadata for dependency tracking and optimization:

```bash
# File: src/workflow/lib/step_metadata.sh

# Add your step's metadata
register_step_metadata "16" "api_validation" \
    "dependencies:00,01" \
    "outputs:backlog/step_16_*.md" \
    "requires:openapi.yaml" \
    "project_kinds:nodejs_api,python_api" \
    "duration:180" \
    "parallel_safe:true"
```

**Metadata Fields**:
- `dependencies` - Step numbers this depends on (comma-separated)
- `outputs` - File patterns created by this step
- `requires` - Required files/tools (comma-separated)
- `project_kinds` - Relevant project types (empty = all projects)
- `duration` - Expected duration in seconds
- `parallel_safe` - Can run in parallel with other steps?

### Step 4: Integrate with Orchestrator

Add your step to the appropriate orchestrator or main script:

```bash
# Option A: Add to existing orchestrator
# File: src/workflow/orchestrators/quality_orchestrator.sh

run_quality_phase() {
    local phase_status=0
    
    # Existing steps
    run_step 8 "step_08_dependencies" "step8_dependency_check" || ((phase_status++))
    run_step 9 "step_09_code_quality" "step9_code_quality_check" || ((phase_status++))
    
    # NEW: Add your step
    run_step 16 "step_16_api_validation" "step16_api_validation" || ((phase_status++))
    
    return $phase_status
}

# Option B: Call directly from main orchestrator
# File: src/workflow/execute_tests_docs_workflow.sh

# Add to step execution section
if should_run_step 16; then
    source "${STEPS_DIR}/step_16_api_validation.sh"
    step16_api_validation || workflow_failed=true
fi
```

### Step 5: Add Help Text

Document your step in the CLI help:

```bash
# File: src/workflow/execute_tests_docs_workflow.sh

show_step_help() {
    cat << 'EOF'
...
Step 16: API Contract Validation
  - Validates API endpoints match OpenAPI specification
  - Only runs for API projects (nodejs_api, python_api)
  - Checks endpoint implementations, request/response schemas
  - Duration: ~3-5 minutes
...
EOF
}
```

### Step 6: Create Tests

Write unit tests for your step:

```bash
# File: tests/test_step_16_api_validation.sh
#!/bin/bash
set -euo pipefail

# Test setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source the step module
source "$PROJECT_ROOT/src/workflow/steps/step_16_api_validation.sh"
source "$PROJECT_ROOT/src/workflow/lib/colors.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test helper
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    echo "Running: $test_name"
    ((TESTS_RUN++))
    
    if $test_func; then
        echo "  ✅ PASS"
        ((TESTS_PASSED++))
    else
        echo "  ❌ FAIL"
    fi
}

# Test: is_api_project detects nodejs_api
test_is_api_project_nodejs() {
    export PROJECT_KIND="nodejs_api"
    is_api_project
}

# Test: is_api_project rejects non-API projects
test_is_api_project_rejects_non_api() {
    export PROJECT_KIND="static_website"
    ! is_api_project
}

# Run all tests
echo "Step 16 API Validation Tests"
echo "============================="
run_test "is_api_project: detects nodejs_api" test_is_api_project_nodejs
run_test "is_api_project: rejects non-API" test_is_api_project_rejects_non_api

echo ""
echo "Results: $TESTS_PASSED/$TESTS_RUN passed"
[[ $TESTS_PASSED -eq $TESTS_RUN ]]
```

### Step 7: Document Your Step

Update API reference documentation:

```markdown
### Step 16: API Contract Validation

**Module**: `step_16_api_validation.sh`  
**Version**: 1.0.0  
**Purpose**: Validates API endpoints match OpenAPI specification

**Main Function**: `step16_api_validation()`

**Performance**: ~3-5 minutes

**Exit Codes**:
- `0` - Validation passed or skipped
- `1` - Validation failed
```

---

## Common Patterns

### Pattern: File Discovery with Exclusions

```bash
find_project_files() {
    local pattern="$1"
    
    find . -name "$pattern" -type f \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -path "*/vendor/*" \
        2>/dev/null
}
```

### Pattern: Parallel Processing

```bash
parallel_process() {
    local files=("$@")
    local max_jobs=4
    
    for file in "${files[@]}"; do
        process_file "$file" &
        
        if [[ $(jobs -r | wc -l) -ge $max_jobs ]]; then
            wait -n
        fi
    done
    wait
}
```

### Pattern: AI Integration

```bash
analyze_with_ai() {
    local context="$1"
    
    if ! check_copilot_available; then
        return 0
    fi
    
    local prompt="Analyze: $context"
    ai_call "code_reviewer" "$prompt"
}
```

### Pattern: Metrics Tracking

```bash
track_step_metrics() {
    start_step_metrics "16" "api_validation"
    record_metric "endpoints_validated" "$count"
    end_step_metrics "16" "success"
}
```

---

## Troubleshooting

### Issue: Step Not Running

**Check step metadata**:
```bash
grep "step_16" src/workflow/lib/step_metadata.sh
```

**Check project kind**:
```bash
echo "Project kind: $PROJECT_KIND"
```

### Issue: Module Not Found

**Verify path**:
```bash
STEP16_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP16_DIR}/../lib"
ls -la "$WORKFLOW_LIB_DIR"
```

### Issue: Performance Problems

**Add timing**:
```bash
time phase1_logic
time phase2_logic
```

**Optimization strategies**:
1. Cache expensive operations
2. Parallelize independent work
3. Use faster tools (ripgrep, fd)
4. Reduce file I/O

---

## FAQ

**Q: When should I create a new step vs extending an existing one?**

A: Create new step if:
- Logically distinct validation
- Takes > 2 minutes
- Different relevance conditions
- Different AI personas

**Q: Should my module be a step or library?**

A: Make it a **step** if it:
- Generates backlog report
- Has distinct validation purpose
- Should appear in progress

Make it a **library** if it:
- Provides reusable utilities
- Used by multiple steps
- Doesn't generate reports

**Q: How do I handle optional dependencies?**

A: Check availability and provide fallbacks:
```bash
if command -v advanced_tool &> /dev/null; then
    use_advanced_tool
else
    use_fallback_tool
fi
```

**Q: How do I make my step skippable?**

A: Check project kind or changes:
```bash
if [[ "$PROJECT_KIND" != "expected_kind" ]]; then
    print_info "Skipping: Not relevant"
    return 0
fi
```

**Q: How do I debug module issues?**

A: Use verbose mode:
```bash
VERBOSE=true ./execute_tests_docs_workflow.sh --steps 16

# Add debug logging
if [[ "${VERBOSE:-false}" == "true" ]]; then
    echo "[DEBUG] $var" >&2
fi
```

---

## Resources

### Internal Documentation
- **API Reference**: `docs/reference/API_STEP_MODULES.md`
- **Library Modules**: `docs/reference/API_LIBRARY_MODULES.md`
- **Orchestrators**: `docs/reference/API_ORCHESTRATORS.md`
- **Data Flow**: `docs/reference/DATA_FLOW.md`
- **Cookbook**: `docs/COOKBOOK.md`

### Code Examples
- **Simple Step**: `src/workflow/steps/step_00_analyze.sh`
- **Complex Step**: `src/workflow/steps/step_01_documentation.sh`
- **Library Module**: `src/workflow/lib/ai_helpers.sh`
- **Orchestrator**: `src/workflow/orchestrators/validation_orchestrator.sh`

### Testing
- **Test Framework**: `tests/test_step_00_analyze.sh`
- **Library Tests**: `src/workflow/lib/test_*.sh`

---

## Checklist for New Modules

### Step Modules
- [ ] Module header with purpose, version
- [ ] Main function: `stepXX_<action>()`
- [ ] Error handling (return codes 0/1)
- [ ] Metrics tracking
- [ ] Report generation
- [ ] AI integration (if applicable)
- [ ] Status updates
- [ ] Help text added
- [ ] Step metadata registered
- [ ] Unit tests created
- [ ] Documentation updated

### Library Modules
- [ ] Module header with API docs
- [ ] Public functions exported
- [ ] Private functions prefixed `_`
- [ ] Input validation
- [ ] Error messages to stderr
- [ ] Return codes documented
- [ ] Usage examples in comments
- [ ] No side effects
- [ ] Tool availability checks
- [ ] Fallback implementations
- [ ] Unit tests (80%+ coverage)

### Orchestrators
- [ ] Module header
- [ ] Main function: `run_<phase>_phase()`
- [ ] Phase metrics tracking
- [ ] Step execution with error handling
- [ ] Parallel execution support
- [ ] Phase summary output
- [ ] Integration with main orchestrator
- [ ] Documentation updated

---

## Contributing

When contributing new modules:

1. **Discuss First** - Open issue to discuss
2. **Follow Patterns** - Use existing modules as templates
3. **Write Tests** - Include unit and integration tests
4. **Document** - Update all relevant docs
5. **Submit PR** - With clear description

See `docs/guides/developer/contributing.md` for full guidelines.

---

## Quick Reference

### Module File Structure

```
src/workflow/
├── steps/
│   ├── step_XX_name.sh          # Main step file
│   └── step_XX_lib/             # Submodules (if complex)
│       ├── cache.sh
│       ├── validation.sh
│       └── ai_integration.sh
├── lib/
│   └── module_name.sh           # Library module
└── orchestrators/
    └── phase_orchestrator.sh    # Orchestrator
```

### Essential Functions

```bash
# Step module
stepXX_action() {
    print_step "XX" "Step Name"
    start_step_metrics "XX" "action"
    # ... logic
    end_step_metrics "XX" "success"
}

# Library module
public_function() {
    local input="$1"
    # Validate
    if [[ -z "$input" ]]; then
        return 1
    fi
    # Process
    echo "$result"
}

_private_helper() {
    # Internal use only
    echo "$result"
}

# Orchestrator
run_phase() {
    start_phase_metrics "phase"
    run_step XX "step_XX" "stepXX_func"
    end_phase_metrics "phase" "$status"
}
```

### Common Commands

```bash
# Create new step
cp src/workflow/steps/step_00_analyze.sh src/workflow/steps/step_XX_name.sh

# Test module
bash tests/test_step_XX_name.sh

# Run single step
./execute_tests_docs_workflow.sh --steps XX --auto

# Debug step
VERBOSE=true ./execute_tests_docs_workflow.sh --steps XX
```

---

**Document Version**: 1.0.0  
**Workflow Version**: v3.0.0  
**Last Updated**: 2026-01-31

**Contributors**: Marcelo Pereira Barbosa (@mpbarbosa)
