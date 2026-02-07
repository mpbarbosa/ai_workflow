# AI Workflow Automation - System Architecture

**Version**: 3.1.0  
**Last Updated**: 2026-02-07  
**Status**: Production

## Table of Contents

- [Overview](#overview)
- [High-Level Architecture](#high-level-architecture)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Module System](#module-system)
- [AI Integration](#ai-integration)
- [Optimization System](#optimization-system)
- [Persistence Layer](#persistence-layer)

---

## Overview

AI Workflow Automation is a modular, intelligent workflow system built on Unix philosophy principles: do one thing well, compose small tools into powerful workflows.

**Core Principles**:
1. **Functional Core, Imperative Shell** - Pure functions in library modules, side effects in step execution
2. **Single Responsibility** - Each module has one clear purpose
3. **Dependency Injection** - Testable, composable components
4. **Configuration as Code** - YAML-based prompt templates and configuration
5. **Smart by Default** - Intelligent optimization with manual override options

### System Characteristics

- **Language**: Bash 4.0+ (POSIX-compliant where possible)
- **Architecture Pattern**: Pipeline + Event-Driven
- **Execution Model**: Linear steps with parallel optimization
- **State Management**: File-based with atomic operations
- **AI Integration**: GitHub Copilot CLI with 15 specialized personas

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                     │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────────┐  │
│  │ CLI Entry  │  │ VS Code    │  │ CI/CD Integration    │  │
│  │ Point      │  │ Tasks      │  │ (GitHub Actions)     │  │
│  └────────────┘  └────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Orchestration Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Pre-Flight   │  │ Validation   │  │ Quality Check   │  │
│  │ Orchestrator │  │ Orchestrator │  │ Orchestrator    │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Execution Engine                          │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │ Step Execution   │  │ Parallel Executor            │    │
│  │ Manager          │  │ (fork/join pattern)          │    │
│  └──────────────────┘  └──────────────────────────────┘    │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │ Smart Execution  │  │ Multi-Stage Pipeline         │    │
│  │ Optimizer        │  │ (3-stage progressive)        │    │
│  └──────────────────┘  └──────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Intelligence Layer                        │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │ Change Detection │  │ ML Optimization Engine       │    │
│  │ & Analysis       │  │ (predictive duration)        │    │
│  └──────────────────┘  └──────────────────────────────┘    │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │ AI Persona       │  │ AI Response Cache            │    │
│  │ Manager (15)     │  │ (60-80% reduction)           │    │
│  └──────────────────┘  └──────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Library Layer (62 Modules)                │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────────────┐ │
│  │ AI Ops  │ │ File Ops│ │ Git Ops │ │ Metrics & Report │ │
│  │ (5)     │ │ (8)     │ │ (3)     │ │ (10)             │ │
│  └─────────┘ └─────────┘ └─────────┘ └──────────────────┘ │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────────────┐ │
│  │ Config  │ │ Analysis│ │ Utils   │ │ Validation       │ │
│  │ (6)     │ │ (7)     │ │ (13)    │ │ (8)              │ │
│  └─────────┘ └─────────┘ └─────────┘ └──────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Persistence Layer                           │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────────┐  │
│  │ File System│  │ Git Repo   │  │ JSON/JSONL Storage   │  │
│  │ (.ai_*)    │  │ (tracking) │  │ (metrics, ML data)   │  │
│  └────────────┘  └────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### 1. Orchestration Layer

**Purpose**: Coordinate workflow execution phases

**Components**:
```
orchestrators/
├── pre_flight.sh      # Environment validation, config loading
├── validation.sh      # Input validation, dependency checks
├── quality.sh         # Code quality gates, test validation
└── finalization.sh    # Metrics, reports, cleanup
```

**Responsibilities**:
- **Pre-Flight**: Validate environment, load configuration, initialize metrics
- **Validation**: Check inputs, verify dependencies, validate project structure
- **Quality**: Run quality gates, validate test results
- **Finalization**: Generate reports, commit artifacts, cleanup resources

### 2. Execution Engine

**Purpose**: Execute workflow steps with optimization

**Key Components**:

#### Step Execution Manager
```bash
# Linear execution with dependency resolution
execute_steps() {
    local steps=("$@")
    
    for step in "${steps[@]}"; do
        if should_execute_step "$step"; then
            execute_step "$step"
        fi
    done
}
```

#### Parallel Executor
```bash
# Fork/join pattern for independent steps
execute_parallel() {
    local -a pids=()
    
    for step in "${parallel_steps[@]}"; do
        execute_step "$step" &
        pids+=($!)
    done
    
    # Wait for all to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}
```

#### Smart Execution Optimizer
```bash
# Change-driven step selection
optimize_execution() {
    local change_type=$(detect_change_type)
    
    case "$change_type" in
        "docs-only")
            steps=$(get_docs_steps)  # 85% faster
            ;;
        "tests-only")
            steps=$(get_test_steps)
            ;;
        *)
            steps=$(get_all_steps)
            ;;
    esac
}
```

#### Multi-Stage Pipeline
```bash
# Progressive validation (3 stages)
execute_multi_stage() {
    # Stage 1: Quick validation (80% complete here)
    execute_stage "quick" || return 1
    
    # Stage 2: Standard validation (15% continue)
    execute_stage "standard" || return 1
    
    # Stage 3: Full validation (5% need this)
    execute_stage "full"
}
```

### 3. Intelligence Layer

**Purpose**: Provide AI and ML capabilities

#### AI Persona Manager
```
ai_personas.sh
├── 15 specialized personas
├── Dynamic prompt building
├── Context injection
└── Response validation
```

**Personas**:
1. documentation_specialist
2. code_reviewer
3. test_engineer
4. ux_designer
5. technical_writer
6. security_analyst
7. performance_engineer
8. api_designer
9. devops_engineer
10. data_architect
11. quality_assurance
12. accessibility_expert
13. integration_specialist
14. refactoring_expert
15. prompt_engineer

#### AI Response Cache
```
.ai_cache/
├── index.json              # Cache metadata
└── <sha256>.json          # Cached responses (24h TTL)
```

**Cache Algorithm**:
```bash
# SHA256 of (persona + prompt + project_context)
cache_key=$(echo -n "$persona|$prompt|$context" | sha256sum | cut -d' ' -f1)

if [[ -f ".ai_cache/${cache_key}.json" ]]; then
    # Check TTL (24 hours)
    if is_cache_valid "$cache_key"; then
        return cached_response
    fi
fi
```

#### ML Optimization Engine
```
ml_optimization.sh
├── Predictive duration estimation
├── Historical pattern analysis
├── Smart recommendations
└── Confidence scoring
```

**ML Features**:
- Requires 10+ historical runs for accuracy
- Linear regression for duration prediction
- Confidence intervals for recommendations
- Auto-learning from execution history

### 4. Library Layer (62 Modules)

**Organization by Function**:

#### AI Operations (5 modules)
- `ai_helpers.sh` - Copilot CLI integration
- `ai_cache.sh` - Response caching
- `ai_prompt_builder.sh` - Dynamic prompt construction
- `ai_personas.sh` - Persona management
- `ai_validation.sh` - Response validation

#### File Operations (8 modules)
- `file_operations.sh` - Safe file ops (atomic writes)
- `edit_operations.sh` - Surgical file editing
- `backup_manager.sh` - Backup/restore
- `file_diff.sh` - Diff generation
- `file_merger.sh` - Merge operations
- `template_engine.sh` - Template processing
- `yaml_parser.sh` - YAML handling
- `path_resolver.sh` - Path resolution

#### Git Operations (3 modules)
- `git_automation.sh` - Git commands
- `git_cache.sh` - Git status caching
- `git_submodule_helpers.sh` - Submodule management

#### Metrics & Reporting (10 modules)
- `metrics.sh` - Core metrics collection
- `performance.sh` - Timing utilities
- `performance_monitoring.sh` - Real-time monitoring
- `metrics_validation.sh` - Data validation
- `dashboard.sh` - Visual display
- `summary.sh` - Summary generation
- `report_generator.sh` - Report creation
- `chart_generator.sh` - Charts
- `export_formatter.sh` - Export formatting
- `backlog.sh` - Execution history

#### Configuration (6 modules)
- `config.sh` - Core configuration
- `config_wizard.sh` - Interactive setup
- `argument_parser.sh` - CLI parsing
- `config_loader.sh` - Config loading
- `env_validator.sh` - Environment validation
- `option_validator.sh` - Option validation

---

## Data Flow

### Workflow Execution Flow

```
1. Entry Point (execute_tests_docs_workflow.sh)
   │
   ├──> Parse Arguments (argument_parser.sh)
   │    └──> Validate & Set Defaults
   │
   ├──> Pre-Flight Checks (pre_flight.sh)
   │    ├──> Load Configuration
   │    ├──> Validate Environment
   │    └──> Initialize Metrics
   │
   ├──> Change Detection (change_detection.sh)
   │    ├──> Analyze Git Diff
   │    ├──> Classify Changes
   │    └──> Determine Optimization Strategy
   │
   ├──> Step Selection (workflow_optimization.sh)
   │    ├──> Smart Execution Analysis
   │    ├──> ML Predictions (if enabled)
   │    └──> Build Step Graph
   │
   ├──> Execute Steps (step_execution.sh)
   │    ├──> Sequential Steps
   │    ├──> Parallel Steps (if enabled)
   │    └──> Multi-Stage Pipeline (if enabled)
   │
   ├──> Quality Checks (quality.sh)
   │    ├──> Test Validation
   │    ├──> Code Quality Gates
   │    └──> Documentation Validation
   │
   └──> Finalization (finalization.sh)
        ├──> Generate Reports
        ├──> Update Metrics
        ├──> Auto-Commit (if enabled)
        └──> Cleanup Resources
```

### AI Request Flow

```
1. Step Requests AI Assistance
   │
   ├──> Build Prompt (ai_prompt_builder.sh)
   │    ├──> Load Persona Template
   │    ├──> Inject Project Context
   │    └──> Add Language-Specific Rules
   │
   ├──> Check Cache (ai_cache.sh)
   │    ├──> Calculate Cache Key (SHA256)
   │    ├──> Check TTL (24 hours)
   │    └──> Return if Valid
   │
   ├──> Call AI (ai_helpers.sh)
   │    ├──> Validate Copilot CLI
   │    ├──> Execute Request
   │    └──> Handle Errors/Retries
   │
   ├──> Validate Response (ai_validation.sh)
   │    ├──> Check Format
   │    ├──> Verify Content
   │    └──> Log Quality Metrics
   │
   └──> Cache Response (ai_cache.sh)
        └──> Store with Metadata
```

### Metrics Collection Flow

```
1. Workflow Start
   │
   ├──> init_metrics()
   │    ├──> Create METRICS_DIR
   │    ├──> Initialize current_run.json
   │    └──> Set WORKFLOW_START_EPOCH
   │
   ├──> For Each Step:
   │    ├──> record_step_start(step_name)
   │    ├──> Execute Step Logic
   │    └──> record_step_end(step_name, status)
   │
   └──> Workflow End
        └──> finalize_metrics()
             ├──> Calculate Totals
             ├──> Append to history.jsonl
             ├──> Generate summary.md
             └──> Export Formats (JSON, CSV)
```

---

## Module System

### Module Structure

Every library module follows this structure:

```bash
#!/bin/bash
set -euo pipefail

################################################################################
# Module Name
# Purpose: Clear, concise purpose statement
# Part of: AI Workflow Automation v3.1.0
################################################################################

# ==============================================================================
# CONSTANTS & CONFIGURATION
# ==============================================================================
declare -r MODULE_VERSION="1.0.0"

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Function: function_name
# Purpose: What it does
# Parameters:
#   $1 - parameter description
# Returns:
#   Exit code: 0 on success, 1 on error
#   Output: Description of stdout
function_name() {
    local param="$1"
    
    # Implementation
    
    return 0
}

# ==============================================================================
# PRIVATE FUNCTIONS
# ==============================================================================

_private_function() {
    # Internal helper functions
    :
}
```

### Module Categories

```
Core Modules (12)
├── Infrastructure (5): ai_helpers, tech_stack, workflow_optimization, 
│                       project_kind_config, config_wizard
├── Analysis (3): change_detection, dependency_graph, health_check
├── Performance (2): metrics, performance
└── Execution (2): step_adaptation, file_operations

Supporting Modules (50)
├── AI & Prompts (5)
├── File & Edit (8)
├── Process & Session (6)
├── Project Analysis (7)
├── Metrics & Reports (5)
├── CLI & Config (6)
└── Utilities (13)

Step Modules (18)
├── Pre-processing (2): step_0a, step_0b
├── Core Pipeline (15): step_01 through step_15
└── Bootstrap: step_0b (documentation generation)

Orchestrators (4)
├── pre_flight.sh
├── validation.sh
├── quality.sh
└── finalization.sh
```

### Dependency Management

**Dependency Graph**:
```bash
# Core dependencies (required by many modules)
utils.sh
├── colors.sh
└── logging functions

# AI dependencies
ai_helpers.sh
├── ai_prompt_builder.sh
├── ai_personas.sh
├── ai_cache.sh
└── jq_wrapper.sh

# Execution dependencies
step_execution.sh
├── metrics.sh
├── change_detection.sh
├── step_metadata.sh
└── session_manager.sh
```

**Loading Order**:
1. Utils & colors
2. Configuration modules
3. Core infrastructure
4. Specialized modules
5. Step modules

---

## AI Integration

### Persona System

**Architecture**:
```
┌─────────────────────────────────────────────────────┐
│              AI Persona System                       │
├─────────────────────────────────────────────────────┤
│                                                       │
│  Persona Definition (ai_personas.sh)                │
│  ├── Name & Role                                     │
│  ├── Expertise Areas                                 │
│  ├── Prompt Templates                                │
│  └── Quality Standards                               │
│                                                       │
│  Prompt Builder (ai_prompt_builder.sh)              │
│  ├── Load Template                                   │
│  ├── Inject Context                                  │
│  │   ├── Project Metadata                            │
│  │   ├── Tech Stack                                  │
│  │   └── Language Rules                              │
│  ├── Variable Substitution                           │
│  └── Validation                                      │
│                                                       │
│  Context Manager                                     │
│  ├── Project Context                                 │
│  │   ├── .workflow-config.yaml                       │
│  │   ├── project_kinds.yaml                          │
│  │   └── Detected tech stack                         │
│  ├── Step Context                                    │
│  │   ├── Previous step results                       │
│  │   ├── Change analysis                             │
│  │   └── Quality metrics                             │
│  └── Session Context                                 │
│      ├── Workflow history                            │
│      └── User preferences                            │
│                                                       │
└─────────────────────────────────────────────────────┘
```

### Prompt Template System

**Template Structure**:
```yaml
# .workflow_core/config/ai_helpers.yaml
prompts:
  documentation_review:
    base: |
      You are a ${PERSONA} expert specializing in ${PROJECT_KIND} projects.
      
      Project: ${PROJECT_NAME}
      Language: ${PRIMARY_LANGUAGE}
      
      ${LANGUAGE_RULES}
      
      Task: ${TASK_DESCRIPTION}
      
      Files to review:
      ${FILE_LIST}
      
      Changes made:
      ${CHANGES}
      
      Provide your analysis.
    
    variables:
      - PERSONA
      - PROJECT_KIND
      - PROJECT_NAME
      - PRIMARY_LANGUAGE
      - LANGUAGE_RULES
      - TASK_DESCRIPTION
      - FILE_LIST
      - CHANGES
```

**Dynamic Enhancement**:
```bash
# Language-specific rules auto-injected when PRIMARY_LANGUAGE is set
if [[ -n "${PRIMARY_LANGUAGE}" ]]; then
    language_rules=$(get_language_rules "$PRIMARY_LANGUAGE")
    prompt="${prompt/\$\{LANGUAGE_RULES\}/$language_rules}"
fi
```

---

## Optimization System

### Smart Execution

**Decision Tree**:
```
detect_changes()
  ├── docs-only
  │   ├── Skip: Tests (steps 5-7)
  │   ├── Skip: Code quality (steps 8-10)
  │   ├── Run: Documentation (steps 2-4, 11-12)
  │   └── Run: Finalization (steps 13-15)
  │   Result: 85% faster (23min → 3.5min)
  │
  ├── tests-only
  │   ├── Skip: Documentation updates (steps 2-4)
  │   ├── Run: Tests (steps 5-7)
  │   ├── Run: Quality (steps 8-10)
  │   └── Run: Finalization (steps 13-15)
  │   Result: 35% faster
  │
  └── full-stack
      ├── Run: All steps
      └── Use: Parallel execution if enabled
```

### Parallel Execution

**Parallelizable Steps**:
```bash
# Independent steps that can run simultaneously
PARALLEL_GROUPS=(
    "step_02,step_05"  # Docs + Tests (no dependencies)
    "step_03,step_06"  # Validation + Test validation
)

# Fork/join implementation
for group in "${PARALLEL_GROUPS[@]}"; do
    IFS=',' read -ra steps <<< "$group"
    
    for step in "${steps[@]}"; do
        execute_step "$step" &
    done
    
    wait  # Barrier
done
```

**Result**: 33% faster (23min → 15.5min)

### Multi-Stage Pipeline

**Stage Definitions**:
```bash
STAGE_QUICK=(
    step_00_analyze
    step_01_validate
    step_02_update_docs
)

STAGE_STANDARD=(
    step_05_run_tests
    step_06_validate_tests
    step_08_code_quality
)

STAGE_FULL=(
    step_09_ux_analysis
    step_10_security_review
    step_11_integration_test
)
```

**Progressive Execution**:
- Stage 1 (Quick): 80% of runs complete here
- Stage 2 (Standard): 15% continue
- Stage 3 (Full): 5% need full validation

### ML Optimization

**Predictive Model**:
```bash
# Linear regression on historical data
predict_duration() {
    local step="$1"
    local history=$(get_last_n_runs 20)
    
    # Extract features: change_type, file_count, lines_changed
    # Train simple linear model
    # Return: predicted_duration, confidence_interval
    
    echo "${predicted_duration} ${confidence}"
}
```

**Requirements**:
- Minimum 10 historical runs
- Accuracy improves with more data
- 15-30% additional time savings

---

## Persistence Layer

### File System Structure

```
.ai_workflow/
├── backlog/                  # Execution history
│   └── workflow_YYYYMMDD_HHMMSS/
│       ├── step_NN_*.md
│       └── CHANGE_*.md
├── logs/                     # Execution logs
│   └── workflow_YYYYMMDD_HHMMSS/
│       └── *.log
├── metrics/                  # Performance data
│   ├── current_run.json
│   ├── history.jsonl
│   └── summary.md
└── summaries/               # AI summaries
    └── workflow_YYYYMMDD_HHMMSS/

.ml_data/                    # ML optimization data
├── features.jsonl
├── predictions.jsonl
└── model_state.json

src/workflow/
├── .ai_cache/              # AI response cache
│   ├── index.json
│   └── <sha256>.json
├── .checkpoints/           # Resume state
│   └── checkpoint_*.json
└── logs/                   # Workflow logs
```

### Data Formats

**Metrics (JSONL)**:
```json
{"run_id":"20260207_174530","duration":932,"steps_completed":15,"success":true}
```

**AI Cache (JSON)**:
```json
{
  "key": "abc123...",
  "persona": "documentation_specialist",
  "prompt_hash": "def456...",
  "response": "...",
  "timestamp": 1739816730,
  "ttl": 86400
}
```

**Checkpoints (JSON)**:
```json
{
  "workflow_id": "20260207_174530",
  "last_completed_step": "step_05_run_tests",
  "state": {
    "change_type": "full-stack",
    "metrics": {...}
  }
}
```

---

## Related Documentation

- [Module Inventory](../PROJECT_REFERENCE.md#module-inventory)
- [API Reference](../api/README.md)
- [Developer Guide](../developer-guide/architecture.md)
- [Optimization Guide](../guides/OPTIMIZATION.md)
