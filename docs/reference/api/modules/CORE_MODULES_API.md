# Core Modules API Reference

**Version**: v3.1.0  
**Last Updated**: 2026-02-08

This document provides complete API reference for the 12 core library modules that form the foundation of the AI Workflow Automation system.

## Table of Contents

1. [ai_helpers.sh](#ai_helperssh) - AI Integration
2. [tech_stack.sh](#tech_stacksh) - Technology Detection
3. [workflow_optimization.sh](#workflow_optimizationsh) - Smart Execution
4. [change_detection.sh](#change_detectionsh) - Git Change Analysis
5. [metrics.sh](#metricssh) - Performance Tracking
6. [performance.sh](#performancesh) - Parallel Execution
7. [step_adaptation.sh](#step_adaptationsh) - Dynamic Step Behavior
8. [config_wizard.sh](#config_wizardsh) - Interactive Configuration
9. [dependency_graph.sh](#dependency_graphsh) - Execution Dependencies
10. [health_check.sh](#health_checksh) - System Validation
11. [file_operations.sh](#file_operationssh) - Safe File Operations
12. [project_kind_config.sh](#project_kind_configsh) - Project Classification

---

## ai_helpers.sh

**Size**: 102K (~3,086 lines)  
**Purpose**: AI prompt templates, GitHub Copilot CLI integration, and project-aware personas

### Core Functions

#### `is_copilot_available()`
Check if GitHub Copilot CLI is installed and available.

```bash
# Usage
if is_copilot_available; then
    echo "Copilot CLI is available"
fi

# Returns
# 0 - Copilot CLI available
# 1 - Not available
```

#### `build_doc_analysis_prompt(doc_file, project_kind)`
Build documentation analysis prompt with project kind awareness.

```bash
# Usage
build_doc_analysis_prompt "docs/API.md" "nodejs_api"

# Parameters
# $1 - doc_file: Path to documentation file
# $2 - project_kind: Project type

# Returns
# Formatted prompt string optimized for documentation_specialist persona
```

#### `execute_copilot_batch(prompt_file, output_file, [model])`
Execute AI prompt using GitHub Copilot CLI with batch processing.

```bash
# Usage
execute_copilot_batch "prompt.txt" "output.md" "claude-sonnet-4.5"

# Parameters
# $1 - prompt_file: File containing the prompt
# $2 - output_file: Where to save AI response
# $3 - model: (Optional) AI model to use

# Returns
# 0 - Success
# 1 - Failure
```

**Dependencies**: config.sh, colors.sh, utils.sh, ai_prompt_builder.sh

---

## tech_stack.sh

**Size**: 47K (~400+ lines)  
**Purpose**: Auto-detect technology stack and provide adaptive workflow configuration

### Core Functions

#### `init_tech_stack([config_file])`
Initialize tech stack with config file or auto-detection.

```bash
# Usage
init_tech_stack ".workflow-config.yaml"

# Environment Variables Set
# - PRIMARY_LANGUAGE (javascript, python, go, etc.)
# - BUILD_SYSTEM (npm, pip, maven, cargo, etc.)
# - TEST_FRAMEWORK (jest, pytest, go test, junit)
```

#### `detect_tech_stack()`
Auto-detect primary language with confidence scoring.

```bash
# Usage
detect_tech_stack

# Returns
# Sets global: PRIMARY_LANGUAGE, DETECTION_CONFIDENCE
```

**Dependencies**: config.sh, colors.sh, utils.sh

---

## workflow_optimization.sh

**Size**: 31K (~200+ lines)  
**Purpose**: Conditional step execution, checkpointing, and parallel validation

### Core Functions

#### `should_skip_step_by_impact(step_number, impact_level)`
Determine if step can be skipped based on change analysis.

```bash
# Usage
if should_skip_step_by_impact 5 "LOW"; then
    echo "Skipping test planning - no code changes"
fi

# Parameters
# $1 - step_number: Workflow step (0-15)
# $2 - impact_level: LOW, MEDIUM, HIGH
```

#### `analyze_change_impact()`
Determine workflow scope from git changes.

```bash
# Usage
analyze_change_impact

# Returns
# Sets: CHANGE_IMPACT_LEVEL=<LOW|MEDIUM|HIGH>
```

**Dependencies**: git, logging functions, dependency_graph.sh

---

## change_detection.sh

**Size**: 17K (~200+ lines)  
**Purpose**: Auto-classify git changes for smart workflow execution

### Core Functions

#### `detect_change_type()`
Classify changes into categories.

```bash
# Usage
detect_change_type

# Returns
# docs-only, tests-only, config, scripts, code, mixed
# Sets: CHANGE_TYPE=<category>
```

#### `get_step_recommendations(change_type)`
Recommend which steps to execute.

```bash
# Usage
steps=$(get_step_recommendations "docs-only")
echo "Run steps: $steps"  # Output: 0,1,2,12,13
```

**Dependencies**: git

---

## metrics.sh

**Size**: 16K (~300+ lines)  
**Purpose**: Track workflow duration, success rates, and performance metrics

### Core Functions

#### `init_metrics()`
Initialize metrics collection system.

```bash
# Usage
init_metrics

# Creates
# - ${METRICS_DIR}/current_run.json
# - ${METRICS_DIR}/history.jsonl
# - ${METRICS_DIR}/summary.md
```

#### `start_step_timer(step_number, step_name)`
Begin timing a workflow step.

```bash
# Usage
start_step_timer 5 "Test Planning"
```

#### `stop_step_timer(step_number, [status])`
Stop timing and record completion.

```bash
# Usage
stop_step_timer 5 "success"

# Parameters
# $2 - status: success|failure|skipped
```

**Dependencies**: jq, date utilities

---

## performance.sh

**Size**: 16K (~250+ lines)  
**Purpose**: Parallel execution, caching, and optimized file operations

### Core Functions

#### `parallel_execute(max_jobs, command_array)`
Execute multiple commands in parallel with job control.

```bash
# Usage
commands=("step1_function" "step2_function")
parallel_execute 2 "${commands[@]}"
```

#### `fast_find(directory, pattern, [exclude_patterns])`
Optimized directory search.

```bash
# Usage
fast_find "src/" "*.js" "node_modules,dist"
```

**Dependencies**: git, ripgrep (optional)

---

## step_adaptation.sh

**Size**: 16K (~200+ lines)  
**Purpose**: Adapt step execution based on detected project kind

### Core Functions

#### `should_execute_step(step_number, project_kind)`
Determine if step is relevant for project type.

```bash
# Usage
if should_execute_step 11 "nodejs_api"; then
    echo "UX analysis relevant"
fi
```

**Dependencies**: project_kind_detection.sh, config.sh

---

## config_wizard.sh

**Size**: 16K (~400+ lines)  
**Purpose**: Interactive configuration wizard

### Core Functions

#### `run_config_wizard()`
Main interactive configuration wizard.

```bash
# Usage
run_config_wizard

# Generates
# .workflow-config.yaml with complete configuration
```

**Dependencies**: colors.sh, utils.sh

---

## dependency_graph.sh

**Size**: 15K (~250+ lines)  
**Purpose**: Visualize execution flow and identify parallelization opportunities

### Data Structures

```bash
# Step dependencies
declare -A STEP_DEPENDENCIES=(
    ["0"]=""
    ["1"]="0"
    ["2"]="0"
    ["3"]="1,2"
)

# Parallel groups
PARALLEL_GROUPS=(
    "1,2"
    "3,4"
)
```

**Dependencies**: None (data-driven)

---

## health_check.sh

**Size**: 15K (~200+ lines)  
**Purpose**: Verify workflow completion

### Core Functions

#### `verify_workflow_health()`
Check all workflow steps for completion status.

```bash
# Usage
verify_workflow_health

# Output
# ✅ Step 0: Pre-Analysis [PASSED]
# ❌ Step 2: Code Review [FAILED]
```

**Dependencies**: colors.sh, utils.sh

---

## file_operations.sh

**Size**: 15K (~250+ lines)  
**Purpose**: Safe file operations with pre-flight checks

### Core Functions

#### `safe_copy_file(source, destination, [options])`
Atomic copy with rollback capability.

```bash
# Usage
safe_copy_file "source.txt" "dest.txt" "--backup --verify"
```

**Dependencies**: None (pure bash)

---

## project_kind_config.sh

**Size**: 26K  
**Purpose**: Project classification and kind-specific configuration

### Core Functions

#### `load_project_kind_config(project_kind)`
Load configuration for specific project type.

```bash
# Usage
load_project_kind_config "nodejs_api"
```

### Supported Project Kinds (15+)

- shell_automation, nodejs_api, nodejs_cli, nodejs_library
- static_website, client_spa, react_spa, vue_spa
- python_api, python_cli, python_library
- go_service, rust_cli, java_api, documentation

**Dependencies**: config.sh, utils.sh

---

## Summary

These 12 core modules provide the foundation for the AI Workflow Automation system with consistent patterns, comprehensive error handling, and extensive documentation.

**Next**: See full documentation at [docs/reference/api/](../) for all 88 modules.
