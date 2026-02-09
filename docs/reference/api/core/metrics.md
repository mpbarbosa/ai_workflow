# metrics.sh - Workflow Metrics Collection API

**Version**: 2.0.0  
**Location**: `src/workflow/lib/metrics.sh`  
**Purpose**: Track duration, success rate, and step timing for workflow automation with comprehensive performance analytics

## Overview

The Metrics module provides comprehensive performance tracking for workflow execution. It records step timings, success rates, resource usage, and generates detailed reports and visualizations.

**Key Features**:
- Step-level timing and status tracking
- Workflow-level performance metrics
- Historical data collection (JSONL format)
- Phase tracking for multi-stage operations
- Real-time metrics updates
- Performance trend analysis
- Export to multiple formats (JSON, Markdown, CSV)

## Dependencies

**Required Modules**:
- `jq_wrapper.sh` - JSON processing
- `utils.sh` - Logging and utilities

**External Tools**:
- `jq` - JSON processing
- `date` - Time calculations

## Configuration

**Environment Variables**:
```bash
# Set by argument_parser.sh based on --target option
METRICS_DIR=""  # Metrics storage directory

# Auto-initialized by init_metrics()
METRICS_CURRENT=""   # Current run metrics (JSON)
METRICS_HISTORY=""   # Historical runs (JSONL)
METRICS_SUMMARY=""   # Human-readable summary (Markdown)

# Workflow-level tracking
WORKFLOW_START_EPOCH=0
WORKFLOW_END_EPOCH=0
WORKFLOW_DURATION=0
WORKFLOW_SUCCESS=false
WORKFLOW_STEPS_COMPLETED=0
WORKFLOW_STEPS_FAILED=0
WORKFLOW_STEPS_SKIPPED=0

# Step tracking (associative arrays)
declare -A STEP_START_TIMES
declare -A STEP_END_TIMES
declare -A STEP_DURATIONS
declare -A STEP_STATUSES

# Phase tracking
declare -A PHASE_START_TIMES
declare -A PHASE_DURATIONS
declare -A PHASE_DESCRIPTIONS
```

**Directory Structure**:
```
.ai_workflow/metrics/
├── current_run.json      # Current execution metrics
├── history.jsonl         # Historical run data (one JSON per line)
└── summary.md           # Human-readable summary
```

## Functions

### Initialization

#### `init_metrics()`

Initialize metrics collection system.

**Parameters**: None

**Returns**:
- Exit code: 0 on success, 1 if METRICS_DIR not set

**Side Effects**:
- Creates `METRICS_DIR` if needed
- Initializes `current_run.json`
- Creates `history.jsonl` if missing
- Sets `WORKFLOW_START_EPOCH`

**Example**:
```bash
# Must be called after validate_parsed_arguments()
validate_parsed_arguments
init_metrics

# Metrics now ready for tracking
record_step_start "step_01_analyze"
```

**JSON Structure** (current_run.json):
```json
{
  "workflow_run_id": "20260207_174530",
  "start_time": "2026-02-07T17:45:30+00:00",
  "start_epoch": 1739816730,
  "version": "3.1.0",
  "mode": "auto",
  "steps": {}
}
```

#### `get_execution_mode()`

Get current execution mode as string.

**Parameters**: None

**Returns**:
- String (stdout): "dry-run", "auto", "interactive", or "manual"
- Exit code: 0 (always succeeds)

**Example**:
```bash
mode=$(get_execution_mode)
echo "Running in $mode mode"
```

### Step Tracking

#### `record_step_start(step_name)`

Record the start time of a workflow step.

**Parameters**:
- `step_name` (string): Unique step identifier (e.g., "step_01_analyze")

**Returns**:
- Exit code: 0 on success

**Side Effects**:
- Sets `STEP_START_TIMES[$step_name]` to current epoch
- Updates `current_run.json`

**Example**:
```bash
record_step_start "step_01_analyze"

# Run step logic
run_analysis

record_step_end "step_01_analyze" "success"
```

#### `record_step_end(step_name, status)`

Record the end time and status of a workflow step.

**Parameters**:
- `step_name` (string): Step identifier (must match `record_step_start` call)
- `status` (string): "success", "failed", or "skipped"

**Returns**:
- Exit code: 0 on success, 1 if step not started

**Side Effects**:
- Sets `STEP_END_TIMES[$step_name]`
- Calculates `STEP_DURATIONS[$step_name]`
- Sets `STEP_STATUSES[$step_name]`
- Updates workflow counters
- Updates `current_run.json`

**Example**:
```bash
record_step_start "step_02_validate"

if validate_code; then
    record_step_end "step_02_validate" "success"
else
    record_step_end "step_02_validate" "failed"
fi
```

#### `get_step_duration(step_name)`

Get the duration of a completed step in seconds.

**Parameters**:
- `step_name` (string): Step identifier

**Returns**:
- Duration in seconds (stdout)
- Exit code: 0 if step completed, 1 if not found or incomplete

**Example**:
```bash
duration=$(get_step_duration "step_01_analyze")
echo "Analysis took $duration seconds"

# Format for display
minutes=$((duration / 60))
seconds=$((duration % 60))
echo "Duration: ${minutes}m ${seconds}s"
```

#### `get_step_status(step_name)`

Get the status of a step.

**Parameters**:
- `step_name` (string): Step identifier

**Returns**:
- Status string (stdout): "success", "failed", "skipped", or "not_run"
- Exit code: 0 (always succeeds)

**Example**:
```bash
status=$(get_step_status "step_03_test")

case "$status" in
    "success")
        echo "✓ Tests passed"
        ;;
    "failed")
        echo "✗ Tests failed"
        ;;
    "skipped")
        echo "⊘ Tests skipped"
        ;;
    "not_run")
        echo "- Tests not run yet"
        ;;
esac
```

### Phase Tracking

#### `record_phase_start(phase_name, description)`

Start tracking a sub-phase within a step (e.g., "validation", "analysis").

**Parameters**:
- `phase_name` (string): Unique phase identifier
- `description` (string): Human-readable description

**Returns**:
- Exit code: 0 on success

**Side Effects**:
- Sets `PHASE_START_TIMES[$phase_name]`
- Sets `PHASE_DESCRIPTIONS[$phase_name]`

**Example**:
```bash
record_phase_start "validation" "Validating input files"
validate_inputs
record_phase_end "validation"

record_phase_start "processing" "Processing data"
process_data
record_phase_end "processing"
```

#### `record_phase_end(phase_name)`

End tracking a phase and calculate duration.

**Parameters**:
- `phase_name` (string): Phase identifier (must match `record_phase_start`)

**Returns**:
- Exit code: 0 on success, 1 if phase not started

**Side Effects**:
- Calculates `PHASE_DURATIONS[$phase_name]`
- Logs phase completion

**Example**:
```bash
record_phase_start "compilation" "Compiling sources"

if compile_sources; then
    record_phase_end "compilation"
    echo "Compilation completed in $(get_phase_duration "compilation")s"
fi
```

#### `get_phase_duration(phase_name)`

Get duration of a completed phase.

**Parameters**:
- `phase_name` (string): Phase identifier

**Returns**:
- Duration in seconds (stdout)
- Exit code: 0 if phase completed, 1 otherwise

**Example**:
```bash
duration=$(get_phase_duration "validation")
echo "Validation phase: ${duration}s"
```

### Workflow-Level Metrics

#### `finalize_metrics()`

Complete metrics collection and generate final reports.

**Parameters**: None

**Returns**:
- Exit code: 0 on success

**Side Effects**:
- Sets `WORKFLOW_END_EPOCH`
- Calculates `WORKFLOW_DURATION`
- Appends to `history.jsonl`
- Generates `summary.md`
- Exports metrics to JSON

**Example**:
```bash
init_metrics

# Run workflow steps
for step in "${STEPS[@]}"; do
    record_step_start "$step"
    run_step "$step"
    record_step_end "$step" "success"
done

# Finalize and generate reports
finalize_metrics
```

**Generated Files**:
1. **history.jsonl** - Appends one JSON object per run
2. **summary.md** - Human-readable Markdown report
3. **current_run.json** - Updated with final metrics

#### `get_workflow_duration()`

Get total workflow duration in seconds.

**Parameters**: None

**Returns**:
- Duration in seconds (stdout)
- Exit code: 0 on success

**Example**:
```bash
duration=$(get_workflow_duration)
minutes=$((duration / 60))
echo "Total workflow time: ${minutes} minutes"
```

#### `get_success_rate()`

Calculate workflow success rate as percentage.

**Parameters**: None

**Returns**:
- Success rate (stdout): "0-100"
- Exit code: 0 on success

**Example**:
```bash
rate=$(get_success_rate)
echo "Success rate: ${rate}%"

if [[ $rate -lt 80 ]]; then
    echo "WARNING: Low success rate"
fi
```

### Reporting

#### `generate_metrics_summary()`

Generate human-readable Markdown summary.

**Parameters**: None

**Returns**:
- Exit code: 0 on success

**Side Effects**:
- Writes to `METRICS_SUMMARY`

**Example**:
```bash
finalize_metrics
generate_metrics_summary

cat "${METRICS_SUMMARY}"
```

**Summary Format**:
```markdown
# Workflow Execution Summary

**Run ID**: 20260207_174530  
**Version**: 3.1.0  
**Mode**: auto  
**Duration**: 15m 32s  
**Status**: ✓ Success

## Steps Executed

| Step | Duration | Status |
|------|----------|--------|
| step_01_analyze | 2m 15s | ✓ success |
| step_02_validate | 1m 30s | ✓ success |
| step_03_test | 8m 45s | ✓ success |

## Performance Metrics

- **Total Steps**: 15
- **Completed**: 15
- **Failed**: 0
- **Skipped**: 0
- **Success Rate**: 100%
```

#### `export_metrics_json(output_file)`

Export metrics to JSON file.

**Parameters**:
- `output_file` (string): Path for JSON export

**Returns**:
- Exit code: 0 on success, 1 on error

**Example**:
```bash
export_metrics_json "/tmp/metrics_export.json"

# Use with external tools
jq '.steps' /tmp/metrics_export.json
```

#### `export_metrics_csv(output_file)`

Export metrics to CSV format.

**Parameters**:
- `output_file` (string): Path for CSV export

**Returns**:
- Exit code: 0 on success

**Example**:
```bash
export_metrics_csv "/tmp/metrics.csv"

# CSV format:
# step_name,duration_seconds,status,start_time,end_time
```

### Historical Analysis

#### `get_historical_metrics([limit])`

Retrieve historical metrics data.

**Parameters**:
- `limit` (optional): Number of recent runs to return (default: 10)

**Returns**:
- JSON array of historical runs (stdout)
- Exit code: 0 on success

**Example**:
```bash
# Get last 5 runs
history=$(get_historical_metrics 5)

# Analyze trends
echo "$history" | jq '.[].workflow_duration' | awk '{sum+=$1; count++} END {print "Average:", sum/count, "seconds"}'
```

#### `calculate_performance_trend(step_name, [window])`

Calculate performance trend for a specific step.

**Parameters**:
- `step_name` (string): Step to analyze
- `window` (optional): Number of runs to analyze (default: 10)

**Returns**:
- Trend indicator (stdout): "improving", "stable", or "degrading"
- Exit code: 0 on success

**Example**:
```bash
trend=$(calculate_performance_trend "step_03_test" 20)

case "$trend" in
    "improving")
        echo "✓ Test performance is improving"
        ;;
    "degrading")
        echo "⚠ Test performance is degrading - investigate"
        ;;
esac
```

## Usage Patterns

### Basic Workflow Tracking

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

# Initialize
validate_parsed_arguments
init_metrics

# Track steps
for step in step_01 step_02 step_03; do
    record_step_start "$step"
    
    if run_step "$step"; then
        record_step_end "$step" "success"
    else
        record_step_end "$step" "failed"
        break
    fi
done

# Finalize
finalize_metrics
```

### Phase Tracking in Complex Steps

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

run_complex_step() {
    record_step_start "step_05_integration"
    
    # Phase 1: Setup
    record_phase_start "setup" "Setting up environment"
    setup_environment
    record_phase_end "setup"
    
    # Phase 2: Execution
    record_phase_start "execution" "Running integration tests"
    run_integration_tests
    record_phase_end "execution"
    
    # Phase 3: Cleanup
    record_phase_start "cleanup" "Cleaning up resources"
    cleanup_resources
    record_phase_end "cleanup"
    
    record_step_end "step_05_integration" "success"
}
```

### Performance Monitoring

```bash
#!/bin/bash
source "$(dirname "$0")/lib/metrics.sh"

# Check if step is running slow
check_step_performance() {
    local step="$1"
    local threshold_seconds="$2"
    
    record_step_start "$step"
    run_step "$step"
    record_step_end "$step" "success"
    
    local duration=$(get_step_duration "$step")
    
    if [[ $duration -gt $threshold_seconds ]]; then
        echo "WARNING: $step took ${duration}s (threshold: ${threshold_seconds}s)"
        return 1
    fi
    
    return 0
}

# Usage
check_step_performance "step_03_test" 300  # 5 minute threshold
```

## Error Handling

**Error Codes**:
- `0` - Success
- `1` - METRICS_DIR not set (must call validate_parsed_arguments first)
- `2` - Step not found or not started
- `3` - JSON processing error
- `4` - File I/O error

**Error Examples**:
```bash
# Handle initialization errors
if ! init_metrics; then
    echo "ERROR: Failed to initialize metrics"
    echo "Make sure METRICS_DIR is set by argument_parser.sh"
    exit 1
fi

# Handle step tracking errors
if ! record_step_end "step_99" "success"; then
    echo "WARNING: Step not found - was record_step_start called?"
fi
```

## Performance Considerations

- **Metrics overhead**: < 0.1% of total workflow time
- **Storage**: ~2KB per workflow run (JSONL format)
- **History limit**: Consider pruning after 1000+ runs

**Optimization Tips**:
- Use phase tracking sparingly (adds overhead)
- Don't track micro-operations
- Aggregate metrics periodically

## Testing

```bash
# Run module tests
cd src/workflow/lib
./test_metrics.sh

# Manual testing
init_metrics
record_step_start "test_step"
sleep 2
record_step_end "test_step" "success"
echo "Duration: $(get_step_duration "test_step")s"
```

## Related Modules

- **performance.sh** - Low-level timing utilities
- **performance_monitoring.sh** - Real-time monitoring
- **metrics_validation.sh** - Metrics data validation
- **dashboard.sh** - Visual metrics display

## Version History

- **2.0.0** (2025-12-18): Modular implementation
  - Added phase tracking
  - Added historical analysis
  - Added export functions
  - Improved JSON structure

## See Also

- [Performance Guide](../../guides/PERFORMANCE.md)
- [Metrics Dashboard](../../user-guide/feature-guide.md#metrics-dashboard)
- [Optimization Strategies](../../developer-guide/OPTIMIZATION.md)
