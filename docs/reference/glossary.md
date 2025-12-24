# Glossary

A comprehensive glossary of domain-specific terms used in AI Workflow Automation.

---

## A

### AI Cache
A persistent storage system that caches AI responses to avoid redundant queries. Uses SHA256 keys based on prompt content and has a 24-hour TTL. Reduces token usage by 60-80% and provides near-instant responses for repeated prompts.

**See also**: [AI Response Caching](#ai-response-caching), [TTL](#ttl-time-to-live)

### AI Helper
A module (`ai_helpers.sh`) that integrates with GitHub Copilot CLI to provide AI-powered analysis and generation capabilities. Includes 14 functional personas for different workflow tasks.

**See also**: [Persona](#persona), [GitHub Copilot CLI](#github-copilot-cli)

### AI Persona
See [Persona](#persona)

### AI Response Caching
The system that stores AI-generated responses to avoid making the same API call multiple times. Implemented in `ai_cache.sh` with file-based storage and automatic TTL management.

**Related**: ADR-004  
**See also**: [Cache Hit Rate](#cache-hit-rate), [TTL](#ttl-time-to-live)

### Atomic Operation
A file operation that completes entirely or not at all, preventing partial writes or corruption. Used extensively in workflow for safe file modifications.

**Example**: Write to temporary file, then rename to target (rename is atomic on most filesystems)

---

## B

### Backlog
A directory (`src/workflow/backlog/`) that stores execution history, including step reports, analysis results, and AI-generated summaries. Each workflow run creates a timestamped subdirectory.

**Location**: `src/workflow/backlog/workflow_YYYYMMDD_HHMMSS/`  
**See also**: [Execution History](#execution-history)

### Background Process
A shell process started with `&` that runs asynchronously while the parent script continues. Used in parallel execution to run independent steps simultaneously.

**See also**: [Parallel Execution](#parallel-execution)

### BATS
Bash Automated Testing System - a testing framework used for shell script unit tests in this project.

**See also**: [Test Framework](#test-framework)

---

## C

### Cache Hit
When a requested AI response is found in the cache and returned without making a new API call.

**See also**: [Cache Hit Rate](#cache-hit-rate), [AI Cache](#ai-cache)

### Cache Hit Rate
The percentage of AI queries that are satisfied from cache rather than making new API calls. Typically 60-80% for documentation-only changes.

**Formula**: `(cache_hits / total_queries) × 100`

### Cache Key
A SHA256 hash generated from the prompt, persona, and context used to uniquely identify cached AI responses.

**Example**: `sha256("prompt:documentation_specialist:context") → a1b2c3d4...`

### Change Classification
The process of categorizing git changes into types (documentation, code, tests, configuration) to determine which workflow steps are relevant.

**See also**: [Change Detection](#change-detection), [Impact Analysis](#impact-analysis)

### Change Detection
A system that analyzes git diffs to determine what files changed and classifies the impact. Used by smart execution to skip irrelevant steps.

**Implementation**: `change_detection.sh` module  
**Related**: ADR-005  
**See also**: [Smart Execution](#smart-execution), [Git Diff Analysis](#git-diff-analysis)

### Checkpoint
A saved workflow state that allows resuming from the last completed step if the workflow is interrupted. Stored in `.workflow_checkpoint` file.

**Format**: Bash-compatible variable assignments  
**See also**: [Resume](#resume), [Checkpoint Resume](#checkpoint-resume)

### Checkpoint Resume
The ability to continue a workflow from where it left off after an interruption, using saved checkpoint data.

**Disable with**: `--no-resume` flag  
**See also**: [Checkpoint](#checkpoint)

### Configuration Externalization
The architectural decision to move configuration from shell code to YAML files for easier customization without code changes.

**Related**: ADR-002  
**See also**: [YAML Configuration](#yaml-configuration)

### Contributor Covenant
An industry-standard code of conduct adopted by 100,000+ open source projects. Used as the basis for this project's CODE_OF_CONDUCT.md.

**Version**: 2.1  
**See also**: [Code of Conduct](#code-of-conduct)

### Coordinated Disclosure
A vulnerability disclosure process where security issues are reported privately, fixed, and then disclosed publicly after users have time to update.

**See also**: [Security Policy](#security-policy), [Embargo Period](#embargo-period)

---

## D

### Dependency Graph
A directed graph showing which workflow steps depend on other steps. Used to determine parallel execution groups and step ordering.

**Implementation**: `dependency_graph.sh` module  
**Visualization**: Mermaid diagrams  
**See also**: [Parallel Execution](#parallel-execution), [Execution Groups](#execution-groups)

### Dry Run
A mode where the workflow simulates execution without making actual changes. Useful for previewing what would happen.

**Flag**: `--dry-run`  
**See also**: [Preview Mode](#preview-mode)

---

## E

### Embargo Period
A timeframe (typically 90 days) after reporting a security vulnerability during which public disclosure is withheld to allow users to update.

**See also**: [Coordinated Disclosure](#coordinated-disclosure), [Security Policy](#security-policy)

### Enforcement Guidelines
The 4-level progressive discipline system in the Code of Conduct: Correction, Warning, Temporary Ban, Permanent Ban.

**See also**: [Code of Conduct](#code-of-conduct)

### Execution Groups
Sets of workflow steps that can run in parallel because they have no dependencies on each other.

**Group 1**: Steps 1, 3, 4, 5, 8, 13, 14 (independent)  
**Group 2**: Steps 6, 7 (depend on Group 1)  
**Group 3**: Steps 9, 10, 11, 12 (depend on previous groups)

**See also**: [Parallel Execution](#parallel-execution), [Dependency Graph](#dependency-graph)

### Execution History
The record of previous workflow runs stored in the backlog directory. Includes step reports, metrics, and summaries.

**See also**: [Backlog](#backlog), [Metrics](#metrics)

---

## F

### Functional Persona
See [Persona](#persona)

---

## G

### Git Diff Analysis
The process of examining `git diff` output to determine what files changed between commits. Foundation of change detection.

**See also**: [Change Detection](#change-detection), [Change Classification](#change-classification)

### GitHub Copilot CLI
A command-line interface for GitHub Copilot that provides AI-powered assistance. Used as the AI backend for this workflow.

**See also**: [AI Helper](#ai-helper), [Persona](#persona)

---

## H

### Health Check
A validation script that verifies all prerequisites (Bash version, Git, Node.js, etc.) are available before workflow execution.

**Script**: `src/workflow/lib/health_check.sh`  
**See also**: [Pre-flight Checks](#pre-flight-checks)

---

## I

### Impact Analysis
The process of determining which workflow steps are affected by specific changes. Used to decide which steps to run in smart execution.

**See also**: [Change Detection](#change-detection), [Step Relevance](#step-relevance)

---

## L

### Library Module
A reusable shell script module in `src/workflow/lib/` that provides functions for use by steps and the orchestrator. Examples: `utils.sh`, `ai_helpers.sh`, `metrics.sh`.

**Count**: 28 modules  
**See also**: [Modular Architecture](#modular-architecture), [Step Module](#step-module)

---

## M

### Metrics
Performance and execution data collected during workflow runs, including timing, token usage, cache hit rates, and step success rates.

**Implementation**: `metrics.sh` module  
**Storage**: `src/workflow/metrics/` directory  
**Format**: JSON and JSONL  
**See also**: [Metrics Collection](#metrics-collection), [Performance Tracking](#performance-tracking)

### Metrics Collection
The automated gathering of performance data during workflow execution for analysis and optimization.

**See also**: [Metrics](#metrics), [Historical Metrics](#historical-metrics)

### Modular Architecture
The architectural pattern of splitting functionality into focused, single-purpose modules rather than a monolithic script.

**Related**: ADR-001  
**Result**: 28 library + 15 step + 6 config modules  
**See also**: [Library Module](#library-module), [Step Module](#step-module)

---

## O

### Orchestrator
The main workflow coordination script (`execute_tests_docs_workflow.sh`) that manages step execution, handles errors, and collects metrics.

**Lines**: ~2,009 (reduced from 2,500+ after sub-module split)  
**Related**: ADR-003  
**See also**: [Orchestrator Sub-module](#orchestrator-sub-module)

### Orchestrator Sub-module
Specialized modules that handle specific orchestrator responsibilities: pre-flight checks, validation, quality checks, and finalization.

**Count**: 4 sub-modules (630 lines extracted)  
**Related**: ADR-003  
**See also**: [Orchestrator](#orchestrator)

---

## P

### Parallel Execution
The ability to run independent workflow steps simultaneously using shell background processes, reducing total execution time by ~33%.

**Implementation**: `workflow_optimization.sh` module  
**Related**: ADR-006  
**Flag**: `--parallel`  
**See also**: [Execution Groups](#execution-groups), [Background Process](#background-process)

### Performance Tracking
The continuous monitoring and recording of workflow performance metrics for optimization analysis.

**See also**: [Metrics](#metrics), [Metrics Collection](#metrics-collection)

### Persona
A specialized AI role with specific expertise and prompt templates. The workflow uses 14 personas including documentation_specialist, test_engineer, code_reviewer, etc.

**Count**: 14 functional personas  
**Implementation**: `ai_personas.sh`, `ai_helpers.yaml`  
**Examples**:
- `documentation_specialist` - Documentation updates
- `test_engineer` - Test generation
- `code_reviewer` - Code quality analysis
- `ux_designer` - UX/UI analysis

**See also**: [AI Helper](#ai-helper), [Prompt Template](#prompt-template)

### Pre-flight Checks
Initial validations performed before workflow execution to ensure all prerequisites are met (git repo, dependencies, permissions).

**Implementation**: `pre_flight.sh` orchestrator sub-module  
**See also**: [Health Check](#health-check)

### Preview Mode
See [Dry Run](#dry-run)

### Primary Language
The main programming language of the target project, detected automatically or specified in `.workflow-config.yaml`. Used for language-aware AI prompt enhancement.

**Examples**: `bash`, `javascript`, `python`, `go`  
**See also**: [Tech Stack](#tech-stack), [Project Kind](#project-kind)

### Project Kind
A classification of the target project type (shell_automation, nodejs_api, react_spa, python_app, etc.) used to customize workflow behavior.

**Configuration**: `project_kinds.yaml`  
**Count**: 12+ project types  
**Detection**: Automatic via `project_kind_detection.sh`  
**Examples**:
- `shell_script_automation` - Shell scripts and utilities
- `nodejs_api` - Node.js REST APIs
- `react_spa` - React single-page applications
- `python_library` - Python packages

**See also**: [Tech Stack](#tech-stack), [Step Relevance](#step-relevance)

### Prompt Template
A pre-defined prompt structure for a specific AI persona, stored in YAML files. Can include variable interpolation and project-kind-specific enhancements.

**Storage**: `ai_helpers.yaml`, `ai_prompts_project_kinds.yaml`  
**See also**: [Persona](#persona), [Variable Interpolation](#variable-interpolation)

---

## R

### Resume
The process of continuing a workflow from a saved checkpoint after interruption.

**See also**: [Checkpoint](#checkpoint), [Checkpoint Resume](#checkpoint-resume)

---

## S

### SHA256
A cryptographic hash function used to generate unique cache keys from AI prompts. Ensures same input always produces same key.

**See also**: [Cache Key](#cache-key), [AI Cache](#ai-cache)

### Single Responsibility Principle (SRP)
A design principle stating each module should have one clear purpose. Applied throughout the modular architecture.

**Related**: ADR-001  
**See also**: [Modular Architecture](#modular-architecture)

### Smart Execution
An optimization that skips workflow steps that aren't relevant to the changes made, based on git diff analysis. Can reduce execution time by 40-85%.

**Implementation**: `workflow_optimization.sh` module  
**Related**: ADR-005  
**Flag**: `--smart-execution`  
**Example**: Documentation-only changes skip code quality checks

**Performance**:
- Docs-only: 85% faster (23min → 3.5min)
- Code-only: 40% faster (23min → 14min)

**See also**: [Change Detection](#change-detection), [Step Relevance](#step-relevance)

### Step Module
A shell script in `src/workflow/steps/` that implements a specific workflow step (e.g., `step_01_documentation.sh`).

**Count**: 15 steps (Step 0-14)  
**See also**: [Library Module](#library-module), [Workflow Step](#workflow-step)

### Step Relevance
The determination of whether a workflow step should run based on what changed in the project. Defined in `step_relevance.yaml`.

**Example**: Code quality step (Step 9) is only relevant when code files change  
**See also**: [Smart Execution](#smart-execution), [Impact Analysis](#impact-analysis)

---

## T

### Target Directory
The project directory being analyzed by the workflow. Can be current directory (default) or specified with `--target` option.

**Default**: Current working directory  
**Flag**: `--target /path/to/project`  
**Environment Variable**: `TARGET_DIR`  
**See also**: [Target Project](#target-project)

### Target Project
The project being analyzed by the workflow, which may be different from where the workflow scripts are installed.

**See also**: [Target Directory](#target-directory)

### Tech Stack
The collection of technologies, languages, frameworks, and tools used in the target project. Auto-detected and used to customize workflow behavior.

**Configuration**: `tech_stack_definitions.yaml`  
**Detection**: `tech_stack.sh` module  
**Components**: Primary language, frameworks, build tools, test frameworks  
**See also**: [Project Kind](#project-kind), [Primary Language](#primary-language)

### Test Framework
The testing system used by a project. The workflow supports BATS (shell), Jest (JavaScript), and pytest (Python).

**Detection**: Automatic based on files present  
**See also**: [Tech Stack](#tech-stack)

### TTL (Time To Live)
The duration that a cached AI response remains valid before expiring. Default is 24 hours.

**Configuration**: Can be customized in workflow settings  
**See also**: [AI Cache](#ai-cache), [Cache Expiration](#cache-expiration)

### Third-Party Exclusion
The system that filters out files from third-party sources (node_modules, vendor, etc.) to avoid analyzing code not owned by the project.

**Implementation**: `third_party_exclusion.sh` module  
**Excluded**: `node_modules/`, `vendor/`, `.git/`, build artifacts

---

## V

### Variable Interpolation
The substitution of variables in configuration files (YAML) with actual values at runtime.

**Syntax**: `${VARIABLE_NAME}`  
**Example**: `${PROJECT_ROOT}/src/workflow`  
**See also**: [YAML Configuration](#yaml-configuration)

---

## W

### Workflow Step
One of the 15 stages in the workflow pipeline, each with specific responsibilities.

**Steps**:
0. Pre-flight analysis
1. Documentation updates
2. Consistency validation
3. Script reference validation
4. Directory structure validation
5. Test coverage review
6. Test case generation
7. Test execution
8. Dependency validation
9. Code quality checks
10. Context analysis
11. Git operations
12. Markdown linting
13. Prompt engineering analysis
14. UX/UI analysis

**See also**: [Step Module](#step-module), [Execution Groups](#execution-groups)

---

## Y

### YAML Configuration
External configuration files in YAML format that define paths, prompts, project types, and other settings without requiring code changes.

**Location**: `src/workflow/config/`  
**Count**: 6 configuration files (2,716 lines)  
**Related**: ADR-002  
**See also**: [Configuration Externalization](#configuration-externalization), [Variable Interpolation](#variable-interpolation)

---

## Acronyms

| Acronym | Full Form | Description |
|---------|-----------|-------------|
| ADR | Architecture Decision Record | Documents important architectural decisions |
| AI | Artificial Intelligence | Machine learning capabilities via GitHub Copilot |
| API | Application Programming Interface | Interface for programmatic interaction |
| BATS | Bash Automated Testing System | Shell script testing framework |
| CLI | Command-Line Interface | Text-based program interaction |
| JSON | JavaScript Object Notation | Data interchange format |
| JSONL | JSON Lines | One JSON object per line format |
| MIT | Massachusetts Institute of Technology | Permissive open source license |
| SHA256 | Secure Hash Algorithm 256-bit | Cryptographic hash function |
| SRP | Single Responsibility Principle | Design principle for modularity |
| TTL | Time To Live | Duration until cached data expires |
| UI | User Interface | Visual interface for interaction |
| UX | User Experience | User interaction and satisfaction |
| WCAG | Web Content Accessibility Guidelines | Web accessibility standards |
| YAML | YAML Ain't Markup Language | Human-readable data serialization |

---

## Quick Reference

### Flags and Options

| Flag | Description | Related Term |
|------|-------------|--------------|
| `--smart-execution` | Enable smart step skipping | [Smart Execution](#smart-execution) |
| `--parallel` | Run independent steps simultaneously | [Parallel Execution](#parallel-execution) |
| `--target DIR` | Specify project directory | [Target Directory](#target-directory) |
| `--no-resume` | Ignore checkpoints, start fresh | [Checkpoint Resume](#checkpoint-resume) |
| `--no-ai-cache` | Disable AI response caching | [AI Cache](#ai-cache) |
| `--dry-run` | Preview without changes | [Dry Run](#dry-run) |
| `--steps N,M` | Run only specific steps | [Workflow Step](#workflow-step) |
| `--show-graph` | Display dependency graph | [Dependency Graph](#dependency-graph) |
| `--init-config` | Run configuration wizard | [Tech Stack](#tech-stack) |

### File Locations

| Path | Purpose | Related Term |
|------|---------|--------------|
| `.workflow-config.yaml` | Project configuration | [YAML Configuration](#yaml-configuration) |
| `.workflow_checkpoint` | Resume state | [Checkpoint](#checkpoint) |
| `.ai_cache/` | Cached AI responses | [AI Cache](#ai-cache) |
| `src/workflow/backlog/` | Execution history | [Backlog](#backlog) |
| `src/workflow/metrics/` | Performance data | [Metrics](#metrics) |
| `src/workflow/lib/` | Library modules | [Library Module](#library-module) |
| `src/workflow/steps/` | Step implementations | [Step Module](#step-module) |
| `src/workflow/config/` | YAML configurations | [YAML Configuration](#yaml-configuration) |

### Performance Metrics

| Optimization | Time Savings | Related Term |
|--------------|--------------|--------------|
| AI Caching | 60-80% token reduction | [AI Response Caching](#ai-response-caching) |
| Smart Execution (docs) | 85% faster (23m→3.5m) | [Smart Execution](#smart-execution) |
| Smart Execution (code) | 40% faster (23m→14m) | [Smart Execution](#smart-execution) |
| Parallel Execution | 33% faster | [Parallel Execution](#parallel-execution) |
| Combined Optimizations | 90% faster (23m→2.3m) | All above |

---

## See Also

- [Architecture Decision Records](../design/adr/README.md) - Historical architectural decisions
- [Configuration Schema](configuration.md) - YAML configuration reference
- [Performance Benchmarks](performance-benchmarks.md) - Detailed performance data
- [Migration Guide](../user-guide/migration-guide.md) - Version upgrade instructions
- [Contributing Guide](../../CONTRIBUTING.md) - How to contribute

---

**Last Updated**: 2025-12-23  
**Version**: 1.0.0  
**Total Terms**: 70+  
**Status**: ✅ Complete
