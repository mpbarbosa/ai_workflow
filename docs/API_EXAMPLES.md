# AI Workflow Automation - API Examples

**Version**: v4.0.1  
**Comprehensive code examples** for API usage

---

## 📚 Table of Contents

1. [AI Helpers API](#ai-helpers-api)
2. [Metrics API](#metrics-api)
3. [Change Detection API](#change-detection-api)
4. [File Operations API](#file-operations-api)
5. [Workflow Optimization API](#workflow-optimization-api)
6. [Tech Stack Detection API](#tech-stack-detection-api)
7. [Session Manager API](#session-manager-api)
8. [Validation API](#validation-api)
9. [Integration Examples](#integration-examples)
10. [Custom Step Development](#custom-step-development)

---

## AI Helpers API

### Basic AI Call

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_helpers.sh"

# Simple AI call with persona
ai_call "documentation_specialist" \
  "Review this README and suggest improvements" \
  "output_report.md"

# Check result
if [[ -f "output_report.md" ]]; then
  echo "AI analysis complete"
  cat "output_report.md"
fi
```

### Check Copilot Availability

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_helpers.sh"

# Check if Copilot is available
if ! check_copilot_available; then
  echo "Copilot CLI not available, skipping AI features"
  exit 0
fi

# Check authentication
if ! is_copilot_authenticated; then
  echo "Please authenticate: gh auth login"
  exit 1
fi

# Proceed with AI operations
echo "Copilot available and authenticated"
```

### Advanced AI Prompt Building

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_helpers.sh"
source "$(dirname "$0")/lib/ai_prompt_builder.sh"

# Build complex prompt with context
prompt=$(build_prompt \
  --persona "code_reviewer" \
  --context "file:src/main.js" \
  --context "tech:nodejs,express" \
  --instruction "Review code for security issues" \
  --format "markdown")

# Call AI with built prompt
ai_call "code_reviewer" "$prompt" "security_review.md"
```

### Batch AI Processing

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_helpers.sh"

# Process multiple files with AI
declare -a files=("README.md" "CONTRIBUTING.md" "API.md")

for file in "${files[@]}"; do
  echo "Analyzing $file..."
  
  ai_call "documentation_specialist" \
    "Analyze $file for completeness and clarity" \
    "analysis_$(basename "$file" .md).md"
done

echo "Batch analysis complete"
```

### AI Response Caching

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_cache.sh"

# Initialize cache (automatic TTL: 24 hours)
init_ai_cache

# Check if response cached
cache_key=$(generate_cache_key "prompt text here" "persona_name")

if has_cached_response "$cache_key"; then
  echo "Using cached response"
  response=$(get_cached_response "$cache_key")
else
  echo "Calling AI (will be cached)"
  response=$(ai_call_with_cache "persona_name" "prompt text")
fi

# Clear old cache entries
cleanup_expired_cache
```

### Custom AI Personas

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ai_personas.sh"

# Define custom persona
register_persona "security_auditor" \
  "You are a security expert reviewing code for vulnerabilities" \
  "security_audit"

# Use custom persona
ai_call "security_auditor" \
  "Review this authentication code" \
  "security_audit.md"
```

---

## Metrics API

### Initialize Metrics System

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

# Initialize metrics collection
init_metrics

# Metrics files are created:
# - .ai_workflow/metrics/current_run.json
# - .ai_workflow/metrics/history.jsonl
# - .ai_workflow/metrics/summary.json
```

### Track Step Execution

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

# Initialize metrics
init_metrics

# Start tracking step
start_step 5 "Documentation Validation"

# Execute step logic
sleep 5  # Simulate work

# End tracking with status
end_step 5 "success"

# Record step status explicitly
record_step_status 5 "success" "All validations passed"
```

### Track Custom Phases

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

init_metrics

# Track custom phase within a step
start_phase "preprocessing" "Preparing documentation files"
# ... do preprocessing work ...
end_phase "preprocessing"

start_phase "ai_analysis" "Running AI analysis"
# ... do AI analysis ...
end_phase "ai_analysis"

start_phase "validation" "Validating results"
# ... do validation ...
end_phase "validation"
```

### Record Custom Metrics

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

init_metrics

# Record custom metric
record_custom_metric "files_processed" 42
record_custom_metric "ai_tokens_used" 15234
record_custom_metric "cache_hit_rate" 0.75

# Record error
record_error "step_5" "Validation failed: Missing required field"

# Record warning
record_warning "step_3" "Test coverage below threshold (65%)"
```

### Finalize and Report Metrics

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

init_metrics

# ... execute workflow ...

# Finalize metrics
finalize_metrics "success"

# Generate report
generate_metrics_report

# View summary
cat .ai_workflow/metrics/summary.json | jq '.summary'

# Example output:
# {
#   "total_duration": 845,
#   "steps_completed": 15,
#   "steps_failed": 0,
#   "success_rate": 100,
#   "avg_step_duration": 56.3
# }
```

### Query Metrics History

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

# Get last 10 runs
tail -10 .ai_workflow/metrics/history.jsonl | jq .

# Calculate average duration
awk '{sum+=$0} END {print sum/NR}' \
  <(jq -r '.duration' .ai_workflow/metrics/history.jsonl)

# Find slowest steps
jq -r '.steps[] | "\(.name):\(.duration)"' \
  .ai_workflow/metrics/history.jsonl | \
  sort -t: -k2 -nr | head -5
```

---

## Change Detection API

### Detect Changes

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"

# Analyze changes since last commit
analyze_changes

# Check what changed
if has_code_changes; then
  echo "Code changes detected"
fi

if has_doc_changes; then
  echo "Documentation changes detected"
fi

if has_test_changes; then
  echo "Test changes detected"
fi

if has_config_changes; then
  echo "Configuration changes detected"
fi
```

### Get Changed Files

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"

# Get list of changed files
changed_files=$(get_changed_files)

echo "Changed files:"
echo "$changed_files"

# Get files by type
doc_files=$(get_changed_files_by_type "docs")
code_files=$(get_changed_files_by_type "src")
test_files=$(get_changed_files_by_type "test")

echo "Documentation files: $doc_files"
echo "Source files: $code_files"
echo "Test files: $test_files"
```

### Change Impact Analysis

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"

# Analyze impact
analyze_changes

# Get impact level
impact=$(get_change_impact)

case "$impact" in
  "high")
    echo "Major changes detected - run full workflow"
    ;;
  "medium")
    echo "Moderate changes - run selected steps"
    ;;
  "low")
    echo "Minor changes - run minimal validation"
    ;;
  "none")
    echo "No significant changes - skip workflow"
    exit 0
    ;;
esac
```

### Smart Step Selection

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"
source "$(dirname "$0")/lib/workflow_optimization.sh"

# Analyze changes
analyze_changes

# Get recommended steps based on changes
recommended_steps=$(get_smart_steps)

echo "Recommended steps: $recommended_steps"

# Execute only necessary steps
for step in $recommended_steps; do
  echo "Executing step $step..."
  ./steps/step_${step}_*.sh
done
```

---

## File Operations API

### Safe File Operations

```bash
#!/bin/bash
source "$(dirname "$0")/lib/file_operations.sh"

# Create backup before modifying
backup_file "important.txt"

# Safe write with backup
safe_write "important.txt" "New content here"

# Restore from backup if needed
restore_file "important.txt"
```

### Batch File Operations

```bash
#!/bin/bash
source "$(dirname "$0")/lib/file_operations.sh"
source "$(dirname "$0")/lib/batch_operations.sh"

# Process multiple files
declare -a files=("file1.txt" "file2.txt" "file3.txt")

batch_process_files files "process_function"

# Custom processing function
process_function() {
  local file=$1
  echo "Processing $file..."
  # ... processing logic ...
}
```

### File Validation

```bash
#!/bin/bash
source "$(dirname "$0")/lib/file_operations.sh"
source "$(dirname "$0")/lib/validation.sh"

# Validate file exists and is readable
if ! validate_file_exists "config.yaml"; then
  echo "Error: config.yaml not found"
  exit 1
fi

if ! validate_file_readable "config.yaml"; then
  echo "Error: config.yaml not readable"
  exit 1
fi

# Validate file is writable
if ! validate_file_writable "output.md"; then
  echo "Error: output.md not writable"
  exit 1
fi
```

### Directory Operations

```bash
#!/bin/bash
source "$(dirname "$0")/lib/file_operations.sh"

# Create directory structure
ensure_directory_exists ".ai_workflow/metrics"
ensure_directory_exists ".ai_workflow/logs"
ensure_directory_exists ".ai_workflow/cache"

# Check if directory is empty
if is_directory_empty ".ai_workflow/cache"; then
  echo "Cache directory is empty"
fi

# Clean old files
clean_old_files ".ai_workflow/logs" 30  # older than 30 days
```

---

## Workflow Optimization API

### Smart Execution

```bash
#!/bin/bash
source "$(dirname "$0")/lib/workflow_optimization.sh"
source "$(dirname "$0")/lib/change_detection.sh"

# Enable smart execution
enable_smart_execution

# Analyze changes
analyze_changes

# Determine which steps to run
steps_to_run=$(calculate_smart_steps)

echo "Running steps: $steps_to_run"

# Execute smart workflow
execute_smart_workflow "$steps_to_run"
```

### Parallel Execution

```bash
#!/bin/bash
source "$(dirname "$0")/lib/workflow_optimization.sh"

# Enable parallel execution
enable_parallel_execution

# Define independent steps
declare -a independent_steps=(2 3 5)

# Execute in parallel
execute_parallel_steps independent_steps

# Wait for all to complete
wait_for_parallel_completion
```

### ML Optimization

```bash
#!/bin/bash
source "$(dirname "$0")/lib/ml_optimization.sh"

# Check if ML is available
if ! is_ml_available; then
  echo "ML optimization not available (need 10+ runs)"
  exit 0
fi

# Get predictions
predictions=$(get_step_predictions)

echo "Predicted durations:"
echo "$predictions" | jq .

# Apply ML recommendations
apply_ml_recommendations
```

### Multi-Stage Pipeline

```bash
#!/bin/bash
source "$(dirname "$0")/lib/multi_stage_pipeline.sh"

# Configure stages
configure_stages

# Execute stage 1 (critical checks)
execute_stage 1

if stage_passed 1; then
  echo "Stage 1 passed - continue to stage 2"
  execute_stage 2
else
  echo "Stage 1 failed - stopping"
  exit 1
fi

# Auto-advance to next stage if appropriate
auto_advance_stages
```

---

## Tech Stack Detection API

### Detect Project Type

```bash
#!/bin/bash
source "$(dirname "$0")/lib/tech_stack.sh"

# Detect technology stack
detect_tech_stack

# Get project kind
project_kind=$(get_project_kind)
echo "Project kind: $project_kind"

# Get primary language
primary_lang=$(get_primary_language)
echo "Primary language: $primary_lang"

# Get frameworks
frameworks=$(get_frameworks)
echo "Frameworks: $frameworks"
```

### Custom Tech Stack Configuration

```bash
#!/bin/bash
source "$(dirname "$0")/lib/tech_stack.sh"
source "$(dirname "$0")/lib/config_wizard.sh"

# Run interactive configuration
run_config_wizard

# Or set programmatically
set_project_kind "nodejs_api"
set_primary_language "javascript"
add_framework "express"
add_framework "jest"
set_test_command "npm test"

# Save configuration
save_tech_stack_config
```

### Query Tech Stack

```bash
#!/bin/bash
source "$(dirname "$0")/lib/tech_stack.sh"

# Load configuration
load_tech_stack_config

# Check for specific technology
if has_framework "react"; then
  echo "React project detected"
  # ... React-specific logic ...
fi

if has_test_framework "jest"; then
  echo "Jest testing framework detected"
  # ... Jest-specific logic ...
fi

# Get all tools
tools=$(get_all_tools)
echo "Tools: $tools"
```

---

## Session Manager API

### Process Management

```bash
#!/bin/bash
source "$(dirname "$0")/lib/session_manager.sh"

# Initialize session
init_session "workflow_$$"

# Start background process
start_process "ai_analysis" "copilot analyze code.js"

# Check if running
if is_process_running "ai_analysis"; then
  echo "AI analysis in progress..."
fi

# Wait for completion
wait_for_process "ai_analysis"

# Get exit status
status=$(get_process_status "ai_analysis")
echo "Process exited with status: $status"

# Cleanup
cleanup_session
```

### Parallel Process Management

```bash
#!/bin/bash
source "$(dirname "$0")/lib/session_manager.sh"

init_session "parallel_$$"

# Start multiple processes
start_process "doc_check" "./steps/step_02_documentation.sh"
start_process "code_check" "./steps/step_03_code_quality.sh"
start_process "test_check" "./steps/step_07_test_validation.sh"

# Wait for all
wait_for_all_processes

# Check results
for proc in doc_check code_check test_check; do
  status=$(get_process_status "$proc")
  if [[ $status -ne 0 ]]; then
    echo "Process $proc failed with status $status"
  fi
done

cleanup_session
```

### Resource Monitoring

```bash
#!/bin/bash
source "$(dirname "$0")/lib/session_manager.sh"

# Monitor resource usage
monitor_resources() {
  while true; do
    cpu=$(get_cpu_usage "workflow_$$")
    mem=$(get_memory_usage "workflow_$$")
    
    echo "CPU: ${cpu}% | Memory: ${mem}MB"
    
    # Throttle if needed
    if [[ ${cpu%.*} -gt 80 ]]; then
      echo "High CPU - throttling"
      sleep 5
    fi
    
    sleep 1
  done
}

# Start monitoring in background
monitor_resources &
monitor_pid=$!

# ... do work ...

# Stop monitoring
kill $monitor_pid
```

---

## Validation API

### Input Validation

```bash
#!/bin/bash
source "$(dirname "$0")/lib/validation.sh"

# Validate step number
if ! validate_step_number "$STEP"; then
  echo "Error: Invalid step number: $STEP"
  exit 1
fi

# Validate file path
if ! validate_file_path "$FILE"; then
  echo "Error: Invalid file path: $FILE"
  exit 1
fi

# Validate directory
if ! validate_directory "$DIR"; then
  echo "Error: Directory does not exist: $DIR"
  exit 1
fi
```

### Content Validation

```bash
#!/bin/bash
source "$(dirname "$0")/lib/validation.sh"

# Validate YAML syntax
if ! validate_yaml "config.yaml"; then
  echo "Error: Invalid YAML in config.yaml"
  exit 1
fi

# Validate JSON syntax
if ! validate_json "data.json"; then
  echo "Error: Invalid JSON in data.json"
  exit 1
fi

# Validate Markdown
if ! validate_markdown "README.md"; then
  echo "Error: Invalid Markdown in README.md"
  exit 1
fi
```

### Configuration Validation

```bash
#!/bin/bash
source "$(dirname "$0")/lib/validation.sh"
source "$(dirname "$0")/lib/config_validation.sh"

# Validate workflow configuration
if ! validate_workflow_config ".workflow-config.yaml"; then
  echo "Error: Invalid workflow configuration"
  exit 1
fi

# Validate required fields
validate_required_field "project.kind" "$config"
validate_required_field "tech_stack.primary_language" "$config"

# Validate field values
validate_enum "project.kind" "$kind" "nodejs_api,python_app,react_spa"
```

---

## Integration Examples

### GitHub Actions Integration

```yaml
# .github/workflows/ai-workflow.yml
name: AI Workflow

on: [push, pull_request]

jobs:
  workflow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup workflow
        run: |
          git clone https://github.com/mpbarbosa/ai_workflow.git /tmp/ai_workflow
      
      - name: Run workflow
        run: |
          cd ${{ github.workspace }}
          /tmp/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
            --auto \
            --smart-execution \
            --parallel
```

### Custom CI Script

```bash
#!/bin/bash
# ci_workflow.sh - Custom CI integration

set -euo pipefail

# Source workflow libraries
WORKFLOW_PATH="/opt/ai_workflow"
source "$WORKFLOW_PATH/src/workflow/lib/metrics.sh"
source "$WORKFLOW_PATH/src/workflow/lib/change_detection.sh"
source "$WORKFLOW_PATH/src/workflow/lib/workflow_optimization.sh"

# Initialize
init_metrics
analyze_changes

# Determine execution mode
if has_doc_changes && ! has_code_changes; then
  echo "Documentation-only changes detected"
  STEPS="0,2,5,15"
else
  echo "Code changes detected - full workflow"
  STEPS="all"
fi

# Execute workflow
"$WORKFLOW_PATH/src/workflow/execute_tests_docs_workflow.sh" \
  --steps "$STEPS" \
  --smart-execution \
  --parallel \
  --auto

# Check results
if finalize_metrics "success"; then
  echo "Workflow completed successfully"
  exit 0
else
  echo "Workflow failed"
  exit 1
fi
```

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit - Fast validation

set -euo pipefail

WORKFLOW_PATH="/opt/ai_workflow"

# Fast checks only
"$WORKFLOW_PATH/src/workflow/lib/validation.sh" check_syntax
"$WORKFLOW_PATH/src/workflow/lib/validation.sh" check_links
"$WORKFLOW_PATH/src/workflow/lib/validation.sh" check_formatting

# Exit with status
if [[ $? -eq 0 ]]; then
  echo "✅ Pre-commit checks passed"
  exit 0
else
  echo "❌ Pre-commit checks failed"
  exit 1
fi
```

---

## Custom Step Development

### Minimal Step Template

```bash
#!/bin/bash
set -euo pipefail

################################################################################
# Step XX: Custom Step Name
# Purpose: Brief description of what this step does
################################################################################

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../lib" && pwd)"

source "${LIB_DIR}/metrics.sh"
source "${LIB_DIR}/validation.sh"
source "${LIB_DIR}/ai_helpers.sh"

# Step configuration
STEP_NUMBER=99
STEP_NAME="Custom Step"

# Validate step can run
validate_step() {
  # Check prerequisites
  if ! validate_directory "$PROJECT_ROOT"; then
    return 1
  fi
  
  return 0
}

# Execute step logic
execute_step() {
  local output_file="${BACKLOG_DIR}/step_${STEP_NUMBER}_custom.md"
  
  # Start tracking
  start_step "$STEP_NUMBER" "$STEP_NAME"
  
  # Step logic here
  echo "Executing custom step..."
  
  # AI processing if needed
  ai_call "code_reviewer" \
    "Review code for issues" \
    "$output_file"
  
  # End tracking
  end_step "$STEP_NUMBER" "success"
  
  return 0
}

# Main execution
main() {
  if ! validate_step; then
    echo "Step validation failed"
    return 1
  fi
  
  if ! execute_step; then
    echo "Step execution failed"
    return 1
  fi
  
  echo "Step completed successfully"
  return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

### Advanced Step with Phases

```bash
#!/bin/bash
set -euo pipefail

# ... header and sourcing ...

execute_step() {
  start_step "$STEP_NUMBER" "$STEP_NAME"
  
  # Phase 1: Preparation
  start_phase "preparation" "Preparing data"
  prepare_data
  end_phase "preparation"
  
  # Phase 2: Processing
  start_phase "processing" "Processing with AI"
  process_with_ai
  end_phase "processing"
  
  # Phase 3: Validation
  start_phase "validation" "Validating results"
  validate_results
  end_phase "validation"
  
  end_step "$STEP_NUMBER" "success"
}

prepare_data() {
  # Preparation logic
  echo "Preparing data..."
}

process_with_ai() {
  # AI processing logic
  echo "Processing with AI..."
}

validate_results() {
  # Validation logic
  echo "Validating results..."
}
```

### Step with Error Handling

```bash
#!/bin/bash
set -euo pipefail

# ... header and sourcing ...

execute_step() {
  start_step "$STEP_NUMBER" "$STEP_NAME"
  
  # Set trap for cleanup
  trap cleanup ERR EXIT
  
  # Execute with error handling
  if ! execute_with_retry 3 process_data; then
    record_error "$STEP_NAME" "Data processing failed after 3 retries"
    end_step "$STEP_NUMBER" "failed"
    return 1
  fi
  
  end_step "$STEP_NUMBER" "success"
  return 0
}

execute_with_retry() {
  local max_retries=$1
  shift
  local command=("$@")
  local attempt=1
  
  while [[ $attempt -le $max_retries ]]; do
    if "${command[@]}"; then
      return 0
    fi
    
    echo "Attempt $attempt failed, retrying..."
    ((attempt++))
    sleep 2
  done
  
  return 1
}

cleanup() {
  # Cleanup logic
  echo "Cleaning up..."
}
```

---

## Best Practices

### Error Handling

```bash
# Always check return codes
if ! some_function; then
  echo "Error: Function failed"
  return 1
fi

# Use set -e for automatic error handling
set -euo pipefail

# Trap errors for cleanup
trap 'cleanup_on_error $?' ERR
```

### Logging

```bash
# Use consistent log levels
log_debug "Debug information"
log_info "Informational message"
log_warning "Warning message"
log_error "Error message"

# Log to file and console
log_message "Important" | tee -a "$LOG_FILE"
```

### Resource Management

```bash
# Always clean up resources
cleanup() {
  rm -f "$TEMP_FILE"
  kill_process "$PID"
  restore_state
}
trap cleanup EXIT

# Use temporary files safely
TEMP_FILE=$(mktemp)
```

### Testing

```bash
# Test your functions
test_function() {
  local result
  result=$(my_function "test_input")
  
  if [[ "$result" == "expected" ]]; then
    echo "✅ Test passed"
  else
    echo "❌ Test failed: expected 'expected', got '$result'"
    return 1
  fi
}
```

---

## Next Steps

- **Full API Reference**: [docs/reference/api/API_REFERENCE.md](api/API_REFERENCE.md)
- **Module Documentation**: [docs/reference/api/LIBRARY_API_REFERENCE.md](api/LIBRARY_API_REFERENCE.md)
- **Developer Guide**: [docs/guides/developer/MODULE_DEVELOPMENT.md](developer-guide/MODULE_DEVELOPMENT.md)
- **Contributing**: [CONTRIBUTING.md](../CONTRIBUTING.md)

---

**For more examples**, see the [tutorials](TUTORIALS.md) and [user guide](user-guide/USER_GUIDE.md).
