# Configuration File Schema Documentation

**Version**: v2.4.0  
**Last Updated**: 2025-12-23  
**Status**: ✅ Complete Reference

---

## 📋 Table of Contents

- [Overview](#overview)
- [1. .workflow-config.yaml](#1-workflow-configyaml)
- [2. paths.yaml](#2-pathsyaml)
- [3. project_kinds.yaml](#3-project_kindsyaml)
- [4. ai_prompts_project_kinds.yaml](#4-ai_prompts_project_kindsyaml)
- [5. step_relevance.yaml](#5-step_relevanceyaml)
- [6. tech_stack_definitions.yaml](#6-tech_stack_definitionsyaml)
- [7. workflow_config_schema.yaml](#7-workflow_config_schemayaml)
- [Validation Tools](#validation-tools)
- [Examples](#examples)

---

## Overview

The AI Workflow Automation system uses multiple YAML configuration files for different purposes:

| File | Purpose | Location | Lines | User Editable |
|------|---------|----------|-------|---------------|
| `.workflow-config.yaml` | Per-project workflow configuration | Project root | Variable | ✅ Yes |
| `paths.yaml` | Centralized path management | `src/workflow/config/` | 85 | ⚠️ Advanced |
| `project_kinds.yaml` | Project type definitions | `src/workflow/config/` | 730 | ⚠️ Advanced |
| `ai_prompts_project_kinds.yaml` | Project-specific AI prompts | `src/workflow/config/` | 468 | ⚠️ Advanced |
| `step_relevance.yaml` | Step relevance matrix | `src/workflow/config/` | 559 | ⚠️ Advanced |
| `tech_stack_definitions.yaml` | Technology stack definitions | `src/workflow/config/` | 568 | ⚠️ Advanced |
| `workflow_config_schema.yaml` | Schema validation rules | `src/workflow/config/` | 306 | ❌ No |

**Total Configuration**: 2,716 lines of YAML

---

## 1. .workflow-config.yaml

**Purpose**: Per-project configuration file for workflow customization  
**Location**: Project root directory  
**User Editable**: ✅ Yes (primary user configuration)

### 1.1 Complete Schema

```yaml
# Project Information
project:
  name: string                    # Project display name (max 100 chars)
  type: string                    # Project type identifier
  description: string             # Brief description (max 500 chars)
  kind: enum                      # Project kind (see section 1.2)
  repository: string              # Repository URL (optional)

# Technology Stack Configuration
tech_stack:
  primary_language: enum          # REQUIRED: Main language (see section 1.3)
  languages: [string]             # Additional languages (optional)
  build_system: string            # Build/package manager
  build_tools: [string]           # Additional build tools (optional)
  test_framework: string          # Testing framework name
  test_command: string            # Command to run tests
  linter: string                  # Code linter tool
  lint_command: string            # Command to run linter

# Project Structure
structure:
  source_dirs: [string]           # Source code directories (default: ["src"])
  test_dirs: [string]             # Test directories (default: ["tests", "test"])
  docs_dirs: [string]             # Documentation directories (default: ["docs"])
  exclude_dirs: [string]          # Directories to exclude from processing
  entry_point: string             # Main entry point file (optional)

# Dependency Configuration
dependencies:
  package_file: string            # Primary dependency file
  lock_file: string               # Lock file (optional)
  install_command: string         # Command to install dependencies

# AI Customization (Optional)
ai_prompts:
  language_context: string        # Additional context for AI prompts (max 2000 chars)
  custom_instructions: [string]   # Custom AI instructions
```

### 1.2 Valid Project Kinds

```yaml
project.kind: enum
  # Shell Script Projects
  - shell_automation            # Shell script automation tools
  - shell_script_automation     # Alias for shell_automation
  
  # Node.js Projects
  - nodejs_api                  # Node.js REST/GraphQL API
  - nodejs_cli                  # Node.js CLI tool
  - nodejs_library              # Node.js reusable library
  
  # Frontend Projects
  - static_website              # Static HTML/CSS/JS site
  - client_spa                  # Generic SPA framework
  - react_spa                   # React single-page app
  - vue_spa                     # Vue.js single-page app
  
  # Python Projects
  - python_api                  # Python REST/GraphQL API
  - python_cli                  # Python CLI tool
  - python_library              # Python reusable library
  
  # Documentation
  - documentation               # Documentation-only project
  - documentation_site          # Documentation website
  
  # Generic
  - generic                     # Generic project type
```

### 1.3 Valid Primary Languages

```yaml
tech_stack.primary_language: enum
  - javascript    # JavaScript/Node.js
  - python        # Python
  - go            # Go/Golang
  - java          # Java
  - ruby          # Ruby
  - rust          # Rust
  - cpp           # C/C++
  - bash          # Bash/Shell
  - typescript    # TypeScript
```

### 1.4 Example Configurations

#### Shell Script Automation Project

```yaml
# .workflow-config.yaml
project:
  name: "My Automation Scripts"
  type: "bash-automation-framework"
  description: "Shell script utilities for CI/CD automation"
  kind: "shell_automation"

tech_stack:
  primary_language: "bash"
  build_system: "none"
  test_framework: "bats"
  test_command: "./tests/run_all_tests.sh"
  lint_command: "shellcheck src/**/*.sh"

structure:
  source_dirs:
    - src
    - scripts
  test_dirs:
    - tests
  docs_dirs:
    - docs
  exclude_dirs:
    - node_modules
    - .git
    - backlog
```

#### Node.js API Project

```yaml
# .workflow-config.yaml
project:
  name: "My REST API"
  type: "nodejs-api"
  description: "RESTful API with Express.js"
  kind: "nodejs_api"

tech_stack:
  primary_language: "javascript"
  languages:
    - javascript
    - typescript
  build_system: "npm"
  test_framework: "jest"
  test_command: "npm test"
  linter: "eslint"
  lint_command: "npm run lint"

structure:
  source_dirs:
    - src
    - lib
  test_dirs:
    - tests
    - __tests__
  docs_dirs:
    - docs
  exclude_dirs:
    - node_modules
    - dist
    - coverage

dependencies:
  package_file: "package.json"
  lock_file: "package-lock.json"
  install_command: "npm install"
```

#### React SPA Project

```yaml
# .workflow-config.yaml
project:
  name: "My React App"
  type: "react-spa"
  description: "React single-page application"
  kind: "react_spa"

tech_stack:
  primary_language: "javascript"
  languages:
    - javascript
    - typescript
    - css
    - html
  build_system: "npm"
  build_tools:
    - vite
    - webpack
  test_framework: "jest"
  test_command: "npm test"
  linter: "eslint"
  lint_command: "npm run lint"

structure:
  source_dirs:
    - src
  test_dirs:
    - src/__tests__
    - tests
  docs_dirs:
    - docs
  exclude_dirs:
    - node_modules
    - build
    - dist
  entry_point: "src/index.js"

dependencies:
  package_file: "package.json"
  lock_file: "package-lock.json"
  install_command: "npm install"
```

#### Python API Project

```yaml
# .workflow-config.yaml
project:
  name: "My Python API"
  type: "python-api"
  description: "FastAPI REST API"
  kind: "python_api"

tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"
  test_command: "pytest"
  linter: "pylint"
  lint_command: "pylint src/"

structure:
  source_dirs:
    - src
    - app
  test_dirs:
    - tests
  docs_dirs:
    - docs
  exclude_dirs:
    - venv
    - .venv
    - __pycache__
    - .pytest_cache
  entry_point: "src/main.py"

dependencies:
  package_file: "requirements.txt"
  lock_file: "poetry.lock"
  install_command: "pip install -r requirements.txt"
```

### 1.5 Creating Your Configuration

**Option 1: Interactive Wizard** (Recommended)
```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

**Option 2: Manual Creation**
```bash
# Copy template
cp /path/to/ai_workflow/.workflow-config.yaml.template .workflow-config.yaml

# Edit with your values
vim .workflow-config.yaml
```

**Option 3: Minimal Configuration**
```yaml
# .workflow-config.yaml (minimum required)
tech_stack:
  primary_language: "bash"  # REQUIRED FIELD
```

### 1.6 Validation Rules

The workflow validates configurations against these rules:

1. **Required Fields**:
   - `tech_stack.primary_language` - MUST be present

2. **Type Validation**:
   - All string fields must be strings
   - All array fields must be arrays
   - Enum fields must match valid values

3. **Consistency Checks**:
   - If `tech_stack.languages` is specified, it must include `tech_stack.primary_language`
   - If paths specified in `structure.*`, they should exist (warning only)
   - Commands in `*_command` fields should be executable (warning only)

4. **Format Validation**:
   - URLs must match pattern: `^https?://.*`
   - Strings must not exceed max lengths

---

## 2. paths.yaml

**Purpose**: Centralized path management for portability  
**Location**: `src/workflow/config/paths.yaml`  
**User Editable**: ⚠️ Advanced users only

### 2.1 Schema

```yaml
# Base Paths
project:
  root: string          # Absolute path to project root
  name: string          # Project name

# Source Directories
directories:
  src: string           # Source directory
  public: string        # Public assets directory
  docs: string          # Documentation directory
  shell_scripts: string # Shell scripts directory
  config: string        # Configuration directory
  
  # Target Projects (where workflow may be applied)
  targets:
    [key]: string       # Project name → absolute path mapping

# Workflow Directories
workflow:
  root: string          # Workflow root directory
  lib: string           # Library modules directory
  steps: string         # Step modules directory
  backlog: string       # Execution history directory
  logs: string          # Log files directory
  summaries: string     # Summary reports directory

# Testing Configuration
testing:
  lib_tests: string     # Path to library test runner

# Node.js Configuration
node:
  required_version: string  # Required Node.js version

# Documentation Paths
documentation:
  readme: string              # Main README path
  migration_readme: string    # Migration guide path
  workflow_automation: string # Workflow docs directory

# Git Configuration
git:
  gitignore: string     # .gitignore path
  gitmodules: string    # .gitmodules path
  github_dir: string    # .github directory path

# Editor Configuration
editor:
  editorconfig: string  # .editorconfig path
  mdlrc: string         # Markdown lint config
  vscode: string        # VS Code settings directory

# Environment Detection
environment:
  current: enum         # development | staging | production
  user_home: string     # User home directory
  is_ci: boolean        # Running in CI/CD environment

# Repository Configuration
repository:
  url: string           # Repository URL
  origin: string        # Origin repository name

# Script Paths
scripts:
  workflow:
    main: string              # Main workflow script
    session_manager: string   # Session manager example
```

### 2.2 Variable Interpolation

Paths support variable interpolation using `${variable.path}` syntax:

```yaml
project:
  root: /home/user/my-project
  
workflow:
  root: ${project.root}/src/workflow     # Resolves to: /home/user/my-project/src/workflow
  lib: ${workflow.root}/lib              # Resolves to: /home/user/my-project/src/workflow/lib
```

### 2.3 Example

```yaml
# paths.yaml
project:
  root: /home/mpb/Documents/GitHub/ai_workflow
  name: ai_workflow

directories:
  src: ${project.root}/src
  docs: ${project.root}/docs
  shell_scripts: ${project.root}/src/workflow
  
  targets:
    mpbarbosa_site: /home/mpb/Documents/GitHub/mpbarbosa_site
    my_api: /home/mpb/Documents/GitHub/my_api

workflow:
  root: ${project.root}/src/workflow
  lib: ${workflow.root}/lib
  steps: ${workflow.root}/steps
  backlog: ${workflow.root}/backlog

environment:
  current: development
  user_home: /home/mpb
  is_ci: false
```

---

## 3. project_kinds.yaml

**Purpose**: Define validation rules, test commands, and quality standards per project kind  
**Location**: `src/workflow/config/project_kinds.yaml`  
**User Editable**: ⚠️ Advanced users only (730 lines)

### 3.1 Schema

```yaml
project_kinds:
  [kind_name]:
    name: string                    # Display name
    description: string             # Description
    
    # Validation rules
    validation:
      required_files: [string]      # Files that must exist
      required_directories: [string] # Directories that must exist
      optional_files: [string]      # Optional files
      file_patterns: [string]       # Expected file patterns
    
    # Test execution configuration
    testing:
      test_framework: string        # Testing framework name
      test_directory: string        # Test directory location
      test_file_pattern: string     # Test file naming pattern
      test_command: string          # Command to run tests
      coverage_required: boolean    # Whether coverage is required
      coverage_threshold: number    # Min coverage % (0-100)
    
    # Quality standards
    quality:
      linters: [object]             # Linter configurations
        - name: string              # Linter name
          enabled: boolean          # Whether linter is enabled
          command: string           # Command to run linter
          args: [string]            # Command arguments
          file_pattern: string      # Files to lint
      
      documentation_required: boolean    # Whether docs are required
      inline_comments_recommended: boolean  # Whether inline comments recommended
      readme_required: boolean      # Whether README is required
    
    # Dependencies configuration
    dependencies:
      package_files: [string]       # Dependency files
      lock_files: [string]          # Lock files
      validation_required: boolean  # Whether deps must be validated
    
    # Build configuration
    build:
      required: boolean             # Whether build is required
      build_command: string         # Command to build
      output_directory: string      # Build output directory
    
    # Deployment configuration
    deployment:
      type: enum                    # script | application | library | website
      requires_build: boolean       # Whether build required before deploy
      artifact_patterns: [string]   # Artifact file patterns
    
    # AI guidance
    ai_guidance:
      testing_standards: [string]   # Testing best practices
      style_guides: [string]        # Code style guides
      best_practices: [string]      # Best practices
      directory_standards: [string] # Directory structure standards
```

### 3.2 Example: Shell Script Automation

```yaml
project_kinds:
  shell_script_automation:
    name: "Shell Script Automation"
    description: "Bash/shell script based automation tools and utilities"
    
    validation:
      required_files:
        - "*.sh"
      required_directories:
        - "src"
      optional_files:
        - "README.md"
        - ".gitignore"
      file_patterns:
        - "*.sh"
        - "*.bash"
    
    testing:
      test_framework: "bash_unit"
      test_directory: "tests"
      test_file_pattern: "test_*.sh"
      test_command: "bash"
      coverage_required: false
      coverage_threshold: 0
    
    quality:
      linters:
        - name: "shellcheck"
          enabled: true
          command: "shellcheck"
          args: ["-x", "-S", "warning"]
          file_pattern: "*.sh"
      
      documentation_required: true
      inline_comments_recommended: true
      readme_required: true
    
    dependencies:
      package_files: []
      lock_files: []
      validation_required: false
    
    build:
      required: false
      build_command: ""
      output_directory: ""
    
    deployment:
      type: "script"
      requires_build: false
      artifact_patterns: ["*.sh"]
    
    ai_guidance:
      testing_standards:
        - "BATS testing conventions and best practices"
        - "Test with set -euo pipefail for strict error handling"
      style_guides:
        - "Google Shell Style Guide"
        - "ShellCheck recommendations"
      best_practices:
        - "Quote all variable expansions: \"${var}\""
        - "Use [[ ]] for conditionals instead of [ ]"
        - "Use functions for code organization"
```

### 3.3 Supported Project Kinds

| Kind | Description | Lines |
|------|-------------|-------|
| `shell_script_automation` | Shell script automation tools | ~100 |
| `nodejs_api` | Node.js REST/GraphQL API | ~100 |
| `nodejs_cli` | Node.js CLI application | ~100 |
| `nodejs_library` | Node.js reusable library | ~100 |
| `static_website` | Static HTML/CSS/JS site | ~100 |
| `client_spa` | Generic SPA framework | ~100 |
| `react_spa` | React single-page app | ~100 |
| `vue_spa` | Vue.js single-page app | ~100 |

---

## 4. ai_prompts_project_kinds.yaml

**Purpose**: Project kind-specific AI prompt templates for workflow steps  
**Location**: `src/workflow/config/ai_prompts_project_kinds.yaml`  
**User Editable**: ⚠️ Advanced users only (468 lines)

### 4.1 Schema

```yaml
[project_kind]:
  [persona_name]:
    role: string          # AI persona role description
    task_context: string  # Task-specific context (multiline)
    approach: string      # Recommended approach (multiline)
```

### 4.2 Available Personas

- `documentation_specialist` - Documentation updates
- `test_engineer` - Test generation and review
- `code_reviewer` - Code quality review
- `ux_designer` - UX/UI analysis (web projects only)

### 4.3 Example: Shell Automation Documentation Specialist

```yaml
shell_automation:
  documentation_specialist:
    role: "You are a senior DevOps engineer and shell script documentation specialist with expertise in automation workflows, CI/CD pipelines, and infrastructure-as-code documentation."
    
    task_context: |
      **YOUR TASK**: Analyze the changed files and update the affected documentation files.
      
      This is a shell script automation project. Update documentation to reflect:
      - New/modified script parameters, options, and flags
      - Changes to workflow orchestration or execution flow
      - Updated pipeline stages or step dependencies
      - Modified exit codes or error handling behavior
      - New/changed environment variable requirements
      - Updated execution prerequisites or system dependencies
      
      **REQUIRED ACTIONS**:
      1. Read each changed file to understand what was modified
      2. Identify which documentation files need updates
      3. Make specific, surgical edits to the affected sections
      4. Ensure all code examples in documentation still work
      5. Update inline code comments if complex logic was added
      
      **OUTPUT**: Provide the exact file edits needed.
    
    approach: |
      1. **Analyze Changes**: Review git diff for each changed file
      2. **Identify Impact**: Determine which docs are affected
      3. **Make Surgical Edits**: Update ONLY the specific sections affected
      4. **Verify Examples**: Check that shell examples match current code
      5. **Update Comments**: Add/improve inline comments for new logic
      6. **Maintain Consistency**: Keep terminology and style consistent
```

---

## 5. step_relevance.yaml

**Purpose**: Define which workflow steps are relevant for each project kind  
**Location**: `src/workflow/config/step_relevance.yaml`  
**User Editable**: ⚠️ Advanced users only (559 lines)

### 5.1 Schema

```yaml
step_relevance:
  [project_kind]:
    [step_name]: enum  # required | recommended | optional | skip
```

### 5.2 Relevance Levels

- `required` - Step must run (cannot be skipped)
- `recommended` - Step should run (can be skipped with warning)
- `optional` - Step may run (skipped without warning)
- `skip` - Step not applicable (always skipped)

### 5.3 Example

```yaml
step_relevance:
  shell_script_automation:
    step_00_analyze: required
    step_01_documentation: required
    step_02_consistency: required
    step_03_script_refs: required        # Shell scripts need validation
    step_04_directory: recommended
    step_05_test_review: required
    step_06_test_gen: recommended
    step_07_test_exec: required
    step_08_dependencies: optional       # May not have package.json
    step_09_code_quality: required
    step_10_context: recommended
    step_11_git: required
    step_12_markdown_lint: required
    step_13_prompt_engineer: skip        # Only for ai_workflow
    step_14_ux_analysis: skip            # No UI components
  
  react_spa:
    step_00_analyze: required
    step_01_documentation: required
    step_02_consistency: required
    step_03_script_refs: skip            # No shell scripts
    step_04_directory: required
    step_05_test_review: required
    step_06_test_gen: required
    step_07_test_exec: required
    step_08_dependencies: required       # Critical for React
    step_09_code_quality: required
    step_10_context: recommended
    step_11_git: required
    step_12_markdown_lint: recommended
    step_13_prompt_engineer: skip
    step_14_ux_analysis: required        # UI/UX validation critical
```

---

## 6. tech_stack_definitions.yaml

**Purpose**: Technology stack definitions and language metadata  
**Location**: `src/workflow/config/tech_stack_definitions.yaml`  
**User Editable**: ⚠️ Advanced users only (568 lines)

### 6.1 Schema

```yaml
languages:
  [language_id]:
    name: string                    # Display name
    aliases: [string]               # Alternative names
    file_extensions: [string]       # File extensions
    default_build_system: string    # Default package manager
    default_test_framework: string  # Default test framework
    common_linters: [string]        # Common linting tools
    
build_systems:
  [build_system_id]:
    name: string                    # Display name
    languages: [string]             # Supported languages
    package_file: string            # Package definition file
    lock_file: string               # Lock file name
    install_command: string         # Install command
    build_command: string           # Build command (optional)
    test_command: string            # Test command

test_frameworks:
  [framework_id]:
    name: string                    # Display name
    languages: [string]             # Supported languages
    test_command: string            # Command to run tests
    coverage_command: string        # Command for coverage
    config_files: [string]          # Configuration files
```

### 6.2 Example: JavaScript

```yaml
languages:
  javascript:
    name: "JavaScript/Node.js"
    aliases: ["js", "node", "nodejs"]
    file_extensions: [".js", ".mjs", ".cjs"]
    default_build_system: "npm"
    default_test_framework: "jest"
    common_linters: ["eslint", "jshint"]

build_systems:
  npm:
    name: "npm"
    languages: ["javascript", "typescript"]
    package_file: "package.json"
    lock_file: "package-lock.json"
    install_command: "npm install"
    build_command: "npm run build"
    test_command: "npm test"

test_frameworks:
  jest:
    name: "Jest"
    languages: ["javascript", "typescript"]
    test_command: "jest"
    coverage_command: "jest --coverage"
    config_files: ["jest.config.js", "jest.config.json"]
```

---

## 7. workflow_config_schema.yaml

**Purpose**: Schema validation rules for .workflow-config.yaml  
**Location**: `src/workflow/config/workflow_config_schema.yaml`  
**User Editable**: ❌ No (internal schema definition)

This file defines the validation rules and error messages for the workflow configuration. See Section 1 for the user-facing schema.

---

## Validation Tools

### Check Configuration Validity

```bash
# Validate your .workflow-config.yaml
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
```

### Interactive Configuration Wizard

```bash
# Create configuration interactively
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

### Manual Validation

```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.workflow-config.yaml'))"

# Validate against schema (if jsonschema installed)
pip install pyyaml jsonschema
python3 -c "
import yaml
import jsonschema
config = yaml.safe_load(open('.workflow-config.yaml'))
# Validation logic here
"
```

---

## Examples

### Minimal Configuration

```yaml
# .workflow-config.yaml (bare minimum)
tech_stack:
  primary_language: "bash"
```

### Complete Shell Project Configuration

```yaml
# .workflow-config.yaml
project:
  name: "DevOps Automation Toolkit"
  type: "bash-automation-framework"
  description: "Collection of shell scripts for CI/CD automation"
  kind: "shell_automation"
  repository: "https://github.com/user/devops-toolkit"

tech_stack:
  primary_language: "bash"
  build_system: "none"
  test_framework: "bats"
  test_command: "./tests/run_all_tests.sh"
  linter: "shellcheck"
  lint_command: "shellcheck src/**/*.sh"

structure:
  source_dirs:
    - src
    - scripts
    - bin
  test_dirs:
    - tests
  docs_dirs:
    - docs
  exclude_dirs:
    - node_modules
    - .git
    - backlog
    - logs
    - summaries

ai_prompts:
  language_context: |
    This project follows Google Shell Style Guide.
    All scripts use set -euo pipefail for strict error handling.
    Functions are documented with inline comments.
  custom_instructions:
    - "Follow ShellCheck recommendations"
    - "Quote all variable expansions"
    - "Use functions for code organization"
```

### Complete Node.js Project Configuration

```yaml
# .workflow-config.yaml
project:
  name: "Task Management API"
  type: "nodejs-api"
  description: "RESTful API for task management with Express.js"
  kind: "nodejs_api"
  repository: "https://github.com/user/task-api"

tech_stack:
  primary_language: "javascript"
  languages:
    - javascript
    - typescript
  build_system: "npm"
  build_tools:
    - webpack
  test_framework: "jest"
  test_command: "npm test"
  linter: "eslint"
  lint_command: "npm run lint"

structure:
  source_dirs:
    - src
    - lib
    - controllers
    - models
  test_dirs:
    - tests
    - __tests__
  docs_dirs:
    - docs
    - api-docs
  exclude_dirs:
    - node_modules
    - dist
    - coverage
    - .nyc_output
  entry_point: "src/index.js"

dependencies:
  package_file: "package.json"
  lock_file: "package-lock.json"
  install_command: "npm ci"

ai_prompts:
  language_context: |
    This project uses Express.js with async/await.
    All endpoints follow REST conventions.
    Error handling uses custom middleware.
  custom_instructions:
    - "Follow Airbnb JavaScript Style Guide"
    - "Write JSDoc comments for all functions"
    - "Use async/await instead of callbacks"
    - "Include OpenAPI documentation for endpoints"
```

---

## Best Practices

### Configuration Management

1. **Version Control**: Always commit `.workflow-config.yaml` to version control
2. **Documentation**: Document custom configuration choices in project README
3. **Validation**: Run `--show-tech-stack` after configuration changes
4. **Minimal Config**: Start with minimal config and add fields as needed

### Path Management

1. **Use Relative Paths**: In `.workflow-config.yaml`, use relative paths when possible
2. **Absolute Paths**: In `paths.yaml`, always use absolute paths
3. **Variable Interpolation**: Use `${variable.path}` syntax in `paths.yaml`

### Custom AI Prompts

1. **Keep It Concise**: Limit `language_context` to 2000 characters
2. **Be Specific**: Provide concrete examples in custom instructions
3. **Project-Specific**: Include project-specific conventions and patterns

---

## Troubleshooting

### Configuration Not Detected

**Problem**: Workflow doesn't detect `.workflow-config.yaml`  
**Solution**:
```bash
# Ensure file is in project root
ls -la .workflow-config.yaml

# Check file permissions
chmod 644 .workflow-config.yaml

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.workflow-config.yaml'))"
```

### Invalid Configuration

**Problem**: Validation errors when running workflow  
**Solution**:
```bash
# Check configuration
./execute_tests_docs_workflow.sh --show-tech-stack

# Re-run configuration wizard
./execute_tests_docs_workflow.sh --init-config
```

### Missing Required Fields

**Problem**: "Required field missing" error  
**Solution**:
```yaml
# Ensure primary_language is set
tech_stack:
  primary_language: "bash"  # REQUIRED
```

---

## Migration Guide

### From No Configuration

If your project has no `.workflow-config.yaml`:

1. **Option 1**: Let workflow auto-detect (works for simple projects)
2. **Option 2**: Run wizard: `--init-config`
3. **Option 3**: Create minimal config manually

### From Old Configuration Format

If you have an old configuration format, migrate to new format:

```yaml
# OLD FORMAT (deprecated)
language: bash
test_command: ./tests/run.sh

# NEW FORMAT (current)
tech_stack:
  primary_language: bash
  test_command: ./tests/run.sh
```

---

## Reference Links

- **Configuration Wizard Guide**: `docs/INIT_CONFIG_WIZARD.md`
- **Tech Stack Framework**: `docs/TECH_STACK_ADAPTIVE_FRAMEWORK.md`
- **Project Kind Framework**: `docs/PROJECT_KIND_FRAMEWORK.md`
- **Quick Start Guide**: `docs/QUICK_START_GUIDE.md`

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Status**: ✅ Complete and Validated
