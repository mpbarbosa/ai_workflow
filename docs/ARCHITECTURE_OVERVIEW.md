# Architecture Overview - AI Workflow Automation

**Version**: 4.0.0  
**Last Updated**: 2026-02-08  
**Audience**: Developers and technical architects

> 📋 **Related Documentation**:
> - [Comprehensive Architecture Guide](architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md) - Detailed implementation
> - [Architecture Deep Dive](architecture/ARCHITECTURE_DEEP_DIVE.md) - Internal workings
> - [Workflow Diagrams](reference/workflow-diagrams.md) - Visual representations (17 diagrams)

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [Core Design Principles](#core-design-principles)
3. [System Components](#system-components)
4. [Data Flow](#data-flow)
5. [Module Categories](#module-categories)
6. [Execution Model](#execution-model)
7. [Performance Architecture](#performance-architecture)
8. [Extension Points](#extension-points)

## High-Level Architecture

AI Workflow Automation follows a **modular, functional architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Entry Point Layer                         │
│              execute_tests_docs_workflow.sh                  │
│         (Orchestrator - 2,009 lines)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
┌────────▼─────────┐       ┌────────▼──────────┐
│  Orchestrators   │       │  Configuration    │
│  (4 modules)     │       │  (YAML + Shell)   │
│                  │       │                   │
│ • pre_flight     │       │ • paths.yaml      │
│ • validation     │       │ • ai_helpers.yaml │
│ • quality        │       │ • project_kinds   │
│ • finalization   │       │ • .workflow-cfg   │
└────────┬─────────┘       └──────────┬────────┘
         │                            │
         └──────────┬─────────────────┘
                    │
     ┌──────────────┴──────────────┐
     │                             │
┌────▼────────┐           ┌───────▼──────┐
│   Steps     │           │   Library    │
│ (21 modules)│◄─────────►│ (81 modules) │
│             │           │              │
│ • step_00   │           │ • Core (12)  │
│ • step_0a   │           │ • Support(69)│
│ • step_0b   │           │              │
│ • step_01   │           │              │
│ • ...       │           │              │
│ • step_15   │           │              │
└─────────────┘           └──────────────┘
         │                       │
         └───────────┬───────────┘
                     │
          ┌──────────▼──────────┐
          │    Execution        │
          │    Artifacts        │
          │                     │
          │ • Backlog           │
          │ • Logs              │
          │ • Metrics           │
          │ • Cache             │
          │ • Checkpoints       │
          └─────────────────────┘
```

## Core Design Principles

### 1. Functional Core / Imperative Shell

**Functional Core** (Library Modules):
- Pure functions with no side effects
- Predictable, testable logic
- Composable operations
- Examples: `change_detection.sh`, `edit_operations.sh`, `validation.sh`

**Imperative Shell** (Steps & Orchestrators):
- Coordinates I/O operations
- Manages side effects (file writes, AI calls)
- Handles workflow state
- Examples: Step modules, orchestrators

### 2. Single Responsibility Principle

Each module has **one clear purpose**:
- `ai_helpers.sh` - AI communication only
- `change_detection.sh` - Change analysis only
- `metrics.sh` - Performance tracking only
- `session_manager.sh` - Session state only

### 3. Dependency Injection

Modules receive dependencies rather than creating them:
```bash
# Good: Dependencies injected
analyze_changes "${PROJECT_DIR}" "${TECH_STACK}"

# Bad: Module creates dependencies
analyze_changes  # Internally discovers PROJECT_DIR
```

### 4. Configuration as Code

- **YAML files** for AI prompts and project configuration
- **Environment variables** for runtime settings
- **Config files** for project-specific overrides
- **No hardcoded values** in logic

## System Components

### 1. Entry Point (`execute_tests_docs_workflow.sh`)

**Responsibilities**:
- Parse command-line options
- Initialize execution environment
- Load configuration and modules
- Orchestrate workflow execution
- Handle errors and cleanup

**Key Features**:
- 2,009 lines of orchestration logic
- 20+ command-line options
- Smart execution engine
- Parallel execution coordinator
- Metrics collection

### 2. Orchestrators (4 modules, 630 lines)

Coordinate major workflow phases:

**`orchestrators/pre_flight.sh`** (183 lines)
- Validate prerequisites
- Initialize directories
- Load configuration
- Set up environment

**`orchestrators/validation.sh`** (165 lines)
- Documentation validation
- Code quality checks
- Test execution
- Compliance verification

**`orchestrators/quality.sh`** (140 lines)
- Code review
- Test coverage
- Performance analysis
- Security scanning

**`orchestrators/finalization.sh`** (142 lines)
- Git operations
- Artifact packaging
- Metrics finalization
- Cleanup

### 3. Step Modules (21 modules)

Execute individual workflow steps:

**Categories**:
- **Preprocessing** (3 steps): Analysis, pre-processing, bootstrap
- **Validation** (4 steps): Documentation, architecture, code review, technical review
- **Testing** (3 steps): Test generation, execution, coverage
- **Quality** (4 steps): UX analysis, refactoring, code quality, final review
- **Finalization** (6 steps): Version control, documentation, artifacts, release

**Standard Interface**:
```bash
# Each step module provides:
validate_step()   # Prerequisites check
execute_step()    # Main logic
cleanup_step()    # Cleanup (optional)
```

### 4. Library Modules (81 modules)

Provide reusable functionality:

**Core Modules** (12):
- `ai_helpers.sh` - AI integration
- `tech_stack.sh` - Technology detection
- `workflow_optimization.sh` - Performance optimization
- `change_detection.sh` - Change analysis
- `metrics.sh` - Performance tracking
- `validation.sh` - Input validation
- `dependency_graph.sh` - Step dependencies
- `file_operations.sh` - File utilities
- `git_operations.sh` - Git utilities
- `logging.sh` - Structured logging
- `error_handling.sh` - Error management
- `session_manager.sh` - Session state

**Supporting Modules** (69):
- AI utilities (10 modules)
- File operations (8 modules)
- Git operations (6 modules)
- Optimization features (12 modules)
- Testing utilities (7 modules)
- Configuration (5 modules)
- Reporting (8 modules)
- Miscellaneous (5 modules)

See [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md#module-inventory) for complete list.

## Data Flow

### Execution Pipeline

```
User Command
     │
     ▼
┌─────────────────────┐
│  Command Parsing    │  Parse options, validate inputs
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Pre-Flight         │  Check prerequisites, init environment
│  Orchestrator       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Change Detection   │  Analyze modified files
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Smart Execution    │  Determine steps to run
│  Engine             │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Step Execution     │  Run steps (sequential/parallel)
│                     │
│  For each step:     │
│  1. Load module     │
│  2. Validate        │
│  3. Execute         │
│  4. Capture output  │
│  5. Update metrics  │
│  6. Save checkpoint │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Finalization       │  Git, artifacts, reports
│  Orchestrator       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Metrics & Reports  │  Generate execution summary
└─────────────────────┘
```

### Data Storage

**Temporary State** (In-Memory):
- Environment variables
- Function return values
- Shell arrays

**Persistent State** (Filesystem):
- `.checkpoints/` - Resume state
- `.ai_cache/` - AI response cache
- `backlog/` - Execution artifacts
- `logs/` - Execution logs
- `metrics/` - Performance data
- `.ml_data/` - ML predictions

## Module Categories

### By Responsibility

**1. Core Infrastructure** (12 modules)
- System initialization
- Configuration management
- Logging and error handling

**2. Workflow Orchestration** (8 modules)
- Step execution
- Dependency management
- Parallel coordination

**3. AI Integration** (10 modules)
- Prompt building
- Response caching
- Persona management

**4. Change Intelligence** (7 modules)
- File analysis
- Diff processing
- Impact assessment

**5. Performance Optimization** (12 modules)
- Smart execution
- ML predictions
- Parallel processing

**6. Testing & Quality** (10 modules)
- Test execution
- Coverage analysis
- Code review

**7. Git & Version Control** (8 modules)
- Commit management
- Branch operations
- History analysis

**8. Reporting & Metrics** (6 modules)
- Performance tracking
- Report generation
- Visualization

### By Layer

**Layer 1: Foundation** (20 modules)
- Basic utilities, logging, error handling

**Layer 2: Core Services** (25 modules)
- AI, git, file operations

**Layer 3: Domain Logic** (20 modules)
- Change detection, validation, testing

**Layer 4: Orchestration** (8 modules)
- Workflow coordination, optimization

## Execution Model

### Sequential Execution (Default)

Steps run one at a time in dependency order:

```bash
Step 0 → Step 0a → Step 0b → Step 1 → Step 2 → ... → Step 15
```

**Advantages**:
- Simple to debug
- Predictable resource usage
- Clear execution trace

### Parallel Execution (`--parallel`)

Independent steps run simultaneously:

```bash
       ┌─ Step 2 ─┐
Step 0 ┤          ├─ Step 5 → ...
       └─ Step 3 ─┘
```

**Requirements**:
- Steps have no dependencies
- Sufficient system resources
- Thread-safe operations

**Performance**: 33% faster on average

### Smart Execution (`--smart-execution`)

Skip steps based on change analysis:

```bash
# Only documentation changed
Skip: Step 3 (code review)
Skip: Step 6 (test generation)
Run: Step 2 (doc validation)
```

**Performance**: 40-85% faster depending on change type

### Multi-Stage Pipeline (`--multi-stage`)

Progressive validation in 3 stages:

**Stage 1: Core Validation** (Fast - 3-5 min)
- Change analysis
- Documentation validation
- Quick tests

**Stage 2: Extended Validation** (Medium - 8-12 min)
- Full test suite
- Code review
- Coverage analysis

**Stage 3: Finalization** (Complete - 15-20 min)
- UX analysis
- Performance testing
- Release preparation

**Result**: 80%+ of runs complete in first 2 stages

## Performance Architecture

### Optimization Layers

**Level 1: Change Detection**
- File-level diff analysis
- Intelligent step skipping
- 40-85% time reduction

**Level 2: Parallel Execution**
- Concurrent step execution
- Resource pooling
- 33% time reduction

**Level 3: AI Caching**
- Response deduplication
- 24-hour TTL
- 60-80% token reduction

**Level 4: ML Predictions** (v2.7.0+)
- Step duration forecasting
- Resource allocation
- 15-30% additional improvement

**Level 5: Incremental Processing** (v3.2.0+)
- Skip unchanged documentation
- Parallel AI calls
- 75-85% faster for Step 1

### Performance Data Flow

```
┌──────────────────┐
│  Change Analysis │ ──► Determine modified files
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Smart Execution │ ──► Skip unnecessary steps
│  Engine          │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  ML Predictor    │ ──► Estimate durations
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Parallel        │ ──► Schedule independent steps
│  Coordinator     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  AI Cache        │ ──► Reuse previous responses
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Execute Steps   │ ──► Run optimized workflow
└──────────────────┘
```

## Extension Points

### Adding New Steps

1. **Create step module**: `steps/new_step.sh`
2. **Implement interface**:
   ```bash
   validate_step() { ... }
   execute_step() { ... }
   ```
3. **Update config**: Add to `workflow_steps.yaml`
4. **Define dependencies**: Update `dependency_graph.sh`
5. **Write tests**: Create test suite
6. **Document**: Update relevant docs

### Adding Library Modules

1. **Create module**: `lib/new_module.sh`
2. **Define API**:
   ```bash
   # Clear function names
   # Single responsibility
   # Return status codes
   ```
3. **Write tests**: Unit test coverage
4. **Document**: API reference entry
5. **Source**: Load in main script

### Adding AI Personas

1. **Define prompts**: Add to `ai_helpers.yaml`
2. **Create persona**: Implement in `ai_personas.sh`
3. **Configure**: Set up in `ai_prompt_builder.sh`
4. **Test**: Validate AI responses
5. **Document**: Update persona list

### Adding Orchestrators

1. **Create module**: `orchestrators/new_orchestrator.sh`
2. **Define phase**: Clear responsibilities
3. **Integrate**: Call from main script
4. **Test**: Phase execution
5. **Document**: Architecture update

## Technology Stack

**Languages**:
- Bash 4.0+ (primary)
- YAML (configuration)
- JSON (data interchange)

**External Tools**:
- Git (version control)
- GitHub Copilot CLI (AI integration)
- Node.js 25.2.1+ (optional, for some features)
- jq (JSON processing)

**AI Integration**:
- GitHub Copilot CLI (primary)
- Multiple model support (Claude, GPT, Gemini)
- Response caching layer

## Security Architecture

**Principles**:
1. **No secrets in code** - Environment variables only
2. **Minimal permissions** - Least privilege access
3. **Input validation** - All user inputs sanitized
4. **Sandboxed execution** - Isolated step execution
5. **Audit logging** - Complete execution trail

**Implementation**:
- Git hooks validation
- File operation sandboxing
- Environment isolation
- Credential management via environment

## Testing Architecture

**Levels**:
1. **Unit Tests** - Individual functions (37+ tests)
2. **Integration Tests** - Module interactions
3. **System Tests** - Full workflow execution
4. **Performance Tests** - Benchmark validation

**Coverage**: 100% of critical paths

**Tools**:
- `tests/run_all_tests.sh` - Test runner
- `tests/unit/` - Unit test suites
- `tests/integration/` - Integration tests

## Related Documentation

- **[Comprehensive Architecture Guide](architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md)** - Detailed implementation
- **[Architecture Deep Dive](architecture/ARCHITECTURE_DEEP_DIVE.md)** - Internal workings
- **[Workflow Diagrams](reference/workflow-diagrams.md)** - Visual system (17 Mermaid diagrams)
- **[Module API Reference](MODULE_API_REFERENCE.md)** - API documentation
- **[Developer Onboarding](developer-guide/DEVELOPER_ONBOARDING_GUIDE.md)** - Getting started
- **[Extending the Workflow](developer-guide/EXTENDING_THE_WORKFLOW.md)** - Customization guide

---

**Last Updated**: 2026-02-08  
**Version**: 4.0.0  
**Author**: Marcelo Pereira Barbosa (@mpbarbosa)
