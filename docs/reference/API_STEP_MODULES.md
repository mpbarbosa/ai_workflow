# API Reference - Workflow Step Modules

**Version**: v4.0.1  
**Last Updated**: 2026-02-09

This document provides a comprehensive API reference for all 23 workflow step modules in the AI Workflow Automation system. Each step is a self-contained executable module that performs a specific phase of the workflow automation process.

## Table of Contents

- [Overview](#overview)
- [Step Module Architecture](#step-module-architecture)
- [Pre-Flight Steps (0x)](#pre-flight-steps-0x)
- [Analysis & Documentation (00-03)](#analysis--documentation-00-03)
- [Structure & Testing (04-07)](#structure--testing-04-07)
- [Quality & Dependencies (08-10)](#quality--dependencies-08-10)
- [Finalization (11-13)](#finalization-11-13)
- [Specialized Analysis (11.7, 14-15)](#specialized-analysis-14-15)
- [Common Patterns](#common-patterns)
- [Error Handling](#error-handling)

---

## Overview

The workflow consists of **23 step modules** organized into logical phases:

| Phase | Steps | Purpose | Can Parallelize |
|-------|-------|---------|-----------------|
| Pre-Flight | 0a, 0b, 00 | Version pre-increment, bootstrap docs, analysis | No (sequential) |
| Analysis | 01-03 | Documentation and cross-reference validation | Yes (1-3) |
| Structure | 04 | Directory structure validation | Yes (with 1-3) |
| Testing | 05-07 | Test review, generation, execution | No (sequential) |
| Quality | 08-10 | Dependencies, code quality, context | Yes (8-10) |
| Front-End | 11.7 | Front-end technical implementation analysis (NEW v4.0.1) | Yes (with 10) |
| Finalization | 11-13 | Git, markdown lint, prompt engineer | No (11 after all, 12-13 parallel) |
| Specialized | 15, 16 | UX analysis, version update | Yes (15 after 11.7, 16 with others) |

**Total Code**: ~6,600 lines across 18 modules  
**Execution Time**: 2-23 minutes (smart: 1.5-23 min, parallel: 1.5-15.5 min)

---

## Step Module Architecture

### Standard Structure

Every step module follows this pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step XX: [Step Name]
# Purpose: [One-line description]
# Part of: Tests & Documentation Workflow Automation v3.0.0
# Version: [Step version]
################################################################################

# Module version information
readonly STEPXX_VERSION="X.Y.Z"
readonly STEPXX_VERSION_MAJOR=X
readonly STEPXX_VERSION_MINOR=Y
readonly STEPXX_VERSION_PATCH=Z

# Required function: Validate prerequisites
validate_step_XX() {
    # Check if step should run
    # Validate dependencies
    # Return 0 if ready, 1 if should skip
}

# Required function: Execute step logic
execute_step_XX() {
    # Main step implementation
    # AI integration if needed
    # Report generation
    # Return 0 on success, non-zero on failure
}
```

### Required Functions

Each step module **must** export these functions:

1. **`validate_step_XX()`** - Prerequisite validation and skip logic
2. **`execute_step_XX()`** or **`stepXX_[operation]()`** - Main execution logic

### Optional Components

- **Submodules** (step_XX_lib/) - For complex steps (01, 02, 05, 06)
- **Helper functions** - Step-specific utilities
- **Version information** - `stepXX_get_version()`

---

## Pre-Flight Steps (0x)

### Step 0a: Version Pre-Update

**File**: `step_0a_version_update.sh` (466 lines)  
**Purpose**: Pre-increment semantic versions before workflow starts  
**Dependencies**: None  
**AI Personas**: None  
**Execution**: ~10 seconds

#### Key Functions

##### `step0a_version_pre_update()`
```bash
step0a_version_pre_update
```
- **Description**: Pre-increments version numbers in modified files
- **Logic**:
  1. Detect modified files with version patterns
  2. Determine bump type (major/minor/patch) via heuristics
  3. Update version numbers atomically
  4. Stage version changes
- **Returns**: 0 on success, 1 on failure
- **Side Effects**: Modifies files, updates git index

##### `detect_version_patterns(file)`
```bash
detect_version_patterns "package.json"
```
- **Parameters**: File path to scan
- **Returns**: Line numbers with version matches
- **Pattern**: Matches `X.Y.Z` semver format

##### `increment_version(version, bump_type)`
```bash
new_version=$(increment_version "1.2.3" "minor")  # Returns "1.3.0"
```
- **Parameters**: 
  - `version`: Current version (X.Y.Z)
  - `bump_type`: major|minor|patch
- **Returns**: New version string

**Configuration**:
- Respects `--skip-version-update` flag
- Integrates with git cache for change detection

---

### Step 0b: Bootstrap Documentation

**File**: `step_0b_bootstrap_docs.sh` (431 lines)  
**Purpose**: Generate initial documentation for new projects  
**Dependencies**: None  
**AI Personas**: `documentation_specialist`  
**Execution**: ~2-3 minutes

#### Key Functions

##### `step0b_bootstrap_documentation()`
```bash
step0b_bootstrap_documentation
```
- **Description**: Creates starter documentation for projects with minimal docs
- **Logic**:
  1. Check if documentation exists (README.md, docs/)
  2. Detect project type and tech stack
  3. Generate AI-powered initial documentation
  4. Create standard doc structure
- **Returns**: 0 on success, 1 on failure
- **Triggers**: Projects with < 3 documentation files

##### `should_bootstrap()`
```bash
if should_bootstrap; then
    step0b_bootstrap_documentation
fi
```
- **Description**: Determines if bootstrapping is needed
- **Criteria**:
  - No README.md or < 500 bytes
  - No docs/ directory or < 2 files
  - No CHANGELOG.md
- **Returns**: 0 if should bootstrap, 1 otherwise

**AI Integration**:
- Generates README.md with project overview
- Creates initial CHANGELOG.md
- Generates docs/QUICK_START.md
- Suggests documentation structure

---

### Step 00: Pre-Flight Analysis

**File**: `step_00_analyze.sh` (235 lines)  
**Purpose**: Analyze git state, detect tech stack, validate test infrastructure  
**Dependencies**: None (runs first)  
**AI Personas**: None  
**Execution**: ~5-15 seconds

#### Key Functions

##### `step0_analyze_changes()`
```bash
step0_analyze_changes
```
- **Description**: Comprehensive pre-flight validation and context gathering
- **Logic**:
  1. Analyze git repository state (commits, changes)
  2. Detect technology stack (language, framework, build system)
  3. Determine project kind (nodejs_api, react_spa, etc.)
  4. Run test infrastructure smoke test (v3.0.0)
  5. Auto-detect change scope (docs/tests/src/config)
- **Returns**: 0 on success, 1 on failure
- **Side Effects**: 
  - Sets global variables: `ANALYSIS_COMMITS`, `ANALYSIS_MODIFIED`
  - Exports: `PROJECT_KIND`, `PROJECT_KIND_CONFIDENCE`
  - Exports: `PRIMARY_LANGUAGE`, `BUILD_SYSTEM`, `TEST_FRAMEWORK`

##### Change Scope Detection
```bash
# Automatic scope detection (exported variables)
CHANGE_SCOPE_DOCS=5        # Number of doc files changed
CHANGE_SCOPE_TESTS=3       # Number of test files changed
CHANGE_SCOPE_SRC=8         # Number of source files changed
CHANGE_SCOPE_CONFIG=1      # Number of config files changed
```

**Tech Stack Detection**:
- Auto-detects from package.json, requirements.txt, Cargo.toml, etc.
- Sets `PRIMARY_LANGUAGE`: javascript, python, go, rust, shell
- Sets `TEST_FRAMEWORK`: jest, pytest, go test, cargo test, bats
- Sets `BUILD_SYSTEM`: npm, cargo, go mod, pip

**Test Infrastructure Validation** (NEW v3.0.0):
```bash
if declare -f smoke_test_infrastructure >/dev/null 2>&1; then
    smoke_test_infrastructure  # Quick validation of test setup
fi
```
- Validates test command exists and is executable
- Checks test framework is installed
- Verifies test directory structure
- Catches issues early (saves 30+ minutes on failures)

**Project Kind Detection**:
- Priority: 1. Config file (`.workflow-config.yaml`), 2. Auto-detection
- Supports: nodejs_api, nodejs_cli, react_spa, vue_spa, python_api, shell_automation, static_website, documentation
- Used by AI personas for context-aware analysis

---

## Analysis & Documentation (00-03)

### Step 01: Documentation Updates

**File**: `step_01_documentation.sh` (431 lines) + **4 submodules** (951 lines)  
**Purpose**: AI-powered documentation review and updates  
**Dependencies**: Step 00  
**AI Personas**: `documentation_specialist` (project-aware)  
**Execution**: ~3-5 minutes (cached: ~30 seconds)

#### Key Functions

##### `step1_documentation_updates()` (main orchestrator)
```bash
step1_documentation_updates
```
- **Description**: Comprehensive documentation analysis and update workflow
- **Logic**:
  1. Discover documentation files (README, docs/, guides)
  2. Validate documentation structure
  3. Build AI prompt with project context
  4. Execute AI review (with caching)
  5. Process and save AI recommendations
- **Returns**: 0 on success
- **AI Context**: Includes PROJECT_KIND, tech stack, recent changes

#### Submodule Functions

**Validation Module** (`step_01_lib/validation.sh`):

##### `discover_docs_step1([pattern])`
```bash
docs=$(discover_docs_step1 "*.md")
```
- **Parameters**: Optional glob pattern (default: "*.md")
- **Returns**: Newline-separated list of documentation files
- **Excludes**: node_modules, .git, vendor, venv

##### `validate_doc_structure_step1(file)`
```bash
validate_doc_structure_step1 "README.md"
```
- **Parameters**: Documentation file path
- **Checks**:
  - File size (> 100 bytes)
  - Heading structure (has # title)
  - No broken reference patterns
- **Returns**: 0 if valid, 1 if issues found

**Cache Module** (`step_01_lib/cache.sh`):

##### `cache_doc_state_step1(file)`
```bash
cache_doc_state_step1 "docs/API.md"
```
- **Description**: Caches documentation file state for change detection
- **Caches**: SHA256 hash, mtime, size
- **Returns**: 0 on success

##### `get_cached_docs_step1()`
```bash
cached_docs=$(get_cached_docs_step1)
```
- **Returns**: JSON array of cached doc states
- **Usage**: Skip unchanged files in subsequent runs

**File Operations Module** (`step_01_lib/file_operations.sh`):

##### `update_doc_file_step1(file, content)`
```bash
update_doc_file_step1 "README.md" "$new_content"
```
- **Parameters**: 
  - `file`: Path to documentation file
  - `content`: New content to write
- **Safety**:
  - Creates backup before modification
  - Validates content is not empty
  - Atomic write operation
- **Returns**: 0 on success, 1 on failure

##### `create_backup_step1(file)`
```bash
backup_path=$(create_backup_step1 "README.md")
```
- **Parameters**: File path to backup
- **Returns**: Backup file path on stdout
- **Format**: `{file}.backup.{timestamp}`

**AI Integration Module** (`step_01_lib/ai_integration.sh`):

##### `build_documentation_prompt_step1(change_summary, doc_list)`
```bash
prompt=$(build_documentation_prompt_step1 "$changes" "$docs")
```
- **Parameters**:
  - `change_summary`: Summary of git changes
  - `doc_list`: List of documentation files
- **Returns**: Formatted AI prompt with full context
- **Context Includes**:
  - Project kind and description
  - Tech stack details
  - Recent changes
  - Existing documentation structure
  - Language-specific conventions (if PRIMARY_LANGUAGE set)

##### `execute_ai_review_step1(prompt, output_file)`
```bash
execute_ai_review_step1 "$prompt" "step_01_analysis.md"
```
- **Parameters**:
  - `prompt`: AI prompt text
  - `output_file`: Path to save response
- **Returns**: 0 on success, 1 on failure
- **Caching**: Automatic 24-hour TTL
- **Persona**: Uses `documentation_specialist`

**Performance Characteristics**:
- **First run**: ~3-5 minutes (AI analysis)
- **Cached run**: ~30 seconds (cache hit)
- **Smart execution**: Skipped if no relevant changes
- **Token usage**: ~2,000-4,000 tokens (cached: 0)

---

### Step 02: Cross-Reference Validation

**File**: `step_02_consistency.sh` (210 lines) + **4 submodules** (790 lines)  
**Purpose**: Validate documentation consistency and cross-references  
**Dependencies**: Step 01  
**AI Personas**: `consistency_analyst`  
**Execution**: ~2-3 minutes

#### Key Functions

##### `step2_validate_consistency()`
```bash
step2_validate_consistency
```
- **Description**: Comprehensive consistency validation across all documentation
- **Logic**:
  1. Check version references across files
  2. Validate internal links (relative paths)
  3. Check cross-references between documents
  4. Identify broken or outdated references
  5. Generate consistency report
- **Returns**: 0 if consistent, 1 if issues found

#### Submodule Functions

**Validation Module** (`step_02_lib/validation.sh`):

##### `validate_consistency_step2()`
```bash
issues=$(validate_consistency_step2)
```
- **Description**: Core consistency checking logic
- **Checks**:
  - Version string consistency across files
  - Feature mentions match actual implementation
  - API references are accurate
- **Returns**: List of issues (empty if all good)

##### `check_version_refs_step2()`
```bash
version_issues=$(check_version_refs_step2)
```
- **Description**: Validates version references across documentation
- **Pattern**: Matches "v1.2.3", "version 1.2.3", "@version 1.2.3"
- **Returns**: Inconsistent version references

**Link Checker Module** (`step_02_lib/link_checker.sh`):

##### `check_file_refs_step2(file)`
```bash
check_file_refs_step2 "README.md"
```
- **Parameters**: Documentation file to check
- **Validates**:
  - Markdown links: `[text](path.md)`
  - HTML links: `<a href="path.md">`
  - Relative path resolution
- **Returns**: List of broken links
- **False Positive Handling**: Excludes external URLs, anchors

##### `extract_absolute_refs_step2(file)`
```bash
refs=$(extract_absolute_refs_step2 "docs/guide.md")
```
- **Parameters**: File path
- **Returns**: List of absolute file references
- **Pattern**: `/path/to/file.md`

**Reporting Module** (`step_02_lib/reporting.sh`):

##### `generate_consistency_report_step2(issues)`
```bash
generate_consistency_report_step2 "$issues" > report.md
```
- **Parameters**: Array of consistency issues
- **Format**: Markdown report with sections:
  - Version inconsistencies
  - Broken links
  - Outdated references
  - Recommendations
- **Returns**: Formatted report on stdout

**AI Integration Module** (`step_02_lib/ai_integration.sh`):

##### `build_consistency_prompt_step2(issues)`
```bash
prompt=$(build_consistency_prompt_step2 "$issues")
```
- **Parameters**: List of detected issues
- **Returns**: AI prompt for consistency analysis
- **AI Task**: Prioritize issues, suggest fixes, identify patterns

**Performance**:
- Parallel link checking (4 concurrent jobs)
- Cached file reads
- Incremental validation (only changed files)

---

### Step 03: Script Reference Validation

**File**: `step_03_script_refs.sh` (338 lines)  
**Purpose**: Validate script paths, command references, code examples  
**Dependencies**: Step 02  
**AI Personas**: `script_validator`  
**Execution**: ~2-3 minutes

#### Key Functions

##### `step3_validate_script_references()`
```bash
step3_validate_script_references
```
- **Description**: Validates all script references in documentation
- **Logic**:
  1. Extract script references from docs (code blocks, inline code)
  2. Validate script file paths exist
  3. Check command examples are syntactically valid
  4. Verify executable permissions
  5. Test example commands (dry-run mode)
- **Returns**: 0 if all valid, 1 if issues found

##### `extract_script_refs(file)`
```bash
refs=$(extract_script_refs "docs/guide.md")
```
- **Parameters**: Documentation file path
- **Patterns Detected**:
  - Inline code: `` `./script.sh` ``
  - Code blocks: ` ```bash ... ``` `
  - File paths: `src/workflow/execute_tests_docs_workflow.sh`
- **Returns**: List of script references

##### `validate_script_path(path)`
```bash
validate_script_path "./src/workflow/steps/step_00_analyze.sh"
```
- **Parameters**: Script file path
- **Checks**:
  - File exists
  - Is readable
  - Has shebang (for shell scripts)
  - Is executable (or should be)
- **Returns**: 0 if valid, 1 with error message

##### `validate_command_syntax(command)`
```bash
validate_command_syntax "./execute_tests_docs_workflow.sh --help"
```
- **Parameters**: Shell command string
- **Validation**: Parses with `bash -n` (syntax check only)
- **Returns**: 0 if valid syntax, 1 if errors

##### `test_example_command(command)`
```bash
test_example_command "./execute_tests_docs_workflow.sh --dry-run"
```
- **Parameters**: Command to test
- **Mode**: Executes in dry-run/help mode only (safe)
- **Returns**: 0 if executes without error
- **Safety**: Never executes destructive operations

**Example Patterns Validated**:
```bash
# Valid patterns in documentation
./execute_tests_docs_workflow.sh --smart-execution
source ./src/workflow/lib/ai_helpers.sh
bash -c "cd /path && ./script.sh"

# Detected issues
./nonexistent_script.sh                    # File not found
source ./lib/missing_module.sh             # Module missing
./script.sh --invalid-flag                 # Invalid flag
```

**AI Analysis**:
- Reviews broken references
- Suggests corrections (typos, moved files)
- Identifies documentation debt

---

## Structure & Testing (04-07)

### Step 04: Directory Structure Validation

**File**: `step_04_directory.sh` (400 lines)  
**Purpose**: Validate project directory structure meets conventions  
**Dependencies**: Step 00  
**AI Personas**: `directory_validator`  
**Execution**: ~1-2 minutes

#### Key Functions

##### `step4_validate_directory_structure()`
```bash
step4_validate_directory_structure
```
- **Description**: Comprehensive directory structure validation
- **Logic**:
  1. Detect project type (from PROJECT_KIND)
  2. Load expected structure from project_kinds.yaml
  3. Validate required directories exist
  4. Check recommended directories
  5. Identify unexpected structure
  6. Generate structure report
- **Returns**: 0 if valid, 1 if issues

##### `validate_required_directories(project_kind)`
```bash
validate_required_directories "nodejs_api"
```
- **Parameters**: Project kind identifier
- **Required Directories** (by kind):
  - **nodejs_api**: `src/`, `tests/`, `docs/`
  - **react_spa**: `src/components/`, `public/`, `tests/`
  - **python_api**: `src/`, `tests/`, `requirements.txt`
  - **shell_automation**: `src/`, `tests/`, `lib/` (optional)
- **Returns**: List of missing directories

##### `check_directory_conventions()`
```bash
issues=$(check_directory_conventions)
```
- **Validates**:
  - Lowercase directory names (src/ not Src/)
  - Consistent naming (tests/ not test/ mixed with testing/)
  - No deeply nested structures (max 5 levels recommended)
  - No orphaned directories (empty or unused)
- **Returns**: Convention violations

##### `generate_structure_tree([depth])`
```bash
tree=$(generate_structure_tree 3)
```
- **Parameters**: Maximum depth (default: 4)
- **Returns**: ASCII tree representation of directory structure
- **Format**:
```
project-root/
├── src/
│   ├── lib/
│   └── workflow/
├── tests/
└── docs/
```

**Project Kind Structures**:

| Project Kind | Required | Recommended | Notes |
|--------------|----------|-------------|-------|
| nodejs_api | src/, tests/, package.json | docs/, .env.example | Standard Node.js structure |
| nodejs_cli | src/, bin/, tests/ | docs/, examples/ | bin/ for executables |
| react_spa | src/components/, public/ | src/hooks/, src/utils/ | Standard React structure |
| python_api | src/, tests/, requirements.txt | docs/, .env.example | Standard Python structure |
| shell_automation | src/, tests/ | lib/, docs/ | lib/ for shared functions |

**AI Analysis**:
- Suggests missing directories
- Identifies unconventional structure
- Recommends refactoring for better organization

---

### Step 05: Test Coverage Review

**File**: `step_05_test_review.sh` (133 lines) + **4 submodules** (448 lines)  
**Purpose**: Review existing tests and identify coverage gaps  
**Dependencies**: Step 04  
**AI Personas**: `test_engineer`  
**Execution**: ~2-4 minutes

#### Key Functions

##### `step5_review_existing_tests()`
```bash
step5_review_existing_tests
```
- **Description**: Comprehensive test suite analysis
- **Logic**:
  1. Discover all test files
  2. Analyze test coverage (if reports available)
  3. Identify uncovered code paths
  4. Review test quality
  5. Generate coverage report
- **Returns**: 0 on success, 1 if critical issues

#### Submodule Functions

**Test Discovery Module** (`step_05_lib/test_discovery.sh`):

##### `discover_test_files_step5([pattern])`
```bash
tests=$(discover_test_files_step5 "*.test.js")
```
- **Parameters**: Optional test file pattern
- **Auto-detects**: Based on TEST_FRAMEWORK
  - Jest: `*.test.js`, `*.spec.js`
  - Pytest: `test_*.py`, `*_test.py`
  - Go: `*_test.go`
  - Bats: `*.bats`, `test_*.sh`
- **Returns**: Newline-separated list of test files

##### `count_test_files_step5(test_list)`
```bash
count=$(count_test_files_step5 "$tests")
```
- **Parameters**: Output from discover_test_files_step5
- **Returns**: Integer count of test files

##### `detect_test_framework_step5()`
```bash
framework=$(detect_test_framework_step5)
```
- **Detection Logic**:
  1. Check TEST_FRAMEWORK env var
  2. Examine package.json (jest, mocha, vitest)
  3. Check requirements.txt (pytest, unittest)
  4. Look for go.mod (go test)
  5. Find *.bats files (bats)
- **Returns**: Framework name or "unknown"

**Coverage Analysis Module** (`step_05_lib/coverage_analysis.sh`):

##### `find_coverage_reports_step5()`
```bash
if find_coverage_reports_step5; then
    echo "Coverage data available"
fi
```
- **Search Paths**:
  - `coverage/` (Jest, NYC)
  - `.coverage`, `htmlcov/` (Pytest)
  - `coverage.out` (Go)
- **Returns**: 0 if found, 1 if not found

##### `parse_coverage_step5()`
```bash
coverage_data=$(parse_coverage_step5)
```
- **Format**: Parses coverage reports to extract:
  - Overall coverage percentage
  - Per-file coverage
  - Uncovered lines
- **Returns**: JSON object with coverage stats

##### `identify_gaps_step5(coverage_data)`
```bash
gaps=$(identify_gaps_step5 "$coverage_data")
```
- **Parameters**: Coverage data from parse_coverage_step5
- **Analysis**:
  - Files with < 80% coverage
  - Critical paths without tests
  - Edge cases not tested
- **Returns**: List of coverage gaps

**Reporting Module** (`step_05_lib/reporting.sh`):

##### `generate_test_report_step5(test_count, coverage, gaps)`
```bash
generate_test_report_step5 42 "85%" "$gaps" > report.md
```
- **Parameters**:
  - `test_count`: Number of test files
  - `coverage`: Coverage percentage
  - `gaps`: Coverage gaps from identify_gaps_step5
- **Returns**: Formatted markdown report

**AI Integration Module** (`step_05_lib/ai_integration.sh`):

##### `build_test_review_prompt_step5(context)`
```bash
prompt=$(build_test_review_prompt_step5 "$context")
```
- **Parameters**: Test context (counts, coverage, framework)
- **AI Task**:
  - Review test quality and coverage
  - Identify missing test scenarios
  - Suggest improvements
  - Prioritize testing gaps
- **Returns**: Formatted prompt for test_engineer persona

**Performance**:
- Parallel test file discovery
- Cached coverage reports
- Skipped if no tests found

---

### Step 06: Test Case Generation

**File**: `step_06_test_gen.sh` (118 lines) + **4 submodules** (180 lines)  
**Purpose**: AI-powered test case generation for coverage gaps  
**Dependencies**: Step 05  
**AI Personas**: `test_engineer`  
**Execution**: ~3-5 minutes

#### Key Functions

##### `step6_generate_test_cases()`
```bash
step6_generate_test_cases
```
- **Description**: Generates missing test cases based on gap analysis
- **Logic**:
  1. Import coverage gaps from Step 05
  2. Analyze untested code paths
  3. Generate test case recommendations (AI)
  4. Create test stubs/templates
  5. Save generated tests
- **Returns**: 0 on success

#### Submodule Functions

**Gap Analysis Module** (`step_06_lib/gap_analysis.sh`):

##### `identify_untested_code_step6()`
```bash
untested=$(identify_untested_code_step6)
```
- **Description**: Identifies code without test coverage
- **Sources**:
  - Coverage gaps from Step 05
  - New files without tests
  - Modified functions without test updates
- **Returns**: List of untested code units (files, functions, classes)

##### `analyze_gaps_step6(untested_list)`
```bash
prioritized=$(analyze_gaps_step6 "$untested")
```
- **Parameters**: Output from identify_untested_code_step6
- **Prioritization**:
  1. Critical paths (main APIs, entry points)
  2. Complex logic (high cyclomatic complexity)
  3. Error handling paths
  4. Edge cases
- **Returns**: Prioritized list with metadata

**Test Generation Module** (`step_06_lib/test_generation.sh`):

##### `generate_test_stub_step6(code_unit, framework)`
```bash
generate_test_stub_step6 "src/api/users.js" "jest"
```
- **Parameters**:
  - `code_unit`: Code file/function to test
  - `framework`: Test framework to use
- **Generates**:
  - Test file with proper naming
  - Import/require statements
  - Test structure (describe/it blocks)
  - Basic test cases (happy path, error cases)
- **Returns**: Path to generated test file

**Reporting Module** (`step_06_lib/reporting.sh`):

##### `report_generated_tests_step6(generated_list)`
```bash
report_generated_tests_step6 "$generated" > report.md
```
- **Parameters**: List of generated test files
- **Report Includes**:
  - Generated test file paths
  - Test cases per file
  - Coverage improvement estimate
  - Next steps for manual refinement
- **Returns**: Markdown report

**AI Integration Module** (`step_06_lib/ai_integration.sh`):

##### `build_test_gen_prompt_step6(code_unit, context)`
```bash
prompt=$(build_test_gen_prompt_step6 "src/api/users.js" "$context")
```
- **Parameters**:
  - `code_unit`: Code to generate tests for
  - `context`: Project context, tech stack
- **AI Task**:
  - Analyze code structure
  - Identify test scenarios (happy, edge, error)
  - Generate test code
  - Include setup/teardown if needed
- **Returns**: AI prompt with code samples

**Example Output**:
```javascript
// Generated: tests/api/users.test.js
describe('User API', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Generated test case
    });
    
    it('should reject invalid email', async () => {
      // Generated test case
    });
  });
});
```

---

### Step 07: Test Execution

**File**: `step_07_test_exec.sh` (371 lines)  
**Purpose**: Execute test suite and collect results  
**Dependencies**: Step 06  
**AI Personas**: `test_execution_analyst`  
**Execution**: ~2-10 minutes (depends on test suite)

#### Key Functions

##### `step7_execute_tests()`
```bash
step7_execute_tests
```
- **Description**: Runs complete test suite and analyzes results
- **Logic**:
  1. Detect test command (from tech stack)
  2. Execute tests with coverage
  3. Collect test results
  4. Parse failures and errors
  5. Generate execution report
- **Returns**: 0 if all tests pass, 1 if failures

##### `get_test_command()`
```bash
test_cmd=$(get_test_command)
```
- **Auto-detection**:
  - Checks `.workflow-config.yaml` first
  - Falls back to tech stack detection
  - Adds coverage flags automatically
- **Examples**:
  - Jest: `npm test -- --coverage`
  - Pytest: `pytest --cov=src tests/`
  - Go: `go test -cover ./...`
  - Bats: `bats tests/`
- **Returns**: Complete test command string

##### `execute_test_suite(command)`
```bash
execute_test_suite "$test_cmd"
```
- **Parameters**: Test command from get_test_command
- **Execution**:
  - Runs in PROJECT_ROOT or TARGET_PROJECT_ROOT
  - Captures stdout and stderr
  - Records exit code
  - Measures execution time
- **Returns**: Exit code from test command

##### `parse_test_results(output)`
```bash
results=$(parse_test_results "$test_output")
```
- **Parameters**: Test command output
- **Parses**:
  - Total tests run
  - Passed count
  - Failed count
  - Skipped count
  - Coverage percentage
- **Format**: JSON object with stats
- **Returns**: Structured test results

##### `analyze_failures(output)`
```bash
failures=$(analyze_failures "$test_output")
```
- **Parameters**: Test output from execute_test_suite
- **Extracts**:
  - Failed test names
  - Error messages
  - Stack traces
  - File locations
- **Returns**: List of failure details

##### `generate_execution_report(results, failures)`
```bash
generate_execution_report "$results" "$failures" > report.md
```
- **Parameters**:
  - `results`: Parsed test results
  - `failures`: Failure analysis
- **Report Sections**:
  - Executive summary (pass/fail counts)
  - Coverage metrics
  - Failed tests with details
  - Recommendations for fixes
- **Returns**: Markdown report

**AI Analysis**:
- Reviews failure patterns
- Suggests root causes
- Identifies flaky tests
- Recommends debugging steps

**Error Handling**:
```bash
# Graceful handling of test command not found
if ! command -v npm &>/dev/null; then
    print_warning "npm not found - skipping test execution"
    return 0  # Non-critical failure
fi
```

**Performance**:
- Parallel test execution (if framework supports)
- Cached test results (subsequent runs)
- Smart execution skip if no code changes

---

## Quality & Dependencies (08-10)

### Step 08: Dependency Validation

**File**: `step_08_dependencies.sh` (469 lines)  
**Purpose**: Analyze dependencies for security, compatibility, updates  
**Dependencies**: Step 07  
**AI Personas**: `dependency_analyst`, `security_analyst`  
**Execution**: ~2-4 minutes

#### Key Functions

##### `step8_validate_dependencies()`
```bash
step8_validate_dependencies
```
- **Description**: Comprehensive dependency analysis and validation
- **Logic**:
  1. Detect dependency manifest files
  2. Parse dependency lists
  3. Check for known vulnerabilities (if tools available)
  4. Identify outdated dependencies
  5. Validate version constraints
  6. Generate dependency report
- **Returns**: 0 if no critical issues, 1 if vulnerabilities found

##### `detect_dependency_files()`
```bash
manifests=$(detect_dependency_files)
```
- **Detects**:
  - Node.js: `package.json`, `package-lock.json`, `yarn.lock`
  - Python: `requirements.txt`, `Pipfile`, `pyproject.toml`
  - Go: `go.mod`, `go.sum`
  - Rust: `Cargo.toml`, `Cargo.lock`
  - Ruby: `Gemfile`, `Gemfile.lock`
- **Returns**: List of found manifest files

##### `parse_dependencies(manifest_file)`
```bash
deps=$(parse_dependencies "package.json")
```
- **Parameters**: Dependency manifest file
- **Parses**:
  - Direct dependencies
  - Dev dependencies
  - Peer dependencies (Node.js)
  - Version constraints
- **Returns**: JSON array of dependencies with versions

##### `check_vulnerabilities(deps)`
```bash
vulns=$(check_vulnerabilities "$deps")
```
- **Parameters**: Dependencies from parse_dependencies
- **Tools Used** (if available):
  - `npm audit` (Node.js)
  - `pip-audit` (Python)
  - `cargo audit` (Rust)
  - GitHub Advisory Database API
- **Returns**: List of vulnerabilities with severity

##### `identify_outdated(deps)`
```bash
outdated=$(identify_outdated "$deps")
```
- **Parameters**: Dependencies list
- **Checks**:
  - Current version vs latest stable
  - Major version updates available
  - Breaking changes in updates
- **Returns**: Outdated dependencies with update recommendations

##### `validate_version_constraints(manifest)`
```bash
issues=$(validate_version_constraints "package.json")
```
- **Parameters**: Manifest file path
- **Validates**:
  - Semantic version constraints valid
  - No conflicting version ranges
  - Pinned vs range versions (best practices)
- **Returns**: Version constraint issues

**Security Analysis**:
```bash
# Example vulnerability report
{
  "package": "lodash",
  "current": "4.17.19",
  "vulnerable": true,
  "severity": "high",
  "cve": "CVE-2020-8203",
  "fix": "4.17.21"
}
```

**AI Analysis**:
- Prioritizes vulnerability fixes
- Suggests dependency update strategy
- Identifies unused dependencies
- Recommends alternative packages

**Integration with External Tools**:
```bash
# Automatically runs if available
if command -v npm &>/dev/null; then
    npm audit --json
fi
```

---

### Step 09: Code Quality Review

**File**: `step_09_code_quality.sh` (313 lines)  
**Purpose**: AI-powered code quality and best practices review  
**Dependencies**: Step 08  
**AI Personas**: `code_reviewer`  
**Execution**: ~3-5 minutes

#### Key Functions

##### `step9_code_quality_review()`
```bash
step9_code_quality_review
```
- **Description**: Comprehensive code quality analysis
- **Logic**:
  1. Identify modified source files
  2. Run linters (if available)
  3. Check code style consistency
  4. Analyze complexity metrics
  5. AI-powered best practices review
  6. Generate quality report
- **Returns**: 0 if quality acceptable, 1 if critical issues

##### `identify_source_files()`
```bash
sources=$(identify_source_files)
```
- **Detection**: Based on PRIMARY_LANGUAGE
  - JavaScript/TypeScript: `*.js`, `*.ts`, `*.jsx`, `*.tsx`
  - Python: `*.py`
  - Go: `*.go`
  - Rust: `*.rs`
  - Shell: `*.sh`
- **Excludes**: tests/, vendor/, node_modules/
- **Returns**: List of source files

##### `run_linters(files)`
```bash
lint_results=$(run_linters "$source_files")
```
- **Parameters**: List of files to lint
- **Linters Used** (if available):
  - ESLint (JavaScript/TypeScript)
  - Pylint, Flake8 (Python)
  - golint, go vet (Go)
  - Clippy (Rust)
  - ShellCheck (Shell scripts)
- **Returns**: Linter output with issues

##### `check_code_style(files)`
```bash
style_issues=$(check_code_style "$files")
```
- **Parameters**: Source files list
- **Checks**:
  - Indentation consistency (spaces vs tabs)
  - Line length (max 100-120 chars recommended)
  - Naming conventions
  - Comment style
- **Returns**: Style violations

##### `analyze_complexity(files)`
```bash
complexity=$(analyze_complexity "$files")
```
- **Parameters**: Source files
- **Metrics**:
  - Cyclomatic complexity (max 10 recommended)
  - Nesting depth (max 4 recommended)
  - Function length (max 50 lines recommended)
  - File length (max 500 lines recommended)
- **Tools**: complexity analysis based on language
- **Returns**: Complexity metrics per file/function

##### `build_quality_review_prompt(context)`
```bash
prompt=$(build_quality_review_prompt "$context")
```
- **Parameters**: Quality context (files, issues, metrics)
- **AI Task**:
  - Review code for best practices
  - Identify anti-patterns
  - Suggest refactoring opportunities
  - Check error handling
  - Validate documentation in code
- **Context Includes**:
  - Language-specific conventions (if PRIMARY_LANGUAGE set)
  - Project kind expectations
  - Tech stack patterns
- **Returns**: Formatted prompt for code_reviewer persona

**Example Analysis Output**:
```markdown
## Code Quality Issues

### High Priority
- `src/api/users.js`: Function `validateUser` has cyclomatic complexity of 15 (threshold: 10)
- `src/utils/parser.js`: Missing error handling for file I/O operations

### Medium Priority  
- `src/lib/helpers.js`: 4 functions exceed 50 lines
- Inconsistent indentation (mix of 2 and 4 spaces)

### Recommendations
1. Refactor `validateUser` into smaller functions
2. Add try-catch blocks for file operations
3. Configure Prettier for consistent formatting
```

**AI-Powered Review**:
- Language-aware analysis
- Context-sensitive recommendations
- Prioritized issue list
- Refactoring suggestions

**Performance**:
- Parallel file analysis
- Cached lint results
- Smart execution skip if no code changes

---

### Step 10: Context Analysis

**File**: `step_10_context.sh` (351 lines)  
**Purpose**: Analyze cross-cutting concerns and project-wide context  
**Dependencies**: Step 09  
**AI Personas**: `context_analyst`  
**Execution**: ~2-3 minutes

#### Key Functions

##### `step10_context_analysis()`
```bash
step10_context_analysis
```
- **Description**: High-level contextual analysis of the project
- **Logic**:
  1. Aggregate insights from previous steps
  2. Analyze cross-cutting concerns (logging, error handling, security)
  3. Check architectural consistency
  4. Identify integration points
  5. Generate context report
- **Returns**: 0 on success

##### `aggregate_step_insights()`
```bash
insights=$(aggregate_step_insights)
```
- **Description**: Collects key findings from Steps 1-9
- **Aggregates**:
  - Documentation issues (Step 1-3)
  - Test coverage (Step 5-7)
  - Dependencies (Step 8)
  - Code quality (Step 9)
- **Returns**: Combined insights JSON object

##### `analyze_cross_cutting_concerns()`
```bash
concerns=$(analyze_cross_cutting_concerns)
```
- **Analyzes**:
  - **Logging**: Consistent logging strategy across modules
  - **Error Handling**: Uniform error propagation patterns
  - **Security**: Authentication, authorization, input validation
  - **Performance**: Caching, database queries, resource usage
  - **Configuration**: Environment variables, config management
- **Returns**: List of cross-cutting issues

##### `check_architectural_consistency()`
```bash
arch_issues=$(check_architectural_consistency)
```
- **Validates**:
  - Module boundaries respected
  - Dependency flow (no circular dependencies)
  - Separation of concerns
  - Design patterns followed consistently
- **Returns**: Architectural inconsistencies

##### `identify_integration_points()`
```bash
integrations=$(identify_integration_points)
```
- **Detects**:
  - External API calls
  - Database connections
  - File system operations
  - Third-party service integrations
- **Returns**: List of integration points with metadata

##### `build_context_prompt(insights, concerns)`
```bash
prompt=$(build_context_prompt "$insights" "$concerns")
```
- **Parameters**:
  - `insights`: Aggregated step insights
  - `concerns`: Cross-cutting concerns
- **AI Task**:
  - Synthesize project-wide view
  - Identify systemic issues
  - Suggest architectural improvements
  - Provide strategic recommendations
- **Returns**: Formatted prompt for context_analyst persona

**Example Context Report**:
```markdown
## Project Context Analysis

### Architecture Overview
- **Pattern**: Modular monolith with clear boundaries
- **Layers**: Library modules (62), Step modules (18), Orchestrators (4)
- **Dependencies**: Unidirectional (orchestrator → steps → lib)

### Cross-Cutting Concerns
✅ **Logging**: Consistent use of print_* functions from colors.sh
✅ **Error Handling**: Uniform error codes and propagation
⚠️  **Configuration**: Mixed config sources (env vars, YAML, defaults)
❌ **Security**: No input validation in user-facing functions

### Integration Points
- GitHub Copilot CLI (ai_helpers.sh)
- Git commands (git_cache.sh)
- File system (extensive, uses mktemp for safety)
- YAML parsing (yq dependency)

### Recommendations
1. Consolidate configuration into single source
2. Add input validation layer for external data
3. Consider API rate limiting for Copilot calls
```

**AI Analysis**:
- Strategic recommendations
- Architecture evolution suggestions
- Risk assessment
- Technical debt identification

---

## Finalization (11-13)

### Step 11: Git Finalization

**File**: `step_11_git.sh` (442 lines)  
**Purpose**: Stage changes, generate commit message, push to remote  
**Dependencies**: All previous steps (runs after workflow completion)  
**AI Personas**: `git_specialist`  
**Execution**: ~30 seconds - 2 minutes

#### Key Functions

##### `step11_git_finalization()`
```bash
step11_git_finalization
```
- **Description**: Complete git workflow automation
- **Logic**:
  1. Analyze repository state
  2. Stage all changes (atomic staging v2.7.0)
  3. Generate commit message (AI or heuristic)
  4. Commit with comprehensive message
  5. Push to remote (if configured)
- **Returns**: 0 on success, 1 on failure

##### Atomic Staging (NEW v2.7.0)
```bash
# Phase: Reset mixed staged/unstaged state
git reset HEAD 2>/dev/null || true

# Phase: Atomic staging with verification
git add -A
staged=$(git diff --cached --name-only | wc -l)
unstaged=$(git diff --name-only | wc -l)

if [[ $unstaged -gt 0 ]]; then
    print_error "Mixed staging state detected - aborting"
    return 1
fi
```
- **Purpose**: Prevents partial commits and state confusion
- **Process**:
  1. Reset any mixed staged/unstaged state
  2. Stage all changes atomically with `git add -A`
  3. Verify no mixed state remains
  4. Abort if inconsistency detected

##### `generate_commit_message([mode])`
```bash
message=$(generate_commit_message "ai-batch")
```
- **Parameters**: Mode - "interactive", "ai-batch", "auto"
- **Modes**:
  - **Interactive**: User pastes AI-generated message (manual)
  - **AI Batch** (`--ai-batch`): Automatic AI generation (NEW v2.7.0)
  - **Auto** (`--auto`): Heuristic conventional commit
- **Returns**: Commit message text

**AI Batch Mode** (NEW v2.7.0):
```bash
# Automatic AI commit message generation
ai_call "git_specialist" "$prompt" "$commit_msg_file"
```
- Non-interactive AI invocation using Copilot CLI
- Enhanced fallback with full context
- Maintains backward compatibility

##### `infer_commit_type(changes)`
```bash
commit_type=$(infer_commit_type "$git_changes")
```
- **Parameters**: Git change statistics
- **Inference**:
  - `feat`: New features or code changes
  - `fix`: Bug fixes
  - `docs`: Documentation only
  - `test`: Test changes only
  - `refactor`: Code refactoring
  - `chore`: Build, config, dependencies
  - `style`: Formatting, no code change
- **Returns**: Conventional commit type

##### `build_commit_body(changes, analysis)`
```bash
body=$(build_commit_body "$changes" "$analysis")
```
- **Parameters**:
  - `changes`: Git diff statistics
  - `analysis`: Workflow step summaries
- **Generates**:
  - Change summary (files modified, added, deleted)
  - Key improvements from workflow
  - Test results
  - Breaking changes (if any)
- **Returns**: Commit message body

**Example Commit Message**:
```
feat(workflow): add ML-driven optimization and multi-stage pipeline

Implements predictive workflow intelligence and progressive validation
for improved performance and user experience.

Changes:
- Added 3 new modules: ml_optimizer.sh, ml_trainer.sh, pipeline_stages.sh
- Modified 8 workflow steps for ML integration
- Added 12 new tests (100% coverage maintained)
- Updated documentation (15 files)

Performance:
- 15-30% improvement with ML predictions
- 80%+ workflows complete in first 2 stages

Tests: ✅ All 49 tests passing
```

##### `push_to_remote()`
```bash
push_to_remote
```
- **Description**: Pushes committed changes to remote repository
- **Safety Checks**:
  - Verifies remote exists
  - Checks branch is tracking
  - Handles push rejection (fetch + rebase)
- **Returns**: 0 on success

**Dry-Run Mode**:
```bash
if [[ "$DRY_RUN" == true ]]; then
    print_info "[DRY RUN] Would stage, commit, and push changes"
    return 0
fi
```

**Git Cache Integration**:
- Uses cached git state for analysis (performance)
- Refreshes cache before committing (accuracy)
- Cache functions: `get_git_*` from git_cache.sh

**Error Recovery**:
```bash
# Graceful handling of push failures
if ! git push origin "$branch" 2>/dev/null; then
    print_warning "Push failed - manual intervention may be needed"
    print_info "Try: git pull --rebase && git push"
    return 1  # Non-fatal - changes are committed locally
fi
```

---

### Step 12: Markdown Linting

**File**: `step_12_markdown_lint.sh` (219 lines)  
**Purpose**: Validate markdown formatting and style  
**Dependencies**: Step 01 (documentation)  
**AI Personas**: `markdown_linter`  
**Execution**: ~1-2 minutes

#### Key Functions

##### `step12_markdown_lint()`
```bash
step12_markdown_lint
```
- **Description**: Comprehensive markdown validation
- **Logic**:
  1. Find all markdown files
  2. Run markdownlint (if available)
  3. Check custom style rules
  4. Validate markdown structure
  5. Generate lint report
- **Returns**: 0 if no issues, 1 if warnings/errors

##### `find_markdown_files()`
```bash
md_files=$(find_markdown_files)
```
- **Searches**: `*.md` files recursively
- **Excludes**: node_modules/, vendor/, .git/
- **Returns**: List of markdown files

##### `run_markdownlint(files)`
```bash
lint_results=$(run_markdownlint "$md_files")
```
- **Parameters**: Markdown files to lint
- **Tool**: markdownlint-cli (if available)
- **Rules Checked**:
  - MD001: Heading levels increment by one
  - MD003: Heading style (ATX, #)
  - MD013: Line length (configurable)
  - MD022: Blank lines around headings
  - MD032: Blank lines around lists
- **Configuration**: Uses `.markdownlint.json` if present
- **Returns**: Lint issues with line numbers

##### `check_custom_rules(file)`
```bash
issues=$(check_custom_rules "README.md")
```
- **Parameters**: Markdown file path
- **Custom Checks**:
  - No trailing whitespace
  - Consistent list markers (- vs *)
  - Code block language specified
  - No bare URLs (use [text](url))
  - Consistent heading capitalization
- **Returns**: Custom rule violations

##### `validate_markdown_structure(file)`
```bash
validate_markdown_structure "docs/guide.md"
```
- **Parameters**: Markdown file
- **Validates**:
  - Has H1 heading (title)
  - Heading hierarchy (no skipping levels)
  - Table of contents matches headings
  - Internal links valid
  - Code blocks properly closed
- **Returns**: 0 if valid, 1 if structural issues

##### `generate_lint_report(results)`
```bash
generate_lint_report "$lint_results" > report.md
```
- **Parameters**: Combined lint results
- **Report Includes**:
  - Summary (files checked, issues found)
  - Issues by severity (error, warning)
  - Issues by file
  - Fix suggestions
- **Returns**: Formatted markdown report

**Example Lint Output**:
```markdown
## Markdown Lint Report

### Summary
- Files checked: 47
- Issues found: 8 warnings, 2 errors

### Errors
1. `docs/API.md:142` - MD013: Line too long (135/120)
2. `README.md:56` - MD001: Heading skipped (### after #)

### Warnings
1. `docs/guide.md:89` - MD032: Missing blank line before list
2. `CHANGELOG.md:34` - Custom: Bare URL without markdown link
```

**Auto-fix Support**:
```bash
# If markdownlint-cli supports --fix
if [[ "${AUTO_FIX:-false}" == "true" ]]; then
    markdownlint --fix "$md_files"
fi
```

**AI Analysis**:
- Reviews style consistency
- Suggests documentation structure improvements
- Identifies documentation smells

---

### Step 13: Prompt Engineer Analysis

**File**: `step_13_prompt_engineer.sh` (517 lines)  
**Purpose**: Analyze and optimize AI persona prompts  
**Dependencies**: Step 00  
**AI Personas**: `prompt_engineer`  
**Execution**: ~2-3 minutes  
**Scope**: Only runs on `shell_automation` projects (ai_workflow itself)

#### Key Functions

##### `step13_prompt_engineer_analysis()`
```bash
step13_prompt_engineer_analysis
```
- **Description**: Meta-analysis of AI prompt quality
- **Logic**:
  1. Check if step should run (project kind check)
  2. Load AI persona prompts from config
  3. Analyze prompt structure and clarity
  4. Check token efficiency
  5. Generate optimization recommendations
  6. Create GitHub issues for improvements (optional)
- **Returns**: 0 on success

##### `should_run_prompt_analysis()`
```bash
if should_run_prompt_analysis; then
    step13_prompt_engineer_analysis
fi
```
- **Description**: Determines if prompt analysis should run
- **Scope Restriction**: Only `shell_automation` or `bash-automation-framework`
- **Rationale**: Prevents analyzing prompts in unrelated projects
- **Returns**: 0 if should run, 1 if skip

##### `load_ai_prompts()`
```bash
prompts=$(load_ai_prompts)
```
- **Source**: `.workflow_core/config/ai_helpers.yaml`
- **Loads**: All AI persona prompt templates
- **Returns**: JSON object with persona → prompt mapping

##### `analyze_prompt_quality(prompt, persona)`
```bash
analysis=$(analyze_prompt_quality "$prompt" "code_reviewer")
```
- **Parameters**:
  - `prompt`: Prompt template text
  - `persona`: Persona name
- **Checks**:
  - **Clarity**: Instructions clear and unambiguous
  - **Completeness**: All necessary context included
  - **Consistency**: Terminology and style uniform
  - **Specificity**: Concrete examples and expectations
  - **Token Efficiency**: Concise without losing clarity
- **Returns**: Quality metrics and issues

##### `check_token_efficiency(prompt)`
```bash
efficiency=$(check_token_efficiency "$prompt")
```
- **Parameters**: Prompt text
- **Calculates**:
  - Estimated token count
  - Redundancy score
  - Unnecessary verbosity
  - Optimization potential
- **Approximation**: ~4 characters per token (English)
- **Returns**: Efficiency metrics

##### `generate_optimization_recommendations(analysis)`
```bash
recommendations=$(generate_optimization_recommendations "$analysis")
```
- **Parameters**: Prompt analysis results
- **Generates**:
  - Specific improvements per prompt
  - Rewrite suggestions
  - Token reduction opportunities
  - Context enhancement ideas
- **Returns**: Prioritized recommendations

##### `create_github_issues(recommendations)`
```bash
create_github_issues "$recommendations"
```
- **Parameters**: Optimization recommendations
- **Creates**: GitHub issues for prompt improvements (if `--create-issues` flag set)
- **Issue Template**:
  - Title: "Optimize [persona] prompt - [issue]"
  - Labels: prompt-engineering, enhancement
  - Body: Current prompt, issue, suggested improvement
- **Returns**: 0 on success

**Example Analysis Output**:
```markdown
## Prompt Engineer Analysis

### Persona: code_reviewer

**Current Token Count**: ~850 tokens
**Optimization Potential**: 15-20% reduction

#### Issues
1. **Redundancy**: "code quality" mentioned 4 times
2. **Verbosity**: Long explanation could be bullet points
3. **Missing**: No specific examples of good vs bad code

#### Recommendations
1. Consolidate repeated concepts
2. Convert prose to structured format (bullets, numbered lists)
3. Add 2-3 concrete examples
4. Estimated savings: ~150 tokens

### Persona: test_engineer
...
```

**AI-Powered Analysis**:
- Meta-analysis (AI reviewing AI prompts)
- Benchmarking against prompt engineering best practices
- Context-aware optimization

**Integration**:
```bash
# Automatically runs only on ai_workflow itself
if [[ "$PROJECT_KIND" == "shell_automation" ]]; then
    step13_prompt_engineer_analysis
fi
```

---

### Step 11.7: Front-End Development Analysis

**File**: `step_11_7_frontend_dev.sh` (653 lines)  
**Purpose**: Analyze front-end code for technical implementation quality and performance  
**Dependencies**: Step 10 (code quality)  
**AI Personas**: `front_end_developer` (NEW v4.0.1)  
**Execution**: ~3-5 minutes  
**Scope**: Only runs for projects with front-end code (React, Vue, Angular, Svelte, etc.)

#### Key Functions

##### `step11_7_frontend_dev_analysis()`
```bash
# Main execution function
step11_7_frontend_dev_analysis
```
- **Phase 1**: Discover front-end files (JSX, TSX, Vue, Svelte)
- **Phase 2**: Analyze structure (framework, build tool, state management)
- **Phase 3**: Run AI-powered technical analysis
- **Returns**: 0 for success, 1 for skip (no front-end code)

##### `has_frontend_code()`
```bash
if has_frontend_code; then
    echo "Front-end code detected"
fi
```
- **Project Detection**:
  - Checks project kind (react_spa, vue_spa, client_spa, static_website)
  - Scans for component files (*.jsx, *.tsx, *.vue, *.svelte)
  - Detects frameworks in package.json
  - Identifies static websites (HTML + CSS)
- **Returns**: 0 if front-end detected, 1 otherwise

##### `find_frontend_files()`
```bash
frontend_files=$(find_frontend_files)
```
- **File Types**:
  - React: `*.jsx`, `*.tsx`
  - Vue: `*.vue`
  - Svelte: `*.svelte`
  - JavaScript: `src/components/*.js`, `src/pages/*.js`
  - TypeScript: `src/components/*.ts` (non-declaration files)
- **Excludes**: node_modules/, dist/, build/, .git/
- **Returns**: List of front-end files (up to 100)

##### `analyze_frontend_structure()`
```bash
structure=$(analyze_frontend_structure)
```
- **Parameters**: None (uses TARGET_PROJECT_ROOT)
- **Analysis**:
  - **Framework Detection**: React, Vue, Angular, Svelte
  - **Build Tool**: Vite, Webpack, CRA, Next.js
  - **State Management**: Redux, Zustand, Vuex, Pinia
  - **Component Counts**: By file type
  - **CSS Files**: Count
- **Returns**: JSON object with structure analysis

**Structure Analysis Example**:
```json
{
  "framework": "React",
  "build_tool": "Vite",
  "state_management": "Zustand",
  "component_counts": {
    "jsx": 15,
    "tsx": 42,
    "vue": 0,
    "svelte": 0
  },
  "css_files": 8
}
```

##### `build_frontend_dev_prompt(files, analysis)`
```bash
prompt=$(build_frontend_dev_prompt "$frontend_files" "$structure_analysis")
```
- **Parameters**: Frontend files list, structure analysis JSON
- **AI Task**:
  - Review component architecture and composition
  - Identify performance bottlenecks
  - Validate TypeScript usage and type safety
  - Evaluate state management patterns
  - Check accessibility implementation (ARIA, semantic HTML)
  - Assess testing coverage
  - Review build configuration
- **Returns**: Formatted prompt for front_end_developer persona

**Example Front-End Analysis Report**:
```markdown
## Front-End Development Analysis Report

### Executive Summary
57 components analyzed
- 5 critical issues (performance)
- 12 improvements (architecture)
- 8 optimizations (bundle size)

### Critical Issues

#### Issue 1: Unnecessary Re-renders in UserList
- **File**: src/components/UserList.tsx:45
- **Issue**: Component re-renders on every parent update
- **Impact**: Performance degradation (Lighthouse score: 65)
- **Fix**: Wrap with React.memo and useCallback for handlers
```typescript
export const UserList = React.memo(({ users, onSelect }) => {
  const handleSelect = useCallback((id) => onSelect(id), [onSelect]);
  // ...
});
```

### Architecture & Design

✅ **Good Patterns**:
- Component composition with HOCs
- Props properly typed with TypeScript
- Clear separation of presentational and container components

⚠️ **Needs Improvement**:
- Props drilling in 3 components (consider Context API)
- Large component files (>300 lines): refactor into smaller components

### Performance Optimizations

1. **Bundle Size**: 450KB (target: <300KB)
   - Implement code splitting for routes
   - Lazy load heavy components (Chart.js, Monaco Editor)
   - Tree-shake unused lodash functions

2. **Re-render Optimization**:
   - Add React.memo to 8 components
   - Use useMemo for expensive calculations
   - Implement virtual scrolling for long lists

### Code Quality

- **TypeScript Coverage**: 85% (target: 95%)
- **Test Coverage**: 72% (target: 80%)
- **ESLint Issues**: 23 warnings, 2 errors

### Accessibility Implementation

✅ **Good**: Semantic HTML structure
⚠️ **Needs Work**: Missing ARIA labels on 5 interactive elements
❌ **Critical**: No focus indicators on buttons

### Recommendations

1. **High Priority**: Add focus indicators (accessibility - WCAG 2.1 AA)
2. **Medium Priority**: Implement code splitting for routes
3. **Low Priority**: Increase TypeScript coverage to 95%
```

**AI-Powered Technical Analysis**:
- Component architecture patterns
- Performance bottlenecks identification
- Type safety validation
- Accessibility implementation review
- Testing coverage assessment

**Integration with Project Kinds**:
```bash
# Automatically runs for front-end projects
case "$PROJECT_KIND" in
    react_spa|vue_spa|static_website|client_spa)
        step11_7_frontend_dev_analysis
        ;;
esac
```

**Relationship with Step 15 (UX Analysis)**:
- **Step 11.7**: Technical implementation (code architecture, performance, testing)
- **Step 15**: User experience (usability, visual design, interaction patterns)
- Run sequentially: Technical quality → User experience quality

---

## Specialized Analysis (14-15)

### Step 15: UX Analysis

**File**: `step_15_ux_analysis.sh` (634 lines)  
**Purpose**: Analyze UI for user experience and visual design quality  
**Dependencies**: Step 11.7 (front-end development)  
**AI Personas**: `ui_ux_designer` (UPDATED v4.0.1)  
**Execution**: ~3-5 minutes  
**Scope**: Only runs for projects with UI components

#### Key Functions

##### `step15_ux_analysis()`
```bash
step15_ux_analysis
```
- **Description**: Comprehensive UX and accessibility analysis
- **Logic**:
  1. Check if project has UI components
  2. Find UI files (React, Vue, HTML)
  3. Analyze accessibility (WCAG 2.1)
  4. Check usability patterns
  5. Review responsive design
  6. Generate UX report
- **Returns**: 0 on success

##### `has_ui_components()`
```bash
if has_ui_components; then
    step15_ux_analysis
fi
```
- **Description**: Detects if project has UI components
- **Detection**:
  1. Check PROJECT_KIND (react_spa, vue_spa, static_website)
  2. Find UI files (*.jsx, *.tsx, *.vue, index.html)
  3. Check for UI frameworks in dependencies
- **Returns**: 0 if UI detected, 1 otherwise

##### `should_run_ux_analysis_step()`
```bash
if should_run_ux_analysis_step; then
    # Run UX analysis
fi
```
- **Description**: Determines if UX analysis should run
- **Checks**:
  - Step relevance from project kind configuration
  - UI component presence
  - Skip flag (`--skip-ux` option)
- **Returns**: 0 if should run, 1 if skip

##### `find_ui_files()`
```bash
ui_files=$(find_ui_files)
```
- **File Types**:
  - React: `*.jsx`, `*.tsx`
  - Vue: `*.vue`
  - Static: `*.html`, `*.css`
  - Angular: `*.component.ts`, `*.component.html`
- **Excludes**: node_modules/, dist/, build/
- **Returns**: List of UI files

##### `analyze_accessibility(files)`
```bash
a11y_issues=$(analyze_accessibility "$ui_files")
```
- **Parameters**: UI files list
- **WCAG 2.1 Checks**:
  - **Perceivable**:
    - Alt text for images
    - Color contrast ratios
    - Text alternatives for non-text content
  - **Operable**:
    - Keyboard navigation
    - Focus indicators
    - Skip links
  - **Understandable**:
    - Form labels
    - Error messages
    - Consistent navigation
  - **Robust**:
    - Semantic HTML
    - ARIA attributes
    - Valid markup
- **Returns**: Accessibility violations with severity

**Accessibility Analysis Example**:
```javascript
// Detected issue in React component
<button onClick={handleClick}>  {/* Missing accessible label */}
  <img src="icon.png" />  {/* Missing alt text */}
</button>

// Recommended fix
<button 
  onClick={handleClick}
  aria-label="Submit form"
>
  <img src="icon.png" alt="Submit icon" />
</button>
```

##### `check_usability_patterns(files)`
```bash
usability_issues=$(check_usability_patterns "$ui_files")
```
- **Parameters**: UI files
- **Patterns Checked**:
  - Loading states (spinners, skeletons)
  - Error handling (user-friendly messages)
  - Empty states (no data scenarios)
  - Form validation (inline feedback)
  - Button states (disabled, loading)
  - Navigation clarity
- **Returns**: Usability issues and recommendations

##### `review_responsive_design(files)`
```bash
responsive_issues=$(review_responsive_design "$ui_files")
```
- **Parameters**: UI files
- **Checks**:
  - Media queries present
  - Viewport meta tag
  - Flexible layouts (flexbox, grid)
  - Mobile-first approach
  - Touch-friendly targets (min 44x44px)
- **Returns**: Responsive design issues

##### `build_ux_review_prompt(context)`
```bash
prompt=$(build_ux_review_prompt "$context")
```
- **Parameters**: UX analysis context (files, issues, patterns)
- **AI Task**:
  - Review UI code for usability
  - Identify accessibility barriers
  - Suggest UX improvements
  - Check design consistency
  - Validate user workflows
- **Returns**: Formatted prompt for ux_designer persona

**Example UX Report**:
```markdown
## UX Analysis Report

### Accessibility Issues (WCAG 2.1)

#### Critical (A-level)
- 5 images missing alt text
- 3 form inputs without labels
- 2 buttons without accessible names

#### Serious (AA-level)
- 8 color contrast violations (text too light)
- No focus indicators on interactive elements

#### Moderate (AAA-level)
- Line height < 1.5 in body text

### Usability Patterns

✅ **Good**
- Loading states implemented consistently
- Error messages user-friendly

⚠️ **Needs Improvement**
- No empty state handling in data tables
- Form validation only on submit (no inline)

❌ **Missing**
- No keyboard shortcuts
- No undo/redo functionality

### Responsive Design

✅ Mobile-first CSS architecture
⚠️ Touch targets < 44px on 3 buttons
❌ No viewport meta tag in HTML

### Recommendations
1. Add alt text to all images (use empty alt="" for decorative)
2. Ensure 4.5:1 contrast ratio for all text
3. Implement focus indicators (outline or ring)
4. Add empty states with helpful CTAs
5. Add viewport meta tag: `<meta name="viewport" content="width=device-width, initial-scale=1">`
```

**AI-Powered Review**:
- Context-aware UX suggestions
- Pattern recognition (anti-patterns)
- Industry best practices
- Prioritized recommendations

**Integration with Project Kinds**:
```bash
# Automatically runs for UI-focused projects
case "$PROJECT_KIND" in
    react_spa|vue_spa|static_website|client_spa)
        step15_ux_analysis
        ;;
esac
```

---

### Step 16: Semantic Version Update

**File**: `step_16_version_update.sh` (484 lines)  
**Purpose**: Update semantic versions in files and project metadata  
**Dependencies**: Steps 10, 11.7, 12, 13, 15 (runs after analysis)  
**AI Personas**: `version_specialist`  
**Execution**: ~30 seconds - 1 minute

#### Key Functions

##### `step15_version_update()`
```bash
step15_version_update
```
- **Description**: Post-workflow semantic version updates
- **Logic**:
  1. Detect files with version patterns
  2. Determine bump type (major/minor/patch) via AI or heuristics
  3. Update version numbers consistently
  4. Update CHANGELOG.md
  5. Stage version changes
- **Returns**: 0 on success, 1 on failure

##### `detect_version_patterns(file)`
```bash
patterns=$(detect_version_patterns "package.json")
```
- **Parameters**: File to scan for versions
- **Patterns Matched**:
  - `"version": "1.2.3"` (package.json)
  - `VERSION="1.2.3"` (shell scripts)
  - `__version__ = "1.2.3"` (Python)
  - `version = "1.2.3"` (Cargo.toml)
  - `@version 1.2.3` (JSDoc, docblock)
- **Returns**: Line numbers with version matches

##### `increment_version(version, bump_type)`
```bash
new_version=$(increment_version "1.2.3" "minor")  # Returns "1.3.0"
```
- **Parameters**:
  - `version`: Current version (X.Y.Z)
  - `bump_type`: major|minor|patch
- **Semantics**:
  - **major**: Breaking changes (1.0.0 → 2.0.0)
  - **minor**: New features (1.2.3 → 1.3.0)
  - **patch**: Bug fixes (1.2.3 → 1.2.4)
- **Returns**: New version string

##### `determine_heuristic_bump_type()`
```bash
bump_type=$(determine_heuristic_bump_type)
```
- **Description**: Determines version bump using heuristics (fallback when AI unavailable)
- **Heuristics**:
  - **Major**: > 50% files changed, breaking changes in commit messages
  - **Minor**: New files added, new features in commits
  - **Patch**: Small changes, bug fixes, documentation only
- **Returns**: major|minor|patch

##### `determine_ai_bump_type(changes)`
```bash
bump_type=$(determine_ai_bump_type "$change_summary")
```
- **Parameters**: Summary of changes (git diff, step summaries)
- **AI Analysis**:
  - Analyzes change impact
  - Identifies breaking changes
  - Categorizes by semver convention
  - Provides reasoning
- **Returns**: major|minor|patch with confidence

##### `update_version_in_file(file, old_version, new_version)`
```bash
update_version_in_file "package.json" "1.2.3" "1.3.0"
```
- **Parameters**:
  - `file`: File to update
  - `old_version`: Current version
  - `new_version`: New version
- **Safety**:
  - Backup before modification
  - Atomic write
  - Verify change applied
- **Returns**: 0 on success

##### `update_changelog(new_version, changes)`
```bash
update_changelog "1.3.0" "$change_summary"
```
- **Parameters**:
  - `new_version`: Version being released
  - `changes`: Change summary
- **Updates**: CHANGELOG.md with new entry
- **Format**: Keep a Changelog format
```markdown
## [1.3.0] - 2026-01-31

### Added
- New feature X
- New feature Y

### Changed
- Improved performance of Z

### Fixed
- Bug in module A
```
- **Returns**: 0 on success

**Version Update Strategy**:
```bash
# Step 0a (pre-workflow): Pre-increment modified files
# - Updates version in recently changed files only
# - Used for incremental development

# Step 15 (post-workflow): Post-increment all versions
# - Updates version consistently across all files
# - Finalizes version for release
# - Updates changelog
# - Used for release preparation
```

**AI-Powered Analysis**:
- Intelligent bump type detection
- Breaking change identification
- Release note generation

**Integration with Git**:
```bash
# Automatically stage version changes
git add package.json CHANGELOG.md src/**/*.js

# Tag release (optional, with --tag-release)
git tag -a "v${new_version}" -m "Release ${new_version}"
```

---

## Common Patterns

### Step Validation

All steps implement a validation function to check prerequisites:

```bash
validate_step_XX() {
    # Check if step should run
    if [[ "${SKIP_STEP_XX:-false}" == "true" ]]; then
        print_info "Step XX skipped (SKIP_STEP_XX=true)"
        return 1
    fi
    
    # Check dependencies
    if ! command -v required_tool &>/dev/null; then
        print_warning "required_tool not found - skipping step XX"
        return 1
    fi
    
    # Check relevance (project kind)
    if [[ "$PROJECT_KIND" != "relevant_kind" ]]; then
        print_info "Step XX not relevant for $PROJECT_KIND"
        return 1
    fi
    
    return 0  # Ready to run
}
```

### AI Integration Pattern

Steps that use AI follow this pattern:

```bash
# 1. Check Copilot availability
if ! check_copilot_available; then
    print_warning "Copilot CLI not available - using fallback"
    # ... fallback logic
    return 0
fi

# 2. Build context-aware prompt
prompt=$(build_prompt_for_step "$context")

# 3. Call AI with caching
ai_call "persona_name" "$prompt" "$output_file"

# 4. Process response
process_ai_response "$output_file"
```

### Report Generation

Each step generates a standardized report:

```bash
# Save step issues (problems found)
save_step_issues "XX" "Step_Name" "$issues_content"

# Save step summary (what was done)
save_step_summary "XX" "Step_Name" "$summary" "$status_icon"

# Update workflow status
update_workflow_status "stepXX" "$status_icon"
```

### Error Handling

Consistent error handling across steps:

```bash
execute_step_XX() {
    # Set up cleanup
    local temp_file=$(mktemp)
    TEMP_FILES+=("$temp_file")
    
    # Main logic with error handling
    if ! some_operation; then
        print_error "Operation failed"
        # Clean up happens automatically via TEMP_FILES
        return 1
    fi
    
    # Success
    return 0
}
```

### Dependency Management

Steps declare dependencies for execution order:

```bash
# In src/workflow/lib/dependency_graph.sh
get_step_dependencies() {
    case "$1" in
        "5") echo "4" ;;          # Step 5 depends on Step 4
        "6") echo "5" ;;          # Step 6 depends on Step 5
        "7") echo "6" ;;          # Step 7 depends on Step 6
        "11") echo "0 1 2 3 4 5 6 7 8 9 10 12 13 14 15" ;;  # Step 11 runs last
        *) echo "" ;;             # No dependencies
    esac
}
```

---

## Error Handling

### Exit Codes

Standardized exit codes across all steps:

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Continue workflow |
| 1 | Failure | Halt workflow (unless --continue-on-error) |
| 2 | Skipped | Continue to next step |

### Error Propagation

```bash
# Main orchestrator handles step errors
if ! execute_step_XX; then
    step_status="❌"
    update_workflow_status "stepXX" "❌"
    
    if [[ "${CONTINUE_ON_ERROR:-false}" != "true" ]]; then
        print_error "Step XX failed - halting workflow"
        exit 1
    fi
    
    print_warning "Step XX failed - continuing (--continue-on-error)"
fi
```

### Cleanup Handlers

Steps register cleanup handlers for temporary files:

```bash
# Automatic cleanup on exit
TEMP_FILES=()

cleanup_step() {
    for file in "${TEMP_FILES[@]}"; do
        rm -f "$file" 2>/dev/null || true
    done
}

trap cleanup_step EXIT
```

### Graceful Degradation

Steps gracefully handle missing optional dependencies:

```bash
# Example: AI unavailable
if ! check_copilot_available; then
    print_warning "AI features unavailable - using heuristics"
    # ... fallback to non-AI logic
    return 0  # Success with degraded functionality
fi
```

---

## Related Documentation

- **Main Orchestrator**: `src/workflow/execute_tests_docs_workflow.sh`
- **Step Directory README**: `src/workflow/steps/README.md`
- **Library Modules API**: `docs/reference/API_REFERENCE.md`
- **Orchestrators API**: `docs/reference/API_ORCHESTRATORS.md` (TODO)
- **Workflow Diagrams**: `docs/reference/workflow-diagrams.md`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`

---

**Document Version**: 1.0.0  
**Workflow Version**: v3.0.0  
**Last Updated**: 2026-01-31
