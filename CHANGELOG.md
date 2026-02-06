# Changelog

All notable changes to the AI Workflow Automation project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2026-02-06

### Added
- **Intelligent AI Model Selection** based on change complexity
  - Automatic analysis of git changes (code/documentation/tests)
  - Cyclomatic complexity calculation for code files
  - Semantic analysis of commit messages
  - 4-tier model selection system (Fast, Balanced, Deep Reasoning, Agentic)
  - JSON persistence of model definitions (`.ai_workflow/model_definitions.json`)
  - New module: `src/workflow/lib/model_selector.sh` (650+ lines)
- **CLI Flags** for model control:
  - `--force-model <model>` - Override automatic selection
  - `--show-model-plan` - Preview model assignments without execution
- **Model Validation**:
  - Validates model names against supported GitHub Copilot models
  - Suggests similar models for typos
  - Lists all 23 supported models
- **Configuration File**: `.workflow_core/config/model_selection_rules.yaml`
  - Customizable complexity thresholds
  - Configurable model preferences per tier
  - Step-specific overrides
  - Adjustable complexity calculation weights
- **Step 0 Enhancement**: Model selection analysis phase
  - Displays complexity scores for code/docs/tests
  - Shows model assignments with reasoning
  - Reports estimated token savings
- **Documentation**:
  - `docs/MODEL_SELECTION.md` - Comprehensive 12KB guide
  - Functional requirements document (30KB)
  - Implementation summary

### Changed
- `ai_helpers.sh`: Updated `execute_copilot_batch()` and `execute_copilot_prompt()` to use model selection
- `change_detection.sh`: Added `classify_files_by_nature()` function
- `step_00_analyze.sh`: Integrated model selection workflow
- `argument_parser.sh`: Enhanced with model validation

### Performance
- **Token Usage**: 30-50% reduction by using appropriate models
- **Execution Time**: 15-25% faster with optimized model selection
- **Cost Efficiency**: Lower costs with tiered model approach

### Technical Details
- Model tier system based on complexity scores:
  - Tier 1 (0-25): claude-haiku-4.5 - Fast tasks
  - Tier 2 (26-60): claude-sonnet-4.5 - Balanced
  - Tier 3 (61-90): claude-opus-4.5 - Deep reasoning
  - Tier 4 (91+): claude-opus-4.6 - Agentic
- Complexity formulas for code, documentation, and tests
- Alternative model fallback system
- Atomic JSON file writes for reliability

## [Unreleased]

### Added
- **Step 1 Optimization - Incremental Processing** (Phase 1)
  - File-level SHA256 hash tracking for documentation files
  - Smart change detection: Skip AI analysis for unchanged docs
  - JSON cache: `.ai_cache/doc_hashes.json` with automatic cleanup
  - Performance: 96% time savings when no docs changed, 75% on partial changes
  - New module: `step_01_lib/incremental.sh` (280 lines)
  - Functions: `calculate_file_hash()`, `detect_changed_docs()`, `detect_and_cache_changed_docs()`, `get_doc_cache_stats()`
  
- **Step 1 Optimization - Parallel Processing** (Phase 2)
  - Category-based parallel documentation analysis (5 categories: root, guides, architecture, reference, examples)
  - Concurrent AI analysis with job control (max 4 parallel jobs)
  - Automatic threshold detection (≥4 files triggers parallel mode)
  - Performance: 71% time savings on concurrent processing
  - Enhanced module: `step_01_lib/ai_integration.sh` (+190 lines)
  - Functions: `categorize_doc_file()`, `analyze_doc_category()`, `parallel_doc_analysis_step1()`

### Changed
- **Step 1 Performance**: Reduced from ~14.5 min to ~3 min average (75-85% improvement)
  - No doc changes: 14.5 min → 0.5 min (96% faster)
  - Few changes (5-10 files): 14.5 min → 2-2.5 min (83% faster)
  - Many changes (20+ files): 14.5 min → 4-5 min (71% faster)
- Updated `step_01_documentation.sh` with incremental and parallel logic integration (+50 lines)
- Modified workflow execution to support new optimization flags

### Configuration
- `ENABLE_DOC_INCREMENTAL=true` - Enable/disable file-level change detection (default: true)
- `ENABLE_DOC_PARALLEL=true` - Enable/disable parallel processing (default: true)
- `DOC_PARALLEL_THRESHOLD=4` - Minimum files to trigger parallel mode (default: 4)
- `DOC_MAX_PARALLEL_JOBS=4` - Maximum concurrent AI jobs (default: 4)

### Technical Details
- Total code added: ~985 lines (745 production, 240 tests)
- Test coverage: Comprehensive unit tests for both optimizations
- Backward compatibility: 100% - Zero breaking changes, automatic fallbacks
- Resource usage: Minimal overhead (~1-2s for 200 files), efficient parallel job control

## [3.1.0] - 2026-01-30

### Added
- **Step 0b: Bootstrap Documentation** - New workflow step using technical_writer AI persona
  - Generates comprehensive documentation from scratch for undocumented/minimally documented projects
  - Uses technical_writer_prompt template from ai_workflow_core submodule (v4.1.0)
  - Covers API docs, architecture, user guides, developer guides, and code documentation
  - Positioned after Step 0a (Version Update) and before Step 1 (Documentation Updates)
  - Complements existing documentation personas:
    - Step 0b (technical_writer): Comprehensive from-scratch documentation
    - Step 1 (doc_analysis): Incremental change-driven updates
    - Step 2 (consistency): Documentation quality assurance
- **15th AI Persona**: technical_writer for bootstrap documentation generation
- **Module Count**: Increased to 88 total modules (62 libraries + 18 steps + 4 orchestrators + 4 configs)

### Changed
- Updated dependency graph with Step 0b execution flow (0 → 0a → 0b → 1)
- Modified 3-track parallel execution structure to include Step 0b in documentation track
- Updated all documentation to reflect 18-step workflow (was 17 steps)
- Updated step time estimates (Step 0b: 120 seconds with AI)

### Documentation
- Updated `src/workflow/README.md` with Step 0b information
- Updated `docs/PROJECT_REFERENCE.md` with new module counts and AI persona list
- Updated workflow orchestrator header with Step 0b in AI personas list
- Updated usage documentation with Step 0b in workflow steps list

### Technical Details
- File: `src/workflow/steps/step_0b_bootstrap_docs.sh` (430 lines)
- AI Persona: technical_writer (from .workflow_core/config/ai_helpers.yaml)
- Dependencies: Step 0a (Version Update)
- Dependents: Step 1 (Documentation Updates)
- Execution Time: ~120 seconds (with AI)
- Auto-sourced via STEPS_DIR pattern
- No breaking changes - 100% backward compatible

## [3.0.0] - 2026-01-28 (Previously Unreleased)

### Fixed
- **Step 0 Project Kind Detection**: Config file now takes priority over auto-detection (#critical-bugfix)
  - Previously: Auto-detection always ran and could override config file settings
  - Now: `.workflow-config.yaml` project kind is used if present (100% confidence)
  - Auto-detection only runs when no config file exists or project kind not specified
  - Example: `client-spa` in config correctly used instead of misdetected `python_cli`
  - Affects: `src/workflow/steps/step_00_analyze.sh`
  - Impact: Prevents misclassification of projects, ensures accurate AI prompts and step execution
  - Priority order: Config file > Auto-detection
- **Step 14 UX Analysis**: Fixed skipping for client-spa projects (#bugfix)
  - `get_project_kind()` now reads both `project.kind` and `project.type` from config
  - Added automatic normalization: hyphens to underscores (`client-spa` → `client_spa`)
  - Updated `has_ui_components()` to normalize project kind values
  - Affects: `src/workflow/lib/project_kind_config.sh`, `src/workflow/steps/step_14_ux_analysis.sh`
  - Impact: Step 14 now correctly runs for all UI-based project types regardless of config field name
  - Backward compatible: No breaking changes, enhanced flexibility

### Added
- **Step Dependency Metadata System**: Comprehensive metadata for all workflow steps
  - New module: `src/workflow/lib/step_metadata.sh` (300+ lines)
  - Per-step metadata: name, description, category, dependencies, timing, capabilities
  - Queryable properties: can_skip, can_parallelize, requires_ai, affects_files
  - Categories: analysis, documentation, validation, testing, quality, finalization
  - CLI tool: `src/workflow/bin/query-step-info.sh` for querying metadata
  - JSON export: `export_step_metadata_json()` for external tools
  - Enables smarter execution planning and optimization
  - Foundation for advanced parallelization strategies
- **Test Pre-Validation in Step 0**: Quick smoke test to catch test infrastructure issues early
  - New module: `src/workflow/lib/test_smoke.sh`
  - Validates test dependencies, commands, and infrastructure before full workflow
  - Saves 30+ minutes by catching issues at start instead of Step 7
  - Supports JavaScript (Jest/Mocha/Vitest), Python (pytest/unittest), and Bash
  - Interactive mode prompts user to continue or abort on validation failure
  - Auto mode continues with warning

### Enhanced
- **Dependency Graph Module**: Extended with metadata integration and JSON export
  - Added `export_step_metadata_json()` for full workflow metadata export
  - Added `query_step_info()` for detailed step information
  - Added `get_ready_steps()` to find executable steps based on completed work
  - Added `calculate_critical_path()` for workflow optimization
  - Added `calculate_total_time()` for time estimation
  - Better integration with step metadata system
- **AI Prompt Templates**: Strengthened domain expertise
  - `quality_prompt`: Enhanced role authority with specific credentials
  - Before: "focused code review specialist"
  - After: "senior code review specialist with 10+ years experience"
  - Added expertise details: anti-patterns, language best practices, maintainability
  - Increases AI confidence and potentially improves output quality
  - Cost: +~20 tokens (worthwhile for authority boost)

### Optimized
- **AI Prompt Templates**: Simplified overly prescriptive output formats
  - `consistency_prompt`: Reduced from 26 lines to 5 lines (~295 tokens)
  - `ai_log_analysis_prompt`: Reduced from 13 lines to 4 lines (~50 tokens)
  - `step9_code_quality_prompt`: Reduced from 9 lines to 3 lines (~45 tokens)
  - `markdown_lint_prompt`: Removed word count requirement (~10 tokens)
  - `step13_prompt_engineer_prompt`: Condensed verbose framework (~150 tokens)
  - Changed from rigid templates to outcome-focused guidance
  - AI can now adapt structure to finding volume
  - Maintains all required information elements
  - **Total savings**: ~550 tokens per full workflow execution
  - Better consistency across all prompts (no arbitrary length requirements)
  - **Meta-optimization**: Even the prompt engineer prompt is now optimized! 😄
- **AI Prompt Templates**: Removed verbose language-specific injection comments
  - Affected prompts: `doc_analysis_prompt`, `step2_consistency_prompt`, `step3_script_refs_prompt`, `step5_test_review_prompt`, `step9_code_quality_prompt`
  - Before: Multi-line comments explaining dynamic population with examples (~6-8 lines each)
  - After: Single-line reference: `**Language-Specific Standards:** {variable}`
  - AI doesn't need implementation details about template population
  - **Savings**: ~80-100 tokens per prompt × 5 prompts = 400-500 tokens per workflow
  - Cleaner, more maintainable prompts
- **AI Prompt Templates**: Consolidated redundant test framework context
  - Affected prompts: `step5_test_review_prompt`, `step7_test_exec_prompt`
  - Before: Framework and environment listed separately, then repeated in "Test Configuration" section
  - After: Single consolidated line: "Test Config: {framework} in {env}" or "Test Config: {framework} via `{command}`"
  - Eliminates duplication, improves readability
  - **Savings**: ~25-30 tokens per prompt × 2 prompts = 50-60 tokens per workflow
  - **Total combined savings**: ~1,000-1,100 tokens per full workflow execution
- **AI Prompt Templates**: Enhanced DevOps expertise alignment
  - `step3_script_refs_prompt`: Added DevOps integration documentation validation
  - New validation points: CI/CD pipelines, containers, IaC, deployment automation
  - Expanded file analysis to include .github/workflows/, Dockerfiles, Terraform, etc.
  - Better alignment with "DevOps expert" persona
  - Catches CI/CD and container-related documentation gaps
  - Cost: +50 tokens per invocation (high value for DevOps projects)
- **Documentation**: Added token efficiency metrics to ai_helpers.yaml header
  - Cumulative savings summary: ~1,400-1,500 tokens per workflow
  - Breakdown by optimization type with version history
  - Cost impact analysis (GPT-4 pricing: ~$252-270/year for 500 workflows/month)
  - Better visibility into optimization progress over versions
  - Documentation-only change (no token cost)

### Fixed
- AI cache test failures (7 test assertions)
  - Added variable defaults to prevent unbound errors (`VERBOSE`, `USE_AI_CACHE`, `WORKFLOW_RUN_ID`, `SCRIPT_VERSION`)
  - Enhanced `update_cache_index()` to respect `USE_AI_CACHE` flag
  - Fixed `check_cache()` to work without `.meta` file (backward compatibility)
  - Refactored `cleanup_ai_cache_old_entries()` for better reliability
- Commit message history - removed ANSI escape codes and emoji characters from 8 commits
- Added `AUTO_MODE` default to `utils.sh` to prevent errors in test environments
- **Critical**: `step11_git_commit_prompt` contradiction - removed code blocks from example format
  - output_format explicitly states "No markdown code blocks"
  - approach section was showing example in code blocks (```)
  - Fixed to show format inline without code blocks
  - Prevents AI from outputting incorrect format

### Changed
- Step 0 (Pre-Analysis) now includes test infrastructure validation
  - Version bumped to 2.3.0
  - Summary includes smoke test status
  - Backlog report includes validation details

## [2.6.0] - 2025-12-24

### Added
- **Auto-Commit Workflow**: Automatically commit workflow artifacts with intelligent message generation
  - New module: `src/workflow/lib/auto_commit.sh` (250 lines)
  - Command-line flag: `--auto-commit`
  - Smart detection of documentation, test, and source file changes
  - Excludes logs, temporary files, and backlog artifacts
- **Workflow Templates**: Pre-configured scripts for common scenarios
  - `templates/workflows/docs-only.sh` - Documentation updates (3-4 min, 85% faster)
  - `templates/workflows/test-only.sh` - Test development (8-10 min)
  - `templates/workflows/feature.sh` - Full feature development (15-20 min)
  - All templates include `--smart-execution`, `--parallel`, and `--auto-commit`
- **IDE Integration**: VS Code tasks and guides for JetBrains/Vim
  - 10 pre-configured VS Code tasks in `.vscode/tasks.json`
  - Quick access via `Cmd+Shift+P > Tasks: Run Task`
  - Comprehensive setup guides in `docs/IDE_INTEGRATION_GUIDE.md`

### Fixed
- Step 13 bug: Fixed YAML block scalar parsing in prompt engineer analysis
  - Corrected `sed` pattern to properly extract multi-line YAML blocks
  - Added validation for YAML format before processing
  - Improved error messages for invalid YAML responses

### Documentation
- Added `docs/RELEASE_NOTES_v2.6.0.md` - Comprehensive release notes
- Added `docs/DOCUMENTATION_UPDATES_v2.6.0.md` - Documentation changes summary
- Added `docs/IDE_INTEGRATION_GUIDE.md` - IDE setup instructions
- Updated `docs/PROJECT_REFERENCE.md` with v2.6.0 features
- Updated `.github/copilot-instructions.md` with new capabilities

### Performance
- No performance impact - all new features are opt-in
- Templates provide significant time savings (40-85% faster for specific workflows)

## [2.5.0] - 2025-12-24

### Added
- **Phase 2 Optimizations**: Smart execution and parallel processing
  - Command-line flags: `--smart-execution`, `--parallel`
  - Performance improvements: 40-85% faster for partial changes
  - Dependency graph for step relationships
- **AI Response Caching**: 60-80% token usage reduction
  - 24-hour TTL with automatic cleanup
  - SHA256-based cache keys
  - Comprehensive cache statistics

### Fixed
- Test regression in Step 7 (Test Execution)
  - Fixed directory navigation before running tests
  - Added validation for test command paths
  - Improved error handling for missing test configurations

### Documentation
- Added `docs/workflow-automation/PHASE2_COMPLETION.md`
- Updated performance benchmarks in `docs/PROJECT_REFERENCE.md`

## [2.4.0] - 2025-12-23

### Added
- **UX Analysis (Step 14)**: Accessibility and usability analysis
  - UX Designer AI persona with WCAG 2.1 expertise
  - Automated accessibility checks (alt text, color contrast, keyboard navigation)
  - Comprehensive UX reports with actionable recommendations
- **Project Kind Auto-Detection**: Intelligent project type identification
  - Supports 13 project kinds (shell_automation, nodejs_api, react_spa, etc.)
  - Custom quality standards per project type
  - Enhanced AI prompts with project-specific context

### Enhanced
- AI prompt engineering improvements
  - Language-aware enhancements when `PRIMARY_LANGUAGE` is set
  - Project-kind specific documentation standards
  - Improved testing framework recommendations

### Documentation
- Added `docs/UX_ANALYSIS_GUIDE.md`
- Updated AI persona documentation with UX Designer
- Enhanced project configuration guide

## [2.3.1] - 2025-12-23

### Fixed
- Step 13 (Prompt Engineer Analysis) YAML parsing
  - Fixed block scalar extraction for multi-line content
  - Improved error handling for malformed responses

## [2.3.0] - 2025-12-18

### Added
- **AI Response Caching**: Reduce token usage by 60-80%
  - New module: `src/workflow/lib/ai_cache.sh`
  - 24-hour TTL with automatic cleanup
  - Cache statistics and metrics tracking
  - Command-line flag: `--no-ai-cache` to disable

### Enhanced
- Metrics system improvements
  - Cache hit/miss tracking
  - Token usage estimation
  - Performance metrics per step

### Documentation
- Added cache architecture documentation
- Updated performance benchmarks

## [2.2.0] - 2025-12-17

### Added
- **Enhanced Metrics System**: Comprehensive performance tracking
  - JSON-based metrics collection
  - Historical data in `src/workflow/metrics/history.jsonl`
  - Per-step execution times and success rates
  - Workflow-level statistics

### Enhanced
- Checkpoint resume functionality
  - Automatic continuation from last completed step
  - Command-line flag: `--no-resume` to force fresh start

## [2.1.0] - 2025-12-16

### Added
- **Workflow Modularization**: Refactored monolithic script
  - 33 library modules (15,500+ lines)
  - 15 step modules (4,777 lines)
  - 4 orchestrator modules (630 lines)
  - Improved maintainability and testability

### Enhanced
- Test coverage improvements (37+ automated tests)
- Code quality: B+ grade (87/100)

### Documentation
- Added `docs/workflow-automation/WORKFLOW_MODULARIZATION_PHASE1.md`
- Updated module inventory documentation

## [2.0.0] - 2025-12-15

### Added
- **15-Step Automated Pipeline**: Complete workflow automation
  - Documentation validation and generation
  - Code quality analysis
  - Test development and execution
  - Dependency validation
  - Git finalization
- **14 AI Personas**: Specialized assistants for each step
  - Documentation Specialist
  - Code Reviewer
  - Test Engineer
  - Quality Engineer
  - And 10 more...

### Enhanced
- GitHub Copilot CLI integration
- YAML-based configuration system
- Comprehensive error handling

### Documentation
- Complete workflow documentation suite
- API reference for all modules
- Setup and usage guides

## [1.0.0] - 2025-12-01

### Added
- Initial release
- Basic workflow automation
- Documentation generation
- Test execution support

---

## Version History Summary

| Version | Date | Type | Key Features |
|---------|------|------|--------------|
| 2.6.0 | 2025-12-24 | Minor | Auto-commit, Templates, IDE Integration |
| 2.5.0 | 2025-12-24 | Minor | Smart Execution, Parallel Processing, Test Regression Fix |
| 2.4.0 | 2025-12-23 | Minor | UX Analysis, Project Auto-Detection |
| 2.3.1 | 2025-12-23 | Patch | Step 13 YAML Parsing Fix |
| 2.3.0 | 2025-12-18 | Minor | AI Response Caching |
| 2.2.0 | 2025-12-17 | Minor | Enhanced Metrics System |
| 2.1.0 | 2025-12-16 | Minor | Workflow Modularization |
| 2.0.0 | 2025-12-15 | Major | 15-Step Pipeline, 14 AI Personas |
| 1.0.0 | 2025-12-01 | Major | Initial Release |

## Links

- [Project Reference](docs/PROJECT_REFERENCE.md) - Authoritative project statistics and features
- [Release Notes](docs/) - Detailed release notes for each version
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [GitHub Repository](https://github.com/mpbarbosa/ai_workflow)

## Breaking Changes Policy

This project follows semantic versioning:
- **Major version** (X.0.0): Breaking changes that require user action
- **Minor version** (0.X.0): New features, backward compatible
- **Patch version** (0.0.X): Bug fixes, backward compatible

All breaking changes are documented with migration guides.
