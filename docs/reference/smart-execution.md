# Smart Execution - Complete Change Detection Guide

**Version**: 1.0.0  
**Feature**: Smart Execution (v2.3.0+)  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Change Detection Logic](#change-detection-logic)
- [Change Type Classification](#change-type-classification)
- [File Pattern Matching](#file-pattern-matching)
- [Change Type → Step Matrix](#change-type--step-matrix)
- [File Pattern → Step Relevance](#file-pattern--step-relevance)
- [Classification Algorithm](#classification-algorithm)
- [Performance Impact](#performance-impact)
- [Use Cases](#use-cases)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Overview

### What is Smart Execution?

Smart execution analyzes git changes and skips workflow steps that aren't relevant to the modifications. Instead of running all 15 steps, only necessary steps execute based on what changed.

### Key Benefits

- **40-85% Faster**: Dramatic time savings for focused changes
- **Intelligent Skipping**: Automatic step relevance detection
- **Token Savings**: Fewer AI API calls for skipped steps
- **Still Safe**: Critical steps never skipped

> 📊 **Performance Evidence**: See [Performance Benchmarks](performance-benchmarks.md) for complete methodology, raw data, and validation of all performance claims.

### When Added

**Version**: v2.3.0 (2025-12-18)  
**Module**: `src/workflow/lib/change_detection.sh` (17K)  
**Configuration**: `src/workflow/config/step_relevance.yaml` (560 lines)

---

## Quick Start

### Enable Smart Execution

```bash
# Single flag to enable
./execute_tests_docs_workflow.sh --smart-execution
```

### Combined with Other Optimizations

```bash
# Recommended: Smart + Parallel
./execute_tests_docs_workflow.sh --smart-execution --parallel

# Ultimate optimization
./execute_tests_docs_workflow.sh --smart-execution --parallel --auto
```

### See What Gets Skipped

```bash
# During execution, you'll see:
"📊 Change Type: docs-only"
"⏩ Skipping Step 3 (not relevant for documentation changes)"
"⏩ Skipping Step 5 (not relevant for documentation changes)"
...
```

---

## Change Detection Logic

### How It Works

1. **Git Analysis**: Checks `git diff`, `git status`, and untracked files
2. **File Filtering**: Excludes workflow artifacts (logs, checkpoints, etc.)
3. **Pattern Matching**: Categorizes files by type (docs, code, tests, etc.)
4. **Classification**: Determines change type (docs-only, code-only, mixed, etc.)
5. **Step Selection**: Maps change type to relevant workflow steps
6. **Execution**: Runs only selected steps

### What Gets Analyzed

**Checked Files**:
- Modified files: `git diff --name-only HEAD`
- Staged files: `git diff --cached --name-only`
- Untracked files: `git ls-files --others --exclude-standard`

**Excluded (Workflow Artifacts)**:
- `src/workflow/backlog/*`
- `src/workflow/logs/*`
- `src/workflow/summaries/*`
- `src/workflow/metrics/*`
- `src/workflow/.checkpoints/*`
- `src/workflow/.ai_cache/*`
- `*.tmp`, `*.bak`, `*.swp`, `*~`
- `.DS_Store`, `Thumbs.db`

---

## Change Type Classification

### 8 Change Types

| Change Type | Description | Example Files |
|-------------|-------------|---------------|
| `docs-only` | Documentation changes only | `README.md`, `docs/**/*.md` |
| `tests-only` | Test files only | `*.test.js`, `*.spec.js`, `__tests__/*` |
| `config-only` | Configuration files only | `package.json`, `*.yaml`, `.gitignore` |
| `scripts-only` | Shell scripts only | `*.sh`, `src/workflow/*`, `Makefile` |
| `code-only` | Source code only | `*.js`, `*.ts`, `*.py`, `*.go` |
| `full-stack` | Multiple categories | Any combination of above |
| `mixed` | Mixed changes (fallback) | Unclear categorization |
| `unknown` | No changes detected | No modified files |

---

## File Pattern Matching

### Pattern Definitions

#### Documentation Patterns
```
*.md
*.txt
*.rst
docs/*
README*
CHANGELOG*
LICENSE*
CONTRIBUTING*
AUTHORS*
```

**Matches**:
- `README.md` ✅
- `docs/API.md` ✅
- `CHANGELOG.md` ✅
- `docs/guides/setup.md` ✅

**Doesn't Match**:
- `src/index.js` ❌
- `tests/test.js` ❌

---

#### Test Patterns
```
*test*.js
*spec*.js
__tests__/*
*.test.mjs
*.spec.mjs
*test*.sh
test_*.sh
```

**Matches**:
- `user.test.js` ✅
- `api.spec.js` ✅
- `__tests__/utils.js` ✅
- `test_utils.sh` ✅

**Doesn't Match**:
- `src/utils.js` ❌
- `README.md` ❌

---

#### Configuration Patterns
```
*.json
*.yaml
*.yml
*.toml
*.ini
.editorconfig
.gitignore
.nvmrc
.node-version
.mdlrc
```

**Matches**:
- `package.json` ✅
- `config.yaml` ✅
- `.gitignore` ✅
- `.workflow-config.yaml` ✅

**Doesn't Match**:
- `src/data.json` (data file) ⚠️
- `build/output.json` (generated) ⚠️

---

#### Shell Script Patterns
```
*.sh
src/workflow/*
Makefile
*.bash
```

**Matches**:
- `setup.sh` ✅
- `src/workflow/execute.sh` ✅
- `Makefile` ✅

**Doesn't Match**:
- `README.md` ❌
- `src/index.js` ❌

---

#### Source Code Patterns
```
*.js
*.mjs
*.ts
*.tsx
*.jsx
*.css
*.html
*.php
*.py
*.go
*.rs
*.java
*.c
*.cpp
```

**Matches**:
- `src/index.js` ✅
- `components/Button.tsx` ✅
- `app.py` ✅
- `main.go` ✅

**Doesn't Match**:
- `README.md` ❌
- `package.json` ❌

---

## Change Type → Step Matrix

### Complete Step Mapping

| Change Type | Steps Executed | Steps Skipped | Time Savings |
|-------------|-----------------|---------------|--------------|
| `docs-only` | 0, 1, 2, 11, 12 (5 steps) | 3, 4, 5, 6, 7, 8, 9, 10, 13, 14 (10 steps) | **85%** |
| `tests-only` | 0, 5, 6, 7, 11 (5 steps) | 1, 2, 3, 4, 8, 9, 10, 12, 13, 14 (10 steps) | **80%** |
| `config-only` | 0, 8, 11 (3 steps) | 1, 2, 3, 4, 5, 6, 7, 9, 10, 12, 13, 14 (12 steps) | **90%** |
| `scripts-only` | 0, 3, 4, 11 (4 steps) | 1, 2, 5, 6, 7, 8, 9, 10, 12, 13, 14 (11 steps) | **88%** |
| `code-only` | 0, 5, 6, 7, 9, 11 (6 steps) | 1, 2, 3, 4, 8, 10, 12, 13, 14 (9 steps) | **70%** |
| `full-stack` | 0-14 (all 15 steps) | None (0 steps) | **0%** |
| `mixed` | 0-14 (all 15 steps) | None (0 steps) | **0%** |
| `unknown` | 0-14 (all 15 steps) | None (0 steps) | **0%** |

---

### Detailed Step Breakdown

#### docs-only Changes

**Steps Executed** (5):
- ✅ **Step 0**: Pre-Analysis (always required)
- ✅ **Step 1**: Documentation Updates (primary target)
- ✅ **Step 2**: Consistency Checks (validate docs)
- ✅ **Step 11**: Git Finalization (always required)
- ✅ **Step 12**: Markdown Linting (validate formatting)

**Steps Skipped** (10):
- ⏩ **Step 3**: Script Refs (no shell scripts changed)
- ⏩ **Step 4**: Directory (structure unchanged)
- ⏩ **Step 5**: Test Review (no test changes)
- ⏩ **Step 6**: Test Generation (no code changes)
- ⏩ **Step 7**: Test Execution (no tests to run)
- ⏩ **Step 8**: Dependencies (config unchanged)
- ⏩ **Step 9**: Code Quality (no code changes)
- ⏩ **Step 10**: Context (minimal context needed)
- ⏩ **Step 13**: Prompt Engineer (not relevant)
- ⏩ **Step 14**: UX Analysis (no UI changes)

**Time**: 3-4 minutes (vs 23 minutes baseline)

---

#### tests-only Changes

**Steps Executed** (5):
- ✅ **Step 0**: Pre-Analysis
- ✅ **Step 5**: Test Review (review test changes)
- ✅ **Step 6**: Test Generation (generate additional tests)
- ✅ **Step 7**: Test Execution (run modified tests)
- ✅ **Step 11**: Git Finalization

**Steps Skipped** (10):
- ⏩ **Step 1**: Documentation (docs unchanged)
- ⏩ **Step 2**: Consistency (not needed)
- ⏩ **Step 3**: Script Refs (no scripts changed)
- ⏩ **Step 4**: Directory (structure unchanged)
- ⏩ **Step 8**: Dependencies (config unchanged)
- ⏩ **Step 9**: Code Quality (source code unchanged)
- ⏩ **Step 10**: Context (minimal context)
- ⏩ **Step 12**: Markdown Lint (no docs changed)
- ⏩ **Step 13**: Prompt Engineer (not relevant)
- ⏩ **Step 14**: UX Analysis (no UI changes)

**Time**: 4-5 minutes

---

#### config-only Changes

**Steps Executed** (3):
- ✅ **Step 0**: Pre-Analysis
- ✅ **Step 8**: Dependency Validation (check package.json, etc.)
- ✅ **Step 11**: Git Finalization

**Steps Skipped** (12):
- ⏩ All other steps (source and docs unchanged)

**Time**: 1.5-2 minutes

---

#### scripts-only Changes

**Steps Executed** (4):
- ✅ **Step 0**: Pre-Analysis
- ✅ **Step 3**: Script Reference Validation
- ✅ **Step 4**: Directory Structure Validation
- ✅ **Step 11**: Git Finalization

**Steps Skipped** (11):
- ⏩ Docs, tests, code quality (unchanged)

**Time**: 2-3 minutes

---

#### code-only Changes

**Steps Executed** (6):
- ✅ **Step 0**: Pre-Analysis
- ✅ **Step 5**: Test Review
- ✅ **Step 6**: Test Generation
- ✅ **Step 7**: Test Execution
- ✅ **Step 9**: Code Quality
- ✅ **Step 11**: Git Finalization

**Steps Skipped** (9):
- ⏩ Documentation steps (docs unchanged)
- ⏩ Script validation (no scripts changed)

**Time**: 10-14 minutes

---

#### full-stack Changes

**Steps Executed** (15):
- ✅ All steps (0-14)

**Steps Skipped** (0):
- None

**Time**: 20-25 minutes (baseline)

---

## File Pattern → Step Relevance

### Matrix: File Type → Required Steps

| File Type | Triggers Steps | Reason |
|-----------|---------------|---------|
| `*.md` (docs) | 0, 1, 2, 12 | Documentation analysis and validation |
| `*.test.js` (tests) | 0, 5, 6, 7 | Test review and execution |
| `package.json` | 0, 8 | Dependency validation |
| `*.sh` (scripts) | 0, 3, 4 | Script validation and structure |
| `*.js` (code) | 0, 5, 6, 7, 9 | Code quality and testing |
| `*.yaml` (config) | 0, 8 | Configuration validation |
| `README.md` | 0, 1, 2, 12 | Primary documentation |
| `*.tsx` (React) | 0, 5, 6, 7, 9, 14 | Code + UX analysis |
| `*.css` (styles) | 0, 9, 14 | Code quality + UX |

---

## Classification Algorithm

### Step-by-Step Process

```
1. Collect Changed Files
   ├─ git diff --name-only HEAD
   ├─ git diff --cached --name-only
   └─ git ls-files --others --exclude-standard

2. Filter Workflow Artifacts
   ├─ Remove logs, backlog, metrics
   ├─ Remove .checkpoints, .ai_cache
   └─ Remove .tmp, .bak, .swp files

3. Categorize Each File
   ├─ Match against docs patterns → docs_count++
   ├─ Match against tests patterns → tests_count++
   ├─ Match against config patterns → config_count++
   ├─ Match against scripts patterns → scripts_count++
   └─ Match against code patterns → code_count++

4. Count Active Categories
   categories_changed = sum of non-zero counts

5. Classify Change Type
   ├─ If categories_changed == 0 → "unknown"
   ├─ If categories_changed == 1:
   │  ├─ docs_count == total → "docs-only"
   │  ├─ tests_count == total → "tests-only"
   │  ├─ config_count == total → "config-only"
   │  ├─ scripts_count == total → "scripts-only"
   │  └─ code_count == total → "code-only"
   └─ If categories_changed >= 2 → "full-stack" or "mixed"

6. Map to Steps
   Lookup change type in STEP_RECOMMENDATIONS table

7. Execute Selected Steps
   Run only recommended steps, skip others
```

---

## Performance Impact

### Real-World Scenarios

#### Scenario 1: Documentation Update

**Changes**: Modified 3 markdown files in `docs/`

**Detection**:
```
Change Type: docs-only
Files Changed: 3
Categories: 1 (docs)
```

**Execution**:
```
✅ Step 0: Pre-Analysis (15s)
✅ Step 1: Documentation (140s)
✅ Step 2: Consistency (90s)
✅ Step 11: Git (60s)
✅ Step 12: Markdown Lint (45s)
───────────────────────────
Total: 350s (5.8 minutes)
```

**Comparison**:
- **Without Smart**: 23 minutes (all 15 steps)
- **With Smart**: 5.8 minutes
- **Savings**: 17.2 minutes (75% faster) ⚡

---

#### Scenario 2: Bug Fix in Source Code

**Changes**: Modified 2 JavaScript files

**Detection**:
```
Change Type: code-only
Files Changed: 2
Categories: 1 (code)
```

**Execution**:
```
✅ Step 0: Pre-Analysis (15s)
✅ Step 5: Test Review (120s)
✅ Step 6: Test Generation (180s)
✅ Step 7: Test Execution (240s)
✅ Step 9: Code Quality (150s)
✅ Step 11: Git (60s)
───────────────────────────
Total: 765s (12.75 minutes)
```

**Comparison**:
- **Without Smart**: 23 minutes
- **With Smart**: 12.75 minutes
- **Savings**: 10.25 minutes (45% faster) ⚡

---

#### Scenario 3: Configuration Update

**Changes**: Modified `package.json`

**Detection**:
```
Change Type: config-only
Files Changed: 1
Categories: 1 (config)
```

**Execution**:
```
✅ Step 0: Pre-Analysis (15s)
✅ Step 8: Dependencies (60s)
✅ Step 11: Git (60s)
───────────────────────────
Total: 135s (2.25 minutes)
```

**Comparison**:
- **Without Smart**: 23 minutes
- **With Smart**: 2.25 minutes
- **Savings**: 20.75 minutes (90% faster) ⚡

---

#### Scenario 4: Full Feature Development

**Changes**: Modified code, tests, docs, config

**Detection**:
```
Change Type: full-stack
Files Changed: 15
Categories: 4 (code, tests, docs, config)
```

**Execution**:
```
All 15 steps execute (baseline)
Total: 1380s (23 minutes)
```

**Comparison**:
- **Without Smart**: 23 minutes
- **With Smart**: 23 minutes
- **Savings**: None (full workflow needed) ❌

---

### Performance Summary

| Scenario | Without Smart | With Smart | Savings |
|----------|---------------|------------|---------|
| Docs Update | 23 min | 5.8 min | **75%** |
| Bug Fix | 23 min | 12.75 min | **45%** |
| Config Change | 23 min | 2.25 min | **90%** |
| Full Feature | 23 min | 23 min | 0% |

**Average Savings**: 40-85% for focused changes

---

## Use Cases

### Use Case 1: Documentation Maintenance

**Scenario**: Regular documentation updates, no code changes

**Command**:
```bash
./execute_tests_docs_workflow.sh --smart-execution
```

**Result**:
- Only docs-related steps run
- 5-6 minutes total
- 75-80% time savings ✅

---

### Use Case 2: Development Workflow

**Scenario**: Bug fixes and features during development

**Command**:
```bash
./execute_tests_docs_workflow.sh --smart-execution --parallel
```

**Result**:
- Adapts to change type automatically
- Code changes: 10-12 minutes
- Docs changes: 5-6 minutes
- Optimal for iterative development ✅

---

### Use Case 3: Pre-Commit Hook

**Scenario**: Fast validation before committing

**Command**:
```bash
./execute_tests_docs_workflow.sh --smart-execution --steps 0,2,3,9
```

**Result**:
- Combined with manual step selection
- Super fast pre-commit checks
- 2-3 minutes ✅

---

## Troubleshooting

### Issue 1: Wrong Change Type Detected

**Symptoms**:
- Smart execution classifies changes incorrectly
- Steps skipped that should run
- Steps run that should be skipped

**Diagnosis**:
```bash
# Check what files are considered changed
git diff --name-only HEAD
git status --short

# Check change detection logic
grep "CHANGE_TYPE" src/workflow/logs/workflow_*/workflow.log
```

**Solutions**:
1. **Verify git status**: Ensure committed changes match intent
2. **Check file patterns**: Review pattern matching in `change_detection.sh`
3. **Override if needed**: Use `--steps` flag to force specific steps
4. **Disable smart execution**: Use without `--smart-execution` for full workflow

---

### Issue 2: Critical Steps Skipped

**Symptoms**:
- Important validation steps not running
- Feeling unsafe about skipped steps

**Diagnosis**:
```bash
# See which steps were skipped
grep "Skipping Step" src/workflow/logs/workflow_*/workflow.log
```

**Solutions**:
1. **Run full workflow**: Disable `--smart-execution`
2. **Add specific steps**: Use `--steps 0,5,7,11` to force key steps
3. **Classify as full-stack**: Make changes across multiple categories

---

### Issue 3: No Time Savings

**Symptoms**:
- Smart execution doesn't reduce time
- All steps still running

**Diagnosis**:
```bash
# Check detected change type
grep "Change Type:" src/workflow/logs/workflow_*/workflow.log

# Check if classified as full-stack
```

**Solutions**:
- **Likely full-stack**: Changes span multiple categories
- **Expected behavior**: Smart execution correctly detected need for all steps
- **Make focused changes**: Separate docs, code, test changes into different commits

---

## Best Practices

### Do's ✅

1. **Use for focused changes** - Maximum benefit
2. **Combine with parallel** - Double optimization
3. **Trust the detection** - Algorithm is well-tested
4. **Make atomic commits** - One type of change per commit
5. **Review skipped steps** - Verify correct detection

### Don'ts ❌

1. **Don't use for major refactors** - Full workflow safer
2. **Don't mix unrelated changes** - Triggers full-stack
3. **Don't bypass critical steps** - Safety > speed
4. **Don't assume always faster** - Full-stack needs all steps
5. **Don't forget to test** - Skipped steps mean less validation

### Recommendations

**For Documentation Work**:
```bash
# Perfect for doc-only changes
./execute_tests_docs_workflow.sh --smart-execution
```

**For Development**:
```bash
# Smart + Parallel for best optimization
./execute_tests_docs_workflow.sh --smart-execution --parallel
```

**For Major Changes**:
```bash
# Skip smart execution, run everything
./execute_tests_docs_workflow.sh --parallel
```

**For CI/CD**:
```bash
# Smart can work, but consider full validation
./execute_tests_docs_workflow.sh --smart-execution --auto --no-resume
```

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────┐
│  Smart Execution - Quick Reference                       │
├──────────────────────────────────────────────────────────┤
│  Enable Smart:                                           │
│  ./workflow.sh --smart-execution                        │
│                                                          │
│  Change Types:                                           │
│  • docs-only: 5 steps (85% faster)                      │
│  • tests-only: 5 steps (80% faster)                     │
│  • config-only: 3 steps (90% faster)                    │
│  • scripts-only: 4 steps (88% faster)                   │
│  • code-only: 6 steps (70% faster)                      │
│  • full-stack: 15 steps (0% faster)                     │
│                                                          │
│  File Patterns:                                          │
│  • Docs: *.md, docs/*, README*                          │
│  • Tests: *.test.js, *.spec.js, __tests__/*            │
│  • Config: *.json, *.yaml, .gitignore                  │
│  • Scripts: *.sh, Makefile                             │
│  • Code: *.js, *.ts, *.py, *.go                        │
│                                                          │
│  Best For:                                               │
│  • Focused changes (docs, tests, config)               │
│  • Iterative development                               │
│  • Fast pre-commit checks                              │
│                                                          │
│  Not For:                                                │
│  • Major refactoring                                    │
│  • Mixed change types                                   │
│  • First-time full validation                          │
└──────────────────────────────────────────────────────────┘
```

---

**Version**: 1.0.0  
**Status**: ✅ Complete  
**Feature**: v2.3.0+  
**Module**: `src/workflow/lib/change_detection.sh` (17K)  
**Configuration**: `src/workflow/config/step_relevance.yaml` (560 lines)  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

**This is the authoritative guide for smart execution and change detection logic.**
