# API Documentation - AI Workflow Automation

**Version**: v4.1.0  
**Last Updated**: 2026-02-10

## Overview

This directory contains comprehensive API documentation for all modules, functions, and interfaces in the AI Workflow Automation system.

## Quick Links

- **[Complete API Reference](COMPLETE_API_REFERENCE.md)** - All 848 functions across 69 modules
- **[Module Examples](#module-examples)** - Practical usage examples
- **[Core Modules](#core-modules)** - Essential modules for workflow integration
- **[Integration Guide](../INTEGRATION_GUIDE.md)** - Using workflow modules in your projects

## Module Categories

### 1. Core Infrastructure (4 modules)

Essential modules that form the foundation of the workflow system.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| [ai_helpers.sh](#ai_helperssh) | 44 | AI integration with GitHub Copilot CLI | `ai_call "persona" "prompt" "output.md"` |
| [change_detection.sh](#change_detectionsh) | 18 | Detect code, doc, and test changes | `analyze_changes && get_change_summary` |
| [metrics.sh](#metricssh) | 20 | Performance tracking and reporting | `init_metrics && finalize_metrics` |
| [workflow_optimization.sh](#workflow_optimizationsh) | 15 | Smart execution and parallel processing | `should_skip_step 5 && run_parallel` |

### 2. AI & Caching (6 modules)

AI integration, response caching, and prompt management.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| ai_cache.sh | 16 | AI response caching (60-80% token reduction) | `cache_ai_response "key" "response"` |
| ai_personas.sh | 10 | 17 specialized AI personas | `get_persona_prompt "documentation_specialist"` |
| ai_prompt_builder.sh | 12 | Dynamic prompt construction | `build_context_prompt "review" "$context"` |
| ai_validation.sh | 8 | AI response validation | `validate_ai_output "$response"` |
| analysis_cache.sh | 14 | Analysis result caching | `get_cached_analysis "step_1"` |
| api_coverage.sh | 6 | API documentation coverage tracking | `check_api_coverage` |

### 3. Git Operations (5 modules)

Automated git operations, caching, and commit management.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| git_automation.sh | 11 | Automated git operations | `stage_artifacts && commit_changes` |
| auto_commit.sh | 9 | Intelligent commit messages | `generate_commit_message "$changes"` |
| git_cache.sh | 7 | Git operation caching | `cache_git_status` |
| git_commit_history.sh | 8 | Commit history tracking | `track_step_commit "step_5"` |
| git_submodule_manager.sh | 10 | Submodule management | `sync_submodules` |

### 4. File Operations (2 modules)

Safe file manipulation and editing operations.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| file_operations.sh | 25 | Safe file operations | `safe_write_file "path" "content"` |
| edit_operations.sh | 18 | File editing utilities | `batch_edit "pattern" "replacement"` |

### 5. Documentation (6 modules)

Auto-documentation generation, changelog, and validation.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| auto_documentation.sh | 22 | Auto-generate documentation reports | `generate_step_report 5` |
| changelog_generator.sh | 15 | CHANGELOG generation from commits | `generate_changelog "v4.0.0"` |
| doc_template_validator.sh | 12 | Template validation | `validate_template "step_01.md"` |
| documentation_helpers.sh | 18 | Doc utilities and formatting | `format_markdown "$content"` |
| documentation_optimizer.sh | 14 | Doc optimization (Step 2.5) | `optimize_documentation` |
| toc_generator.sh | 8 | Table of contents generation | `generate_toc "README.md"` |

### 6. Step Management (7 modules)

Workflow step execution, loading, and registry.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| step_execution.sh | 20 | Execute steps with dependencies | `execute_step 5` |
| step_loader.sh | 15 | Dynamic step loading | `load_step "documentation_updates"` |
| step_registry.sh | 12 | Step metadata management | `register_step "step_5"` |
| step_adaptation.sh | 16 | Dynamic step behavior | `adapt_step_for_project 5` |
| step_validation_cache.sh | 10 | Cache validation results | `cache_step_validation 5` |
| step_skip_handler.sh | 8 | Interactive step skipping | `handle_skip_prompt` |
| checkpoint_manager.sh | 18 | Checkpoint resume | `save_checkpoint 5` |

### 7. Optimization (11 modules)

Smart execution, ML optimization, and performance tuning.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| ml_optimization.sh | 25 | ML-based step prediction | `predict_step_duration 5` |
| multi_stage_pipeline.sh | 18 | Progressive 3-stage validation | `execute_stage 1` |
| conditional_execution.sh | 22 | Smart step skipping | `should_skip_step 5` |
| dependency_graph.sh | 15 | Dependency analysis | `get_step_dependencies 5` |
| parallel_execution.sh | 20 | Parallel step processing | `run_parallel [3,4,5]` |
| performance.sh | 16 | Performance utilities | `measure_step_time 5` |
| code_changes_optimization.sh | 12 | Code-specific optimizations | `optimize_for_code_changes` |
| batch_operations.sh | 14 | Batch file operations | `batch_process_files` |
| smart_filters.sh | 10 | Intelligent file filtering | `filter_changed_files` |
| third_party_exclusion.sh | 8 | Exclude third-party code | `filter_third_party` |
| workflow_profiles.sh | 9 | Workflow templates | `load_profile "docs-only"` |

### 8. Configuration (4 modules)

Project configuration, wizard, and kind detection.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| config_wizard.sh | 16 | Interactive configuration | `run_config_wizard` |
| project_kind_config.sh | 26 | Project kind configuration | `load_project_config` |
| project_kind_detection.sh | 14 | Auto-detect project type | `detect_project_kind` |
| tech_stack.sh | 47 | Tech stack detection | `detect_tech_stack` |

### 9. Session & State (3 modules)

Session management, backlog, and execution state.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| session_manager.sh | 12 | Process and session management | `start_session "workflow"` |
| backlog.sh | 8 | Execution history tracking | `save_to_backlog "step_5.md"` |
| summaries.sh | 10 | Summary generation | `generate_summary` |

### 10. Performance & Monitoring (3 modules)

Performance tracking, dashboard, and profiling.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| performance.sh | 16 | Performance measurement | `track_performance "step_5"` |
| dashboard.sh | 12 | Metrics dashboard | `show_dashboard` |
| metrics_validation.sh | 11 | Metrics validation | `validate_metrics` |

### 11. Validation & Testing (6 modules)

Enhanced validation, API coverage, and test execution.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| enhanced_validations.sh | 18 | Advanced validation checks | `validate_all` |
| test_helpers.sh | 15 | Testing utilities | `run_test_suite` |
| pre_commit_hooks.sh | 10 | Fast pre-commit validation | `run_pre_commit_check` |
| code_example_tester.sh | 8 | Test code examples in docs | `test_code_examples` |
| validation_orchestrator.sh | 12 | Orchestrate validations | `run_validation_suite` |
| test_workflow_execution.sh | 20 | Workflow testing | `test_workflow` |

### 12. Utilities (7 modules)

Colors, argument parsing, health checks, and utilities.

| Module | Functions | Purpose | Example |
|--------|-----------|---------|---------|
| colors.sh | 10 | Terminal color output | `echo_info "message"` |
| argument_parser.sh | 19 | CLI argument parsing | `parse_arguments "$@"` |
| health_check.sh | 15 | System health validation | `run_health_check` |
| version_bump.sh | 8 | Version management | `bump_version "4.1.0"` |
| audio_notifications.sh | 6 | Audio feedback | `play_success_sound` |
| cleanup_handlers.sh | 12 | Resource cleanup | `register_cleanup_handler` |
| jq_wrapper.sh | 10 | Safe JSON operations | `jq_safe '.key' file.json` |

## Module Examples

### ai_helpers.sh

Core AI integration module with 44 functions and 17 AI personas.

**Basic Usage:**

```bash
#!/usr/bin/env bash
source "src/workflow/lib/ai_helpers.sh"

# Check if Copilot CLI is available
if ! check_copilot_available; then
    echo "Copilot CLI not available"
    exit 1
fi

# Call AI with a specific persona
ai_call "documentation_specialist" \
    "Review this README file and suggest improvements" \
    "review_output.md"

# Build a context-aware prompt
context=$(cat README.md)
prompt=$(build_ai_prompt "code_reviewer" "$context")
echo "$prompt" | gh copilot suggest
```

**Available Personas (17 total):**

1. `documentation_specialist` - Documentation updates and validation
2. `code_reviewer` - Code quality and best practices
3. `test_engineer` - Test development and validation
4. `technical_writer` - Bootstrap documentation (Step 0b)
5. `front_end_developer` - Front-end technical analysis (Step 11.7)
6. `ui_ux_designer` - UX/accessibility review (Step 15)
7. `integration_specialist` - Integration testing
8. `performance_analyst` - Performance optimization
9. `security_reviewer` - Security assessment
10. `api_designer` - API design review
11. `configuration_specialist` - Configuration management
12. `deployment_engineer` - Deployment automation
13. `devops_engineer` - CI/CD pipeline
14. `database_specialist` - Database operations
15. `git_specialist` - Git operations
16. `general_assistant` - General purpose tasks
17. `quality_engineer` - Overall quality assessment

**Advanced Features:**

```bash
# AI response caching (automatic, 60-80% token reduction)
# Responses cached for 24 hours with SHA256 keys
ai_call_with_cache "persona" "prompt" "output.md"

# Project-aware prompts (automatically enhanced)
# Uses PRIMARY_LANGUAGE from .workflow-config.yaml
ai_call_project_aware "documentation_specialist" "prompt" "output.md"

# Dynamic prompt building with context
build_context_prompt "review" "$(cat changed_files.txt)"
```

**See Also:**
- [ai_cache.sh](#ai_cachesh) - AI response caching
- [ai_personas.sh](#ai_personassh) - Persona management
- [ai_prompt_builder.sh](#ai_prompt_buildersh) - Prompt construction

---

### change_detection.sh

Detect code, documentation, and test changes with 18 functions.

**Basic Usage:**

```bash
#!/usr/bin/env bash
source "src/workflow/lib/change_detection.sh"

# Analyze all changes
analyze_changes

# Check specific change types
if has_code_changes; then
    echo "Code changes detected"
fi

if has_doc_changes; then
    echo "Documentation changes detected"
fi

if has_test_changes; then
    echo "Test changes detected"
fi

# Get change summary
get_change_summary
```

**Advanced Usage:**

```bash
# Get specific file lists
code_files=$(get_changed_code_files)
doc_files=$(get_changed_doc_files)
test_files=$(get_changed_test_files)

# Change severity (for smart execution)
severity=$(get_change_severity)  # minor, moderate, major

# Filter changes
get_filtered_changes --exclude-vendor --exclude-generated

# Export for other scripts
export_change_data "changes.json"
```

**Integration with Smart Execution:**

```bash
# Automatically skip steps based on changes
source "src/workflow/lib/conditional_execution.sh"

if should_skip_step 5; then
    echo "Skipping step 5 (no relevant changes)"
    exit 0
fi
```

**See Also:**
- [conditional_execution.sh](#conditional_executionsh) - Smart step skipping
- [workflow_optimization.sh](#workflow_optimizationsh) - Optimization
- [smart_filters.sh](#smart_filterssh) - File filtering

---

### metrics.sh

Performance tracking and reporting with 20 functions.

**Basic Usage:**

```bash
#!/usr/bin/env bash
source "src/workflow/lib/metrics.sh"

# Initialize metrics collection
init_metrics

# Track step execution
start_step_timer 5
# ... execute step ...
end_step_timer 5

# Record step outcome
record_step_result 5 "success"

# Finalize and save metrics
finalize_metrics
```

**Advanced Usage:**

```bash
# Custom metrics
record_custom_metric "ai_tokens_used" 1500
record_custom_metric "files_changed" 42

# Performance analysis
get_step_duration 5
get_total_duration
get_slowest_steps 5

# Export metrics
export_metrics_json "metrics/run_$(date +%Y%m%d_%H%M%S).json"
export_metrics_csv "metrics/history.csv"

# Historical comparison
compare_with_baseline
detect_performance_regression
```

**Metrics Dashboard:**

```bash
# Show real-time dashboard
source "src/workflow/lib/dashboard.sh"
show_metrics_dashboard

# Example output:
# ┌─────────────────────────────────────────┐
# │  Workflow Metrics Dashboard             │
# ├─────────────────────────────────────────┤
# │  Total Duration: 12m 34s                │
# │  Steps Completed: 15/23                 │
# │  Steps Skipped: 8 (smart execution)     │
# │  AI Token Usage: 12,450 (70% cached)    │
# │  Performance: 78% faster than baseline  │
# └─────────────────────────────────────────┘
```

**See Also:**
- [performance.sh](#performancesh) - Performance utilities
- [dashboard.sh](#dashboardsh) - Metrics dashboard
- [ml_optimization.sh](#ml_optimizationsh) - ML predictions

---

### workflow_optimization.sh

Smart execution and parallel processing with 15 functions.

**Basic Usage:**

```bash
#!/usr/bin/env bash
source "src/workflow/lib/workflow_optimization.sh"

# Enable smart execution
enable_smart_execution

# Check if step should be skipped
if should_skip_step 5; then
    echo "Step 5 skipped (no relevant changes)"
    exit 0
fi

# Enable parallel execution
enable_parallel_execution

# Run steps in parallel
run_steps_parallel 3 4 5
```

**Configuration:**

```bash
# Smart execution configuration
export SMART_EXECUTION=true
export PARALLEL_EXECUTION=true
export MAX_PARALLEL_JOBS=4

# ML optimization (requires 10+ historical runs)
export ML_OPTIMIZE=true
export ML_DATA_DIR=".ml_data"

# Multi-stage pipeline
export MULTI_STAGE=true
export CURRENT_STAGE=1  # 1=core, 2=extended, 3=finalization
```

**Performance Characteristics:**

| Mode | Documentation Only | Code Changes | Full Changes |
|------|-------------------|--------------|--------------|
| Baseline | 23 min | 23 min | 23 min |
| Smart | 3.5 min (85% faster) | 14 min (40% faster) | 23 min |
| Parallel | 15.5 min (33% faster) | 15.5 min (33% faster) | 15.5 min (33% faster) |
| Combined | 2.3 min (90% faster) | 10 min (57% faster) | 15.5 min (33% faster) |
| With ML | 1.5 min (93% faster) | 6-7 min (70-75% faster) | 10-11 min (52-57% faster) |

**See Also:**
- [conditional_execution.sh](#conditional_executionsh) - Smart skipping
- [parallel_execution.sh](#parallel_executionsh) - Parallel processing
- [ml_optimization.sh](#ml_optimizationsh) - ML predictions

---

## Integration Examples

### Example 1: Custom Workflow Script

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/src/workflow/lib/ai_helpers.sh"
source "$SCRIPT_DIR/src/workflow/lib/change_detection.sh"
source "$SCRIPT_DIR/src/workflow/lib/metrics.sh"

# Initialize
init_metrics
analyze_changes

# Check if AI is available
if check_copilot_available; then
    # Use AI for code review
    if has_code_changes; then
        code_files=$(get_changed_code_files)
        ai_call "code_reviewer" \
            "Review these code changes: $code_files" \
            "code_review.md"
    fi
fi

# Finalize
finalize_metrics
echo "Custom workflow completed!"
```

### Example 2: Git Pre-Commit Hook

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/src/workflow/lib/enhanced_validations.sh"
source "$REPO_ROOT/src/workflow/lib/pre_commit_hooks.sh"

# Fast validation checks (< 1 second)
if ! run_pre_commit_check; then
    echo "Pre-commit validation failed!"
    exit 1
fi

echo "Pre-commit validation passed!"
exit 0
```

### Example 3: CI/CD Pipeline

```yaml
# .github/workflows/workflow.yml
name: AI Workflow Automation

on: [push, pull_request]

jobs:
  workflow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Workflow
        run: |
          ./src/workflow/execute_tests_docs_workflow.sh \
            --auto \
            --smart-execution \
            --parallel \
            --ml-optimize \
            --multi-stage
      
      - name: Upload Metrics
        uses: actions/upload-artifact@v3
        with:
          name: metrics
          path: src/workflow/metrics/
```

### Example 4: Custom Step Module

```bash
#!/usr/bin/env bash
# src/workflow/steps/custom_analysis.sh

set -euo pipefail

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ai_helpers.sh"
source "$SCRIPT_DIR/../lib/colors.sh"

validate_step() {
    # Validation logic
    [[ -f "package.json" ]] || return 1
    return 0
}

execute_step() {
    echo_info "Running custom analysis..."
    
    # Your custom logic here
    ai_call "code_reviewer" \
        "Analyze package.json dependencies" \
        "dependency_analysis.md"
    
    echo_success "Custom analysis completed!"
    return 0
}

# Required for step module
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    execute_step
fi
```

**Register in workflow_steps.yaml:**

```yaml
- id: custom_analysis
  name: "Custom Dependency Analysis"
  file: custom_analysis.sh
  category: validation
  dependencies: []
  stage: 2
```

## Best Practices

### Module Usage

1. **Always source modules at the start**
   ```bash
   source "$SCRIPT_DIR/lib/module_name.sh"
   ```

2. **Check prerequisites**
   ```bash
   if ! check_copilot_available; then
       echo "Copilot CLI required but not available"
       exit 1
   fi
   ```

3. **Use error handling**
   ```bash
   set -euo pipefail  # Exit on error, undefined vars, pipe failures
   ```

4. **Clean up resources**
   ```bash
   trap cleanup_handler EXIT
   ```

### Performance Optimization

1. **Enable smart execution** for 40-85% faster execution
2. **Enable parallel execution** for 33% faster execution  
3. **Use AI caching** for 60-80% token reduction
4. **Enable ML optimization** for 15-30% additional improvement (requires 10+ runs)
5. **Use multi-stage pipeline** for early exit (80%+ complete in 2 stages)

### Testing

1. **Write unit tests** for new functions
2. **Test error conditions** and edge cases
3. **Use test helpers** from test_helpers.sh
4. **Run full test suite** before committing

```bash
cd src/workflow/lib
./test_enhancements.sh
```

## Further Reading

- **[Complete API Reference](COMPLETE_API_REFERENCE.md)** - Detailed function documentation
- **[Integration Guide](../INTEGRATION_GUIDE.md)** - Integration patterns and examples
- **[Module Development Guide](../MODULE_DEVELOPMENT_GUIDE.md)** - Creating new modules
- **[Testing Guide](../TESTING_BEST_PRACTICES.md)** - Testing strategies
- **[Architecture Overview](../ARCHITECTURE_OVERVIEW.md)** - System architecture

## Support

For questions or issues:
- **GitHub Issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
- **Email**: mpbarbosa@gmail.com

---

**Last Updated**: 2026-02-10 | **Version**: v4.1.0
