# Artifact Cleanup Step Implementation

**Version**: 2.6.0  
**Date**: 2025-12-31  
**Status**: ✅ Implemented

## Overview

Added automatic cleanup of old workflow artifacts after successful workflow execution. This helps manage disk space by removing artifacts (backlogs, summaries, logs, checkpoints) older than a configurable retention period.

## Implementation Details

### New Module Function

**Location**: `src/workflow/lib/cleanup_handlers.sh`

**Function**: `cleanup_old_artifacts`

```bash
cleanup_old_artifacts <days> <dry_run>
```

**Parameters**:
- `days` - Remove artifacts older than this many days (default: 7)
- `dry_run` - If "true", only report what would be deleted (default: false)

**Features**:
- Cleans up workflow run directories in:
  - `.ai_workflow/backlog/`
  - `.ai_workflow/summaries/`
  - `.ai_workflow/logs/`
- Removes old checkpoint files from `.ai_workflow/checkpoints/`
- Provides detailed output with sizes and counts
- Safe dry-run mode for preview
- Handles missing directories gracefully

### Integration Point

**Location**: `src/workflow/execute_tests_docs_workflow.sh`

The cleanup runs automatically after successful workflow completion (line ~1600):

```bash
# Cleanup old workflow artifacts (v2.6.0)
# Removes artifacts older than specified days after successful workflow completion
# Default: 7 days, customizable with --cleanup-days, disable with --no-cleanup
if [[ "$DRY_RUN" != true ]] && [[ "${NO_CLEANUP:-false}" != "true" ]] && type -t cleanup_old_artifacts > /dev/null; then
    echo ""
    print_header "Artifact Cleanup"
    local cleanup_days="${CLEANUP_DAYS:-7}"
    cleanup_old_artifacts "$cleanup_days" false
fi
```

### Command-Line Options

**Location**: `src/workflow/lib/argument_parser.sh`

Added two new options:

```bash
--cleanup-days N   Remove artifacts older than N days (default: 7)
                   Runs automatically after successful completion
--no-cleanup       Disable automatic artifact cleanup
```

**Validation**:
- `--cleanup-days` requires a positive integer
- Invalid values produce clear error messages
- Options are mutually exclusive in practice (--no-cleanup takes precedence)

## Behavior

### Default Behavior

- **When**: Runs after successful workflow completion (all steps passed)
- **Retention**: Keeps artifacts from the last 7 days
- **Scope**: Cleans backlog, summaries, logs, and checkpoint directories
- **Conditions**: 
  - Only runs in non-dry-run mode
  - Can be disabled with `--no-cleanup`
  - Retention period configurable with `--cleanup-days`

### What Gets Cleaned

1. **Workflow Run Directories**:
   - `workflow_YYYYMMDD_HHMMSS/` older than N days
   - Includes all files and subdirectories within

2. **Checkpoint Files**:
   - `*.checkpoint` files older than N days
   - Located in `.ai_workflow/checkpoints/`

### What Gets Preserved

- Recent workflow runs (within retention period)
- Current workflow run (never removed)
- Non-workflow files in artifact directories
- All other .ai_workflow subdirectories

## Examples

### Basic Usage

```bash
# Default cleanup (7 days retention)
./execute_tests_docs_workflow.sh --auto

# Custom retention period (30 days)
./execute_tests_docs_workflow.sh --auto --cleanup-days 30

# Disable cleanup
./execute_tests_docs_workflow.sh --auto --no-cleanup

# Dry run mode (no cleanup happens)
./execute_tests_docs_workflow.sh --dry-run
```

### Manual Cleanup

```bash
# From within a script
source src/workflow/lib/cleanup_handlers.sh
export PROJECT_ROOT="/path/to/project"

# Dry run to see what would be deleted
cleanup_old_artifacts 7 true

# Actual cleanup
cleanup_old_artifacts 7 false

# Custom retention
cleanup_old_artifacts 30 false
```

## Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Artifact Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧹 Cleaning up workflow artifacts older than 7 days...
  Found 3 old run(s) in backlog/
    Removing: workflow_20241220_120000 (245K)
    Removing: workflow_20241221_083000 (189K)
    Removing: workflow_20241222_140000 (312K)
  Found 3 old run(s) in summaries/
    Removing: workflow_20241220_120000 (12K)
    Removing: workflow_20241221_083000 (8K)
    Removing: workflow_20241222_140000 (15K)
  Found 3 old run(s) in logs/
    Removing: workflow_20241220_120000 (45K)
    Removing: workflow_20241221_083000 (38K)
    Removing: workflow_20241222_140000 (52K)
  Found 2 old checkpoint(s)
    Removing: workflow_20241220_120000.checkpoint
    Removing: workflow_20241221_083000.checkpoint
✅ Cleanup complete - removed 9 run(s)
```

## Testing

### Manual Tests

1. **Function Availability**: Verify cleanup_old_artifacts exists
2. **Dry Run Mode**: Ensure no deletions occur in dry run
3. **Actual Cleanup**: Verify old artifacts are removed
4. **Recent Preservation**: Ensure recent artifacts are kept
5. **Custom Retention**: Test different retention periods
6. **Checkpoint Cleanup**: Verify checkpoint files are handled

### Integration Test

```bash
cd /home/mpb/Documents/GitHub/ai_workflow
source src/workflow/lib/cleanup_handlers.sh
export PROJECT_ROOT="$(pwd)"

# Test dry run
cleanup_old_artifacts 7 true

# Test actual cleanup
cleanup_old_artifacts 7 false
```

## Performance Impact

- **Execution Time**: < 1 second for typical artifact counts
- **Disk Space Savings**: Varies based on workflow run frequency
  - Average run: ~500KB (logs + backlog + summaries)
  - 10 old runs: ~5MB savings
  - 100 old runs: ~50MB savings

## Edge Cases Handled

1. **Missing Directories**: Skips cleanup gracefully if directories don't exist
2. **No Old Artifacts**: Reports "no artifacts to clean" message
3. **Permission Errors**: Continues cleanup even if individual deletions fail
4. **Concurrent Workflows**: Safe due to timestamp-based directory names
5. **Interrupted Workflows**: Partial runs are cleaned up like complete runs

## Future Enhancements

Potential improvements for future versions:

1. **Size-Based Cleanup**: Remove oldest artifacts when total size exceeds threshold
2. **Selective Cleanup**: Keep failures longer than successes for debugging
3. **Compression**: Archive old artifacts instead of deleting
4. **Metrics**: Track cleanup statistics (size freed, files removed)
5. **Scheduled Cleanup**: Background cleanup job independent of workflow runs

## Related Files

- `src/workflow/lib/cleanup_handlers.sh` - Core cleanup logic
- `src/workflow/lib/argument_parser.sh` - Command-line argument parsing
- `src/workflow/execute_tests_docs_workflow.sh` - Main workflow integration
- `test_cleanup_step.sh` - Comprehensive test suite (optional)

## Version History

- **v2.6.0** (2025-12-31): Initial implementation
  - Added `cleanup_old_artifacts` function
  - Added `--cleanup-days` and `--no-cleanup` options
  - Integrated into main workflow post-execution
  - 7-day default retention period

## Documentation Updates

Updated the following documentation files:
- Added command-line options to `--help` output
- Updated `argument_parser.sh` show_usage function
- Created this implementation document

## Conclusion

The artifact cleanup step successfully addresses disk space management concerns by automatically removing old workflow artifacts after successful execution. The implementation is safe, configurable, and integrates seamlessly with the existing workflow infrastructure.
