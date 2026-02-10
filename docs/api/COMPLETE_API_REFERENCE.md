# Complete API Reference - AI Workflow Automation

> **Version**: 4.0.1  
> **Last Updated**: 2026-02-10  
> **Generated**: Auto-generated from source code  

**Total Modules**: 69  
**Total Functions**: 848  


## Introduction

This document provides a complete API reference for all library modules in the AI Workflow Automation system. The system consists of **69 library modules** with **848 functions** organized into **12 categories**.

### Purpose

This reference serves as:
- **Developer Guide**: Understand available functions and their usage
- **Integration Reference**: Learn how to use workflow modules in custom scripts
- **Maintenance Guide**: Track function signatures and documentation
- **Code Navigation**: Quickly find relevant functions by category

### Module Organization

Modules are organized into the following categories:

1. **AI & Caching** (6 modules) - AI prompt management, response caching, persona handling
2. **Core Infrastructure** (4 modules) - Change detection, metrics, tech stack, optimization
3. **Configuration** (4 modules) - Project configuration, wizard, kind detection
4. **Git Operations** (5 modules) - Git automation, caching, submodule management, auto-commit
5. **File Operations** (2 modules) - File editing and manipulation utilities
6. **Documentation** (6 modules) - Auto-documentation, changelog, templates, validation
7. **Step Management** (7 modules) - Step execution, loading, registry, validation cache
8. **Session & State** (3 modules) - Session management, backlog, summaries
9. **Optimization** (11 modules) - Smart execution, ML optimization, multi-stage pipeline
10. **Performance & Monitoring** (3 modules) - Performance tracking, dashboard
11. **Validation & Testing** (6 modules) - Enhanced validations, API coverage, test execution
12. **Utilities** (7 modules) - Colors, argument parsing, health checks, version bumping

### Key Modules

#### Core Infrastructure
- **change_detection.sh** (18 functions) - Detect code, documentation, and test changes
- **metrics.sh** (20 functions) - Performance metrics collection and reporting
- **workflow_optimization.sh** - Smart execution and performance optimization
- **tech_stack.sh** - Tech stack detection and configuration

#### AI & Caching
- **ai_helpers.sh** (44 functions) - Core AI integration with GitHub Copilot CLI
- **ai_cache.sh** (16 functions) - AI response caching with 60-80% token reduction
- **ai_personas.sh** - 17 specialized AI personas for different tasks
- **ai_prompt_builder.sh** - Dynamic prompt construction with context awareness

#### Git Operations
- **git_automation.sh** (11 functions) - Automated git operations and artifact staging
- **auto_commit.sh** - Intelligent commit message generation
- **git_cache.sh** - Git operation caching for performance

#### Step Management
- **step_execution.sh** - Execute workflow steps with dependency management
- **step_loader.sh** - Dynamic step loading with configuration support
- **step_registry.sh** - Step registration and metadata management
- **step_validation_cache.sh** - Cache validation results across runs

#### Optimization
- **ml_optimization.sh** - Machine learning-based step prediction
- **multi_stage_pipeline.sh** - Progressive 3-stage validation
- **conditional_execution.sh** - Smart step skipping based on changes
- **dependency_graph.sh** - Step dependency analysis and optimization

### Usage Patterns

#### Sourcing Modules

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/ai_helpers.sh"
source "${SCRIPT_DIR}/lib/change_detection.sh"
source "${SCRIPT_DIR}/lib/metrics.sh"

# Use module functions
init_metrics
analyze_changes
# ... your code
finalize_metrics
```

#### Using AI Helpers

```bash
# Initialize AI cache
init_ai_cache

# Call AI with specific persona
ai_call "documentation_specialist" "Analyze this file" "output.md"

# Build dynamic prompt
build_ai_prompt "code_reviewer" "additional context" > prompt.txt
```

#### Change Detection

```bash
# Analyze what changed
analyze_changes

# Check specific change types
if has_code_changes; then
    echo "Code changes detected"
fi

if has_doc_changes; then
    echo "Documentation changes detected"
fi

# Get filtered file lists
get_changed_code_files
get_changed_doc_files
```

#### Metrics Collection

```bash
# Initialize metrics
init_metrics

# Track step execution
start_step_timer "01" "Documentation Analysis"
# ... execute step
stop_step_timer "01" "success"

# Finalize and report
finalize_metrics
generate_metrics_report
```

#### Step Execution

```bash
# Load step configuration
load_step_config "documentation_updates"

# Execute step with dependencies
execute_step_with_dependencies "documentation_updates"

# Check step status
if step_completed "documentation_updates"; then
    echo "Step completed successfully"
fi
```

### Function Naming Conventions

Functions follow consistent naming patterns:

- **Verb_Noun**: `init_metrics`, `analyze_changes`, `validate_config`
- **Get_Something**: `get_changed_files`, `get_step_name`, `get_execution_mode`
- **Has/Is_Something**: `has_code_changes`, `is_workflow_artifact`, `is_copilot_available`
- **Check_Something**: `check_prerequisites`, `check_git_status`
- **Build/Generate_Something**: `build_prompt`, `generate_report`

### Return Values and Exit Codes

Most functions follow these conventions:

- **0** - Success
- **1** - General error
- **2** - Invalid arguments
- **3** - Missing dependencies
- **4** - Configuration error

### Error Handling

All modules follow consistent error handling:

```bash
function example_function() {
    local param="${1:-}"
    
    # Validate parameters
    if [[ -z "$param" ]]; then
        echo "ERROR: Parameter required" >&2
        return 1
    fi
    
    # Execute with error handling
    if ! some_command; then
        echo "ERROR: Command failed" >&2
        return 1
    fi
    
    return 0
}
```

### Testing

Each module has corresponding test files in `src/workflow/lib/test_*.sh`. Run tests with:

```bash
cd src/workflow/lib
./test_enhancements.sh        # Run all tests
./test_batch_operations.sh    # Test specific module
```

### Documentation Standards

All functions should include:
- **Description**: What the function does
- **Parameters**: List of parameters with types and descriptions
- **Returns**: Return value and exit codes
- **Examples**: Usage examples when complex
- **Notes**: Important implementation details

---


## Table of Contents

### AI & Caching

- [ai_cache.sh](#module-ai-cache)
- [ai_helpers.sh](#module-ai-helpers)
- [ai_personas.sh](#module-ai-personas)
- [ai_prompt_builder.sh](#module-ai-prompt-builder)
- [ai_validation.sh](#module-ai-validation)
- [analysis_cache.sh](#module-analysis-cache)

### AI Model Selection

- [model_selector.sh](#module-model-selector)

### Cleanup

- [cleanup_handlers.sh](#module-cleanup-handlers)
- [cleanup_template.sh](#module-cleanup-template)

### Configuration

- [config.sh](#module-config)
- [config_wizard.sh](#module-config-wizard)
- [project_kind_config.sh](#module-project-kind-config)
- [project_kind_detection.sh](#module-project-kind-detection)

### Core Infrastructure

- [change_detection.sh](#module-change-detection)
- [metrics.sh](#module-metrics)
- [tech_stack.sh](#module-tech-stack)
- [workflow_optimization.sh](#module-workflow-optimization)

### Documentation

- [auto_documentation.sh](#module-auto-documentation)
- [changelog_generator.sh](#module-changelog-generator)
- [doc_section_extractor.sh](#module-doc-section-extractor)
- [doc_section_mapper.sh](#module-doc-section-mapper)
- [doc_template_validator.sh](#module-doc-template-validator)
- [link_validator.sh](#module-link-validator)

### File Operations

- [edit_operations.sh](#module-edit-operations)
- [file_operations.sh](#module-file-operations)

### Git Operations

- [auto_commit.sh](#module-auto-commit)
- [batch_ai_commit.sh](#module-batch-ai-commit)
- [git_automation.sh](#module-git-automation)
- [git_cache.sh](#module-git-cache)
- [git_submodule_helpers.sh](#module-git-submodule-helpers)

### Hooks

- [precommit_hooks.sh](#module-precommit-hooks)

### Optimization

- [code_changes_optimization.sh](#module-code-changes-optimization)
- [conditional_execution.sh](#module-conditional-execution)
- [dependency_cache.sh](#module-dependency-cache)
- [dependency_graph.sh](#module-dependency-graph)
- [docs_only_optimization.sh](#module-docs-only-optimization)
- [full_changes_optimization.sh](#module-full-changes-optimization)
- [incremental_analysis.sh](#module-incremental-analysis)
- [ml_optimization.sh](#module-ml-optimization)
- [multi_stage_pipeline.sh](#module-multi-stage-pipeline)
- [skip_predictor.sh](#module-skip-predictor)
- [workflow_profiles.sh](#module-workflow-profiles)

### Performance & Monitoring

- [dashboard.sh](#module-dashboard)
- [performance.sh](#module-performance)
- [performance_monitoring.sh](#module-performance-monitoring)

### Session & State

- [backlog.sh](#module-backlog)
- [session_manager.sh](#module-session-manager)
- [summary.sh](#module-summary)

### Step Management

- [step_adaptation.sh](#module-step-adaptation)
- [step_execution.sh](#module-step-execution)
- [step_loader.sh](#module-step-loader)
- [step_metadata.sh](#module-step-metadata)
- [step_registry.sh](#module-step-registry)
- [step_validation_cache.sh](#module-step-validation-cache)
- [step_validation_cache_integration.sh](#module-step-validation-cache-integration)

### User Experience

- [audio_notifications.sh](#module-audio-notifications)

### Utilities

- [argument_parser.sh](#module-argument-parser)
- [colors.sh](#module-colors)
- [health_check.sh](#module-health-check)
- [jq_wrapper.sh](#module-jq-wrapper)
- [third_party_exclusion.sh](#module-third-party-exclusion)
- [utils.sh](#module-utils)
- [version_bump.sh](#module-version-bump)

### Validation & Testing

- [api_coverage.sh](#module-api-coverage)
- [code_example_tester.sh](#module-code-example-tester)
- [deployment_validator.sh](#module-deployment-validator)
- [enhanced_validations.sh](#module-enhanced-validations)
- [metrics_validation.sh](#module-metrics-validation)
- [validation.sh](#module-validation)

---

## Module: ai_cache.sh

**Location**: `src/workflow/lib/ai_cache.sh`  
**Category**: AI & Caching

**Functions**: 16

### `init_ai_cache`

**Description**: Initialize AI cache directory and index

**Source Line**: 34

---

### `generate_cache_key`

**Description**: Generate a cache key from prompt and context Args: $1 = prompt text, $2 = context (optional)

**Returns**: Returns: SHA256 hash as cache key

**Source Line**: 72

---

### `check_cache`

**Description**: Check if cached response exists and is valid Args: $1 = cache_key

**Returns**: Returns: 0 if exists and valid, 1 otherwise

**Source Line**: 88

---

### `get_cached_response`

**Description**: Get cached response Args: $1 = cache_key

**Returns**: Returns: Cached response content

**Source Line**: 122

---

### `get_from_cache`

**Description**: Alias for backward compatibility with tests

**Source Line**: 140

---

### `save_to_cache`

**Description**: Save response to cache Args: $1 = cache_key, $2 = response_text, $3 = prompt (optional), $4 = context (optional)

**Source Line**: 146

---

### `update_cache_index`

**Description**: Update cache index with new entry

**Source Line**: 189

---

### `cleanup_ai_cache_old_entries`

**Description**: Cleanup old cache entries

**Source Line**: 223

---

### `get_cache_stats`

**Description**: Get cache statistics

**Source Line**: 285

---

### `clear_ai_cache`

**Description**: Clear entire cache

**Source Line**: 308

---

### `call_ai_with_cache`

**Description**: Wrapper function for AI calls with caching Args: $1 = prompt, $2 = context, $3 = ai_command

**Returns**: Returns: AI response (cached or fresh)

**Source Line**: 323

---

### `record_cache_hit`

*No documentation available*

**Source Line**: 366

---

### `record_cache_miss`

*No documentation available*

**Source Line**: 372

---

### `get_cache_metrics`

*No documentation available*

**Source Line**: 376

---

### `track_ai_cache_temp`

**Description**: Register temp file for cleanup

**Source Line**: 402

---

### `cleanup_ai_cache`

**Description**: Cleanup function for ai_cache module

**Source Line**: 408

---


## Module: ai_helpers.sh

**Location**: `src/workflow/lib/ai_helpers.sh`  
**Category**: AI & Caching

**Functions**: 44

### `track_ai_helpers_temp`

**Description**: Register temp file for cleanup

**Source Line**: 24

---

### `cleanup_ai_helpers_files`

**Description**: Cleanup handler for AI helpers

**Source Line**: 30

---

### `is_copilot_available`

**Description**: Check if Copilot CLI is available

**Returns**: Returns: 0 if available, 1 if not

**Source Line**: 44

---

### `is_copilot_authenticated`

**Description**: Check if Copilot CLI is authenticated

**Returns**: Returns: 0 if authenticated, 1 if not

**Source Line**: 50

---

### `validate_copilot_cli`

**Description**: Validate Copilot CLI and provide user feedback Usage: validate_copilot_cli

**Source Line**: 70

---

### `get_project_metadata`

**Description**: Get project metadata from configuration

**Returns**: Returns: pipe-delimited string with project_name|project_description|primary_language

**Source Line**: 96

---

### `build_ai_prompt`

**Description**: Build a structured AI prompt with role, task, and standards Usage: build_ai_prompt <role> <task> <standards>

**Source Line**: 151

---

### `compose_role_from_yaml`

**Description**: Compose role from role_prefix and behavioral_guidelines if available Falls back to legacy 'role' field for backward compatibility Usage: compose_role_from_yaml <yaml_file> <prompt_section>

**Returns**: Returns: Complete role text

**Source Line**: 173

---

### `build_doc_analysis_prompt`

**Description**: Build a documentation analysis prompt Usage: build_doc_analysis_prompt <changed_files> <doc_files> Step 1: Build a documentation analysis prompt Build documentation analysis prompt Usage: build_doc_analysis_prompt <changed_files> <doc_files>

**Source Line**: 241

---

### `build_consistency_prompt`

**Description**: Build a consistency analysis prompt Usage: build_consistency_prompt <files_to_check> Step 2: Build a documentation consistency analysis prompt

**Source Line**: 506

---

### `build_test_strategy_prompt`

**Description**: Build a test strategy analysis prompt Usage: build_test_strategy_prompt <coverage_stats> <test_files>

**Source Line**: 564

---

### `build_quality_prompt`

**Description**: Build a code quality validation prompt Usage: build_quality_prompt <files_to_review>

**Source Line**: 625

---

### `build_issue_extraction_prompt`

**Description**: Build an issue extraction prompt for Copilot session logs Usage: build_issue_extraction_prompt <log_file> <log_content>

**Source Line**: 684

---

### `build_step2_consistency_prompt`

**Description**: Build a documentation consistency analysis prompt (Step 2) Usage: build_step2_consistency_prompt <doc_count> <change_scope> <modified_count> <broken_refs> <doc_files>

**Source Line**: 761

---

### `build_step3_script_refs_prompt`

**Description**: Build a shell script reference validation prompt (Step 3) Usage: build_step3_script_refs_prompt <script_count> <change_scope> <issues> <script_issues> <all_scripts> <modified_count>

**Source Line**: 893

---

### `build_step4_directory_prompt`

**Description**: Build a directory structure validation prompt (Step 4) Usage: build_step4_directory_prompt <dir_count> <change_scope> <missing_critical> <undocumented_dirs> <doc_mismatch> <structure_issues> <dir_tree> [modified_count]

**Source Line**: 1056

---

### `build_step5_test_review_prompt`

**Description**: Build a test review and recommendations prompt (Step 5) Usage: build_step5_test_review_prompt <test_framework> <test_env> <test_count> <code_files> <tests_in_dir> <tests_colocated> <coverage_exists> <test_issues> <test_files>

**Source Line**: 1249

---

### `build_step7_test_exec_prompt`

**Description**: Build a test execution analysis prompt (Step 7) Usage: build_step7_test_exec_prompt <test_exit_code> <tests_total> <tests_passed> <tests_failed> <exec_summary> <test_output> <failed_tests>

**Source Line**: 1420

---

### `build_step8_dependencies_prompt`

**Description**: Build a dependency management analysis prompt (Step 8) Usage: build_step8_dependencies_prompt <node_version> <npm_version> <dep_count> <dev_dep_count> <total_deps> <dep_summary> <dep_report> <prod_deps> <dev_deps> <audit_summary> <outdated_list>

**Source Line**: 1573

---

### `build_step9_code_quality_prompt`

**Description**: Build a code quality assessment prompt (Step 9) Usage: build_step9_code_quality_prompt <total_files> <js_files> <html_files> <css_files> <quality_summary> <quality_report> <large_files> <sample_code> Phase 4: Now includes language-aware enhancements

**Source Line**: 1742

---

### `build_step11_git_commit_prompt`

**Description**: Build a git commit message generation prompt (Step 11) Usage: build_step11_git_commit_prompt <script_version> <change_scope> <git_context> <changed_files> <diff_summary> <git_analysis> <diff_sample>

**Source Line**: 1928

---

### `log_ai_prompt`

**Description**: Log executed AI prompt to prompts directory Usage: log_ai_prompt <step_name> <persona> <prompt_text>

**Source Line**: 2130

---

### `normalize_step_id`

**Description**: Normalize step ID to match model_definitions.json keys Usage: normalize_step_id <step_id>

**Returns**: Returns: normalized step ID (e.g., "0b" → "step_0b_bootstrap_docs", "step01" → "step_01_documentation")

**Source Line**: 2190

---

### `get_model_for_step`

**Description**: Get model for specific workflow step from model definitions Usage: get_model_for_step <step_id>

**Returns**: Returns: model name or "default"

**Source Line**: 2227

---

### `get_current_step_id`

**Description**: Get current step ID from environment or call stack Usage: get_current_step_id

**Returns**: Returns: step ID (e.g., "step_01_documentation")

**Source Line**: 2257

---

### `execute_copilot_batch`

**Description**: Usage: execute_copilot_batch <prompt_text> <log_file> [timeout_seconds] [step_name] [persona]

**Source Line**: 2282

---

### `execute_copilot_prompt`

**Description**: Enhanced execute_copilot_prompt with batch mode support Usage: execute_copilot_prompt <prompt_text> [log_file] [step_name] [persona]

**Source Line**: 2356

---

### `trigger_ai_step`

**Description**: Trigger an AI-enhanced step with confirmation Usage: trigger_ai_step <step_name> <prompt_builder_function> <args...>

**Source Line**: 2464

---

### `extract_and_save_issues_from_log`

**Description**: Execute issue extraction workflow from Copilot session logs This function handles the complete workflow of extracting issues from a Copilot CLI session log file and saving them to the backlog. Supports two modes: - AUTO_MODE: Automatically parses log file for issues (no user interaction) - INTERACTIVE: Uses Copilot CLI for extraction with user confirmation Usage: extract_and_save_issues_from_log <step_number> <step_name> <log_file>

**Parameters**:
- Parameters:
- step_number - The workflow step number (e.g., "2", "3")
- step_name   - The step name for backlog organization (e.g., "Consistency_Analysis")
- log_file    - Path to the Copilot session log file

**Returns**: Returns: 0 on success, 1 on error Workflow (AUTO_MODE): 1. Automatically parses log file for issues 2. Extracts key sections (changes, recommendations, warnings) 3. Saves formatted issues to backlog Workflow (INTERACTIVE): 1. Prompts user to confirm issue extraction 2. Builds issue extraction prompt 3. Executes Copilot CLI with the prompt 4. Accepts multi-line user input of organized issues 5. Saves issues to backlog

**Source Line**: 2551

---

### `get_language_documentation_conventions`

**Description**: ###################################### Load language-specific documentation conventions Globals: PRIMARY_LANGUAGE Arguments: None

**Returns**: Returns: Language-specific documentation conventions ######################################

**Source Line**: 2689

---

### `get_language_quality_standards`

**Description**: ###################################### Load language-specific quality standards Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Language-specific quality focus areas and best practices ######################################

**Source Line**: 2716

---

### `get_language_testing_patterns`

**Description**: ###################################### Load language-specific testing patterns Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Language-specific test framework and patterns ######################################

**Source Line**: 2744

---

### `generate_language_aware_prompt`

**Description**: ###################################### Generate language-aware AI prompt Arguments: $1 - Base prompt (from existing functions) $2 - Prompt type (documentation|quality|testing) Globals: PRIMARY_LANGUAGE BUILD_SYSTEM TEST_FRAMEWORK

**Returns**: Returns: Enhanced prompt with language-specific context ######################################

**Source Line**: 2777

---

### `build_language_aware_doc_prompt`

**Description**: ###################################### Build language-aware documentation prompt Enhanced version of build_doc_analysis_prompt Arguments: $1 - changed_files $2 - doc_files

**Returns**: Returns: Language-aware documentation prompt ######################################

**Source Line**: 2852

---

### `build_language_aware_quality_prompt`

**Description**: ###################################### Build language-aware quality prompt Enhanced version of build_quality_prompt Arguments: $1 - files_to_review

**Returns**: Returns: Language-aware quality prompt ######################################

**Source Line**: 2872

---

### `build_language_aware_test_prompt`

**Description**: ###################################### Build language-aware test strategy prompt Enhanced version of build_test_strategy_prompt Arguments: $1 - coverage_stats $2 - test_files

**Returns**: Returns: Language-aware test strategy prompt ######################################

**Source Line**: 2892

---

### `should_use_language_aware_prompts`

**Description**: ###################################### Check if language-aware prompts should be used

**Returns**: Returns: 0 if language-aware prompts should be used, 1 otherwise ######################################

**Source Line**: 2909

---

### `get_project_kind_prompt`

**Description**: ###################################### Load project kind-specific prompt template Arguments: $1 - project_kind (e.g., "shell_automation", "nodejs_api") $2 - persona (e.g., "documentation_specialist", "test_engineer", "code_reviewer") $3 - field (e.g., "role", "task_context", "approach")

**Returns**: Returns: Prompt template text ######################################

**Source Line**: 2950

---

### `build_project_kind_prompt`

**Description**: ###################################### Build project kind-aware AI prompt Arguments: $1 - project_kind $2 - persona $3 - task_description (specific task details to append)

**Returns**: Returns: Complete AI prompt ######################################

**Source Line**: 3012

---

### `build_project_kind_doc_prompt`

**Description**: ###################################### Get project kind-aware documentation prompt Arguments: $1 - changed_files $2 - doc_files

**Returns**: Returns: Project kind-aware documentation prompt ######################################

**Source Line**: 3048

---

### `build_project_kind_test_prompt`

**Description**: ###################################### Get project kind-aware test prompt Arguments: $1 - coverage_stats $2 - test_files

**Returns**: Returns: Project kind-aware test prompt ######################################

**Source Line**: 3077

---

### `build_project_kind_review_prompt`

**Description**: ###################################### Get project kind-aware code review prompt Arguments: $1 - files_to_review $2 - review_focus (optional: "security", "performance", "maintainability")

**Returns**: Returns: Project kind-aware code review prompt ######################################

**Source Line**: 3105

---

### `should_use_project_kind_prompts`

**Description**: ###################################### Check if project kind-aware prompts should be used

**Returns**: Returns: 0 if should use, 1 otherwise ######################################

**Source Line**: 3135

---

### `generate_adaptive_prompt`

**Description**: ###################################### Get combined language and project kind-aware prompt Arguments: $1 - base_prompt $2 - context_type ("documentation", "testing", "quality")

**Returns**: Returns: Enhanced prompt with both language and project kind awareness ######################################

**Source Line**: 3159

---


## Module: ai_personas.sh

**Location**: `src/workflow/lib/ai_personas.sh`  
**Category**: AI & Caching

**Functions**: 10

### `get_project_kind_prompt`

**Description**: Get project kind specific prompt from YAML configuration Usage: get_project_kind_prompt <persona_name> <project_kind>

**Returns**: Returns: Prompt text or empty string if not found

**Source Line**: 18

---

### `build_project_kind_prompt`

**Description**: Build project-kind aware prompt Usage: build_project_kind_prompt <persona_name> <project_kind> <fallback_prompt>

**Source Line**: 41

---

### `build_project_kind_doc_prompt`

**Description**: Build project-kind aware documentation prompt Usage: build_project_kind_doc_prompt <project_kind> <changed_files> <doc_files>

**Source Line**: 60

---

### `build_project_kind_test_prompt`

**Description**: Build project-kind aware test prompt Usage: build_project_kind_test_prompt <project_kind> <code_files>

**Source Line**: 74

---

### `build_project_kind_review_prompt`

**Description**: Build project-kind aware code review prompt Usage: build_project_kind_review_prompt <project_kind> <code_files>

**Source Line**: 87

---

### `should_use_project_kind_prompts`

**Description**: Check if project-kind aware prompts should be used Usage: should_use_project_kind_prompts

**Returns**: Returns: 0 if should use, 1 if not

**Source Line**: 101

---

### `generate_adaptive_prompt`

**Description**: Generate adaptive prompt based on project configuration Usage: generate_adaptive_prompt <persona_name> <fallback_prompt> [additional_context]

**Source Line**: 119

---

### `get_language_documentation_conventions`

**Description**: Get language-specific documentation conventions Usage: get_language_documentation_conventions <language>

**Source Line**: 152

---

### `get_language_quality_standards`

**Description**: Get language-specific quality standards Usage: get_language_quality_standards <language>

**Source Line**: 179

---

### `get_language_testing_patterns`

**Description**: Get language-specific testing patterns Usage: get_language_testing_patterns <language>

**Source Line**: 200

---


## Module: ai_prompt_builder.sh

**Location**: `src/workflow/lib/ai_prompt_builder.sh`  
**Category**: AI & Caching

**Functions**: 9

### `get_language_specific_content`

**Description**: Get language-specific content from YAML and format for prompt Usage: get_language_specific_content <yaml_file> <section_name> <language>

**Examples**:
```bash
```

**Source Line**: 18

---

### `substitute_language_placeholders`

**Description**: Substitute language-specific placeholders in prompt template Usage: substitute_language_placeholders <prompt_text> <yaml_file> Replaces: {language_specific_documentation}, {language_specific_testing_standards}, {language_specific_quality}

**Source Line**: 70

---

### `get_yq_value`

**Description**: Get YAML value with version detection Usage: get_yq_value <yaml_file> <yaml_path>

**Source Line**: 143

---

### `build_ai_prompt`

**Description**: Build a structured AI prompt with role, task, and standards Usage: build_ai_prompt <role> <task> <standards>

**Source Line**: 162

---

### `build_doc_analysis_prompt`

**Description**: Build a documentation analysis prompt Usage: build_doc_analysis_prompt <changed_files> <doc_files>

**Source Line**: 178

---

### `build_consistency_prompt`

**Description**: Build a consistency analysis prompt Usage: build_consistency_prompt <doc_directory>

**Source Line**: 262

---

### `build_test_strategy_prompt`

**Description**: Build a test strategy prompt Usage: build_test_strategy_prompt <code_files> <test_framework>

**Source Line**: 337

---

### `build_quality_prompt`

**Description**: Build a code quality review prompt Usage: build_quality_prompt <code_files> <language>

**Source Line**: 419

---

### `build_issue_extraction_prompt`

**Description**: Build an issue extraction prompt Usage: build_issue_extraction_prompt <log_file>

**Source Line**: 509

---


## Module: ai_validation.sh

**Location**: `src/workflow/lib/ai_validation.sh`  
**Category**: AI & Caching

**Functions**: 5

### `is_copilot_available`

**Description**: Check if Copilot CLI is available

**Returns**: Returns: 0 if available, 1 if not

**Source Line**: 17

---

### `is_copilot_authenticated`

**Description**: Check if Copilot CLI is authenticated

**Returns**: Returns: 0 if authenticated, 1 if not

**Source Line**: 23

---

### `validate_copilot_cli`

**Description**: Validate Copilot CLI and provide user feedback Usage: validate_copilot_cli

**Source Line**: 43

---

### `validate_ai_response`

**Description**: Validate AI response for completeness Usage: validate_ai_response <response_file> <expected_sections>

**Returns**: Returns: 0 if valid, 1 if not

**Source Line**: 66

---

### `should_enable_ai`

**Description**: Check if AI features should be enabled Usage: should_enable_ai

**Returns**: Returns: 0 if should enable, 1 if not

**Source Line**: 101

---


## Module: analysis_cache.sh

**Location**: `src/workflow/lib/analysis_cache.sh`  
**Category**: AI & Caching

**Functions**: 24

### `track_analysis_cache_temp`

**Description**: Register temp file for cleanup

**Source Line**: 34

---

### `cleanup_analysis_cache_files`

**Description**: Cleanup handler for analysis cache

**Source Line**: 40

---

### `init_analysis_cache`

**Description**: Initialize analysis cache

**Source Line**: 53

---

### `generate_file_hash`

**Description**: Generate content hash for a file Args: $1 = file_path

**Returns**: Returns: SHA256 hash

**Source Line**: 97

---

### `generate_directory_tree_hash`

**Description**: Generate hash for directory tree structure Args: $1 = directory_path

**Returns**: Returns: SHA256 hash of directory structure

**Source Line**: 111

---

### `generate_multi_file_hash`

**Description**: Generate hash for multiple files Args: $@ = file_paths

**Returns**: Returns: Combined SHA256 hash

**Source Line**: 126

---

### `check_docs_analysis_cache`

**Description**: Check if documentation analysis is cached Args: $1 = file_path

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 143

---

### `save_docs_analysis_cache`

**Description**: Save documentation analysis to cache Args: $1 = file_path, $2 = analysis_result, $3 = status (pass/fail)

**Source Line**: 172

---

### `get_docs_analysis_cache`

**Description**: Retrieve documentation analysis from cache Args: $1 = file_path

**Returns**: Returns: Cached analysis result

**Source Line**: 200

---

### `check_script_validation_cache`

**Description**: Check if script validation is cached Args: $1 = script_path

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 217

---

### `save_script_validation_cache`

**Description**: Save script validation to cache Args: $1 = script_path, $2 = validation_result, $3 = status

**Source Line**: 241

---

### `check_directory_structure_cache`

**Description**: Check if directory structure validation is cached Args: $1 = directory_path

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 271

---

### `save_directory_structure_cache`

**Description**: Save directory structure validation to cache Args: $1 = directory_path, $2 = validation_result, $3 = status

**Source Line**: 295

---

### `check_consistency_cache`

**Description**: Check if consistency analysis is cached Args: $@ = file_paths

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 325

---

### `save_consistency_cache`

**Description**: Save consistency analysis to cache Args: $1 = analysis_result, $2 = status, $@ = file_paths

**Source Line**: 348

---

### `check_quality_cache`

**Description**: Check if code quality analysis is cached Args: $1 = file_path

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 381

---

### `save_quality_cache`

**Description**: Save code quality analysis to cache Args: $1 = file_path, $2 = analysis_result, $3 = status

**Source Line**: 405

---

### `update_cache_index`

**Description**: Update cache index with new entry Args: $1 = cache_type, $2 = cache_key, $3 = hash

**Source Line**: 434

---

### `increment_cache_stat`

**Description**: Increment cache statistic Args: $1 = stat_name (cache_hits or cache_misses)

**Source Line**: 457

---

### `record_cache_miss`

**Description**: Record cache miss

**Source Line**: 474

---

### `cleanup_analysis_cache_old_entries`

**Description**: Cleanup old cache entries

**Source Line**: 479

---

### `get_cache_stats`

**Description**: Get cache statistics

**Source Line**: 517

---

### `display_cache_stats`

**Description**: Display cache statistics

**Source Line**: 533

---

### `clear_analysis_cache`

**Description**: Clear entire cache

**Source Line**: 559

---


## Module: model_selector.sh

**Location**: `src/workflow/lib/model_selector.sh`  
**Category**: AI Model Selection

**Functions**: 16

### `load_model_selection_config`

**Description**: Load configuration from YAML file

**Source Line**: 16

---

### `validate_model_name`

**Description**: Validate model name Usage: validate_model_name <model_name>

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 68

---

### `list_supported_models`

**Description**: Get list of supported models Usage: list_supported_models

**Returns**: Returns: Space-separated list of models

**Source Line**: 84

---

### `suggest_similar_models`

**Description**: Suggest similar models if invalid Usage: suggest_similar_models <invalid_model>

**Returns**: Returns: List of similar model names

**Source Line**: 91

---

### `calculate_cyclomatic_complexity`

**Description**: Calculate cyclomatic complexity for a code file Usage: calculate_cyclomatic_complexity <file_path>

**Returns**: Returns: Complexity score (integer)

**Source Line**: 175

---

### `calculate_function_depth`

**Description**: Calculate maximum function nesting depth for a file Usage: calculate_function_depth <file_path>

**Returns**: Returns: Maximum depth (integer)

**Source Line**: 220

---

### `detect_semantic_factor`

**Description**: Detect semantic complexity factor from git commit messages and diff patterns Usage: detect_semantic_factor <file_list>

**Returns**: Returns: One of: minor_change, enhancement, major_refactor, architectural_change

**Source Line**: 250

---

### `calculate_code_complexity`

**Description**: Calculate complexity for code files Usage: calculate_code_complexity <file_list>

**Returns**: Returns: JSON object with score and factors

**Source Line**: 292

---

### `calculate_docs_complexity`

**Description**: Calculate complexity for documentation files Usage: calculate_docs_complexity <file_list>

**Returns**: Returns: JSON object with score and factors

**Source Line**: 369

---

### `calculate_tests_complexity`

**Description**: Calculate complexity for test files Usage: calculate_tests_complexity <file_list>

**Returns**: Returns: JSON object with score and factors

**Source Line**: 445

---

### `get_model_for_tier`

**Description**: Map complexity tier to model Usage: get_model_for_tier <tier> <step_id>

**Returns**: Returns: Model name

**Source Line**: 522

---

### `get_alternative_models`

**Description**: Get alternative models for a tier Usage: get_alternative_models <tier>

**Returns**: Returns: Space-separated list of alternative models

**Source Line**: 565

---

### `get_model_reason`

**Description**: Get reason for model selection Usage: get_model_reason <tier> <category>

**Returns**: Returns: Human-readable reason

**Source Line**: 590

---

### `generate_model_definitions`

**Description**: Generate model definitions for all workflow steps Usage: generate_model_definitions <code_files> <doc_files> <test_files>

**Returns**: Returns: JSON object with model definitions

**Source Line**: 620

---

### `save_model_definitions`

**Description**: Save model definitions to JSON file Usage: save_model_definitions <json_content>

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 752

---

### `load_model_definitions`

**Description**: Load model definitions from JSON file Usage: load_model_definitions

**Returns**: Returns: JSON content or empty object

**Source Line**: 780

---


## Module: cleanup_handlers.sh

**Location**: `src/workflow/lib/cleanup_handlers.sh`  
**Category**: Cleanup

**Functions**: 15

### `track_cleanup_handlers_temp`

**Description**: Register temp file for cleanup

**Source Line**: 18

---

### `cleanup_cleanup_handlers_files`

**Description**: Cleanup handler for cleanup handlers module

**Source Line**: 24

---

### `init_cleanup`

**Description**: Initialize cleanup system Usage: init_cleanup

**Source Line**: 44

---

### `register_cleanup_handler`

**Description**: Register a cleanup handler Usage: register_cleanup_handler <name> <command>

**Source Line**: 59

---

### `register_temp_file`

**Description**: Register a temporary file for cleanup Usage: register_temp_file <file_path>

**Source Line**: 69

---

### `register_temp_dir`

**Description**: Register a temporary directory for cleanup Usage: register_temp_dir <dir_path>

**Source Line**: 78

---

### `unregister_cleanup_handler`

**Description**: Unregister a cleanup handler Usage: unregister_cleanup_handler <name>

**Source Line**: 87

---

### `unregister_temp_file`

**Description**: Unregister a temporary file Usage: unregister_temp_file <file_path>

**Source Line**: 94

---

### `execute_cleanup`

**Description**: Execute all registered cleanup handlers Usage: execute_cleanup (called automatically on EXIT/INT/TERM)

**Source Line**: 101

---

### `create_temp_file`

**Description**: Create a temporary file and register for cleanup Usage: create_temp_file [prefix] Outputs: Path to temporary file

**Source Line**: 130

---

### `create_temp_dir`

**Description**: Create a temporary directory and register for cleanup Usage: create_temp_dir [prefix] Outputs: Path to temporary directory

**Source Line**: 143

---

### `cleanup_step_execution`

**Description**: Cleanup for workflow step execution Usage: cleanup_step_execution <step_number>

**Source Line**: 159

---

### `cleanup_test_execution`

**Description**: Cleanup for test execution Usage: cleanup_test_execution

**Source Line**: 169

---

### `cleanup_sessions`

**Description**: Cleanup for session management Usage: cleanup_sessions

**Source Line**: 177

---

### `cleanup_old_artifacts`

**Description**: Cleanup old workflow artifacts Usage: cleanup_old_artifacts <days> <dry_run> Arguments: days     - Remove artifacts older than this many days (default: 7) dry_run  - If "true", only report what would be deleted (default: false)

**Source Line**: 194

---


## Module: cleanup_template.sh

**Location**: `src/workflow/lib/cleanup_template.sh`  
**Category**: Cleanup

**Functions**: 8

### `cleanup`

**Description**: ###################################### Cleanup function called on script exit Cleans up all tracked resources in reverse order of creation. Handles errors gracefully to ensure all cleanup attempts are made. Globals: TEMP_FILES - Array of temporary files to remove TEMP_DIRS - Array of temporary directories to remove BACKGROUND_PIDS - Array of background process PIDs to terminate LOCK_FILES - Array of lock files to release Arguments: None

**Returns**: Returns:

**Exit Codes**:
- Exit code from script execution (preserved)
- ######################################

**Source Line**: 59

---

### `track_temp_file`

**Description**: ###################################### Register a temporary file for cleanup Arguments: $1 - Path to temporary file ######################################

**Source Line**: 130

---

### `track_temp_dir`

**Description**: ###################################### Register a temporary directory for cleanup Arguments: $1 - Path to temporary directory ######################################

**Source Line**: 140

---

### `track_background_pid`

**Description**: ###################################### Register a background process PID for cleanup Arguments: $1 - Process ID ######################################

**Source Line**: 150

---

### `track_lock_file`

**Description**: ###################################### Register a lock file for cleanup Arguments: $1 - Path to lock file ######################################

**Source Line**: 160

---

### `create_tracked_temp_file`

**Description**: ###################################### Create tracked temporary file

**Returns**: Returns: Path to temp file via stdout ######################################

**Source Line**: 169

---

### `create_tracked_temp_dir`

**Description**: ###################################### Create tracked temporary directory

**Returns**: Returns: Path to temp directory via stdout ######################################

**Source Line**: 180

---

### `setup_cleanup`

**Description**: ###################################### Initialize cleanup handler Call this once at the beginning of your script to set up the cleanup trap. Handles EXIT, INT (Ctrl+C), and TERM signals. ######################################

**Source Line**: 197

---


## Module: config.sh

**Location**: `src/workflow/lib/config.sh`  
**Category**: Configuration

**Functions**: 0

*No public functions documented*


## Module: config_wizard.sh

**Location**: `src/workflow/lib/config_wizard.sh`  
**Category**: Configuration

**Functions**: 12

### `wizard_header`

**Description**: ###################################### Print wizard header ######################################

**Source Line**: 34

---

### `wizard_step`

**Description**: ###################################### Print wizard step header Arguments: $1 - Step number $2 - Total steps $3 - Step title ######################################

**Source Line**: 57

---

### `confirm_prompt`

**Description**: ###################################### Confirm prompt (yes/no) Arguments: $1 - Prompt message

**Returns**: Returns: 0 for yes, 1 for no ######################################

**Source Line**: 76

---

### `input_prompt`

**Description**: ###################################### Text input prompt Arguments: $1 - Prompt message $2 - Default value (optional) Outputs: User input or default ######################################

**Source Line**: 99

---

### `select_prompt`

**Description**: ###################################### Select from list Arguments: $1 - Prompt message $@ - Options Outputs: Selected option ######################################

**Source Line**: 128

---

### `wizard_welcome`

**Description**: ###################################### Main wizard: Welcome screen ######################################

**Source Line**: 161

---

### `wizard_detect_project`

**Description**: ###################################### Step 1: Auto-detect tech stack ######################################

**Source Line**: 185

---

### `wizard_project_info`

**Description**: ###################################### Step 2: Project information ######################################

**Source Line**: 284

---

### `wizard_project_structure`

**Description**: ###################################### Step 3: Project structure ######################################

**Source Line**: 317

---

### `wizard_commands`

**Description**: ###################################### Step 4: Commands configuration ######################################

**Source Line**: 360

---

### `wizard_preview_and_save`

**Description**: ###################################### Step 5: Preview and save ######################################

**Source Line**: 409

---

### `run_config_wizard`

**Description**: ###################################### Main wizard entry point ######################################

**Source Line**: 526

---


## Module: project_kind_config.sh

**Location**: `src/workflow/lib/project_kind_config.sh`  
**Category**: Configuration

**Functions**: 39

### `detect_yq_version`

**Description**: Detect yq version

**Source Line**: 29

---

### `load_project_kind_config`

**Description**: Load project kind configuration from YAML file Uses yq to parse YAML into shell-friendly format

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 62

---

### `get_project_kind_config`

**Description**: Get a configuration value for a project kind Usage: get_project_kind_config <kind> <path>

**Returns**: Returns: Configuration value or empty string

**Examples**:
```bash
```

**Source Line**: 114

---

### `get_project_kind_name`

**Description**: Get project kind name

**Source Line**: 145

---

### `get_project_kind_description`

**Description**: Get project kind description

**Source Line**: 151

---

### `get_project_kind`

**Description**: Get project kind from .workflow-config.yaml Arguments: $1 - Project directory (optional, defaults to current directory)

**Returns**: Returns: Project kind string or empty string if not found

**Examples**:
```bash
kind=$(get_project_kind)
kind=$(get_project_kind "/path/to/project")
```

**Source Line**: 168

---

### `get_required_files`

**Description**: Get required files for project kind

**Returns**: Returns: Space-separated list of required files

**Source Line**: 236

---

### `_get_array_values`

**Description**: Helper function to get array values

**Source Line**: 242

---

### `get_required_directories`

**Description**: Get required directories for project kind

**Source Line**: 262

---

### `get_optional_files`

**Description**: Get optional files for project kind

**Source Line**: 268

---

### `get_file_patterns`

**Description**: Get file patterns for project kind

**Source Line**: 274

---

### `get_test_framework`

**Description**: Get test framework for project kind

**Source Line**: 284

---

### `get_test_directory`

**Description**: Get test directory for project kind

**Source Line**: 290

---

### `get_test_file_pattern`

**Description**: Get test file pattern for project kind

**Source Line**: 296

---

### `get_test_command`

**Description**: Get test command for project kind

**Source Line**: 302

---

### `is_coverage_required`

**Description**: Check if coverage is required for project kind

**Source Line**: 308

---

### `get_coverage_threshold`

**Description**: Get coverage threshold for project kind

**Source Line**: 316

---

### `get_linters`

**Description**: Get list of linters for project kind

**Returns**: Returns: JSON array of linter configurations

**Source Line**: 327

---

### `get_enabled_linters`

**Description**: Get enabled linters for project kind

**Returns**: Returns: Space-separated list of enabled linter names

**Source Line**: 348

---

### `is_documentation_required`

**Description**: Check if documentation is required

**Source Line**: 382

---

### `is_readme_required`

**Description**: Check if README is required

**Source Line**: 390

---

### `get_package_files`

**Description**: Get package files for project kind

**Source Line**: 402

---

### `get_lock_files`

**Description**: Get lock files for project kind

**Source Line**: 408

---

### `is_dependency_validation_required`

**Description**: Check if dependency validation is required

**Source Line**: 414

---

### `is_security_audit_required`

**Description**: Check if security audit is required

**Source Line**: 422

---

### `get_audit_command`

**Description**: Get security audit command

**Source Line**: 430

---

### `is_build_required`

**Description**: Check if build is required

**Source Line**: 440

---

### `get_build_command`

**Description**: Get build command

**Source Line**: 448

---

### `get_build_output_directory`

**Description**: Get build output directory

**Source Line**: 454

---

### `get_deployment_type`

**Description**: Get deployment type

**Source Line**: 464

---

### `is_deployment_build_required`

**Description**: Check if build is required for deployment

**Source Line**: 470

---

### `get_artifact_patterns`

**Description**: Get artifact patterns for deployment

**Source Line**: 478

---

### `list_project_kinds`

**Description**: List all available project kinds

**Source Line**: 488

---

### `validate_project_kind`

**Description**: Validate project against kind configuration

**Returns**: Returns: 0 if valid, 1 if validation fails

**Source Line**: 508

---

### `print_project_kind_config`

**Description**: Print project kind configuration summary

**Source Line**: 554

---

### `get_language_testing_standards`

**Description**: Get language-specific testing standards for AI prompts Usage: get_language_testing_standards <project_kind>

**Returns**: Returns: Newline-separated list of testing standards

**Source Line**: 632

---

### `get_language_style_guides`

**Description**: Get language-specific style guides for AI prompts Usage: get_language_style_guides <project_kind>

**Returns**: Returns: Newline-separated list of style guides

**Source Line**: 666

---

### `get_language_best_practices`

**Description**: Get language-specific best practices for AI prompts Usage: get_language_best_practices <project_kind>

**Returns**: Returns: Newline-separated list of best practices

**Source Line**: 700

---

### `get_language_directory_standards`

**Description**: Get language-specific directory structure standards for AI prompts Usage: get_language_directory_standards <project_kind>

**Returns**: Returns: Newline-separated list of directory standards

**Source Line**: 739

---


## Module: project_kind_detection.sh

**Location**: `src/workflow/lib/project_kind_detection.sh`  
**Category**: Configuration

**Functions**: 5

### `detect_project_kind`

**Description**: ###################################### Detect the kind/type of project Arguments: $1 - Project directory path (optional, defaults to current directory)

**Returns**: Returns: 0 on success, 1 on error Outputs: JSON object with detection results ######################################

**Source Line**: 97

---

### `get_project_kind_config`

**Description**: ###################################### Get configuration for a specific project kind Arguments: $1 - Project kind name $2 - Config key (optional, returns all if not specified)

**Returns**: Returns: 0 on success, 1 on error Outputs: Configuration value or JSON object ######################################

**Source Line**: 207

---

### `validate_project_kind`

**Description**: ###################################### Validate if project matches expected kind Arguments: $1 - Expected project kind $2 - Project directory (optional, defaults to current) $3 - Minimum confidence threshold (optional, defaults to 50)

**Returns**: Returns: 0 if matches, 1 if doesn't match or error Outputs: Validation message ######################################

**Source Line**: 253

---

### `list_supported_project_kinds`

**Description**: ###################################### List all supported project kinds

**Returns**: Returns: 0 on success Outputs: JSON array of supported project kinds with metadata ######################################

**Source Line**: 295

---

### `get_project_kind_description`

**Description**: ###################################### Get human-readable description of project kind Arguments: $1 - Project kind name

**Returns**: Returns: 0 on success, 1 on error Outputs: Description string ######################################

**Source Line**: 332

---


## Module: change_detection.sh

**Location**: `src/workflow/lib/change_detection.sh`  
**Category**: Core Infrastructure

**Functions**: 18

### `filter_workflow_artifacts`

**Description**: Filter out ephemeral workflow artifacts from file list Usage: filter_workflow_artifacts <file_list>

**Returns**: Returns: Filtered file list (one file per line)

**Source Line**: 42

---

### `is_workflow_artifact`

**Description**: Check if a single file is a workflow artifact Usage: is_workflow_artifact <file_path>

**Returns**: Returns: 0 (true) if artifact, 1 (false) otherwise

**Source Line**: 79

---

### `get_history_file`

**Description**: Get path to workflow history file Usage: get_history_file

**Returns**: Returns: Path to history.jsonl in current project

**Source Line**: 103

---

### `has_workflow_history`

**Description**: Check if workflow history exists Usage: has_workflow_history

**Returns**: Returns: 0 if history exists, 1 otherwise

**Source Line**: 111

---

### `validate_commit_count`

**Description**: Validate requested commit count doesn't exceed available commits Usage: validate_commit_count <requested_count>

**Returns**: Returns: 0 if valid, 1 if exceeds available commits

**Source Line**: 119

---

### `get_last_workflow_commit`

**Description**: Get the last workflow execution commit hash or HEAD~N if --last-commits specified Usage: get_last_workflow_commit

**Returns**: Returns: Commit hash from last successful workflow, or HEAD~N, or empty if none

**Source Line**: 137

---

### `validate_clean_working_tree`

**Description**: Validate that git working tree is clean (no uncommitted changes) Usage: validate_clean_working_tree

**Returns**: Returns: 0 if clean, 1 if dirty

**Source Line**: 196

---

### `save_workflow_history`

**Description**: Save workflow history entry after successful execution Usage: save_workflow_history <workflow_id> [force] Args: workflow_id: Current workflow run identifier force: Optional, skip clean tree validation if set to "force"

**Returns**: Returns: 0 on success, 1 on error

**Source Line**: 210

---

### `detect_change_type`

**Description**: Detect change type from git status Usage: detect_change_type

**Returns**: Returns: Change type category

**Source Line**: 305

---

### `matches_pattern`

**Description**: Check if file matches pattern Usage: matches_pattern <file> <pattern>

**Source Line**: 410

---

### `analyze_changes`

**Description**: Get detailed change analysis Usage: analyze_changes Prints detailed breakdown of changes by category

**Source Line**: 432

---

### `get_recommended_steps`

**Description**: Get recommended steps for detected change type Usage: get_recommended_steps

**Returns**: Returns: Comma-separated list of step numbers

**Source Line**: 527

---

### `should_execute_step`

**Description**: Check if step should be executed based on change type and user skip requests. Updated: v4.1.0 - Added support for SKIP_NEXT_STEP flag.

**Usage**: `should_execute_step <step_identifier>`

**Behavior**:
1. **Skip Flag Check**: If `SKIP_NEXT_STEP=true`, clears flag and skips this step (returns 1)
2. **Step Selection**: Checks if step is in SELECTED_STEPS array
3. **Returns**: 0 (true) if step should run, 1 (false) if skipped

**Related**: Works with `confirm_action()` space bar skip feature

**Source Line**: 1358

---

### `display_execution_plan`

**Description**: Display step execution plan based on change detection

**Source Line**: 550

---

### `get_step_name_for_display`

**Description**: Get human-readable step name for display

**Source Line**: 584

---

### `assess_change_impact`

**Description**: Assess change impact for risk analysis

**Returns**: Returns: low, medium, high

**Source Line**: 611

---

### `generate_change_report`

**Description**: Generate change summary report

**Source Line**: 683

---

### `classify_files_by_nature`

**Description**: Classify changed files into code, documentation, tests, and config Usage: classify_files_by_nature

**Returns**: Returns: Four pipe-separated lists: "code_files|doc_files|test_files|config_files"

**Source Line**: 723

---


## Module: metrics.sh

**Location**: `src/workflow/lib/metrics.sh`  
**Category**: Core Infrastructure

**Functions**: 20

### `init_metrics`

**Description**: Initialize metrics collection Creates necessary directories and files

**Source Line**: 54

---

### `get_execution_mode`

**Description**: Get current execution mode as string

**Source Line**: 95

---

### `start_step_timer`

**Description**: Start timing for a step Usage: start_step_timer <step_number> <step_name>

**Source Line**: 113

---

### `stop_step_timer`

**Description**: Stop timing for a step Usage: stop_step_timer <step_number> <status> [error_message]

**Source Line**: 125

---

### `get_step_name`

**Description**: Get step name from step number

**Source Line**: 175

---

### `start_phase_timer`

**Description**: Start timing for a phase within a step Usage: start_phase_timer <step_num> <phase_name> <description>

**Source Line**: 204

---

### `stop_phase_timer`

**Description**: Stop timing for a phase Usage: stop_phase_timer <step_num> <phase_name>

**Source Line**: 218

---

### `generate_phase_report`

**Description**: Generate phase timing report for a step Usage: generate_phase_report <step_num>

**Source Line**: 235

---

### `update_current_run_step`

**Description**: Update current run JSON with step information Usage: update_current_run_step <step_num> <step_name> <status> <duration> <error_msg>

**Source Line**: 271

---

### `finalize_metrics`

**Description**: Finalize metrics and save to history Usage: finalize_metrics [success|failed]

**Source Line**: 335

---

### `generate_metrics_summary`

**Description**: Generate human-readable metrics summary

**Source Line**: 420

---

### `get_workflow_status_emoji`

**Description**: Get workflow status emoji

**Source Line**: 452

---

### `format_duration`

**Description**: Format duration in human-readable format Usage: format_duration <seconds>

**Source Line**: 462

---

### `generate_step_timing_table`

**Description**: Generate step timing table for markdown

**Source Line**: 478

---

### `get_step_status_emoji`

**Description**: Get step status emoji

**Source Line**: 493

---

### `generate_historical_stats`

**Description**: Generate historical statistics from past runs

**Source Line**: 506

---

### `calculate_average_duration`

**Description**: Calculate average duration from history

**Source Line**: 539

---

### `display_recent_runs`

**Description**: Display recent workflow runs

**Source Line**: 555

---

### `get_success_rate`

**Description**: Get success rate for last N runs Usage: get_success_rate [count]

**Source Line**: 575

---

### `get_average_step_duration`

**Description**: Get average step duration across history Usage: get_average_step_duration <step_number>

**Source Line**: 596

---


## Module: tech_stack.sh

**Location**: `src/workflow/lib/tech_stack.sh`  
**Category**: Core Infrastructure

**Functions**: 36

### `init_tech_stack`

**Description**: ###################################### Initialize tech stack system Loads config file or auto-detects tech stack Globals: TECH_STACK_CONFIG PRIMARY_LANGUAGE TECH_STACK_CONFIG_FILE (optional) Arguments: None

**Returns**: Returns: 0 on success, 1 on failure ######################################

**Source Line**: 61

---

### `load_tech_stack_config`

**Description**: ###################################### Load tech stack configuration from YAML file Globals: TECH_STACK_CONFIG PRIMARY_LANGUAGE Arguments: $1 - Path to config file

**Returns**: Returns: 0 on success, 1 on failure ######################################

**Source Line**: 147

---

### `parse_yaml_config`

**Description**: ###################################### Parse YAML config file This is a simple YAML parser for our config format Globals: None Arguments: $1 - Path to YAML file

**Returns**: Returns: 0 on success, 1 on failure ######################################

**Source Line**: 210

---

### `get_config_value`

**Description**: ###################################### Get configuration value from parsed YAML Globals: TECH_STACK_CONFIG Arguments: $1 - Config key (dot notation, e.g., "tech_stack.primary_language") $2 - Default value (optional)

**Returns**: Returns: Config value or default ######################################

**Source Line**: 238

---

### `detect_tech_stack`

**Description**: ###################################### Auto-detect project tech stack Globals: PRIMARY_LANGUAGE LANGUAGE_CONFIDENCE Arguments: None

**Returns**: Returns: 0 on success, 1 on failure ######################################

**Source Line**: 301

---

### `detect_javascript_project`

**Description**: ###################################### Detect JavaScript/Node.js project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 468

---

### `detect_python_project`

**Description**: ###################################### Detect Python project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 519

---

### `detect_go_project`

**Description**: ###################################### Detect Go project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 584

---

### `detect_java_project`

**Description**: ###################################### Detect Java project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 639

---

### `detect_ruby_project`

**Description**: ###################################### Detect Ruby project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 698

---

### `detect_rust_project`

**Description**: ###################################### Detect Rust project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 764

---

### `detect_cpp_project`

**Description**: ###################################### Detect C/C++ project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 819

---

### `detect_bash_project`

**Description**: ###################################### Detect Bash/Shell project

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 882

---

### `get_confidence_score`

**Description**: ###################################### Get confidence score for a language Arguments: $1 - Language name

**Returns**: Returns: Confidence score (0-100) ######################################

**Source Line**: 951

---

### `load_default_tech_stack`

**Description**: ###################################### Load default tech stack (JavaScript/Node.js) Maintains backward compatibility with v2.4.0 Globals: PRIMARY_LANGUAGE BUILD_SYSTEM

**Returns**: Returns: 0 ######################################

**Source Line**: 965

---

### `export_tech_stack_variables`

**Description**: ###################################### Export tech stack variables to environment Globals: PRIMARY_LANGUAGE BUILD_SYSTEM

**Returns**: Returns: 0 ######################################

**Source Line**: 996

---

### `init_tech_stack_cache`

**Description**: ###################################### Initialize tech stack cache for performance Globals: TECH_STACK_CACHE

**Returns**: Returns: 0 ######################################

**Source Line**: 1014

---

### `get_tech_stack_property`

**Description**: ###################################### Get tech stack property Arguments: $1 - Property name $2 - Default value (optional)

**Returns**: Returns: Property value ######################################

**Source Line**: 1033

---

### `print_tech_stack_summary`

**Description**: ###################################### Print tech stack summary Globals: PRIMARY_LANGUAGE BUILD_SYSTEM

**Returns**: Returns: 0 ######################################

**Source Line**: 1060

---

### `is_language_supported`

**Description**: ###################################### Check if language is supported Arguments: $1 - Language name

**Returns**: Returns: 0 if supported, 1 if not ######################################

**Source Line**: 1093

---

### `get_supported_languages`

**Description**: ###################################### Get list of supported languages

**Returns**: Returns: Space-separated list of languages ######################################

**Source Line**: 1112

---

### `get_source_extensions`

**Description**: ###################################### Get source file extensions for current language

**Returns**: Returns: Space-separated list of extensions (e.g., ".js .jsx .ts") ######################################

**Source Line**: 1122

---

### `get_test_patterns`

**Description**: ###################################### Get test file patterns for current language

**Returns**: Returns: Space-separated list of patterns ######################################

**Source Line**: 1161

---

### `get_exclude_patterns`

**Description**: ###################################### Get exclude directory patterns for current language

**Returns**: Returns: Space-separated list of directories to exclude ######################################

**Source Line**: 1200

---

### `find_source_files`

**Description**: ###################################### Find source files for current language Globals: PRIMARY_LANGUAGE

**Returns**: Returns: List of source files (one per line) ######################################

**Source Line**: 1241

---

### `find_test_files`

**Description**: ###################################### Find test files for current language Globals: PRIMARY_LANGUAGE

**Returns**: Returns: List of test files (one per line) ######################################

**Source Line**: 1277

---

### `get_language_command`

**Description**: ###################################### Get language-specific command Arguments: $1 - Command type (install, test, lint, build, clean)

**Returns**: Returns: Command string ######################################

**Source Line**: 1313

---

### `get_install_command`

**Description**: ###################################### Execute a language-specific command with error handling Arguments: $1 - Command to execute

**Returns**: Returns: 0 on success, 1 on failure ###################################### Get install command for current language Globals: PRIMARY_LANGUAGE Returns: Install command string ######################################

**Source Line**: 1476

---

### `get_test_command`

**Description**: ###################################### Get test command for current language Globals: PRIMARY_LANGUAGE TEST_COMMAND (if set manually)

**Returns**: Returns: Test command string ######################################

**Source Line**: 1488

---

### `get_test_verbose_command`

**Description**: ###################################### Get test command with verbose output Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Verbose test command string ######################################

**Source Line**: 1505

---

### `get_test_coverage_command`

**Description**: ###################################### Get test coverage command Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Test coverage command string ######################################

**Source Line**: 1516

---

### `get_lint_command`

**Description**: ###################################### Get lint command for current language Globals: PRIMARY_LANGUAGE LINT_COMMAND (if set manually)

**Returns**: Returns: Lint command string ######################################

**Source Line**: 1528

---

### `get_format_command`

**Description**: ###################################### Get format command for current language Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Format command string ######################################

**Source Line**: 1545

---

### `get_build_command`

**Description**: ###################################### Get build command for current language Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Build command string ######################################

**Source Line**: 1556

---

### `get_clean_command`

**Description**: ###################################### Get clean command for current language Globals: PRIMARY_LANGUAGE

**Returns**: Returns: Clean command string ######################################

**Source Line**: 1567

---

### `execute_language_command`

**Description**: ###################################### Execute a language-specific command Arguments: $1 - Command to execute $2 - Optional description for logging

**Returns**: Returns: 0 on success, 1 on failure ######################################

**Source Line**: 1579

---


## Module: workflow_optimization.sh

**Location**: `src/workflow/lib/workflow_optimization.sh`  
**Category**: Core Infrastructure

**Functions**: 8

### `should_skip_step_by_impact`

**Description**: Determine if a step should be skipped based on change impact analysis Args: $1 = step_number, $2 = change_impact (Low/Medium/High)

**Returns**: Returns: 0 if should skip, 1 if should execute

**Source Line**: 34

---

### `analyze_change_impact`

**Description**: Analyze change impact to determine workflow optimization strategy

**Returns**: Returns: Sets CHANGE_IMPACT global variable (Low/Medium/High)

**Source Line**: 90

---

### `execute_parallel_tracks`

**Description**: Execute workflow in 3 parallel tracks for optimal performance Track 1: Analysis (0 → 3,4,13 → 10 → 11) Track 2: Validation (5 → 6 → 7 → 9 + 8) Track 3: Documentation (1 → 2 → 12)

**Returns**: Returns: 0 if all succeed, 1 if any fail

**Source Line**: 231

---

### `generate_parallel_tracks_report`

**Description**: Generate report for 3-track parallel execution

**Source Line**: 463

---

### `execute_parallel_validation`

**Description**: Execute validation steps (1-4) in parallel for faster execution

**Returns**: Returns: 0 if all succeed, 1 if any fail

**Notes**:
- NOTE: This is the legacy function, prefer execute_parallel_tracks() for full workflow

**Source Line**: 571

---

### `save_checkpoint`

**Description**: Save workflow checkpoint for resume capability Args: $1 = last_completed_step_number

**Notes**:
- Note: All variables are properly quoted to prevent Bash interpretation errors (v2.3.1)

**Source Line**: 811

---

### `load_checkpoint`

**Description**: Load checkpoint and validate it's safe to resume

**Returns**: Returns: 0 if valid checkpoint found, 1 otherwise Sets: RESUME_FROM_STEP global variable

**Source Line**: 858

---

### `cleanup_old_checkpoints`

**Description**: Cleanup old checkpoints (older than 7 days)

**Source Line**: 992

---


## Module: auto_documentation.sh

**Location**: `src/workflow/lib/auto_documentation.sh`  
**Category**: Documentation

**Functions**: 9

### `track_auto_doc_temp`

**Description**: Register temp file for cleanup

**Source Line**: 36

---

### `cleanup_auto_documentation_files`

**Description**: Cleanup handler for auto documentation

**Source Line**: 42

---

### `init_auto_documentation`

**Description**: Initialize auto-documentation system

**Source Line**: 55

---

### `generate_workflow_report`

**Description**: Generate workflow execution report Args: $1 = workflow_run_id, $2 = status (success/failure)

**Source Line**: 70

---

### `generate_changelog`

**Description**: Generate CHANGELOG.md from git commits Args: $1 = since_tag (optional, default: last tag)

**Source Line**: 212

---

### `generate_api_docs`

**Description**: Generate API documentation from function comments Args: $1 = source_file or directory

**Source Line**: 391

---

### `generate_file_api_docs`

**Description**: Generate API docs for a single file Args: $1 = source_file, $2 = output_dir

**Source Line**: 415

---

### `validate_documentation`

**Description**: Validate documentation completeness

**Source Line**: 494

---

### `on_workflow_complete_docs`

**Description**: Hook: Generate documentation after workflow completion

**Source Line**: 541

---


## Module: changelog_generator.sh

**Location**: `src/workflow/lib/changelog_generator.sh`  
**Category**: Documentation

**Functions**: 8

### `parse_conventional_commit`

**Description**: Parse a conventional commit message Args: $1 = commit message Output: Format "type|scope|description|breaking|body"

**Source Line**: 48

---

### `parse_commits_since`

**Description**: Parse all commits since a reference Args: $1 = since reference (tag, commit, or empty for all), $2 = until reference (default: HEAD) Output: Parsed commit data, one per line

**Source Line**: 95

---

### `generate_changelog_section`

**Description**: Generate changelog section for a version Args: $1 = version, $2 = date, $3 = since reference Output: Changelog markdown section

**Source Line**: 133

---

### `generate_enhanced_changelog`

**Description**: Generate complete changelog Args: $1 = since tag (optional), $2 = version (optional), $3 = output file (optional)

**Source Line**: 219

---

### `validate_changelog`

**Description**: Validate changelog format Args: $1 = changelog file path

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 283

---

### `generate_release_notes`

**Description**: Generate release notes from changelog Args: $1 = version, $2 = output file (optional)

**Source Line**: 346

---

### `update_changelog_for_release`

**Description**: Update changelog before version bump Args: $1 = new version

**Source Line**: 380

---

### `suggest_next_version`

**Description**: Suggest next version based on commits

**Returns**: Returns: suggested version (major.minor.patch)

**Source Line**: 397

---


## Module: doc_section_extractor.sh

**Location**: `src/workflow/lib/doc_section_extractor.sh`  
**Category**: Documentation

**Functions**: 8

### `track_doc_extractor_temp`

**Description**: Register temp file for cleanup

**Source Line**: 19

---

### `cleanup_doc_extractor_files`

**Description**: Cleanup handler for doc section extractor

**Source Line**: 25

---

### `extract_doc_section`

**Description**: Extract specific section from markdown file Args: $1 - doc file path, $2 - section ID (e.g., "#configuration" or "configuration")

**Returns**: Returns: Section content (without heading) Usage: content=$(extract_doc_section "docs/api/README.md" "#getting-started")

**Source Line**: 41

---

### `extract_doc_section_with_heading`

**Description**: Extract section with heading Args: $1 - doc file, $2 - section ID

**Returns**: Returns: Section content including heading

**Source Line**: 89

---

### `replace_doc_section`

**Description**: Replace specific section in markdown file Args: $1 - doc file, $2 - section ID, $3 - new content

**Returns**: Returns: 0 on success, 1 on failure Usage: replace_doc_section "docs/api/README.md" "#configuration" "$new_content"

**Source Line**: 135

---

### `section_exists`

**Description**: Check if section exists in document Args: $1 - doc file, $2 - section ID

**Returns**: Returns: 0 if exists, 1 if not

**Source Line**: 208

---

### `validate_doc_structure`

**Description**: Validate markdown structure after modification Args: $1 - doc file

**Returns**: Returns: 0 if valid, 1 if corrupt

**Source Line**: 231

---

### `get_section_level`

**Description**: Get section heading level Args: $1 - doc file, $2 - section ID

**Returns**: Returns: Heading level (2-6) or 0 if not found

**Source Line**: 260

---


## Module: doc_section_mapper.sh

**Location**: `src/workflow/lib/doc_section_mapper.sh`  
**Category**: Documentation

**Functions**: 6

### `map_file_to_doc_sections`

**Description**: Map changed file to affected documentation sections Args: $1 - changed file path, $2 - project kind

**Returns**: Returns: List of "doc_file:section_id" (one per line) Usage: sections=$(map_file_to_doc_sections "src/workflow/lib/metrics.sh" "nodejs_api")

**Source Line**: 19

---

### `map_files_to_sections`

**Description**: Map multiple files to documentation sections Args: $1 - newline-separated list of files, $2 - project kind

**Returns**: Returns: Deduplicated list of "doc_file:section_id"

**Source Line**: 145

---

### `get_doc_sections`

**Description**: Get all documentation sections in a file Args: $1 - documentation file path

**Returns**: Returns: List of section IDs (without #)

**Source Line**: 173

---

### `count_total_doc_sections`

**Description**: Count total documentation sections across all docs

**Returns**: Returns: Total number of sections

**Source Line**: 189

---

### `should_use_incremental_docs`

**Description**: Check if incremental documentation should be used Args: $1 - project kind

**Returns**: Returns: 0 if should use incremental, 1 otherwise

**Source Line**: 209

---

### `calculate_section_savings`

**Description**: Calculate percentage savings Args: $1 - total sections, $2 - affected sections

**Returns**: Returns: Percentage saved

**Source Line**: 228

---


## Module: doc_template_validator.sh

**Location**: `src/workflow/lib/doc_template_validator.sh`  
**Category**: Documentation

**Functions**: 6

### `validate_doc_structure`

**Description**: Validate documentation structure Usage: validate_doc_structure <filepath> <template_name>

**Returns**: Returns: 0 if valid, 1 if issues found

**Source Line**: 52

---

### `extract_version_refs`

**Description**: Extract all version references from a file Usage: extract_version_refs <filepath>

**Returns**: Returns: list of version strings found

**Source Line**: 98

---

### `check_version_consistency`

**Description**: Check version consistency across documentation Usage: check_version_consistency [expected_version]

**Returns**: Returns: 0 if consistent, 1 if inconsistencies found

**Source Line**: 119

---

### `update_all_versions`

**Description**: Update all version references in documentation Usage: update_all_versions <new_version> [dry_run]

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 193

---

### `check_doc_formatting`

**Description**: Check for common formatting issues Usage: check_doc_formatting <filepath>

**Returns**: Returns: 0 if no issues, 1 if issues found

**Source Line**: 275

---

### `audit_documentation`

**Description**: Run all documentation checks Usage: audit_documentation [fix]

**Returns**: Returns: 0 if all checks pass, 1 if issues found

**Source Line**: 340

---


## Module: link_validator.sh

**Location**: `src/workflow/lib/link_validator.sh`  
**Category**: Documentation

**Functions**: 9

### `init_link_validator`

**Description**: Initialize link validation system

**Source Line**: 31

---

### `cleanup_link_cache`

**Description**: Clean up expired cache entries

**Source Line**: 38

---

### `extract_markdown_links`

**Description**: Extract all markdown links from a file Args: $1 = file path Output: Format "line_number|link_type|link_target|link_text"

**Source Line**: 66

---

### `extract_link_references`

**Description**: Extract reference definitions from markdown file Args: $1 = file path Output: Format "ref_id|link_target"

**Source Line**: 112

---

### `validate_local_link`

**Description**: Validate a local file path reference Args: $1 = file path, $2 = base directory for relative paths

**Returns**: Returns: 0 if valid, 1 if broken

**Source Line**: 136

---

### `validate_url`

**Description**: Validate a URL (with caching) Args: $1 = URL

**Returns**: Returns: 0 if valid/cached, 1 if broken

**Source Line**: 182

---

### `validate_file_links`

**Description**: Validate all links in a markdown file Args: $1 = file path, $2 = output report file

**Returns**: Returns: Count of broken links

**Source Line**: 229

---

### `validate_all_documentation_links`

**Description**: Validate links in all documentation files Args: $1 = output report file, $2 = directory to scan (default: current)

**Returns**: Returns: Total count of broken links

**Source Line**: 303

---

### `generate_link_validation_summary`

**Description**: Generate link validation summary report Args: $1 = report file, $2 = output summary file

**Source Line**: 338

---


## Module: edit_operations.sh

**Location**: `src/workflow/lib/edit_operations.sh`  
**Category**: File Operations

**Functions**: 8

### `levenshtein_distance`

**Description**: Calculate Levenshtein distance between two strings Usage: levenshtein_distance <string1> <string2>

**Returns**: Returns: distance value via stdout

**Source Line**: 23

---

### `string_similarity`

**Description**: Calculate similarity percentage between two strings Usage: string_similarity <string1> <string2>

**Returns**: Returns: percentage (0-100) via stdout

**Source Line**: 66

---

### `find_fuzzy_match`

**Description**: Find best fuzzy match in file Usage: find_fuzzy_match <filepath> <search_string> [min_similarity]

**Returns**: Returns: 0 on success with match info, 1 if no match found

**Source Line**: 88

---

### `validate_edit_string`

**Description**: Validate that search string exists in file before attempting edit Usage: validate_edit_string <filepath> <search_string>

**Returns**: Returns: 0 if found, 1 if not found, 2 if found multiple times

**Source Line**: 145

---

### `show_match_context`

**Description**: Show context around match in file Usage: show_match_context <filepath> <search_string> [context_lines]

**Source Line**: 180

---

### `preview_edit_diff`

**Description**: Generate diff preview before applying edit Usage: preview_edit_diff <filepath> <old_string> <new_string>

**Returns**: Returns: diff output via stdout

**Source Line**: 209

---

### `safe_edit_file`

**Description**: Perform safe edit operation with validation and retry Usage: safe_edit_file <filepath> <old_string> <new_string> [preview] [max_retries]

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 258

---

### `batch_edit_file`

**Description**: Apply multiple edits to a file atomically Usage: batch_edit_file <filepath> <edits_file> edits_file format: one edit per line: "OLD_STRING|||NEW_STRING"

**Source Line**: 362

---


## Module: file_operations.sh

**Location**: `src/workflow/lib/file_operations.sh`  
**Category**: File Operations

**Functions**: 12

### `check_file_exists`

**Description**: Check if file exists and handle according to strategy Usage: check_file_exists <filepath> <strategy> Strategies: fail, overwrite, append_timestamp, increment, prompt

**Returns**: Returns: 0 if OK to proceed, 1 if should abort

**Source Line**: 18

---

### `get_safe_filename`

**Description**: Generate safe filename when file exists Usage: get_safe_filename <filepath> <strategy>

**Returns**: Returns: safe filename via stdout

**Source Line**: 88

---

### `safe_create_file`

**Description**: Create file safely with pre-flight check Usage: safe_create_file <filepath> <content> [strategy] [backup]

**Returns**: Returns: 0 on success, 1 on failure Outputs: actual filepath used (may differ if renamed)

**Source Line**: 145

---

### `safe_create_markdown`

**Description**: Create markdown file with header and content Usage: safe_create_markdown <filepath> <title> <content> [strategy]

**Source Line**: 206

---

### `ensure_directory`

**Description**: Ensure directory exists, create if needed Usage: ensure_directory <dirpath> [permissions]

**Source Line**: 235

---

### `retry_operation`

**Description**: Retry operation with exponential backoff Usage: retry_operation <max_attempts> <command> [args...]

**Source Line**: 264

---

### `atomic_update_file`

**Description**: Atomic file update (write to temp, then move) Usage: atomic_update_file <filepath> <content> [strategy]

**Source Line**: 298

---

### `acquire_file_lock`

**Description**: Acquire file lock Usage: acquire_file_lock <lockfile> [timeout_seconds]

**Source Line**: 347

---

### `release_file_lock`

**Description**: Release file lock Usage: release_file_lock <lockfile>

**Source Line**: 379

---

### `resilient_save_step_issues`

**Description**: Save step issues with resilience (replaces save_step_issues from utils.sh) Usage: resilient_save_step_issues <step_num> <step_name> <issues_content> [strategy]

**Source Line**: 396

---

### `resilient_save_step_summary`

**Description**: Save step summary with resilience Usage: resilient_save_step_summary <step_num> <step_name> <summary_content> <status> [strategy]

**Source Line**: 445

---

### `safe_rm_rf`

**Description**: ###################################### Safely remove directory with validation and safeguards Implements multiple safety layers to prevent accidental data loss: - Path existence validation - Path pattern matching (allowlist) - Forbidden path checking (denylist) - Confirmation for non-temporary paths - Dry-run support Globals: DRY_RUN (read): If true, only simulates deletion Arguments: $1 - Directory path to remove (required) $2 - Confirmation mode: auto|prompt|force (optional, default: auto) Outputs: Status messages to stdout/stderr

**Returns**: Returns: 0 - Successfully removed or validated 1 - Validation failed or user aborted 2 - Path does not exist (not an error)

**Examples**:
```bash
safe_rm_rf "/path/to/.ai_cache" "auto"
safe_rm_rf "$TEMP_DIR" "force"
######################################
```

**Source Line**: 518

---


## Module: auto_commit.sh

**Location**: `src/workflow/lib/auto_commit.sh`  
**Category**: Git Operations

**Functions**: 12

### `tests_passed`

**Description**: Check if tests passed based on workflow status

**Returns**: Returns: 0 if tests passed, 1 if failed or not run

**Source Line**: 18

---

### `docs_modified`

**Description**: Check if documentation files were modified

**Returns**: Returns: 0 if docs modified, 1 otherwise

**Source Line**: 27

---

### `stage_docs_only`

**Description**: Stage only documentation files Usage: stage_docs_only

**Returns**: Returns: Number of files staged

**Source Line**: 43

---

### `conditional_stage_docs`

**Description**: Conditionally stage documentation files after tests pass Implements: auto_stage_docs condition from YAML spec Usage: conditional_stage_docs

**Returns**: Returns: 0 on success, 1 on skip

**Source Line**: 67

---

### `has_changes_to_commit`

**Description**: Check if there are changes to commit

**Source Line**: 124

---

### `get_modified_files`

**Description**: Get list of modified files

**Source Line**: 129

---

### `is_workflow_artifact`

**Description**: Check if file matches artifact patterns

**Source Line**: 134

---

### `generate_commit_message`

**Description**: Generate commit message based on changes

**Source Line**: 161

---

### `detect_change_type`

**Description**: Detect change type from modified files

**Source Line**: 215

---

### `stage_workflow_artifacts`

**Description**: Stage workflow artifacts

**Source Line**: 244

---

### `execute_auto_commit`

**Description**: Execute auto-commit

**Source Line**: 266

---

### `show_auto_commit_status`

**Description**: Show auto-commit status

**Source Line**: 317

---


## Module: batch_ai_commit.sh

**Location**: `src/workflow/lib/batch_ai_commit.sh`  
**Category**: Git Operations

**Functions**: 12

### `track_batch_commit_temp`

**Description**: Register temp file for cleanup

**Source Line**: 36

---

### `cleanup_batch_commit`

**Description**: Cleanup handler for batch commit

**Source Line**: 42

---

### `assemble_git_context_for_ai`

**Description**: Assemble comprehensive git context for AI commit message generation

**Returns**: Returns: Context string suitable for AI prompt Usage: context=$(assemble_git_context_for_ai)

**Source Line**: 57

---

### `build_batch_commit_prompt`

**Description**: Build AI prompt for commit message generation Args: $1 - git context

**Returns**: Returns: Formatted prompt for Copilot CLI

**Source Line**: 176

---

### `generate_ai_commit_message_batch`

**Description**: Generate commit message using AI in non-interactive mode

**Returns**: Returns: 0 on success with message in stdout, 1 on failure Usage: ai_message=$(generate_ai_commit_message_batch)

**Source Line**: 219

---

### `parse_ai_commit_response`

**Description**: Parse AI response to extract clean commit message Args: $1 - raw AI response

**Returns**: Returns: Cleaned commit message

**Source Line**: 303

---

### `generate_enhanced_fallback_message`

**Description**: Generate enhanced fallback commit message with context

**Returns**: Returns: Enhanced conventional commit message

**Source Line**: 349

---

### `generate_batch_ai_commit_message`

**Description**: Main function to generate commit message in batch mode Tries AI generation first, falls back to enhanced message if needed

**Returns**: Returns: 0 on success with message in stdout, 1 on failure

**Source Line**: 420

---

### `assemble_submodule_context_for_ai`

**Description**: Assemble git context for submodule commit message generation Args: $1 - submodule path

**Returns**: Returns: Context string suitable for AI prompt Usage: context=$(assemble_submodule_context_for_ai ".workflow_core")

**Source Line**: 474

---

### `build_submodule_commit_prompt`

**Description**: Build AI prompt for submodule commit message generation Args: $1 - submodule git context $2 - submodule path

**Returns**: Returns: Formatted prompt for Copilot CLI

**Source Line**: 548

---

### `generate_submodule_commit_message`

**Description**: Generate commit message for submodule using AI Args: $1 - submodule path

**Returns**: Returns: 0 on success with message in stdout, 1 on failure Usage: message=$(generate_submodule_commit_message ".workflow_core")

**Source Line**: 594

---

### `generate_submodule_fallback_message`

**Description**: Generate fallback commit message for submodule Args: $1 - submodule path

**Returns**: Returns: Conventional commit message

**Source Line**: 676

---


## Module: git_automation.sh

**Location**: `src/workflow/lib/git_automation.sh`  
**Category**: Git Operations

**Functions**: 11

### `detect_workflow_artifacts`

**Description**: Detect workflow artifacts that should be staged

**Returns**: Returns: List of files to stage (newline-separated)

**Source Line**: 66

---

### `categorize_artifacts`

**Description**: Categorize artifacts by type Args: $@ = file paths

**Returns**: Returns: JSON with categorized files

**Source Line**: 99

---

### `stage_workflow_artifacts`

**Description**: Stage workflow artifacts based on success/failure Args: $1 = workflow_status (success/failure)

**Source Line**: 150

---

### `generate_artifact_commit_message`

**Description**: Generate context-aware commit message for workflow artifacts

**Returns**: Returns: Commit message

**Source Line**: 234

---

### `execute_post_workflow_actions`

**Description**: Execute post-workflow automation Args: $1 = workflow_status (success/failure)

**Source Line**: 305

---

### `show_git_automation_config`

**Description**: Show current Git automation configuration

**Source Line**: 355

---

### `enable_git_automation`

**Description**: Enable Git automation

**Source Line**: 377

---

### `disable_git_automation`

**Description**: Disable Git automation

**Source Line**: 384

---

### `on_workflow_start`

**Description**: Hook for workflow start

**Source Line**: 395

---

### `on_workflow_complete`

**Description**: Hook for workflow completion

**Source Line**: 406

---

### `on_workflow_failure`

**Description**: Hook for workflow failure

**Source Line**: 412

---


## Module: git_cache.sh

**Location**: `src/workflow/lib/git_cache.sh`  
**Category**: Git Operations

**Functions**: 24

### `init_git_cache`

**Description**: Initialize git state cache - called once at workflow start Captures all git information in a single batch of queries

**Source Line**: 33

---

### `refresh_git_cache`

**Description**: Refresh git state cache - call when git state changes (e.g., before Step 11) Updates all cached values with current git state

**Source Line**: 103

---

### `get_git_modified_count`

**Description**: File count accessors

**Source Line**: 170

---

### `get_git_staged_count`

*No documentation available*

**Source Line**: 171

---

### `get_git_untracked_count`

*No documentation available*

**Source Line**: 172

---

### `get_git_deleted_count`

*No documentation available*

**Source Line**: 173

---

### `get_git_total_changes`

*No documentation available*

**Source Line**: 174

---

### `get_git_current_branch`

**Description**: Branch and tracking accessors

**Source Line**: 177

---

### `get_git_commits_ahead`

*No documentation available*

**Source Line**: 178

---

### `get_git_commits_behind`

*No documentation available*

**Source Line**: 179

---

### `get_git_status_output`

**Description**: Raw output accessors

**Source Line**: 182

---

### `get_git_status_short_output`

*No documentation available*

**Source Line**: 183

---

### `get_git_diff_stat_output`

*No documentation available*

**Source Line**: 184

---

### `get_git_diff_summary_output`

*No documentation available*

**Source Line**: 185

---

### `get_git_diff_files_output`

*No documentation available*

**Source Line**: 186

---

### `get_git_docs_modified`

**Description**: File type accessors

**Source Line**: 189

---

### `get_git_tests_modified`

*No documentation available*

**Source Line**: 190

---

### `get_git_scripts_modified`

*No documentation available*

**Source Line**: 191

---

### `get_git_code_modified`

*No documentation available*

**Source Line**: 192

---

### `is_deps_modified`

**Description**: Boolean accessors

**Source Line**: 195

---

### `is_git_repo`

*No documentation available*

**Source Line**: 196

---

### `get_cached_git_branch`

**Description**: Convenience aliases for backward compatibility

**Source Line**: 199

---

### `get_cached_git_status`

*No documentation available*

**Source Line**: 200

---

### `get_cached_git_diff`

*No documentation available*

**Source Line**: 201

---


## Module: git_submodule_helpers.sh

**Location**: `src/workflow/lib/git_submodule_helpers.sh`  
**Category**: Git Operations

**Functions**: 20

### `detect_submodules`

**Description**: Detect all configured submodules from .gitmodules

**Returns**: Returns: List of submodule paths (one per line), or empty if none Usage: submodules=$(detect_submodules)

**Source Line**: 28

---

### `has_submodules`

**Description**: Check if project has any submodules configured

**Returns**: Returns: 0 if submodules exist, 1 if none Usage: if has_submodules; then ...

**Source Line**: 44

---

### `get_submodule_count`

**Description**: Get count of configured submodules

**Returns**: Returns: Number of submodules Usage: count=$(get_submodule_count)

**Source Line**: 53

---

### `is_submodule_initialized`

**Description**: Check if submodule is initialized Args: $1 - submodule path

**Returns**: Returns: 0 if initialized, 1 if not Usage: if is_submodule_initialized ".workflow_core"; then ...

**Source Line**: 71

---

### `get_submodule_status`

**Description**: Get submodule status (clean, modified, untracked, etc.) Args: $1 - submodule path

**Returns**: Returns: Status string (clean, dirty, uninitialized, detached) Usage: status=$(get_submodule_status ".workflow_core")

**Source Line**: 89

---

### `has_submodule_changes`

**Description**: Check if submodule has uncommitted changes Args: $1 - submodule path

**Returns**: Returns: 0 if changes exist, 1 if clean Usage: if has_submodule_changes ".workflow_core"; then ...

**Source Line**: 120

---

### `has_submodule_pointer_change`

**Description**: Check if submodule pointer has changed in parent repo Args: $1 - submodule path

**Returns**: Returns: 0 if pointer changed, 1 if not Usage: if has_submodule_pointer_change ".workflow_core"; then ...

**Source Line**: 137

---

### `get_submodule_branch`

**Description**: Get submodule current branch Args: $1 - submodule path

**Returns**: Returns: Branch name or "detached" Usage: branch=$(get_submodule_branch ".workflow_core")

**Source Line**: 151

---

### `get_submodule_url`

**Description**: Get submodule remote URL Args: $1 - submodule path

**Returns**: Returns: Remote URL Usage: url=$(get_submodule_url ".workflow_core")

**Source Line**: 169

---

### `init_submodule`

**Description**: Initialize submodule if not already initialized Args: $1 - submodule path

**Returns**: Returns: 0 on success, 1 on failure Usage: init_submodule ".workflow_core"

**Source Line**: 185

---

### `update_submodule`

**Description**: Update submodule to latest remote commit Args: $1 - submodule path

**Returns**: Returns: 0 on success, 1 on failure Usage: update_submodule ".workflow_core"

**Source Line**: 214

---

### `update_all_submodules`

**Description**: Update all submodules in the repository

**Returns**: Returns: 0 if all succeed, 1 if any fail Usage: update_all_submodules

**Source Line**: 248

---

### `get_submodule_diff`

**Description**: Get detailed diff of submodule changes for AI context Args: $1 - submodule path

**Returns**: Returns: Formatted diff string Usage: diff=$(get_submodule_diff ".workflow_core")

**Source Line**: 274

---

### `get_submodule_change_summary`

**Description**: Get summary of submodule changes (files changed, insertions, deletions) Args: $1 - submodule path

**Returns**: Returns: Summary string Usage: summary=$(get_submodule_change_summary ".workflow_core")

**Source Line**: 307

---

### `get_submodule_modified_files`

**Description**: Get list of modified files in submodule Args: $1 - submodule path

**Returns**: Returns: List of files (one per line) Usage: files=$(get_submodule_modified_files ".workflow_core")

**Source Line**: 325

---

### `stage_submodule_changes`

**Description**: Stage all changes in submodule Args: $1 - submodule path

**Returns**: Returns: 0 on success, 1 on failure Usage: stage_submodule_changes ".workflow_core"

**Source Line**: 346

---

### `commit_submodule_changes`

**Description**: Commit changes in submodule Args: $1 - submodule path $2 - commit message

**Returns**: Returns: 0 on success, 1 on failure Usage: commit_submodule_changes ".workflow_core" "feat: update config"

**Source Line**: 376

---

### `push_submodule`

**Description**: Push submodule changes to remote Args: $1 - submodule path

**Returns**: Returns: 0 on success, 1 on failure Usage: push_submodule ".workflow_core"

**Source Line**: 412

---

### `validate_submodule_state`

**Description**: Validate submodule state before operations Args: $1 - submodule path

**Returns**: Returns: 0 if valid, 1 if invalid with error message Usage: validate_submodule_state ".workflow_core"

**Source Line**: 449

---

### `print_submodule_status`

**Description**: Print formatted submodule status Args: $1 - submodule path Usage: print_submodule_status ".workflow_core"

**Source Line**: 487

---


## Module: precommit_hooks.sh

**Location**: `src/workflow/lib/precommit_hooks.sh`  
**Category**: Hooks

**Functions**: 10

### `generate_precommit_template`

**Description**: Generate pre-commit hook template Args: $1 = project_kind (optional)

**Source Line**: 31

---

### `install_precommit_hook`

**Description**: Install pre-commit hook Args: $1 = project_kind (optional)

**Source Line**: 259

---

### `uninstall_precommit_hook`

**Description**: Uninstall pre-commit hook

**Source Line**: 305

---

### `test_precommit_hook`

**Description**: Test pre-commit hook without committing

**Source Line**: 328

---

### `validate_shell_syntax`

**Description**: Fast syntax check for shell scripts

**Returns**: Returns: 0 if all valid, 1 if errors found

**Source Line**: 354

---

### `validate_js_syntax`

**Description**: Fast syntax check for JavaScript/TypeScript

**Source Line**: 368

---

### `validate_python_syntax`

**Description**: Fast syntax check for Python

**Source Line**: 386

---

### `check_merge_conflicts`

**Description**: Check for merge conflict markers

**Source Line**: 404

---

### `auto_stage_generated_files`

**Description**: Auto-stage generated files

**Source Line**: 425

---

### `create_hook_config`

**Description**: Create hook configuration file

**Source Line**: 460

---


## Module: code_changes_optimization.sh

**Location**: `src/workflow/lib/code_changes_optimization.sh`  
**Category**: Optimization

**Functions**: 8

### `detect_code_changes_with_details`

**Description**: Enhanced code change detection with file categorization

**Returns**: Returns: JSON object with change details

**Source Line**: 31

---

### `is_code_changes`

**Description**: Quick code changes check (boolean only)

**Returns**: Returns: 0 if code changes detected, 1 otherwise

**Source Line**: 82

---

### `get_related_test_files`

**Description**: Get test files related to changed code files

**Returns**: Returns: Newline-separated list of test file paths

**Source Line**: 93

---

### `execute_incremental_tests`

**Description**: Execute incremental tests (only for changed modules)

**Returns**: Returns: 0 if tests pass, 1 if tests fail

**Source Line**: 129

---

### `generate_test_shards`

**Description**: Split tests into shards for parallel execution Args: $1 = number of shards

**Returns**: Returns: Generates shard files

**Source Line**: 200

---

### `execute_parallel_test_shards`

**Description**: Execute tests in parallel shards Args: $1 = number of shards

**Returns**: Returns: 0 if all shards pass, 1 if any fail

**Source Line**: 244

---

### `execute_incremental_code_quality`

**Description**: Run code quality checks only on changed files

**Returns**: Returns: 0 if checks pass, 1 if checks fail

**Source Line**: 337

---

### `enable_code_changes_optimization`

**Description**: Enable code changes optimization based on detection

**Returns**: Returns: 0 if enabled, 1 otherwise

**Source Line**: 407

---


## Module: conditional_execution.sh

**Location**: `src/workflow/lib/conditional_execution.sh`  
**Category**: Optimization

**Functions**: 15

### `get_modified_files`

**Description**: Get modified files from Git

**Returns**: Returns: List of modified files (newline-separated)

**Source Line**: 29

---

### `get_new_dirs_count`

**Description**: Get new directories

**Returns**: Returns: Count of new directories

**Source Line**: 35

---

### `get_deleted_dirs_count`

**Description**: Get deleted directories

**Returns**: Returns: Count of deleted directories

**Source Line**: 46

---

### `modified_files_contain`

**Description**: Check if modified files contain pattern Args: $1 = pattern (e.g., "docs/", "*.sh", "README.md")

**Returns**: Returns: 0 if pattern found, 1 otherwise

**Source Line**: 58

---

### `evaluate_condition`

**Description**: Evaluate a condition expression Args: $1 = condition_expression

**Returns**: Returns: 0 if condition met, 1 otherwise

**Source Line**: 148

---

### `evaluate_single_condition`

**Description**: Evaluate a single condition Args: $1 = single_condition

**Returns**: Returns: 0 if true, 1 if false

**Source Line**: 189

---

### `should_execute_step_conditional`

**Description**: Check if step should execute based on conditions Args: $1 = step_number

**Returns**: Returns: 0 if should execute, 1 if should skip

**Source Line**: 234

---

### `get_skip_reason`

**Description**: Get skip reason for step Args: $1 = step_number

**Returns**: Returns: Human-readable skip reason

**Source Line**: 251

---

### `generate_conditional_execution_plan`

**Description**: Generate execution plan based on conditions

**Returns**: Returns: JSON with execution plan

**Source Line**: 295

---

### `display_conditional_execution_plan`

**Description**: Display execution plan

**Source Line**: 329

---

### `should_execute_step_enhanced`

**Description**: Enhanced should_execute_step with conditional logic Args: $1 = step_number

**Returns**: Returns: 0 if should execute, 1 if should skip

**Source Line**: 361

---

### `record_step_decision`

**Description**: Record step decision Args: $1 = step_number, $2 = executed (true/false)

**Source Line**: 402

---

### `display_conditional_stats`

**Description**: Display conditional execution statistics

**Source Line**: 420

---

### `add_step_condition`

**Description**: Add custom condition for a step Args: $1 = step_number, $2 = condition_expression

**Source Line**: 444

---

### `remove_step_condition`

**Description**: Remove condition for a step (always execute) Args: $1 = step_number

**Source Line**: 453

---


## Module: dependency_cache.sh

**Location**: `src/workflow/lib/dependency_cache.sh`  
**Category**: Optimization

**Functions**: 11

### `track_dep_cache_temp`

**Description**: Register temp file for cleanup

**Source Line**: 35

---

### `cleanup_dep_cache_files`

**Description**: Cleanup handler for dependency cache

**Source Line**: 41

---

### `init_dependency_cache`

**Description**: Initialize dependency cache directory and index

**Source Line**: 54

---

### `generate_dependency_cache_key`

**Description**: Generate a cache key from package.json content and command type Args: $1 = package.json path, $2 = cache type (audit|outdated)

**Returns**: Returns: SHA256 hash as cache key

**Source Line**: 92

---

### `check_dependency_cache`

**Description**: Check if cached result exists and is valid Args: $1 = cache_key

**Returns**: Returns: 0 if exists and valid, 1 otherwise

**Source Line**: 117

---

### `get_cached_dependency_result`

**Description**: Get cached result Args: $1 = cache_key, $2 = output file path

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 156

---

### `save_to_dependency_cache`

**Description**: Save result to cache Args: $1 = cache_key, $2 = result file path, $3 = cache type

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 177

---

### `update_dependency_cache_index`

**Description**: Update cache index with new entry Args: $1 = cache_key, $2 = cache_type

**Source Line**: 211

---

### `cleanup_dependency_cache_old_entries`

**Description**: Remove expired cache entries

**Source Line**: 240

---

### `clear_dependency_cache`

**Description**: Clear entire dependency cache

**Source Line**: 285

---

### `get_dependency_cache_stats`

**Description**: Get cache statistics

**Source Line**: 299

---


## Module: dependency_graph.sh

**Location**: `src/workflow/lib/dependency_graph.sh`  
**Category**: Optimization

**Functions**: 13

### `check_dependencies`

**Description**: Check if step's dependencies are met Usage: check_dependencies <step_number> <completed_steps>

**Returns**: Returns: 0 if dependencies met, 1 otherwise

**Source Line**: 129

---

### `get_next_runnable_steps`

**Description**: Get next runnable steps based on completed steps Usage: get_next_runnable_steps <completed_steps>

**Returns**: Returns: Comma-separated list of step numbers that can run

**Source Line**: 154

---

### `get_parallel_steps`

**Description**: Get steps that can run in parallel Usage: get_parallel_steps <completed_steps>

**Returns**: Returns: Comma-separated list of steps that can run simultaneously

**Source Line**: 180

---

### `generate_dependency_diagram`

**Description**: Generate Mermaid diagram of step dependencies Usage: generate_dependency_diagram [output_file]

**Source Line**: 194

---

### `generate_dependency_tree`

**Description**: Generate ASCII dependency tree

**Source Line**: 325

---

### `generate_execution_plan`

**Description**: Generate optimal execution plan with parallelization Usage: generate_execution_plan

**Source Line**: 363

---

### `display_execution_phases`

**Description**: Display execution phases in terminal

**Source Line**: 444

---

### `calculate_critical_path`

**Description**: Calculate critical path duration

**Source Line**: 470

---

### `export_step_metadata_json`

**Description**: Export step metadata and dependencies as JSON Usage: export_step_metadata_json [output_file]

**Source Line**: 495

---

### `query_step_info`

**Description**: Query step dependencies with metadata Usage: query_step_info <step_number>

**Source Line**: 634

---

### `get_ready_steps`

**Description**: Find steps that can run now based on completed steps Usage: get_ready_steps <completed_steps_csv>

**Source Line**: 661

---

### `calculate_critical_path`

**Description**: Calculate critical path through workflow

**Returns**: Returns: Space-separated list of steps in critical path

**Source Line**: 686

---

### `calculate_total_time`

**Description**: Calculate total time for step list Usage: calculate_total_time <step_list_csv>

**Source Line**: 694

---


## Module: docs_only_optimization.sh

**Location**: `src/workflow/lib/docs_only_optimization.sh`  
**Category**: Optimization

**Functions**: 10

### `detect_docs_only_with_confidence`

**Description**: Enhanced docs-only detection with confidence scoring

**Returns**: Returns: JSON object with detection result and confidence

**Source Line**: 25

---

### `is_docs_only_change`

**Description**: Quick docs-only check (boolean only)

**Returns**: Returns: 0 if docs-only, 1 otherwise

**Source Line**: 58

---

### `should_skip_step_docs_only`

**Description**: Enhanced skip decision for docs-only workflow Args: $1 = step_number

**Returns**: Returns: 0 to skip, 1 to execute

**Source Line**: 94

---

### `get_deps_hash`

**Description**: Get hash of dependency files

**Source Line**: 121

---

### `is_deps_validated_cached`

**Description**: Check if dependencies have been validated recently

**Returns**: Returns: 0 if cached, 1 if needs validation

**Source Line**: 145

---

### `mark_deps_validated`

**Description**: Mark dependencies as validated

**Source Line**: 167

---

### `cleanup_deps_cache`

**Description**: Cleanup old dependency cache entries

**Source Line**: 178

---

### `execute_docs_only_fast_track`

**Description**: Execute docs-only workflow in optimized parallel mode Only runs: 0 → (1,2,12 parallel) → 11 Expected time: ~90-120 seconds (vs 180-240 for standard docs-only)

**Source Line**: 203

---

### `generate_docs_only_fast_track_report`

**Description**: Generate report for docs-only fast track execution

**Source Line**: 363

---

### `enable_docs_only_optimization`

**Description**: Hook into main workflow to enable docs-only fast track Call this early in workflow execution (after change detection)

**Source Line**: 496

---


## Module: full_changes_optimization.sh

**Location**: `src/workflow/lib/full_changes_optimization.sh`  
**Category**: Optimization

**Functions**: 3

### `execute_4track_parallel`

**Description**: Execute workflow in 4 parallel tracks for maximum performance Track 1: Analysis (0 → 3,4,13 → 10 → 11) Track 2: Testing (5,8 → 6 → 7 sharded) Track 3: Quality (waits for 7 → 9) Track 4: Documentation (1 → 2 → 12 → 14)

**Returns**: Returns: 0 if all succeed, 1 if any fail

**Source Line**: 35

---

### `generate_4track_execution_report`

**Description**: Generate execution report for 4-track parallel mode

**Source Line**: 338

---

### `enable_full_changes_optimization`

**Description**: Enable full changes optimization (4-track + sharding)

**Returns**: Returns: 0 if should use 4-track, 1 otherwise

**Source Line**: 485

---


## Module: incremental_analysis.sh

**Location**: `src/workflow/lib/incremental_analysis.sh`  
**Category**: Optimization

**Functions**: 11

### `init_incremental_cache`

**Description**: Initialize cache directory Usage: init_incremental_cache

**Source Line**: 27

---

### `get_cached_tree`

**Description**: Get cached git tree for directory analysis Usage: get_cached_tree <output_file>

**Returns**: Returns: 0 if cache exists and is valid, 1 otherwise

**Source Line**: 34

---

### `get_changed_js_files`

**Description**: Get list of changed JavaScript/source files since last commit Usage: get_changed_js_files [base_ref]

**Returns**: Returns: List of changed .js/.mjs files (one per line)

**Source Line**: 63

---

### `get_changed_consistency_files`

**Description**: Get list of changed files for consistency analysis Usage: get_changed_consistency_files [base_ref]

**Returns**: Returns: List of changed documentation and code files

**Source Line**: 73

---

### `should_use_incremental_analysis`

**Description**: Check if incremental analysis should be used Usage: should_use_incremental_analysis <project_kind>

**Returns**: Returns: 0 if incremental analysis is applicable, 1 otherwise

**Source Line**: 84

---

### `get_incremental_doc_inventory`

**Description**: Get documentation inventory with incremental filtering Usage: get_incremental_doc_inventory [base_ref]

**Returns**: Returns: List of documentation files to analyze

**Source Line**: 107

---

### `analyze_consistency_incremental`

**Description**: Analyze consistency for changed files only Usage: analyze_consistency_incremental [base_ref]

**Returns**: Returns: Consistency analysis results

**Source Line**: 125

---

### `get_cached_directory_tree`

**Description**: Get directory structure using cached git tree Usage: get_cached_directory_tree

**Returns**: Returns: Directory tree from cache or generates new one

**Source Line**: 152

---

### `can_skip_directory_validation`

**Description**: Check if directory structure validation can be skipped Usage: can_skip_directory_validation [base_ref]

**Returns**: Returns: 0 if can skip, 1 if full validation needed

**Source Line**: 170

---

### `calculate_incremental_savings`

**Description**: Calculate time savings from incremental analysis Usage: calculate_incremental_savings <total_files> <analyzed_files>

**Source Line**: 196

---

### `report_incremental_stats`

**Description**: Report incremental analysis statistics Usage: report_incremental_stats <step_number> <total_files> <analyzed_files>

**Source Line**: 211

---


## Module: ml_optimization.sh

**Location**: `src/workflow/lib/ml_optimization.sh`  
**Category**: Optimization

**Functions**: 17

### `jq_safe`

**Description**: Fallback: define jq_safe as alias to jq if wrapper not found

**Source Line**: 28

---

### `init_ml_system`

**Description**: Initialize ML data structures

**Source Line**: 47

---

### `extract_change_features`

**Description**: Extract features from current changes

**Returns**: Returns: JSON object with features

**Source Line**: 76

---

### `predict_step_duration`

**Description**: Predict step duration based on features Args: $1 = step_number, $2 = features_json

**Returns**: Returns: predicted duration in seconds

**Source Line**: 194

---

### `predict_workflow_duration`

**Description**: Predict total workflow duration Args: $1 = features_json, $2 = steps_array

**Returns**: Returns: predicted total duration

**Source Line**: 282

---

### `recommend_parallelization`

**Description**: Recommend optimal parallelization strategy Args: $1 = features_json

**Returns**: Returns: parallelization recommendation JSON

**Source Line**: 312

---

### `recommend_skip_steps`

**Description**: Recommend which steps to skip based on ML classification Args: $1 = features_json

**Returns**: Returns: array of steps to skip

**Source Line**: 414

---

### `detect_anomaly`

**Description**: Detect if current execution is anomalous Args: $1 = step_number, $2 = actual_duration, $3 = predicted_duration

**Returns**: Returns: 0 if normal, 1 if anomaly

**Source Line**: 484

---

### `log_anomaly`

**Description**: Log anomaly for investigation Args: $1 = step, $2 = actual, $3 = predicted, $4 = deviation_pct

**Source Line**: 511

---

### `record_execution`

**Description**: Record workflow execution for training Args: $1 = execution_data_json

**Source Line**: 555

---

### `record_step_execution`

**Description**: Record step execution for training Args: $1 = step_number, $2 = duration, $3 = features_json, $4 = issues_found

**Source Line**: 567

---

### `check_retraining_needed`

**Description**: Check if retraining is needed

**Source Line**: 618

---

### `retrain_models`

**Description**: Retrain ML models

**Source Line**: 638

---

### `calculate_model_statistics`

**Description**: Calculate and cache model statistics

**Source Line**: 661

---

### `apply_ml_optimization`

**Description**: Apply ML recommendations to workflow

**Returns**: Returns: JSON with recommendations

**Source Line**: 689

---

### `validate_ml_predictions`

**Description**: Validate ML predictions after execution Args: $1 = actual_duration

**Source Line**: 759

---

### `display_ml_status`

**Description**: Display ML system status

**Source Line**: 789

---


## Module: multi_stage_pipeline.sh

**Location**: `src/workflow/lib/multi_stage_pipeline.sh`  
**Category**: Optimization

**Functions**: 18

### `should_run_stage`

**Description**: Check if stage should run based on trigger Args: $1 = stage_number

**Returns**: Returns: 0 if should run, 1 if should skip

**Source Line**: 74

---

### `evaluate_stage_trigger`

**Description**: Evaluate stage trigger condition Args: $1 = trigger_expression, $2 = stage_number

**Returns**: Returns: 0 if trigger met, 1 otherwise

**Source Line**: 99

---

### `evaluate_single_trigger`

**Description**: Evaluate single trigger condition Args: $1 = condition, $2 = stage_number

**Returns**: Returns: 0 if true, 1 if false

**Source Line**: 150

---

### `is_high_impact_change`

**Description**: Check if changes are high impact

**Returns**: Returns: 0 if high impact, 1 otherwise

**Source Line**: 213

---

### `has_docs_changes`

**Description**: Check if documentation changed

**Source Line**: 247

---

### `has_script_changes`

**Description**: Check if scripts changed

**Source Line**: 252

---

### `has_structure_changes`

**Description**: Check if directory structure changed

**Source Line**: 257

---

### `has_code_changes`

**Description**: Check if source code changed

**Source Line**: 265

---

### `execute_stage`

**Description**: Execute a pipeline stage Args: $1 = stage_number

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 276

---

### `execute_pipeline`

**Description**: Execute multi-stage pipeline

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 358

---

### `print_stage_header`

**Description**: Display stage header Args: $1 = stage_number, $2 = stage_name, $3 = target_seconds

**Source Line**: 421

---

### `display_pipeline_summary`

**Description**: Display pipeline execution summary

**Source Line**: 436

---

### `display_pipeline_plan`

**Description**: Display pipeline plan (dry-run)

**Source Line**: 495

---

### `enable_manual_trigger`

**Description**: Enable manual trigger for Stage 3

**Source Line**: 528

---

### `disable_manual_trigger`

**Description**: Disable manual trigger

**Source Line**: 534

---

### `run_stages`

**Description**: Run only specific stage(s) Args: $@ = stage numbers (e.g., "1" or "1 2")

**Source Line**: 540

---

### `set_stage_target`

**Description**: Set custom stage target times Args: $1 = stage_number, $2 = target_seconds

**Source Line**: 554

---

### `display_pipeline_config`

**Description**: Display pipeline configuration

**Source Line**: 568

---


## Module: skip_predictor.sh

**Location**: `src/workflow/lib/skip_predictor.sh`  
**Category**: Optimization

**Functions**: 10

### `jq_safe`

*No documentation available*

**Source Line**: 27

---

### `init_skip_predictor`

**Description**: Initialize skip prediction system

**Source Line**: 52

---

### `calculate_feature_similarity`

**Description**: Calculate cosine similarity between feature vectors Args: $1 = features_json_1, $2 = features_json_2

**Returns**: Returns: similarity score (0.0 - 1.0)

**Source Line**: 79

---

### `query_skip_history`

**Description**: Query skip history for similar executions Args: $1 = step_number, $2 = features_json

**Returns**: Returns: JSON with historical skip data

**Source Line**: 140

---

### `calculate_skip_confidence`

**Description**: Calculate multi-factor confidence score Args: $1 = step, $2 = features, $3 = skip_history_json

**Returns**: Returns: confidence score (0.0 - 1.0)

**Source Line**: 214

---

### `is_safe_to_skip`

**Description**: Check if step is safe to skip Args: $1 = step_number, $2 = confidence, $3 = features

**Returns**: Returns: 0 if safe to skip, 1 if should run

**Source Line**: 268

---

### `predict_step_necessity`

**Description**: Predict if step should be skipped Args: $1 = step_number, $2 = features_json

**Returns**: Returns: JSON prediction with confidence and recommendation

**Source Line**: 318

---

### `record_skip_decision`

**Description**: Record skip decision for learning Args: $1 = run_id, $2 = step, $3 = skipped (true/false), $4 = features, $5 = confidence

**Source Line**: 395

---

### `update_skip_outcome`

**Description**: Update skip decision outcome Args: $1 = run_id, $2 = step, $3 = outcome (success/should_have_run)

**Source Line**: 430

---

### `generate_skip_report`

**Description**: Generate skip prediction report Args: $1 = predictions_json_array

**Source Line**: 467

---


## Module: workflow_profiles.sh

**Location**: `src/workflow/lib/workflow_profiles.sh`  
**Category**: Optimization

**Purpose**: Workflow Profiles - Customize execution by change type

**Functions**: 14

### `detect_workflow_profile`

**Description**: ###################################### Detect workflow profile based on git changes Analyzes changed files and selects appropriate profile Globals: WORKFLOW_PROFILE SKIP_PROFILE_DETECTION Arguments: None

**Returns**: Returns: 0 on success ######################################

**Source Line**: 80

---

### `get_changed_files`

**Description**: ###################################### Get changed files from git

**Returns**: Returns: List of changed files, one per line ######################################

**Source Line**: 157

---

### `matches_pattern`

**Description**: ###################################### Check if file matches pattern Arguments: $1 - File path $2 - Pattern (can contain | for multiple patterns)

**Returns**: Returns: 0 if matches, 1 otherwise ######################################

**Source Line**: 179

---

### `get_skip_steps`

**Description**: ###################################### Get steps to skip for a profile Arguments: $1 - Profile name

**Returns**: Returns: Comma-separated list of step numbers to skip ######################################

**Source Line**: 199

---

### `get_focus_steps`

**Description**: ###################################### Get steps to focus on for a profile Arguments: $1 - Profile name

**Returns**: Returns: Comma-separated list of step numbers to focus on ######################################

**Source Line**: 219

---

### `get_estimated_time`

**Description**: ###################################### Get estimated time for a profile Arguments: $1 - Profile name

**Returns**: Returns: Estimated time string ######################################

**Source Line**: 239

---

### `get_profile_description`

**Description**: ###################################### Get profile description Arguments: $1 - Profile name

**Returns**: Returns: Description string ######################################

**Source Line**: 259

---

### `should_skip_step`

**Description**: ###################################### Check if step should be skipped based on profile Arguments: $1 - Step number

**Returns**: Returns: 0 if should skip, 1 if should run ######################################

**Source Line**: 279

---

### `display_profile_info`

**Description**: ###################################### Display profile information Arguments: $1 - Profile name (optional, uses WORKFLOW_PROFILE if not set)

**Returns**: Returns: None ######################################

**Source Line**: 304

---

### `list_profiles`

**Description**: ###################################### List all available profiles

**Returns**: Returns: None ######################################

**Source Line**: 331

---

### `calculate_savings`

**Description**: ###################################### Calculate time savings vs full validation Arguments: $1 - Profile name

**Returns**: Returns: Savings percentage ######################################

**Source Line**: 352

---

### `log_info`

**Description**: ###################################### Log helper functions ######################################

**Source Line**: 381

---

### `log_warning`

*No documentation available*

**Source Line**: 385

---

### `log_error`

*No documentation available*

**Source Line**: 389

---


## Module: dashboard.sh

**Location**: `src/workflow/lib/dashboard.sh`  
**Category**: Performance & Monitoring

**Functions**: 15

### `parse_workflow_log`

**Description**: Parse workflow execution log to JSON Args: $1 = log_file

**Source Line**: 33

---

### `generate_dashboard`

**Description**: Generate HTML dashboard Args: $1 = metrics_json, $2 = output_file

**Source Line**: 118

---

### `initDashboard`

*No documentation available*

**Source Line**: 349

---

### `renderMetricCards`

*No documentation available*

**Source Line**: 350

---

### `renderDurationChart`

*No documentation available*

**Source Line**: 351

---

### `renderStepsTable`

*No documentation available*

**Source Line**: 352

---

### `updateTimestamp`

*No documentation available*

**Source Line**: 353

---

### `renderMetricCards`

*No documentation available*

**Source Line**: 356

---

### `renderDurationChart`

*No documentation available*

**Source Line**: 378

---

### `renderStepsTable`

*No documentation available*

**Source Line**: 400

---

### `calculateMetrics`

*No documentation available*

**Source Line**: 418

---

### `updateTimestamp`

*No documentation available*

**Source Line**: 428

---

### `extract_current_metrics`

**Description**: Extract comprehensive metrics from current run

**Source Line**: 452

---

### `generate_current_dashboard`

**Description**: Generate dashboard from current workflow

**Source Line**: 464

---

### `serve_dashboard`

**Description**: Serve dashboard on local HTTP server Args: $1 = dashboard_file, $2 = port (default: 8080)

**Source Line**: 477

---


## Module: performance.sh

**Location**: `src/workflow/lib/performance.sh`  
**Category**: Performance & Monitoring

**Functions**: 26

### `track_perf_temp`

**Description**: Register temp file for cleanup

**Source Line**: 19

---

### `track_perf_cache`

**Description**: Register cache file for cleanup

**Source Line**: 25

---

### `cleanup_performance_files`

**Description**: Cleanup handler for performance module

**Source Line**: 31

---

### `parallel_execute`

**Description**: Execute commands in parallel with job control Usage: parallel_execute <max_jobs> <command1> <command2> ...

**Returns**: Returns: 0 if all succeed, 1 if any fail

**Source Line**: 52

---

### `parallel_workflow_steps`

**Description**: Execute workflow steps in parallel (safe subset) Usage: parallel_workflow_steps <step1_func> <step2_func> ...

**Source Line**: 88

---

### `fast_find`

**Description**: Fast find with optimal filters Usage: fast_find <directory> <pattern> [max_depth] [exclude_dirs...]

**Source Line**: 122

---

### `fast_find_modified`

**Description**: Find modified files faster using git Usage: fast_find_modified [since_commit]

**Source Line**: 143

---

### `fast_grep`

**Description**: Fast grep with smart filtering Usage: fast_grep <pattern> <directory> [file_pattern] [exclude_dirs...]

**Source Line**: 161

---

### `fast_grep_count`

**Description**: Count pattern matches efficiently Usage: fast_grep_count <pattern> <directory> [file_pattern]

**Source Line**: 192

---

### `cache_get`

**Description**: Simple file-based cache with TTL Usage: cache_get <key>

**Returns**: Returns: cached value if exists and not expired

**Source Line**: 216

---

### `cache_set`

**Description**: Store value in cache Usage: cache_set <key> <value>

**Source Line**: 238

---

### `cache_clear`

**Description**: Clear cache for key or all Usage: cache_clear [key]

**Source Line**: 248

---

### `memoize`

**Description**: Memoize function results Usage: memoize <function_name> [args...]

**Source Line**: 261

---

### `batch_git_commands`

**Description**: Batch multiple git commands Usage: batch_git_commands <command1> <command2> ...

**Source Line**: 292

---

### `fast_file_count`

**Description**: Optimized file counting Usage: fast_file_count <directory> [pattern]

**Source Line**: 309

---

### `fast_dir_size`

**Description**: Optimized directory size Usage: fast_dir_size <directory>

**Source Line**: 319

---

### `time_command`

**Description**: Measure command execution time Usage: time_command <command> [args...]

**Source Line**: 332

---

### `profile_section`

**Description**: Profile workflow section Usage: profile_section <section_name> <command>

**Source Line**: 348

---

### `generate_perf_report`

**Description**: Generate performance report Usage: generate_perf_report

**Source Line**: 374

---

### `batch_process`

**Description**: Process files in batches Usage: batch_process <batch_size> <command> <file1> <file2> ...

**Source Line**: 403

---

### `lazy_load`

**Description**: Lazy load expensive data Usage: lazy_load <variable_name> <command>

**Source Line**: 438

---

### `parallel_file_process`

**Description**: Process files in parallel Usage: parallel_file_process <max_jobs> <command> <file1> <file2> ...

**Source Line**: 458

---

### `execute_if_needed`

**Description**: Execute command only if needed (check prerequisites) Usage: execute_if_needed <check_command> <execute_command>

**Source Line**: 495

---

### `batch_read_files`

*No documentation available*

**Source Line**: 533

---

### `batch_read_files_limited`

*No documentation available*

**Source Line**: 551

---

### `batch_command_outputs`

*No documentation available*

**Source Line**: 571

---


## Module: performance_monitoring.sh

**Location**: `src/workflow/lib/performance_monitoring.sh`  
**Category**: Performance & Monitoring

**Functions**: 17

### `check_step_duration_threshold`

**Description**: Check if step duration exceeds threshold Args: $1 = step_number, $2 = duration_seconds

**Returns**: Returns: 0 if OK, 1 if warning, 2 if critical

**Source Line**: 63

---

### `report_step_threshold_violation`

**Description**: Report step duration threshold violation Args: $1 = step_number, $2 = duration_seconds, $3 = severity (WARNING/CRITICAL)

**Source Line**: 89

---

### `check_workflow_duration_threshold`

**Description**: Check if workflow duration exceeds threshold Args: $1 = duration_seconds

**Returns**: Returns: 0 if OK, 1 if warning, 2 if critical (should fail)

**Source Line**: 129

---

### `report_workflow_threshold_violation`

**Description**: Report workflow duration threshold violation Args: $1 = duration_seconds, $2 = severity (WARNING/CRITICAL)

**Source Line**: 149

---

### `execute_with_api_timeout`

**Description**: Execute command with Copilot API timeout Args: $1 = command, $2 = description

**Returns**: Returns: 0 on success, 1 on timeout/failure

**Source Line**: 183

---

### `monitor_step_execution`

**Description**: Monitor step execution in real-time Args: $1 = step_number

**Returns**: Returns: Monitoring report

**Source Line**: 232

---

### `monitor_workflow_progress`

**Description**: Monitor overall workflow progress

**Returns**: Returns: Progress report

**Source Line**: 257

---

### `analyze_performance_trend`

**Description**: Analyze performance trends Args: $1 = step_number (optional, blank for workflow)

**Returns**: Returns: Trend analysis

**Source Line**: 291

---

### `analyze_workflow_trend`

**Description**: Analyze workflow performance trend

**Source Line**: 304

---

### `analyze_step_trend`

**Description**: Analyze step performance trend Args: $1 = step_number

**Source Line**: 339

---

### `suggest_step_remediation`

**Description**: Suggest remediation for slow step Args: $1 = step_number, $2 = duration_seconds

**Source Line**: 365

---

### `suggest_api_timeout_remediation`

**Description**: Suggest remediation for API timeout Args: $1 = description

**Source Line**: 404

---

### `display_threshold_violations`

**Description**: Display threshold violations summary

**Source Line**: 424

---

### `set_step_duration_threshold`

**Description**: Set custom step duration threshold Args: $1 = threshold_seconds

**Source Line**: 473

---

### `set_workflow_duration_threshold`

**Description**: Set custom workflow duration threshold Args: $1 = threshold_seconds

**Source Line**: 481

---

### `set_api_timeout`

**Description**: Set custom API timeout Args: $1 = timeout_seconds

**Source Line**: 489

---

### `display_threshold_config`

**Description**: Display current threshold configuration

**Source Line**: 496

---


## Module: backlog.sh

**Location**: `src/workflow/lib/backlog.sh`  
**Category**: Session & State

**Functions**: 1

### `create_workflow_summary`

**Description**: Create a comprehensive summary file for the entire workflow run Called at the end of execute_full_workflow()

**Source Line**: 16

---


## Module: session_manager.sh

**Location**: `src/workflow/lib/session_manager.sh`  
**Category**: Session & State

**Functions**: 12

### `generate_session_id`

**Description**: Generate unique session ID with workflow context Usage: generate_session_id <step_num> <operation_name>

**Returns**: Returns: session_id string (e.g., "step07_test_exec_20251113_193721_abc123")

**Source Line**: 21

---

### `register_session`

**Description**: Register a session for tracking and cleanup Usage: register_session <session_id> <description>

**Source Line**: 36

---

### `unregister_session`

**Description**: Unregister a session after completion Usage: unregister_session <session_id>

**Source Line**: 48

---

### `execute_with_session`

**Description**: Execute command with proper session management Usage: execute_with_session <step_num> <operation> <command> [timeout_seconds] [mode]

**Returns**: Returns: command exit code

**Source Line**: 72

---

### `wait_for_session`

**Description**: Wait for async session to complete Usage: wait_for_session <session_id> [timeout_seconds]

**Returns**: Returns: 0 if completed successfully, 1 if timeout or error

**Source Line**: 145

---

### `kill_session`

**Description**: Kill async session Usage: kill_session <session_id>

**Source Line**: 196

---

### `cleanup_all_sessions`

**Description**: Cleanup all active sessions (called on exit/interrupt) Usage: cleanup_all_sessions

**Source Line**: 221

---

### `list_active_sessions`

**Description**: List all active sessions Usage: list_active_sessions

**Source Line**: 248

---

### `get_recommended_timeout`

**Description**: Get recommended timeout for common operations Usage: get_recommended_timeout <operation_type>

**Returns**: Returns: timeout in seconds

**Source Line**: 276

---

### `execute_npm_command`

**Description**: Execute npm command with proper session management Usage: execute_npm_command <step_num> <npm_command> [args...]

**Source Line**: 313

---

### `execute_git_command`

**Description**: Execute git command with proper session management Usage: execute_git_command <step_num> <git_args...>

**Source Line**: 330

---

### `enhanced_workflow_cleanup`

**Description**: Enhanced cleanup that includes session management Should be called from main workflow cleanup handler

**Source Line**: 350

---


## Module: summary.sh

**Location**: `src/workflow/lib/summary.sh`  
**Category**: Session & State

**Functions**: 6

### `determine_step_status`

**Description**: Determine step status icon based on findings Usage: determine_step_status <issues_found> <warnings_found>

**Returns**: Returns: ✅ (success), ⚠️ (warnings), or ❌ (errors)

**Source Line**: 17

---

### `format_step_summary`

**Description**: Format summary content with consistent structure Usage: format_step_summary <step_name> <summary_text>

**Source Line**: 32

---

### `create_progress_summary`

**Description**: Create a concise one-line summary for progress tracking Usage: create_progress_summary <step_num> <step_name> <status>

**Source Line**: 51

---

### `generate_step_stats`

**Description**: Generate summary statistics from step execution Usage: generate_step_stats <files_checked> <issues_found> <warnings_found>

**Source Line**: 61

---

### `create_summary_badge`

**Description**: Create a summary badge/indicator Usage: create_summary_badge <status>

**Source Line**: 76

---

### `aggregate_summaries`

**Description**: Aggregate summaries from multiple steps Usage: aggregate_summaries <step_files...>

**Source Line**: 97

---


## Module: step_adaptation.sh

**Location**: `src/workflow/lib/step_adaptation.sh`  
**Category**: Step Management

**Functions**: 11

### `load_yaml_value`

**Description**: ###################################### Load a single value from YAML file using yq Arguments: $1 - YAML path (e.g., "step_relevance.nodejs_api.step_00_analyze") $2 - YAML file path Outputs: Value from YAML or empty string

**Returns**: Returns: 0 on success ######################################

**Source Line**: 61

---

### `load_yaml_section`

**Description**: ###################################### Load a section from YAML file as key=value pairs Arguments: $1 - YAML path (e.g., "step_adaptations.step_05_test_review.nodejs_api") $2 - YAML file path Outputs: Key=value pairs, one per line

**Returns**: Returns: 0 on success ######################################

**Source Line**: 104

---

### `should_execute_step`

**Description**: ###################################### Determine if a step should be executed based on project kind and user preferences Globals: PRIMARY_KIND - Current project kind SKIP_STEPS - Array of steps to skip (optional) INCLUDE_STEPS - Array of steps to include (optional) Arguments: $1 - Step name (e.g., "step_05_test_review")

**Returns**: Returns: 0 if step should execute, 1 otherwise ######################################

**Source Line**: 148

---

### `get_step_relevance`

**Description**: ###################################### Get the relevance level for a step Globals: STEP_RELEVANCE_CACHE - Cache for loaded relevance values Arguments: $1 - Step name $2 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: Relevance level (required|recommended|optional|skip)

**Returns**: Returns: 0 on success, 1 on error ######################################

**Source Line**: 207

---

### `get_step_adaptations`

**Description**: ###################################### Get step-specific adaptations for project kind Globals: STEP_ADAPTATIONS_CACHE - Cache for loaded adaptations Arguments: $1 - Step name $2 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: YAML section as key=value pairs

**Returns**: Returns: 0 on success, 1 on error ######################################

**Source Line**: 255

---

### `get_adaptation_value`

**Description**: ###################################### Get a specific adaptation value for a step Arguments: $1 - Step name $2 - Adaptation key (e.g., "minimum_coverage") $3 - Project kind (optional, defaults to PRIMARY_KIND) $4 - Default value (optional) Outputs: Adaptation value or default

**Returns**: Returns: 0 on success ######################################

**Source Line**: 295

---

### `list_step_adaptations`

**Description**: ###################################### List all available adaptations for a step Arguments: $1 - Step name $2 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: List of adaptation keys (one per line)

**Returns**: Returns: 0 on success ######################################

**Source Line**: 325

---

### `validate_step_relevance`

**Description**: ###################################### Validate step relevance configuration Globals: STEP_RELEVANCE_CONFIG - Configuration file path Outputs: Validation errors (if any)

**Returns**: Returns: 0 if valid, 1 if errors found ######################################

**Source Line**: 352

---

### `get_required_steps`

**Description**: ###################################### Get list of required steps for a project kind Arguments: $1 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: List of required step names (one per line)

**Returns**: Returns: 0 on success ######################################

**Source Line**: 397

---

### `get_skippable_steps`

**Description**: ###################################### Get list of optional/skippable steps for a project kind Arguments: $1 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: List of optional/skip step names (one per line)

**Returns**: Returns: 0 on success ######################################

**Source Line**: 419

---

### `display_execution_plan`

**Description**: ###################################### Display step execution plan based on project kind Arguments: $1 - Project kind (optional, defaults to PRIMARY_KIND) Outputs: Formatted execution plan

**Returns**: Returns: 0 on success ######################################

**Source Line**: 441

---


## Module: step_execution.sh

**Location**: `src/workflow/lib/step_execution.sh`  
**Category**: Step Management

**Functions**: 3

### `execute_phase2_ai_analysis`

**Description**: Handles Phase 2 AI analysis with issue extraction Arguments: $1 - copilot_prompt: The prompt to execute $2 - step_number: Step number (e.g., "2", "3") $3 - step_name: Step name for logging (e.g., "consistency_analysis") $4 - step_name_display: Display name (e.g., "Consistency_Analysis") $5 - has_issues: Number of issues found (>0 triggers auto execution) $6 - analysis_type: Description of analysis type $7 - optional_prompt_msg: Message for optional run (when has_issues=0) $8 - success_question: Question to ask after copilot runs

**Returns**: Returns: 0 for success, 1 for failure

**Source Line**: 21

---

### `extract_and_save_issues`

**Description**: Extracts issues from Copilot log and saves to backlog Arguments: $1 - log_file: Path to Copilot session log $2 - step_number: Step number $3 - step_name: Step name for backlog

**Returns**: Returns: 0 for success

**Source Line**: 139

---

### `save_step_results`

**Description**: Generates and saves step summary and backlog Arguments: $1 - step_number: Step number $2 - step_name: Step name for backlog $3 - issues_found: Number of issues found $4 - success_message: Message when no issues found $5 - failure_message: Message when issues found $6 - issues_file: Path to file containing issue details (optional) $7 - doc_count: Count of documents/items checked (optional)

**Returns**: Returns: 0 for success

**Source Line**: 191

---


## Module: step_loader.sh

**Location**: `src/workflow/lib/step_loader.sh`  
**Category**: Step Management

**Functions**: 9

### `load_step_module`

**Description**: Load a step module dynamically Args: $1 = step name

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 37

---

### `load_all_step_modules`

**Description**: Pre-load all step modules Useful for validation and early error detection

**Returns**: Returns: 0 if all modules loaded, 1 if any failed

**Source Line**: 88

---

### `validate_step_exists`

**Description**: Validate that a step exists and can be executed Args: $1 = step name or index

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 123

---

### `validate_step_dependencies_met`

**Description**: Validate step dependencies are met Args: $1 = step name Args: $2 = comma-separated list of completed steps

**Returns**: Returns: 0 if dependencies met, 1 if not

**Source Line**: 161

---

### `execute_step`

**Description**: Execute a step with proper error handling and logging Args: $1 = step name or index

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 195

---

### `execute_steps`

**Description**: Execute multiple steps in sequence Args: $@ = step names or indices

**Returns**: Returns: 0 if all succeed, 1 if any fail

**Source Line**: 287

---

### `get_loaded_module_count`

**Description**: Get loaded module count

**Source Line**: 336

---

### `is_module_loaded`

**Description**: Check if module is loaded Args: $1 = step name

**Returns**: Returns: 0 if loaded, 1 if not

**Source Line**: 343

---

### `print_loaded_modules`

**Description**: Print loaded modules

**Source Line**: 349

---


## Module: step_metadata.sh

**Location**: `src/workflow/lib/step_metadata.sh`  
**Category**: Step Management

**Functions**: 12

### `get_step_name`

**Description**: Get step name

**Source Line**: 182

---

### `get_step_description`

**Description**: Get step description

**Source Line**: 188

---

### `get_step_category`

**Description**: Get step category

**Source Line**: 194

---

### `can_skip_step`

**Description**: Check if step can be skipped

**Source Line**: 200

---

### `can_parallelize_step`

**Description**: Check if step can be parallelized

**Source Line**: 207

---

### `requires_ai`

**Description**: Check if step requires AI

**Source Line**: 214

---

### `get_affected_files`

**Description**: Get files affected by step

**Source Line**: 221

---

### `get_steps_by_category`

**Description**: Get steps by category

**Source Line**: 227

---

### `get_skippable_steps`

**Description**: Get skippable steps

**Source Line**: 241

---

### `get_parallelizable_steps`

**Description**: Get parallelizable steps

**Source Line**: 254

---

### `get_ai_dependent_steps`

**Description**: Get AI-dependent steps

**Source Line**: 267

---

### `generate_metadata_report`

**Description**: Generate step metadata report

**Source Line**: 280

---


## Module: step_registry.sh

**Location**: `src/workflow/lib/step_registry.sh`  
**Category**: Step Management

**Functions**: 11

### `load_step_definitions`

**Description**: Load step definitions from .workflow-config.yaml

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 49

---

### `_load_legacy_step_definitions`

**Description**: Load legacy v3.x step definitions for backward compatibility

**Source Line**: 173

---

### `get_step_by_index`

**Description**: Get step name by numeric index Args: $1 = numeric index (1-N)

**Returns**: Returns: step name, or empty string if not found

**Source Line**: 241

---

### `get_step_index`

**Description**: Get step index by name Args: $1 = step name

**Returns**: Returns: numeric index, or empty string if not found

**Source Line**: 255

---

### `get_step_metadata`

**Description**: Get step metadata Args: $1 = step name

**Returns**: Returns: module_file:function_name:description:enabled

**Source Line**: 269

---

### `is_step_enabled`

**Description**: Check if step is enabled Args: $1 = step name

**Returns**: Returns: 0 if enabled, 1 if disabled

**Source Line**: 293

---

### `get_step_dependencies`

**Description**: Get step dependencies Args: $1 = step name

**Returns**: Returns: comma-separated list of dependencies

**Source Line**: 301

---

### `validate_step_dependencies`

**Description**: Validate that all step dependencies exist

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 312

---

### `resolve_execution_order`

**Description**: Resolve execution order using topological sort Respects step dependencies and ensures steps run in correct order

**Returns**: Returns: 0 on success, 1 on circular dependency

**Source Line**: 355

---

### `get_execution_order`

**Description**: Get resolved execution order

**Returns**: Returns: space-separated list of step names in execution order

**Source Line**: 469

---

### `print_step_registry`

**Description**: Print step registry summary

**Source Line**: 478

---


## Module: step_validation_cache.sh

**Location**: `src/workflow/lib/step_validation_cache.sh`  
**Category**: Step Management

**Functions**: 20

### `track_step_val_cache_temp`

**Description**: Register temp file for cleanup

**Source Line**: 46

---

### `cleanup_step_val_cache_files`

**Description**: Cleanup handler for step validation cache

**Source Line**: 52

---

### `init_validation_cache`

**Description**: Initialize validation cache directory and index

**Source Line**: 65

---

### `calculate_file_hash`

**Description**: Calculate SHA256 hash of file content Args: $1 = file path

**Returns**: Returns: SHA256 hash string

**Source Line**: 102

---

### `calculate_files_hash`

**Description**: Calculate combined hash for multiple files Args: $@ = file paths

**Returns**: Returns: Combined SHA256 hash

**Source Line**: 116

---

### `calculate_directory_hash`

**Description**: Calculate directory structure hash (recursive file listing) Args: $1 = directory path

**Returns**: Returns: SHA256 hash of directory structure

**Source Line**: 131

---

### `generate_validation_cache_key`

**Description**: Generate cache key for file validation Args: $1 = step_name, $2 = validation_type, $3 = file_path

**Returns**: Returns: Cache key string

**Source Line**: 152

---

### `generate_directory_validation_key`

**Description**: Generate cache key for directory validation Args: $1 = step_name, $2 = validation_type, $3 = directory_path

**Returns**: Returns: Cache key string

**Source Line**: 167

---

### `check_validation_cache`

**Description**: Check if validation result is cached and still valid Args: $1 = cache_key, $2 = current_file_hash

**Returns**: Returns: 0 if cached and valid, 1 otherwise

**Source Line**: 183

---

### `get_validation_result`

**Description**: Get cached validation result Args: $1 = cache_key

**Returns**: Returns: Cached validation result (JSON)

**Source Line**: 232

---

### `save_validation_result`

**Description**: Save validation result to cache Args: $1 = cache_key, $2 = file_hash, $3 = validation_status (pass/fail), $4 = details (optional)

**Source Line**: 244

---

### `validate_file_cached`

**Description**: Validate file with caching Args: $1 = step_name, $2 = validation_type, $3 = file_path, $4 = validation_command

**Returns**: Returns: 0 if valid (cached or fresh), 1 if invalid

**Source Line**: 290

---

### `validate_directory_cached`

**Description**: Validate directory structure with caching Args: $1 = step_name, $2 = validation_type, $3 = directory_path, $4 = validation_command

**Returns**: Returns: 0 if valid (cached or fresh), 1 if invalid

**Source Line**: 336

---

### `batch_validate_files_cached`

**Description**: Batch validate files with caching Args: $1 = step_name, $2 = validation_type, $3 = validation_command_template, $@ = file paths

**Returns**: Returns: Count of failed validations

**Source Line**: 382

---

### `cleanup_validation_cache_old_entries`

**Description**: Cleanup old cache entries

**Source Line**: 430

---

### `invalidate_files_cache`

**Description**: Invalidate cache entries for specific files Args: $@ = file paths

**Source Line**: 467

---

### `clear_validation_cache`

**Description**: Clear entire validation cache

**Source Line**: 492

---

### `get_validation_cache_stats`

**Description**: Get validation cache statistics

**Source Line**: 505

---

### `export_validation_cache_metrics`

**Description**: Export validation cache metrics for workflow metrics

**Source Line**: 541

---

### `invalidate_changed_files_cache`

**Description**: Invalidate cache for changed files from git

**Source Line**: 564

---


## Module: step_validation_cache_integration.sh

**Location**: `src/workflow/lib/step_validation_cache_integration.sh`  
**Category**: Step Management

**Purpose**: Integration Example: Using Step Validation Cache in Workflow Steps

**Functions**: 18

### `track_step_val_int_temp`

**Description**: Register temp file for cleanup

**Source Line**: 13

---

### `cleanup_step_val_int_files`

**Description**: Cleanup handler for step validation cache integration

**Source Line**: 19

---

### `integrate_step9_with_cache`

*No documentation available*

**Source Line**: 32

---

### `integrate_step12_with_cache`

*No documentation available*

**Source Line**: 89

---

### `integrate_step4_with_cache`

*No documentation available*

**Source Line**: 117

---

### `cached_lint_file`

**Description**: Pattern 1: Simple file validation wrapper

**Source Line**: 149

---

### `cached_lint_all_files`

**Description**: Pattern 2: Batch validation wrapper

**Source Line**: 157

---

### `cached_validate_directory`

**Description**: Pattern 3: Directory validation wrapper

**Source Line**: 171

---

### `usage_example_simple`

*No documentation available*

**Source Line**: 182

---

### `usage_example_batch`

*No documentation available*

**Source Line**: 195

---

### `usage_example_invalidation`

*No documentation available*

**Source Line**: 207

---

### `pre_workflow_cache_optimization`

**Description**: TIP 1: Invalidate only changed files before workflow run

**Source Line**: 223

---

### `manual_cache_cleanup`

**Description**: TIP 2: Clear cache periodically (already automatic with TTL=24h)

**Source Line**: 229

---

### `monitor_cache_performance`

**Description**: TIP 3: Monitor cache hit rate

**Source Line**: 235

---

### `step9_original`

**Description**: BEFORE (Without Caching):

**Source Line**: 254

---

### `step9_with_cache`

**Description**: AFTER (With Caching):

**Source Line**: 261

---

### `test_step9_integration`

*No documentation available*

**Source Line**: 311

---

### `handle_cache_flags`

*No documentation available*

**Source Line**: 349

---


## Module: audio_notifications.sh

**Location**: `src/workflow/lib/audio_notifications.sh`  
**Category**: User Experience

**Functions**: 4

### `detect_audio_player`

**Description**: Detect available audio playback tools

**Returns**: Returns: 0 if audio player found, 1 otherwise Sets: AUDIO_PLAYER_CMD to the command to use

**Source Line**: 49

---

### `play_notification_sound`

**Description**: Play audio notification sound Args: $1 - notification type: "continue_prompt" or "completion"

**Returns**: Returns: 0 on success, 1 on error (non-fatal)

**Source Line**: 91

---

### `is_audio_available`

**Description**: Check if audio notifications are available

**Returns**: Returns: 0 if available, 1 otherwise

**Source Line**: 149

---

### `show_audio_config`

**Description**: Get current audio configuration status Prints configuration details to stdout

**Source Line**: 167

---


## Module: argument_parser.sh

**Location**: `src/workflow/lib/argument_parser.sh`  
**Category**: Utilities

**Functions**: 3

### `parse_workflow_arguments`

**Description**: Parse command-line arguments for workflow execution Sets global variables based on provided options Usage: parse_workflow_arguments "$@"

**Source Line**: 14

---

### `validate_parsed_arguments`

**Description**: Validate that required arguments are provided

**Returns**: Returns 0 if valid, 1 if invalid

**Source Line**: 376

---

### `show_usage`

**Description**: Display usage information

**Source Line**: 442

---


## Module: colors.sh

**Location**: `src/workflow/lib/colors.sh`  
**Category**: Utilities

**Functions**: 0

*No public functions documented*


## Module: health_check.sh

**Location**: `src/workflow/lib/health_check.sh`  
**Category**: Utilities

**Functions**: 3

### `verify_workflow_health`

**Description**: Verify all 13 steps completed successfully or identify where workflow stopped

**Returns**: Returns: 0 if healthy (all steps passed), 1 if issues found

**Source Line**: 18

---

### `validate_doc_placement`

**Description**: Validate that documentation files are placed in /docs directory

**Returns**: Returns: 0 if validation passes, 1 if issues found

**Source Line**: 141

---

### `enhanced_git_state_report`

**Description**: Enhanced git state reporting with separate coverage regeneration detection

**Returns**: Returns: 0 always (informational only)

**Source Line**: 281

---


## Module: jq_wrapper.sh

**Location**: `src/workflow/lib/jq_wrapper.sh`  
**Category**: Utilities

**Purpose**: Note: No 'set -e' in this module as it's meant to be sourced

**Functions**: 4

### `jq_safe`

**Description**: Safe wrapper for jq command with argument validation and logging Prevents "invalid JSON text passed to --argjson" errors Logs all arguments when DEBUG=true or WORKFLOW_LOG_FILE is set Usage: jq_safe [jq options and arguments...] Features: - Validates --argjson arguments are non-empty before execution - Logs all arguments for debugging when DEBUG=true - Provides clear error messages with context - Handles both -n (null input) and file input modes - Preserves all jq exit codes and behavior

**Returns**: Returns: Same exit code as jq would return 0 = success, 1+ = error

**Examples**:
```bash
jq_safe -n --arg name "test" --argjson count 5 '{name: $name, count: $count}'
jq_safe '.foo' input.json
jq_safe -r '.items[] | .name' < data.json
```

**Source Line**: 38

---

### `validate_json`

**Description**: Validate a JSON string is well-formed Args: $1 = JSON string

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 148

---

### `sanitize_argjson_value`

**Description**: Sanitize a value for use with --argjson Ensures value is a valid JSON primitive (number, boolean, or null) Args: $1 = value to sanitize, $2 = default value (optional, defaults to 0)

**Returns**: Returns: sanitized value

**Source Line**: 169

---

### `jq_wrapper_help`

**Description**: Show usage information

**Source Line**: 211

---


## Module: third_party_exclusion.sh

**Location**: `src/workflow/lib/third_party_exclusion.sh`  
**Category**: Utilities

**Purpose**: Note: set -euo pipefail removed to allow this module to be sourced in test files

**Functions**: 15

### `get_standard_exclusion_patterns`

**Description**: Get standard exclusion patterns for all languages

**Returns**: Returns: Array of directory patterns to exclude Usage: get_standard_exclusion_patterns

**Source Line**: 24

---

### `get_exclusion_array`

**Description**: Get exclusion patterns as array Usage: exclusion_patterns=($(get_exclusion_array))

**Source Line**: 55

---

### `get_find_exclusions`

**Description**: Get exclusion patterns for find command Usage: find . $(get_find_exclusions) -name "*.sh"

**Source Line**: 61

---

### `get_language_exclusions`

**Description**: Get exclusion patterns for specific language/tech stack Usage: get_language_exclusions "javascript"

**Source Line**: 78

---

### `get_tech_stack_exclusions`

**Description**: Get exclusion patterns from tech stack configuration Requires: tech_stack.sh module loaded Usage: get_tech_stack_exclusions

**Source Line**: 120

---

### `find_with_exclusions`

**Description**: Fast find with standard exclusions applied Usage: find_with_exclusions <directory> <pattern> [max_depth]

**Examples**:
```bash
```

**Source Line**: 143

---

### `grep_with_exclusions`

**Description**: Grep with standard exclusions applied Usage: grep_with_exclusions <pattern> <directory> [file_pattern]

**Examples**:
```bash
```

**Source Line**: 166

---

### `count_project_files`

**Description**: Count files excluding third-party directories Usage: count_project_files [directory] [pattern]

**Source Line**: 198

---

### `is_excluded_path`

**Description**: Check if path is in excluded directory Usage: is_excluded_path "/path/to/file"

**Returns**: Returns: 0 if excluded, 1 if not excluded

**Source Line**: 212

---

### `filter_excluded_files`

**Description**: Filter file list to remove excluded paths Usage: filter_excluded_files < file_list.txt Or: echo "/path/file" | filter_excluded_files

**Source Line**: 228

---

### `get_exclusion_summary`

**Description**: Get human-readable exclusion list for logging Usage: get_exclusion_summary

**Source Line**: 243

---

### `log_exclusions`

**Description**: Log exclusion information Usage: log_exclusions [log_file]

**Source Line**: 249

---

### `count_excluded_dirs`

**Description**: Count excluded directories in current project Usage: count_excluded_dirs [directory]

**Source Line**: 262

---

### `get_ai_exclusion_context`

**Description**: Get exclusion context for AI prompts Usage: get_ai_exclusion_context

**Source Line**: 282

---

### `fast_find_safe`

**Description**: Wrapper for backward compatibility with fast_find Usage: fast_find_safe <directory> <pattern> [max_depth] [additional_excludes...]

**Source Line**: 298

---


## Module: utils.sh

**Location**: `src/workflow/lib/utils.sh`  
**Category**: Utilities

**Functions**: 14

### `print_header`

*No documentation available*

**Source Line**: 21

---

### `print_success`

*No documentation available*

**Source Line**: 28

---

### `print_error`

*No documentation available*

**Source Line**: 32

---

### `print_warning`

*No documentation available*

**Source Line**: 36

---

### `print_info`

*No documentation available*

**Source Line**: 40

---

### `print_step`

*No documentation available*

**Source Line**: 44

---

### `print_section`

*No documentation available*

**Source Line**: 50

---

### `save_step_issues`

**Description**: Save issues found in a step to backlog Usage: save_step_issues <step_num> <step_name> <issues_content>

**Source Line**: 61

---

### `save_step_summary`

**Description**: Save step conclusion summary to summaries folder Usage: save_step_summary <step_num> <step_name> <summary_content> <status>

**Source Line**: 102

---

### `confirm_action`

**Description**: User confirmation prompt with auto-mode bypass and skip-next-step feature. Updated: v4.1.0 - Added space bar option to skip next step.

**Usage**: 
- Press **Enter**: Continue to next step normally
- Press **Space**: Skip the next workflow step
- Press **Ctrl+C**: Exit workflow

**Behavior**:
- In auto-mode: Always returns true (bypasses prompt)
- In interactive mode: Reads single character input
- Sets `SKIP_NEXT_STEP=true` flag when space is pressed
- Provides visual feedback: "⏭️ Next step will be skipped"

**Source Line**: 143

---

### `collect_ai_output`

**Description**: Collect AI-generated output from user (single-line or multi-line) Usage: collect_ai_output <prompt_message> <mode> Modes: "single" (single-line input), "multi" (multi-line with END terminator)

**Returns**: Returns: Echoes collected content or empty string if none provided

**Source Line**: 173

---

### `cleanup`

**Description**: Cleanup handler for temporary files Registered via trap in main() to ensure cleanup on EXIT/INT/TERM

**Source Line**: 207

---

### `update_workflow_status`

**Description**: Update workflow status for a step Usage: update_workflow_status <step_name> <status>

**Source Line**: 224

---

### `show_progress`

**Description**: Show overall workflow progress

**Source Line**: 231

---


## Module: version_bump.sh

**Location**: `src/workflow/lib/version_bump.sh`  
**Category**: Utilities

**Purpose**: ###############################################################################

**Functions**: 8

### `detect_version_tool`

**Description**: Detect project type and available version management tools

**Returns**: Returns: package_manager (npm|yarn|poetry|cargo|go|manual)

**Source Line**: 22

---

### `get_current_version`

**Description**: Get current project version Args: $1 - project root path

**Returns**: Returns: current version string

**Source Line**: 65

---

### `bump_version_with_tool`

**Description**: Bump version using appropriate tool Args: $1 - bump type (major|minor|patch|premajor|preminor|prepatch|prerelease) $2 - project root path $3 - pre-release identifier (optional, e.g., "alpha", "beta")

**Returns**: Returns: 0 on success, 1 on failure

**Source Line**: 115

---

### `calculate_new_version`

**Description**: Calculate new version from current version and bump type Args: $1 - current version $2 - bump type (major|minor|patch) $3 - prerelease identifier (optional)

**Returns**: Returns: new version string

**Source Line**: 178

---

### `manual_version_update`

**Description**: Manually update version in common files Args: $1 - project root $2 - old version $3 - new version

**Source Line**: 224

---

### `commit_version_bump`

**Description**: Commit version bump changes Args: $1 - new version $2 - project root

**Returns**: Returns: 0 on success

**Source Line**: 268

---

### `automated_version_bump`

**Description**: Main function: Automated version bump workflow Args: $1 - bump type (major|minor|patch|auto) $2 - project root path $3 - auto commit (true|false) $4 - prerelease identifier (optional)

**Returns**: Returns: 0 on success

**Source Line**: 306

---

### `determine_bump_type_from_git`

**Description**: Determine bump type from git changes (heuristic) Args: $1 - project root

**Returns**: Returns: major|minor|patch

**Source Line**: 365

---


## Module: api_coverage.sh

**Location**: `src/workflow/lib/api_coverage.sh`  
**Category**: Validation & Testing

**Functions**: 14

### `init_api_coverage`

**Description**: Initialize API coverage system

**Source Line**: 28

---

### `extract_bash_functions`

**Description**: Extract public functions from Bash scripts Args: $1 = file path Output: Function names, one per line

**Source Line**: 48

---

### `extract_python_functions`

**Description**: Extract public functions from Python files Args: $1 = file path Output: Function/method names, one per line

**Source Line**: 65

---

### `extract_javascript_functions`

**Description**: Extract public functions from JavaScript/TypeScript files Args: $1 = file path Output: Function names, one per line

**Source Line**: 80

---

### `extract_go_functions`

**Description**: Extract public methods from Go files Args: $1 = file path Output: Function names, one per line

**Source Line**: 105

---

### `extract_java_methods`

**Description**: Extract public methods from Java files Args: $1 = file path Output: Method names, one per line

**Source Line**: 118

---

### `extract_source_apis`

**Description**: Extract APIs from source files based on language Args: $1 = file path, $2 = language (optional, auto-detected) Output: API names, one per line

**Source Line**: 132

---

### `extract_documented_apis_markdown`

**Description**: Extract documented APIs from markdown files Args: $1 = file path Output: API names, one per line

**Source Line**: 182

---

### `extract_documented_apis_jsdoc`

**Description**: Extract documented APIs from JSDoc comments in JavaScript/TypeScript Args: $1 = file path Output: API names, one per line

**Source Line**: 205

---

### `extract_documented_apis_python`

**Description**: Extract documented APIs from Python docstrings Args: $1 = file path Output: API names, one per line

**Source Line**: 220

---

### `extract_documented_apis_go`

**Description**: Extract documented APIs from Go comments Args: $1 = file path Output: API names, one per line

**Source Line**: 241

---

### `analyze_file_api_coverage`

**Description**: Analyze API coverage for a single file Args: $1 = source file, $2 = docs directory, $3 = output file

**Returns**: Returns: Count of undocumented APIs

**Source Line**: 266

---

### `analyze_project_api_coverage`

**Description**: Analyze API coverage for all source files Args: $1 = source directory, $2 = docs directory, $3 = output report file

**Returns**: Returns: Total count of undocumented APIs

**Source Line**: 334

---

### `generate_api_coverage_summary`

**Description**: Generate API coverage summary report Args: $1 = report file, $2 = output summary file, $3 = total APIs, $4 = undocumented APIs

**Source Line**: 426

---


## Module: code_example_tester.sh

**Location**: `src/workflow/lib/code_example_tester.sh`  
**Category**: Validation & Testing

**Functions**: 18

### `init_code_example_tester`

**Description**: Initialize code example testing system

**Source Line**: 48

---

### `cleanup_code_examples`

**Description**: Cleanup temporary files

**Source Line**: 59

---

### `extract_code_blocks`

**Description**: Extract code blocks from markdown file Args: $1 = file path Output: Format "line_number|language|code_block_content"

**Source Line**: 71

---

### `extract_inline_code`

**Description**: Extract inline code from markdown (single backticks) Args: $1 = file path Output: Format "line_number|inline_code"

**Source Line**: 129

---

### `validate_bash_code`

**Description**: Validate Bash code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 155

---

### `validate_python_code`

**Description**: Validate Python code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 172

---

### `validate_javascript_code`

**Description**: Validate JavaScript code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 200

---

### `validate_typescript_code`

**Description**: Validate TypeScript code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 223

---

### `validate_go_code`

**Description**: Validate Go code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 246

---

### `validate_java_code`

**Description**: Validate Java code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 269

---

### `validate_c_code`

**Description**: Validate C code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 294

---

### `validate_cpp_code`

**Description**: Validate C++ code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 317

---

### `validate_ruby_code`

**Description**: Validate Ruby code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 340

---

### `validate_php_code`

**Description**: Validate PHP code Args: $1 = code content, $2 = temp file path

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 363

---

### `validate_code_block`

**Description**: Validate a single code block Args: $1 = language, $2 = code content (base64 encoded), $3 = source file, $4 = line number

**Returns**: Returns: 0 if valid, 1 if errors

**Source Line**: 390

---

### `validate_file_code_examples`

**Description**: Validate all code examples in a file Args: $1 = file path, $2 = report file

**Returns**: Returns: Count of validation errors

**Source Line**: 435

---

### `validate_all_code_examples`

**Description**: Validate code examples in all documentation files Args: $1 = output report file, $2 = directory to scan (default: current)

**Returns**: Returns: Total count of validation errors

**Source Line**: 459

---

### `generate_code_validation_summary`

**Description**: Generate code example validation summary Args: $1 = report file, $2 = output summary file

**Source Line**: 496

---


## Module: deployment_validator.sh

**Location**: `src/workflow/lib/deployment_validator.sh`  
**Category**: Validation & Testing

**Functions**: 15

### `init_deployment_validator`

**Description**: Initialize deployment validator

**Source Line**: 33

---

### `check_required_env_vars`

**Description**: Check if required environment variables are set Args: $@ = list of required environment variable names

**Returns**: Returns: Count of missing variables

**Source Line**: 53

---

### `load_env_file`

**Description**: Load environment variables from file Args: $1 = env file path (e.g., .env)

**Returns**: Returns: Count of loaded variables

**Source Line**: 76

---

### `validate_environment_config`

**Description**: Validate environment configuration Args: $1 = environment name (dev, staging, production)

**Source Line**: 100

---

### `validate_node_dependencies`

**Description**: Check Node.js dependencies

**Returns**: Returns: 0 if valid, 1 if issues found

**Source Line**: 163

---

### `validate_python_dependencies`

**Description**: Check Python dependencies

**Returns**: Returns: 0 if valid, 1 if issues found

**Source Line**: 205

---

### `validate_dependencies`

**Description**: Validate dependencies based on tech stack

**Returns**: Returns: 0 if valid, 1 if issues found

**Source Line**: 255

---

### `validate_json_config`

**Description**: Validate JSON configuration file Args: $1 = file path

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 299

---

### `validate_yaml_config`

**Description**: Validate YAML configuration file Args: $1 = file path

**Returns**: Returns: 0 if valid, 1 if invalid

**Source Line**: 321

---

### `validate_config_files`

**Description**: Validate all configuration files

**Returns**: Returns: Count of invalid config files

**Source Line**: 350

---

### `validate_build_artifacts`

**Description**: Validate build artifacts exist

**Returns**: Returns: 0 if valid, 1 if missing artifacts

**Source Line**: 374

---

### `check_port_available`

**Description**: Check port availability Args: $1 = port number

**Returns**: Returns: 0 if available, 1 if in use

**Source Line**: 420

---

### `check_database_connection`

**Description**: Check database connection Args: $1 = database URL (optional, uses DATABASE_URL env var)

**Returns**: Returns: 0 if connected, 1 if failed

**Source Line**: 448

---

### `check_for_secrets`

**Description**: Check for secrets in code

**Returns**: Returns: Count of potential secrets found

**Source Line**: 488

---

### `run_deployment_validation`

**Description**: Run complete deployment validation Args: $1 = environment name (optional, default: production)

**Returns**: Returns: 0 if ready, 1 if issues found

**Source Line**: 529

---


## Module: enhanced_validations.sh

**Location**: `src/workflow/lib/enhanced_validations.sh`  
**Category**: Validation & Testing

**Functions**: 5

### `validate_pre_commit_lint`

**Description**: Check if npm run lint is available and execute it

**Returns**: Returns: 0 if linting passes or not available, 1 if linting fails

**Source Line**: 18

---

### `validate_changelog`

**Description**: Verify CHANGELOG.md is updated for version changes

**Returns**: Returns: 0 if valid or not applicable, 1 if validation fails

**Source Line**: 61

---

### `validate_cdn_readiness`

**Description**: Validate cdn-urls.txt matches package.json version

**Returns**: Returns: 0 if valid or not applicable, 1 if validation fails

**Source Line**: 119

---

### `validate_metrics_health`

**Description**: Ensure history.jsonl receives data from workflow execution

**Returns**: Returns: 0 if valid, 1 if validation fails Mitigation Strategy: Validates history.jsonl has content (test -s)

**Source Line**: 178

---

### `run_enhanced_validations`

**Description**: Run all enhanced validations Usage: run_enhanced_validations [--strict]

**Returns**: Returns: 0 if all pass or non-strict, 1 if any fail in strict mode

**Source Line**: 282

---


## Module: metrics_validation.sh

**Location**: `src/workflow/lib/metrics_validation.sh`  
**Category**: Validation & Testing

**Functions**: 11

### `metrics_print_info`

**Description**: Print functions compatible with workflow or standalone use

**Source Line**: 22

---

### `metrics_print_success`

*No documentation available*

**Source Line**: 30

---

### `metrics_print_warning`

*No documentation available*

**Source Line**: 38

---

### `metrics_print_error`

*No documentation available*

**Source Line**: 46

---

### `metrics_print_header`

*No documentation available*

**Source Line**: 54

---

### `calculate_workflow_metrics`

**Description**: Calculate actual line counts for workflow modules

**Returns**: Returns: Sets global variables with actual counts

**Source Line**: 72

---

### `format_number`

**Description**: Format number with thousands separator (e.g., 6993 → 6,993)

**Source Line**: 106

---

### `validate_doc_metrics`

**Description**: Validate line count references in a documentation file Arguments: $1 - file path, $2 - expected total lines, $3 - expected lib lines, $4 - expected step lines

**Returns**: Returns: 0 if valid, 1 if inconsistencies found

**Source Line**: 118

---

### `validate_module_counts`

**Description**: Validate module count references in a documentation file Arguments: $1 - file path, $2 - expected total modules, $3 - expected lib count, $4 - expected step count

**Returns**: Returns: 0 if valid, 1 if inconsistencies found

**Source Line**: 171

---

### `validate_all_documentation_metrics`

**Description**: Run comprehensive metrics validation across all documentation

**Returns**: Returns: 0 if all valid, 1 if inconsistencies found

**Source Line**: 209

---

### `generate_metrics_report`

**Description**: Generate metrics report for documentation

**Returns**: Returns: Formatted metrics report string

**Source Line**: 271

---


## Module: validation.sh

**Location**: `src/workflow/lib/validation.sh`  
**Category**: Validation & Testing

**Functions**: 3

### `detect_project_tech_stack`

*No documentation available*

**Source Line**: 14

---

### `check_prerequisites`

*No documentation available*

**Source Line**: 65

---

### `validate_dependencies`

*No documentation available*

**Source Line**: 214

---


