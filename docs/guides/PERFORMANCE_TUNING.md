# Performance Tuning Guide

**Version**: 3.1.0  
**Last Updated**: 2026-02-08  
**Audience**: DevOps Engineers, Performance Engineers

## Overview

This guide helps you optimize AI Workflow Automation for maximum performance. Learn how to reduce execution time from 23 minutes baseline to 1.5 minutes (93% faster).

## Performance Characteristics

### Baseline Performance

| Scenario | Duration | Steps Executed | Description |
|----------|----------|----------------|-------------|
| Full Run (no optimization) | 23 min | 18 steps | All steps execute regardless of changes |
| Documentation only | 23 min | 18 steps | No optimization, runs everything |
| Code changes | 23 min | 18 steps | No optimization, runs everything |

### Optimized Performance

| Scenario | Smart Only | Parallel Only | Smart + Parallel | Smart + Parallel + ML |
|----------|-----------|---------------|------------------|----------------------|
| Docs only | 3.5 min (85%) | 15.5 min (33%) | 2.3 min (90%) | 1.5 min (93%) |
| Code changes | 14 min (40%) | 15.5 min (33%) | 10 min (57%) | 6-7 min (70-75%) |
| Full changes | 23 min (0%) | 15.5 min (33%) | 15.5 min (33%) | 10-11 min (52-57%) |

**Key Insight**: Combining all optimizations provides 52-93% time reduction depending on change type.

## Optimization Strategies

### Level 1: Smart Execution (40-85% faster)

**What it does**: Skips unnecessary steps based on detected changes.

```bash
./src/workflow/execute_tests_docs_workflow.sh --smart-execution
```

**How it works**:
- Analyzes git diff to detect changed files
- Categorizes changes: documentation, code, tests, config
- Automatically skips irrelevant steps

**Example**:
```bash
# Only README.md changed
# Skips: Steps 5 (test creation), 7 (test execution), 12 (UX analysis)
# Executes: Steps 0, 1, 2, 3, 4, 6, 8, 9, 10, 11, 13, 14, 15
# Result: 3.5 min instead of 23 min (85% faster)
```

**Best for**: Development workflows, documentation updates

### Level 2: Parallel Execution (33% faster)

**What it does**: Runs independent steps simultaneously.

```bash
./src/workflow/execute_tests_docs_workflow.sh --parallel
```

**How it works**:
- Analyzes step dependencies
- Groups independent steps
- Executes groups concurrently

**Execution Plan**:
```
Wave 1 (parallel): Step 0
Wave 2 (parallel): Steps 1, 2
Wave 3 (parallel): Steps 3, 4, 5
Wave 4 (parallel): Steps 6, 7
Wave 5 (parallel): Steps 8, 9, 10
Wave 6 (parallel): Steps 11, 12, 13
Wave 7 (parallel): Steps 14, 15
```

**Best for**: CI/CD pipelines, large codebases

### Level 3: ML Optimization (15-30% additional improvement)

**What it does**: Uses machine learning to predict step durations and optimize execution.

```bash
./src/workflow/execute_tests_docs_workflow.sh --ml-optimize
```

**Requirements**:
- 10+ historical workflow runs
- Metrics data in `src/workflow/metrics/history.jsonl`

**How it works**:
- Analyzes historical execution patterns
- Predicts step durations based on changes
- Recommends optimal execution strategy
- Learns from each run

**Check status**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Output:
# ML Optimization Status
# ======================
# Historical runs: 15
# Prediction accuracy: 87%
# Avg time savings: 42%
# Model last trained: 2026-02-07 18:30:00
# 
# Recommendations:
#   ✓ Smart execution enabled
#   ✓ Parallel execution enabled
#   ✓ ML optimization available
```

**Best for**: Mature projects with consistent workflow patterns

### Level 4: Multi-Stage Pipeline (Progressive Validation)

**What it does**: Runs workflow in 3 stages, stopping early if issues found.

```bash
./src/workflow/execute_tests_docs_workflow.sh --multi-stage
```

**Stages**:
1. **Fast Validation** (30 sec): Basic checks, syntax validation
2. **Core Validation** (2-4 min): Documentation, tests, basic quality
3. **Comprehensive** (10-15 min): UX analysis, full quality checks

**Statistics**:
- 80% of runs complete in Stage 1-2
- Only 20% need Stage 3
- Average time: 3 minutes (instead of 15-23 minutes)

**Pipeline Configuration**:
```bash
# View pipeline stages
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline

# Force all stages (manual trigger)
./src/workflow/execute_tests_docs_workflow.sh --multi-stage --manual-trigger
```

**Best for**: Development iterations, frequent commits

### Level 5: AI Response Caching (60-80% token reduction)

**What it does**: Caches AI responses for 24 hours.

**Enabled by default** - no configuration needed!

```bash
# Caching is automatic
./src/workflow/execute_tests_docs_workflow.sh

# Disable if needed
./src/workflow/execute_tests_docs_workflow.sh --no-ai-cache
```

**How it works**:
- Creates SHA256 hash of prompt + context
- Stores response in `.ai_cache/`
- Returns cached response if found within TTL (24 hours)
- Automatic cleanup every 24 hours

**Cache statistics**:
```bash
# View cache stats
cat src/workflow/.ai_cache/index.json | jq '.stats'

# Output:
{
  "total_entries": 42,
  "cache_hits": 156,
  "cache_misses": 38,
  "hit_rate": "80.4%",
  "avg_token_savings": "62%"
}
```

**Best for**: All workflows (always enabled by default)

## Combined Optimization

### Maximum Performance Configuration

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto
```

**Expected performance**:
- Documentation changes: **1.5-2 minutes** (93% faster)
- Code changes: **6-7 minutes** (70-75% faster)
- Full changes: **10-11 minutes** (52-57% faster)

### Development Workflow (Balance speed and thoroughness)

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --multi-stage \
  --auto
```

**Expected performance**:
- Fast validation: **30 seconds**
- Most runs: **2-4 minutes**
- Complex changes: **8-10 minutes**

### CI/CD Pipeline (Maximum reliability)

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --parallel \
  --multi-stage \
  --manual-trigger \
  --auto
```

**Configuration**:
- No smart execution (always comprehensive)
- Parallel for speed
- All stages forced
- Expected duration: **15-18 minutes**

## Fine-Tuning

### Skip Specific Steps

For repetitive workflows where you know certain steps aren't needed:

```bash
# Only run core steps
./src/workflow/execute_tests_docs_workflow.sh --steps 0,2,5,7

# Common combinations:
# Docs only: --steps 0,1,2,3,4
# Tests only: --steps 0,5,6,7
# Quality only: --steps 0,8,9,10,11
```

### Custom Workflow Templates

Create project-specific scripts:

```bash
# scripts/quick-check.sh
#!/bin/bash
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,2,7 \
  --smart-execution \
  --parallel \
  --dry-run

# scripts/full-validation.sh
#!/bin/bash
./src/workflow/execute_tests_docs_workflow.sh \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto-commit
```

### Environment Variables

```bash
# Set workflow optimization defaults
export WORKFLOW_SMART_EXECUTION=1
export WORKFLOW_PARALLEL=1
export WORKFLOW_ML_OPTIMIZE=1

# Now run without flags
./src/workflow/execute_tests_docs_workflow.sh --auto
```

## Monitoring Performance

### Metrics Collection

Every run generates metrics in `src/workflow/metrics/`:

```bash
# View latest metrics
cat src/workflow/metrics/current_run.json

{
  "run_id": "20260208_102345",
  "total_duration": 180,
  "steps_executed": 12,
  "steps_skipped": 6,
  "optimization_enabled": {
    "smart_execution": true,
    "parallel": true,
    "ml_optimize": true
  },
  "cache_stats": {
    "hits": 8,
    "misses": 4,
    "hit_rate": "66.7%"
  },
  "step_durations": {
    "step_00": 15,
    "step_02": 45,
    "step_05": 60,
    "step_07": 40,
    "step_15": 20
  }
}
```

### Historical Analysis

```bash
# View trends
jq -s '
  map({
    date: .timestamp,
    duration: .total_duration,
    optimization: .optimization_savings
  })
' src/workflow/metrics/history.jsonl

# Output:
[
  {"date": "2026-02-01", "duration": 1380, "optimization": "0%"},
  {"date": "2026-02-02", "duration": 450, "optimization": "67%"},
  {"date": "2026-02-03", "duration": 210, "optimization": "85%"},
  {"date": "2026-02-08", "duration": 90, "optimization": "93%"}
]
```

### Performance Dashboard

```bash
# Generate performance report
./src/workflow/lib/metrics.sh generate_report

# Output: src/workflow/metrics/performance_report.md
```

## Troubleshooting Performance Issues

### Issue 1: Smart Execution Not Skipping Steps

**Symptom**: All steps execute even with `--smart-execution`

**Diagnosis**:
```bash
# Check change detection
./src/workflow/lib/change_detection.sh

# Output shows what changes were detected
```

**Solutions**:
```bash
# Ensure clean git state
git status

# Verify baseline commit
git log -1

# Check for uncommitted changes
git diff --stat
```

### Issue 2: Parallel Execution Slow

**Symptom**: `--parallel` not improving performance

**Diagnosis**:
```bash
# Check CPU cores
nproc

# Check concurrent steps
grep -A 5 "Wave" src/workflow/logs/latest/*.log
```

**Solutions**:
```bash
# Reduce concurrent steps if low CPU
export MAX_PARALLEL_STEPS=2

# Increase for high-CPU systems
export MAX_PARALLEL_STEPS=8
```

### Issue 3: ML Optimization Not Working

**Symptom**: `--ml-optimize` has no effect

**Diagnosis**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status
```

**Solutions**:
```bash
# Need 10+ historical runs
# Run workflow multiple times to build history
for i in {1..10}; do
  ./src/workflow/execute_tests_docs_workflow.sh \
    --smart-execution \
    --parallel \
    --auto
  sleep 60
done

# ML optimization will become available
```

### Issue 4: Cache Not Helping

**Symptom**: Low cache hit rate

**Diagnosis**:
```bash
# Check cache stats
cat src/workflow/.ai_cache/index.json | jq '.stats.hit_rate'
```

**Solutions**:
```bash
# Cache is most effective for:
# - Repeated similar prompts
# - Documentation updates
# - Test generation with stable code

# Clear stale cache
find src/workflow/.ai_cache -type f -mtime +1 -delete

# Increase TTL if needed (in lib/ai_cache.sh)
CACHE_TTL_SECONDS=86400  # Default 24 hours
```

## Performance Benchmarks

### By Project Size

| Project Size | Full Run | Smart + Parallel | Smart + Parallel + ML |
|--------------|----------|------------------|----------------------|
| Small (&lt;1K LOC) | 5-8 min | 2-3 min | 1-2 min |
| Medium (1-10K LOC) | 15-20 min | 8-12 min | 5-7 min |
| Large (&gt;10K LOC) | 30-40 min | 18-25 min | 12-15 min |

### By Change Type

| Change Type | Files Affected | Optimized Duration | Steps Skipped |
|-------------|----------------|-------------------|---------------|
| Typo fix | 1 doc file | 1.5 min | 12/18 |
| Function add | 1 source + 1 test | 6 min | 8/18 |
| Feature add | 5 source + 5 tests + docs | 11 min | 3/18 |
| Refactor | 20+ files | 15 min | 1/18 |

## Best Practices

### For Development

1. **Use smart execution**: `--smart-execution` for all dev work
2. **Enable multi-stage**: `--multi-stage` for fast feedback
3. **Cache responses**: Keep caching enabled (default)
4. **Monitor metrics**: Review after each run

### For CI/CD

1. **Use parallel**: `--parallel` for speed
2. **Force all stages**: `--manual-trigger` for thoroughness
3. **Archive metrics**: Save for historical analysis
4. **Set timeouts**: Prevent hanging builds

### For Teams

1. **Share ML data**: Commit `metrics/history.jsonl` for team benefit
2. **Standardize options**: Use same optimization flags
3. **Review trends**: Weekly performance reviews
4. **Tune incrementally**: Add one optimization at a time

## Next Steps

- [Integration Guide](INTEGRATION_GUIDE.md) - CI/CD setup
- [Command-Line Reference](../user-guide/COMMAND_LINE_REFERENCE.md) - All options
- [Architecture Guide](../developer-guide/architecture.md) - How it works
- [Troubleshooting](../user-guide/troubleshooting.md) - Common issues
