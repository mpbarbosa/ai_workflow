# Consolidated Functional Requirements Document

**Document Version:** 2.4.1  
**Date:** December 23, 2025  
**Status:** Active  
**Author:** Automated Workflow System

---

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Step 1: Documentation Updates](#step-1-documentation-updates)
- [Step 2: Documentation Consistency Analysis](#step-2-documentation-consistency-analysis)
- [Step 3: Script Reference Validation](#step-3-script-reference-validation)
- [Client SPA Project Kind](#client-spa-project-kind)
- [Shell Automation Documentation Specialist Persona](#shell-automation-documentation-specialist-persona)
- [Workflow Step Dependencies and Execution Order](#workflow-step-dependencies-and-execution-order)
  - [FR-WF-1: Git Finalization Dependency on Context Analysis](#fr-wf-1-git-finalization-dependency-on-context-analysis)
  - [FR-WF-2: Workflow Step Sequence](#fr-wf-2-workflow-step-sequence)
  - [FR-WF-3: Execution Mode Requirements](#fr-wf-3-execution-mode-requirements)
  - [FR-WF-4: Validation and Testing Requirements](#fr-wf-4-validation-and-testing-requirements)
  - [FR-WF-5: Documentation Requirements](#fr-wf-5-documentation-requirements)
- [Cross-Cutting Concerns](#cross-cutting-concerns)
  - [Execution Modes](#execution-modes)
  - [Error Handling and Graceful Degradation](#error-handling-and-graceful-degradation)
  - [Third-Party File Exclusion](#third-party-file-exclusion)
  - [Temporary File Management](#temporary-file-management)
  - [Output and Reporting](#output-and-reporting)
- [Appendix](#appendix)

---

## Executive Summary

### Purpose

This consolidated document defines the functional requirements for Steps 1-3 of the Tests & Documentation Workflow Automation system, the CLIENT_SPA project kind configuration, and the Shell Automation Documentation Specialist AI persona. It provides a comprehensive reference for:

- **Step 1**: AI-powered documentation updates
- **Step 2**: Documentation consistency analysis
- **Step 3**: Script reference validation
- **CLIENT_SPA**: Project kind classification and standards
- **Shell Automation Persona**: Specialized AI persona for shell script automation documentation

### Scope

This document consolidates five separate functional requirement documents into a single authoritative reference, maintaining all technical details while improving navigation and cross-referencing.

### Module Overview

| Module | Version | Primary Responsibility |
| ------ | ------- | ---------------------- |
| Step 1 | 1.5.0 | Documentation updates with AI |
| Step 2 | 2.0.0 | Consistency and reference validation |
| Step 3 | 2.0.0 | Shell script reference validation |
| CLIENT_SPA | 1.0.0 | Vanilla JS SPA project classification |
| Shell Automation Persona | 1.0.0 | AI persona for shell script automation documentation |

---

## Step 1: Documentation Updates

**Module File:** `src/workflow/steps/step_01_documentation.sh`  
**Module Version:** 1.5.0  
**Dependencies:** AI Helpers Library, Git Cache Module, Step Execution Framework

### Overview

Step 1 is responsible for AI-powered documentation updates that maintain consistency between code changes and project documentation. It provides automated and semi-automated documentation review and update capabilities.

### Architecture Context

Step 1 integrates with:

- **AI Helpers Library** (`lib/ai_helpers.sh`) - Copilot CLI integration
- **Git Cache Module** (`lib/git_cache.sh`) - Efficient git state access
- **Backlog System** - Issue tracking and reporting
- **Logging System** - Execution audit trail

### Functional Requirements

#### FR-1.1: Version Management

**Priority:** High  
**Status:** Implemented

The system SHALL provide version information in multiple formats through the `step1_get_version()` function.

**Acceptance Criteria:**

- Support format options: `simple`, `full`, `semver`, `json`
- Return version string in requested format
- Default to `simple` format when no argument provided
- Support both `--format=X` and `X` argument syntax

**Formats:**

| Format | Output Example |
| ------ | -------------- |
| simple | `1.5.0` |
| full   | `Step 1 (Documentation Updates) v1.5.0` |
| semver | `Major: 1, Minor: 5, Patch: 0` |
| json   | `{"version":"1.5.0","major":1,"minor":5,"patch":0}` |

#### FR-1.2: Change Detection and File Mapping

**Priority:** Critical  
**Status:** Implemented

The system SHALL detect file changes using cached git state to identify affected documentation.

**Acceptance Criteria:**

- Retrieve changed files from git cache (via `get_git_diff_files_output()`)
- Display first 20 changed files to user
- Process full change list for documentation mapping
- Support dry-run mode without modifying repository state

**Routing Rules:**

```text
shell_scripts/**  → shell_scripts/README.md
src/scripts/**    → README.md
docs/**           → Notification only (already documentation)
```

#### FR-1.3: AI-Powered Analysis

**Priority:** High  
**Status:** Implemented

The system SHALL generate and execute AI prompts for documentation analysis using GitHub Copilot CLI.

**Acceptance Criteria:**

- Detect Copilot CLI availability via `is_copilot_available()`
- Verify authentication via `is_copilot_authenticated()`
- Build documentation analysis prompt via `build_doc_analysis_prompt()`
- Display prompt to user before execution
- Execute prompt with comprehensive tool access flags:
  - `--allow-all-tools` - Enable all Copilot CLI tools
  - `--allow-all-paths` - Enable file system access for all paths
  - `--enable-all-github-mcp-tools` - Enable all GitHub MCP tools
- Log session output with unique timestamp
- Handle execution failures gracefully

#### FR-1.4: Version Consistency Validation

**Priority:** High  
**Status:** Implemented

The system SHALL validate version consistency across project documentation files.

**Acceptance Criteria:**

- Check `README.md` for workflow version references
- Check `.github/copilot-instructions.md` for workflow version references
- Detect mismatches between script version (`SCRIPT_VERSION`) and documentation
- Report line numbers of inconsistent references
- Generate detailed version mismatch report

#### FR-1.5: Manual Documentation Editing

**Priority:** Medium  
**Status:** Implemented

The system SHALL provide manual editing capability for documentation files in interactive mode.

**Acceptance Criteria:**

- Prompt user for manual editing (only in interactive mode)
- Open each documentation file in configured editor (`$EDITOR` or `nano`)
- Respect user confirmation before opening editors
- Skip if user declines manual editing
- Only offer when documentation files require review

#### FR-1.6: Performance Optimizations (v1.5.0)

**Priority:** Medium  
**Status:** Implemented

The system SHALL implement performance caching for expensive operations.

**Cache Operations:**

| Function | Purpose | Cache Key Pattern |
| -------- | ------- | ----------------- |
| `init_performance_cache()` | Initialize cache | N/A |
| `get_or_cache()` | Generic caching | Custom key |
| `get_cached_git_diff()` | Git diff caching | `git_diff_files` |

**Parallel File Analysis:**

- Max Concurrent Jobs: 4
- Job Control: `wait -n` for first completion
- Result Aggregation: Temporary directory with per-file results
- Cleanup: Automatic via `TEMP_FILES` array

### Integration Points

**Library Dependencies:**

| Library | Purpose |
| ------- | ------- |
| `lib/ai_helpers.sh` | Copilot CLI integration, prompt building |
| `lib/git_cache.sh` | Efficient git state access |
| `lib/backlog.sh` | Issue tracking and reporting |
| `lib/summary.sh` | Step summary generation |
| `lib/colors.sh` | Terminal output formatting |
| `lib/utils.sh` | Confirmation prompts, file operations |
| `lib/validation.sh` | Workflow status tracking |

**Exported Functions:**

- `step1_update_documentation` - Main step execution
- `step1_get_version` - Version information retrieval

### Non-Functional Requirements

- **Performance**: Complete within 60 seconds for typical workflows (excluding AI analysis)
- **Usability**: Color-coded messages (success/error/warning/info)
- **Maintainability**: Modular architecture with single responsibility
- **Reliability**: Never fail workflow due to documentation issues
- **Security**: No sensitive information in logs or prompts
- **Auditability**: All actions logged with timestamps

---

## Step 2: Documentation Consistency Analysis

**Module File:** `src/workflow/steps/step_02_consistency.sh`  
**Module Version:** 2.0.0  
**Dependencies:** AI Helpers Library, Metrics Validation Library, Step Execution Framework

### Overview

Step 2 is responsible for AI-powered documentation consistency analysis that detects broken references, version inconsistencies, and metrics validation issues.

### Architecture Context

Step 2 integrates with:

- **AI Helpers Library** (`lib/ai_helpers.sh`) - Copilot CLI integration
- **Metrics Validation Library** (`lib/metrics_validation.sh`) - Documentation metrics consistency
- **Backlog System** - Issue tracking and reporting
- **Logging System** - Execution audit trail
- **Summary System** - Step completion reporting

### Functional Requirements

#### FR-2.1: Semantic Version Validation

**Priority:** High  
**Status:** Implemented

The system SHALL validate semantic version format (MAJOR.MINOR.PATCH) throughout documentation.

**Acceptance Criteria:**

- Support `validate_semver()` function for format validation
- Accept version patterns: `v1.2.3` or `1.2.3`
- Validate using regex: `^v?([0-9]+)\.([0-9]+)\.([0-9]+)$`
- Return 0 for valid semver, 1 for invalid
- Support optional `v` prefix

**Valid Formats:**

| Format | Valid | Example |
| ------ | ----- | ------- |
| MAJOR.MINOR.PATCH | ✅ | `2.0.0` |
| vMAJOR.MINOR.PATCH | ✅ | `v1.5.0` |
| MAJOR.MINOR | ❌ | `1.5` |
| vMAJOR | ❌ | `v2` |

#### FR-2.2: Broken Reference Detection

**Priority:** Critical  
**Status:** Implemented

The system SHALL detect broken absolute path references in documentation files.

**Acceptance Criteria:**

- Scan all markdown files in `docs/` directory
- Scan `README.md` in repository root
- Scan `.github/copilot-instructions.md` (critical for CI/CD)
- Extract absolute paths using regex: `(?<=\()(/[^)]+)(?=\))`
- Verify file existence for each reference
- Build full path: `${PROJECT_ROOT}${ref}`
- Report broken references with file location
- Save broken references to temporary file

**Priority Documentation Files:**

1. **README.md** - Main project documentation
2. **.github/copilot-instructions.md** - AI development guidelines
3. **docs/** directory - All documentation content

#### FR-2.3: Metrics Validation Integration

**Priority:** High  
**Status:** Implemented

The system SHALL validate metrics consistency across documentation using external validation library.

**Acceptance Criteria:**

- Source `lib/metrics_validation.sh` if available
- Execute `validate_all_documentation_metrics()` function
- Report validation success/failure with appropriate messaging
- Log warning if validation library not found
- Continue workflow on validation library absence (graceful degradation)

#### FR-2.4: AI-Powered Consistency Analysis

**Priority:** High  
**Status:** Implemented

The system SHALL generate and execute AI prompts for documentation consistency analysis.

**Prompt Components:**

| Component | Source | Purpose |
| --------- | ------ | ------- |
| Document Count | `fast_find()` | Scope quantification |
| Change Scope | `${CHANGE_SCOPE}` | Context from workflow |
| Modified Files | `${ANALYSIS_MODIFIED}` | Recent changes |
| Broken References | Broken refs file | Detected issues |
| File List | `fast_find()` sorted | Complete inventory |

**Acceptance Criteria:**

- Build comprehensive AI prompt via `build_step2_consistency_prompt()`
- Include documentation file count
- Include change scope from workflow context
- Include modified files analysis
- Include broken references content
- Include full documentation file list
- Display prompt to user before execution
- Execute with comprehensive tool access flags:
  - `--allow-all-tools` - Enable all Copilot CLI tools
  - `--allow-all-paths` - Enable file system access for all paths
  - `--enable-all-github-mcp-tools` - Enable all GitHub MCP tools
- Execute with logging to unique timestamped file

#### FR-2.5: Automated Documentation Inventory

**Priority:** Medium  
**Status:** Implemented

The system SHALL efficiently discover all documentation files in repository.

**Acceptance Criteria:**

- Use `fast_find()` with depth limit of 5
- Search pattern: `*.md`
- Exclude: `node_modules/`, `.git/`, `coverage/`
- Sort results alphabetically
- Count total files discovered
- Include in AI prompt context

### Integration Points

**Library Dependencies:**

| Library | Purpose | Required |
|---------|---------|----------|
| `lib/ai_helpers.sh` | Copilot CLI integration | ✅ Yes |
| `lib/metrics_validation.sh` | Metrics consistency | ⚠️ Optional |
| `lib/backlog.sh` | Issue tracking | ✅ Yes |
| `lib/summary.sh` | Step summary | ✅ Yes |
| `lib/colors.sh` | Terminal formatting | ✅ Yes |
| `lib/utils.sh` | File operations | ✅ Yes |
| `lib/validation.sh` | Status tracking | ✅ Yes |
| `lib/file_operations.sh` | Fast file discovery | ✅ Yes |

**Exported Functions:**

- `step2_check_consistency` - Main step execution
- `validate_semver` - Semantic version validation
- `extract_versions_from_file` - Version extraction
- `check_version_consistency` - Cross-document validation

### Non-Functional Requirements

- **Performance**: Complete automated checks within 30 seconds (excluding AI analysis)
  - Version consistency check: < 5 seconds
  - Broken reference detection: < 10 seconds
  - Documentation inventory: < 5 seconds
  - Metrics validation: < 10 seconds
- **Usability**: Color-coded messages with clear severity indicators
- **Maintainability**: Modular architecture with single responsibility
- **Reliability**: Never fail workflow due to consistency issues
- **Auditability**: All validation actions logged with detailed context

---

## Step 3: Script Reference Validation

**Module File:** `src/workflow/steps/step_03_script_refs.sh`  
**Module Version:** 2.0.0  
**Dependencies:** AI Helpers Library, File Operations Library, Step Execution Framework

### Overview

Step 3 is responsible for AI-powered script reference validation that ensures shell scripts are properly documented, executable, and correctly referenced in documentation.

### Architecture Context

Step 3 integrates with:

- **AI Helpers Library** (`lib/ai_helpers.sh`) - Copilot CLI integration
- **File Operations Library** (`lib/file_operations.sh`) - Fast file discovery
- **Backlog System** - Issue tracking and reporting
- **Logging System** - Execution audit trail
- **Summary System** - Step completion reporting

### Functional Requirements

#### FR-3.1: Version Management

**Priority:** High  
**Status:** Implemented

The system SHALL maintain version information in standardized module constants.

**Version Format:**

| Constant | Type | Example |
| -------- | ---- | ------- |
| `STEP3_VERSION` | String | `"2.0.0"` |
| `STEP3_VERSION_MAJOR` | Integer | `2` |
| `STEP3_VERSION_MINOR` | Integer | `0` |
| `STEP3_VERSION_PATCH` | Integer | `0` |

#### FR-3.2: Script Reference Validation

**Priority:** Critical  
**Status:** Implemented

The system SHALL validate that all scripts referenced in documentation actually exist in the repository.

**Acceptance Criteria:**

- Parse `shell_scripts/README.md` for script references
- Extract script paths using regex: `` `./shell_scripts/[^`]+\.sh` ``
- Verify file existence for each referenced script
- Report missing scripts with file paths
- Count total missing script references
- Save issues to temporary tracking file

**Reference Detection Pattern:**

```text
Input:  See `./shell_scripts/deploy_to_webserver.sh` for details
Extract: shell_scripts/deploy_to_webserver.sh
Validate: [[ -f "shell_scripts/deploy_to_webserver.sh" ]]
```

#### FR-3.3: Executable Permission Validation

**Priority:** High  
**Status:** Implemented

The system SHALL verify that all shell scripts have executable permissions.

**Acceptance Criteria:**

- Discover all `.sh` files in `shell_scripts/` directory
- Use `fast_find()` with depth limit of 5
- Exclude `node_modules/` and `.git/` directories
- Check executable permission with `[[ -x "$file" ]]` test
- Report non-executable scripts with file paths
- Count total permission issues

**Permission Check Logic:**

```bash
# For each .sh file:
if [[ ! -x "$script" ]]; then
    # Report as non-executable
fi
```

#### FR-3.4: Undocumented Script Detection

**Priority:** High  
**Status:** Implemented

The system SHALL identify scripts that exist in the repository but are not documented.

**Detection Algorithm:**

```bash
for script in all_scripts; do
    script_name=$(basename "$script")
    if ! grep -q "$script_name" "shell_scripts/README.md"; then
        # Report as undocumented
    fi
done
```

**Acceptance Criteria:**

- Compare script inventory against `shell_scripts/README.md` content
- Check if script basename appears anywhere in documentation
- Report undocumented scripts with full paths
- Count total undocumented scripts
- Save to issues tracking file

#### FR-3.5: AI-Powered Analysis

**Priority:** High  
**Status:** Implemented

The system SHALL generate and execute AI prompts for script reference validation.

**Prompt Components:**

| Component | Source | Purpose |
| --------- | ------ | ------- |
| Script Count | `fast_find()` count | Scope quantification |
| Change Scope | `${CHANGE_SCOPE}` | Context from workflow |
| Issues Found | Automated checks | Detected problems |
| Issues Content | Issues file | Detailed problem list |
| Script Inventory | `fast_find()` sorted | Complete script list |

**Acceptance Criteria:**

- Build validation prompt via `build_step3_script_refs_prompt()`
- Include script count in prompt context
- Include change scope from workflow
- Include detected issues summary
- Include complete script inventory
- Display prompt to user before execution
- Execute with comprehensive tool access flags:
  - `--allow-all-tools` - Enable all Copilot CLI tools
  - `--allow-all-paths` - Enable file system access for all paths
  - `--enable-all-github-mcp-tools` - Enable all GitHub MCP tools
- Execute with logging to unique timestamped file

#### FR-3.6: Issue Reporting and Tracking

**Priority:** High  
**Status:** Implemented

The system SHALL automatically detect and report script reference issues.

**Issue Categories:**

| Category | Detection Method | Severity |
| -------- | ---------------- | -------- |
| Missing References | File existence check | Critical |
| Non-Executable | Permission test | High |
| Undocumented | Documentation search | Medium |

**Issue Aggregation Format:**

```text
Missing script reference: shell_scripts/deleted.sh
Non-executable: shell_scripts/script_without_exec.sh
Undocumented: shell_scripts/new_feature.sh
Undocumented: shell_scripts/utility.sh
```

### Integration Points

**Library Dependencies:**

| Library | Purpose | Required |
| ------- | ------- | -------- |
| `lib/ai_helpers.sh` | Copilot CLI integration | ✅ Yes |
| `lib/file_operations.sh` | Fast file discovery | ✅ Yes |
| `lib/backlog.sh` | Issue tracking | ✅ Yes |
| `lib/summary.sh` | Step summary | ✅ Yes |
| `lib/colors.sh` | Terminal formatting | ✅ Yes |
| `lib/utils.sh` | File operations | ✅ Yes |
| `lib/validation.sh` | Status tracking | ✅ Yes |

**Exported Functions:**

- `step3_validate_script_references` - Main step execution

### Non-Functional Requirements

- **Performance**: Complete automated checks within 30 seconds (excluding AI analysis)
  - Script inventory generation: < 5 seconds
  - Reference validation: < 5 seconds
  - Permission checks: < 5 seconds
  - Documentation checks: < 10 seconds
- **Usability**: Color-coded messages with clear severity indicators
- **Maintainability**: Modular architecture with single responsibility
- **Reliability**: Never fail workflow due to validation issues
- **Auditability**: All validation actions logged with detailed context

---

## Client SPA Project Kind

**Configuration File:** `src/workflow/config/project_kinds.yaml`  
**Version:** 1.0.0  
**Status:** Draft

### Overview

The `client_spa` project kind defines classification and standards for vanilla JavaScript Single Page Applications that use Bootstrap or similar CSS frameworks without React/Vue/Angular.

### Purpose

Fill the gap between `static_website` and `react_spa` for modern client-side applications built with native web technologies.

### Project Classification

#### FR-4.1: Project Kind Definition

**Priority:** High  
**Status:** Required

The system SHALL recognize and classify projects as `client_spa` when they meet specific criteria.

**Acceptance Criteria:**

**AC-4.1.1**: Project MUST have `index.html` as entry point

- `index.html` or `public/index.html` MUST exist

**AC-4.1.2**: Project MUST use ES6+ JavaScript modules

- Detect `import`/`export` statements or `<script type="module">` tags

**AC-4.1.3**: Project MUST have client-side state management

- Detect state management patterns (localStorage, SessionStorage, or custom state objects)

**AC-4.1.4**: Project MUST use CSS framework

- Detect Bootstrap, Tailwind, Bulma, or Foundation

**AC-4.1.5**: Project MUST NOT use React/Vue/Angular

- `react`, `vue`, `@angular/core` MUST NOT be present in dependencies

#### FR-4.2: File Structure Validation

**Priority:** High  
**Status:** Required

**Required Files:**

```yaml
required_files:
  - "index.html|public/index.html"
  - "package.json"
  - "src/**/*.js"
```

**Required Directories:**

```yaml
required_directories:
  - "src"
  - "public|dist"
```

**Optional Files:**

```yaml
optional_files:
  - "README.md"
  - "vite.config.js|webpack.config.js"
  - "jest.config.js"
  - "eslint.config.js"
  - "sw.js|service-worker.js"
  - ".env.example"
```

**File Patterns:**

```yaml
file_patterns:
  - "*.html"
  - "*.css"
  - "*.js"
  - "*.mjs"
```

**Excluded Patterns:**

```yaml
excluded_patterns:
  - "*.jsx|*.tsx"  # React/JSX files
  - "*.vue"        # Vue components
  - "angular.json" # Angular config
```

### Testing Standards

#### FR-4.3: Testing Framework Detection

**Priority:** High  
**Status:** Required

**Test Framework Configuration:**

```yaml
testing:
  test_framework: "jest|playwright|selenium"
  test_directory: "tests"
  test_file_pattern: "*.test.js|*.spec.js|*.e2e.test.js"
  test_command: "npm test"
  e2e_command: "npm run test:e2e"
  coverage_required: true
  coverage_threshold: 70
```

**Required Test Categories:**

1. **API Client Tests**
   - Mock fetch responses
   - Test error handling
   - Test retry logic
   - Test timeout behavior
   - Test cache interactions

2. **State Management Tests**
   - Test localStorage/sessionStorage operations
   - Test state transitions
   - Test event emission/handling
   - Test data validation

3. **DOM Manipulation Tests**
   - Test element creation/updates
   - Test event listeners
   - Test form validation
   - Test responsive behavior

### Quality Standards

#### FR-4.4: Quality Metrics

**Priority:** High  
**Status:** Required

**Quality Configuration:**

```yaml
quality:
  linters:
    - name: "eslint"
      enabled: true
      command: "npx eslint"
      args: ["src/**/*.js"]
      file_pattern: "*.js|*.mjs"
    - name: "htmlhint"
      enabled: true
      command: "npx htmlhint"
      args: ["**/*.html"]
      file_pattern: "*.html"
    - name: "stylelint"
      enabled: true
      command: "npx stylelint"
      args: ["src/styles/**/*.css"]
      file_pattern: "*.css"
  
  documentation_required: true
  inline_comments_recommended: true
  readme_required: true
  api_documentation_required: true
  accessibility_required: true
  wcag_level: "AA"
```

**Quality Metrics:**

| Metric | Threshold | Tool |
| ------ | --------- | ---- |
| Test Coverage | ≥70% | Jest |
| ESLint Errors | 0 | ESLint |
| HTML Validation | 0 errors | HTMLHint |
| CSS Validation | 0 errors | Stylelint |
| Accessibility Score | ≥90 | Lighthouse |
| Performance Score | ≥85 | Lighthouse |

### AI Guidance Rules

#### FR-4.5: Documentation Review Persona

When reviewing `client_spa` projects, the AI SHALL:

1. **Validate SPA Architecture**
   - Verify modular JavaScript structure
   - Check for proper separation of concerns (UI, API, state)
   - Validate ES6+ module usage

2. **Check API Integration**
   - Review API client implementation
   - Verify error handling patterns
   - Check caching strategies
   - Validate timeout configurations

3. **Validate State Management**
   - Review localStorage/sessionStorage usage
   - Check for memory leaks (event listeners)
   - Validate state synchronization

4. **Review Testing Coverage**
   - Verify unit test coverage ≥70%
   - Check E2E test scenarios
   - Validate mock/stub patterns

5. **Accessibility Audit**
   - Check ARIA labels
   - Verify keyboard navigation
   - Validate semantic HTML

#### FR-4.6: Best Practices Enforcement

**AI Guidance Configuration:**

```yaml
ai_guidance:
  testing_standards:
    - "Jest for unit testing with jsdom environment"
    - "Playwright/Selenium for E2E browser testing"
    - "Test API client with mock responses and fetch mocks"
    - "Test state management and localStorage interactions"
    - "Validate DOM manipulation and event handlers"
    - "Test responsive design breakpoints"
    - "Mock external API calls consistently"
  
  style_guides:
    - "Airbnb JavaScript Style Guide (ES6+)"
    - "Bootstrap 5 Best Practices"
    - "Vanilla JS Best Practices (avoiding jQuery where possible)"
    - "HTML5 semantic markup guidelines"
    - "CSS BEM methodology for custom styles"
  
  best_practices:
    - "Use ES6+ modules (import/export) for code organization"
    - "Implement client-side routing with History API if SPA navigation needed"
    - "Use fetch() API with proper error handling and timeouts"
    - "Implement caching strategy (localStorage/sessionStorage) with TTL"
    - "Use async/await for asynchronous operations"
    - "Implement proper state management (avoid global variables)"
    - "Use Bootstrap utilities before custom CSS"
    - "Optimize bundle size with tree-shaking and code splitting"
    - "Implement proper CORS handling for API consumption"
    - "Use semantic HTML5 elements (nav, main, article, section)"
    - "Follow mobile-first responsive design principles"
    - "Implement proper accessibility (ARIA labels, keyboard navigation)"
    - "Use Service Worker for PWA features (optional)"
    - "Validate forms with HTML5 attributes + JavaScript"
    - "Implement proper error boundaries for API failures"
```

### Deployment Configuration

#### FR-4.7: Deployment Settings

**Priority:** Medium  
**Status:** Required

**Deployment Configuration:**

```yaml
deployment:
  type: "static"
  requires_build: false
  artifact_patterns:
    - "public/**/*"
    - "dist/**/*"
    - "index.html"
    - "src/**/*.js"
    - "src/**/*.css"
  cdn_compatible: true
```

**Build Configuration:**

```yaml
build:
  required: false  # Optional - supports both static serving and build tools
  build_command: "npm run build"
  output_directory: "dist|build|public"
  dev_server: "npm run dev|python3 -m http.server"
```

### Reference Implementation

**Project Example**: `monitora_vagas`

- **Description**: Hotel vacancy search application
- **Tech Stack**: Vanilla JS, Bootstrap 5.3.3, Jest, Selenium
- **API**: External Busca Vagas API consumption
- **State**: LocalStorage caching with TTL
- **Features**: PWA (service worker), responsive design, E2E tests

### Comparison Matrix

| Feature | static_website | client_spa | react_spa |
|---------|---------------|------------|-----------|
| ES6 Modules | Optional | Required | Required |
| State Management | No | Yes | Yes |
| API Consumption | Optional | Required | Required |
| Framework | None | Bootstrap/CSS | React |
| Build Tool | Optional | Optional | Required |
| Test Coverage | 0% | 70% | 70% |
| PWA Support | Optional | Optional | Optional |

---

## Shell Automation Documentation Specialist Persona

**Version**: 1.0.0  
**Date**: 2025-12-19  
**Purpose**: Specialized AI persona for documenting shell script automation workflows  
**Context**: AI Workflow Automation System (v2.3.1+)

### Overview

The Shell Automation Documentation Specialist is a specialized AI persona designed for generating and maintaining documentation for shell script automation workflows. This persona understands bash idioms, POSIX compatibility, shellcheck rules, and workflow orchestration patterns.

### Persona Definition

#### FR-5.1: Role and Expertise

**Priority:** Critical  
**Status:** Implemented

The AI persona SHALL act as a senior technical documentation specialist with deep expertise in:

**Shell Script & Automation Domain:**

- Bash/POSIX shell scripting (20+ years experience)
- Workflow automation and CI/CD pipeline documentation
- DevOps best practices and toolchain integration
- Command-line tool documentation and man page formatting
- Shell script architecture patterns and modular design

**Documentation Excellence:**

- Software architecture documentation (API, system design, workflows)
- Developer experience (DX) optimization and onboarding
- Technical writing for automation engineers and DevOps teams
- Documentation testing and validation strategies

**Shell-Specific Standards:**

- Google Shell Style Guide adherence
- ShellCheck compliance and static analysis integration
- POSIX compatibility documentation requirements
- Bash 4.0+ feature documentation (arrays, associative arrays)
- Error handling patterns (set -euo pipefail, trap handlers)

**Context Awareness:**

- Understands project kind from `src/workflow/config/project_kinds.yaml` (shell_script_automation type)
- References `.workflow-config.yaml` (bash primary language, shellcheck linting)
- Adapts documentation to shell-specific terminology and conventions

#### FR-5.2: Documentation Approach

**Priority:** High  
**Status:** Implemented

The persona SHALL follow standardized documentation patterns:

**Header Comments:**

```bash
#!/usr/bin/env bash
# OR: #!/bin/bash for Bash-specific features
set -euo pipefail  # Document error handling mode

################################################################################
# Script Name
# Purpose: Clear one-line description
# Usage: script.sh [options] <required_arg> [optional_arg]
# Dependencies: List external commands, sourced scripts
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Invalid arguments
################################################################################
```

**Function Documentation:**

```bash
#######################################
# Brief function description (one line)
# More detailed explanation if needed.
# Globals:
#   GLOBAL_VAR - Description of global variable usage
# Arguments:
#   $1 - First parameter description
#   $2 - Optional second parameter (default: value)
# Outputs:
#   Writes results to stdout
#   Writes logs to stderr
# Returns:
#   0 - Success
#   1 - Error condition
# Side Effects:
#   Creates temporary files in /tmp
#   Modifies global state variable
#######################################
function_name() {
    local param1="$1"
    local param2="${2:-default}"
    # Implementation
}
```

**README Structure:**

- Overview - Purpose and key features
- Prerequisites - Required tools, versions, environment setup
- Installation - Setup instructions, permissions, sourcing
- Usage - Command syntax, options, arguments
- Examples - Common use cases with expected output
- Module Documentation - Exported functions, sourcing patterns
- Configuration - Environment variables, config files
- Architecture - Module dependencies, execution flow
- Testing - How to run tests, test framework
- Troubleshooting - Common issues and solutions
- Exit Codes - Meaning of each exit code
- Contributing - Code style, documentation standards

#### FR-5.3: Shell-Specific Considerations

**Priority:** High  
**Status:** Required

The persona SHALL document shell-specific patterns:

**Error Handling:**

- Document `set -e` (exit on error) implications
- Explain `set -u` (error on undefined variables)
- Describe `set -o pipefail` (pipeline failure detection)
- Document trap handlers for cleanup (`trap 'cleanup' EXIT`)
- Explain error propagation in functions

**Variable Handling:**

- Document quoting requirements: `"${var}"` vs `$var`
- Explain local vs global scope
- Describe array handling: `arr=()` vs `arr[0]=`
- Document parameter expansion patterns
- Explain special variables: `$?`, `$!`, `$$`, `$@`, `$*`

**Command Execution:**

- Document command substitution: `$(command)` vs `` `command` ``
- Explain process substitution: `<(command)` and `>(command)`
- Describe subshell execution: `(command)` vs `{ command; }`
- Document pipeline behavior and `PIPESTATUS`
- Explain background execution: `command &` and `wait`

**Portability:**

- Note Bash-specific features (require `#!/bin/bash`)
- Document POSIX alternatives where applicable
- Explain version requirements (Bash 4.0+ for assoc arrays)
- Identify system-dependent commands (GNU vs BSD)
- Document external command dependencies

**Best Practices:**

- Use `[[ ]]` for conditionals (document why vs `[ ]`)
- Quote all variable expansions unless intentional word splitting
- Use `local` for function variables
- Check exit codes explicitly: `if command; then`
- Use shellcheck and document rule suppressions
- Prefer `${var}` over `$var` for clarity
- Use functions for repeated logic (DRY principle)
- Document magic numbers and complex regex

#### FR-5.4: Workflow Automation Specifics

**Priority:** High  
**Status:** Required

The persona SHALL document workflow-specific patterns:

**Step Documentation Format:**

```markdown
# Step N: Step Name

## Purpose
Brief description of what this step accomplishes

## Prerequisites
- Previous steps that must complete successfully
- Required files or state
- Environment variables that must be set

## Execution
- Input: What data/files are consumed
- Process: Key operations performed
- Output: Generated files, updated state

## Success Criteria
- Conditions for successful completion
- Expected exit code (0)
- Generated artifacts

## Failure Modes
- Common error scenarios
- Exit codes for each failure type
- Recovery procedures

## Dependencies
- Functions or modules sourced
- External commands required
- Configuration files accessed
```

**Orchestration Patterns:**

- Document execution order and dependencies
- Explain parallel vs sequential execution decisions
- Describe checkpoint/resume mechanisms
- Document smart execution and change detection
- Explain metrics collection and reporting
- Describe error handling and recovery strategies

**AI Integration:**

- Document AI persona usage and prompt templates
- Explain AI response caching mechanisms
- Describe context gathering for AI calls
- Document AI output validation and parsing
- Explain fallback strategies when AI unavailable

#### FR-5.5: Quality Assurance

**Priority:** High  
**Status:** Required

The persona SHALL enforce quality standards:

**ShellCheck Integration:**

- Document enabled ShellCheck rules
- Explain rule suppressions with inline comments
- Reference ShellCheck wiki for complex issues
- Integrate ShellCheck into documentation examples
- Document CI/CD integration for automated checking

**Testing Documentation:**

- Document test framework (bats, bash_unit, custom)
- Explain test file naming conventions
- Describe test execution commands
- Document mock/stub strategies for dependencies
- Explain integration vs unit test organization

**Validation Criteria:**

- Scripts have executable permissions (+x)
- Shebang line is present and correct
- Error handling mode is set (set -euo pipefail)
- Functions use `local` for variables
- All variables are quoted appropriately
- Exit codes are documented and consistent
- ShellCheck passes with no warnings
- Usage examples are tested and accurate

#### FR-5.6: Output Format

**Priority:** Medium  
**Status:** Required

The persona SHALL follow consistent formatting:

**Markdown Conventions:**

- Use `##` for top-level sections
- Use `###` for subsections
- Use ` ```bash ` fenced code blocks for shell examples
- Use inline `` `code` `` for commands and variables
- Use `>` blockquotes for important notes
- Use `-` for unordered lists
- Use `1.` for ordered lists
- Use `**bold**` for emphasis on key concepts

**Code Examples:**

- Always include shebang in full script examples
- Show error handling in examples
- Include comments explaining non-obvious logic
- Demonstrate proper quoting and best practices
- Show expected output or exit codes
- Include troubleshooting examples

**Consistency:**

- Use consistent terminology (script vs program)
- Maintain consistent formatting across all docs
- Use same style for all code examples
- Keep similar structure across module READMEs
- Use consistent section ordering

#### FR-5.7: Response Guidelines

**Priority:** High  
**Status:** Required

The persona SHALL follow these response guidelines:

**Precision:**

- Be surgical and precise - update only affected sections
- Maintain existing style and voice
- Preserve working code and documentation
- Don't modify unrelated files

**Completeness:**

- Update all related documentation files
- Ensure cross-references remain valid
- Update version numbers consistently
- Sync examples with actual code

**Clarity:**

- Use clear, concise technical language
- Avoid jargon unless defined
- Provide context for shell-specific idioms
- Include practical examples
- Explain 'why' not just 'what'

**Actionability:**

- Provide specific file paths and line numbers
- Include command examples users can copy-paste
- Suggest concrete improvements with examples
- Prioritize recommendations by impact

### Integration Points

#### FR-5.8: Workflow Integration

**Priority:** High  
**Status:** Implemented

**Step 1 - Documentation Analysis:**

```bash
# This persona is used when analyzing shell script changes
source "$(dirname "$0")/lib/ai_helpers.sh"

ai_call "shell_automation_documentation_specialist" \
    "Analyze these shell script changes and update documentation: ${changed_files}" \
    "docs/update_report.md"
```

**Configuration Reference:**

```yaml
# In .workflow-config.yaml
project:
  type: "bash-automation-framework"
tech_stack:
  primary_language: "bash"
  test_framework: "shell-script"
  lint_command: "shellcheck src/workflow/**/*.sh"
```

**Project Kind Definition:**

```yaml
# In project_kinds.yaml - shell_script_automation type
quality:
  documentation_required: true
  inline_comments_recommended: true
  readme_required: true
```

### Example Outputs

#### Example 1: Function Documentation Enhancement

**Before:**

```bash
process_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    cat "$file" | grep -v "^#" | sed 's/  */ /g'
}
```

**After (with Shell Automation Persona):**

```bash
#######################################
# Process file by removing comments and normalizing whitespace
# Reads a text file, filters out comment lines starting with #,
# and normalizes multiple spaces to single spaces.
# Arguments:
#   $1 - Path to input file
# Outputs:
#   Writes processed content to stdout
# Returns:
#   0 - File processed successfully
#   1 - File not found or not readable
#######################################
process_file() {
    local file="$1"
    
    # Validate file exists and is readable
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Remove comment lines and normalize whitespace
    # - grep -v "^#": Filter out lines starting with #
    # - sed 's/  */ /g': Replace multiple spaces with single space
    cat "$file" | grep -v "^#" | sed 's/  */ /g'
}
```

#### Example 2: Script Header Enhancement

**Before:**

```bash
#!/bin/bash
set -e
# backup script
```

**After (with Shell Automation Persona):**

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Database Backup Script
# Purpose: Create automated backups of PostgreSQL databases with compression
# Usage: backup_database.sh <database_name> [backup_dir]
#
# Arguments:
#   database_name - Name of PostgreSQL database to backup (required)
#   backup_dir    - Target directory for backup file (default: /var/backups)
#
# Dependencies:
#   - pg_dump (PostgreSQL client tools)
#   - gzip (compression utility)
#   - date command (for timestamp generation)
#
# Environment Variables:
#   PGHOST     - PostgreSQL server host (default: localhost)
#   PGPORT     - PostgreSQL server port (default: 5432)
#   PGUSER     - PostgreSQL user for backup (required)
#   PGPASSWORD - PostgreSQL user password (required)
#
# Exit Codes:
#   0 - Backup completed successfully
#   1 - Missing required arguments
#   2 - Database connection failed
#   3 - Backup directory not writable
#   4 - Backup operation failed
#
# Example:
#   export PGUSER=backup_user PGPASSWORD=secret
#   ./backup_database.sh myapp_production /backups
#
# Author: DevOps Team
# Version: 1.0.0
# Last Modified: 2025-12-19
################################################################################
```

### Benefits

The Shell Automation Documentation Specialist persona provides:

1. **Shell-Specific Expertise** - Understands bash idioms and POSIX compatibility
2. **Automation Context** - Documents workflow orchestration patterns correctly
3. **Quality Standards** - Enforces Google Shell Style Guide and shellcheck compliance
4. **Developer Experience** - Provides practical, copy-paste examples with clear troubleshooting
5. **Consistency** - Maintains uniform documentation style across all shell modules

### Related Documentation

- **Main Persona Config**: `src/workflow/lib/ai_helpers.yaml`
- **Project Kind Config**: `src/workflow/config/project_kinds.yaml`
- **Workflow Config**: `.workflow-config.yaml`
- **Google Shell Style Guide**: https://google.github.io/styleguide/shellguide.html
- **ShellCheck Wiki**: https://www.shellcheck.net/wiki/

---

## Cross-Cutting Concerns

### Execution Modes

All workflow steps support three execution modes:

#### Interactive Mode

**Characteristics:**

- Prompt before running Copilot CLI
- Prompt before file modifications
- Prompt for continuation after critical operations
- Use `confirm_action()` with appropriate defaults
- Default behaviors favor primary features

#### Automatic Mode

**Characteristics:**

- Skip all prompts when `$AUTO_MODE == true`
- Use default behaviors for all decisions
- Execute automated checks unconditionally
- Log automatic decisions to workflow log
- Provide fallback analysis without AI

#### Dry-Run Mode

**Characteristics:**

- Display intended actions without execution
- Skip Copilot CLI invocation
- Skip file modifications
- Display prompts that would be used
- Log actions with `[DRY RUN]` prefix
- Execute read-only validations only

### Error Handling and Graceful Degradation

All steps implement consistent error handling:

1. **Directory Navigation Errors**
   - Attempt to change to `$PROJECT_ROOT`
   - Return error code 1 on failure
   - Prevent execution in wrong directory
   - Log error to workflow log

2. **AI Service Unavailability**
   - Check availability via `is_copilot_available()`
   - Display warning when not found
   - Provide installation instructions
   - Continue workflow with basic checks only
   - Do not fail workflow due to missing AI

3. **File Operation Failures**
   - Use temporary files with cleanup tracking
   - Register temp files in `TEMP_FILES` array
   - Handle errors with appropriate fallbacks
   - Support empty result scenarios
   - Continue workflow on non-critical failures

### Third-Party File Exclusion

**Status:** ✅ IMPLEMENTED (v1.0.0)  
**Module:** `src/workflow/lib/third_party_exclusion.sh`  
**Tests:** 44/44 passing (100% coverage)  
**Documentation:** `docs/workflow-automation/THIRD_PARTY_EXCLUSION_MODULE.md`

All workflow steps MUST exclude third-party dependencies and build artifacts from analysis, as they are outside the project development scope.

**Rationale:**

Third-party files are maintained by external teams and should not be validated, analyzed, or modified by the workflow automation system. Including these files would:

- Generate false positives in quality checks
- Significantly increase execution time
- Consume unnecessary AI tokens
- Produce irrelevant analysis results

**Standard Exclusion Patterns:**

All file discovery operations (`find`, `fast_find`, `grep`) SHALL exclude the following patterns:

| Pattern | Technology | Purpose |
|---------|------------|---------|
| `node_modules/` | Node.js/JavaScript | NPM package dependencies |
| `venv/`, `.venv/`, `env/` | Python | Virtual environment packages |
| `__pycache__/` | Python | Bytecode cache |
| `vendor/` | PHP, Go, Ruby | Package manager dependencies |
| `target/` | Java, Rust | Build output directory |
| `build/`, `dist/` | Multiple | Compiled/bundled artifacts |
| `.git/` | Git | Version control metadata |
| `coverage/` | Testing | Test coverage reports |
| `.pytest_cache/` | Python | Pytest cache directory |
| `*.egg-info/` | Python | Package metadata |

**Implementation Requirements:**

1. **File Discovery Functions** - All file search operations MUST use exclusion patterns:
   ```bash
   # find command pattern
   find . -type f -name "*.js" \
       ! -path "*/node_modules/*" \
       ! -path "*/.git/*" \
       ! -path "*/coverage/*"
   
   # fast_find pattern
   fast_find "." "*.py" 5 "venv" "__pycache__" ".git"
   ```

2. **Step-Specific Exclusions:**
   - **Step 1 (Documentation)**: Exclude third-party directories from file mapping
   - **Step 2 (Consistency)**: Exclude from documentation inventory
   - **Step 3 (Script Refs)**: Exclude from script validation
   - **Step 4 (Directory)**: Exclude from structure validation
   - **Step 5 (Test Review)**: Exclude third-party test files
   - **Step 9 (Code Quality)**: Exclude from source code analysis
   - **Step 12 (Markdown)**: Exclude from markdown linting

3. **AI Prompt Context** - When providing file lists to AI, explicitly state exclusions:
   ```
   "Analyzing project files (excluding node_modules, venv, and build artifacts)"
   ```

4. **Configuration Support** - Tech stack definitions SHALL specify exclusion patterns per language:
   ```yaml
   # JavaScript/Node.js
   exclude_dirs: ["node_modules", "dist", "build", "coverage", ".next", "out"]
   
   # Python
   exclude_dirs: ["venv", ".venv", "env", "__pycache__", ".pytest_cache", "*.egg-info"]
   
   # Go
   exclude_dirs: ["vendor", "target"]
   ```

**Acceptance Criteria:**

- ✅ All file discovery operations use consistent exclusion patterns
  - **Implementation:** `find_with_exclusions()`, `grep_with_exclusions()`, `fast_find_safe()`
- ✅ Exclusion patterns documented in function headers
  - **Documentation:** Complete API reference in module documentation
- ✅ Tech stack configurations define language-specific exclusions
  - **Implementation:** `get_language_exclusions()`, `get_tech_stack_exclusions()`
- ✅ AI prompts acknowledge excluded directories
  - **Implementation:** `get_ai_exclusion_context()` provides contextual messages
- ✅ Execution logs note excluded directory counts
  - **Implementation:** `log_exclusions()`, `count_excluded_dirs()`
- ✅ Performance impact: 40-85% faster execution by excluding large dependency directories
  - **Verified:** See performance benchmarks in module documentation

**Implementation Details:**

- **Module File:** `src/workflow/lib/third_party_exclusion.sh`
- **Test Suite:** `tests/unit/lib/test_third_party_exclusion.sh` (44 tests, 100% pass rate)
- **Documentation:** `docs/workflow-automation/THIRD_PARTY_EXCLUSION_MODULE.md`
- **Version:** 1.0.0
- **Date Implemented:** 2025-12-23

**Key Functions:**
- `get_standard_exclusion_patterns()` - Returns all standard patterns
- `get_language_exclusions(language)` - Language-specific exclusions
- `find_with_exclusions(dir, pattern, depth)` - File discovery with exclusions
- `grep_with_exclusions(pattern, dir, file_pattern)` - Search with exclusions
- `is_excluded_path(path)` - Path validation
- `filter_excluded_files()` - Filter stdin for excluded paths
- `get_ai_exclusion_context()` - AI prompt context messages
- `count_excluded_dirs(dir)` - Count excluded directories
- `fast_find_safe()` - Backward-compatible wrapper

**Integration Status:**
- ✅ Step 1 (Documentation): Ready to integrate
- ✅ Step 2 (Consistency): Ready to integrate
- ✅ Step 3 (Script Refs): Already uses exclusions, can migrate to module
- ✅ Step 4 (Directory): Ready to integrate
- ✅ Step 5 (Test Review): Ready to integrate
- ✅ Step 9 (Code Quality): Ready to integrate
- ✅ Step 12 (Markdown): Ready to integrate

### Temporary File Management

All steps use consistent temporary file management:

**Pattern:**

```bash
# Create temporary file
temp_file=$(mktemp)
TEMP_FILES+=("$temp_file")

# Use file
echo "data" > "$temp_file"

# Cleanup handled by parent workflow
```

**Cleanup:**

- Files registered in `TEMP_FILES` array
- Cleanup performed by parent workflow
- Support multiple temporary files per step
- Automatic cleanup on workflow completion

### Output and Reporting

All steps use standardized reporting functions:

#### Step Results Persistence

**Function:** `save_step_results()`

**Parameters:**

- Step number (e.g., `"1"`, `"2"`, `"3"`)
- Step name (e.g., `"Documentation_Updates"`)
- Issue count (total detected issues)
- Success message (when issues == 0)
- Warning message (when issues > 0)
- Data file (optional, contains detailed results)
- Context value (optional, e.g., file count)

#### Workflow Status Update

**Function:** `update_workflow_status()`

**Parameters:**

- Step identifier (e.g., `"step1"`, `"step2"`, `"step3"`)
- Status indicator (e.g., `"✅"`)

#### Issue Extraction

**Function:** `extract_and_save_issues_from_log()`

**Parameters:**

- Step number
- Step name
- Log file path

### Data Requirements

#### Common Input Data

All steps access:

- `$PROJECT_ROOT` - Repository root directory
- `$LOGS_RUN_DIR` - Log file directory path
- `$BACKLOG_RUN_DIR` - Backlog directory path
- `$SUMMARIES_RUN_DIR` - Summaries directory path
- `$INTERACTIVE_MODE` - User interaction flag
- `$AUTO_MODE` - Automatic execution flag
- `$DRY_RUN` - Dry-run mode flag

#### Common Output Data

All steps generate:

- Backlog reports: `${BACKLOG_RUN_DIR}/step[N]_*.md`
- Summaries: `${SUMMARIES_RUN_DIR}/step[N]_*.md`
- Logs: `${LOGS_RUN_DIR}/step[N]_*.log`

### User Interaction Requirements

All steps provide:

#### Command-Line Output

- Step headers with step number and name
- Informational messages (cyan)
- Success messages (green with ✅)
- Warning messages (yellow with ⚠️)
- Error messages (red with ❌)
- Highlighted prompts (yellow/cyan)

#### Result Summaries

- Concise summaries after each phase
- Clear status indicators
- Count of issues/successes
- Recommended actions

### Testing Requirements

All steps require:

#### Unit Testing

- Test core functions with various inputs
- Test error conditions and edge cases
- Test return codes and error messages
- Verify output formats

#### Integration Testing

- Test with real repository data
- Test with missing dependencies
- Test in all execution modes
- Test error recovery

#### Edge Cases

- Empty input scenarios
- Missing files/directories
- Permission issues
- Malformed input data
- Resource exhaustion

### Non-Functional Requirements Summary

**Performance:**

- Steps 1-3: Complete automated checks within 30-60 seconds (excluding AI analysis)
- CLIENT_SPA detection: Complete within 5 seconds

**Usability:**

- Color-coded messages with clear severity indicators
- Consistent command-line interface
- Clear error messages with remediation steps

**Maintainability:**

- Modular architecture with single responsibility
- Clear function naming conventions
- Comprehensive inline documentation
- Reusable validation components

**Reliability:**

- Never fail workflow due to detected issues (report only)
- Graceful degradation for optional features
- Automatic retry for transient failures

**Security:**

- No sensitive information in logs
- No execution of untrusted code
- Safe file operations with validation

**Auditability:**

- All actions logged with timestamps
- Comprehensive execution trail
- Issue tracking and reporting

---

## Workflow Step Dependencies and Execution Order

**Version:** 2.4.0  
**Date:** December 23, 2025  
**Status:** Mandatory

### Overview

This section defines the mandatory workflow step dependencies and execution order requirements that must be enforced in all execution modes (sequential, parallel, smart execution, and checkpoint resume).

### FR-WF-1: Git Finalization Dependency on Context Analysis

**Priority:** Critical  
**Status:** Mandatory

#### FR-WF-1.1: Comprehensive Prerequisites for Git Finalization

**Requirement:** Git Finalization (Step 11) SHALL always depend on the following steps completing successfully:
- Step 10: Context Analysis (MANDATORY)
- Step 12: Markdown Lint (MANDATORY - added 2025-12-23)
- Step 13: Prompt Engineer Analysis (MANDATORY - added 2025-12-23)
- Step 14: UX Analysis (MANDATORY - added 2025-12-23)

**Acceptance Criteria:**

- Step 11 (Git Finalization) MUST NOT execute until ALL prerequisite steps complete successfully
- Step 11 MUST verify all prerequisite statuses before proceeding:
  - Step 10 (Context Analysis) status must be "✅"
  - Step 12 (Markdown Lint) status must be "✅"
  - Step 13 (Prompt Engineer) status must be "✅"
  - Step 14 (UX Analysis) status must be "✅"
- If ANY prerequisite fails or is skipped, Step 11 MUST NOT execute
- This dependency MUST be enforced in all execution modes:
  - Sequential execution
  - Parallel execution (--parallel flag)
  - Smart execution (--smart-execution flag)
  - Checkpoint resume (default and --no-resume modes)
  - Selective step execution (--steps flag)

**Rationale:**

**Step 10 (Context Analysis)**: Provides critical workflow assessment, risk identification, and readiness evaluation. Performs irreversible operations require comprehensive context to:
1. Assess workflow completion status
2. Identify critical issues that should block finalization
3. Verify all previous steps executed successfully
4. Evaluate change impact and deployment readiness
5. Provide strategic recommendations before committing

**Step 12 (Markdown Lint)**: Ensures documentation quality and consistency before finalizing changes. Prevents committing documentation with:
- Formatting errors
- Broken link syntax
- Inconsistent markdown styles
- Missing required sections

**Step 13 (Prompt Engineer Analysis)**: Validates AI prompt templates and configurations. Critical for projects using AI-powered workflows to ensure:
- Prompt templates are syntactically valid
- AI integration configurations are correct
- Persona definitions are properly structured
- No breaking changes in AI workflows

**Step 14 (UX Analysis)**: Validates user experience and accessibility requirements. Ensures:
- UI changes meet accessibility standards (WCAG)
- UX patterns are consistent
- User-facing documentation is clear
- Interface changes don't break existing workflows

**Implementation:**

The dependency is implemented in:
- `src/workflow/lib/dependency_graph.sh`: `[11]="10,12,13,14"`
- `src/workflow/steps/step_11_git.sh`: Runtime validation checks all four prerequisites
- `src/workflow/execute_tests_docs_workflow.sh`: Sequential execution order enforces this naturally

**Validation:**

- Unit tests MUST verify all four dependencies are enforced
- Integration tests MUST verify Step 11 cannot execute without ANY prerequisite
- Parallel execution MUST respect all dependency constraints
- 35 comprehensive tests verify enforcement (100% pass rate)

#### FR-WF-1.2: Git Finalization as Final Step

**Requirement:** Git Finalization (Step 11) SHALL always be the last step in workflow execution.

**Acceptance Criteria:**

- No workflow step SHALL execute after Step 11
- Step 11 MUST be positioned as the final step in all execution sequences
- Parallel execution groups MUST NOT contain Step 11 with other steps
- Step 11 MUST run in its own execution phase as the final phase
- After Step 11 completion, the workflow MUST terminate

**Rationale:**

Git Finalization performs irreversible git operations (commit and push to remote). No workflow step should execute after these operations because:

1. All validation and analysis must complete before committing
2. Modifications after commit would leave repository in inconsistent state
3. Git operations represent the workflow's completion and finalization
4. Step 11 includes cleanup and permission updates as final actions

**Implementation:**

Current implementation in `src/workflow/lib/dependency_graph.sh`:
```bash
PARALLEL_GROUPS=(
    "1,3,4,5,8,13,14"     # Group 1: Can run after Pre-Analysis
    "2,12"                # Group 2: Consistency checks
    "6"                   # Group 3: Test Generation
    "7,9"                 # Group 4: Test Execution and Code Quality
    "10"                  # Group 5: Context Analysis
    "11"                  # Group 6: Git Finalization (ISOLATED - ALWAYS LAST)
)
```

**Validation:**

- Step 11 MUST be in its own parallel group
- No step SHALL be added to Group 6 with Step 11
- New workflow steps MUST be inserted before Step 11

### FR-WF-2: Workflow Step Sequence

**Priority:** High  
**Status:** Mandatory

#### FR-WF-2.1: Standard Execution Order

**Requirement:** The workflow SHALL execute steps in the following standard sequence when no optimization flags are used:

```
Step 0:  Pre-Analysis
Step 1:  Documentation Updates
Step 2:  Consistency Analysis
Step 3:  Script Reference Validation
Step 4:  Directory Structure Validation
Step 5:  Test Review
Step 6:  Test Generation
Step 7:  Test Execution
Step 8:  Dependency Validation
Step 9:  Code Quality Checks
Step 10: Context Analysis
Step 11: Git Finalization (ALWAYS LAST)
```

**Additional Steps (Optional):**
```
Step 12: Markdown Linting (parallel with Step 2)
Step 13: Prompt Engineer Analysis (parallel with Group 1)
Step 14: UX Analysis (parallel with Group 1)
```

#### FR-WF-2.2: Dependency Enforcement

**Requirement:** The workflow SHALL enforce the following dependency relationships:

| Step | Name | Dependencies | Notes |
|------|------|--------------|-------|
| 0 | Pre-Analysis | None | Entry point |
| 1 | Documentation | 0 | |
| 2 | Consistency | 1 | |
| 3 | Script Refs | 0 | Can parallel with Group 1 |
| 4 | Directory | 0 | Can parallel with Group 1 |
| 5 | Test Review | 0 | Can parallel with Group 1 |
| 6 | Test Generation | 5 | |
| 7 | Test Execution | 6 | |
| 8 | Dependencies | 0 | Can parallel with Group 1 |
| 9 | Code Quality | 7 | |
| 10 | Context Analysis | 1,2,3,4,7,8,9 | **MANDATORY prerequisite for Step 11** |
| 11 | Git Finalization | 10,12,13,14 | **ALWAYS LAST - MANDATORY** (updated 2025-12-23) |
| 12 | Markdown Lint | 2 | **MANDATORY prerequisite for Step 11** |
| 13 | Prompt Engineer | 0 | **MANDATORY prerequisite for Step 11** |
| 14 | UX Analysis | 0,1 | **MANDATORY prerequisite for Step 11** |

**Key Constraints:**
- ⚠️ **CRITICAL**: Step 11 MUST depend on Steps 10, 12, 13, 14 (updated 2025-12-23)
- ⚠️ **CRITICAL**: Step 11 MUST be the absolute last step
- Step 10 aggregates results from multiple previous steps
- Steps 12, 13, 14 provide quality gates before finalization
- Step 0 is the entry point for all execution paths

### FR-WF-3: Execution Mode Requirements

**Priority:** High  
**Status:** Mandatory

#### FR-WF-3.1: Parallel Execution Mode

**Requirement:** When `--parallel` flag is used, the workflow SHALL execute steps in parallel groups while maintaining all dependency constraints.

**Parallel Groups Definition:**

```bash
Group 1: Steps 1,3,4,5,8,13,14  (Independent validation after Step 0)
Group 2: Steps 2,12             (Consistency checks)
Group 3: Step 6                 (Test Generation)
Group 4: Steps 7,9              (Test Execution and Code Quality)
Group 5: Step 10                (Context Analysis - waits for all dependencies)
Group 6: Step 11                (Git Finalization - ISOLATED AND LAST)
```

**Acceptance Criteria:**
- Each group executes sequentially after its dependencies complete
- Within a group, steps execute in parallel
- Group 6 (Step 11) MUST execute after Group 5 (Step 10)
- No other steps SHALL be added to Group 6

#### FR-WF-3.2: Smart Execution Mode

**Requirement:** When `--smart-execution` flag is used, the workflow MAY skip steps based on change impact analysis, but SHALL NOT skip Steps 10, 11, 12, 13, or 14.

**Acceptance Criteria:**
- Steps 10, 12, 13, 14 (prerequisites for Step 11) MUST always execute (never skipped)
- Step 11 (Git Finalization) MUST always execute (never skipped)
- If any prerequisite is skipped for any reason, Step 11 MUST also be skipped
- Skipped steps MUST be logged with rationale

#### FR-WF-3.3: Selective Step Execution

**Requirement:** When `--steps` flag is used to select specific steps, the workflow SHALL enforce all dependencies.

**Acceptance Criteria:**
- If Step 11 is selected without Steps 10, 12, 13, or 14, workflow MUST either:
  - Automatically include all missing prerequisites in execution, OR
  - Display error and abort execution
- If any prerequisite (10, 12, 13, 14) is selected, Step 11 MAY be optionally included
- Dependency validation MUST occur before execution begins
- User MUST be notified of all auto-included dependencies

### FR-WF-4: Validation and Testing Requirements

**Priority:** High  
**Status:** Mandatory

#### FR-WF-4.1: Dependency Validation Tests

**Requirement:** The workflow SHALL include automated tests to verify dependency enforcement.

**Test Coverage Required:**
- ✅ Test Step 11 cannot execute without any prerequisite (Steps 10, 12, 13, 14)
- ✅ Test Step 11 is always the last step in sequential execution
- ✅ Test Step 11 is isolated in parallel execution (Group 6)
- ✅ Test selective execution enforces all Step 11 dependencies
- ✅ Test smart execution never skips Steps 10, 11, 12, 13, 14
- ✅ Test checkpoint resume respects all Step 11 dependencies
- ✅ Test individual prerequisite failures block Step 11
- ✅ Test all prerequisites must be successful for Step 11 to run

#### FR-WF-4.2: Runtime Validation

**Requirement:** The workflow SHALL validate dependencies at runtime before step execution.

**Acceptance Criteria:**
- Before executing Step 11, verify all prerequisite statuses:
  - Step 10 status is "✅" (completed)
  - Step 12 status is "✅" (completed)
  - Step 13 status is "✅" (completed)
  - Step 14 status is "✅" (completed)
- If ANY prerequisite failed ("❌"), Step 11 MUST NOT execute
- If ANY prerequisite was skipped, Step 11 MUST NOT execute
- Log validation results for audit trail with all prerequisite statuses

### FR-WF-5: Documentation Requirements

**Priority:** Medium  
**Status:** Mandatory

#### FR-WF-5.1: Dependency Documentation

**Requirement:** All workflow documentation SHALL clearly state the comprehensive Step 11 dependencies (Steps 10, 12, 13, 14).

**Documentation Locations:**
- ✅ `src/workflow/lib/dependency_graph.sh` - Dependency definition and comments
- ✅ `docs/workflow-automation/CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md` - This document
- ✅ `docs/workflow-automation/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md` - Workflow analysis
- ✅ `.github/copilot-instructions.md` - AI assistant guidelines
- ✅ `README.md` - Project overview (if applicable)

#### FR-WF-5.2: Dependency Visualization

**Requirement:** The workflow dependency graph SHALL visually highlight all Step 11 dependencies (Steps 10, 12, 13, 14 → Step 11).

**Acceptance Criteria:**
- Mermaid diagram MUST show MANDATORY edges from Steps 10, 12, 13, 14 to Step 11
- Step 11 MUST be visually distinguished as "final step"
- Steps 10, 12, 13, 14 MUST be visually marked as prerequisites for finalization
- ASCII dependency tree MUST show Step 11 as terminal node with all four prerequisites
- Generated documentation MUST include critical path highlighting

---

## Appendix

### A. Version Format Examples

**Step 1 Version Formats:**

```text
Simple:  1.5.0
Full:    Step 1 (Documentation Updates) v1.5.0
Semver:  Major: 1, Minor: 5, Patch: 0
JSON:    {"version":"1.5.0","major":1,"minor":5,"patch":0}
```

### B. Routing Rules Reference

**Step 1 Documentation Routing:**

| Source Pattern | Target Documentation |
|----------------|---------------------|
| `shell_scripts/**` | `shell_scripts/README.md` |
| `src/scripts/**` | `README.md` |
| `docs/**` | Notification only |

### C. Validation Patterns

**Step 2 Version Validation:**

```regex
# Valid semantic version pattern
^v?([0-9]+)\.([0-9]+)\.([0-9]+)$

# Examples:
✅ 2.0.0
✅ v1.5.0
❌ 1.5
❌ v2
```

**Step 2 Absolute Path Detection:**

```regex
# Absolute path in markdown links
(?<=\()(/[^)]+)(?=\))

# Examples:
✅ [text](/path/to/file.md)
✅ ![alt](/images/pic.png)
❌ [text](../file.md)  # Relative path (not detected)
```

**Step 3 Script Reference Detection:**

```regex
# Script path in backticks
`./shell_scripts/[^`]+\.sh`

# Examples:
✅ `./shell_scripts/deploy_to_webserver.sh`
✅ `./shell_scripts/pull_all_submodules.sh`
```

### D. Sample AI Prompt Structures

#### Copilot CLI Execution Flags

All AI-powered analysis steps (Steps 1, 2, and 3) execute prompts with comprehensive tool access:

**Required Flags:**

```bash
copilot \
  --allow-all-tools \
  --allow-all-paths \
  --enable-all-github-mcp-tools \
  "${prompt}"
```

**Flag Purposes:**

| Flag | Purpose |
|------|---------|
| `--allow-all-tools` | Enable all Copilot CLI tools for file operations, git commands, etc. |
| `--allow-all-paths` | Enable file system access for all paths within repository |
| `--enable-all-github-mcp-tools` | Enable all GitHub Model Context Protocol (MCP) tools for repository analysis |

#### Step 1: Documentation Update Prompt

```text
You are a Technical Documentation Specialist analyzing code changes
for documentation updates.

TASK:
Review the following modified files and identify documentation updates
needed to maintain consistency:

MODIFIED FILES:
- file1.sh
- file2.js
- file3.md

DOCUMENTATION TO REVIEW:
- README.md
- shell_scripts/README.md

STANDARDS:
- Ensure version references are up-to-date
- Check for new features requiring documentation
- Validate cross-references between files
- Identify outdated information
```

#### Step 2: Consistency Analysis Prompt

```text
You are a Technical Documentation Specialist analyzing documentation
consistency and broken references.

TASK:
Review the following documentation inventory for consistency issues,
broken references, and semantic versioning compliance.

DOCUMENTATION STATISTICS:
- Total Files: 45
- Change Scope: shell_scripts + workflow modules
- Modified Files: 12

BROKEN REFERENCES DETECTED:
README.md: /docs/DELETED_FILE.md
.github/copilot-instructions.md: /shell_scripts/OLD_SCRIPT.sh

DOCUMENTATION FILES:
./README.md
./docs/WORKFLOW.md
./shell_scripts/README.md
...

VALIDATION TASKS:
1. Review broken references and suggest fixes
2. Check version consistency across files
3. Identify outdated cross-references
4. Validate metrics accuracy
```

#### Step 3: Script Validation Prompt

```text
You are a Shell Script Documentation Specialist analyzing script
references and documentation accuracy.

TASK:
Review the following shell script inventory for documentation gaps,
broken references, and permission issues.

SCRIPT STATISTICS:
- Total Scripts: 23
- Change Scope: shell_scripts modifications
- Issues Found: 5

DETECTED ISSUES:
Missing script reference: shell_scripts/deleted.sh
Non-executable: shell_scripts/new_script.sh
Undocumented: shell_scripts/utility.sh

SCRIPT INVENTORY:
./shell_scripts/deploy_to_webserver.sh
./shell_scripts/pull_all_submodules.sh
./shell_scripts/sync_to_public.sh
...

VALIDATION TASKS:
1. Review missing script references and suggest documentation updates
2. Identify permission issues requiring fixing
3. Recommend documentation for undocumented scripts
4. Validate script organization and naming conventions
```

#### CLIENT_SPA: Project Context Prompt

```markdown
Project Kind: client_spa (Client-Side SPA - Vanilla JS/Bootstrap)

Context for AI Review:
- This is a vanilla JavaScript SPA without React/Vue/Angular
- Uses Bootstrap 5.3.3 for UI components and responsive design
- Implements client-side state management with localStorage
- Consumes external REST APIs with fetch()
- Tests include Jest unit tests + Selenium/Playwright E2E tests
- No server-side rendering - 100% client-side execution
- Static file serving (Python HTTP server or similar)

Focus Areas:
1. ES6+ module architecture and code organization
2. API client implementation (error handling, retries, caching)
3. State management patterns (localStorage, event-driven)
4. Bootstrap utility usage vs. custom CSS
5. Accessibility (ARIA, semantic HTML, keyboard navigation)
6. Test coverage (70%+ required)
7. Performance optimization (bundle size, lazy loading)
```

### E. Issue Report Templates

#### Step 1: Version Consistency Report

```markdown
## Version Consistency Issues
**Timestamp**: YYYY-MM-DD HH:MM:SS
**Current Script Version**: vX.Y.Z

### Issues Detected
⚠️  **VERSION MISMATCH**: [file] contains outdated version references
   - Script version: vX.Y.Z
   - Found in [file]: Line [N]: [content]
   - Update all references to vX.Y.Z

### Recommended Actions
1. Update README.md to reference vX.Y.Z
2. Update .github/copilot-instructions.md to reference vX.Y.Z
3. Ensure all version references are consistent
```

#### Step 2: Consistency Analysis Report

```markdown
## Documentation Consistency Issues
**Timestamp**: YYYY-MM-DD HH:MM:SS
**Documentation Files Checked**: N

### Broken References
⚠️  **BROKEN LINK**: [source_file] references missing file
   - Reference: /path/to/missing/file
   - Line [N]: [content]
   - Action: Update reference or restore missing file

### Version Inconsistencies
⚠️  **VERSION MISMATCH**: [file] contains inconsistent version
   - Expected: vX.Y.Z
   - Found in [file]: Line [N]: [content]
   - Action: Update to consistent version format

### Metrics Validation
⚠️  **METRICS MISMATCH**: Cross-document metrics inconsistency
   - File: [filename]
   - Expected: [value]
   - Actual: [value]
   - Action: Reconcile metrics across documentation

### Recommended Actions
1. Fix all broken references by updating paths or restoring files
2. Standardize version numbers across documentation
3. Validate and update metrics for consistency
```

#### Step 3: Script Validation Report

```markdown
## Script Reference Validation Issues
**Timestamp**: YYYY-MM-DD HH:MM:SS
**Total Scripts Checked**: N

### Missing Script References
⚠️  **BROKEN REFERENCE**: Documentation references non-existent script
   - Reference: shell_scripts/deleted_script.sh
   - Source: shell_scripts/README.md
   - Action: Remove reference or restore missing script

### Permission Issues
⚠️  **NON-EXECUTABLE**: Script lacks executable permission
   - Script: shell_scripts/script_name.sh
   - Action: Run `chmod +x shell_scripts/script_name.sh`

### Undocumented Scripts
⚠️  **MISSING DOCUMENTATION**: Script not documented in README
   - Script: shell_scripts/new_script.sh
   - Action: Add documentation to shell_scripts/README.md

### Recommended Actions
1. Remove or update broken script references in documentation
2. Fix executable permissions: `chmod +x [script_path]`
3. Document all scripts in shell_scripts/README.md
4. Re-run validation to verify all issues resolved
```

### F. Related Documentation

**Workflow System:**

- `/src/workflow/README.md` - Workflow system overview
- `/docs/TESTS_DOCS_WORKFLOW_AUTOMATION_PLAN.md` - Workflow architecture
- `.github/copilot-instructions.md` - Project development guidelines

**Configuration:**

- `src/workflow/config/project_kinds.yaml` - Project kind definitions
- `.workflow-config.yaml` - Project-specific configuration

**Library Modules:**

- `lib/ai_helpers.sh` - AI integration
- `lib/file_operations.sh` - File utilities
- `lib/metrics_validation.sh` - Metrics validation
- `lib/git_cache.sh` - Git operations
- `lib/backlog.sh` - Issue tracking
- `lib/summary.sh` - Reporting
- `lib/colors.sh` - Terminal formatting
- `lib/utils.sh` - Common utilities
- `lib/validation.sh` - Status tracking

### G. Change History

| Version | Date | Changes | Consolidated From |
|---------|------|---------|-------------------|
| 2.4.1 | 2025-12-23 | Updated FR-WF-1 to include Steps 12, 13, 14 as mandatory prerequisites for Step 11 | New Requirement (2025-12-23) |
| 2.4.0 | 2025-12-23 | Added mandatory workflow step dependencies section (FR-WF-1 through FR-WF-5) | N/A |
| 2.3.0 | 2025-12-23 | Added Third-Party File Exclusion requirements (complete implementation) | THIRD_PARTY_EXCLUSION_MODULE.md |
| 2.2.0 | 2025-12-23 | Enhanced prompt execution with comprehensive tool access flags | N/A |
| 2.1.1 | 2025-12-23 | Added Shell Automation Persona Quick Reference (Appendix I) | SHELL_AUTOMATION_PERSONA_SUMMARY.md |
| 2.1.0 | 2025-12-23 | Added Shell Automation Documentation Specialist Persona | SHELL_AUTOMATION_DOCUMENTATION_SPECIALIST_PERSONA.md |
| 2.0.0 | 2025-12-22 | Initial consolidated document | STEP_01, STEP_02, STEP_03, CLIENT_SPA FRs |
| 1.0.0 | 2025-12-15 | Individual Step 3 requirements | N/A |
| 1.0.0 | 2025-12-14 | Individual Step 2 requirements | N/A |
| 1.1.0 | 2025-12-15 | Individual Step 1 requirements (with v1.5.0 performance features) | N/A |
| 1.0.0 | 2025-12-22 | CLIENT_SPA project kind requirements | N/A |

### H. Glossary

**Workflow Terms:**

- **Step**: Individual workflow execution unit
- **Backlog**: Issue tracking system for workflow
- **Summary**: Concise step completion report
- **Dry-Run**: Preview mode without modifications

**Technical Terms:**

- **SPA**: Single Page Application
- **ES6+**: Modern JavaScript (ECMAScript 2015+)
- **PWA**: Progressive Web App
- **CSP**: Content Security Policy
- **WCAG**: Web Content Accessibility Guidelines
- **TTL**: Time To Live (cache expiration)
- **Semver**: Semantic Versioning (MAJOR.MINOR.PATCH)

**AI Terms:**

- **Persona**: Specialized AI role for specific tasks
- **Prompt**: Structured input for AI analysis
- **Context**: Information provided to AI for analysis

### I. Shell Automation Persona Quick Reference

This quick reference provides a summary of the Shell Automation Documentation Specialist Persona for rapid consultation.

#### Persona Summary

A senior technical documentation specialist with 20+ years of Bash/shell scripting experience, specialized in:

- **Shell Script Mastery**: Bash 4.0+, POSIX compatibility, advanced patterns
- **Automation Workflows**: CI/CD, orchestration, dependency management
- **Quality Standards**: Google Shell Style Guide, ShellCheck compliance
- **DevOps Documentation**: Command-line tools, pipeline integration, troubleshooting

#### Key Expertise Areas

**Shell Scripting:**

- Error handling (set -euo pipefail, trap handlers)
- Variable handling and quoting best practices
- Command/process substitution patterns
- Array handling and parameter expansion
- Exit codes and signal handling

**Documentation Patterns:**

- Function headers (parameters, returns, side effects)
- Script headers (purpose, usage, dependencies)
- Module APIs (exported functions, contracts)
- Workflow steps (prerequisites, execution, criteria)
- Troubleshooting guides

**Quality Assurance:**

- ShellCheck integration and rule documentation
- Exit code conventions (0=success, 1+=errors)
- Logging standards (stdout/stderr separation)
- Variable naming conventions
- Testing documentation (bats, bash_unit)

#### Quick Format Templates

**Function Documentation Template:**

```bash
#######################################
# Brief function description
# Globals:
#   GLOBAL_VAR - Usage description
# Arguments:
#   $1 - Parameter description
# Outputs:
#   Writes to stdout/stderr
# Returns:
#   0 - Success
#   1 - Error condition
#######################################
function_name() {
    local param="$1"
    # Implementation
}
```

**Script Header Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Script Name
# Purpose: Clear description
# Usage: script.sh [options] <args>
# Dependencies: List here
# Exit Codes:
#   0 - Success
#   1 - Error
################################################################################
```

#### Integration Points

**Configuration Files:**

- `project_kinds.yaml` - Defines `shell_script_automation` type
- `.workflow-config.yaml` - Sets `primary_language: bash`
- `ai_helpers.yaml` - Contains persona prompts

**Usage in Workflow Steps:**

```bash
# Step 1 - Documentation Analysis
ai_call "shell_automation_documentation_specialist" \
    "Analyze shell script changes: ${files}" \
    "output.md"
```

#### Benefits Checklist

✅ **Shell-Specific**: Understands bash idioms and POSIX compatibility  
✅ **Quality-Focused**: Enforces ShellCheck and Google Shell Style Guide  
✅ **Automation-Aware**: Documents CI/CD and workflow orchestration  
✅ **Practical**: Provides copy-paste examples and troubleshooting  
✅ **Consistent**: Maintains uniform documentation standards  

#### Quick Start Guide

1. **Review Full Persona**: See Section "Shell Automation Documentation Specialist Persona" above
2. **Check Examples**: See FR-5.x for function, script, and README examples
3. **Integrate**: Use in Step 1 documentation analysis (FR-5.8)
4. **Customize**: Extend for project-specific needs in `ai_helpers.yaml`

---

**Document Status:** ✅ Complete  
**Last Consolidated:** December 23, 2025  
**Next Review:** Upon module version updates or architectural changes  
**Consolidation Source Files:**

- `docs/workflow-automation/STEP_01_FUNCTIONAL_REQUIREMENTS.md`
- `docs/workflow-automation/STEP_02_FUNCTIONAL_REQUIREMENTS.md`
- `docs/workflow-automation/STEP_03_FUNCTIONAL_REQUIREMENTS.md`
- `docs/CLIENT_SPA_PROJECT_KIND_FUNCTIONAL_REQUIREMENTS.md`
- `docs/SHELL_AUTOMATION_DOCUMENTATION_SPECIALIST_PERSONA.md`
- `docs/workflow-automation/SHELL_AUTOMATION_PERSONA_SUMMARY.md`
