# GitHub Copilot Instructions - AI Workflow Automation

**Repository**: ai_workflow  
**Version**: v2.3.1  
**Last Updated**: 2025-12-18

## Project Overview

AI Workflow Automation is an intelligent workflow system for validating and enhancing documentation, code, and tests with AI support. It provides a comprehensive 13-step automated pipeline with advanced optimization features including smart execution, parallel processing, and AI response caching.

### Key Capabilities

- **14-Step Automated Pipeline**: Complete workflow from pre-analysis to git finalization
- **28 Library Modules**: Modular architecture with single responsibility principle (27 .sh + 1 .yaml)
- **AI Integration**: GitHub Copilot CLI with 13 specialized personas
- **Smart Execution**: Change-based step skipping (40-85% faster)
- **Parallel Execution**: Independent steps run simultaneously (33% faster)
- **AI Response Caching**: 60-80% token usage reduction with automatic TTL management
- **Checkpoint Resume**: Automatic workflow continuation from last completed step
- **Metrics Collection**: Automatic performance tracking and historical analysis
- **Dependency Visualization**: Interactive graph with Mermaid diagrams
- **100% Test Coverage**: 37 automated tests ensure reliability

### Project Statistics

- **Total Lines**: 19,952 shell code + 4,194 YAML configuration = 24,146 total *[See PROJECT_STATISTICS.md]*
- **Modules**: 48 total (28 libraries + 14 steps + 6 configs)
- **Configuration**: YAML-based externalized prompt templates
- **Performance**: Up to 90% faster for documentation-only changes

> 📊 See [PROJECT_STATISTICS.md](../PROJECT_STATISTICS.md) for detailed breakdown.

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

#### Workflow Orchestration
- `execute_tests_docs_workflow.sh` - Main orchestrator (4,740 lines)
- `step_execution.sh` - Step lifecycle management
- `workflow_optimization.sh` - Smart execution and parallel processing

#### AI Integration
- `ai_helpers.sh` - GitHub Copilot CLI integration with 13 personas
- `ai_cache.sh` - AI response caching system (NEW in v2.3.0)
- `ai_helpers.yaml` - Prompt templates (762 lines)

#### Change Intelligence
- `change_detection.sh` - Git diff analysis and impact classification
- `dependency_graph.sh` - Execution dependency visualization
- `git_cache.sh` - Optimized git operations

#### Metrics & Performance
- `metrics.sh` - Performance tracking and historical analysis
- `performance.sh` - Timing and benchmarking utilities
- `health_check.sh` - System validation

#### Utilities
- `config.sh` - YAML configuration loading
- `backlog.sh` - Execution history management
- `file_operations.sh` - Safe file operations
- `colors.sh` - Terminal output formatting
- `utils.sh` - Common utilities
- `validation.sh` - Input validation and safety checks
- `summary.sh` - Report generation
- `session_manager.sh` - Long-running process management

## Key Files and Directories

### Primary Entry Points

```
src/workflow/execute_tests_docs_workflow.sh
├── Main orchestrator script (4,740 lines)
├── Handles all command-line options
├── Coordinates 13-step workflow execution
└── Manages parallel execution and metrics
```

### Configuration Files

```
src/workflow/config/
├── paths.yaml                 # Path configuration
└── ai_helpers.yaml           # AI prompt templates (762 lines)
```

### Library Modules (src/workflow/lib/)

**Core Modules**:
- `ai_helpers.sh` (18.7 KB) - AI integration with 13 personas
- `ai_cache.sh` (10.6 KB) - AI response caching (NEW v2.3.0)
- `change_detection.sh` (14.7 KB) - Change analysis
- `dependency_graph.sh` (13.5 KB) - Dependency visualization
- `metrics.sh` (12.2 KB) - Performance tracking
- `workflow_optimization.sh` (11.5 KB) - Execution optimization

**Support Modules**:
- `step_execution.sh` (9.6 KB) - Step lifecycle
- `config.sh` (6.8 KB) - Configuration loading
- `backlog.sh` (6.7 KB) - History management
- `file_operations.sh` (5.9 KB) - File utilities
- `health_check.sh` (5.7 KB) - System validation
- `performance.sh` (4.9 KB) - Timing utilities
- `session_manager.sh` (4.5 KB) - Process management
- `validation.sh` (4.3 KB) - Input validation
- `git_cache.sh` (3.8 KB) - Git operations
- `summary.sh` (3.0 KB) - Report generation
- `utils.sh` (2.8 KB) - Common utilities
- `colors.sh` (1.6 KB) - Terminal colors

### Step Modules (src/workflow/steps/)

1. `step_00_analyze.sh` - Pre-flight analysis and validation
2. `step_01_documentation.sh` - Documentation updates with AI
3. `step_02_consistency.sh` - Cross-reference consistency validation
4. `step_03_script_refs.sh` - Script reference validation
5. `step_04_directory.sh` - Directory structure validation
6. `step_05_test_review.sh` - Test coverage review
7. `step_06_test_gen.sh` - Test case generation
8. `step_07_test_exec.sh` - Test execution
9. `step_08_dependencies.sh` - Dependency validation
10. `step_09_code_quality.sh` - Code quality checks
11. `step_10_context.sh` - Context analysis
12. `step_11_git.sh` - Git operations and finalization
13. `step_12_markdown_lint.sh` - Markdown linting
14. `step_13_prompt_engineer.sh` - Prompt engineering analysis
15. `step_14_ux_analysis.sh` - UX/UI analysis (NEW in v2.4.0)

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

### Command-Line Options (v2.3.1)

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

### Performance Characteristics (v2.3.1)

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

The system uses 14 specialized AI personas for different tasks:

1. **documentation_specialist** - Documentation updates and validation (context-aware: adapts based on project kind and language from `project_kinds.yaml` and `.workflow-config.yaml`)
2. **consistency_analyst** - Cross-reference consistency checks
3. **code_reviewer** - Code quality and architecture review
4. **test_engineer** - Test generation and validation
5. **dependency_analyst** - Dependency graph analysis
6. **git_specialist** - Git operations and finalization
7. **performance_analyst** - Performance optimization
8. **security_analyst** - Security vulnerability scanning
9. **markdown_linter** - Markdown formatting validation
10. **context_analyst** - Contextual understanding and analysis
11. **script_validator** - Shell script validation
12. **directory_validator** - Directory structure validation
13. **test_execution_analyst** - Test execution analysis
14. **ux_designer** - UX/UI analysis and accessibility (NEW in v2.4.0)

Each persona has specialized prompts in `ai_helpers.yaml`. The documentation_specialist persona is project-aware and references:
- **`src/workflow/config/project_kinds.yaml`** - Defines project types (shell_script_automation, nodejs_api, static_website, react_spa, python_app, generic) with quality standards, testing frameworks, and documentation requirements
- **`.workflow-config.yaml`** - Project-specific configuration including:
  - `project.kind` - Explicitly set project kind (shell_automation, nodejs_api, nodejs_cli, nodejs_library, static_website, react_spa, vue_spa, python_api, python_cli, python_library, documentation)
  - `tech_stack.primary_language` - Primary programming language
  - Test commands and framework configuration
  - If `project.kind` is not specified, it will be auto-detected using the `detect_project_kind()` function

## Version History

### v2.3.1 (2025-12-18) - Critical Fixes & Checkpoint Control

**New Features**:
- ✅ `--no-resume` flag to bypass checkpoint resume functionality
- ✅ `--init-config` flag to run interactive configuration wizard
- ✅ `--show-tech-stack` flag to display detected technology stack
- ✅ `--config-file FILE` option to use custom .workflow-config.yaml file
- ✅ Tech stack initialization with auto-detection and configuration support
- ✅ Adaptive test execution supporting Jest, BATS, and pytest frameworks
- ✅ Adaptive directory validation based on project configuration
- ✅ Force fresh workflow start from Step 0 when needed

**Bug Fixes**:
- ✅ Fixed checkpoint file Bash syntax errors (proper variable quoting)
- ✅ Fixed metrics calculation arithmetic errors in historical stats
- ✅ Resolved "command not found" errors in checkpoint files
- ✅ Fixed Step 7 test execution directory navigation (now uses TARGET_DIR)
- ✅ Added safe log file directory checks to prevent early execution errors

**Improvements**:
- Enhanced checkpoint file format with proper quoting
- Improved error handling in metrics calculations
- Added tech stack detection and configuration framework
- Updated Step 4 to use config-based directory validation
- Updated Step 7 to support multiple test frameworks adaptively
- Added comprehensive project critical analysis documentation

### v2.3.0 (2025-12-18) - Phase 2 Integration Complete

**Major Features**:
- ✅ Smart execution with change detection (--smart-execution)
- ✅ Parallel execution of independent steps (--parallel)
- ✅ AI response caching system (ai_cache.sh module)
- ✅ Integrated metrics collection
- ✅ Dependency graph visualization (--show-graph)
- ✅ Target project option (--target, defaults to current directory)

**Performance Impact**:
- Up to 90% faster for documentation-only changes
- 60-80% token usage reduction with AI caching
- 33% time savings with parallel execution

### v2.2.0 (2025-12-17)
- Change detection and impact analysis
- Dependency graph generation
- Metrics framework foundation

### v2.1.0 (2025-12-15)
- Complete modularization (30 modules)
- YAML configuration system
- Enhanced output limits

### v2.0.0 (2025-12-14)
- Initial modular architecture
- 13-step workflow pipeline
- AI integration framework

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

- **Main Documentation**: `MIGRATION_README.md`
- **Technical Analysis**: `docs/workflow-automation/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md`
- **Module Reference**: `src/workflow/README.md`
- **Feature Guide**: `docs/TARGET_PROJECT_FEATURE.md`
- **Quick Reference**: `docs/QUICK_REFERENCE_TARGET_OPTION.md`

---

**Note**: This project emphasizes code quality, maintainability, and developer experience. All changes should maintain the high standards established in the modular architecture and comprehensive documentation.
