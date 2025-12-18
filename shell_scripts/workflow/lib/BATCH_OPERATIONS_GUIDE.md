# Batch Operations Performance Guide

## Overview

The workflow performance library now includes batch file reading and command execution functions to reduce API calls and improve overall workflow performance.

## Problem Statement

**Before Optimization**:
- Workflow made 25+ sequential read operations
- Each file read was a separate API call
- Total duration: ~3m 10s with 1.2M tokens cached
- Excessive I/O operations for small files

**After Optimization**:
- Batch multiple file reads into single operation
- Parallel command execution for independent operations
- Reduced API calls and improved throughput
- Better resource utilization

## New Batch Functions

### 1. batch_read_files()

Read multiple files in a single batch operation.

**Signature**:
```bash
batch_read_files <file1> <file2> <file3> ...
```

**Usage**:
```bash
# Source the performance library
source shell_scripts/workflow/lib/performance.sh

# Batch read multiple files
batch_read_files "$audit_output" "$test_results_file" "$outdated_output"

# Access content from associative array
echo "Audit output:"
echo "${FILE_CONTENTS[$audit_output]}"

echo "Test results:"
echo "${FILE_CONTENTS[$test_results_file]}"
```

**Benefits**:
- Single function call for multiple files
- Reduced overhead from multiple file operations
- Automatic error handling (empty string for missing files)
- Cleaner code with associative array access

### 2. batch_read_files_limited()

Read multiple files with line limits for performance.

**Signature**:
```bash
batch_read_files_limited <line_limit> <file1> <file2> ...
```

**Usage**:
```bash
# Read first 200 lines of multiple files
batch_read_files_limited 200 "$test_results_file" "$dependency_report" "$code_quality_report"

# Access truncated content
echo "Test results (first 200 lines):"
echo "${FILE_CONTENTS_LIMITED[$test_results_file]}"
```

**Use Cases**:
- Large log files where full content isn't needed
- Preview generation for AI prompts
- Reducing memory usage for large datasets

### 3. batch_command_outputs()

Execute multiple commands in parallel and collect outputs.

**Signature**:
```bash
batch_command_outputs <cmd1> <cmd2> <cmd3> ...
```

**Usage**:
```bash
# Execute multiple git commands in parallel
batch_command_outputs \
    "git status --short" \
    "git diff --stat" \
    "git log -1 --pretty=format:'%H'"

# Access command outputs
echo "Git status:"
echo "${CMD_OUTPUTS[git status --short]}"

echo "Diff stats:"
echo "${CMD_OUTPUTS[git diff --stat]}"
```

**Benefits**:
- True parallel execution with background jobs
- Automatic temporary file management
- Wait for all commands to complete
- Associative array for easy result access

## Migration Examples

### Before: Sequential File Reads

```bash
# OLD: Multiple sequential reads
test_output=$(cat "$test_results_file" 2>/dev/null | head -200 || echo "unavailable")
audit_data=$(cat "$audit_output" 2>/dev/null)
outdated_data=$(cat "$outdated_output" 2>/dev/null | jq -r '...' | head -20)
```

### After: Batched Reads

```bash
# NEW: Single batch operation
batch_read_files_limited 200 "$test_results_file"
batch_read_files "$audit_output" "$outdated_output"

test_output="${FILE_CONTENTS_LIMITED[$test_results_file]}"
audit_data="${FILE_CONTENTS[$audit_output]}"
outdated_data=$(echo "${FILE_CONTENTS[$outdated_output]}" | jq -r '...' | head -20)
```

### Before: Sequential Commands

```bash
# OLD: Sequential execution
git_status=$(git status --short)
git_diff=$(git diff --stat)
git_log=$(git log -1 --pretty=format:'%H')
```

### After: Parallel Commands

```bash
# NEW: Parallel execution
batch_command_outputs \
    "git status --short" \
    "git diff --stat" \
    "git log -1 --pretty=format:'%H'"

git_status="${CMD_OUTPUTS[git status --short]}"
git_diff="${CMD_OUTPUTS[git diff --stat]}"
git_log="${CMD_OUTPUTS[git log -1 --pretty=format:'%H']}"
```

## Best Practices

### 1. Group Related Operations

Batch files that are read in the same workflow step:

```bash
# Group dependency-related files
batch_read_files "$audit_output" "$outdated_output" "$package_lock"

# Group test-related files
batch_read_files_limited 200 "$test_results" "$test_coverage" "$test_errors"
```

### 2. Use Line Limits for Large Files

For files that might be very large, always use limited reads:

```bash
# Good: Limit large log files
batch_read_files_limited 200 "$workflow_log" "$debug_log"

# Bad: Reading entire large file into memory
batch_read_files "$workflow_log"  # Could cause memory issues
```

### 3. Parallel Independent Commands

Only batch commands that don't depend on each other:

```bash
# Good: Independent git operations
batch_command_outputs \
    "git status --short" \
    "git branch" \
    "git tag -l | head -5"

# Bad: Dependent operations (second depends on first)
# DON'T DO THIS:
batch_command_outputs \
    "git checkout main" \
    "git pull"  # Depends on checkout completing first
```

### 4. Error Handling

Always check if content exists before processing:

```bash
batch_read_files "$optional_file1" "$optional_file2"

if [[ -n "${FILE_CONTENTS[$optional_file1]}" ]]; then
    # File exists and has content
    process_file_content "${FILE_CONTENTS[$optional_file1]}"
else
    # File missing or empty
    echo "Warning: File not found or empty"
fi
```

## Performance Impact

### Expected Improvements

Based on typical workflow execution patterns:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| File read operations | 25+ sequential | 3-5 batches | 80% reduction |
| API calls | ~30 | ~10-15 | 50% reduction |
| I/O wait time | High | Low | 60% reduction |
| Estimated duration | 3m 10s | 1m 30s - 2m | 30-50% faster |

### Measurement

Use the built-in profiling functions:

```bash
# Profile a batched section
profile_section "batch_file_reads" batch_read_files "$file1" "$file2" "$file3"

# Generate performance report
generate_perf_report
```

## Integration with Workflow Steps

### Step 7 (Test Execution) - Example

```bash
# Before: Multiple reads
test_output=$(cat "$test_results_file" 2>/dev/null | head -200 || echo "unavailable")
coverage_data=$(cat "$coverage_file" 2>/dev/null)

# After: Batched
batch_read_files_limited 200 "$test_results_file"
batch_read_files "$coverage_file"
test_output="${FILE_CONTENTS_LIMITED[$test_results_file]}"
coverage_data="${FILE_CONTENTS[$coverage_file]}"
```

### Step 8 (Dependency Validation) - Example

```bash
# Before: Multiple reads
audit_data=$(cat "$audit_output" 2>/dev/null)
outdated_data=$(cat "$outdated_output" 2>/dev/null)
package_data=$(cat "$package_json" 2>/dev/null)

# After: Batched
batch_read_files "$audit_output" "$outdated_output" "$package_json"
audit_data="${FILE_CONTENTS[$audit_output]}"
outdated_data="${FILE_CONTENTS[$outdated_output]}"
package_data="${FILE_CONTENTS[$package_json]}"
```

## Testing

Test the batch functions:

```bash
# Create test files
echo "Test content 1" > /tmp/test1.txt
echo "Test content 2" > /tmp/test2.txt

# Test batch_read_files
source shell_scripts/workflow/lib/performance.sh
batch_read_files /tmp/test1.txt /tmp/test2.txt

# Verify results
[[ "${FILE_CONTENTS[/tmp/test1.txt]}" == "Test content 1" ]] && echo "✓ Test 1 passed"
[[ "${FILE_CONTENTS[/tmp/test2.txt]}" == "Test content 2" ]] && echo "✓ Test 2 passed"

# Cleanup
rm /tmp/test1.txt /tmp/test2.txt
```

## Troubleshooting

### Issue: Associative array not found

**Error**: `FILE_CONTENTS: unbound variable`

**Solution**: Ensure performance.sh is sourced before calling batch functions:
```bash
source shell_scripts/workflow/lib/performance.sh
```

### Issue: Command output truncated

**Error**: `CMD_OUTPUTS` contains partial output

**Solution**: Ensure commands complete before accessing results. The function automatically waits, but very long-running commands might need adjustment.

### Issue: Memory usage high

**Error**: Script consumes too much memory

**Solution**: Use `batch_read_files_limited` instead of `batch_read_files` for large files:
```bash
# Instead of:
batch_read_files "$large_log_file"

# Use:
batch_read_files_limited 500 "$large_log_file"
```

## Future Enhancements

Potential improvements for future versions:

1. **Streaming batch processing**: Process files as they're read rather than loading all into memory
2. **Configurable parallelism**: Allow max parallel jobs for `batch_command_outputs`
3. **Progress callbacks**: Show progress for long-running batch operations
4. **Retry logic**: Automatic retry for failed file reads or command executions
5. **Metrics collection**: Automatic performance metrics for batch operations

## Related Documentation

- Main workflow: `shell_scripts/workflow/execute_tests_docs_workflow.sh`
- Performance library: `shell_scripts/workflow/lib/performance.sh`
- File operations: `shell_scripts/workflow/lib/file_operations.sh`
- Workflow README: `shell_scripts/workflow/README.md`

## Version History

- **v2.0.1** (December 15, 2025): Added batch file operations for performance optimization
  - New: `batch_read_files()`
  - New: `batch_read_files_limited()`
  - New: `batch_command_outputs()`
  - Expected performance improvement: 30-50% faster workflow execution
