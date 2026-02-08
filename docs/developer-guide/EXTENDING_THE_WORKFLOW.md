# Extending the Workflow - Developer Guide

**Version**: v4.0.0  
**Last Updated**: 2026-02-08  
**Audience**: Developers extending or customizing the workflow system

> 🚀 **NEW in v4.0.0**: Configuration-driven step execution! Use descriptive step names instead of numbers. See [Migration Guide](../MIGRATION_GUIDE_v4.0.md) for details.

## Table of Contents

1. [Overview](#overview)
2. [Adding a New Step](#adding-a-new-step)
3. [Adding a New Library Module](#adding-a-new-library-module)
4. [Creating Custom AI Personas](#creating-custom-ai-personas)
5. [Extending Configuration](#extending-configuration)
6. [Testing Your Extensions](#testing-your-extensions)
7. [Best Practices](#best-practices)

---

## Overview

The AI Workflow Automation system is designed for extensibility. This guide covers the most common extension points:

- **New Workflow Steps**: Add custom validation or processing steps
- **Library Modules**: Create reusable functionality
- **AI Personas**: Define specialized AI behaviors
- **Configuration**: Extend project configuration options

### Architecture Quick Reference

```
src/workflow/
├── execute_tests_docs_workflow.sh    # Main orchestrator
├── lib/                               # Reusable library modules (73 files)
├── steps/                             # Workflow step implementations (20+ files)
├── orchestrators/                     # Phase orchestrators (4 files)
└── .workflow_core/config/            # Submodule: shared configuration

.workflow_core/config/
├── ai_helpers.yaml                   # AI prompt templates (762 lines)
├── ai_prompts_project_kinds.yaml    # Project-specific AI prompts
├── paths.yaml                        # Path configuration
├── project_kinds.yaml                # Project type definitions
└── model_selection_rules.yaml        # AI model selection rules

.workflow-config.yaml                 # Project configuration (includes step definitions in v4.0+)
```

---

## Adding a New Step

Steps are the core building blocks of the workflow pipeline. Each step performs a specific validation or enhancement task.

### Step Structure (v4.0.0)

In v4.0.0, steps use **descriptive names** instead of numbers. Create a new file in `src/workflow/steps/` following this template:

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Custom Validation Step
# Purpose: [Clear description of what this step does]
# Dependencies: [List required modules and previous steps]
# AI Persona: [If using AI, specify which persona]
# Version: 1.0.0
################################################################################

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"
source "${SCRIPT_DIR}/../lib/validation.sh"

# Step constants
readonly STEP_NAME="custom_validation"
readonly STEP_DESCRIPTION="Custom validation logic"
readonly STEP_VERSION="1.0.0"

# ==============================================================================
# VALIDATION
# ==============================================================================

# Validate prerequisites for this step
# Returns: 0 if valid, 1 if invalid
validate_step() {
    local step_num="${1:-}"
    
    print_info "Validating Step ${step_num} prerequisites..."
    
    # Check required files exist
    if [[ ! -f "${PROJECT_ROOT}/required-file.txt" ]]; then
        print_error "Required file not found"
        return 1
    fi
    
    # Check required commands available
    if ! command -v required-command &> /dev/null; then
        print_error "Required command not found: required-command"
        return 1
    fi
    
    print_success "Step ${step_num} validation passed"
    return 0
}

# ==============================================================================
# EXECUTION
# ==============================================================================

# Execute the step logic
# Returns: 0 on success, 1 on failure
execute_step() {
    local step_num="${1:-}"
    local output_file="${2:-}"
    
    print_section "Step ${step_num}: ${STEP_DESCRIPTION}"
    
    # Step implementation
    local start_time
    start_time=$(date +%s)
    
    # Your step logic here
    print_info "Processing..."
    
    # Example: Process files
    local processed_count=0
    for file in "${PROJECT_ROOT}"/*.md; do
        if [[ -f "$file" ]]; then
            process_file "$file" || return 1
            ((processed_count++))
        fi
    done
    
    # Write results to output file
    if [[ -n "$output_file" ]]; then
        {
            echo "# Step ${step_num} Results"
            echo ""
            echo "**Processed**: ${processed_count} files"
            echo "**Status**: ✅ Success"
        } > "$output_file"
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Step ${step_num} completed in ${duration}s"
    return 0
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Process individual file
process_file() {
    local file="$1"
    
    print_info "Processing: $(basename "$file")"
    
    # Your processing logic
    
    return 0
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

# Allow step to be run independently
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set up environment
    PROJECT_ROOT="${PROJECT_ROOT:-.}"
    
    # Validate
    validate_step "${STEP_NUMBER}" || exit 1
    
    # Execute
    execute_step "${STEP_NUMBER}" "${1:-}" || exit 1
fi
```

### Step Integration (v4.0.0 - Configuration-Driven)

With v4.0.0, step integration is done through YAML configuration instead of code changes.

1. **Add to Configuration** (`.workflow-config.yaml` or `.workflow_core/config/`):

```yaml
workflow:
  steps:
    # ... existing steps ...
    
    - name: custom_validation
      module: custom_validation.sh
      function: custom_validation
      enabled: true
      dependencies: 
        - pre_analysis
        - documentation_updates
      description: "Custom validation logic"
      category: validation
      ai_persona: "code_reviewer"  # optional
      stage: 2  # 1=core, 2=extended, 3=finalization
```

2. **Step Registry Auto-Loading**:

The workflow automatically loads steps from configuration via `step_registry.sh`:

```bash
# No manual code changes needed!
# Step registry automatically:
# - Loads step definitions from YAML
# - Resolves dependencies (topological sort)
# - Validates configuration
# - Provides step lookup by name or legacy index
```

3. **Running Your Step**:

```bash
# By name (v4.0 preferred)
./execute_tests_docs_workflow.sh --steps custom_validation

# By name with dependencies
./execute_tests_docs_workflow.sh --steps pre_analysis,custom_validation

# Mixed with other steps
./execute_tests_docs_workflow.sh --steps documentation_updates,custom_validation,test_execution
```

4. **Legacy Integration** (if not using YAML configuration):

If you're in legacy mode (no `workflow:` section in config), you still need manual integration:

```bash
# In src/workflow/lib/dependency_graph.sh
case "${step_id}" in
    "custom_validation")
        echo "pre_analysis documentation_updates"
        ;;
esac
```

### Step Best Practices

1. **Single Responsibility**: Each step should do one thing well
2. **Idempotency**: Steps should be safe to run multiple times
3. **Validation First**: Always validate prerequisites before execution
4. **Error Handling**: Return appropriate exit codes and provide clear error messages
5. **Metrics**: Track execution time and success/failure
6. **Output**: Write structured output to the specified output file
7. **Documentation**: Include clear comments and purpose statements

---

## Adding a New Library Module

Library modules provide reusable functionality across steps and the main orchestrator.

### Module Structure

Create a new file in `src/workflow/lib/` following this template:

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Module Name
# Purpose: [Clear description of module purpose]
# Dependencies: [List required modules]
# Version: 1.0.2
################################################################################

# Module constants
readonly MODULE_NAME="your_module"
readonly MODULE_VERSION="1.0.0"

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Function to do something useful
# Usage: do_something <param1> <param2>
# Parameters:
#   $1 - param1: Description of first parameter
#   $2 - param2: Description of second parameter
# Returns: 0 on success, 1 on failure
# Example:
#   do_something "value1" "value2"
do_something() {
    local param1="${1:-}"
    local param2="${2:-}"
    
    # Validate inputs
    if [[ -z "$param1" ]]; then
        echo "ERROR: param1 is required" >&2
        return 1
    fi
    
    # Implementation
    local result
    result=$(process_data "$param1" "$param2")
    
    # Output result
    echo "$result"
    return 0
}

# Another public function
# Usage: check_status
# Returns: 0 if status is good, 1 otherwise
check_status() {
    # Implementation
    if is_valid_state; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# PRIVATE HELPERS
# ==============================================================================

# Private function (not part of public API)
# These should be used only within this module
process_data() {
    local data="$1"
    local option="${2:-default}"
    
    # Processing logic
    echo "processed: $data ($option)"
}

# Another private helper
is_valid_state() {
    # Validation logic
    return 0
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Module initialization (runs when sourced)
# Keep this minimal - most setup should happen in functions
_init_module() {
    # Set up any required state
    :
}

# Run initialization
_init_module
```

### Module Best Practices

1. **Clear API**: Separate public functions from private helpers
2. **Documentation**: Document every public function with usage, parameters, and examples
3. **Error Handling**: Validate inputs and return appropriate status codes
4. **No Side Effects**: Avoid global state modifications unless necessary
5. **Testability**: Design functions to be easily testable
6. **Dependencies**: Minimize dependencies on other modules
7. **Naming**: Use verb_noun pattern (e.g., `validate_config`, `process_files`)

### Testing Your Module

Create a test file in `tests/lib/`:

```bash
#!/usr/bin/env bash

# Test your_module.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../src/workflow/lib/your_module.sh"
source "${SCRIPT_DIR}/../test_helpers.sh"

test_do_something() {
    local result
    result=$(do_something "test" "value")
    
    assert_equals "processed: test (value)" "$result"
}

test_do_something_missing_param() {
    local result
    result=$(do_something "" "value" 2>&1) || true
    
    assert_contains "ERROR: param1 is required" "$result"
}

test_check_status() {
    assert_success check_status
}

# Run tests
run_tests \
    test_do_something \
    test_do_something_missing_param \
    test_check_status
```

---

## Creating Custom AI Personas

AI personas define how the workflow interacts with AI for specific tasks.

### Adding a New Persona

1. **Define in Configuration** (`.workflow_core/config/ai_helpers.yaml`):

```yaml
# Add to the ai_helpers section
ai_helpers:
  personas:
    your_persona_name:
      role: "You are a [role description]"
      capabilities:
        - "Capability 1"
        - "Capability 2"
        - "Capability 3"
      task_template: |
        ## Task
        {task_description}
        
        ## Context
        {context}
        
        ## Requirements
        {requirements}
      
      standards:
        - "Standard 1"
        - "Standard 2"
      
      output_format: |
        Your output should include:
        1. Summary
        2. Details
        3. Recommendations
```

2. **Use in Your Step**:

```bash
# Source AI helpers
source "${SCRIPT_DIR}/../lib/ai_helpers.sh"

# Call AI with your persona
call_ai_persona "your_persona_name" \
    "Analyze this code for security issues" \
    "${output_file}" || return 1
```

### Project-Specific Personas

For project-kind specific behaviors, add to `ai_prompts_project_kinds.yaml`:

```yaml
shell_script_automation:
  your_persona_name:
    additional_context: |
      For shell scripts, also consider:
      - ShellCheck compliance
      - POSIX compatibility
      - Error handling patterns
    
    quality_standards:
      - "Use set -euo pipefail"
      - "Quote all variables"
      - "Check command exit codes"
```

### Persona Best Practices

1. **Clear Role**: Define specific expertise and perspective
2. **Focused Capabilities**: List 3-5 key capabilities
3. **Structured Output**: Specify expected output format
4. **Quality Standards**: Include measurable quality criteria
5. **Context-Aware**: Provide relevant context based on project type

---

## Extending Configuration

The workflow uses YAML configuration files for customization.

### Adding Configuration Options

1. **Define Schema** (in `.workflow-config.yaml`):

```yaml
# Add to your project's .workflow-config.yaml
custom_options:
  your_feature:
    enabled: true
    option1: "value1"
    option2: 
      - "item1"
      - "item2"
```

2. **Access in Code**:

```bash
# Source configuration module
source "${SCRIPT_DIR}/../lib/tech_stack.sh"

# Read configuration
local feature_enabled
feature_enabled=$(get_config_value "custom_options.your_feature.enabled" "false")

if [[ "$feature_enabled" == "true" ]]; then
    # Feature is enabled
    local option1
    option1=$(get_config_value "custom_options.your_feature.option1" "")
fi
```

### Configuration Best Practices

1. **Defaults**: Always provide sensible defaults
2. **Validation**: Validate configuration values
3. **Documentation**: Document all options
4. **Backward Compatibility**: Maintain compatibility with older configs

---

## Testing Your Extensions

### Unit Testing

Test individual functions in isolation:

```bash
#!/usr/bin/env bash

test_my_function() {
    local result
    result=$(my_function "input")
    
    assert_equals "expected" "$result"
    assert_success "Function should succeed"
}
```

### Integration Testing

Test step execution end-to-end:

```bash
#!/usr/bin/env bash

test_step_execution() {
    local output_file="/tmp/test_output.md"
    
    # Run step
    execute_step "99" "$output_file"
    
    # Verify output
    assert_file_exists "$output_file"
    assert_file_contains "$output_file" "Success"
}
```

### Running Tests

```bash
# Run all tests
./tests/run_all_tests.sh

# Run specific test file
./tests/lib/test_your_module.sh

# Run with verbose output
VERBOSE=1 ./tests/run_all_tests.sh
```

---

## Best Practices

### Code Style

1. **Bash Standards**:
   - Use `#!/usr/bin/env bash` shebang
   - Set `-euo pipefail` for strict error handling
   - Quote all variable expansions: `"${var}"`
   - Use `[[ ]]` for conditionals (not `[ ]`)

2. **Function Design**:
   - Clear, descriptive names (verb_noun pattern)
   - Single responsibility principle
   - Document parameters and return values
   - Return status codes (0=success, 1+=error)

3. **Error Handling**:
   - Always check command exit codes
   - Provide meaningful error messages
   - Clean up resources on failure
   - Use `trap` for cleanup handlers

4. **Comments**:
   - Module-level header with purpose and dependencies
   - Function-level documentation
   - Inline comments for complex logic only

### Performance

1. **Smart Execution**: Respect change detection and skip unnecessary work
2. **Parallel Safety**: Avoid shared state when possible
3. **Resource Cleanup**: Always clean up temporary files and processes
4. **Caching**: Use AI response caching for repeated queries

### Documentation

1. **Inline Documentation**: Clear comments in code
2. **API Documentation**: Document all public functions
3. **Usage Examples**: Provide working examples
4. **Update References**: Keep PROJECT_REFERENCE.md current

### Version Control

1. **Atomic Commits**: One logical change per commit
2. **Clear Messages**: Descriptive commit messages
3. **Feature Branches**: Develop in branches, not main
4. **Pull Requests**: Use PRs for code review

---

## Examples

### Example: Adding a Security Audit Step (v4.0.0)

**Step 1: Create the step file** (`src/workflow/steps/security_audit.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Security Audit Step
# Purpose: Scan codebase for security vulnerabilities
# Dependencies: consistency_analysis
# Version: 1.0.0
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/ai_helpers.sh"
source "${SCRIPT_DIR}/../lib/colors.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

readonly STEP_NAME="security_audit"
readonly STEP_VERSION="1.0.0"

# Main execution function (called by orchestrator)
security_audit() {
    local output_file="${1:-}"
    
    print_section "Security Audit"
    
    # Run security checks
    local issues_found=0
    
    # Check shell scripts with shellcheck
    while IFS= read -r script; do
        if ! shellcheck "$script" 2>/dev/null; then
            ((issues_found++))
        fi
    done < <(find "${PROJECT_ROOT}" -name "*.sh" -type f)
    
    # AI-powered security review
    call_ai_persona "security_auditor" \
        "Review this codebase for security vulnerabilities" \
        "${output_file}" || return 1
    
    if [[ $issues_found -gt 0 ]]; then
        print_warning "Found ${issues_found} potential security issues"
    else
        print_success "No security issues detected"
    fi
    
    return 0
}

# Allow independent execution for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    security_audit "${1:-/tmp/security_audit.md}" || exit 1
fi
```

**Step 2: Add to configuration** (`.workflow-config.yaml`):

```yaml
workflow:
  steps:
    # ... existing steps ...
    
    - name: security_audit
      module: security_audit.sh
      function: security_audit
      enabled: true
      dependencies: 
        - consistency_analysis
      description: "Scan codebase for security vulnerabilities"
      category: quality
      ai_persona: "security_auditor"
      stage: 2
```

**Step 3: Run your step**:

```bash
# Test independently
./src/workflow/steps/security_audit.sh /tmp/test_output.md

# Run in workflow
./execute_tests_docs_workflow.sh --steps security_audit

# Run with dependencies
./execute_tests_docs_workflow.sh --steps pre_analysis,security_audit
```

### Example: Custom Validation Module (v4.0.0-compatible)

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Custom Validation Module
# Purpose: Project-specific validation rules
# Version: 1.0.0
################################################################################

# Validate API endpoints structure
# Returns: 0 on success, 1 on failure
validate_api_endpoints() {
    local api_dir="${1:-./src/api}"
    
    print_info "Validating API endpoints..."
    
    # Check for required files
    local required_files=("routes.js" "controllers.js" "middleware.js")
    for file in "${required_files[@]}"; do
        if [[ ! -f "${api_dir}/${file}" ]]; then
            print_error "Missing required file: ${file}"
            return 1
        fi
    done
    
    # Validate API documentation
    if [[ ! -f "${api_dir}/API.md" ]]; then
        print_error "Missing API documentation"
        return 1
    fi
    
    print_success "API validation passed"
    return 0
}

# Check test coverage meets minimum threshold
# Returns: 0 if coverage >= threshold, 1 otherwise
validate_test_coverage() {
    local min_coverage="${1:-80}"
    
    print_info "Checking test coverage (minimum: ${min_coverage}%)..."
    
    # Run coverage analysis (example for Node.js)
    local coverage
    if command -v npm &>/dev/null && [[ -f "package.json" ]]; then
        coverage=$(npm run test:coverage 2>&1 | grep -oP '\d+(?=%)' | head -1)
    else
        print_warning "Test coverage check skipped (npm not available)"
        return 0
    fi
    
    if [[ -z "$coverage" ]]; then
        print_warning "Could not determine test coverage"
        return 0
    fi
    
    if [[ ${coverage} -lt ${min_coverage} ]]; then
        print_error "Test coverage ${coverage}% below minimum ${min_coverage}%"
        return 1
    fi
    
    print_success "Test coverage: ${coverage}%"
    return 0
}
```

---

## Getting Help

- **Documentation**: Check `docs/` directory for guides
- **Examples**: See `examples/` for real-world usage
- **Tests**: Review `tests/` for testing patterns
- **Issues**: Report bugs on GitHub
- **Community**: Join discussions in GitHub Discussions

---

## Next Steps

After extending the workflow:

1. ✅ Write tests for your extensions
2. ✅ Update documentation (add to this guide if creating common patterns)
3. ✅ Run the workflow on a test project
4. ✅ Test with `--dry-run` first to validate configuration
5. ✅ Submit a pull request (if contributing back to the project)
6. ✅ Update PROJECT_REFERENCE.md if adding major features

**Related Documentation**:
- [Migration Guide v4.0](../MIGRATION_GUIDE_v4.0.md) - Upgrade from v3.x to v4.0
- [Module API Reference](../MODULE_API_REFERENCE.md) - Complete API documentation
- [Architecture Overview](../architecture/SYSTEM_ARCHITECTURE.md) - System design
- [Testing Guide](../testing/TESTING_STRATEGY.md) - Testing best practices
- [Contributing Guide](../../CONTRIBUTING.md) - Contribution guidelines
