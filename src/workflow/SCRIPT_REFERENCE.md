# AI Workflow Automation - Script Reference

**Version:** 4.0.1  
**Last Updated:** 2026-02-09  
**Total Scripts:** 180+ (81 library modules + 79 step modules + 4 orchestrators + utilities)

> 📋 **Companion Document**: See [docs/PROJECT_REFERENCE.md](../../docs/PROJECT_REFERENCE.md) for project statistics, features, and version history.

---

## Table of Contents

1. [Entry Points](#entry-points)
2. [Library Modules (81)](#library-modules-81)
3. [Step Modules (79)](#step-modules-79)
4. [Orchestrators (4)](#orchestrators-4)
5. [Utility Scripts](#utility-scripts)
6. [Quick Reference](#quick-reference)

---

## Entry Points

### Main Orchestrator

#### `execute_tests_docs_workflow.sh` (2,009 lines)
**Purpose:** Primary workflow orchestrator - coordinates all workflow execution  
**Location:** `src/workflow/`  
**Usage:**
```bash
./src/workflow/execute_tests_docs_workflow.sh [OPTIONS]
```

**Key Responsibilities:**
- Command-line argument parsing (20+ options)
- Pre-flight validation and setup
- 23-step workflow coordination
- Metrics collection and reporting
- Checkpoint management and resume
- Parallel and smart execution orchestration
- AI integration and caching

**Common Options:**
- `--smart-execution` - Skip unnecessary steps (40-85% faster)
- `--parallel` - Run independent steps simultaneously (33% faster)
- `--auto` - Accept all prompts automatically
- `--target PATH` - Run on different project
- `--steps N,M,...` - Execute specific steps (supports names or indices)
- `--dry-run` - Preview execution without changes
- `--ml-optimize` - Enable ML-driven optimization (v2.7.0)
- `--multi-stage` - Enable progressive 3-stage pipeline (v2.8.0)
- `--auto-commit` - Automatically commit workflow artifacts (v2.6.0)
- `--generate-docs` - Auto-generate documentation reports (v2.9.0)
- `--install-hooks` - Install pre-commit hooks (v3.0.0)

**See:** [Command Reference](#command-reference) for complete options

---

### Workflow Templates (NEW v2.6.0)

Pre-configured workflow scripts for common use cases.

#### `templates/workflows/docs-only.sh`
**Purpose:** Documentation-only workflow (fastest)  
**Duration:** 3-4 minutes  
**Skips:** Test review, generation, and execution  
**Use Case:** Quick documentation updates and validation

#### `templates/workflows/test-only.sh`
**Purpose:** Test development workflow  
**Duration:** 8-10 minutes  
**Skips:** Most documentation steps  
**Use Case:** TDD workflow, test development and validation

#### `templates/workflows/feature.sh`
**Purpose:** Full feature development workflow  
**Duration:** 15-20 minutes  
**Includes:** All steps for complete validation  
**Use Case:** New features, comprehensive validation

---

## Library Modules (81)

Library modules provide reusable functionality across the workflow. Located in `src/workflow/lib/`.

### Core Modules (12)

Critical modules that form the workflow foundation.

#### `ai_helpers.sh` (102K, 17 AI personas)
**Purpose:** AI integration with GitHub Copilot CLI  
**Key Functions:**
- `ai_call(persona, prompt, output_file)` - Execute AI requests
- `check_copilot_available()` - Verify Copilot CLI availability
- `build_ai_prompt(persona, context)` - Construct prompts dynamically

**AI Personas (17 total):**
1. documentation_specialist - Documentation updates (context-aware)
2. consistency_analyst - Cross-reference validation
3. code_reviewer - Code quality review
4. test_engineer - Test coverage and generation
5. technical_writer - Bootstrap documentation (v3.1.0)
6. front_end_developer - Front-end implementation (v4.0.1) ⭐ NEW
7. ui_ux_designer - UI/UX design and usability (v4.0.1) ⭐ UPDATED
8. test_strategy - Test strategy planning
9. quality_analyst - Code quality validation
10. issue_extractor - Issue identification
11. markdown_linter - Markdown validation
12. configuration_specialist - Configuration validation
13. version_manager - Version management
14. prompt_engineer - Prompt optimization
15. dependency_analyst - Dependency analysis
16. git_specialist - Git operations
17. performance_analyst - Performance optimization

**Configuration:**
- Base prompts: `.workflow_core/config/ai_helpers.yaml`
- Project-specific: `.workflow_core/config/ai_prompts_project_kinds.yaml`
- Language enhancements: Automatic when PRIMARY_LANGUAGE set

#### `tech_stack.sh` (47K)
**Purpose:** Technology stack detection and configuration  
**Key Functions:**
- `detect_tech_stack()` - Auto-detect project technologies
- `get_test_command()` - Determine appropriate test runner
- `validate_tech_stack_config()` - Validate configuration

**Supports:**
- Node.js (Jest, Mocha, Vitest)
- Python (pytest, unittest)
- Bash (BATS, shunit2)
- Ruby, Go, Rust, Java
- Static site generators (Jekyll, Hugo, Gatsby)

#### `workflow_optimization.sh` (31K)
**Purpose:** Smart execution and parallel processing  
**Key Functions:**
- `analyze_changes_for_optimization()` - Determine skippable steps
- `execute_parallel_group(steps)` - Run steps concurrently
- `should_skip_step(step_num)` - Smart execution logic

**Optimization Types:**
- Smart execution (change-based skipping)
- Parallel execution (6 parallel groups)
- ML-based optimization (v2.7.0)
- Multi-stage pipeline (v2.8.0)

#### `project_kind_config.sh` (26K)
**Purpose:** Project type configuration and adaptation  
**Key Functions:**
- `load_project_kind_config(kind)` - Load project-specific config
- `get_project_kind_prompts(kind, persona)` - Get AI prompts
- `validate_project_kind(kind)` - Validate project type

**Supported Project Kinds:**
- shell_automation, nodejs_api, nodejs_cli, nodejs_library
- static_website, client_spa, react_spa, vue_spa
- python_api, python_cli, python_library
- documentation, generic

#### `change_detection.sh` (17K)
**Purpose:** Git diff analysis and change classification  
**Key Functions:**
- `analyze_git_changes()` - Analyze uncommitted changes
- `detect_change_types()` - Classify changes (docs/code/config)
- `get_changed_files()` - List modified files

**Change Types:**
- Documentation changes
- Code changes
- Configuration changes
- Test changes

#### `metrics.sh` (16K)
**Purpose:** Performance tracking and reporting  
**Key Functions:**
- `init_metrics()` - Initialize metrics collection
- `record_step_start(step)` - Start step timer
- `record_step_end(step, status)` - Record completion
- `finalize_metrics()` - Generate summary report

**Metrics Tracked:**
- Step duration and status
- AI cache hit/miss rates
- Smart execution savings
- Historical trends (JSONL format)

#### `performance.sh` (16K)
**Purpose:** Performance optimization utilities  
**Key Functions:**
- `start_timer()` - Begin timing operation
- `end_timer()` - Stop timer and calculate duration
- `format_duration()` - Human-readable time formatting

#### `step_adaptation.sh` (16K)
**Purpose:** Dynamic step behavior based on project kind  
**Key Functions:**
- `adapt_step_for_project(step, kind)` - Customize step execution
- `should_skip_step_for_kind(step, kind)` - Kind-based skipping
- `get_step_requirements(step, kind)` - Get step prerequisites

#### `config_wizard.sh` (16K)
**Purpose:** Interactive configuration setup  
**Key Functions:**
- `run_config_wizard()` - Interactive `.workflow-config.yaml` setup
- `detect_and_configure()` - Auto-detect and configure tech stack
- `validate_config()` - Validate configuration file

#### `dependency_graph.sh` (15K)
**Purpose:** Execution dependency visualization  
**Key Functions:**
- `generate_dependency_graph()` - Create Mermaid diagram
- `get_step_dependencies(step)` - List step dependencies
- `validate_dependency_order()` - Verify execution order

#### `health_check.sh` (15K)
**Purpose:** System and prerequisite validation  
**Key Functions:**
- `check_prerequisites()` - Verify required tools
- `validate_environment()` - Check environment setup
- `check_git_status()` - Validate git repository

#### `file_operations.sh` (15K)
**Purpose:** Safe and atomic file operations  
**Key Functions:**
- `safe_write()` - Atomic file writing
- `backup_file()` - Create file backup
- `restore_file()` - Restore from backup

---

### Supporting Modules (69)

Additional modules providing specialized functionality.

#### AI Integration (7 modules)

##### `ai_cache.sh` (11K)
**Purpose:** AI response caching system (v2.3.0)  
**Key Functions:**
- `cache_ai_response(key, response)` - Store AI response
- `get_cached_response(key)` - Retrieve cached response
- `cleanup_expired_cache()` - Remove stale entries

**Features:**
- 24-hour TTL
- SHA256 cache keys
- Automatic cleanup
- 60-80% token reduction

##### `ai_personas.sh` (7.0K)
**Purpose:** AI persona management  
**Key Functions:**
- `get_persona_prompt(persona)` - Get persona template
- `list_available_personas()` - List all personas
- `validate_persona(persona)` - Check persona exists

##### `ai_prompt_builder.sh` (8.4K)
**Purpose:** Dynamic AI prompt construction  
**Key Functions:**
- `build_prompt(template, context)` - Construct prompt from template
- `add_context(prompt, data)` - Add contextual information
- `validate_prompt(prompt)` - Validate prompt structure

##### `ai_validation.sh` (3.6K)
**Purpose:** AI integration validation  
**Key Functions:**
- `validate_copilot_auth()` - Check Copilot authentication
- `validate_ai_response(response)` - Validate AI output
- `check_ai_errors(output)` - Detect AI errors

##### `third_party_exclusion.sh` (11K)
**Purpose:** Filter third-party files from workflow  
**Key Functions:**
- `is_third_party_file(path)` - Check if file is third-party
- `filter_project_files(files)` - Remove third-party files
- `load_exclusion_patterns()` - Load .gitignore-style patterns

##### `model_selector.sh`
**Purpose:** AI model selection and routing  
**Key Functions:**
- `select_best_model(task)` - Choose optimal AI model
- `get_model_capabilities(model)` - Query model features

##### `ai_prompt_templates.sh`
**Purpose:** Reusable AI prompt templates  
**Key Functions:**
- `load_template(name)` - Load prompt template
- `interpolate_template(template, vars)` - Fill template variables

#### Session & Process Management (4 modules)

##### `session_manager.sh` (12K)
**Purpose:** Bash session and process management  
**Key Functions:**
- `create_session(name)` - Create new Bash session
- `send_to_session(id, command)` - Send commands to session
- `cleanup_session(id)` - Terminate session

##### `cleanup_handlers.sh` (5.0K)
**Purpose:** Error handling and cleanup patterns  
**Key Functions:**
- `register_cleanup(function)` - Register cleanup handler
- `cleanup_on_exit()` - Execute all cleanup handlers
- `trap_errors()` - Set up error traps

##### `git_automation.sh`
**Purpose:** Automated git operations  
**Key Functions:**
- `auto_stage_files(pattern)` - Stage files automatically
- `generate_commit_message(changes)` - AI-generated messages
- `auto_commit(files)` - Automatic commit workflow

##### `git_submodule_helpers.sh`
**Purpose:** Git submodule operations  
**Key Functions:**
- `update_submodule(path)` - Update specific submodule
- `sync_submodules()` - Synchronize all submodules

#### Caching & Optimization (7 modules)

##### `git_cache.sh` (6.8K)
**Purpose:** Git state caching for performance  
**Key Functions:**
- `cache_git_status()` - Cache git status output
- `get_cached_diff()` - Retrieve cached diff
- `invalidate_git_cache()` - Clear cache

##### `dependency_cache.sh`
**Purpose:** Dependency resolution caching  
**Key Functions:**
- `cache_dependencies(step)` - Cache step dependencies
- `get_cached_dependencies(step)` - Retrieve dependencies

##### `step_validation_cache.sh`
**Purpose:** Validation result caching  
**Key Functions:**
- `cache_validation(step, result)` - Cache validation result
- `get_cached_validation(step)` - Retrieve cached result

##### `step_validation_cache_integration.sh`
**Purpose:** Integration layer for validation caching  
**Key Functions:**
- `integrate_cache(step)` - Enable caching for step

##### `analysis_cache.sh`
**Purpose:** Analysis result caching  
**Key Functions:**
- `cache_analysis(type, result)` - Cache analysis results
- `get_cached_analysis(type)` - Retrieve analysis

##### `incremental_analysis.sh`
**Purpose:** Incremental file analysis  
**Key Functions:**
- `analyze_changed_files()` - Analyze only changed files
- `get_file_hash(path)` - Generate file hash for comparison

##### `skip_predictor.sh`
**Purpose:** ML-based step skip prediction  
**Key Functions:**
- `predict_skip(step, context)` - Predict if step can be skipped
- `train_predictor(history)` - Update prediction model

#### Configuration & Validation (10 modules)

##### `config.sh` (2.1K)
**Purpose:** Central configuration and constants  
**Key Exports:**
- `PROJECT_ROOT`, `SRC_DIR`, `DOCS_DIR`
- `WORKFLOW_RUN_ID`, `BACKLOG_DIR`, `LOGS_DIR`
- `TOTAL_STEPS`, `DRY_RUN`, `AUTO_MODE`

##### `argument_parser.sh` (9.7K)
**Purpose:** CLI argument parsing  
**Key Functions:**
- `parse_arguments(args)` - Parse command-line arguments
- `validate_arguments()` - Validate argument combinations
- `show_help()` - Display usage information

##### `validation.sh` (9.7K)
**Purpose:** Input and precondition validation  
**Key Functions:**
- `validate_directory(path)` - Validate directory exists
- `validate_file(path)` - Validate file exists
- `validate_tool(name)` - Check required tool installed

##### `enhanced_validations.sh`
**Purpose:** Advanced validation patterns  
**Key Functions:**
- `validate_workflow_state()` - Check workflow prerequisites
- `validate_project_structure()` - Verify project layout

##### `metrics_validation.sh` (11K)
**Purpose:** Metrics data validation  
**Key Functions:**
- `validate_metrics_file(path)` - Validate metrics JSON
- `check_metrics_integrity()` - Verify metrics consistency

##### `doc_template_validator.sh` (13K)
**Purpose:** Documentation template validation  
**Key Functions:**
- `validate_template(path)` - Check template structure
- `check_template_vars(template)` - Verify template variables

##### `link_validator.sh`
**Purpose:** Documentation link validation  
**Key Functions:**
- `validate_links(file)` - Check all links in file
- `check_internal_links()` - Verify internal references

##### `project_kind_detection.sh` (14K)
**Purpose:** Auto-detect project type  
**Key Functions:**
- `detect_project_kind()` - Identify project type
- `analyze_project_structure()` - Examine project files

##### `jq_wrapper.sh`
**Purpose:** JSON processing utilities  
**Key Functions:**
- `jq_safe(query, file)` - Safe jq execution with error handling
- `jq_update(file, query)` - Update JSON file

##### `deployment_validator.sh`
**Purpose:** Deployment readiness validation  
**Key Functions:**
- `check_deployment_requirements()` - Verify deployment prerequisites
- `validate_build_artifacts()` - Check build outputs

#### Step Management (8 modules)

##### `step_execution.sh` (9.2K)
**Purpose:** Step lifecycle management  
**Key Functions:**
- `execute_step(number)` - Execute workflow step
- `validate_step_result(step)` - Check step completion
- `record_step_checkpoint(step)` - Save checkpoint

##### `step_loader.sh`
**Purpose:** Dynamic step loading  
**Key Functions:**
- `load_step(name)` - Load step module
- `get_step_path(name)` - Resolve step file path

##### `step_metadata.sh`
**Purpose:** Step metadata management  
**Key Functions:**
- `get_step_info(step)` - Retrieve step metadata
- `list_all_steps()` - Get all available steps

##### `step_registry.sh`
**Purpose:** Step registration and discovery  
**Key Functions:**
- `register_step(name, config)` - Register new step
- `find_step(criteria)` - Search for steps

##### `conditional_execution.sh`
**Purpose:** Conditional step execution logic  
**Key Functions:**
- `should_execute(step, context)` - Determine if step should run
- `evaluate_conditions(step)` - Evaluate execution conditions

##### `workflow_profiles.sh`
**Purpose:** Predefined workflow configurations  
**Key Functions:**
- `load_profile(name)` - Load workflow profile (docs-only, test-only, feature)
- `apply_profile(profile)` - Apply profile settings

##### `edit_operations.sh` (14K)
**Purpose:** Advanced file editing operations  
**Key Functions:**
- `batch_edit(files, pattern, replacement)` - Edit multiple files
- `atomic_edit(file, operation)` - Safe file editing

##### `batch_ai_commit.sh`
**Purpose:** Batch AI commit operations  
**Key Functions:**
- `commit_with_ai_message(files)` - Generate and commit with AI message
- `batch_commit_changes(groups)` - Commit in logical groups

#### Reporting & Documentation (6 modules)

##### `backlog.sh` (2.7K)
**Purpose:** Execution history tracking  
**Key Functions:**
- `create_backlog_entry(step, data)` - Record step execution
- `get_backlog_history()` - Retrieve historical data

##### `summary.sh` (3.8K)
**Purpose:** Summary report generation  
**Key Functions:**
- `generate_summary()` - Create workflow summary
- `format_results(data)` - Format execution results

##### `auto_documentation.sh`
**Purpose:** Automatic documentation generation (v2.9.0)  
**Key Functions:**
- `generate_docs_from_workflow()` - Extract workflow reports
- `update_docs_directory()` - Update documentation

##### `changelog_generator.sh`
**Purpose:** Automatic CHANGELOG generation (v2.9.0)  
**Key Functions:**
- `parse_conventional_commits()` - Parse commit messages
- `generate_changelog_entry()` - Create CHANGELOG entry

##### `api_coverage.sh`
**Purpose:** API documentation coverage analysis  
**Key Functions:**
- `analyze_api_coverage()` - Check API documentation completeness
- `list_undocumented_apis()` - Find missing API docs

##### `doc_section_extractor.sh`
**Purpose:** Documentation section extraction  
**Key Functions:**
- `extract_section(file, heading)` - Extract section by heading
- `get_all_sections(file)` - List all sections

#### Advanced Features (11 modules)

##### `ml_optimization.sh`
**Purpose:** ML-driven workflow optimization (v2.7.0)  
**Key Functions:**
- `predict_step_duration(step, context)` - Predict execution time
- `train_model(historical_data)` - Update ML model
- `optimize_execution_order()` - ML-based step ordering

**Requirements:** 10+ historical workflow runs

##### `multi_stage_pipeline.sh`
**Purpose:** Progressive 3-stage validation (v2.8.0)  
**Key Functions:**
- `determine_stage()` - Identify current stage
- `should_proceed_to_next_stage()` - Stage progression logic
- `execute_stage(num)` - Execute specific stage

**Stages:**
1. Core validation (Steps 0-4)
2. Extended validation (Steps 5-10)
3. Finalization (Steps 11-16)

##### `precommit_hooks.sh`
**Purpose:** Pre-commit hook installation and execution (v3.0.0)  
**Key Functions:**
- `install_hooks()` - Install pre-commit hooks
- `run_precommit_validation()` - Fast validation checks (&lt; 1 second)

##### `auto_commit.sh`
**Purpose:** Automatic artifact commit workflow (v2.6.0)  
**Key Functions:**
- `detect_artifacts()` - Find workflow-generated files
- `generate_commit_message()` - AI-generated commit messages
- `auto_commit_workflow()` - Automatic commit execution

##### `audio_notifications.sh`
**Purpose:** Audio notifications for workflow events (v3.1.0)  
**Key Functions:**
- `play_notification(event)` - Play sound for event
- `notify_completion()` - Completion notification
- `notify_prompt()` - Prompt notification

##### `performance_monitoring.sh`
**Purpose:** Real-time performance monitoring  
**Key Functions:**
- `monitor_step_performance()` - Track step metrics
- `detect_performance_issues()` - Identify bottlenecks

##### `dashboard.sh`
**Purpose:** Interactive metrics dashboard  
**Key Functions:**
- `show_dashboard()` - Display metrics dashboard
- `update_dashboard(data)` - Update display

##### `version_bump.sh`
**Purpose:** Semantic version management  
**Key Functions:**
- `bump_version(type)` - Increment version (major/minor/patch)
- `validate_version(version)` - Check version format

##### `docs_only_optimization.sh`
**Purpose:** Documentation-only workflow optimization  
**Key Functions:**
- `optimize_docs_workflow()` - Apply docs-only optimizations
- `skip_non_doc_steps()` - Skip irrelevant steps

##### `code_changes_optimization.sh`
**Purpose:** Code-focused workflow optimization  
**Key Functions:**
- `optimize_code_workflow()` - Apply code-change optimizations
- `prioritize_code_steps()` - Order steps for code changes

##### `full_changes_optimization.sh`
**Purpose:** Full-change workflow optimization  
**Key Functions:**
- `optimize_full_workflow()` - Apply comprehensive optimizations
- `balance_execution()` - Balance resource usage

#### Utilities (6 modules)

##### `utils.sh` (6.9K)
**Purpose:** Common utility functions  
**Key Functions:**
- `log(level, message)` - Logging with levels
- `error(message, code)` - Error reporting
- `confirm(prompt)` - User confirmation

##### `colors.sh` (637 bytes)
**Purpose:** ANSI color code definitions  
**Exports:**
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `MAGENTA`, `NC`

##### `doc_section_mapper.sh`
**Purpose:** Documentation section mapping and navigation  
**Key Functions:**
- `map_sections(file)` - Create section map
- `navigate_to_section(section)` - Jump to section

##### `code_example_tester.sh`
**Purpose:** Test code examples in documentation  
**Key Functions:**
- `extract_code_examples(file)` - Find code blocks
- `test_example(code)` - Execute and validate example

##### `function_documentation.sh` (in scripts/)
**Purpose:** Extract function documentation from scripts  
**Key Functions:**
- `extract_function_docs(file)` - Parse function comments
- `generate_api_docs()` - Create API documentation

##### `test_broken_reference_analysis.sh` (2.4K)
**Purpose:** Analyze and validate documentation cross-references  
**Key Functions:**
- `find_broken_references(dir)` - Find broken links
- `analyze_reference_patterns()` - Pattern analysis

---

### Test Modules (13 modules)

Test infrastructure ensuring 100% functionality.

#### `test_ai_cache.sh` (466 lines)
**Purpose:** AI cache system tests  
**Coverage:** Caching, TTL, cleanup, hit/miss tracking

#### `test_workflow_optimization.sh` (420 lines)
**Purpose:** Optimization feature tests  
**Coverage:** Smart execution, parallel execution, ML optimization

#### `test_project_kind_integration.sh` (431 lines)
**Purpose:** Project kind integration tests  
**Coverage:** End-to-end project kind detection and configuration

#### `test_step_adaptation.sh` (406 lines)
**Purpose:** Step adaptation tests  
**Coverage:** Dynamic step behavior, project-specific adaptation

#### `test_project_kind_config.sh` (404 lines)
**Purpose:** Project kind configuration tests  
**Coverage:** Configuration loading, validation, defaults

#### `test_project_kind_detection.sh` (403 lines)
**Purpose:** Project kind detection tests  
**Coverage:** Auto-detection algorithms, file pattern matching

#### `test_project_kind_validation.sh` (375 lines)
**Purpose:** Project kind validation tests  
**Coverage:** Configuration validation, error handling

#### `test_tech_stack_phase3.sh` (361 lines)
**Purpose:** Tech stack detection tests  
**Coverage:** Multi-language detection, test command resolution

#### `test_phase5_enhancements.sh` (341 lines)
**Purpose:** Phase 5 enhancement tests  
**Coverage:** Latest features and improvements

#### `test_phase5_final_steps.sh` (318 lines)
**Purpose:** Phase 5 final validation tests  
**Coverage:** Complete Phase 5 functionality

#### `test_project_kind_prompts.sh` (313 lines)
**Purpose:** AI prompt customization tests  
**Coverage:** Project-kind specific prompts

#### `test_get_project_kind.sh` (272 lines)
**Purpose:** Project kind getter tests  
**Coverage:** API function validation

#### `test_ai_helpers_phase4.sh` (412 lines)
**Purpose:** AI helpers Phase 4 tests  
**Coverage:** AI integration, persona management

#### Additional Test Modules:
- `test_atomic_staging.sh` - Atomic git staging tests
- `test_batch_ai_commit.sh` - Batch AI commit tests
- `test_cache_simple.sh` - Simple cache tests
- `test_code_changes_optimization.sh` - Code optimization tests
- `test_docs_only_optimization.sh` - Docs optimization tests
- `test_documentation_enhancements.sh` - Documentation feature tests
- `test_jq_wrapper.sh` - JSON processing tests
- `test_minimal.sh` - Minimal test suite
- `test_skip_predictor.sh` - Skip prediction tests
- `test_smoke.sh` - Smoke tests
- `test_step_validation_cache.sh` - Validation cache tests
- `test_validation.sh` - Validation module tests

---

## Step Modules (79)

Step modules implement individual workflow steps. Located in `src/workflow/steps/`.

### Configuration-Driven Steps (NEW v4.0.0)

Modern descriptive filenames (recommended):

#### `pre_analysis.sh` (Step 0)
**Purpose:** Pre-workflow change analysis  
**Execution:** Always runs first  
**Functions:**
- Analyzes git changes and uncommitted modifications
- Determines change scope (docs/code/config)
- Generates change summary report
- Provides smart execution recommendations

**Output:** `CHANGE_ANALYSIS.md` in backlog directory

#### `bootstrap_documentation.sh` (Step 0b) ⭐ NEW v3.1.0
**Purpose:** Generate comprehensive documentation from scratch  
**AI Persona:** technical_writer  
**Execution:** Manual trigger or when minimal docs exist  
**Functions:**
- Analyzes project structure and code
- Generates README, API docs, guides
- Creates documentation skeleton
- Initializes documentation standards

**Output:** Complete documentation set

#### `documentation_updates.sh` (Step 1)
**Purpose:** Documentation updates and improvements  
**AI Persona:** documentation_specialist (project-kind aware)  
**Execution:** Always (unless skipped by smart execution)  
**Functions:**
- Reviews and updates documentation
- Ensures consistency with code
- Validates documentation structure
- Suggests improvements

**Optimization (v3.2.0):** 75-85% faster with incremental processing

#### `documentation_optimization.sh` (Step 2.5) ⭐ NEW v3.2.0
**Purpose:** Documentation optimization and refinement  
**AI Persona:** documentation_specialist  
**Functions:**
- Optimizes documentation structure
- Improves clarity and consistency
- Removes redundancy
- Enhances readability

#### `consistency_analysis.sh` (Step 2)
**Purpose:** Cross-reference validation  
**AI Persona:** consistency_analyst  
**Execution:** Parallel Group 1  
**Functions:**
- Validates documentation cross-references
- Checks code-documentation alignment
- Verifies version consistency
- Identifies broken links

#### `script_reference_validation.sh` (Step 3)
**Purpose:** Shell script reference validation  
**Execution:** Parallel Group 1 (auto-skips for non-shell projects)  
**Functions:**
- Validates shell script documentation
- Checks function documentation
- Verifies script examples
- Updates script references

#### `config_validation.sh` (Step 4)
**Purpose:** Configuration file validation  
**AI Persona:** configuration_specialist  
**Execution:** Parallel Group 1  
**Functions:**
- Validates YAML configuration files
- Checks configuration completeness
- Verifies configuration schema
- Detects configuration conflicts

#### `directory_validation.sh` (Step 5)
**Purpose:** Directory structure validation  
**Execution:** After validation group  
**Functions:**
- Validates project directory structure
- Checks required directories exist
- Verifies directory organization
- Suggests improvements

#### `test_review.sh` (Step 6)
**Purpose:** Test coverage review  
**AI Persona:** test_engineer  
**Execution:** Smart execution (skips for docs-only changes)  
**Functions:**
- Reviews test coverage
- Identifies untested code
- Suggests test improvements
- Validates test structure

#### `test_generation.sh` (Step 7)
**Purpose:** Test case generation  
**AI Persona:** test_engineer  
**Execution:** Smart execution (skips for docs-only changes)  
**Functions:**
- Generates new test cases
- Creates test stubs
- Suggests test scenarios
- Updates test suites

#### `test_execution.sh` (Step 8)
**Purpose:** Test execution and validation  
**Execution:** Smart execution (skips for docs-only changes)  
**Functions:**
- Runs project test suite
- Validates test results
- Reports test failures
- Generates test report

**Supports:** Jest, Mocha, pytest, BATS, and more

#### `dependency_validation.sh` (Step 9)
**Purpose:** Dependency validation  
**AI Persona:** dependency_analyst  
**Functions:**
- Validates package dependencies
- Checks for security vulnerabilities
- Identifies outdated packages
- Suggests dependency updates

#### `code_quality_validation.sh` (Step 10)
**Purpose:** Code quality checks  
**AI Persona:** quality_analyst  
**Functions:**
- Runs linting and code analysis
- Checks code style compliance
- Identifies code smells
- Suggests improvements

#### `frontend_dev_analysis.sh` (Step 11.7) ⭐ NEW v4.0.1
**Purpose:** Front-end technical implementation analysis  
**AI Persona:** front_end_developer  
**Execution:** For React SPA, Vue SPA, Static Website, Client SPA projects  
**Functions:**
- Analyzes technical implementation
- Reviews component architecture
- Validates state management
- Checks performance patterns
- Assesses accessibility implementation
- Reviews front-end testing

**Project Kinds:** react_spa, vue_spa, static_website, client_spa

#### `context_analysis.sh` (Step 11.5)
**Purpose:** Context and documentation analysis  
**AI Persona:** context_analyst  
**Functions:**
- Analyzes code context
- Reviews documentation completeness
- Validates code comments
- Suggests context improvements

#### `markdown_linting.sh` (Step 13)
**Purpose:** Markdown file validation  
**AI Persona:** markdown_linter  
**Functions:**
- Lints markdown files
- Checks markdown syntax
- Validates markdown structure
- Enforces markdown standards

#### `prompt_engineer_analysis.sh` (Step 14)
**Purpose:** AI prompt optimization (ai_workflow project only)  
**AI Persona:** prompt_engineer  
**Execution:** Only for ai_workflow repository  
**Functions:**
- Reviews AI prompt templates
- Optimizes prompt effectiveness
- Validates prompt structure
- Suggests prompt improvements

#### `ux_analysis.sh` (Step 15) ⭐ UPDATED v4.0.1
**Purpose:** User experience and visual design analysis  
**AI Persona:** ui_ux_designer (updated from ux_designer)  
**Execution:** For projects with user interfaces  
**Functions:**
- Reviews user experience design
- Analyzes visual design and layout
- Evaluates information architecture
- Checks responsive design
- Assesses user flow and interactions
- Reviews color scheme and branding

**Project Kinds:** react_spa, vue_spa, static_website, client_spa

#### `version_update.sh` (Step 16) POST-PROCESSING
**Purpose:** AI-powered semantic version updates  
**AI Persona:** version_manager  
**Execution:** After steps 10, 11.7, 13, 14, 15  
**Functions:**
- Analyzes workflow changes
- Determines semantic version bump
- Updates version files
- Generates version notes

#### `deployment_gate.sh` (Step 11)
**Purpose:** Deployment readiness validation  
**Functions:**
- Validates deployment prerequisites
- Checks build artifacts
- Verifies configuration
- Gates deployment

#### `git_finalization.sh` (Step 12) **[FINAL STEP]**
**Purpose:** Git operations and finalization  
**AI Persona:** git_specialist  
**Execution:** Always runs last (MUST be final step)  
**Functions:**
- Stages workflow changes
- Commits changes (manual or auto-commit)
- Generates commit message
- Finalizes workflow

**Critical:** Step 12 MUST always be the final step to properly commit all changes.

#### `api_coverage_analysis.sh` (Step 1.5)
**Purpose:** API documentation coverage analysis  
**Functions:**
- Analyzes API endpoint documentation
- Checks API completeness
- Validates API examples
- Suggests API doc improvements

---

### Legacy Step Files (Backward Compatibility)

Legacy numeric filenames (still supported, v4.0.0):

- Legacy numeric naming supported for backward compatibility
- `version_update.sh` → Pre-processing version (Step 0a)
- `bootstrap_docs.sh` → Use `bootstrap_documentation.sh`
- `step_01_documentation.sh` → Use `documentation_updates.sh`
- `step_01_5_api_coverage.sh` → Use `api_coverage_analysis.sh`
- `step_02_consistency.sh` → Use `consistency_analysis.sh`
- `step_02_5_doc_optimize.sh` → Use `documentation_optimization.sh`
- `step_03_script_refs.sh` → Use `script_reference_validation.sh`
- `step_04_config_validation.sh` → Use `config_validation.sh`
- `step_05_directory.sh` → Use `directory_validation.sh`
- `step_06_test_review.sh` → Use `test_review.sh`
- `step_07_test_gen.sh` → Use `test_generation.sh`
- `step_08_test_exec.sh` → Use `test_execution.sh`
- `step_09_dependencies.sh` → Use `dependency_validation.sh`
- `step_10_code_quality.sh` → Use `code_quality_validation.sh`
- `step_11_5_context.sh` → Use `context_analysis.sh`
- `step_11_7_frontend_dev.sh` → Use `frontend_dev_analysis.sh`
- `step_11_deployment_gate.sh` → Use `deployment_gate.sh`
- `step_12_git.sh` → Use `git_finalization.sh`
- `step_13_markdown_lint.sh` → Use `markdown_linting.sh`
- `step_14_prompt_engineer.sh` → Use `prompt_engineer_analysis.sh`
- `step_15_ux_analysis.sh` → Use `ux_analysis.sh`
- `step_16_version_update.sh` → Use `version_update.sh`

**Migration:** See [docs/MIGRATION_GUIDE_v4.0.md](../../docs/MIGRATION_GUIDE_v4.0.md) for v4.0.0 migration guide.

---

## Orchestrators (4)

Phase-based orchestration modules (v3.0.1). Located in `src/workflow/orchestrators/`.

### `pre_flight.sh` (227 lines)
**Purpose:** Pre-execution validation and setup  
**Phase:** Pre-flight  
**Functions:**
- `run_preflight_checks()` - Execute all pre-flight validations
- `setup_workflow_environment()` - Prepare execution environment
- `validate_prerequisites()` - Check required tools and configuration

**Validates:**
- Git repository status
- Required tools (git, node, gh copilot)
- Project configuration
- Workflow state

### `validation_orchestrator.sh` (228 lines)
**Purpose:** Validation phase coordination  
**Phase:** Validation (Steps 0-4)  
**Functions:**
- `orchestrate_validation_phase()` - Coordinate validation steps
- `run_parallel_validations()` - Execute parallel validation group
- `collect_validation_results()` - Aggregate validation outcomes

**Coordinates:**
- Pre-analysis (Step 0)
- Documentation validation (Steps 1-2)
- Configuration validation (Steps 3-4)

### `quality_orchestrator.sh` (82 lines)
**Purpose:** Quality checks coordination  
**Phase:** Quality (Steps 5-10)  
**Functions:**
- `orchestrate_quality_phase()` - Coordinate quality checks
- `run_test_pipeline()` - Execute test steps
- `validate_code_quality()` - Run quality validations

**Coordinates:**
- Test review, generation, execution (Steps 6-8)
- Dependency validation (Step 9)
- Code quality checks (Step 10)

### `finalization_orchestrator.sh` (93 lines)
**Purpose:** Finalization phase coordination  
**Phase:** Finalization (Steps 11-16)  
**Functions:**
- `orchestrate_finalization_phase()` - Coordinate finalization
- `run_final_validations()` - Execute final checks
- `finalize_workflow()` - Complete workflow

**Coordinates:**
- Context analysis (Step 11.5)
- Front-end analysis (Step 11.7) ⭐ NEW v4.0.1
- Markdown linting (Step 13)
- Prompt engineering (Step 14)
- UX analysis (Step 15)
- Version update (Step 16)
- Git finalization (Step 12) - FINAL

---

## Utility Scripts

Supporting scripts for workflow operations.

### Repository Root Scripts

#### `scripts/bump_version.sh`
**Purpose:** Semantic version bumping  
**Usage:**
```bash
./scripts/bump_version.sh <major|minor|patch>
./scripts/bump_version.sh 4.0.1  # Set specific version
```

#### `scripts/cleanup_artifacts.sh`
**Purpose:** Clean workflow artifacts  
**Usage:**
```bash
./scripts/cleanup_artifacts.sh --all --older-than 30  # Clean old artifacts
./scripts/cleanup_artifacts.sh --logs --older-than 7  # Clean logs only
./scripts/cleanup_artifacts.sh --dry-run             # Preview cleanup
```

#### `scripts/cleanup_repository.sh`
**Purpose:** Repository cleanup (development backups, etc.)  
**Usage:**
```bash
./scripts/cleanup_repository.sh --dry-run  # Preview
./scripts/cleanup_repository.sh            # Execute cleanup
```

#### `scripts/doc_diff_checker.sh`
**Purpose:** Check documentation differences  
**Usage:**
```bash
./scripts/doc_diff_checker.sh              # Check all docs
./scripts/doc_diff_checker.sh <file>       # Check specific file
```

#### `scripts/fix_documentation_issues.sh`
**Purpose:** Automated documentation fixes  
**Usage:**
```bash
./scripts/fix_documentation_issues.sh      # Interactive mode
./scripts/fix_documentation_issues.sh --auto  # Automatic fixes
```

#### `scripts/function_documentation.sh`
**Purpose:** Extract function documentation from shell scripts  
**Usage:**
```bash
./scripts/function_documentation.sh <script.sh>  # Generate docs
```

#### `scripts/migrate_to_named_steps.sh` ⭐ NEW v4.0.0
**Purpose:** Migrate from numeric to named step references  
**Usage:**
```bash
./scripts/migrate_to_named_steps.sh        # Analyze usage
./scripts/migrate_to_named_steps.sh --fix  # Apply migrations
```

#### `scripts/standardize_dates.sh`
**Purpose:** Standardize date formats in documentation  
**Usage:**
```bash
./scripts/standardize_dates.sh             # Check dates
./scripts/standardize_dates.sh --fix       # Fix dates
```

#### `scripts/validate_doc_examples.sh`
**Purpose:** Validate code examples in documentation  
**Usage:**
```bash
./scripts/validate_doc_examples.sh         # Validate all examples
```

#### `scripts/validate_docs.sh`
**Purpose:** Comprehensive documentation validation  
**Usage:**
```bash
./scripts/validate_docs.sh                 # Validate all docs
```

### Workflow Core Scripts (`.workflow_core/scripts/`)

Configuration submodule utilities (see `.workflow_core/` documentation).

#### `validate_structure.py`
**Purpose:** Validate documentation structure  
**Usage:**
```bash
python3 .workflow_core/scripts/validate_structure.py docs/
```

#### `validate_context_blocks.py`
**Purpose:** Validate context blocks in documentation  
**Usage:**
```bash
python3 .workflow_core/scripts/validate_context_blocks.py docs/
```

#### `check_doc_links.py`
**Purpose:** Check documentation links  
**Usage:**
```bash
python3 scripts/check_doc_links.py
```

#### `validate_api_docs.py`
**Purpose:** Validate API documentation completeness  
**Usage:**
```bash
python3 scripts/validate_api_docs.py
```

### Bin Utilities (`src/workflow/bin/`)

#### `query-step-info.sh`
**Purpose:** Query step metadata and information  
**Usage:**
```bash
./src/workflow/bin/query-step-info.sh <step_name>
./src/workflow/bin/query-step-info.sh documentation_updates
```

**Output:**
- Step number
- Dependencies
- Parallel group
- Execution stage
- Description

---

## Quick Reference

### Common Commands

```bash
# Basic execution
./src/workflow/execute_tests_docs_workflow.sh

# Optimized execution (recommended)
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# ML-optimized execution (v2.7.0+, requires 10+ runs)
./src/workflow/execute_tests_docs_workflow.sh \
  --ml-optimize \
  --smart-execution \
  --parallel \
  --auto

# Multi-stage pipeline (v2.8.0+)
./src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --smart-execution \
  --parallel

# Auto-commit workflow (v2.6.0+)
./src/workflow/execute_tests_docs_workflow.sh \
  --auto-commit

# Documentation-only (3-4 min)
./templates/workflows/docs-only.sh

# Test development (8-10 min)
./templates/workflows/test-only.sh

# Full feature workflow (15-20 min)
./templates/workflows/feature.sh

# Specific steps (v4.0.0: use names or indices)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution,git_finalization

# Mixed syntax (v4.0.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,documentation_updates,12

# Target different project
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/project

# Configuration wizard
./src/workflow/execute_tests_docs_workflow.sh --init-config

# Show tech stack
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# Show dependency graph
./src/workflow/execute_tests_docs_workflow.sh --show-graph

# Dry run preview
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Install pre-commit hooks (v3.0.0)
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Test hooks without committing (v3.0.0)
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# Generate documentation reports (v2.9.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --generate-docs \
  --update-changelog \
  --generate-api-docs

# Check ML system status (v2.7.0)
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Show pipeline configuration (v2.8.0)
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline

# Force all stages (v2.8.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --manual-trigger
```

### Module Usage Patterns

```bash
# Source library modules
source "$(dirname "$0")/lib/ai_helpers.sh"
source "$(dirname "$0")/lib/metrics.sh"
source "$(dirname "$0")/lib/change_detection.sh"

# Use AI integration
ai_call "documentation_specialist" "Review docs" "output.md"

# Track metrics
init_metrics
record_step_start "documentation_updates"
# ... step execution ...
record_step_end "documentation_updates" 0
finalize_metrics

# Analyze changes
analyze_git_changes
detect_change_types
get_changed_files

# Cache AI responses (automatic)
# Responses cached for 24 hours with SHA256 keys
# No code changes needed - transparent integration

# Execute steps
execute_step "documentation_updates"
validate_step_result "documentation_updates"
record_step_checkpoint "documentation_updates"

# Optimize workflow
analyze_changes_for_optimization
should_skip_step "test_generation"
execute_parallel_group "validation"
```

### File Locations

```
src/workflow/
├── execute_tests_docs_workflow.sh    # Main entry point
├── lib/                               # 81 library modules
├── steps/                             # 79 step modules
├── orchestrators/                     # 4 orchestrators
├── bin/                               # Utilities
├── .ai_cache/                         # AI response cache
├── backlog/                           # Execution history
├── logs/                              # Execution logs
├── metrics/                           # Performance metrics
└── summaries/                         # AI summaries

.workflow_core/
├── config/                            # Configuration files
│   ├── ai_helpers.yaml               # AI prompt templates
│   ├── ai_prompts_project_kinds.yaml # Project-specific prompts
│   ├── project_kinds.yaml            # Project type definitions
│   └── paths.yaml                    # Path configuration
└── scripts/                           # Configuration utilities

templates/
└── workflows/                         # Workflow templates
    ├── docs-only.sh                  # 3-4 min
    ├── test-only.sh                  # 8-10 min
    └── feature.sh                    # 15-20 min

scripts/                               # Utility scripts
├── bump_version.sh
├── cleanup_artifacts.sh
├── doc_diff_checker.sh
├── migrate_to_named_steps.sh         # NEW v4.0.0
└── ...more utilities
```

### Performance Characteristics

| Feature | Impact | Version |
|---------|--------|---------|
| Smart Execution | 40-85% faster | v2.3.0 |
| Parallel Execution | 33% faster | v2.3.0 |
| AI Response Caching | 60-80% token reduction | v2.3.0 |
| ML Optimization | Additional 15-30% improvement | v2.7.0 |
| Multi-Stage Pipeline | 80%+ runs complete in 2 stages | v2.8.0 |
| Combined Optimization | Up to 93% faster | v2.7.0+ |
| Checkpoint Resume | Instant recovery | v2.3.0 |
| Auto-Commit | Saves manual commit time | v2.6.0 |
| Pre-Commit Hooks | < 1 second validation | v3.0.0 |

### Testing

```bash
# Run all tests
cd src/workflow/lib
./test_enhancements.sh

# Test specific functionality
./test_ai_cache.sh
./test_workflow_optimization.sh
./test_project_kind_integration.sh

# Module-level tests
cd ../
./test_modules.sh
./test_file_operations.sh
```

---

## Command Reference

### All Command-Line Options

```bash
# Execution Options
--auto                    # Accept all prompts automatically
--dry-run                 # Preview execution without changes
--no-resume               # Force fresh start (ignore checkpoints)
--target PATH             # Run on different project (default: current dir)
--steps LIST              # Execute specific steps (names or indices)

# Optimization Options
--smart-execution         # Skip unnecessary steps based on changes (40-85% faster)
--parallel                # Run independent steps simultaneously (33% faster)
--no-ai-cache            # Disable AI response caching (enabled by default)
--ml-optimize            # Enable ML-driven optimization (v2.7.0, requires 10+ runs)
--multi-stage            # Enable progressive 3-stage pipeline (v2.8.0)
--manual-trigger         # Force all stages (use with --multi-stage)

# Configuration Options
--init-config            # Interactive configuration wizard
--show-tech-stack        # Display detected tech stack
--config-file FILE       # Use custom configuration file

# Analysis Options
--show-graph             # Display dependency visualization
--show-ml-status         # Check ML system status (v2.7.0)
--show-pipeline          # View pipeline configuration (v2.8.0)

# Documentation Options (v2.9.0)
--generate-docs          # Generate workflow reports
--update-changelog       # Update CHANGELOG from commits
--generate-api-docs      # Generate API documentation

# Git Options
--auto-commit            # Automatically commit workflow artifacts (v2.6.0)

# Pre-Commit Hook Options (v3.0.0)
--install-hooks          # Install pre-commit hooks
--test-hooks             # Test hooks without committing

# Help & Info
--help                   # Display help message
--version                # Show version information
```

### Exit Codes

- `0` - Success
- `1` - General error
- `2` - Validation failure
- `3` - Step execution failure
- `4` - Configuration error
- `5` - Prerequisite not met

---

## Version History

See [docs/PROJECT_REFERENCE.md](../../docs/PROJECT_REFERENCE.md#version-history-major-releases) for complete version history.

**Current Version:** v4.0.1 (2026-02-09)
- Front-end development analysis (Step 11.7)
- UI/UX designer modernization (Step 15)
- 17 AI personas (added front_end_developer, updated ui_ux_designer)
- 23 workflow steps

**Recent Versions:**
- v4.0.0 (2026-02-08): Configuration-driven steps with descriptive names
- v3.3.0 (2026-02-08): Git commit hash tracking
- v3.2.0 (2026-01-20): Step 1 optimization (75-85% faster)
- v3.1.0 (2026-01-18): Audio notifications + bootstrap documentation
- v3.0.0 (2026-01-15): Pre-commit hooks and test pre-validation

---

## Related Documentation

- **[Project Reference](../../docs/PROJECT_REFERENCE.md)** - Authoritative project statistics and features
- **[Module API](README.md)** - Detailed module API documentation
- **[Workflow Diagrams](../../docs/reference/workflow-diagrams.md)** - Visual workflow diagrams (17 Mermaid diagrams)
- **[Architecture](../../docs/developer-guide/architecture.md)** - Orchestrator design and patterns
- **[Feature Guide](../../docs/user-guide/feature-guide.md)** - Complete feature documentation
- **[Migration Guide](../../docs/MIGRATION_GUIDE_v4.0.md)** - v4.0.0 migration instructions
- **[GitHub Copilot Instructions](../../.github/copilot-instructions.md)** - Development reference

---

## Support

For issues, questions, or contributions:
- **Repository:** [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
- **Maintainer:** Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
- **License:** MIT

---

**Last Updated:** 2026-02-09 (v4.0.1)
