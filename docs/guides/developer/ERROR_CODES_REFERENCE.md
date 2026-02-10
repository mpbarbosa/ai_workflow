# Error Codes Reference - AI Workflow Automation

**Version**: 4.0.1  
**Last Updated**: 2026-02-10  
**Purpose**: Standard error codes and handling patterns across all modules

## Overview

This document defines the standard error codes, return values, and error handling patterns used throughout the AI Workflow Automation system. Consistent error handling enables better debugging, logging, and automated error recovery.

## Standard Error Codes

### General Error Codes (0-19)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `0` | SUCCESS | Operation completed successfully | Continue execution |
| `1` | GENERAL_ERROR | Non-specific error | Check logs, retry |
| `2` | INVALID_ARGUMENT | Invalid parameter passed to function | Fix calling code |
| `3` | FILE_NOT_FOUND | Required file does not exist | Check path, create file |
| `4` | PERMISSION_DENIED | Insufficient permissions | Check file/dir permissions |
| `5` | DEPENDENCY_MISSING | Required command not found | Install dependency |
| `6` | CONFIGURATION_ERROR | Config file invalid or missing | Fix config file |
| `7` | VALIDATION_FAILED | Data validation failed | Fix input data |
| `8` | TIMEOUT | Operation timed out | Increase timeout, check network |
| `9` | CANCELLED | Operation cancelled by user | Normal exit |
| `10` | NOT_IMPLEMENTED | Feature not yet implemented | Use alternative approach |

### Git Operations (20-39)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `20` | GIT_DIRTY_TREE | Working tree has uncommitted changes | Commit or stash changes |
| `21` | GIT_COMMAND_FAILED | Git command execution failed | Check git status, logs |
| `22` | GIT_MERGE_CONFLICT | Merge conflict detected | Resolve conflicts manually |
| `23` | GIT_PUSH_FAILED | Push to remote failed | Check network, permissions |
| `24` | GIT_SUBMODULE_ERROR | Submodule operation failed | Update submodule, check config |
| `25` | GIT_BRANCH_NOT_FOUND | Requested branch does not exist | Create branch or use correct name |
| `26` | GIT_REMOTE_ERROR | Remote repository unreachable | Check network, remote URL |

### AI Operations (40-59)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `40` | AI_UNAVAILABLE | GitHub Copilot CLI not available | Install gh CLI and copilot extension |
| `41` | AI_AUTH_FAILED | Copilot authentication failed | Run `gh auth login` |
| `42` | AI_QUOTA_EXCEEDED | AI quota limit reached | Wait for quota reset |
| `43` | AI_TIMEOUT | AI call timed out | Retry with simpler prompt |
| `44` | AI_INVALID_RESPONSE | AI returned malformed response | Retry or adjust prompt |
| `45` | AI_CACHE_ERROR | Cache read/write failed | Clear cache, check disk space |
| `46` | AI_PERSONA_INVALID | Requested persona does not exist | Use valid persona name |
| `47` | AI_PROMPT_TOO_LARGE | Prompt exceeds token limit | Reduce prompt size |

### File Operations (60-79)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `60` | FILE_WRITE_ERROR | Cannot write to file | Check permissions, disk space |
| `61` | FILE_READ_ERROR | Cannot read file | Check file exists and is readable |
| `62` | FILE_LOCK_ERROR | File is locked by another process | Wait or force unlock |
| `63` | DIRECTORY_NOT_FOUND | Directory does not exist | Create directory |
| `64` | DISK_SPACE_ERROR | Insufficient disk space | Free up space |
| `65` | FILE_PARSE_ERROR | Cannot parse file (JSON/YAML) | Fix syntax errors |

### Step Execution (80-99)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `80` | STEP_VALIDATION_FAILED | Step validation checks failed | Fix validation errors |
| `81` | STEP_EXECUTION_FAILED | Step execution failed | Check logs, retry |
| `82` | STEP_DEPENDENCY_FAILED | Prerequisite step failed | Fix dependency issues |
| `83` | STEP_TIMEOUT | Step exceeded time limit | Increase timeout or optimize step |
| `84` | STEP_SKIPPED | Step intentionally skipped | Normal operation |
| `85` | STEP_NOT_FOUND | Step module does not exist | Check step name/path |

### Configuration (100-119)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `100` | CONFIG_MISSING | Required config file not found | Run --init-config |
| `101` | CONFIG_INVALID_YAML | Config file has YAML syntax error | Fix YAML syntax |
| `102` | CONFIG_MISSING_FIELD | Required field missing in config | Add missing field |
| `103` | CONFIG_INVALID_VALUE | Config value is invalid | Fix value to match constraints |
| `104` | CONFIG_VERSION_MISMATCH | Config version incompatible | Migrate config to new version |

### Network Operations (120-139)

| Code | Name | Description | Action |
|------|------|-------------|--------|
| `120` | NETWORK_ERROR | General network error | Check connectivity |
| `121` | DNS_RESOLUTION_FAILED | Cannot resolve hostname | Check DNS settings |
| `122` | CONNECTION_TIMEOUT | Connection timed out | Check network, firewall |
| `123` | HTTP_ERROR_4XX | HTTP client error (4xx) | Fix request |
| `124` | HTTP_ERROR_5XX | HTTP server error (5xx) | Retry later |

## Error Handling Patterns

### Pattern 1: Return Code Checking

```bash
# Basic error checking
if ! some_function "param"; then
  echo "ERROR: Function failed" >&2
  return 1
fi

# Capture and check return code
some_function "param"
local ret=$?
if [[ $ret -ne 0 ]]; then
  echo "ERROR: Function returned $ret" >&2
  return $ret
fi

# Check specific error codes
if ! validate_config ".workflow-config.yaml"; then
  ret=$?
  case $ret in
    100)
      echo "ERROR: Config file not found" >&2
      return $ret
      ;;
    101)
      echo "ERROR: Invalid YAML syntax" >&2
      return $ret
      ;;
    *)
      echo "ERROR: Validation failed with code $ret" >&2
      return $ret
      ;;
  esac
fi
```

### Pattern 2: Error Propagation

```bash
# Propagate errors up the call stack
function high_level_operation() {
  if ! mid_level_operation "$@"; then
    local ret=$?
    echo "ERROR: Mid-level operation failed" >&2
    return $ret  # Propagate exact error code
  fi
  return 0
}

function mid_level_operation() {
  if ! low_level_operation "$@"; then
    local ret=$?
    echo "ERROR: Low-level operation failed" >&2
    return $ret  # Propagate exact error code
  fi
  return 0
}
```

### Pattern 3: Cleanup on Error

```bash
# Ensure cleanup even on error
function operation_with_cleanup() {
  local temp_file="/tmp/workflow_$$_temp"
  
  # Create temp file
  touch "$temp_file" || return 60
  
  # Trap ensures cleanup on exit
  trap 'rm -f "$temp_file"' EXIT
  
  # Do work (cleanup happens automatically)
  if ! process_data "$temp_file"; then
    echo "ERROR: Processing failed" >&2
    return 81
  fi
  
  return 0
}
```

### Pattern 4: Retry Logic

```bash
# Retry with exponential backoff
function retry_operation() {
  local max_attempts=3
  local attempt=1
  local delay=2
  
  while [[ $attempt -le $max_attempts ]]; do
    if some_operation "$@"; then
      return 0  # Success
    fi
    
    local ret=$?
    echo "WARNING: Attempt $attempt/$max_attempts failed (code: $ret)" >&2
    
    if [[ $attempt -lt $max_attempts ]]; then
      echo "Retrying in ${delay}s..." >&2
      sleep $delay
      delay=$((delay * 2))  # Exponential backoff
    fi
    
    ((attempt++))
  done
  
  echo "ERROR: Operation failed after $max_attempts attempts" >&2
  return $ret
}
```

### Pattern 5: Graceful Degradation

```bash
# Continue with reduced functionality on error
function robust_operation() {
  local use_cache=1
  
  # Try to use cache
  if ! init_cache; then
    echo "WARNING: Cache unavailable, continuing without cache" >&2
    use_cache=0
  fi
  
  # Main operation works with or without cache
  if [[ $use_cache -eq 1 ]]; then
    get_cached_result "$@" || generate_result "$@"
  else
    generate_result "$@"
  fi
}
```

### Pattern 6: Error Context

```bash
# Add context to error messages
function contextual_error_handling() {
  local operation="$1"
  local file="$2"
  
  if ! process_file "$file"; then
    local ret=$?
    case $ret in
      3)
        echo "ERROR: File not found: $file (during $operation)" >&2
        ;;
      4)
        echo "ERROR: Permission denied: $file (during $operation)" >&2
        ;;
      *)
        echo "ERROR: Failed to process $file (during $operation, code: $ret)" >&2
        ;;
    esac
    return $ret
  fi
  
  return 0
}
```

## Error Logging

### Standard Error Format

```bash
# Error message format: LEVEL: Context: Message (Code: X)
echo "ERROR: validate_config: Missing required field 'project.kind' (Code: 102)" >&2
echo "WARNING: init_cache: Cache directory not writable, using temp dir" >&2
echo "INFO: ai_call: Using cached response from 2h ago"
```

### Log Levels

| Level | Usage | Destination |
|-------|-------|-------------|
| `ERROR` | Operation failed, returning non-zero | stderr |
| `WARNING` | Degraded functionality, continuing | stderr |
| `INFO` | Normal informational message | stdout |
| `DEBUG` | Detailed debugging information | stdout (if DEBUG=1) |

### Logging Functions

```bash
# Standard logging functions
log_error() {
  echo "ERROR: ${FUNCNAME[1]}: $*" >&2
}

log_warning() {
  echo "WARNING: ${FUNCNAME[1]}: $*" >&2
}

log_info() {
  echo "INFO: $*"
}

log_debug() {
  if [[ "${DEBUG:-0}" == "1" ]]; then
    echo "DEBUG: ${FUNCNAME[1]}: $*"
  fi
}

# Usage
validate_input() {
  if [[ -z "$1" ]]; then
    log_error "Input parameter is empty"
    return 2
  fi
  return 0
}
```

## Error Recovery

### Automatic Recovery Strategies

#### 1. Checkpoint Resume

When step execution fails, the system automatically saves progress:

```bash
# Save checkpoint
save_checkpoint() {
  local step_id="$1"
  local checkpoint_file=".workflow_checkpoints/latest.json"
  
  jq -n \
    --arg step "$step_id" \
    --arg timestamp "$(date -Iseconds)" \
    '{step: $step, timestamp: $timestamp}' \
    > "$checkpoint_file"
}

# Resume from checkpoint
resume_from_checkpoint() {
  local checkpoint_file=".workflow_checkpoints/latest.json"
  
  if [[ -f "$checkpoint_file" ]]; then
    local last_step
    last_step=$(jq -r '.step' "$checkpoint_file")
    echo "Resuming from step: $last_step"
    return 0
  fi
  
  return 1
}
```

#### 2. Fallback Mechanisms

```bash
# Try primary method, fall back to alternative
function resilient_operation() {
  # Try modern approach
  if modern_implementation "$@" 2>/dev/null; then
    return 0
  fi
  
  log_warning "Modern implementation failed, using fallback"
  
  # Fall back to legacy approach
  if legacy_implementation "$@"; then
    return 0
  fi
  
  log_error "All implementations failed"
  return 1
}
```

### Manual Recovery Steps

#### Git Dirty Tree (Code 20)

```bash
# Problem: Working tree has uncommitted changes
# Solution:
git stash push -m "Workflow auto-stash"
./execute_tests_docs_workflow.sh
git stash pop
```

#### AI Unavailable (Code 40)

```bash
# Problem: GitHub Copilot CLI not installed
# Solution:
gh extension install github/gh-copilot
gh auth login
```

#### Config Missing (Code 100)

```bash
# Problem: .workflow-config.yaml not found
# Solution:
./execute_tests_docs_workflow.sh --init-config
```

#### Disk Space Error (Code 64)

```bash
# Problem: Insufficient disk space
# Solution:
./scripts/cleanup_artifacts.sh --all --older-than 7
df -h  # Verify space freed
```

## Testing Error Handling

### Unit Test Pattern

```bash
# Test error conditions
test_function_error_handling() {
  # Test missing parameter
  if some_function; then
    echo "FAIL: Should return error for missing parameter"
    return 1
  fi
  local ret=$?
  if [[ $ret -ne 2 ]]; then
    echo "FAIL: Expected error code 2, got $ret"
    return 1
  fi
  
  # Test invalid parameter
  if some_function "invalid"; then
    echo "FAIL: Should return error for invalid parameter"
    return 1
  fi
  ret=$?
  if [[ $ret -ne 7 ]]; then
    echo "FAIL: Expected error code 7, got $ret"
    return 1
  fi
  
  # Test success case
  if ! some_function "valid"; then
    echo "FAIL: Should succeed for valid parameter"
    return 1
  fi
  
  echo "PASS: Error handling test passed"
  return 0
}
```

### Integration Test Pattern

```bash
# Test error recovery
test_error_recovery() {
  local test_dir="/tmp/error_recovery_test_$$"
  mkdir -p "$test_dir"
  cd "$test_dir" || return 1
  
  # Create scenario that will fail
  touch .workflow-config.yaml
  echo "invalid yaml {[" > .workflow-config.yaml
  
  # Test that workflow detects and reports error
  if ./execute_tests_docs_workflow.sh 2>&1 | grep -q "Invalid YAML"; then
    echo "PASS: Error correctly detected and reported"
  else
    echo "FAIL: Error not detected"
    return 1
  fi
  
  # Cleanup
  cd - >/dev/null
  rm -rf "$test_dir"
  return 0
}
```

## Best Practices

### DO

✅ Use specific error codes (not just 1 for all errors)  
✅ Include context in error messages (file names, operation, step)  
✅ Log errors to stderr, info to stdout  
✅ Propagate exact error codes up the call stack  
✅ Clean up resources even when errors occur (use trap)  
✅ Document all possible return codes in function headers  
✅ Test error conditions, not just happy path  
✅ Implement retries for transient failures (network, AI)  

### DON'T

❌ Return 0 for failures (signals success)  
❌ Use exit in library functions (prevents cleanup)  
❌ Swallow errors silently (always log)  
❌ Change error codes during propagation (preserve original)  
❌ Use generic error messages ("Error occurred")  
❌ Forget to quote variable expansions in error messages  
❌ Mix stdout and stderr output  
❌ Retry non-idempotent operations without safeguards  

## Quick Reference

### Common Error Scenarios

```bash
# File not found
[[ -f "$file" ]] || { log_error "File not found: $file"; return 3; }

# Command not found
command -v jq >/dev/null || { log_error "jq not installed"; return 5; }

# Empty parameter
[[ -n "$param" ]] || { log_error "Parameter cannot be empty"; return 2; }

# Invalid JSON
jq empty "$file" 2>/dev/null || { log_error "Invalid JSON: $file"; return 65; }

# Git dirty tree
[[ -z $(git status --porcelain) ]] || { log_error "Working tree not clean"; return 20; }

# AI unavailable
is_copilot_available || { log_error "Copilot CLI not available"; return 40; }
```

## See Also

- [Library Function Documentation Guide](LIBRARY_FUNCTION_DOCUMENTATION_GUIDE.md)
- [Testing Guide](COMPREHENSIVE_TESTING_GUIDE.md)
- [Troubleshooting Guide](../../guides/TROUBLESHOOTING.md)
- [Module Development](MODULE_DEVELOPMENT.md)
