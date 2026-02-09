# API Quick Reference Guide

## Overview

This guide provides quick access to the most commonly used functions across all AI Workflow Automation modules. For complete API documentation, see `docs/reference/api/COMPLETE_API_REFERENCE.md`.

## Core Modules

### AI Helpers (`ai_helpers.sh`)

**Call AI with specific persona:**
```bash
source lib/ai_helpers.sh

# Call AI with documentation specialist persona
ai_call "documentation_specialist" "Analyze this file: $file" "$output_file"

# Call with code review persona
ai_call "code_reviewer" "Review this code: $code" "$output_file"

# Check if Copilot is available
if check_copilot_available; then
    echo "AI features enabled"
fi

# Get available AI personas
list_ai_personas
```

**Common Personas:**
- `documentation_specialist` - Documentation analysis and updates
- `code_reviewer` - Code review and quality analysis
- `test_engineer` - Test generation and review
- `ux_designer` - UX/accessibility analysis
- `technical_writer` - Technical documentation creation

### Configuration Management (`config.sh`)

**Load and access configuration:**
```bash
source lib/config.sh

# Load project configuration
load_project_config

# Get configuration value
project_name=$(get_config "project.name")
test_command=$(get_config "testing.test_command")
smart_exec=$(get_config "workflow.smart_execution" "true")  # with default

# Check if feature is enabled
if is_feature_enabled "workflow.smart_execution"; then
    echo "Smart execution enabled"
fi

# Get project kind
kind=$(get_project_kind)  # Returns: nodejs_api, python_app, etc.

# Validate configuration
validate_config || { echo "Invalid config"; exit 1; }
```

### Change Detection (`change_detection.sh`)

**Analyze changes and determine impact:**
```bash
source lib/change_detection.sh

# Initialize change detection
init_change_detection

# Get list of changed files
changed_files=$(get_changed_files)

# Detect change scope
scope=$(detect_change_scope)  # Returns: docs_only, code_only, mixed, none

# Check if specific change type
if has_documentation_changes; then
    echo "Documentation changed"
fi

if has_code_changes; then
    echo "Code changed"
fi

if has_test_changes; then
    echo "Tests changed"
fi

# Get files by type
doc_files=$(get_changed_documentation_files)
code_files=$(get_changed_code_files)
test_files=$(get_changed_test_files)
```

### Workflow Optimization (`workflow_optimization.sh`)

**Smart execution and step skipping:**
```bash
source lib/workflow_optimization.sh

# Initialize optimization
init_workflow_optimization

# Check if step should run
if should_run_step "test_execution"; then
    echo "Running test execution"
    execute_step_test_execution
else
    echo "Skipping test execution (not needed)"
fi

# Get recommended steps to run
recommended_steps=$(get_recommended_steps)

# Calculate optimization savings
savings=$(calculate_time_savings)
echo "Time savings: ${savings}%"
```

### Metrics Collection (`metrics.sh`)

**Track workflow performance:**
```bash
source lib/metrics.sh

# Initialize metrics
init_metrics

# Record step start
record_step_start "documentation_updates"

# Record step completion
record_step_success "documentation_updates"
# or
record_step_failure "documentation_updates" "Error message"

# Record custom metric
record_metric "files_processed" 42
record_metric "test_coverage" 87.5

# Finalize and save metrics
finalize_metrics

# Get metric value
coverage=$(get_metric "test_coverage")
```

### Session Management (`session_manager.sh`)

**Manage workflow sessions and checkpoints:**
```bash
source lib/session_manager.sh

# Create new session
session_id=$(create_session)

# Save checkpoint
save_checkpoint "step_05" "data_to_save"

# Restore checkpoint
checkpoint_data=$(restore_checkpoint "step_05")

# Get last completed step
last_step=$(get_last_completed_step)

# Check if resuming
if is_resuming; then
    echo "Resuming from checkpoint"
fi

# Clean up old sessions
cleanup_old_sessions 30  # Keep last 30 days
```

## Utility Modules

### Logging and Output (`utils.sh`)

**Consistent logging and output:**
```bash
source lib/utils.sh

# Logging functions
log_info "Processing file: $filename"
log_success "Operation completed"
log_warning "Deprecated function used"
log_error "Failed to process file"

# Print functions
print_header "Step 1: Documentation Updates"
print_section "Analyzing files"
print_step "1" "Process file: $file"

# Progress indication
show_progress 50 100 "Processing files"

# Confirmation
if confirm "Continue with operation?"; then
    echo "User confirmed"
fi
```

### File Operations (`file_operations.sh`)

**Safe file manipulation:**
```bash
source lib/file_operations.sh

# Backup file before modification
backup_file "important.txt"

# Safe file write
safe_write_file "$content" "output.txt"

# Check if file exists and readable
if is_readable_file "input.txt"; then
    content=$(cat "input.txt")
fi

# Create directory if not exists
ensure_directory_exists "logs/workflow"

# Get file hash
hash=$(get_file_hash "file.txt")

# Atomic file operation
atomic_file_operation "source.txt" "dest.txt" "Moving file"
```

### Edit Operations (`edit_operations.sh`)

**Structured file editing:**
```bash
source lib/edit_operations.sh

# Apply edit to file
apply_edit "$file" "$line_number" "$old_content" "$new_content"

# Batch edit operations
batch_edit_start
batch_edit_add "$file1" 10 "old" "new"
batch_edit_add "$file2" 20 "foo" "bar"
batch_edit_commit

# Find and replace
find_and_replace "$pattern" "$replacement" "$file"

# Validate edit
if validate_edit "$file" "$expected_content"; then
    echo "Edit successful"
fi
```

### Validation (`validation.sh`)

**Input and data validation:**
```bash
source lib/validation.sh

# Validate file exists
validate_file_exists "config.yaml" || exit 1

# Validate directory
validate_directory_exists "src" || exit 1

# Validate not empty
validate_not_empty "$variable" "Variable name" || exit 1

# Validate numeric
validate_numeric "$count" "Count" || exit 1

# Validate in range
validate_in_range "$coverage" 0 100 "Coverage" || exit 1

# Validate pattern
validate_pattern "$email" "^[^@]+@[^@]+\.[^@]+$" "Email" || exit 1

# Validate YAML file
validate_yaml_file "config.yaml" || exit 1

# Validate JSON file
validate_json_file "data.json" || exit 1
```

## Step Modules

### Documentation Updates (`step_01_documentation.sh`)

**Update documentation with AI:**
```bash
source steps/step_01_documentation.sh

# Execute documentation step
execute_step_documentation_updates

# Validate prerequisites
validate_step_documentation_updates || exit 1

# Get step info
step_name=$(get_step_name)
step_description=$(get_step_description)
dependencies=$(get_step_dependencies)
```

### Test Review (`step_06_test_review.sh`)

**Analyze test coverage:**
```bash
source steps/step_06_test_review.sh

# Execute test review step
execute_step_test_review

# Get coverage report
coverage_report=$(get_coverage_report)

# Check coverage threshold
if check_coverage_threshold; then
    echo "Coverage meets threshold"
fi

# Get missing test files
missing_tests=$(get_missing_test_files)
```

### Test Generation (`step_07_test_gen.sh`)

**Generate tests with AI:**
```bash
source steps/step_07_test_gen.sh

# Execute test generation step
execute_step_test_generation

# Generate tests for file
generate_tests_for_file "$source_file"

# Validate generated tests
validate_generated_tests "$test_file"
```

### Git Finalization (`step_12_git.sh`)

**Git operations and finalization:**
```bash
source steps/step_12_git.sh

# Execute git finalization
execute_step_git_finalization

# Stage workflow artifacts
stage_workflow_artifacts

# Create workflow commit
create_workflow_commit "message"

# Check if tree is clean
if is_git_tree_clean; then
    echo "No changes to commit"
fi
```

## AI and Caching

### AI Cache (`ai_cache.sh`)

**Manage AI response cache:**
```bash
source lib/ai_cache.sh

# Initialize cache
init_ai_cache

# Check cache
if has_cached_response "$prompt"; then
    response=$(get_cached_response "$prompt")
    echo "Using cached response"
else
    response=$(call_ai "$prompt")
    cache_response "$prompt" "$response"
fi

# Clear expired entries
cleanup_ai_cache

# Get cache statistics
stats=$(get_cache_stats)
echo "Cache hit rate: ${stats[hit_rate]}%"

# Clear entire cache
clear_ai_cache
```

### AI Prompt Builder (`ai_prompt_builder.sh`)

**Build structured AI prompts:**
```bash
source lib/ai_prompt_builder.sh

# Build prompt from template
prompt=$(build_prompt "documentation_analysis" \
    "file" "$filename" \
    "content" "$file_content" \
    "language" "javascript")

# Add context to prompt
prompt=$(add_context_to_prompt "$prompt" \
    "project_kind" "$project_kind" \
    "tech_stack" "$tech_stack")

# Build test generation prompt
test_prompt=$(build_test_generation_prompt \
    "$source_file" \
    "$test_framework" \
    "$coverage_threshold")
```

## Git Operations

### Git Automation (`git_automation.sh`)

**Automated git operations:**
```bash
source lib/git_automation.sh

# Initialize git operations
init_git_operations

# Check repository status
if is_git_repository; then
    echo "In git repository"
fi

# Get current branch
branch=$(get_current_branch)

# Check if branch is protected
if is_protected_branch "$branch"; then
    echo "Cannot commit to protected branch"
fi

# Stage files
stage_files "*.md" "*.txt"

# Create commit
create_commit "chore: update documentation" || exit 1

# Get last commit info
commit_hash=$(get_last_commit_hash)
commit_message=$(get_last_commit_message)

# Check for uncommitted changes
if has_uncommitted_changes; then
    echo "Working tree has changes"
fi
```

### Git Cache (`git_cache.sh`)

**Cache git operations:**
```bash
source lib/git_cache.sh

# Get cached diff
diff=$(get_cached_diff)

# Get cached file list
files=$(get_cached_file_list)

# Get cached commit history
history=$(get_cached_commit_history 10)  # Last 10 commits

# Invalidate cache
invalidate_git_cache
```

## Performance and Optimization

### ML Optimization (`ml_optimization.sh`)

**Machine learning predictions:**
```bash
source lib/ml_optimization.sh

# Check if ML is available
if is_ml_optimization_available; then
    echo "ML optimization enabled"
fi

# Get predicted step duration
duration=$(predict_step_duration "test_execution")
echo "Estimated duration: ${duration}s"

# Get optimization recommendations
recommendations=$(get_optimization_recommendations)

# Train ML model with current run
train_ml_model "$metrics_file"

# Get ML statistics
stats=$(get_ml_stats)
echo "Prediction accuracy: ${stats[accuracy]}%"
```

### Multi-Stage Pipeline (`multi_stage_pipeline.sh`)

**Progressive validation:**
```bash
source lib/multi_stage_pipeline.sh

# Initialize pipeline
init_multi_stage_pipeline

# Get current stage
stage=$(get_current_stage)  # Returns: 1, 2, or 3

# Check if should proceed to next stage
if should_proceed_to_stage 2; then
    echo "Proceeding to stage 2"
fi

# Get stage steps
stage_steps=$(get_stage_steps 1)

# Record stage completion
record_stage_completion 1 "success"
```

## Documentation Tools

### Auto Documentation (`auto_documentation.sh`)

**Generate documentation automatically:**
```bash
source lib/auto_documentation.sh

# Generate API documentation
generate_api_docs "src/lib" "docs/api"

# Generate changelog
generate_changelog "$version" "CHANGELOG.md"

# Update documentation index
update_documentation_index "docs"

# Generate module inventory
generate_module_inventory "src" "docs/modules.md"

# Extract function documentation
extract_function_docs "$script_file" "docs/reference/api/$module.md"
```

### Changelog Generator (`changelog_generator.sh`)

**Generate changelogs from commits:**
```bash
source lib/changelog_generator.sh

# Generate changelog for version
generate_changelog_for_version "2.4.0" "CHANGELOG.md"

# Get changes since last version
changes=$(get_changes_since_version "2.3.0")

# Format commit as changelog entry
entry=$(format_changelog_entry "$commit_hash")

# Group changes by type
feat_changes=$(get_changes_by_type "feat")
fix_changes=$(get_changes_by_type "fix")
```

## Testing Utilities

### Code Example Tester (`code_example_tester.sh`)

**Validate code examples:**
```bash
source lib/code_example_tester.sh

# Test code example
test_code_example "$example_code" "javascript" || exit 1

# Extract and test examples from markdown
test_examples_in_markdown "README.md"

# Validate example syntax
validate_example_syntax "$code" "$language"
```

## Health and Diagnostics

### Health Check (`health_check.sh`)

**System health validation:**
```bash
source lib/health_check.sh

# Run full health check
run_health_check || exit 1

# Check specific dependency
check_dependency "git" "2.0" || exit 1
check_dependency "node" "16.0" || exit 1

# Check filesystem permissions
check_filesystem_permissions || exit 1

# Check configuration
check_configuration || exit 1

# Get health status
status=$(get_health_status)
echo "System status: $status"
```

### Dashboard (`dashboard.sh`)

**Metrics visualization:**
```bash
source lib/dashboard.sh

# Show metrics dashboard
show_metrics_dashboard

# Display workflow summary
display_workflow_summary

# Show performance comparison
show_performance_comparison

# Export metrics report
export_metrics_report "report.html"
```

## Common Patterns

### Pattern 1: Standard Step Execution

```bash
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"
source "$(dirname "$0")/../lib/metrics.sh"
source "$(dirname "$0")/../lib/config.sh"

execute_step_example() {
    local step_name="example_step"
    
    # Initialize
    record_step_start "$step_name"
    log_info "Starting $step_name"
    
    # Validate prerequisites
    validate_step_prerequisites || {
        record_step_failure "$step_name" "Prerequisites not met"
        return 1
    }
    
    # Execute main logic
    if perform_step_operations; then
        record_step_success "$step_name"
        log_success "$step_name completed"
        return 0
    else
        record_step_failure "$step_name" "Operation failed"
        return 1
    fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    execute_step_example
fi
```

### Pattern 2: AI-Powered Analysis

```bash
source lib/ai_helpers.sh
source lib/ai_prompt_builder.sh
source lib/ai_cache.sh

analyze_with_ai() {
    local input_file="$1"
    local output_file="$2"
    
    # Initialize AI cache
    init_ai_cache
    
    # Build prompt
    local content=$(cat "$input_file")
    local prompt=$(build_prompt "analysis" \
        "file" "$input_file" \
        "content" "$content")
    
    # Check cache
    if has_cached_response "$prompt"; then
        log_info "Using cached AI response"
        get_cached_response "$prompt" > "$output_file"
        return 0
    fi
    
    # Call AI
    if ai_call "documentation_specialist" "$prompt" "$output_file"; then
        cache_response "$prompt" "$(cat "$output_file")"
        log_success "AI analysis completed"
        return 0
    else
        log_error "AI analysis failed"
        return 1
    fi
}
```

### Pattern 3: Safe File Operations

```bash
source lib/file_operations.sh
source lib/edit_operations.sh

safe_update_file() {
    local file="$1"
    local new_content="$2"
    
    # Validate file exists
    validate_file_exists "$file" || return 1
    
    # Backup original
    backup_file "$file"
    
    # Apply changes atomically
    if atomic_file_operation "$file" "$file.tmp" "Updating file"; then
        echo "$new_content" > "$file.tmp"
        mv "$file.tmp" "$file"
        log_success "File updated: $file"
        return 0
    else
        log_error "Failed to update file: $file"
        restore_from_backup "$file"
        return 1
    fi
}
```

## Error Handling

### Common Error Patterns

```bash
# Check command success
if ! command_that_might_fail; then
    log_error "Command failed"
    return 1
fi

# Validate input
validate_not_empty "$input" "Input" || return 1

# Handle missing files
if [[ ! -f "$file" ]]; then
    log_warning "File not found: $file"
    create_default_file "$file"
fi

# Cleanup on error
trap 'cleanup_on_error' ERR

cleanup_on_error() {
    log_error "Error occurred, cleaning up"
    rm -f "$temp_file"
    restore_checkpoint
}
```

## See Also

- **Complete API Reference**: `docs/reference/api/COMPLETE_API_REFERENCE.md`
- **Module Inventory**: `docs/reference/api/README.md`
- **Architecture Guide**: `docs/guides/developer/architecture.md`
- **Getting Started**: `docs/getting-started/GETTING_STARTED.md`

---

**Version**: 4.0.0  
**Last Updated**: 2026-02-08
