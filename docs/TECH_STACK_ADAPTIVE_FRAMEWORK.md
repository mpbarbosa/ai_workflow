# Tech Stack Adaptive Framework - Functional Requirements

**Version**: 1.0.0  
**Date**: 2025-12-18  
**Status**: RFC (Request for Comments)  
**Phase**: Design & Requirements  

---

## Executive Summary

This document defines the functional requirements for a **Tech Stack Adaptive Framework** that enables the AI Workflow Automation system to intelligently adapt to different project technology stacks. This framework introduces a project configuration file (`.workflow-config.yaml`) that stores project-specific metadata, allowing the workflow to customize its behavior, prompts, and validations based on the target project's technology.

### Problem Statement

**Current State**:

- Workflow assumes Node.js/JavaScript tech stack
- Hard-coded validations (e.g., `package.json`, `npm`, `node`)
- Generic AI prompts not optimized for specific languages
- Manual workarounds needed for Python, Go, Java, etc. projects

**Impact**:

- ❌ Fails on non-JavaScript projects
- ❌ Generic prompts produce suboptimal results
- ❌ Users must manually skip/modify steps
- ❌ Limited adoption in multi-language teams

**Proposed Solution**:

- ✅ Project configuration file (`.workflow-config.yaml`)
- ✅ Tech stack detection and validation
- ✅ Dynamic prompt generation per language
- ✅ Adaptive step execution logic
- ✅ Multi-language support out-of-the-box

---

## Goals & Objectives

### Primary Goals

1. **Universal Compatibility** (P0)
   - Support 8+ major programming languages
   - Adapt to different build systems and package managers
   - Work with various project structures

2. **Intelligent Adaptation** (P0)
   - Auto-detect tech stack when config missing
   - Customize AI prompts per language
   - Skip irrelevant validation steps
   - Adjust file search patterns

3. **User Experience** (P1)
   - Simple configuration (5 lines max)
   - Automatic setup wizard
   - Clear error messages
   - Backward compatible with v2.4.0

4. **Maintainability** (P1)
   - Centralized tech stack definitions
   - Easy to add new languages
   - Template-based prompt system
   - Minimal code duplication

### Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Language Support** | 8+ languages | Count of supported stacks |
| **Setup Time** | < 2 minutes | Time to configure new project |
| **Accuracy** | 95%+ | Auto-detection success rate |
| **Adoption** | 80%+ | Projects using config file |
| **Error Reduction** | 70%+ | Failed validations vs baseline |

---

## Functional Requirements

### FR-1: Project Configuration File

**ID**: FR-1  
**Priority**: P0 (Must Have)  
**Description**: Define a YAML configuration file that stores project metadata

#### FR-1.1: Configuration File Location

**Requirement**: Configuration file located in project root

**Specification**:

- **File Name**: `.workflow-config.yaml` or `.workflow-config.yml`
- **Location**: Project root directory (where workflow executes)
- **Format**: YAML (human-readable, easy to edit)
- **Encoding**: UTF-8
- **Optional**: File is optional; workflow falls back to auto-detection

**Example**:

```root
/path/to/project/
├── .workflow-config.yaml  ← Configuration file
├── src/
├── tests/
└── README.md
```

#### FR-1.2: Configuration Schema

**Requirement**: Standardized YAML schema for project metadata

**Schema Definition**:

```yaml
# .workflow-config.yaml - Project Configuration for AI Workflow Automation
# Version: 1.0

project:
  name: "my-awesome-project"           # Project display name
  description: "Brief project description"  # Optional
  repository: "https://github.com/..."  # Optional

tech_stack:
  primary_language: "python"            # Main programming language
  languages:                            # Additional languages (optional)
    - python
    - javascript
    - bash
  
  build_system: "pip"                   # Build/package manager
  build_tools:                          # Additional tools (optional)
    - make
    - docker
  
  test_framework: "pytest"              # Testing framework
  test_command: "pytest tests/"         # Command to run tests
  
  linter: "pylint"                      # Code linter
  lint_command: "pylint src/"           # Command to run linter

structure:
  source_dirs:                          # Source code directories
    - src
    - lib
  
  test_dirs:                            # Test directories
    - tests
    - __tests__
  
  docs_dirs:                            # Documentation directories
    - docs
    - documentation
  
  exclude_dirs:                         # Directories to exclude
    - venv
    - .venv
    - __pycache__
    - .pytest_cache
    - dist
    - build
  
  entry_point: "src/main.py"           # Main entry point (optional)

dependencies:
  package_file: "requirements.txt"      # Dependency file
  lock_file: "requirements.lock"        # Lock file (optional)
  install_command: "pip install -r requirements.txt"  # Install command

ai_prompts:
  language_context: |                   # Additional context for AI
    This is a Python data science project using pandas and numpy.
    Focus on scientific computing best practices.
  
  custom_instructions:                  # Custom AI instructions (optional)
    - "Prioritize type hints"
    - "Follow PEP 8 style guide"
    - "Use docstrings for all functions"
```

#### FR-1.3: Supported Tech Stacks

**Requirement**: Support for major programming languages and ecosystems

**Supported Languages** (v1.0):

| Language | Build System | Test Framework | Linter |
|----------|-------------|----------------|--------|
| **JavaScript/Node.js** | npm, yarn, pnpm | jest, mocha, vitest | eslint, prettier |
| **Python** | pip, poetry, pipenv | pytest, unittest | pylint, flake8, black |
| **Java** | maven, gradle | junit, testng | checkstyle, spotbugs |
| **Go** | go mod | go test | golint, staticcheck |
| **Ruby** | bundler, gem | rspec, minitest | rubocop |
| **Rust** | cargo | cargo test | clippy |
| **C/C++** | make, cmake | gtest, catch2 | clang-tidy, cppcheck |
| **Bash/Shell** | N/A | bats, shunit2 | shellcheck |

**Future Support** (v2.0):

- PHP, Swift, Kotlin, TypeScript, Scala, Elixir

#### FR-1.4: Configuration Validation

**Requirement**: Validate configuration file on workflow startup

**Validation Rules**:

1. **Schema Validation**: Ensure YAML follows schema
2. **Required Fields**: Validate required fields present
3. **Value Validation**: Check valid values for enums
4. **Path Validation**: Verify directories exist
5. **Command Validation**: Check commands executable

**Error Handling**:

- Display clear validation errors
- Suggest corrections
- Fall back to auto-detection if validation fails

**Example Validation Output**:

```text
⚠️  Configuration Validation Warnings:
  - tech_stack.primary_language: "nodejs" should be "javascript"
  - structure.source_dirs: Directory "lib" does not exist
  - dependencies.package_file: "package.json" not found

ℹ️  Using auto-detection for missing/invalid fields...
```

---

### FR-2: Tech Stack Auto-Detection

**ID**: FR-2  
**Priority**: P0 (Must Have)  
**Description**: Automatically detect project tech stack when config missing

#### FR-2.1: Detection Strategy

**Requirement**: Multi-signal detection using file patterns and heuristics

**Detection Signals**:

| Signal | Weight | Examples |
|--------|--------|----------|
| **Package Files** | High | `package.json`, `requirements.txt`, `Cargo.toml` |
| **Lock Files** | High | `package-lock.json`, `poetry.lock`, `go.sum` |
| **Config Files** | Medium | `.eslintrc`, `pytest.ini`, `Makefile` |
| **Source Files** | Medium | `*.py`, `*.js`, `*.go` by count/ratio |
| **Directory Structure** | Low | `node_modules`, `venv`, `target` |

**Detection Algorithm**:

```text
1. Scan project root for package files
2. If multiple found, rank by file priority
3. Count source files by extension
4. Calculate language confidence scores
5. Select primary language (highest score)
6. Detect secondary languages (score > 20%)
7. Infer build system from package files
8. Detect test framework from config/imports
```

#### FR-2.2: Detection Examples

**JavaScript/Node.js Detection**:

```txt
Signals:
  ✓ package.json found (High confidence)
  ✓ package-lock.json found
  ✓ node_modules/ directory
  ✓ .eslintrc.js config
  ✓ 150 *.js files, 20 *.ts files

Result:
  Primary Language: JavaScript
  Build System: npm
  Test Framework: jest (detected from package.json)
  Confidence: 98%
```

**Python Detection**:

```text
Signals:
  ✓ requirements.txt found (High confidence)
  ✓ pyproject.toml found
  ✓ venv/ directory
  ✓ pytest.ini config
  ✓ 80 *.py files

Result:
  Primary Language: Python
  Build System: pip
  Test Framework: pytest
  Confidence: 95%
```

**Multi-Language Detection**:

```text
Signals:
  ✓ package.json found
  ✓ requirements.txt found
  ✓ 100 *.js files (60%)
  ✓ 65 *.py files (40%)

Result:
  Primary Language: JavaScript (60% of code)
  Secondary Languages: Python (40%)
  Build Systems: npm, pip
  Confidence: 92%
```

#### FR-2.3: Detection Fallback

**Requirement**: Graceful fallback when detection uncertain

**Fallback Strategy**:

1. If confidence < 80%, prompt user for confirmation
2. If confidence < 50%, prompt user to create config
3. If no signals found, use universal default
4. Always log detection reasoning for debugging

**Interactive Prompt** (if confidence < 80%):

```text
🔍 Tech Stack Detection Results:

  Detected: Python (72% confidence)
  Build System: pip
  Test Framework: pytest

  Based on:
    ✓ requirements.txt found
    ✓ 45 *.py files
    ✗ No pyproject.toml
    ✗ No virtual environment found

  Is this correct? (Y/n)
  > 

  Would you like to create .workflow-config.yaml? (Y/n)
  >
```

---

### FR-3: Adaptive Workflow Execution

**ID**: FR-3  
**Priority**: P0 (Must Have)  
**Description**: Adapt workflow behavior based on detected tech stack

#### FR-3.1: Step Adaptation

**Requirement**: Enable/disable steps based on tech stack

**Adaptation Rules**:

| Step | JavaScript | Python | Go | Java |
|------|-----------|--------|-----|------|
| **Step 8: Dependencies** | npm audit | pip check | go mod verify | mvn verify |
| **Step 9: Code Quality** | eslint | pylint | go vet | checkstyle |
| **Step 7: Test Execution** | npm test | pytest | go test | mvn test |

**Implementation**:

```bash
# Pseudo-code
step8_validate_dependencies() {
    case "$PRIMARY_LANGUAGE" in
        javascript)
            run_npm_audit
            ;;
        python)
            run_pip_check
            run_safety_check
            ;;
        go)
            run_go_mod_verify
            ;;
        *)
            print_info "Dependency validation not configured for $PRIMARY_LANGUAGE"
            ;;
    esac
}
```

#### FR-3.2: File Pattern Adaptation

**Requirement**: Adjust file search patterns per language

**Language-Specific Patterns**:

```yaml
javascript:
  source_extensions: [".js", ".jsx", ".ts", ".tsx", ".mjs"]
  test_patterns: ["*.test.js", "*.spec.js", "__tests__/**"]
  exclude_dirs: ["node_modules", "dist", "build", "coverage"]
  
python:
  source_extensions: [".py"]
  test_patterns: ["test_*.py", "*_test.py", "tests/**"]
  exclude_dirs: ["venv", ".venv", "__pycache__", ".pytest_cache", "dist", "build"]
  
go:
  source_extensions: [".go"]
  test_patterns: ["*_test.go"]
  exclude_dirs: ["vendor", "bin"]
  
java:
  source_extensions: [".java"]
  test_patterns: ["*Test.java", "*Tests.java"]
  exclude_dirs: ["target", "build", ".gradle"]
```

**Usage Example**:

```bash
# Adaptive file search
find_source_files() {
    local extensions="${TECH_STACK_CONFIG[source_extensions]}"
    local exclude_dirs="${TECH_STACK_CONFIG[exclude_dirs]}"
    
    find . -type f \
        \( -name "$extensions" \) \
        ! -path "*/$exclude_dirs/*" \
        -print
}
```

#### FR-3.3: Command Adaptation

**Requirement**: Execute language-appropriate commands

**Command Templates**:

```yaml
javascript:
  install: "npm install"
  test: "npm test"
  lint: "npm run lint"
  build: "npm run build"
  clean: "rm -rf node_modules dist"

python:
  install: "pip install -r requirements.txt"
  test: "pytest"
  lint: "pylint src/"
  format: "black src/"
  clean: "rm -rf venv __pycache__ .pytest_cache"

go:
  install: "go mod download"
  test: "go test ./..."
  lint: "golangci-lint run"
  build: "go build ./..."
  clean: "go clean"

java:
  install: "mvn install"
  test: "mvn test"
  lint: "mvn checkstyle:check"
  build: "mvn package"
  clean: "mvn clean"
```

---

### FR-4: Adaptive AI Prompts

**ID**: FR-4  
**Priority**: P0 (Must Have)  
**Description**: Generate language-specific AI prompts

#### FR-4.1: Prompt Template System

**Requirement**: Template-based prompts with language variables

**Template Structure**:

```yaml
# Template: src/workflow/config/ai_prompts_templates.yaml

documentation_update:
  base_prompt: |
    You are a technical documentation specialist for {{LANGUAGE}} projects.
    
    Task: Review and update project documentation.
    
    Context:
    - Language: {{LANGUAGE}}
    - Build System: {{BUILD_SYSTEM}}
    - Test Framework: {{TEST_FRAMEWORK}}
    
    {{LANGUAGE_SPECIFIC_INSTRUCTIONS}}
    
    Standards:
    {{LANGUAGE_STANDARDS}}
  
  language_specific_instructions:
    javascript: |
      - Focus on JSDoc comments
      - Document async/await patterns
      - Include TypeScript types if applicable
      - Reference npm packages correctly
    
    python: |
      - Follow PEP 257 docstring conventions
      - Use type hints (PEP 484)
      - Document exceptions raised
      - Reference PyPI packages correctly
    
    go: |
      - Follow godoc conventions
      - Document exported functions/types
      - Include usage examples
      - Reference go modules correctly
    
    java: |
      - Use Javadoc format
      - Document parameters and return values
      - Include @throws annotations
      - Reference Maven/Gradle dependencies
  
  language_standards:
    javascript:
      - "Follow MDN Web Docs style"
      - "Use ESLint documentation patterns"
    python:
      - "Follow PEP 8 style guide"
      - "Use NumPy docstring format for data science"
    go:
      - "Follow Effective Go guidelines"
      - "Use standard library conventions"
    java:
      - "Follow Oracle Java Code Conventions"
      - "Use standard Javadoc tags"
```

#### FR-4.2: Prompt Generation

**Requirement**: Dynamic prompt generation from templates

**Generation Process**:

```bash
generate_ai_prompt() {
    local persona="$1"      # e.g., "documentation_specialist"
    local language="$2"     # e.g., "python"
    local build_system="$3" # e.g., "pip"
    
    # Load template
    local template=$(load_prompt_template "$persona")
    
    # Get language-specific instructions
    local lang_instructions=$(get_language_instructions "$persona" "$language")
    local lang_standards=$(get_language_standards "$language")
    
    # Substitute variables
    template="${template//\{\{LANGUAGE\}\}/$language}"
    template="${template//\{\{BUILD_SYSTEM\}\}/$build_system}"
    template="${template//\{\{TEST_FRAMEWORK\}\}/$test_framework}"
    template="${template//\{\{LANGUAGE_SPECIFIC_INSTRUCTIONS\}\}/$lang_instructions}"
    template="${template//\{\{LANGUAGE_STANDARDS\}\}/$lang_standards}"
    
    # Add custom context from config
    if [[ -n "${CONFIG[ai_prompts.language_context]}" ]]; then
        template="$template\n\nProject Context:\n${CONFIG[ai_prompts.language_context]}"
    fi
    
    echo "$template"
}
```

#### FR-4.3: Example Generated Prompts

**JavaScript Project**:

```text
You are a technical documentation specialist for JavaScript projects.

Task: Review and update project documentation.

Context:
- Language: JavaScript
- Build System: npm
- Test Framework: jest

Language-Specific Instructions:
- Focus on JSDoc comments
- Document async/await patterns
- Include TypeScript types if applicable
- Reference npm packages correctly

Standards:
- Follow MDN Web Docs style
- Use ESLint documentation patterns

Project Context:
This is a React web application using modern ES6+ features.
```

**Python Project**:

```text
You are a technical documentation specialist for Python projects.

Task: Review and update project documentation.

Context:
- Language: Python
- Build System: pip
- Test Framework: pytest

Language-Specific Instructions:
- Follow PEP 257 docstring conventions
- Use type hints (PEP 484)
- Document exceptions raised
- Reference PyPI packages correctly

Standards:
- Follow PEP 8 style guide
- Use NumPy docstring format for data science

Project Context:
This is a Python data science project using pandas and numpy.
Focus on scientific computing best practices.
```

---

### FR-5: Configuration Management

**ID**: FR-5  
**Priority**: P1 (Should Have)  
**Description**: Tools for creating and managing project configuration

#### FR-5.1: Interactive Setup Wizard

**Requirement**: Command-line wizard to create configuration file

**Command**:

```bash
./execute_tests_docs_workflow.sh --init-config
# or
./execute_tests_docs_workflow.sh --setup
```

**Wizard Flow**:

```text
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║        AI Workflow Automation - Project Setup Wizard             ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝

Welcome! This wizard will help you configure the workflow for your project.

🔍 Analyzing project...

  Detected: Python project (95% confidence)
  - Found: requirements.txt
  - Found: 80 *.py files
  - Found: pytest.ini

Step 1/5: Project Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Project name: [my-awesome-project] █
  
  Description (optional): █

Step 2/5: Tech Stack
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Primary language: [python] ← detected
  
  Additional languages (comma-separated, optional): bash█
  
  Build system: 
    1) pip (detected) ←
    2) poetry
    3) pipenv
  Select [1]: █
  
  Test framework:
    1) pytest (detected) ←
    2) unittest
    3) nose
  Select [1]: █

Step 3/5: Project Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Source directories: [src] █
  
  Test directories: [tests] █
  
  Documentation directories: [docs] █
  
  Exclude directories (detected):
    - venv
    - __pycache__
    - .pytest_cache
  
  Add more? (y/N): █

Step 4/5: Commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Install command: [pip install -r requirements.txt] █
  
  Test command: [pytest tests/] █
  
  Lint command (optional): [pylint src/] █

Step 5/5: AI Context (optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Add custom context for AI prompts?
  This helps generate more relevant suggestions.
  
  (y/N): y█
  
  Context: This is a Python data science project using pandas and numpy.█
  
  Custom instructions (comma-separated, optional):
  > Use type hints, Follow PEP 8█

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Configuration complete!

  File: .workflow-config.yaml
  
  Preview:
  ┌───────────────────────────────────────────────────────────────┐
  │ project:                                                      │
  │   name: "my-awesome-project"                                  │
  │                                                               │
  │ tech_stack:                                                   │
  │   primary_language: "python"                                  │
  │   languages: [python, bash]                                   │
  │   build_system: "pip"                                         │
  │   test_framework: "pytest"                                    │
  │   linter: "pylint"                                            │
  │ ...                                                           │
  └───────────────────────────────────────────────────────────────┘

  Create this file? (Y/n): █
```

#### FR-5.2: Configuration Templates

**Requirement**: Pre-built templates for common tech stacks

**Template Repository**:

```text
src/workflow/config/templates/
├── javascript-node.yaml
├── python-pip.yaml
├── python-poetry.yaml
├── go-module.yaml
├── java-maven.yaml
├── java-gradle.yaml
├── ruby-bundler.yaml
├── rust-cargo.yaml
└── shell-script.yaml
```

**Usage**:

```bash
# Create config from template
./execute_tests_docs_workflow.sh --init-config --template python-pip

# List available templates
./execute_tests_docs_workflow.sh --list-templates
```

#### FR-5.3: Configuration Validation Tool

**Requirement**: Standalone tool to validate configuration

**Command**:

```bash
# Validate current config
./execute_tests_docs_workflow.sh --validate-config

# Validate specific file
./execute_tests_docs_workflow.sh --validate-config path/to/config.yaml
```

**Output**:

```text
╔═══════════════════════════════════════════════════════════════════╗
║           Configuration Validation Report                         ║
╚═══════════════════════════════════════════════════════════════════╝

File: .workflow-config.yaml

✅ Schema Validation: PASSED
✅ Required Fields: PASSED
✅ Value Validation: PASSED

⚠️  Warnings (2):
  1. structure.source_dirs: Directory "lib" does not exist
     → Suggestion: Remove or create directory
     
  2. dependencies.package_file: "requirements.txt" not found
     → Suggestion: Update path or create file

ℹ️  Recommendations (3):
  1. Consider adding test_framework for better test detection
  2. Add linter configuration for code quality checks
  3. Specify exclude_dirs to improve performance

Overall: ✅ VALID (with warnings)
```

---

### FR-6: Library Module Integration

**ID**: FR-6  
**Priority**: P0 (Must Have)  
**Description**: Create library module for tech stack management

#### FR-6.1: Module Structure

**File**: `src/workflow/lib/tech_stack.sh`

**Functions**:

```bash
# Core functions
load_tech_stack_config()      # Load .workflow-config.yaml
detect_tech_stack()            # Auto-detect if no config
validate_tech_stack_config()  # Validate configuration
get_tech_stack_property()     # Get config property
is_language_supported()       # Check language support

# Language-specific functions
get_source_extensions()        # Get file extensions for language
get_test_patterns()            # Get test file patterns
get_exclude_patterns()         # Get directories to exclude
get_install_command()          # Get dependency install command
get_test_command()             # Get test execution command
get_lint_command()             # Get linting command

# AI prompt functions
generate_language_prompt()     # Generate language-specific prompt
load_prompt_template()         # Load prompt template
substitute_prompt_variables()  # Replace template variables

# Utility functions
get_supported_languages()      # List all supported languages
get_language_confidence()      # Get detection confidence score
print_tech_stack_summary()     # Display detected tech stack
create_default_config()        # Create default config file
```

#### FR-6.2: Configuration Cache

**Requirement**: Cache parsed configuration for performance

**Implementation**:

```bash
declare -A TECH_STACK_CONFIG
declare -A TECH_STACK_CACHE

init_tech_stack() {
    print_info "Loading tech stack configuration..."
    
    # Try to load config file
    if [[ -f ".workflow-config.yaml" ]]; then
        load_tech_stack_config ".workflow-config.yaml"
        print_success "Loaded configuration from .workflow-config.yaml"
    else
        # Auto-detect
        print_info "No configuration found, auto-detecting..."
        detect_tech_stack
        print_success "Auto-detected: ${TECH_STACK_CONFIG[primary_language]}"
    fi
    
    # Validate
    validate_tech_stack_config || {
        print_warning "Configuration validation failed, using defaults"
        load_default_tech_stack
    }
    
    # Cache commonly used values
    TECH_STACK_CACHE[primary_language]="${TECH_STACK_CONFIG[primary_language]}"
    TECH_STACK_CACHE[build_system]="${TECH_STACK_CONFIG[build_system]}"
    TECH_STACK_CACHE[test_framework]="${TECH_STACK_CONFIG[test_framework]}"
    
    # Log summary
    log_to_workflow "INFO" "Tech stack: ${TECH_STACK_CACHE[primary_language]}"
}
```

#### FR-6.3: Global Exports

**Requirement**: Export tech stack variables for use in steps

**Exported Variables**:

```bash
export PRIMARY_LANGUAGE="${TECH_STACK_CONFIG[primary_language]}"
export BUILD_SYSTEM="${TECH_STACK_CONFIG[build_system]}"
export TEST_FRAMEWORK="${TECH_STACK_CONFIG[test_framework]}"
export TEST_COMMAND="${TECH_STACK_CONFIG[test_command]}"
export LINT_COMMAND="${TECH_STACK_CONFIG[lint_command]}"
export INSTALL_COMMAND="${TECH_STACK_CONFIG[install_command]}"

# Language-specific patterns (arrays)
export SOURCE_EXTENSIONS="${TECH_STACK_CONFIG[source_extensions]}"
export TEST_PATTERNS="${TECH_STACK_CONFIG[test_patterns]}"
export EXCLUDE_PATTERNS="${TECH_STACK_CONFIG[exclude_patterns]}"
```

---

### FR-7: Workflow Integration

**ID**: FR-7  
**Priority**: P0 (Must Have)  
**Description**: Integrate tech stack system into workflow execution

#### FR-7.1: Pre-Flight Integration

**Requirement**: Initialize tech stack in pre-flight orchestrator

**Changes to** `orchestrators/pre_flight.sh`:

```bash
execute_preflight() {
    print_header "Pre-Flight Checks & Initialization"
    log_to_workflow "INFO" "Starting pre-flight phase"
    
    # ... existing checks ...
    
    # NEW: Initialize tech stack
    init_tech_stack || {
        print_error "Tech stack initialization failed"
        return 1
    }
    
    # Display tech stack info
    print_tech_stack_summary
    
    # ... rest of function ...
}
```

#### FR-7.2: Step Adaptation

**Requirement**: Adapt steps to use tech stack configuration

**Example - Step 8 (Dependencies)**:

```bash
# Before (hardcoded)
step8_validate_dependencies() {
    if [[ ! -f "package.json" ]]; then
        print_error "package.json not found"
        return 1
    fi
    
    npm audit
}

# After (adaptive)
step8_validate_dependencies() {
    local package_file="${TECH_STACK_CONFIG[package_file]}"
    local install_cmd="${TECH_STACK_CONFIG[install_command]}"
    
    if [[ ! -f "$package_file" ]]; then
        print_warning "Package file not found: $package_file"
        return 0  # Not an error for all tech stacks
    fi
    
    case "$PRIMARY_LANGUAGE" in
        javascript)
            npm audit || npm audit --audit-level=moderate
            ;;
        python)
            pip check
            safety check --json || true  # Optional security check
            ;;
        go)
            go mod verify
            go list -m all | nancy sleuth || true  # Optional
            ;;
        java)
            mvn dependency:analyze
            ;;
        *)
            print_info "Dependency validation not configured for $PRIMARY_LANGUAGE"
            ;;
    esac
}
```

**Example - Step 7 (Test Execution)**:

```bash
# Before (hardcoded)
step7_execute_test_suite() {
    npm test
}

# After (adaptive)
step7_execute_test_suite() {
    local test_cmd="${TECH_STACK_CONFIG[test_command]}"
    
    if [[ -z "$test_cmd" ]]; then
        print_warning "No test command configured"
        return 0
    fi
    
    print_info "Executing: $test_cmd"
    eval "$test_cmd" || {
        print_error "Tests failed"
        return 1
    }
}
```

#### FR-7.3: AI Prompt Integration

**Requirement**: Use adaptive prompts in AI-enhanced steps

**Example - Step 1 (Documentation)**:

```bash
# Before (generic prompt)
step1_update_documentation() {
    local prompt="You are a documentation specialist. Review documentation..."
    ai_call "documentation_specialist" "$prompt" "$output_file"
}

# After (adaptive prompt)
step1_update_documentation() {
    # Generate language-specific prompt
    local prompt=$(generate_language_prompt "documentation_update" "$PRIMARY_LANGUAGE")
    
    # Add detected build system context
    prompt="$prompt\n\nBuild System: $BUILD_SYSTEM"
    prompt="$prompt\nTest Framework: $TEST_FRAMEWORK"
    
    ai_call "documentation_specialist" "$prompt" "$output_file"
}
```

---

## Non-Functional Requirements

### NFR-1: Performance

**Requirement**: Minimal performance impact from tech stack detection

**Targets**:

- Config loading: < 100ms
- Auto-detection: < 500ms
- Prompt generation: < 50ms
- Total overhead: < 1s

**Optimization Strategies**:

- Cache parsed configuration
- Lazy load prompt templates
- Parallel file scanning for detection
- Memoize expensive operations

### NFR-2: Usability

**Requirement**: Simple, intuitive user experience

**Guidelines**:

- Auto-detection should "just work" 95% of the time
- Setup wizard completes in < 2 minutes
- Error messages provide clear guidance
- Configuration file human-readable and editable

### NFR-3: Maintainability

**Requirement**: Easy to add new languages and templates

**Design Principles**:

- Centralized language definitions
- Template-based prompt system
- Minimal code duplication
- Clear extension points

**Adding New Language** (target: < 30 minutes):

1. Add language definition to `tech_stack_definitions.yaml`
2. Create prompt templates in `ai_prompts_templates.yaml`
3. Add detection patterns
4. Test with sample project

### NFR-4: Compatibility

**Requirement**: Backward compatible with v2.4.0

**Guarantees**:

- Existing workflows work without config file
- Auto-detection defaults to JavaScript/Node.js
- No breaking changes to command-line interface
- All v2.4.0 features preserved

### NFR-5: Extensibility

**Requirement**: Support for custom tech stacks and plugins

**Future Capabilities**:

- User-defined language definitions
- Custom prompt templates
- Third-party tech stack plugins
- API for programmatic configuration

---

## Implementation Plan

### Phase 1: Foundation (Week 1-2)

**Deliverables**:

- [x] Requirements document (this file)
- [ ] Configuration schema definition (YAML)
- [ ] Tech stack library module (`lib/tech_stack.sh`)
- [ ] Configuration parser (YAML → Bash arrays)
- [ ] Basic auto-detection (JavaScript, Python)

**Success Criteria**:

- Config file can be loaded and parsed
- Auto-detection works for 2+ languages
- Basic tests pass

### Phase 2: Detection & Validation (Week 3-4)

**Deliverables**:

- [ ] Full auto-detection (8 languages)
- [ ] Detection confidence scoring
- [ ] Configuration validation
- [ ] Interactive setup wizard
- [ ] Configuration templates

**Success Criteria**:

- Auto-detection accuracy > 90%
- Wizard creates valid configs
- Validation catches errors

### Phase 3: Workflow Integration (Week 5-6)

**Deliverables**:

- [ ] Pre-flight tech stack initialization
- [ ] Adaptive step execution (Steps 7-9)
- [ ] Language-specific file patterns
- [ ] Command adaptation
- [ ] Error handling improvements

**Success Criteria**:

- Workflow adapts to 8+ languages
- Steps execute correctly per tech stack
- No regressions in v2.4.0 features

### Phase 4: AI Prompts (Week 7-8)

**Deliverables**:

- [ ] Prompt template system
- [ ] Language-specific templates (8 languages)
- [ ] Template variable substitution
- [ ] Custom context injection
- [ ] Prompt generation integration

**Success Criteria**:

- AI prompts customized per language
- Templates cover all 13 steps
- Quality improvement measurable

### Phase 5: Polish & Documentation (Week 9-10)

**Deliverables**:

- [ ] Comprehensive documentation
- [ ] User guide for configuration
- [ ] Language support matrix
- [ ] Migration guide from v2.4.0
- [ ] Performance optimization

**Success Criteria**:

- All documentation complete
- Setup time < 2 minutes
- Performance targets met

---

## Testing Strategy

### Unit Tests

**Coverage Target**: 80%+

**Test Areas**:

- Configuration parsing
- Tech stack detection
- Validation logic
- Prompt generation
- Command substitution

**Example Tests**:

```bash
test_load_javascript_config() {
    # Test loading JavaScript project config
}

test_detect_python_project() {
    # Test auto-detection of Python projects
}

test_generate_python_prompt() {
    # Test Python-specific prompt generation
}
```

### Integration Tests

**Test Scenarios**:

1. JavaScript/Node.js project (npm)
2. Python project (pip)
3. Python project (poetry)
4. Go project
5. Java project (Maven)
6. Multi-language project
7. Project without config (auto-detection)
8. Project with invalid config (fallback)

**Test Projects**:

- Create test fixtures for each language
- Run full workflow on each
- Verify correct adaptation

### Performance Tests

**Benchmarks**:

- Config loading time
- Auto-detection time
- Prompt generation time
- Full workflow time (vs baseline)

**Targets**:

- Config loading: < 100ms
- Auto-detection: < 500ms
- No significant workflow slowdown (< 5%)

---

## Risk Analysis

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Detection Accuracy** | High | Medium | Extensive testing, user override, confidence scoring |
| **Performance Degradation** | Medium | Low | Caching, lazy loading, optimization |
| **YAML Parsing Complexity** | Medium | Medium | Use battle-tested parser, comprehensive tests |
| **Backward Compatibility** | High | Low | Thorough testing, fallback to v2.4.0 behavior |
| **Prompt Quality** | High | Medium | Expert review, A/B testing, user feedback |

### Organizational Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **User Adoption** | High | Medium | Excellent docs, wizard, auto-detection |
| **Maintenance Burden** | Medium | Medium | Modular design, clear extension points |
| **Feature Creep** | Medium | High | Strict scope, phased rollout, RFC process |

---

## Success Criteria

### Quantitative Metrics

- [ ] Support 8+ programming languages
- [ ] Auto-detection accuracy > 95%
- [ ] Setup wizard completes in < 2 minutes
- [ ] Performance overhead < 5%
- [ ] User adoption > 80% of new projects
- [ ] Error reduction > 70% (failed validations)

### Qualitative Metrics

- [ ] Positive user feedback (surveys, GitHub issues)
- [ ] Increased workflow usage in multi-language teams
- [ ] Reduced support requests for tech stack issues
- [ ] Community contributions (language templates)

---

## Future Roadmap

### v1.1: Enhanced Detection

- Machine learning-based detection
- Project structure analysis
- Dependency graph analysis
- IDE configuration detection

### v1.2: Extended Language Support

- PHP, Swift, Kotlin
- TypeScript (distinct from JavaScript)
- Scala, Elixir, Haskell

### v1.3: Custom Tech Stacks

- User-defined language configurations
- Third-party plugins
- Community template repository
- API for programmatic config

### v1.4: Cloud Integration

- Detect cloud provider (AWS, GCP, Azure)
- Infrastructure-as-code support (Terraform, Kubernetes)
- CI/CD platform detection (GitHub Actions, GitLab CI)

### v2.0: Full Adaptive Workflow

- Dynamic step generation
- Language-specific optimization strategies
- Multi-project workspaces
- Cross-language dependency tracking

---

## Appendices

### Appendix A: Example Configurations

**JavaScript/React Project**:

```yaml
project:
  name: "my-react-app"
  
tech_stack:
  primary_language: "javascript"
  languages: [javascript, css, html]
  build_system: "npm"
  test_framework: "jest"
  linter: "eslint"
  test_command: "npm test"
  lint_command: "npm run lint"

structure:
  source_dirs: [src]
  test_dirs: [src/__tests__]
  docs_dirs: [docs]
  exclude_dirs: [node_modules, build, coverage]

dependencies:
  package_file: "package.json"
  lock_file: "package-lock.json"
  install_command: "npm install"
```

**Python/Data Science Project**:

```yaml
project:
  name: "ml-pipeline"
  
tech_stack:
  primary_language: "python"
  languages: [python, bash]
  build_system: "poetry"
  test_framework: "pytest"
  linter: "pylint"
  test_command: "poetry run pytest"
  lint_command: "poetry run pylint src/"

structure:
  source_dirs: [src, notebooks]
  test_dirs: [tests]
  docs_dirs: [docs]
  exclude_dirs: [.venv, __pycache__, .pytest_cache, .ipynb_checkpoints]

dependencies:
  package_file: "pyproject.toml"
  lock_file: "poetry.lock"
  install_command: "poetry install"

ai_prompts:
  language_context: |
    This is a machine learning pipeline using scikit-learn and pandas.
    Focus on data science and ML best practices.
```

**Go Microservice**:

```yaml
project:
  name: "api-gateway"
  
tech_stack:
  primary_language: "go"
  languages: [go]
  build_system: "go mod"
  test_framework: "go test"
  linter: "golangci-lint"
  test_command: "go test ./..."
  lint_command: "golangci-lint run"

structure:
  source_dirs: [cmd, internal, pkg]
  test_dirs: [cmd, internal, pkg]
  docs_dirs: [docs]
  exclude_dirs: [vendor, bin]
  entry_point: "cmd/server/main.go"

dependencies:
  package_file: "go.mod"
  lock_file: "go.sum"
  install_command: "go mod download"
```

### Appendix B: Language Detection Patterns

**Detection Signature Matrix**:

| Language | Primary Signal | Secondary Signals | Confidence Boost |
|----------|---------------|-------------------|------------------|
| **JavaScript** | package.json | .js files, node_modules/ | +40% |
| **Python** | requirements.txt, pyproject.toml | .py files, venv/ | +40% |
| **Go** | go.mod | .go files, go.sum | +50% |
| **Java** | pom.xml, build.gradle | .java files, target/ | +50% |
| **Ruby** | Gemfile | .rb files, vendor/ | +40% |
| **Rust** | Cargo.toml | .rs files, Cargo.lock | +50% |
| **C/C++** | CMakeLists.txt, Makefile | .c/.cpp files, build/ | +30% |
| **Bash** | No package file | .sh files, shellcheck config | +20% |

### Appendix C: Glossary

- **Tech Stack**: The combination of programming languages, frameworks, and tools used in a project
- **Primary Language**: The main programming language (>50% of codebase)
- **Build System**: Tool for managing dependencies and building the project
- **Adaptive Workflow**: Workflow that modifies behavior based on project characteristics
- **Auto-Detection**: Automatic identification of project tech stack from file patterns
- **Prompt Template**: Reusable AI prompt with variable substitution
- **Configuration Schema**: Structured format for project configuration file

---

**Document Status**: ✅ RFC Ready  
**Next Steps**: Team review → Implementation Phase 1  
**Owner**: AI Workflow Automation Team  
**Last Updated**: 2025-12-18
