# Workflow Checkpoint Management - Complete Guide

**Version**: 1.0.0  
**Feature**: Checkpoint Resume System (v2.3.1+)  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [How Checkpoints Work](#how-checkpoints-work)
- [The --no-resume Flag](#the---no-resume-flag)
- [When to Use --no-resume](#when-to-use---no-resume)
- [Checkpoint File Format](#checkpoint-file-format)
- [Resume Behavior](#resume-behavior)
- [Use Cases & Scenarios](#use-cases--scenarios)
- [Checkpoint Management](#checkpoint-management)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Overview

### What are Checkpoints?

Checkpoints are automatic save points created after each workflow step completes successfully. They enable the workflow to resume from the last successful step if interrupted or if an error occurs.

### Key Features

- **Automatic Checkpointing**: Saves after each step (enabled by default)
- **Crash Recovery**: Resume after failures or interruptions
- **State Persistence**: Preserves execution context and variables
- **Idempotent**: Safe to resume without duplicating work
- **7-Day Retention**: Auto-cleanup after 7 days

### Benefits

✅ **Time Savings**: Don't re-run completed steps  
✅ **Failure Recovery**: Automatically resume after crashes  
✅ **Flexibility**: Continue interrupted workflows  
✅ **Resource Efficiency**: Avoid redundant AI API calls  

---

## Quick Start

### Default Behavior (Resume Enabled)

```bash
# Run workflow normally (checkpoints created automatically)
./execute_tests_docs_workflow.sh

# If interrupted, just run again - automatically resumes from last step
./execute_tests_docs_workflow.sh
# Output: "Resuming from Step 5 (last completed: Step 4)"
```

### Disable Resume (Fresh Start)

```bash
# Force fresh start from Step 0, ignore existing checkpoints
./execute_tests_docs_workflow.sh --no-resume
```

### Quick Decision Guide

**Use default (resume enabled)** when:
- ✅ Continuing interrupted workflow
- ✅ Recovering from failures
- ✅ Step 7 failed and you want to retry
- ✅ Normal execution

**Use `--no-resume`** when:
- ⚠️  Testing workflow changes
- ⚠️  Major project refactoring
- ⚠️  Prompts or steps modified
- ⚠️  Want completely fresh analysis

---

## How Checkpoints Work

### Checkpoint Lifecycle

1. **Workflow Start**: Check for existing checkpoint
2. **Resume Check**: If found and not `--no-resume`, load state
3. **Step Execution**: Execute steps, skip completed ones
4. **Save Checkpoint**: After each step completion
5. **Workflow End**: Mark workflow complete
6. **Auto-Cleanup**: Remove checkpoints >7 days old

### What Gets Saved

```bash
# Checkpoint file contents
WORKFLOW_RUN_ID="workflow_20251223_183719"
LAST_COMPLETED_STEP="4"
TIMESTAMP="2025-12-23 18:37:29"
CHANGE_IMPACT="Medium"
GIT_BRANCH="main"
GIT_COMMIT="46bc4c676de10a88e386ec322630156a5b45d626"

# Step Status
STEP_0_STATUS="✅"
STEP_1_STATUS="✅"
STEP_2_STATUS="✅"
STEP_3_STATUS="✅"
STEP_4_STATUS="✅"
STEP_5_STATUS="NOT_EXECUTED"
...

# Analysis Data
ANALYSIS_COMMITS="3"
ANALYSIS_MODIFIED="12"
CHANGE_SCOPE="code"
```

### Directory Structure

```
src/workflow/.checkpoints/
├── README.md
├── workflow_20251223_183719.checkpoint  # Most recent
├── workflow_20251222_140000.checkpoint
├── workflow_20251221_100000.checkpoint
└── ...
```

---

## The --no-resume Flag

### What It Does

The `--no-resume` flag **bypasses checkpoint resume** and forces a fresh workflow execution from Step 0.

**Command**:
```bash
./execute_tests_docs_workflow.sh --no-resume
```

### Behavior Comparison

| Aspect | Default (Resume) | With `--no-resume` |
|--------|------------------|-------------------|
| Checkpoint Check | ✅ Checks for existing | ❌ Ignores existing |
| Skip Completed | ✅ Skips done steps | ❌ Runs all steps |
| Fresh Analysis | ❌ Uses previous if available | ✅ Always fresh |
| Execution Time | ⚡ Faster (skips steps) | 🐢 Slower (runs all) |
| Use Case | Continue work | Test changes |

### When Added

**Version**: v2.3.1 (2025-12-18)  
**PR**: Critical fixes and checkpoint control  
**Reason**: Users needed way to force fresh start without manually deleting checkpoints

---

## When to Use --no-resume

### Scenario 1: Testing Workflow Changes

**Situation**: Modified workflow steps or prompts

```bash
# You edited step_01_documentation.sh
# Want to test changes from scratch

./execute_tests_docs_workflow.sh --no-resume
```

**Why**: Ensures modified steps execute with new logic, not skipped due to checkpoint.

---

### Scenario 2: Major Project Refactoring

**Situation**: Significant code or documentation restructuring

```bash
# Just refactored entire docs/ directory
# Need fresh analysis of new structure

./execute_tests_docs_workflow.sh --no-resume
```

**Why**: Old checkpoint based on previous structure may not be valid.

---

### Scenario 3: AI Prompt Updates

**Situation**: Updated AI prompts in `ai_helpers.yaml` or config

```bash
# Modified documentation_specialist prompt
# Want to see new prompt results

./execute_tests_docs_workflow.sh --no-resume
```

**Why**: Checkpoint might cause step skip, preventing new prompt from being tested.

---

### Scenario 4: Debugging Failures

**Situation**: Step keeps failing, need to see full execution

```bash
# Step 7 failed, but you're not sure why
# Want complete trace from beginning

./execute_tests_docs_workflow.sh --no-resume
```

**Why**: Fresh execution provides complete logs and context for debugging.

---

### Scenario 5: CI/CD Pipelines

**Situation**: Automated checks on every commit

```bash
# GitHub Actions workflow
# Each run should be independent

./execute_tests_docs_workflow.sh --no-resume --auto
```

**Why**: CI/CD runs should not depend on previous state; always fresh analysis.

---

### Scenario 6: Benchmarking

**Situation**: Measuring full workflow performance

```bash
# Testing optimization impact
# Need baseline timing for all steps

time ./execute_tests_docs_workflow.sh --no-resume
```

**Why**: Resume would skip steps, giving incomplete performance data.

---

### Scenario 7: Documentation Refresh

**Situation**: Want completely fresh AI analysis of docs

```bash
# Haven't run workflow in weeks
# Documentation evolved significantly

./execute_tests_docs_workflow.sh --no-resume --steps 1,2,12
```

**Why**: Old checkpoint may cause AI to miss recent doc changes.

---

## When NOT to Use --no-resume

### Scenario 1: Continuing After Failure

**Situation**: Step 7 (tests) failed, fixed the issue

```bash
# DON'T use --no-resume
# Just run normally to continue
./execute_tests_docs_workflow.sh

# Workflow automatically resumes from Step 7
```

**Why**: Resume saves time by skipping Steps 0-6 that already passed.

---

### Scenario 2: Interrupted Execution

**Situation**: Laptop died during Step 10

```bash
# DON'T use --no-resume
# Resume from where you left off
./execute_tests_docs_workflow.sh

# Continues from Step 10
```

**Why**: No need to re-run 9 completed steps; resume handles interruption.

---

### Scenario 3: Regular Development

**Situation**: Normal daily workflow execution

```bash
# DON'T use --no-resume
# Default behavior is optimal
./execute_tests_docs_workflow.sh --smart-execution
```

**Why**: Smart execution + resume = maximum efficiency.

---

## Checkpoint File Format

### File Structure

**Location**: `src/workflow/.checkpoints/workflow_YYYYMMDD_HHMMSS.checkpoint`  
**Format**: Bash-sourceable variable definitions  
**Size**: ~700 bytes

### Complete Example

```bash
# Workflow Checkpoint
# DO NOT EDIT MANUALLY

WORKFLOW_RUN_ID="workflow_20251223_183719"
LAST_COMPLETED_STEP="4"
TIMESTAMP="2025-12-23 18:37:29"
CHANGE_IMPACT="Medium"
GIT_BRANCH="main"
GIT_COMMIT="46bc4c676de10a88e386ec322630156a5b45d626"

# Step Status (15 steps total)
STEP_0_STATUS="✅"   # Pre-Analysis - Completed
STEP_1_STATUS="✅"   # Documentation - Completed
STEP_2_STATUS="✅"   # Consistency - Completed
STEP_3_STATUS="✅"   # Script Refs - Completed
STEP_4_STATUS="✅"   # Directory - Completed
STEP_5_STATUS="NOT_EXECUTED"
STEP_6_STATUS="NOT_EXECUTED"
STEP_7_STATUS="NOT_EXECUTED"
STEP_8_STATUS="NOT_EXECUTED"
STEP_9_STATUS="NOT_EXECUTED"
STEP_10_STATUS="NOT_EXECUTED"
STEP_11_STATUS="NOT_EXECUTED"
STEP_12_STATUS="NOT_EXECUTED"
STEP_13_STATUS="NOT_EXECUTED"
STEP_14_STATUS="NOT_EXECUTED"

# Analysis Data
ANALYSIS_COMMITS="3"
ANALYSIS_MODIFIED="12"
CHANGE_SCOPE="code"
ANALYZED_FILES="README.md,src/main.js,tests/test.js"
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `WORKFLOW_RUN_ID` | String | Unique workflow identifier |
| `LAST_COMPLETED_STEP` | Integer | Last successfully completed step (0-14) |
| `TIMESTAMP` | DateTime | When checkpoint was created |
| `CHANGE_IMPACT` | String | Low/Medium/High - from change detection |
| `GIT_BRANCH` | String | Git branch at execution time |
| `GIT_COMMIT` | String | Git commit hash |
| `STEP_X_STATUS` | String | Step status: `✅` (done) or `NOT_EXECUTED` |
| `ANALYSIS_COMMITS` | Integer | Number of commits analyzed |
| `ANALYSIS_MODIFIED` | Integer | Number of files modified |
| `CHANGE_SCOPE` | String | Type of changes: code/docs/both |

---

## Resume Behavior

### Automatic Resume Flow

```
┌─────────────────┐
│ Workflow Start  │
└────────┬────────┘
         │
         ▼
    ┌────────────────────┐
    │ Check for          │◄──── --no-resume flag?
    │ existing checkpoint│      (Skip this check)
    └────────┬───────────┘
             │
      ┌──────┴──────┐
      │ Yes         │ No
      │ (Found)     │ (Not found)
      ▼             ▼
┌──────────────┐ ┌──────────────┐
│ Load         │ │ Start from   │
│ Checkpoint   │ │ Step 0       │
└──────┬───────┘ └──────┬───────┘
       │                │
       ▼                ▼
┌───────────────────────────┐
│ Execute Steps             │
│ - Skip completed (✅)     │
│ - Run pending            │
└──────────┬────────────────┘
           │
           ▼
    ┌──────────────┐
    │ Save         │
    │ Checkpoint   │
    │ after each   │
    │ step         │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ Workflow     │
    │ Complete     │
    └──────────────┘
```

### Resume Output

**With Checkpoint**:
```
🔄 Resuming from checkpoint: workflow_20251223_183719
✅ Step 0 already completed - skipping
✅ Step 1 already completed - skipping
✅ Step 2 already completed - skipping
✅ Step 3 already completed - skipping
✅ Step 4 already completed - skipping
▶️  Continuing from Step 5...
```

**With --no-resume**:
```
🆕 Starting fresh workflow (--no-resume flag set)
▶️  Step 0: Pre-Analysis...
```

---

## Use Cases & Scenarios

### Use Case 1: Long-Running Workflow Interrupted

**Scenario**: Running full 15-step workflow, internet drops at Step 10

**Without Checkpoint**:
```bash
# Start over, lose 10 completed steps
./execute_tests_docs_workflow.sh
# Execution time: 23 minutes (full workflow)
```

**With Checkpoint (Default)**:
```bash
# Resume from Step 10 automatically
./execute_tests_docs_workflow.sh
# Execution time: 5 minutes (Steps 10-14 only)
# ⚡ 18 minutes saved
```

---

### Use Case 2: Step Failure During Execution

**Scenario**: Step 7 (Test Execution) fails due to broken test

**Action**:
1. Fix the failing test
2. Run workflow again (no flags needed)
3. Automatically resumes from Step 7

```bash
# Fix test
vim tests/failing_test.sh

# Resume workflow
./execute_tests_docs_workflow.sh
# Output: "Resuming from Step 7..."
```

---

### Use Case 3: Testing Prompt Changes

**Scenario**: Modified AI prompts, need to validate changes

**Action**:
```bash
# Clear checkpoints AND use --no-resume
rm -rf src/workflow/.checkpoints/*.checkpoint
./execute_tests_docs_workflow.sh --no-resume --steps 1,2

# Ensures new prompts tested from scratch
```

---

### Use Case 4: Incremental Development

**Scenario**: Working on documentation, running workflow multiple times

**Workflow**:
1. Edit docs
2. Run workflow (completes all steps)
3. Edit more docs
4. Run workflow again

**Behavior**:
- First run: Creates checkpoint after Step 14
- Second run: Starts fresh (new workflow ID)
- Each run independent

**Note**: Checkpoints are per-run, not incremental across runs.

---

## Checkpoint Management

### View Checkpoints

```bash
# List all checkpoints
ls -lh src/workflow/.checkpoints/*.checkpoint

# Count checkpoints
ls -1 src/workflow/.checkpoints/*.checkpoint | wc -l

# Show recent checkpoints
ls -lt src/workflow/.checkpoints/*.checkpoint | head -5
```

### Check Checkpoint Details

```bash
# View specific checkpoint
cat src/workflow/.checkpoints/workflow_20251223_183719.checkpoint

# Extract last completed step
grep "LAST_COMPLETED_STEP" src/workflow/.checkpoints/workflow_20251223_183719.checkpoint

# Show completed steps
grep "STATUS=\"✅\"" src/workflow/.checkpoints/workflow_20251223_183719.checkpoint
```

### Manual Cleanup

```bash
# Remove all checkpoints
rm -f src/workflow/.checkpoints/*.checkpoint

# Remove checkpoints older than 7 days (automatic)
find src/workflow/.checkpoints/ -name "*.checkpoint" -mtime +7 -delete

# Remove specific checkpoint
rm src/workflow/.checkpoints/workflow_20251223_183719.checkpoint
```

### Disk Usage

```bash
# Check total checkpoint size
du -sh src/workflow/.checkpoints/

# Per-file sizes
du -h src/workflow/.checkpoints/*.checkpoint | sort -hr | head -10

# Typical size: 600-800 bytes per checkpoint
```

---

## Troubleshooting

### Issue 1: Checkpoint Not Resuming

**Symptoms**:
- Workflow starts from Step 0 despite checkpoint existing
- No "Resuming from checkpoint" message

**Diagnosis**:
```bash
# Check if checkpoint exists
ls -la src/workflow/.checkpoints/*.checkpoint

# Check checkpoint is recent
ls -lt src/workflow/.checkpoints/*.checkpoint | head -1

# Verify checkpoint format
head src/workflow/.checkpoints/workflow_20251223_183719.checkpoint
```

**Solutions**:
1. Verify checkpoint file not corrupted
2. Ensure `--no-resume` flag not set
3. Check if workflow ID matches
4. Review logs for checkpoint errors

---

### Issue 2: Checkpoint Causes Errors

**Symptoms**:
- Errors when resuming
- Steps fail that worked before
- Strange behavior after resume

**Diagnosis**:
```bash
# Check git state matches checkpoint
git log -1 --oneline
grep "GIT_COMMIT" src/workflow/.checkpoints/*.checkpoint
```

**Solution**:
Use `--no-resume` to bypass problematic checkpoint:
```bash
./execute_tests_docs_workflow.sh --no-resume
```

---

### Issue 3: Too Many Checkpoints

**Symptoms**:
- Dozens of checkpoint files
- Using significant disk space

**Diagnosis**:
```bash
# Count checkpoints
ls -1 src/workflow/.checkpoints/*.checkpoint | wc -l

# Check age of oldest
ls -lt src/workflow/.checkpoints/*.checkpoint | tail -1
```

**Solution**:
Manual cleanup:
```bash
# Remove all old checkpoints
find src/workflow/.checkpoints/ -name "*.checkpoint" -mtime +3 -delete

# Keep only last 10
ls -t src/workflow/.checkpoints/*.checkpoint | tail -n +11 | xargs rm -f
```

---

### Issue 4: Checkpoint from Different Branch

**Symptoms**:
- Resumed workflow behaves unexpectedly
- Wrong files being analyzed

**Diagnosis**:
```bash
# Check branch in checkpoint
grep "GIT_BRANCH" src/workflow/.checkpoints/*.checkpoint

# Compare to current branch
git branch --show-current
```

**Solution**:
Use `--no-resume` when switching branches:
```bash
git checkout feature-branch
./execute_tests_docs_workflow.sh --no-resume
```

---

## Best Practices

### Do's ✅

1. **Let checkpoints work automatically** - Default behavior is optimal
2. **Use `--no-resume`** when testing workflow changes
3. **Clean old checkpoints periodically** - Automated after 7 days
4. **Resume after failures** - Save time, don't restart
5. **Use `--no-resume` in CI/CD** - Fresh analysis every time
6. **Keep checkpoints** during active development - Aids recovery

### Don'ts ❌

1. **Don't manually edit** checkpoint files - Can cause corruption
2. **Don't delete** checkpoint during execution - Can break resume
3. **Don't share** checkpoints between projects - Not portable
4. **Don't rely on** checkpoints across major changes - Use `--no-resume`
5. **Don't commit** checkpoints to git - Add `.checkpoints/` to `.gitignore`

### Decision Tree

```
Need to run workflow?
│
├─ Is this continuation of interrupted run?
│  └─ YES → Run normally (resume automatic)
│
├─ Testing workflow or prompt changes?
│  └─ YES → Use --no-resume
│
├─ Major refactoring done?
│  └─ YES → Use --no-resume
│
├─ CI/CD pipeline?
│  └─ YES → Use --no-resume --auto
│
└─ Normal development?
   └─ Run normally (resume automatic)
```

---

## Configuration

### Checkpoint Settings

**File**: `src/workflow/execute_tests_docs_workflow.sh`

```bash
# Checkpoint configuration
CHECKPOINT_DIR="src/workflow/.checkpoints"
CHECKPOINT_RETENTION_DAYS=7
NO_RESUME=false  # Default: resume enabled
```

### Modify Retention

```bash
# Edit execute_tests_docs_workflow.sh
# Change line ~93:
CHECKPOINT_RETENTION_DAYS=3  # Keep for 3 days instead of 7
```

### Disable Checkpoints Entirely

```bash
# Not recommended, but possible
# Edit execute_tests_docs_workflow.sh
# Comment out checkpoint logic (advanced users only)
```

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────┐
│  Checkpoint Management - Quick Reference                 │
├──────────────────────────────────────────────────────────┤
│  Default Behavior:                                       │
│  ./workflow.sh              # Auto-resume enabled        │
│                                                          │
│  Force Fresh Start:                                      │
│  ./workflow.sh --no-resume  # Ignore checkpoints        │
│                                                          │
│  View Checkpoints:                                       │
│  ls -lh src/workflow/.checkpoints/*.checkpoint          │
│                                                          │
│  Clear Checkpoints:                                      │
│  rm -f src/workflow/.checkpoints/*.checkpoint           │
│                                                          │
│  When to use --no-resume:                               │
│  • Testing workflow changes                             │
│  • Major refactoring                                    │
│  • Prompt modifications                                 │
│  • CI/CD pipelines                                      │
│  • Benchmarking                                         │
│                                                          │
│  When NOT to use --no-resume:                           │
│  • Continuing after failure                             │
│  • Interrupted execution                                │
│  • Regular development                                  │
│                                                          │
│  Retention: 7 days (automatic cleanup)                  │
│  File size: ~700 bytes per checkpoint                   │
│  Location: src/workflow/.checkpoints/                   │
└──────────────────────────────────────────────────────────┘
```

---

**Version**: 1.0.0  
**Status**: ✅ Complete  
**Feature**: v2.3.1+  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

**This is the authoritative guide for workflow checkpoint management and the --no-resume flag.**
