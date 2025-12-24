# GitHub Copilot Instructions - AI Workflow Automation

**Repository**: ai_workflow  
**Version**: v2.4.0  
**Last Updated**: 2025-12-23  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))

## Project Overview

AI Workflow Automation is an intelligent workflow system for validating and enhancing documentation, code, and tests with AI support. It provides a comprehensive 15-step automated pipeline with advanced optimization features including smart execution, parallel processing, AI response caching, and UX/accessibility analysis.

### Key Capabilities

> 📋 **Reference**: See [docs/PROJECT_REFERENCE.md](../docs/PROJECT_REFERENCE.md) for authoritative project statistics, features, and module inventory.

**Core Features**:
- **15-Step Automated Pipeline** with 14 AI personas
- **32 Library Modules** (14,993 lines) + **15 Step Modules** (4,777 lines)
- **Smart Execution**: 40-85% faster | **Parallel Execution**: 33% faster
- **AI Response Caching**: 60-80% token reduction
- **UX Analysis** (NEW v2.4.0): Accessibility checking with WCAG 2.1
- **Checkpoint Resume**: Automatic continuation from failures
- **100% Test Coverage**: 37+ automated tests

## Architecture Patterns

### Core Design Principles

1. **Functional Core / Imperative Shell**
   - Pure functions in library modules
   - Side effects isolated to step execution
   - Dependency injection for testability

2. **Single Responsibility Principle**
   - Each module has one clear purpose
   - Clean separation of concerns
   - Composable functions

3. **Configuration as Code**
   - YAML files for AI prompt templates
   - Centralized path configuration
   - Environment-based overrides

### Module Categories

> 📋 **Complete Inventory**: See [docs/PROJECT_REFERENCE.md#module-inventory](../docs/PROJECT_REFERENCE.md#module-inventory for full module list with descriptions.

**Quick Reference**:
- **Core Modules** (12): ai_helpers.sh, tech_stack.sh, workflow_optimization.sh, change_detection.sh, etc.
- **Supporting Modules** (16): edit_operations.sh, ai_cache.sh, session_manager.sh, etc.
- **Step Modules** (15): step_00_analyze.sh through step_14_ux_analysis.sh
- **Configuration Files** (6): YAML-based prompt templates and project configuration

## Key Files and Directories

### Primary Entry Points

```
src/workflow/execute_tests_docs_workflow.sh
├── Main orchestrator script (2,009 lines)
├── Handles all command-line options
├── Coordinates 15-step workflow execution
├── Manages parallel execution and metrics
└── Orchestrator modules (630 lines in orchestrators/): pre_flight, validation, quality, finalization
```

### Configuration Files

```
src/workflow/config/
├── paths.yaml                 # Path configuration
└── ai_helpers.yaml           # AI prompt templates (762 lines)
```

### Library and Step Modules

> 📋 **Complete List**: See [docs/PROJECT_REFERENCE.md#module-inventory](../docs/PROJECT_REFERENCE.md#module-inventory for all 28 library modules and 15 step modules with line counts.

### Documentation Structure

```
docs/workflow-automation/
├── COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md  # Master analysis
├── PHASE2_COMPLETION.md                          # Phase 2 features (NEW)
├── WORKFLOW_AUTOMATION_VERSION_EVOLUTION.md      # Version history
├── SHORT_TERM_ENHANCEMENTS_COMPLETION.md        # Enhancement tracking
├── WORKFLOW_MODULARIZATION_PHASE*.md            # Modularization phases
├── WORKFLOW_MODULE_INVENTORY.md                 # Module catalog
└── ...additional technical docs

docs/
├── TARGET_PROJECT_FEATURE.md                    # --target option guide (NEW)
└── QUICK_REFERENCE_TARGET_OPTION.md            # Quick reference (NEW)
```

### Execution Artifacts

```
src/workflow/
├── .ai_cache/                 # AI response cache (NEW v2.3.0)
│   └── index.json            # Cache index with TTL
├── backlog/                  # Execution history
│   └── workflow_YYYYMMDD_HHMMSS/
│       ├── step*_*.md        # Step execution reports
│       └── CHANGE_*.md       # Analysis reports
├── logs/                     # Execution logs
│   └── workflow_YYYYMMDD_HHMMSS/
│       └── *.log
├── metrics/                  # Performance metrics
│   ├── current_run.json      # Current execution metrics
│   └── history.jsonl         # Historical data
└── summaries/                # AI-generated summaries
    └── workflow_YYYYMMDD_HHMMSS/
```

## Development Workflow

### Command-Line Options (v2.4.0)

```bash
# Basic usage - runs on current directory by default
cd /path/to/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Target a different project
./execute_tests_docs_workflow.sh --target /path/to/project

# Smart execution (skip unnecessary steps based on changes)
./execute_tests_docs_workflow.sh --smart-execution

# Parallel execution (run independent steps simultaneously)
./execute_tests_docs_workflow.sh --parallel

# Combined optimization (recommended for production)
./execute_tests_docs_workflow.sh --smart-execution --parallel --auto

# Dependency visualization
./execute_tests_docs_workflow.sh --show-graph

# Disable AI caching (caching enabled by default)
./execute_tests_docs_workflow.sh --no-ai-cache

# Force fresh start (ignore checkpoints)
./execute_tests_docs_workflow.sh --no-resume

# Tech stack configuration
./execute_tests_docs_workflow.sh --init-config                     # Run configuration wizard
./execute_tests_docs_workflow.sh --show-tech-stack                 # Display detected tech stack
./execute_tests_docs_workflow.sh --config-file .my-config.yaml    # Use custom config file

# Selective step execution
./execute_tests_docs_workflow.sh --steps 0,5,6,7

# Dry run mode
./execute_tests_docs_workflow.sh --dry-run
```

### Performance Characteristics (v2.4.0)

| Change Type | Baseline | Smart | Parallel | Combined |
|-------------|----------|-------|----------|----------|
| Documentation Only | 23 min | 3.5 min (85% faster) | 15.5 min (33% faster) | 2.3 min (90% faster) |
| Code Changes | 23 min | 14 min (40% faster) | 15.5 min (33% faster) | 10 min (57% faster) |
| Full Changes | 23 min | 23 min (baseline) | 15.5 min (33% faster) | 15.5 min (33% faster) |

**AI Response Caching**: 60-80% token usage reduction with 24-hour TTL  
**Checkpoint Resume**: Automatic continuation from last completed step (use `--no-resume` to disable)

### Testing

```bash
# Run all library tests
cd src/workflow/lib
./test_enhancements.sh

# Test specific modules
./test_batch_operations.sh
./test_session_manager.sh

# Module-level tests
cd ../
./test_modules.sh
./test_file_operations.sh
```

### Code Style Guidelines

1. **Shell Script Standards**
   - Use `#!/usr/bin/env bash` shebang
   - Set `-euo pipefail` for error handling
   - Use `local` for function variables
   - Quote all variable expansions: `"${var}"`
   - Use `[[ ]]` for conditionals

2. **Function Design**
   - Clear, descriptive names (verb_noun pattern)
   - Single responsibility principle
   - Return status codes (0=success, 1+=error)
   - Document parameters and return values

3. **Error Handling**
   - Always check command exit codes
   - Provide meaningful error messages
   - Clean up resources on failure
   - Use `trap` for cleanup handlers

4. **Documentation**
   - Header comments for each module
   - Function-level documentation
   - Inline comments for complex logic
   - README files for directories

### AI Personas

> 📋 **Complete List**: See [docs/PROJECT_REFERENCE.md#ai-personas-14-total](../docs/PROJECT_REFERENCE.md#ai-personas-14-total for all 14 functional AI personas.

The system uses **14 specialized AI personas** including documentation_specialist, code_reviewer, test_engineer, and ux_designer (NEW v2.4.0).

Personas are implemented through:
- **9 base prompt templates** in `src/workflow/lib/ai_helpers.yaml`
- **4 project-kind specific personas** in `src/workflow/config/ai_prompts_project_kinds.yaml` (documentation_specialist, code_reviewer, test_engineer, ux_designer)
- **Language-aware enhancements**: When `PRIMARY_LANGUAGE` is set in `.workflow-config.yaml`, AI prompts are automatically enhanced with language-specific conventions (documentation standards, testing practices, code quality rules) from `ai_helpers.yaml`. This happens silently in Steps 2 and 5.

The documentation_specialist persona is project-aware and references:
- **`src/workflow/config/project_kinds.yaml`** - Defines project types (shell_script_automation, nodejs_api, static_website, client_spa, react_spa, python_app, generic) with quality standards, testing frameworks, and documentation requirements
- **`.workflow-config.yaml`** - Project-specific configuration including:
  - `project.kind` - Explicitly set project kind (shell_automation, nodejs_api, nodejs_cli, nodejs_library, static_website, client_spa, react_spa, vue_spa, python_api, python_cli, python_library, documentation)
  - `tech_stack.primary_language` - Primary programming language
  - Test commands and framework configuration
  - If `project.kind` is not specified, it will be auto-detected using the `detect_project_kind()` function

## Version History

> 📋 **Complete History**: See [docs/PROJECT_REFERENCE.md#version-history-major-releases](../docs/PROJECT_REFERENCE.md#version-history-major-releases for all releases and detailed changelogs.

**Current Version**: v2.4.0 (2025-12-23)
- Step 14: UX Analysis with accessibility checking
- UX Designer AI persona
- No breaking changes

**Recent Versions**: v2.3.1 (bug fixes), v2.3.0 (smart/parallel execution), v2.2.0 (metrics), v2.1.0 (modularization), v2.0.0 (initial release)

## Common Patterns

### Adding a New Step

1. Create step script in `src/workflow/steps/`
2. Follow naming convention: `step_XX_name.sh`
3. Implement required functions: `validate_step()`, `execute_step()`
4. Update dependency graph in `dependency_graph.sh`
5. Add step to main orchestrator
6. Write tests
7. Document in workflow analysis

### Adding a New Library Module

1. Create module in `src/workflow/lib/`
2. Add header comment with purpose and API
3. Export functions with clear names
4. Write unit tests
5. Update module inventory documentation
6. Source in main script if needed

### Working with AI Helpers

```bash
# Source the AI helpers module
source "$(dirname "$0")/lib/ai_helpers.sh"

# Call AI with specific persona
ai_call "documentation_specialist" "Your prompt here" "output.md"

# Check if Copilot CLI is available
if ! check_copilot_available; then
    echo "Copilot CLI not available, skipping AI features"
    return 0
fi

# AI response caching (automatic in v2.3.0)
# Responses cached for 24 hours with SHA256 keys
# Cleanup runs automatically every 24 hours
```

## Best Practices

### For Contributors

1. **Before Making Changes**
   - Run tests: `./test_modules.sh`
   - Review relevant documentation
   - Check existing patterns in similar modules

2. **When Adding Features**
   - Follow single responsibility principle
   - Update metrics collection if needed
   - Add tests for new functionality
   - Document in appropriate README files

3. **For Performance**
   - Use smart execution for faster iterations
   - Enable parallel execution when possible
   - Leverage AI caching (enabled by default)
   - Monitor metrics for regression detection

4. **For Documentation**
   - Update inline comments for complex logic
   - Keep module READMEs current
   - Update version history
   - Document breaking changes clearly

### For Users

1. **First-Time Setup**
   - Clone repository
   - Install prerequisites (Bash 4.0+, Git, Node.js 25.2.1+)
   - Run health check: `./src/workflow/lib/health_check.sh`
   - Test on sample project first

2. **Regular Usage**
   - Use `--smart-execution --parallel` for optimal performance
   - Review metrics after execution
   - Check backlog for execution history
   - Monitor AI cache hit rates

3. **Troubleshooting**
   - Check logs in `src/workflow/logs/`
   - Review execution reports in backlog
   - Verify prerequisites with health check
   - Use `--dry-run` to preview execution

## Integration Points

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Run Workflow Automation
  run: |
    ./src/workflow/execute_tests_docs_workflow.sh \
      --auto \
      --smart-execution \
      --parallel
```

### Git Hooks

```bash
# pre-commit hook example
#!/bin/bash
cd "$(git rev-parse --show-toplevel)"
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,2,3 \
  --dry-run
```

### Custom Automation

```bash
# Source workflow libraries
source ./src/workflow/lib/change_detection.sh
source ./src/workflow/lib/metrics.sh

# Use workflow functions in custom scripts
init_metrics
analyze_changes
# ... custom logic
finalize_metrics
```

## Support and Resources

> 📋 **Single Source of Truth**: [docs/PROJECT_REFERENCE.md](../docs/PROJECT_REFERENCE.md)

**Key Documentation**:
- **[docs/PROJECT_REFERENCE.md](../docs/PROJECT_REFERENCE.md) - Authoritative project reference (features, modules, versions)
- **[docs/archive/reports/implementation/MIGRATION_README.md](../docs/archive/reports/implementation/MIGRATION_README.md)**: Architecture overview
- **[docs/reference/workflow-diagrams.md](../docs/reference/workflow-diagrams.md) - Visual diagrams (17 Mermaid diagrams)
- **[docs/archive/](../docs/archive/)**: Comprehensive workflow documentation
- **[src/workflow/README.md](../src/workflow/README.md)**: Module API reference

---

**Note**: This project emphasizes code quality, maintainability, and developer experience. All changes should maintain the high standards established in the modular architecture and comprehensive documentation.
