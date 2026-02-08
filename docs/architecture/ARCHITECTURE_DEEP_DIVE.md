# Architecture Deep Dive

**Version**: 3.1.0  
**Last Updated**: 2026-02-08  
**Audience**: Developers, System Architects

## Table of Contents

- [System Architecture](#system-architecture)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Module Architecture](#module-architecture)
- [Design Patterns](#design-patterns)
- [Extension Points](#extension-points)

---

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────┐
│                   User Interface                         │
│  (execute_tests_docs_workflow.sh + CLI arguments)       │
└───────────────────┬─────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────┐
│              Orchestration Layer                         │
│  ┌──────────────┬──────────────┬──────────────┐        │
│  │ Pre-Flight   │ Validation   │ Quality      │        │
│  │ Checks       │ Engine       │ Assurance    │        │
│  └──────────────┴──────────────┴──────────────┘        │
└───────────────────┬─────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────┐
│              Core Library Layer                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Change Detection │ Metrics │ AI Helpers          │  │
│  │ Tech Stack      │ Config  │ Optimization        │  │
│  │ File Ops        │ Git     │ Validation          │  │
│  └──────────────────────────────────────────────────┘  │
└───────────────────┬─────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────┐
│              Step Execution Layer                        │
│  18 Specialized Steps (0a, 0b, 0-15)                   │
│  Each with validate() and execute() functions           │
└───────────────────┬─────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────┐
│              External Integrations                       │
│  ┌──────────────┬──────────────┬──────────────┐        │
│  │ GitHub       │ Git          │ Test         │        │
│  │ Copilot CLI  │ Repository   │ Frameworks   │        │
│  └──────────────┴──────────────┴──────────────┘        │
└─────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Layer | Components | Responsibilities |
|-------|-----------|------------------|
| **User Interface** | CLI, Arguments | Parse options, validate input, display output |
| **Orchestration** | Pre-flight, Validation, Quality, Finalization | Coordinate execution, manage workflow lifecycle |
| **Core Library** | 62 modules | Business logic, utilities, integrations |
| **Step Execution** | 18 step modules | Specialized workflow tasks |
| **External** | Copilot CLI, Git, Tests | Third-party integrations |

---

## Core Components

### 1. Main Orchestrator

**File**: `src/workflow/execute_tests_docs_workflow.sh`  
**Size**: 2,009 lines  
**Role**: Primary entry point and workflow coordinator

**Key Functions**:
```bash
main() {
    # 1. Parse arguments
    parse_arguments "$@"
    
    # 2. Pre-flight checks
    run_preflight_checks
    
    # 3. Load configuration
    load_workflow_config
    
    # 4. Execute workflow
    if [[ $USE_MULTI_STAGE == true ]]; then
        execute_multi_stage_pipeline
    else
        execute_linear_workflow
    fi
    
    # 5. Finalize
    finalize_workflow
}
```

**Dependencies**:
- All 62 library modules (sourced dynamically)
- 4 orchestrator modules (pre_flight, validation, quality, finalization)
- Configuration from `.workflow_core/config/`

### 2. Orchestrator Modules

Located in `src/workflow/orchestrators/` (630 lines total):

#### pre_flight.sh
**Purpose**: System validation before workflow execution

```bash
run_preflight_checks() {
    check_bash_version      # Requires Bash 4.0+
    check_git_available     # Git required
    check_git_repository    # Must be in git repo
    check_node_available    # Node.js 25.2.1+
    check_copilot_cli       # Optional but recommended
    validate_config_files   # .workflow-config.yaml
}
```

#### validation.sh
**Purpose**: Input validation and step verification

```bash
validate_workflow_state() {
    validate_step_numbers       # Steps 0-15
    validate_dependencies       # Check step dependencies
    validate_file_access        # Read/write permissions
    validate_git_state         # Clean working directory
}
```

#### quality.sh
**Purpose**: Code quality checks and metrics validation

```bash
run_quality_checks() {
    validate_shell_scripts      # ShellCheck integration
    check_code_style           # Style guidelines
    validate_test_coverage     # Coverage thresholds
    check_documentation        # Doc completeness
}
```

#### finalization.sh
**Purpose**: Cleanup and summary generation

```bash
finalize_workflow() {
    generate_summary           # AI-powered summary
    update_metrics            # Save performance data
    cleanup_temp_files        # Remove artifacts
    display_results           # User feedback
}
```

### 3. Core Library Modules

#### Change Detection (`change_detection.sh` - 17K)

**Purpose**: Analyze git diff to determine workflow optimization

```bash
# Key Functions
analyze_changes() {
    local changed_files=$(git diff --name-only HEAD)
    
    categorize_changes "$changed_files"
    # Categories: docs, code, tests, config
    
    determine_execution_plan
    # Returns: which steps to execute/skip
}

has_documentation_changes() {
    # Check for .md, .txt, docs/ changes
    [[ -n $(git diff --name-only HEAD | grep -E '\.(md|txt|adoc)$') ]]
}

has_code_changes() {
    # Check for source code changes
    [[ -n $(git diff --name-only HEAD | grep -E '\.(js|ts|py|sh|go|java)$') ]]
}
```

**Used by**: Smart execution optimization

#### AI Helpers (`ai_helpers.sh` - 102K)

**Purpose**: AI integration with 15 specialized personas

```bash
# Architecture
ai_call() {
    local persona="$1"      # documentation_specialist, code_reviewer, etc.
    local prompt="$2"       # Dynamic prompt
    local output_file="$3"  # Result destination
    
    # 1. Check cache
    local cache_key=$(generate_cache_key "$persona" "$prompt")
    if cache_exists "$cache_key"; then
        retrieve_from_cache "$cache_key" "$output_file"
        return 0
    fi
    
    # 2. Build prompt from template
    local full_prompt=$(build_prompt_from_template "$persona" "$prompt")
    
    # 3. Call Copilot CLI
    gh copilot suggest "$full_prompt" > "$output_file"
    
    # 4. Cache response
    cache_response "$cache_key" "$output_file"
}

# Persona Management
load_persona() {
    local persona="$1"
    
    # Load from YAML config
    yq eval ".personas.${persona}" .workflow_core/config/ai_helpers.yaml
}
```

**Features**:
- 15 functional AI personas
- Dynamic prompt construction
- Response caching (24-hour TTL)
- Language-aware enhancements
- Project-kind specific behavior

#### Metrics Collection (`metrics.sh` - 16K)

**Purpose**: Performance tracking and historical analysis

```bash
# Metrics Structure
{
    "run_id": "20260208_102345",
    "timestamp": "2026-02-08T10:23:45Z",
    "total_duration": 180,
    "step_durations": {
        "step_00": 15,
        "step_02": 45,
        ...
    },
    "optimization": {
        "smart_execution": true,
        "parallel": true,
        "ml_optimize": true,
        "steps_skipped": 6,
        "time_saved": 840
    },
    "cache_stats": {
        "hits": 8,
        "misses": 4,
        "hit_rate": 0.667
    },
    "resource_usage": {
        "cpu_percent": 45,
        "memory_mb": 512,
        "disk_io_mb": 128
    }
}
```

**Functions**:
```bash
init_metrics()              # Start metrics collection
record_step_start()         # Mark step begin
record_step_end()          # Mark step complete
calculate_optimization()    # Compute savings
finalize_metrics()         # Save to history
```

#### Tech Stack Detection (`tech_stack.sh` - 47K)

**Purpose**: Automatic technology identification

```bash
detect_tech_stack() {
    local project_dir="$1"
    
    # Detect languages
    detect_languages "$project_dir"
    # Output: javascript, python, shell, go, java, etc.
    
    # Detect frameworks
    detect_frameworks "$project_dir"
    # Output: react, vue, django, express, etc.
    
    # Detect tools
    detect_tools "$project_dir"
    # Output: npm, pip, maven, gradle, etc.
    
    # Detect test frameworks
    detect_test_frameworks "$project_dir"
    # Output: jest, pytest, bats, go test, etc.
}

# Detection Methods
detect_by_file_presence() {
    # package.json -> Node.js
    # requirements.txt -> Python
    # go.mod -> Go
}

detect_by_imports() {
    # import React -> React
    # from django -> Django
}

detect_by_extensions() {
    # .jsx -> React/JSX
    # .vue -> Vue
}
```

**Used by**: Steps 0, 2, 5 for language-aware behavior

### 4. Step Execution Architecture

Each of the 18 steps follows this pattern:

```bash
#!/usr/bin/env bash
# src/workflow/steps/step_XX_name.sh

set -euo pipefail

# Step metadata
STEP_NUMBER=XX
STEP_NAME="Step Name"
STEP_DESCRIPTION="Brief description"

# Dependencies
DEPENDS_ON=(step_YY step_ZZ)

# Load libraries
source "$(dirname "$0")/../lib/utils.sh"
source "$(dirname "$0")/../lib/ai_helpers.sh"

# Validation function
validate_step() {
    # Pre-execution checks
    check_prerequisites
    validate_inputs
    check_dependencies
    
    return 0  # or 1 if validation fails
}

# Execution function
execute_step() {
    log_info "Starting ${STEP_NAME}"
    
    # Step-specific logic
    perform_analysis
    generate_output
    validate_results
    
    log_success "${STEP_NAME} completed"
    return 0
}

# Main entry point
main() {
    if ! validate_step; then
        log_error "Validation failed"
        return 1
    fi
    
    if ! execute_step; then
        log_error "Execution failed"
        return 1
    fi
    
    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## Data Flow

### Linear Workflow (Default)

```
┌─────────────┐
│   Step 0    │ Analyze project structure
└──────┬──────┘
       │
┌──────▼──────┐
│   Step 1    │ Analyze documentation
└──────┬──────┘
       │
┌──────▼──────┐
│   Step 2    │ Update documentation
└──────┬──────┘
       │
      ...
       │
┌──────▼──────┐
│   Step 15   │ Version update
└─────────────┘
```

### Parallel Workflow (--parallel)

```
┌─────────────┐
│   Wave 1    │ Step 0
└──────┬──────┘
       │
┌──────▼──────────────────┐
│   Wave 2 (parallel)      │
│  ┌─────┐      ┌─────┐   │
│  │ S1  │      │ S2  │   │
│  └─────┘      └─────┘   │
└──────┬──────────────────┘
       │
┌──────▼──────────────────────────┐
│   Wave 3 (parallel)              │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │ S3  │  │ S4  │  │ S5  │     │
│  └─────┘  └─────┘  └─────┘     │
└──────┬──────────────────────────┘
       │
      ...
```

### Multi-Stage Pipeline (--multi-stage)

```
┌──────────────────────────┐
│  Stage 1: Fast Validation │ (30 sec)
│  - Basic checks           │
│  - Syntax validation      │
└──────────┬───────────────┘
           │
           ▼ (80% stop here)
┌──────────────────────────┐
│  Stage 2: Core Validation │ (2-4 min)
│  - Documentation          │
│  - Tests                  │
│  - Basic quality          │
└──────────┬───────────────┘
           │
           ▼ (20% continue)
┌──────────────────────────┐
│  Stage 3: Comprehensive   │ (10-15 min)
│  - UX analysis            │
│  - Full quality checks    │
│  - ML optimization        │
└──────────────────────────┘
```

### Data Storage

```
Persistent Storage:
├── .workflow_core/config/     # Configuration (YAML)
│   ├── paths.yaml
│   ├── ai_helpers.yaml
│   └── project_kinds.yaml
│
├── src/workflow/
│   ├── .ai_cache/             # AI response cache
│   │   └── index.json
│   │
│   ├── backlog/               # Execution artifacts
│   │   └── workflow_TIMESTAMP/
│   │       └── step_*.md
│   │
│   ├── logs/                  # Detailed logs
│   │   └── workflow_TIMESTAMP/
│   │       └── *.log
│   │
│   ├── metrics/               # Performance data
│   │   ├── current_run.json
│   │   └── history.jsonl
│   │
│   └── summaries/            # AI summaries
│       └── workflow_TIMESTAMP/
│
└── .ml_data/                  # ML optimization
    ├── models/
    └── training_data.json
```

---

## Design Patterns

### 1. Functional Core / Imperative Shell

**Principle**: Pure functions in library modules, side effects isolated to steps

```bash
# Pure function (lib/change_detection.sh)
categorize_changes() {
    local files="$1"
    
    # No side effects, deterministic
    echo "$files" | grep -E '\.(md|txt)$' || true
}

# Imperative shell (steps/step_02.sh)
execute_step() {
    # Side effects: file I/O, AI calls, git operations
    local docs=$(categorize_changes "$(git diff --name-only)")
    update_documentation "$docs"
    commit_changes "Update documentation"
}
```

### 2. Dependency Injection

**Pattern**: Inject dependencies rather than hardcoding

```bash
# Bad: Hardcoded dependency
execute_step() {
    gh copilot suggest "..." > output.md
}

# Good: Injected dependency
execute_step() {
    local ai_provider="${AI_PROVIDER:-copilot}"
    
    case "$ai_provider" in
        copilot)
            call_copilot "..." > output.md
            ;;
        openai)
            call_openai "..." > output.md
            ;;
    esac
}
```

### 3. Strategy Pattern

**Use case**: Optimization strategies

```bash
# Strategy interface
optimize_execution() {
    local strategy="$1"
    
    case "$strategy" in
        smart)
            apply_smart_execution
            ;;
        parallel)
            apply_parallel_execution
            ;;
        ml)
            apply_ml_optimization
            ;;
        combined)
            apply_smart_execution
            apply_parallel_execution
            apply_ml_optimization
            ;;
    esac
}
```

### 4. Observer Pattern

**Use case**: Metrics collection

```bash
# Observers
observers=(
    "metrics_collector"
    "performance_monitor"
    "cache_tracker"
)

# Notify observers
notify_observers() {
    local event="$1"
    local data="$2"
    
    for observer in "${observers[@]}"; do
        "$observer" "$event" "$data"
    done
}

# Usage
notify_observers "step_start" "step_02"
```

### 5. Template Method Pattern

**Use case**: Step execution framework

```bash
# Template method
execute_step_template() {
    validate_step || return 1
    
    record_step_start
    execute_step
    local result=$?
    record_step_end
    
    return $result
}

# Concrete implementations override execute_step()
```

---

## Extension Points

### 1. Adding New Steps

```bash
# 1. Create step file
src/workflow/steps/step_16_custom.sh

# 2. Implement interface
validate_step() { ... }
execute_step() { ... }

# 3. Update dependency graph
# src/workflow/lib/dependency_graph.sh
add_step_dependency 16 15  # Depends on step 15

# 4. Register in main orchestrator
# src/workflow/execute_tests_docs_workflow.sh
WORKFLOW_STEPS+=("step_16_custom")
```

### 2. Adding New AI Personas

```bash
# 1. Add to config
# .workflow_core/config/ai_helpers.yaml
personas:
  security_auditor:
    role: "Security Auditor"
    expertise: "Security vulnerabilities, best practices"
    instructions: |
      Analyze code for security issues...

# 2. Use in steps
ai_call "security_auditor" "Analyze $file" "output.md"
```

### 3. Custom Optimization Strategies

```bash
# 1. Create strategy module
# src/workflow/lib/custom_optimization.sh

apply_custom_optimization() {
    # Your optimization logic
    detect_custom_patterns
    skip_unnecessary_steps
    optimize_execution_order
}

# 2. Register strategy
# src/workflow/lib/workflow_optimization.sh
register_optimization_strategy "custom" "apply_custom_optimization"

# 3. Use via CLI
--optimization-strategy custom
```

### 4. Custom Metrics Collectors

```bash
# 1. Create collector
# src/workflow/lib/custom_metrics.sh

collect_custom_metrics() {
    local event="$1"
    local data="$2"
    
    # Custom metric logic
    track_custom_kpi "$event" "$data"
    export_to_custom_system
}

# 2. Register observer
register_observer "collect_custom_metrics"
```

## Next Steps

- [Module Development Guide](MODULE_DEVELOPMENT.md)
- [API Reference](../api/API_REFERENCE.md)
- [Contributing Guidelines](../../CONTRIBUTING.md)
- [Testing Guide](../testing/TESTING_GUIDE.md)
