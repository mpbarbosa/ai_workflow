# Complete Configuration Reference

**Version**: v4.0.0  
**Last Updated**: 2026-02-08

## Overview

This document provides comprehensive reference for all configuration files and options in the AI Workflow Automation system.

## Table of Contents

- [Project Configuration](#project-configuration)
- [Workflow Steps Configuration](#workflow-steps-configuration)
- [AI Configuration](#ai-configuration)
- [Project Kinds Configuration](#project-kinds-configuration)
- [Environment Variables](#environment-variables)
- [CLI Options](#cli-options)

---

## Project Configuration

### File: `.workflow-config.yaml`

Location: Project root directory

### Full Schema

```yaml
# Project identification
project:
  name: string                    # Project display name
  type: string                    # Project type identifier
  description: string             # Brief project description
  kind: string                    # Project kind (see Project Kinds)
  version: string                 # Current version

# Technology stack
tech_stack:
  primary_language: string        # Main programming language
  build_system: string            # Build tool (npm, maven, make, etc.)
  test_framework: string          # Testing framework
  test_command: string            # Command to run tests
  lint_command: string            # Command to run linter

# Project structure
structure:
  source_dirs: array             # Source code directories
  test_dirs: array               # Test directories
  docs_dirs: array               # Documentation directories

# Audio notifications (optional, NEW v3.1.0)
audio:
  enabled: boolean               # Enable/disable audio notifications
  continue_prompt_sound: path    # Sound file for continue prompts
  completion_sound: path         # Sound file for workflow completion

# Optimization settings (optional)
optimization:
  smart_execution: boolean       # Enable smart execution
  parallel_execution: boolean    # Enable parallel execution
  ml_optimize: boolean           # Enable ML optimization
  multi_stage: boolean           # Enable multi-stage pipeline

# Custom step configuration (optional)
steps:
  skip: array                    # Steps to skip by default
  required: array                # Steps that cannot be skipped

# Git integration (optional)
git:
  auto_commit: boolean           # Enable auto-commit
  commit_prefix: string          # Commit message prefix
  
# AI settings (optional)
ai:
  cache_enabled: boolean         # Enable AI response caching
  cache_ttl_hours: number        # Cache time-to-live (default: 24)
  max_retries: number            # Max AI call retries (default: 3)
```

### Example Configuration

```yaml
# AI Workflow Automation Configuration
project:
  name: "My Application"
  type: "web-application"
  description: "React-based web application"
  kind: "react_spa"
  version: "1.2.3"

tech_stack:
  primary_language: "javascript"
  build_system: "npm"
  test_framework: "jest"
  test_command: "npm test"
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
    - documentation

audio:
  enabled: true
  continue_prompt_sound: /path/to/beep.mp3
  completion_sound: /path/to/success.mp3

optimization:
  smart_execution: true
  parallel_execution: true
  ml_optimize: true
  multi_stage: true

git:
  auto_commit: true
  commit_prefix: "auto:"

ai:
  cache_enabled: true
  cache_ttl_hours: 24
  max_retries: 3
```

### Field Descriptions

#### project.kind

Determines project-specific AI prompts and quality standards. Valid values:

- `shell_automation` - Shell script automation/frameworks
- `nodejs_api` - Node.js REST API
- `nodejs_cli` - Node.js CLI tool
- `nodejs_library` - Node.js library
- `static_website` - Static HTML/CSS/JS site
- `client_spa` - Single Page Application (generic)
- `react_spa` - React application
- `vue_spa` - Vue.js application
- `python_api` - Python REST API
- `python_cli` - Python CLI tool
- `python_library` - Python library
- `documentation` - Documentation-only project

#### tech_stack.primary_language

Influences documentation standards and AI prompts. Supported languages:

- `bash` / `shell`
- `javascript` / `typescript`
- `python`
- `java`
- `go`
- `ruby`
- `php`
- `rust`

#### audio.enabled (NEW v3.1.0)

When enabled, plays notification sounds for:
- Continue prompts (waiting for user input)
- Workflow completion (success or failure)

Supported formats: MP3, WAV, OGG

---

## Workflow Steps Configuration

### File: `.workflow_core/config/workflow_steps.yaml`

Defines step metadata, dependencies, and execution order.

### Schema

```yaml
steps:
  - id: string                    # Unique step identifier
    name: string                  # Human-readable name
    file: string                  # Step script filename
    category: string              # Step category
    dependencies: array           # Required prerequisite steps
    stage: number                 # Pipeline stage (1-3)
    can_run_parallel: boolean     # Can run in parallel with others
    required: boolean             # Cannot be skipped
    description: string           # Brief description
```

### Example

```yaml
steps:
  - id: documentation_updates
    name: "Documentation Updates"
    file: documentation_updates.sh
    category: validation
    dependencies: []
    stage: 1
    can_run_parallel: false
    required: true
    description: "Analyze and update documentation"

  - id: consistency_check
    name: "Documentation Consistency"
    file: consistency_check.sh
    category: validation
    dependencies:
      - documentation_updates
    stage: 1
    can_run_parallel: true
    required: false
    description: "Check documentation consistency"
```

### Step Categories

- `preprocessing` - Pre-execution tasks (step_0a, step_0b)
- `validation` - Documentation and code validation (steps 1-4)
- `testing` - Test execution and validation (steps 5-8)
- `quality` - Code quality and UX analysis (steps 9-11)
- `finalization` - Git operations and versioning (steps 12-15)
- `postprocessing` - Post-execution cleanup (step_16)

### Pipeline Stages

- **Stage 1 (Core)**: Essential validation and planning
  - Success rate: ~90% of issues caught
  - Average duration: 3-5 minutes
  
- **Stage 2 (Extended)**: Comprehensive testing
  - Success rate: ~8% additional issues
  - Average duration: 8-12 minutes
  
- **Stage 3 (Finalization)**: Cleanup and artifacts
  - Failure rate: <2%
  - Average duration: 1-2 minutes

---

## AI Configuration

### File: `.workflow_core/config/ai_helpers.yaml`

Defines AI personas, prompts, and templates.

### Schema

```yaml
personas:
  persona_name:
    role: string                  # AI role description
    expertise: array              # Areas of expertise
    instructions: string          # Detailed instructions
    constraints: array            # Operational constraints
    output_format: string         # Expected output format

templates:
  template_name:
    prompt: string                # Base prompt template
    context: string               # Context guidelines
    examples: array               # Example outputs
    
language_specific:
  language_name:
    documentation: string         # Doc conventions
    testing: string               # Testing practices
    quality: string               # Quality standards
```

### Example Persona

```yaml
personas:
  documentation_specialist:
    role: >
      Expert technical writer and documentation specialist with deep
      knowledge of software documentation best practices.
    
    expertise:
      - Technical writing and documentation
      - API documentation
      - User guides and tutorials
      - Documentation structure and organization
    
    instructions: |
      You are reviewing and improving technical documentation.
      
      Guidelines:
      - Ensure clarity and conciseness
      - Follow language-specific conventions
      - Include practical examples
      - Maintain consistent formatting
      - Cross-reference related documentation
    
    constraints:
      - Must follow project documentation standards
      - Should preserve existing structure when possible
      - Must include code examples for technical content
    
    output_format: "markdown"
```

### Language-Specific Configuration

```yaml
language_specific:
  javascript:
    documentation: |
      - Use JSDoc format for inline documentation
      - Follow MDN documentation style
      - Include TypeScript type annotations when applicable
      
    testing: |
      - Jest or Mocha/Chai patterns
      - Test descriptions in "should" format
      - AAA pattern (Arrange, Act, Assert)
      
    quality: |
      - ESLint standard rules
      - Airbnb style guide compliance
      - Proper error handling with try/catch
```

### Available Personas

1. **documentation_specialist** - Technical writing and documentation
2. **code_reviewer** - Code quality and best practices
3. **test_engineer** - Test strategy and implementation
4. **ux_designer** - UI/UX and accessibility
5. **technical_writer** - Bootstrap documentation creation
6. **security_analyst** - Security review
7. **performance_engineer** - Performance optimization
8. **integration_specialist** - API and integration
9. **quality_assurance** - QA and validation
10. **devops_engineer** - CI/CD and deployment
11. **data_engineer** - Data processing and pipelines
12. **system_architect** - System design
13. **consistency_checker** - Documentation consistency
14. **version_manager** - Version and release management
15. **git_specialist** - Git operations and workflow

---

## Project Kinds Configuration

### File: `.workflow_core/config/project_kinds.yaml`

Defines project types with their characteristics.

### Schema

```yaml
project_kind_name:
  name: string                    # Display name
  description: string             # Description
  patterns: array                 # Detection patterns
  test_frameworks: array          # Common test frameworks
  quality_standards: array        # Quality requirements
  documentation_requirements: array  # Doc requirements
  common_files: array             # Expected files
```

### Example

```yaml
nodejs_api:
  name: "Node.js REST API"
  description: "Node.js backend API with Express or similar"
  
  patterns:
    - "package.json"
    - "src/routes/*.js"
    - "src/controllers/*.js"
  
  test_frameworks:
    - "jest"
    - "mocha"
    - "supertest"
  
  quality_standards:
    - "ESLint compliance"
    - "API versioning"
    - "Error handling middleware"
    - "Input validation"
    - "Security headers"
  
  documentation_requirements:
    - "API endpoint documentation"
    - "Authentication guide"
    - "Environment variables reference"
    - "Deployment guide"
  
  common_files:
    - "README.md"
    - "package.json"
    - ".env.example"
    - "docs/API.md"
```

### Supported Project Kinds

- **shell_automation** - Shell script frameworks
- **nodejs_api** - Node.js REST APIs
- **nodejs_cli** - Node.js command-line tools
- **nodejs_library** - Node.js libraries
- **static_website** - Static HTML/CSS/JS sites
- **client_spa** - Generic single-page applications
- **react_spa** - React applications
- **vue_spa** - Vue.js applications
- **python_api** - Python REST APIs (Flask, FastAPI)
- **python_cli** - Python CLI tools
- **python_library** - Python libraries
- **documentation** - Documentation-only projects

---

## Environment Variables

### Workflow Control

```bash
# Enable/disable features
export SMART_EXECUTION=true
export PARALLEL_EXECUTION=true
export ML_OPTIMIZE=true
export MULTI_STAGE=true

# Workflow behavior
export AUTO_MODE=true
export DRY_RUN=false
export NO_RESUME=false

# AI settings
export AI_CACHE_ENABLED=true
export AI_CACHE_TTL=24
export COPILOT_MODEL="gpt-4"

# Audio notifications (v3.1.0+)
export AUDIO_ENABLED=true

# Debugging
export DEBUG=false
export VERBOSE=false
export LOG_LEVEL="info"  # debug, info, warning, error
```

### Paths

```bash
# Override default paths
export WORKFLOW_DIR="/custom/path/to/workflow"
export TARGET_PROJECT="/path/to/target/project"
export CONFIG_FILE=".custom-config.yaml"

# Output locations
export BACKLOG_DIR="./custom-backlog"
export LOGS_DIR="./custom-logs"
export METRICS_DIR="./custom-metrics"
```

### Git Integration

```bash
# Auto-commit settings
export AUTO_COMMIT=true
export COMMIT_PREFIX="workflow:"
export COMMIT_SIGN=true

# Branch management
export CREATE_FEATURE_BRANCH=false
export FEATURE_BRANCH_PREFIX="workflow/"
```

---

## CLI Options

### Execution Control

```bash
# Basic execution
./execute_tests_docs_workflow.sh

# Optimization flags
--smart-execution           # Enable change-based optimization
--parallel                  # Enable parallel execution
--ml-optimize              # Enable ML-based optimization
--multi-stage              # Enable multi-stage pipeline

# Auto mode (non-interactive)
--auto                     # Skip all prompts

# Dry run (preview only)
--dry-run                  # Show what would be executed

# Resume control
--no-resume                # Force fresh start (ignore checkpoints)
```

### Step Selection

```bash
# Select specific steps (v4.0.0+)
--steps documentation_updates,test_execution

# Mixed syntax (names and indices)
--steps 0,documentation_updates,12

# Legacy numeric syntax
--steps 0,1,5,12
```

### Project Targeting

```bash
# Target specific project
--target /path/to/project

# Run on current directory (default)
./execute_tests_docs_workflow.sh
```

### Configuration

```bash
# Initialize configuration
--init-config              # Run configuration wizard

# Show configuration
--show-tech-stack          # Display detected tech stack
--show-pipeline            # Display pipeline configuration
--show-ml-status           # Display ML system status

# Custom config file
--config-file .custom-config.yaml
```

### Git Integration

```bash
# Auto-commit workflow
--auto-commit              # Automatically commit artifacts

# Pre-commit hooks
--install-hooks            # Install pre-commit hooks
--test-hooks              # Test hooks without committing
```

### Documentation Generation

```bash
# Generate documentation (v2.9.0+)
--generate-docs            # Generate workflow reports
--update-changelog         # Update CHANGELOG.md
--generate-api-docs        # Generate API documentation
```

### Visualization

```bash
# Display workflow information
--show-graph               # Show dependency graph
--show-metrics             # Show metrics from last run
```

### Audio Notifications (v3.1.0+)

```bash
# Audio control
--audio                    # Enable audio notifications
--no-audio                 # Disable audio notifications
--test-audio               # Test audio configuration
```

### Debugging

```bash
# Debug options
--debug                    # Enable debug logging
--verbose                  # Enable verbose output
--trace                    # Enable bash tracing (set -x)

# Help
--help                     # Show help message
--version                  # Show version information
```

### Combined Usage Examples

```bash
# Optimal production workflow
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto \
  --auto-commit

# Documentation-only workflow
./execute_tests_docs_workflow.sh \
  --steps documentation_updates,consistency_check \
  --smart-execution

# Test-only workflow  
./execute_tests_docs_workflow.sh \
  --steps test_execution,test_validation \
  --parallel

# Full workflow with audio
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --audio \
  --auto

# Dry run to preview
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --dry-run

# Debug mode
./execute_tests_docs_workflow.sh \
  --debug \
  --verbose \
  --steps documentation_updates
```

---

## Configuration Wizard

### Running the Wizard

```bash
./execute_tests_docs_workflow.sh --init-config
```

### Wizard Steps

1. **Project Detection**
   - Scans directory structure
   - Identifies package managers
   - Detects frameworks

2. **Tech Stack Confirmation**
   - Displays detected technologies
   - Prompts for confirmation
   - Allows manual overrides

3. **Test Configuration**
   - Identifies test framework
   - Suggests test command
   - Validates test execution

4. **Documentation Setup**
   - Locates documentation directories
   - Identifies documentation structure

5. **Optimization Preferences**
   - Recommends optimization settings
   - Explains each option

6. **Configuration Generation**
   - Creates `.workflow-config.yaml`
   - Saves to project root
   - Validates configuration

---

## Best Practices

### Configuration Management

1. **Version Control**
   - Commit `.workflow-config.yaml` to git
   - Document configuration changes
   - Use environment variables for secrets

2. **Project-Specific Settings**
   - Create configuration per project
   - Use inheritance for multi-repo projects
   - Override only what's necessary

3. **Optimization Settings**
   - Start with smart execution
   - Add parallel execution after validation
   - Enable ML optimization with sufficient history

### Security

1. **Credentials**
   - Never commit secrets to config files
   - Use environment variables
   - Leverage system credential managers

2. **File Permissions**
   - Keep config files readable only by owner
   - Restrict sound file access if sensitive

3. **Path Validation**
   - Always use absolute paths
   - Validate path existence
   - Check permissions before execution

---

## Troubleshooting

### Configuration Not Found

```bash
# Error: Configuration file not found
# Solution: Run configuration wizard
./execute_tests_docs_workflow.sh --init-config
```

### Invalid Configuration

```bash
# Error: Invalid YAML syntax
# Solution: Validate YAML
yamllint .workflow-config.yaml

# Or use built-in validator
./execute_tests_docs_workflow.sh --validate-config
```

### Step Configuration Issues

```bash
# Error: Step not found
# Solution: Check workflow_steps.yaml
cat .workflow_core/config/workflow_steps.yaml

# Verify step ID exists
grep "id: step_name" .workflow_core/config/workflow_steps.yaml
```

---

## See Also

- [User Guide](../user-guide/usage.md)
- [CLI Options Reference](../reference/cli-options.md)
- [Project Reference](../PROJECT_REFERENCE.md)
- [Configuration Wizard Guide](../reference/init-config-wizard.md)

---

**Maintained by**: AI Workflow Automation Team  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
