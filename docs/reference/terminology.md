# Terminology Guide - AI Workflow Automation

**Version**: 1.0.0  
**Purpose**: Establish consistent terminology across all documentation  
**Status**: ✅ Authoritative Reference  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Purpose](#purpose)
- [Core Terminology](#core-terminology)
- [Architecture Components](#architecture-components)
- [Execution Concepts](#execution-concepts)
- [Configuration Terms](#configuration-terms)
- [Performance Terms](#performance-terms)
- [File Type Conventions](#file-type-conventions)
- [Usage Examples](#usage-examples)
- [Anti-Patterns](#anti-patterns)

---

## Purpose

This guide defines the **authoritative terminology** for the AI Workflow Automation project. All documentation, code comments, and communication should use these consistent terms.

### Why This Matters

- **Clarity**: Reduces confusion about component types
- **Maintainability**: Makes documentation updates easier
- **Professionalism**: Consistent terminology signals quality
- **Onboarding**: New contributors understand structure faster

---

## Core Terminology

### Module

**Definition**: A reusable library component providing specific functionality.

**Characteristics**:
- Located in `src/workflow/lib/`
- Sourced (not executed directly)
- Contains functions to be imported
- Single responsibility principle
- `.sh` file extension

**Examples**:
- `ai_helpers.sh` - AI integration module
- `change_detection.sh` - Change detection module
- `metrics.sh` - Metrics collection module
- `workflow_optimization.sh` - Optimization module

**Usage in Documentation**:
```
✅ "The change_detection module analyzes git changes"
✅ "Import the metrics module to collect data"
✅ "27 library modules provide workflow functionality"

❌ "The change_detection script analyzes..."
❌ "Source the metrics library..."
❌ "27 library scripts provide..."
```

**File Convention**: Always use `.sh` extension, never `.bash`

---

### Step

**Definition**: A discrete workflow stage implementing specific validation or analysis.

**Characteristics**:
- Located in `src/workflow/steps/`
- Executable implementation of workflow stage
- Numbered: `step_00_*.sh` through `step_14_*.sh`
- Contains `execute_step()` and `validate_step()` functions
- Can be run independently or as part of workflow

**Examples**:
- `step_00_analyze.sh` - Pre-analysis step
- `step_01_documentation.sh` - Documentation updates step
- `step_07_test_exec.sh` - Test execution step
- `step_14_ux_analysis.sh` - UX analysis step

**Usage in Documentation**:
```
✅ "Step 0 performs pre-flight analysis"
✅ "The documentation step updates markdown files"
✅ "Execute steps 0-14 in sequence"

❌ "The documentation module updates files"
❌ "Run the test execution script"
❌ "Step 7 module runs tests"
```

**Numbering**: Always include leading zero (Step 0, not Step 00)

---

### Script

**Definition**: A standalone executable file, typically the entry point or utility.

**Characteristics**:
- Directly executable (`./script.sh`)
- Main entry points or utilities
- Not sourced as library
- May orchestrate multiple modules/steps

**Examples**:
- `execute_tests_docs_workflow.sh` - Main workflow script
- `test_modules.sh` - Test suite script
- `setup.sh` - Installation script (if exists)

**Usage in Documentation**:
```
✅ "Run the workflow script"
✅ "The main script orchestrates execution"
✅ "Execute the test script to validate modules"

❌ "Run the workflow module"
❌ "The main module orchestrates..."
```

**Note**: Steps are NOT scripts (they're steps), modules are NOT scripts (they're modules).

---

### Orchestrator

**Definition**: The main coordinator that manages workflow execution.

**Characteristics**:
- Primary entry point: `execute_tests_docs_workflow.sh`
- Coordinates all 15 steps
- Manages parallel execution
- Handles checkpoints and metrics
- 2,009 lines of coordination logic

**Examples**:
- `execute_tests_docs_workflow.sh` - Main orchestrator
- Orchestrator modules in `src/workflow/orchestrators/` (if separate)

**Usage in Documentation**:
```
✅ "The orchestrator manages workflow execution"
✅ "Main orchestrator coordinates all steps"
✅ "Orchestrator handles parallel execution"

❌ "The workflow script manages execution"
❌ "Main module coordinates steps"
```

**Note**: There is ONE orchestrator; everything else it calls is a step or module.

---

## Architecture Components

### Library Module

**Full Term**: Library module  
**Short Form**: Module (in context)  
**Location**: `src/workflow/lib/`  
**Count**: 27 modules (as of v2.4.0)

**Examples**: `ai_helpers.sh`, `metrics.sh`, `dependency_graph.sh`

---

### Workflow Step

**Full Term**: Workflow step  
**Short Form**: Step (most contexts)  
**Location**: `src/workflow/steps/`  
**Count**: 15 steps (0-14)

**Examples**: Step 0 (Pre-Analysis), Step 7 (Test Execution), Step 14 (UX Analysis)

---

### Configuration File

**Full Term**: Configuration file  
**Acceptable**: Config file, YAML config  
**Location**: `src/workflow/config/`  
**Format**: YAML

**Examples**:
- `paths.yaml` - Path configuration
- `ai_helpers.yaml` - AI prompt templates
- `step_relevance.yaml` - Step relevance matrix
- `.workflow-config.yaml` - Project configuration (project root)

---

### Orchestrator Module

**Full Term**: Orchestrator module (or sub-orchestrator)  
**Location**: `src/workflow/orchestrators/` (if separated)  
**Purpose**: Specialized orchestration logic

**Examples**:
- `pre_flight.sh` - Pre-flight checks
- `validation.sh` - Validation orchestration
- `quality.sh` - Quality checks
- `finalization.sh` - Finalization logic

**Note**: As of v2.4.0, these may be integrated in main orchestrator.

---

## Execution Concepts

### Workflow

**Definition**: The complete 15-step automated pipeline.

**Usage**:
```
✅ "The workflow executes 15 steps"
✅ "Enable smart workflow execution"
✅ "Workflow completed in 12 minutes"

❌ "The script executes 15 steps"
❌ "Run the workflow module"
```

---

### Execution Run

**Definition**: A single instance of workflow execution.

**Identifier**: `workflow_YYYYMMDD_HHMMSS`

**Usage**:
```
✅ "The current execution run started at 18:37"
✅ "View logs for execution run workflow_20251223_183719"
✅ "Checkpoint saved for this run"

❌ "The current workflow run"
❌ "This execution's workflow"
```

---

### Checkpoint

**Definition**: Saved state allowing workflow resume.

**File**: `.checkpoints/workflow_YYYYMMDD_HHMMSS.checkpoint`

**Usage**:
```
✅ "Checkpoint saved after Step 4"
✅ "Resume from checkpoint"
✅ "Checkpoint contains step status"

❌ "Save point saved after Step 4"
❌ "Resume from savepoint"
```

---

### Parallel Group

**Definition**: Collection of steps that can execute simultaneously.

**Count**: 6 groups (Group 1-6)

**Usage**:
```
✅ "Group 1 contains 7 steps"
✅ "Steps execute in parallel groups"
✅ "Parallel group 1: Steps 1,3,4,5,8,13,14"

❌ "Parallel batch 1"
❌ "Concurrent group"
```

---

## Configuration Terms

### Project Kind

**Definition**: Project type classification for adaptive workflow.

**Values**: `shell_script_automation`, `nodejs_api`, `react_spa`, `python_app`, etc.

**Usage**:
```
✅ "Detected project kind: nodejs_api"
✅ "Configure project kind in .workflow-config.yaml"
✅ "Step relevance varies by project kind"

❌ "Project type: nodejs_api"
❌ "Application kind: nodejs_api"
```

---

### Tech Stack

**Definition**: Technology configuration for project.

**Configuration**: `.workflow-config.yaml`

**Usage**:
```
✅ "Tech stack: Node.js 25.2.1, Jest"
✅ "Primary language detected from tech stack"
✅ "Configure tech stack with --init-config"

❌ "Technology stack"
❌ "Tech setup"
```

---

### Step Relevance

**Definition**: Applicability of step to project kind.

**Values**: `required`, `recommended`, `optional`, `skip`

**Usage**:
```
✅ "Step 3 relevance: required (for shell projects)"
✅ "Step 14 marked as skip for APIs"
✅ "Relevance matrix in step_relevance.yaml"

❌ "Step applicability"
❌ "Step requirement level"
```

---

## Performance Terms

### Smart Execution

**Definition**: Change-based step skipping optimization.

**Flag**: `--smart-execution`

**Usage**:
```
✅ "Enable smart execution for faster runs"
✅ "Smart execution skipped 10 steps"
✅ "Change detection drives smart execution"

❌ "Intelligent execution"
❌ "Smart mode"
❌ "Adaptive execution"
```

---

### Parallel Execution

**Definition**: Simultaneous execution of independent steps.

**Flag**: `--parallel`

**Usage**:
```
✅ "Parallel execution reduces time 33%"
✅ "Enable parallel execution with --parallel"
✅ "7 steps run in parallel (Group 1)"

❌ "Concurrent execution"
❌ "Simultaneous mode"
❌ "Multi-threaded execution"
```

---

### AI Caching

**Definition**: Response caching for AI API calls.

**Feature**: AI response cache with TTL

**Usage**:
```
✅ "AI caching enabled by default"
✅ "Cache hit reduced API calls 80%"
✅ "24-hour TTL for cached responses"

❌ "AI response storage"
❌ "API call cache"
❌ "AI memory"
```

---

### Change Detection

**Definition**: Analysis of git changes to determine scope.

**Change Types**: docs-only, code-only, full-stack, etc.

**Usage**:
```
✅ "Change detection classified as docs-only"
✅ "Detected change type: code-only"
✅ "Change detection drives smart execution"

❌ "Diff analysis"
❌ "Change classification"
❌ "Git detection"
```

---

## File Type Conventions

### Shell Files

**Extension**: `.sh` (always, never `.bash`)

**Naming**:
- Modules: `descriptive_name.sh`
- Steps: `step_XX_name.sh`
- Scripts: `verb_noun.sh` or `descriptive_name.sh`

**Examples**:
```
✅ ai_helpers.sh
✅ step_00_analyze.sh
✅ execute_tests_docs_workflow.sh

❌ ai_helpers.bash
❌ step_0_analyze.sh (missing leading zero)
❌ execute-tests-docs-workflow.sh (hyphens)
```

---

### YAML Files

**Extension**: `.yaml` (preferred) or `.yml`

**Naming**: `descriptive_name.yaml`

**Examples**:
```
✅ step_relevance.yaml
✅ ai_helpers.yaml
✅ .workflow-config.yaml

❌ step-relevance.yaml (hyphens)
❌ aiHelpers.yaml (camelCase)
```

---

### Markdown Files

**Extension**: `.md`

**Naming**: `UPPERCASE_WITH_UNDERSCORES.md` or `Title_Case.md`

**Examples**:
```
✅ README.md
✅ CHECKPOINT_MANAGEMENT_GUIDE.md
✅ SMART_EXECUTION_GUIDE.md

❌ readme.md
❌ checkpoint-management-guide.md
```

---

## Usage Examples

### Correct Documentation Sentences

```
✅ "The ai_helpers module provides 14 AI personas."
✅ "Step 7 executes tests using the configured framework."
✅ "The orchestrator coordinates all 15 workflow steps."
✅ "Library modules are sourced, not executed directly."
✅ "Enable smart execution with the --smart-execution flag."
✅ "Parallel execution organizes steps into 6 groups."
✅ "Change detection classifies modifications as docs-only."
✅ "Configure project kind in .workflow-config.yaml."
✅ "The checkpoint system enables workflow resume."
✅ "AI caching reduces token usage by 60-80%."
```

---

### Incorrect Documentation Sentences (Anti-Patterns)

```
❌ "The ai_helpers script provides 14 AI personas."
   ✅ "The ai_helpers module provides 14 AI personas."

❌ "Run the test execution module."
   ✅ "Execute Step 7 (test execution)."

❌ "The workflow module coordinates steps."
   ✅ "The orchestrator coordinates steps."

❌ "Library scripts provide functionality."
   ✅ "Library modules provide functionality."

❌ "Enable intelligent execution mode."
   ✅ "Enable smart execution."

❌ "Concurrent execution improves performance."
   ✅ "Parallel execution improves performance."

❌ "Change classification detects modifications."
   ✅ "Change detection analyzes modifications."

❌ "Project type determines relevance."
   ✅ "Project kind determines relevance."

❌ "Save point created after each step."
   ✅ "Checkpoint created after each step."

❌ "API response cache reduces calls."
   ✅ "AI caching reduces API calls."
```

---

## Terminology Quick Reference

| Term | Definition | Location | Don't Say |
|------|------------|----------|-----------|
| **Module** | Reusable library component | `lib/*.sh` | Script, library |
| **Step** | Workflow stage | `steps/step_XX_*.sh` | Module, script |
| **Script** | Standalone executable | Root or utils | Module |
| **Orchestrator** | Main coordinator | `execute_tests_docs_workflow.sh` | Script, module |
| **Workflow** | 15-step pipeline | N/A | Process, pipeline |
| **Execution Run** | Single workflow instance | `workflow_YYYYMMDD_HHMMSS` | Run, workflow run |
| **Checkpoint** | Saved state | `.checkpoints/*.checkpoint` | Save point, savepoint |
| **Parallel Group** | Concurrent step set | Groups 1-6 | Batch, concurrent group |
| **Project Kind** | Project classification | `.workflow-config.yaml` | Project type |
| **Smart Execution** | Change-based skipping | `--smart-execution` | Intelligent mode |
| **Parallel Execution** | Simultaneous execution | `--parallel` | Concurrent execution |
| **AI Caching** | Response cache | `.ai_cache/` | API cache |
| **Change Detection** | Git change analysis | `change_detection.sh` | Diff analysis |

---

## Implementation Guidelines

### For Documentation Authors

1. **Use correct term** from this guide
2. **Be consistent** throughout document
3. **Don't mix** terminology (e.g., "module" and "script" for same thing)
4. **Reference this guide** when unsure

### For Code Comments

```bash
# ✅ Correct
# Load ai_helpers module
source "${WORKFLOW_ROOT}/lib/ai_helpers.sh"

# Execute Step 7 (test execution)
"${WORKFLOW_ROOT}/steps/step_07_test_exec.sh"

# ❌ Incorrect
# Load ai_helpers script
# Run the test execution module
```

### For Commit Messages

```
✅ "Fix: Correct change detection module logic"
✅ "Docs: Update Step 14 documentation"
✅ "Feat: Add checkpoint resume to orchestrator"

❌ "Fix: Correct change detection script logic"
❌ "Docs: Update test execution module docs"
❌ "Feat: Add checkpoint resume to workflow script"
```

---

## Verification Checklist

When writing or reviewing documentation, verify:

- [ ] "Module" used for library components (not "script")
- [ ] "Step" used for workflow stages (not "module" or "script")
- [ ] "Script" used only for standalone executables
- [ ] "Orchestrator" used for main coordinator
- [ ] "Smart execution" (not "intelligent" or "adaptive")
- [ ] "Parallel execution" (not "concurrent")
- [ ] "AI caching" (not "API cache")
- [ ] "Change detection" (not "change classification")
- [ ] "Project kind" (not "project type")
- [ ] "Checkpoint" (not "save point")

---

## Updating This Guide

**Process**:
1. Propose terminology change
2. Discuss with team/maintainers
3. Update this guide first
4. Update all documentation to match
5. Update code comments if needed

**Version History**:
- v1.0.0 (2025-12-23): Initial terminology guide

---

**Version**: 1.0.0  
**Status**: ✅ Authoritative Reference  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

**This is the authoritative terminology reference. All documentation must use these terms consistently.**
