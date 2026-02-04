# JQ Wrapper Function Documentation

## Overview

The `jq_safe` wrapper function provides a safe, validated interface to the `jq` command with automatic argument validation, debug logging, and clear error messages.

## Purpose

Prevents `jq: invalid JSON text passed to --argjson` errors by:
- Validating all `--argjson` arguments before execution
- Sanitizing values to ensure they are valid JSON primitives
- Logging all arguments for debugging
- Providing clear error messages with caller context

## Installation

```bash
# Source the module in your script
source "path/to/lib/jq_wrapper.sh"
```

## Main Function: jq_safe

### Synopsis

```bash
jq_safe [jq-options] [filter] [files...]
```

### Description

A drop-in replacement for `jq` that adds:
- **Validation**: Checks all `--argjson` values are non-empty and look like valid JSON
- **Logging**: Logs arguments when `DEBUG=true` or `WORKFLOW_LOG_FILE` is set
- **Error Context**: Reports which function called jq_safe when errors occur
- **Safety**: Prevents common jq errors that crash workflows

### Usage Examples

#### Basic JSON Creation

```bash
# Simple null input
result=$(jq_safe -n '{}')

# With string argument
result=$(jq_safe -n --arg name "John" '{name: $name}')

# With numeric argument
result=$(jq_safe -n --argjson age 30 '{age: $age}')
```

#### Processing JSON Data

```bash
# From stdin
echo '{"users": [{"name": "Alice"}, {"name": "Bob"}]}' | \
    jq_safe '.users[] | .name'

# From file
jq_safe '.items | length' data.json

# Complex filter
jq_safe '.[] | select(.active == true) | .id' users.json
```

#### Multiple --argjson Arguments

```bash
# With validation
total=$(sanitize_argjson_value "${TOTAL:-}" 0)
completed=$(sanitize_argjson_value "${COMPLETED:-}" 0)

result=$(jq_safe -n \
    --argjson total "$total" \
    --argjson completed "$completed" \
    '{
        total: $total,
        completed: $completed,
        remaining: ($total - $completed),
        percent: (($completed * 100) / $total | floor)
    }')
```

## Helper Functions

### validate_json

Check if a JSON string is well-formed.

**Synopsis:**
```bash
validate_json <json-string>
```

**Returns:**
- `0` if JSON is valid
- `1` if JSON is invalid or empty

**Example:**
```bash
if validate_json "$user_data"; then
    echo "$user_data" | jq_safe '.name'
else
    echo "Invalid JSON data"
    return 1
fi
```

### sanitize_argjson_value

Sanitize a value for safe use with `--argjson`.

**Synopsis:**
```bash
sanitize_argjson_value <value> [default]
```

**Arguments:**
- `value`: The value to sanitize
- `default`: Optional default value (defaults to `0`)

**Returns:**
- Valid JSON primitive (number, boolean, or null)
- Default value if input is invalid

**Example:**
```bash
# Ensure count is a valid number
count=$(sanitize_argjson_value "${COUNT:-}" 0)
jq_safe -n --argjson count "$count" '{count: $count}'

# Handle potentially empty variables
duration=${DURATION:-}
duration=$(sanitize_argjson_value "$duration" 0)
jq_safe -n --argjson dur "$duration" '{duration: $dur}'
```

### jq_wrapper_help

Display comprehensive usage information.

**Synopsis:**
```bash
jq_wrapper_help
```

**Example:**
```bash
# Show help
jq_wrapper_help
```

## Debug Logging

### Enabling Debug Mode

```bash
# Method 1: Set DEBUG environment variable
export DEBUG=true
./my_script.sh

# Method 2: Automatic in workflow (WORKFLOW_LOG_FILE set)
./src/workflow/execute_tests_docs_workflow.sh
```

### Log Output Format

When debug logging is enabled, jq_safe logs:

```
[DEBUG] jq_safe called from: finalize_metrics
  Arguments: -n --arg status failed --argjson duration 120 {status: $status, duration: $duration}
[DEBUG] jq_safe completed successfully in finalize_metrics
```

### Log Location

- Logs written to `${WORKFLOW_LOG_FILE}` if set
- Otherwise logs to `/dev/null` (no-op)
- Check logs: `grep "\[DEBUG\]" src/workflow/logs/workflow_*/workflow_execution.log`

## Error Handling

### Validation Errors

When `--argjson` validation fails:

```
ERROR: jq_safe validation failed in calculate_metrics
  - --argjson variable 'count' has empty value
  - --argjson variable 'ratio' value 'abc' may not be valid JSON
```

### Execution Errors

When jq command fails:

```
[ERROR] jq_safe failed with exit code 5 in process_data
```

## Migration Guide

### Step 1: Source the Module

Add to the top of your script:

```bash
#!/bin/bash
set -euo pipefail

# Source jq wrapper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/jq_wrapper.sh"
```

### Step 2: Replace Direct jq Calls

**Before:**
```bash
result=$(jq -n --argjson count "$count" '{count: $count}')
```

**After:**
```bash
count=$(sanitize_argjson_value "$count" 0)
result=$(jq_safe -n --argjson count "$count" '{count: $count}')
```

### Step 3: Add Validation for Complex Cases

**Before:**
```bash
jq --arg status "${final_status}" \
   --argjson duration "${WORKFLOW_DURATION}" \
   '{status: $status, duration: $duration}' file.json
```

**After:**
```bash
# Sanitize all argjson values
duration=$(sanitize_argjson_value "${WORKFLOW_DURATION}" 0)

jq_safe --arg status "${final_status}" \
        --argjson duration "$duration" \
        '{status: $status, duration: $duration}' file.json
```

### Step 4: Test with DEBUG Mode

```bash
# Enable debug logging
export DEBUG=true

# Run your script
./my_script.sh

# Check for any validation errors in output
```

## Best Practices

### 1. Always Sanitize --argjson Values

```bash
# Good: Sanitize before use
count=$(sanitize_argjson_value "${COUNT:-}" 0)
jq_safe -n --argjson count "$count" '{count: $count}'

# Risky: Direct use of potentially empty variable
jq_safe -n --argjson count "${COUNT}" '{count: $count}'
```

### 2. Validate JSON Input

```bash
# Good: Validate before processing
if validate_json "$json_data"; then
    result=$(echo "$json_data" | jq_safe '.field')
else
    echo "Invalid JSON input" >&2
    return 1
fi
```

### 3. Use Appropriate Defaults

```bash
# Meaningful defaults based on context
total=$(sanitize_argjson_value "${TOTAL}" 0)
enabled=$(sanitize_argjson_value "${ENABLED}" false)
message=$(sanitize_argjson_value "${MESSAGE}" null)
```

### 4. Handle Complex Objects Separately

```bash
# For complex objects, validate the JSON first
features_json="$(...)"  # Build complex JSON

if validate_json "$features_json"; then
    result=$(jq_safe --argjson features "$features_json" '{features: $features}')
else
    echo "Invalid features JSON" >&2
    features_json="{}"
fi
```

## Return Codes

| Code | Meaning |
|------|---------|
| 0    | Success |
| 1    | Validation error or jq execution error |
| 127  | jq command not found |

## Testing

Run the test suite:

```bash
# Run all tests
./src/workflow/lib/test_jq_wrapper.sh

# Expected output:
# ================================
# JQ Wrapper Test Suite
# ================================
# Testing: Basic null input ... ✓ PASS
# Testing: String argument with --arg ... ✓ PASS
# Testing: Numeric --argjson ... ✓ PASS
# ...
# ================================
# Test Summary
# ================================
# Passed: 17
# Failed: 0
# Total:  17
# ✓ All tests passed!
```

## Integration Examples

### In metrics.sh

```bash
source "${SCRIPT_DIR}/jq_wrapper.sh"

finalize_metrics() {
    # ... existing code ...
    
    # Sanitize all numeric values
    duration=$(sanitize_argjson_value "${WORKFLOW_DURATION}" 0)
    completed=$(sanitize_argjson_value "${WORKFLOW_STEPS_COMPLETED}" 0)
    failed=$(sanitize_argjson_value "${WORKFLOW_STEPS_FAILED}" 0)
    
    jq_safe --arg status "${final_status}" \
            --argjson duration "$duration" \
            --argjson completed "$completed" \
            --argjson failed "$failed" \
            '{
                status: $status,
                duration_seconds: $duration,
                steps_completed: $completed,
                steps_failed: $failed
            }' "${METRICS_CURRENT}" > "${METRICS_CURRENT}.tmp"
}
```

### In ml_optimization.sh

```bash
source "${SCRIPT_DIR}/jq_wrapper.sh"

extract_change_features() {
    # ... calculate feature values ...
    
    # Sanitize all numeric features
    total_files=$(sanitize_argjson_value "$total_files" 0)
    doc_files=$(sanitize_argjson_value "$doc_files" 0)
    lines_changed=$(sanitize_argjson_value "$lines_changed" 0)
    
    features=$(jq_safe -n \
        --arg change_type "$change_type" \
        --argjson total_files "$total_files" \
        --argjson doc_files "$doc_files" \
        --argjson lines_changed "$lines_changed" \
        '{
            change_type: $change_type,
            total_files: $total_files,
            doc_files: $doc_files,
            lines_changed: $lines_changed
        }')
    
    echo "$features"
}
```

## Performance

- **Minimal overhead**: Validation adds ~1ms per jq call
- **No impact when disabled**: Logging only occurs when DEBUG=true
- **Same output**: Produces identical output to native jq
- **Preserves behavior**: All jq options and features work as expected

## Troubleshooting

### Issue: "jq_safe: command not found"

**Solution:** Source the module before using:
```bash
source "path/to/lib/jq_wrapper.sh"
```

### Issue: Validation error for valid JSON

**Solution:** Check that complex JSON is properly quoted:
```bash
# Wrong: unquoted JSON gets parsed by shell
jq_safe --argjson data {"foo":"bar"} '{}'

# Correct: proper quoting
jq_safe --argjson data '{"foo":"bar"}' '{}'

# Better: use validate_json first
data='{"foo":"bar"}'
if validate_json "$data"; then
    jq_safe --argjson data "$data" '{data: $data}'
fi
```

### Issue: Empty value errors despite sanitization

**Solution:** Ensure sanitization happens before jq_safe call:
```bash
# Wrong order: sanitize_argjson_value won't affect jq_safe validation
jq_safe -n --argjson count "$(sanitize_argjson_value '')" '{}'

# Correct: sanitize first, then pass to jq_safe
count=$(sanitize_argjson_value '' 0)
jq_safe -n --argjson count "$count" '{count: $count}'
```

## Version History

- **v1.0.0** (2026-02-03): Initial release
  - jq_safe wrapper function
  - validate_json helper
  - sanitize_argjson_value helper
  - Comprehensive test suite (17 tests)
  - Full documentation

## Related

- Original issue: jq --argjson errors in workflow execution
- Fix 1: Safety checks in metrics.sh (commit e86acb4)
- Fix 2: Debug logging for jq calls (commit 7c64ce6)
- Fix 3: jq_safe wrapper function (commit 0d26b57)

## See Also

- jq manual: https://jqlang.org/manual/
- Test file: `src/workflow/lib/test_jq_wrapper.sh`
- Module file: `src/workflow/lib/jq_wrapper.sh`
