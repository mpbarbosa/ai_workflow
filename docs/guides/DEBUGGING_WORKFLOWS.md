# Debugging Workflows Guide

**Version**: v4.0.0  
**Last Updated**: 2026-02-08  
**Related Documentation**: [Troubleshooting Guide](COMPREHENSIVE_TROUBLESHOOTING_GUIDE.md), [Performance Tuning](PERFORMANCE_TUNING.md)

## Overview

This guide provides practical debugging techniques for diagnosing and resolving workflow execution issues. Learn how to use built-in debugging features, analyze logs, and troubleshoot common problems.

## Table of Contents

1. [Quick Debugging Strategies](#quick-debugging-strategies)
2. [Dry-Run Mode](#dry-run-mode)
3. [Checkpoint Resume](#checkpoint-resume)
4. [Log Analysis](#log-analysis)
5. [Step Isolation](#step-isolation)
6. [AI Response Debugging](#ai-response-debugging)
7. [Performance Debugging](#performance-debugging)
8. [Common Issues and Solutions](#common-issues-and-solutions)

---

## Quick Debugging Strategies

### Step 1: Enable Verbose Output

```bash
# Run with verbose logging
./src/workflow/execute_tests_docs_workflow.sh --verbose

# Or set environment variable
export WORKFLOW_DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh
```

### Step 2: Use Dry-Run Mode

```bash
# Preview execution without making changes
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Combine with specific steps
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution \
  --dry-run
```

### Step 3: Check Recent Logs

```bash
# View most recent workflow log
tail -f logs/workflow_*/execute_tests_docs_workflow.log

# Search for errors
grep -i "error\|failed\|fatal" logs/workflow_*/execute_tests_docs_workflow.log
```

---

## Dry-Run Mode

**Purpose**: Preview workflow execution without making any changes to files or executing destructive operations.

### Basic Usage

```bash
./src/workflow/execute_tests_docs_workflow.sh --dry-run
```

**What dry-run does**:
- ✅ Validates configuration
- ✅ Shows which steps would execute
- ✅ Displays dependency graph
- ✅ Checks file existence
- ❌ Does NOT modify files
- ❌ Does NOT call AI services
- ❌ Does NOT create artifacts

### Use Cases

1. **Validate Configuration**
   ```bash
   # Check if workflow-config.yaml is valid
   ./src/workflow/execute_tests_docs_workflow.sh \
     --config-file .workflow-config.yaml \
     --dry-run
   ```

2. **Test Step Selection**
   ```bash
   # Verify step names resolve correctly (v4.0.0)
   ./src/workflow/execute_tests_docs_workflow.sh \
     --steps documentation_updates,code_review,test_execution \
     --dry-run
   ```

3. **Preview Smart Execution**
   ```bash
   # See which steps smart execution would skip
   ./src/workflow/execute_tests_docs_workflow.sh \
     --smart-execution \
     --dry-run
   ```

### Example Output

```
[DRY-RUN] Configuration validated
[DRY-RUN] Detected changes: documentation, source code
[DRY-RUN] Steps to execute: 0, 2, 3, 5, 6, 7, 12
[DRY-RUN] Dependency graph:
  analyze → documentation_updates → code_review → test_execution
[DRY-RUN] Estimated duration: 14 minutes
[DRY-RUN] No changes will be made
```

---

## Checkpoint Resume

**Purpose**: Automatically continue from the last successfully completed step after a failure.

### How It Works

The workflow creates checkpoints after each successful step:

```
.workflow_state/
└── checkpoints/
    ├── step_00_analyze.checkpoint       # Step 0 completed
    ├── step_02_documentation.checkpoint # Step 2 completed
    └── current_run.json                 # Current execution state
```

### Automatic Resume

```bash
# First run - fails at step 5
./src/workflow/execute_tests_docs_workflow.sh

# Second run - automatically resumes from step 5
./src/workflow/execute_tests_docs_workflow.sh
# Output: "Resuming from checkpoint: step_04_config_validation"
```

### Force Fresh Start

```bash
# Ignore checkpoints and start from beginning
./src/workflow/execute_tests_docs_workflow.sh --no-resume
```

### Manual Checkpoint Management

```bash
# View current checkpoint state
cat .workflow_state/checkpoints/current_run.json

# Clear all checkpoints
rm -rf .workflow_state/checkpoints/*

# Clear specific checkpoint
rm .workflow_state/checkpoints/step_05_code_review.checkpoint
```

### Debugging with Checkpoints

**Scenario**: Step 5 fails intermittently

```bash
# 1. Enable checkpoint resume (default)
./src/workflow/execute_tests_docs_workflow.sh

# 2. If step 5 fails, investigate logs
tail -100 logs/workflow_*/step_05_code_review.log

# 3. Fix the issue (e.g., update configuration)
vim .workflow-config.yaml

# 4. Resume automatically
./src/workflow/execute_tests_docs_workflow.sh
# Workflow resumes from step 5
```

---

## Log Analysis

### Log Structure

```
logs/
└── workflow_20260208_223000/
    ├── execute_tests_docs_workflow.log  # Main workflow log
    ├── step_00_analyze.log              # Step-specific logs
    ├── step_02_documentation.log
    ├── ai_calls.log                     # AI interaction log (if enabled)
    └── metrics.log                      # Performance metrics
```

### Finding Errors

```bash
# Search for errors in all logs
grep -r "ERROR\|FATAL" logs/workflow_*/

# Find failed steps
grep "Step.*failed" logs/workflow_*/execute_tests_docs_workflow.log

# Check AI failures
grep "AI call failed" logs/workflow_*/ai_calls.log
```

### Common Log Patterns

#### Successful Step
```
[2026-02-08 22:30:15] INFO: Starting step 2: documentation_updates
[2026-02-08 22:30:20] INFO: Step 2 completed successfully (5.2s)
```

#### Failed Step
```
[2026-02-08 22:35:10] ERROR: Step 5 failed: code_review
[2026-02-08 22:35:10] ERROR: Exit code: 1
[2026-02-08 22:35:10] ERROR: See logs/workflow_20260208_223000/step_05_code_review.log
```

#### AI Call Issue
```
[2026-02-08 22:40:00] WARNING: AI call timeout after 60s
[2026-02-08 22:40:00] INFO: Retrying with exponential backoff (attempt 2/3)
```

### Log Analysis Commands

```bash
# Count errors by type
grep -oh "ERROR: [^:]*" logs/workflow_*/*.log | sort | uniq -c

# Show execution timeline
grep "Starting step\|completed successfully" logs/workflow_*/execute_tests_docs_workflow.log

# Extract AI cache hit rate
grep "cache hit rate" logs/workflow_*/metrics.log | tail -1

# Find slow steps (>60 seconds)
awk '/completed successfully/ { if ($NF ~ /[0-9]+s/ && $NF > 60) print }' \
  logs/workflow_*/execute_tests_docs_workflow.log
```

---

## Step Isolation

**Purpose**: Debug a single step in isolation to identify the root cause of failures.

### Run Single Step

```bash
# Execute only step 2 (documentation_updates)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates

# Legacy numeric syntax also supported
./src/workflow/execute_tests_docs_workflow.sh --steps 2
```

### Run Step Sequence

```bash
# Execute steps 2, 3, and 5
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,code_review,test_execution

# Mixed syntax (v4.0.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,documentation_updates,5
```

### Debug Step Execution

```bash
# Enable debug mode for specific step
WORKFLOW_DEBUG=1 \
  ./src/workflow/execute_tests_docs_workflow.sh \
  --steps code_review \
  --verbose

# Capture full output
./src/workflow/execute_tests_docs_workflow.sh \
  --steps test_execution \
  2>&1 | tee debug_output.log
```

### Step Dependencies

When debugging, consider dependencies:

```bash
# Show dependency graph
./src/workflow/execute_tests_docs_workflow.sh --show-graph

# Example output:
# analyze (0) → documentation_updates (2) → code_review (5)
#                                         → test_execution (7)
```

**Rule**: Always run prerequisite steps before the target step.

```bash
# WRONG: Skip dependencies
./src/workflow/execute_tests_docs_workflow.sh --steps code_review
# Error: Step 2 (documentation_updates) not completed

# CORRECT: Include dependencies
./src/workflow/execute_tests_docs_workflow.sh \
  --steps analyze,documentation_updates,code_review
```

---

## AI Response Debugging

### Enable AI Debug Logging

```bash
# Set environment variable
export AI_DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh

# AI calls will log to logs/workflow_*/ai_calls.log
```

### Check AI Cache

```bash
# View cache statistics
cat .ai_cache/index.json | jq '.statistics'

# Example output:
# {
#   "total_entries": 42,
#   "cache_hit_rate": 0.73,
#   "total_size_mb": 2.4,
#   "oldest_entry": "2026-02-07T10:30:00Z"
# }

# Find cached responses for specific prompt
grep -r "documentation_specialist" .ai_cache/ | head -5

# Clear cache to force fresh AI calls
rm -rf .ai_cache/*
```

### Disable AI Caching

```bash
# Run without AI response caching
./src/workflow/execute_tests_docs_workflow.sh --no-ai-cache
```

### AI Call Failures

**Symptom**: AI calls timeout or fail

```bash
# Check AI availability
gh copilot --version

# Test AI call manually
echo "Test prompt" | gh copilot suggest

# Increase timeout (if calls are timing out)
export AI_TIMEOUT=120
./src/workflow/execute_tests_docs_workflow.sh
```

**Common AI Issues**:

| Issue | Cause | Solution |
|-------|-------|----------|
| Timeout | Network latency | Increase `AI_TIMEOUT` environment variable |
| Rate limit | Too many requests | Enable AI caching (`--no-ai-cache` not set) |
| Authentication | GitHub CLI not logged in | Run `gh auth login` |
| Cache corruption | Invalid cache entries | Clear cache: `rm -rf .ai_cache/*` |

---

## Performance Debugging

### Collect Performance Metrics

```bash
# Run with metrics collection (enabled by default)
./src/workflow/execute_tests_docs_workflow.sh

# View metrics
cat metrics/current_run.json | jq '.'
```

### Analyze Slow Steps

```bash
# Show step durations
jq '.steps[] | {name: .name, duration: .duration_seconds}' \
  metrics/current_run.json

# Find steps taking >60 seconds
jq '.steps[] | select(.duration_seconds > 60)' \
  metrics/current_run.json
```

### Compare Historical Performance

```bash
# Average step durations from history
jq -s '[.[] | .steps[]] | group_by(.name) | 
  map({name: .[0].name, avg_duration: (map(.duration_seconds) | add / length)})' \
  metrics/history.jsonl
```

### Performance Optimization

1. **Enable Smart Execution**
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --smart-execution
   # Skips steps based on change detection (40-85% faster)
   ```

2. **Enable Parallel Execution**
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --parallel
   # Runs independent steps simultaneously (33% faster)
   ```

3. **Enable ML Optimization** (requires 10+ historical runs)
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --ml-optimize
   # Predictive step duration and smart recommendations
   ```

4. **Use Multi-Stage Pipeline** (v2.8.0+)
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --multi-stage
   # Progressive validation - 80%+ runs complete in first 2 stages
   ```

---

## Common Issues and Solutions

### Issue: "Step X failed with exit code 1"

**Diagnosis**:
```bash
# View step-specific log
tail -50 logs/workflow_*/step_0X_*.log

# Check for specific error patterns
grep -A 5 "ERROR" logs/workflow_*/step_0X_*.log
```

**Common Causes**:
1. Missing dependencies → Run health check: `./src/workflow/lib/health_check.sh`
2. Invalid configuration → Validate: `--dry-run`
3. Git repository issues → Check: `git status`
4. File permission issues → Check: `ls -la`

**Solution**:
```bash
# Fix configuration and resume
./src/workflow/execute_tests_docs_workflow.sh
# Automatically resumes from failed step
```

---

### Issue: "Checkpoint not found"

**Diagnosis**:
```bash
ls -la .workflow_state/checkpoints/
```

**Common Causes**:
1. Checkpoints cleared manually
2. Different workflow run ID
3. `.workflow_state/` directory deleted

**Solution**:
```bash
# Start fresh run
./src/workflow/execute_tests_docs_workflow.sh --no-resume
```

---

### Issue: "AI cache corruption"

**Symptoms**:
- AI calls fail with "invalid response"
- Cache hit rate is 0%
- Errors in AI call logs

**Diagnosis**:
```bash
# Check cache integrity
cat .ai_cache/index.json | jq '.'

# Look for malformed entries
find .ai_cache -name "*.json" -exec jq '.' {} \; 2>&1 | grep "parse error"
```

**Solution**:
```bash
# Clear cache
rm -rf .ai_cache/*

# Run workflow to rebuild cache
./src/workflow/execute_tests_docs_workflow.sh
```

---

### Issue: "Out of memory during parallel execution"

**Symptoms**:
- System freezes
- Steps killed with OOM
- High memory usage

**Diagnosis**:
```bash
# Check available memory
free -h

# Monitor during execution
watch -n 1 "ps aux | grep execute_tests_docs_workflow | head -20"
```

**Solution**:
```bash
# Disable parallel execution
./src/workflow/execute_tests_docs_workflow.sh --no-parallel

# Or limit parallel jobs
export MAX_PARALLEL_JOBS=2
./src/workflow/execute_tests_docs_workflow.sh --parallel
```

---

### Issue: "Git pre-commit hook fails"

**Diagnosis**:
```bash
# Test hooks manually
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# View hook logs
cat .git/hooks/pre-commit.log
```

**Common Causes**:
1. Uncommitted changes in workflow artifacts
2. Invalid configuration
3. Missing dependencies

**Solution**:
```bash
# Bypass hooks temporarily
git commit --no-verify -m "Your message"

# Or fix and retry
./src/workflow/execute_tests_docs_workflow.sh --install-hooks
git commit -m "Your message"
```

---

## Advanced Debugging Techniques

### Trace Execution with Bash Debug Mode

```bash
# Run workflow with bash tracing
bash -x src/workflow/execute_tests_docs_workflow.sh --steps analyze \
  2>&1 | tee trace.log

# View function calls
grep "^+" trace.log | head -50
```

### Interactive Debugging with Breakpoints

```bash
# Add breakpoint in step module (temporary)
# Edit: src/workflow/steps/code_review.sh

# Add these lines where you want to pause:
echo "DEBUG: Pausing execution. Press Enter to continue..."
read -r

# Run workflow normally
./src/workflow/execute_tests_docs_workflow.sh --steps code_review
```

### Network Debugging for AI Calls

```bash
# Test GitHub API connectivity
curl -H "Authorization: token $(gh auth token)" \
  https://api.github.com/user

# Check DNS resolution
nslookup api.github.com

# Test with verbose curl
export GH_DEBUG=api
./src/workflow/execute_tests_docs_workflow.sh --steps analyze
```

---

## Best Practices

1. **Start with Dry-Run**
   - Always use `--dry-run` before making changes
   - Validates configuration without side effects

2. **Enable Checkpoint Resume**
   - Let workflow resume automatically (default behavior)
   - Only use `--no-resume` for debugging specific steps

3. **Review Logs After Failures**
   - Check step-specific logs first
   - Look for ERROR and WARNING patterns
   - Search historical logs for patterns

4. **Isolate Problems**
   - Run single steps with `--steps`
   - Use `--verbose` for detailed output
   - Enable AI debug logging when needed

5. **Leverage Built-in Tools**
   - `--show-graph` - Visualize dependencies
   - `--show-ml-status` - Check ML system health
   - `--show-tech-stack` - Verify detected technologies

6. **Collect Performance Data**
   - Review `metrics/current_run.json` after each run
   - Compare with historical data
   - Identify slow steps for optimization

---

## Related Documentation

- **[Comprehensive Troubleshooting Guide](COMPREHENSIVE_TROUBLESHOOTING_GUIDE.md)** - Error codes and solutions
- **[Performance Tuning](PERFORMANCE_TUNING.md)** - Optimization strategies
- **[Command Line Reference](../user-guide/COMMAND_LINE_REFERENCE.md)** - All CLI options
- **[Architecture Guide](../architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md)** - System design
- **[Contributing Guide](../developer-guide/contributing.md)** - Development workflow

---

## Getting Help

If you encounter issues not covered in this guide:

1. Check existing documentation: [DOCUMENTATION_HUB.md](../DOCUMENTATION_HUB.md)
2. Review project issues: https://github.com/mpbarbosa/ai_workflow/issues
3. Run health check: `./src/workflow/lib/health_check.sh`
4. Collect diagnostic info:
   ```bash
   # Generate diagnostic report
   ./src/workflow/execute_tests_docs_workflow.sh --dry-run > diagnostics.txt
   git status >> diagnostics.txt
   env | grep WORKFLOW >> diagnostics.txt
   ```

---

**Version History**:
- v4.0.0 (2026-02-08): Initial debugging guide
