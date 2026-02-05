# Quick Start Guide - AI Workflow Automation

**Version**: 1.0.0  
**Purpose**: Get started quickly with project-specific examples  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Basic Usage](#basic-usage)
- [Project-Specific Quick Starts](#project-specific-quick-starts)
  - [Shell Script Automation](#shell-script-automation)
  - [Node.js API](#nodejs-api)
  - [Node.js CLI Tool](#nodejs-cli-tool)
  - [React SPA](#react-spa)
  - [Static Website](#static-website)
  - [Python Application](#python-application)
  - [Generic Project](#generic-project)
- [Configuration](#configuration)
- [Common Options](#common-options)
- [Next Steps](#next-steps)
- [Troubleshooting](#troubleshooting)

---

## Overview

The AI Workflow Automation system provides an intelligent 15-step pipeline for validating and enhancing documentation, code, and tests. This guide helps you get started quickly based on your project type.

### What It Does

- ✅ **Validates** documentation consistency
- ✅ **Analyzes** code quality and architecture
- ✅ **Reviews** test coverage
- ✅ **Generates** test cases with AI
- ✅ **Executes** tests automatically
- ✅ **Optimizes** performance with smart execution
- ✅ **Tracks** metrics and performance

### Key Features

- **Smart Execution**: Skip unnecessary steps (40-85% faster)
- **Parallel Execution**: Run independent steps simultaneously (33% faster)
- **AI Caching**: 60-80% token usage reduction
- **Checkpoint Resume**: Continue from last completed step
- **Project-Aware**: Adapts to your tech stack

---

## Prerequisites

### Required

- **Bash**: 4.0+ (check: `bash --version`)
- **Git**: Any version (check: `git --version`)
- **GitHub Copilot CLI**: For AI features (check: `gh copilot --version`)

### Project-Specific

| Project Type | Additional Requirements |
|--------------|------------------------|
| Node.js | Node.js 16+, npm/yarn |
| Python | Python 3.8+, pip |
| React | Node.js 16+, npm/yarn |
| Shell Scripts | ShellCheck (optional) |

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR-ORG/ai_workflow.git

# Or if already installed, note the path
export WORKFLOW_PATH="/path/to/ai_workflow"
```

---

## Basic Usage

### Simple Run (Current Directory)

```bash
# Navigate to your project
cd /path/to/your/project

# Run workflow (uses current directory by default)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

### Target a Different Directory

```bash
# Run on a specific project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/your/project
```

### Optimized Run (Recommended)

```bash
# Smart + Parallel execution for best performance
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```

---

## Project-Specific Quick Starts

### Shell Script Automation

**Project Kind**: `shell_script_automation`

#### Example Project Structure

```
my-shell-project/
├── README.md
├── src/
│   ├── main.sh
│   └── lib/
│       ├── utils.sh
│       └── helpers.sh
├── tests/
│   ├── test_main.sh
│   └── test_utils.sh
└── docs/
    └── USAGE.md
```

#### First-Time Setup

```bash
cd my-shell-project

# Initialize configuration
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config

# Select: shell_script_automation
# Primary language: bash
# Test framework: BATS or bash_unit
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My Shell Project"
  kind: shell_script_automation
  description: "Shell script automation tools"

tech_stack:
  primary_language: bash
  
testing:
  framework: bash_unit
  test_command: "bash tests/run_tests.sh"
  test_directory: tests
  test_pattern: "test_*.sh"

quality:
  linter: shellcheck
  linter_command: "shellcheck -x -S warning"
```

#### Quick Run Examples

```bash
# Basic run
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Documentation update only
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,12

# Full quality check
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel
```

#### Expected Results

- ✅ Documentation validated and updated
- ✅ Script references verified
- ✅ ShellCheck quality checks (if installed)
- ✅ Test execution with BATS
- ✅ Directory structure validated

---

### Node.js API

**Project Kind**: `nodejs_api`

#### Example Project Structure

```
my-api/
├── package.json
├── package-lock.json
├── README.md
├── src/
│   ├── index.js
│   ├── routes/
│   ├── controllers/
│   └── models/
├── tests/
│   ├── unit/
│   └── integration/
└── docs/
    └── API.md
```

#### First-Time Setup

```bash
cd my-api

# Initialize configuration
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config

# Select: nodejs_api
# Primary language: javascript
# Test framework: jest
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My API"
  kind: nodejs_api
  description: "RESTful API built with Node.js"

tech_stack:
  primary_language: javascript
  runtime: node
  runtime_version: "20.x"
  framework: express
  
testing:
  framework: jest
  test_command: "npm test"
  coverage_command: "npm run test:coverage"
  test_directory: tests
  test_pattern: "**/*.test.js"
  coverage_threshold: 80

quality:
  linter: eslint
  linter_command: "npm run lint"
  formatter: prettier
  formatter_command: "npm run format"

dependencies:
  package_manager: npm
  lockfile: package-lock.json
```

#### Quick Run Examples

```bash
# First run (includes dependency check)
npm install  # Install dependencies first
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Optimized run after initial setup
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Documentation + tests only
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,5,6,7

# Skip UX analysis (for API-only projects)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution  # Automatically skips Step 14 for APIs
```

#### Expected Results

- ✅ package.json dependencies validated
- ✅ API documentation generated/updated
- ✅ Jest tests executed with coverage
- ✅ ESLint code quality checks
- ✅ Test cases generated for new endpoints
- ⏩ UX analysis skipped (no UI)

---

### Node.js CLI Tool

**Project Kind**: `nodejs_cli`

#### Example Project Structure

```
my-cli/
├── package.json
├── bin/
│   └── my-cli.js
├── src/
│   ├── commands/
│   ├── lib/
│   └── utils/
├── tests/
│   └── commands/
└── README.md
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My CLI Tool"
  kind: nodejs_cli
  description: "Command-line interface tool"

tech_stack:
  primary_language: javascript
  runtime: node
  
testing:
  framework: jest
  test_command: "npm test"
  test_directory: tests
  test_pattern: "**/*.test.js"

quality:
  linter: eslint
  linter_command: "npm run lint"
```

#### Quick Run

```bash
cd my-cli

# Full workflow with optimizations
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```

#### Expected Results

- ✅ CLI documentation validated
- ✅ Command tests executed
- ✅ Help text consistency checked
- ⏩ UX analysis skipped (CLI tool)

---

### React SPA

**Project Kind**: `react_spa`

#### Example Project Structure

```
my-react-app/
├── package.json
├── public/
│   └── index.html
├── src/
│   ├── App.jsx
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── styles/
├── tests/
│   └── components/
└── README.md
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My React App"
  kind: react_spa
  description: "React single-page application"

tech_stack:
  primary_language: javascript
  runtime: node
  framework: react
  framework_version: "18.x"
  ui_library: react
  
testing:
  framework: jest
  test_command: "npm test"
  coverage_command: "npm run test:coverage"
  test_directory: src
  test_pattern: "**/*.test.{js,jsx}"
  coverage_threshold: 70

quality:
  linter: eslint
  linter_command: "npm run lint"
  formatter: prettier
  formatter_command: "npm run format"

build:
  build_command: "npm run build"
  output_directory: build

ux:
  ui_framework: react
  has_ui: true
  accessibility_required: true
```

#### Quick Run Examples

```bash
cd my-react-app

# First run with build
npm install
npm run build  # Optional: pre-build
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Optimized run (includes UX analysis)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Documentation + UX analysis
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,14

# After component changes (includes UX checks)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution  # Auto-includes Step 14 for UI changes
```

#### Expected Results

- ✅ Component documentation validated
- ✅ Jest + React Testing Library tests executed
- ✅ ESLint + Prettier checks
- ✅ Component test coverage analyzed
- ✅ **UX/UI analysis performed** (Step 14)
- ✅ **Accessibility checks** (WCAG 2.1)
- ✅ Build successful

---

### Static Website

**Project Kind**: `static_website`

#### Example Project Structure

```
my-website/
├── index.html
├── css/
│   └── styles.css
├── js/
│   └── main.js
├── images/
├── docs/
│   └── CONTENT.md
└── README.md
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My Website"
  kind: static_website
  description: "Static HTML/CSS/JS website"

tech_stack:
  primary_language: html
  
testing:
  framework: none
  test_command: ""
  test_directory: ""

quality:
  linter: htmlhint
  linter_command: "htmlhint *.html"

ux:
  ui_framework: html
  has_ui: true
  accessibility_required: true
```

#### Quick Run Examples

```bash
cd my-website

# Basic run (includes UX analysis)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Documentation + UX only
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,12,14

# Smart execution (skips test steps automatically)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel
```

#### Expected Results

- ✅ Content documentation validated
- ✅ HTML structure checked
- ⏩ Test steps skipped (no tests)
- ✅ **UX/UI analysis performed** (Step 14)
- ✅ **Accessibility checks** (HTML semantic analysis)
- ✅ Markdown linting

---

### Python Application

**Project Kind**: `python_app`

#### Example Project Structure

```
my-python-app/
├── requirements.txt
├── setup.py
├── README.md
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── main.py
│       └── lib/
├── tests/
│   ├── test_main.py
│   └── test_lib.py
└── docs/
    └── USAGE.md
```

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My Python App"
  kind: python_app
  description: "Python application"

tech_stack:
  primary_language: python
  runtime_version: "3.11"
  
testing:
  framework: pytest
  test_command: "pytest"
  coverage_command: "pytest --cov=src"
  test_directory: tests
  test_pattern: "test_*.py"
  coverage_threshold: 80

quality:
  linter: pylint
  linter_command: "pylint src/"
  formatter: black
  formatter_command: "black --check src/"

dependencies:
  package_manager: pip
  requirements_file: requirements.txt
```

#### Quick Run Examples

```bash
cd my-python-app

# First run (with virtual environment)
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Optimized run
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Code quality focus
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,5,6,7,9
```

#### Expected Results

- ✅ requirements.txt validated
- ✅ Python docstrings checked
- ✅ pytest tests executed with coverage
- ✅ pylint/black quality checks
- ✅ Test cases generated for new functions

---

### Generic Project

**Project Kind**: `generic`

For projects that don't fit specific categories or multi-language projects.

#### Configuration (`.workflow-config.yaml`)

```yaml
version: "1.0"
project:
  name: "My Project"
  kind: generic
  description: "Multi-purpose project"

tech_stack:
  primary_language: generic
  
testing:
  framework: custom
  test_command: "./run_tests.sh"
  test_directory: tests

quality:
  linter: none
```

#### Quick Run

```bash
cd my-project

# Basic run with minimal assumptions
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Smart execution (adapts to detected changes)
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution
```

#### Expected Results

- ✅ Documentation validated
- ✅ Basic consistency checks
- ✅ Custom test command executed (if configured)
- ⏩ Language-specific checks skipped

---

## Configuration

### Interactive Configuration Wizard

The easiest way to configure your project:

```bash
cd your-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

**Wizard Steps**:
1. **Detect project kind** (or select manually)
2. **Detect primary language**
3. **Detect test framework**
4. **Detect quality tools**
5. **Generate `.workflow-config.yaml`**

### Manual Configuration

Create `.workflow-config.yaml` in your project root:

```yaml
version: "1.0"

project:
  name: "Project Name"
  kind: nodejs_api  # or shell_script_automation, react_spa, etc.
  description: "Brief description"

tech_stack:
  primary_language: javascript  # bash, python, javascript, etc.
  runtime: node  # Optional: node, python, etc.
  framework: express  # Optional: framework name

testing:
  framework: jest  # bash_unit, jest, pytest, etc.
  test_command: "npm test"
  test_directory: tests
  test_pattern: "**/*.test.js"

quality:
  linter: eslint  # shellcheck, eslint, pylint, etc.
  linter_command: "npm run lint"
```

### View Detected Configuration

```bash
# Show detected tech stack without running workflow
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
```

---

## Common Options

### Essential Options

```bash
# Smart execution (skip unnecessary steps based on changes)
--smart-execution

# Parallel execution (run independent steps simultaneously)
--parallel

# Auto mode (non-interactive, use defaults)
--auto

# Target specific directory
--target /path/to/project

# Initialize configuration wizard
--init-config
```

### Step Selection

```bash
# Run specific steps only
--steps 0,1,5,6,7

# Common step combinations:
--steps 0,1,2,12      # Documentation only
--steps 0,5,6,7       # Testing focus
--steps 0,9,12        # Quality checks
--steps 0,1,14        # Documentation + UX
```

### Optimization Options

```bash
# Disable AI caching (enabled by default)
--no-ai-cache

# Force fresh start (ignore checkpoints)
--no-resume

# Dry run (show what would be executed)
--dry-run

# Show dependency graph
--show-graph
```

### Custom Configuration

```bash
# Use custom config file
--config-file path/to/custom-config.yaml

# Show tech stack
--show-tech-stack
```

---

## Next Steps

### After First Run

1. **Review Output**
   - Check `src/workflow/backlog/workflow_YYYYMMDD_HHMMSS/`
   - Read step reports: `step*_*.md`
   - Review change analysis: `CHANGE_*.md`

2. **Check Metrics**
   - View `src/workflow/metrics/current_run.json`
   - Analyze performance data
   - Identify optimization opportunities

3. **Review AI Summaries**
   - Check `src/workflow/summaries/workflow_YYYYMMDD_HHMMSS/`
   - Read AI-generated insights

4. **Optimize for Your Workflow**
   ```bash
   # Enable optimizations for regular use
   alias workflow='/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel --auto'
   
   # Run from anywhere
   cd /path/to/project && workflow
   ```

### Learn More

- **[Complete Feature Guide](feature-guide.md)** - All v2.4.0 features
- **[Smart Execution Guide](../reference/smart-execution.md)** - Optimization details
- **[Parallel Execution Guide](../reference/parallel-execution.md)** - Parallel execution model
- **[Metrics Guide](../reference/metrics-interpretation.md)** - Performance analysis
- **[Checkpoint Guide](../reference/checkpoint-management.md)** - Resume behavior

### CI/CD Integration

```yaml
# GitHub Actions example
name: Workflow Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Run AI Workflow
        run: |
          git clone https://github.com/YOUR-ORG/ai_workflow.git
          ./ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto
```

---

## Troubleshooting

### Common Issues

#### Issue: "Copilot CLI not found"

**Solution**:
```bash
# Install GitHub CLI
brew install gh  # macOS
# or download from https://cli.github.com/

# Install Copilot extension
gh extension install github/gh-copilot
```

#### Issue: "Project kind not detected"

**Solution**:
```bash
# Run configuration wizard
./execute_tests_docs_workflow.sh --init-config

# Or manually set in .workflow-config.yaml
echo "project:
  kind: nodejs_api" > .workflow-config.yaml
```

#### Issue: "Tests not running"

**Check**:
1. Test command correct in `.workflow-config.yaml`?
2. Test files exist in configured directory?
3. Test framework installed? (`npm install` or `pip install`)

**Solution**:
```bash
# Show detected config
./execute_tests_docs_workflow.sh --show-tech-stack

# Update test command in .workflow-config.yaml
testing:
  test_command: "npm test"  # or "pytest", "bash tests/run.sh", etc.
```

#### Issue: "Workflow very slow"

**Solution**:
```bash
# Enable optimizations
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Check what's taking time
cat src/workflow/metrics/current_run.json | jq '.steps'
```

#### Issue: "Steps being skipped unexpectedly"

**Cause**: Smart execution is detecting changes and skipping irrelevant steps.

**Solution**:
```bash
# Force run all steps
./execute_tests_docs_workflow.sh --no-resume

# Or run specific steps manually
./execute_tests_docs_workflow.sh --steps 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
```

### Getting Help

1. **Check Logs**: `src/workflow/logs/workflow_YYYYMMDD_HHMMSS/`
2. **Review Docs**: See guides in `docs/`
3. **Health Check**: `src/workflow/lib/health_check.sh`
4. **Dry Run**: Use `--dry-run` to preview execution

### Debug Mode

```bash
# Enable verbose output
export WORKFLOW_DEBUG=1
./execute_tests_docs_workflow.sh

# Show dependency graph
./execute_tests_docs_workflow.sh --show-graph
```

---

## Performance Benchmarks

### Typical Execution Times

| Project Type | Baseline | Smart | Parallel | Combined |
|-------------|----------|-------|----------|----------|
| Shell (small) | 15 min | 5 min | 10 min | 3 min |
| Node.js API | 23 min | 14 min | 15 min | 10 min |
| React SPA | 25 min | 15 min | 17 min | 11 min |
| Python App | 20 min | 12 min | 13 min | 9 min |

### Optimization Impact

**Documentation-only changes**:
- Baseline: 23 minutes
- Smart: 3.5 minutes (85% faster)
- Smart + Parallel: 2.3 minutes (90% faster)

**Code changes**:
- Baseline: 23 minutes
- Smart: 14 minutes (40% faster)
- Smart + Parallel: 10 minutes (57% faster)

---

## Summary

### Quick Reference by Project Type

| Project Type | Config | Key Features | Run Command |
|-------------|--------|--------------|-------------|
| **Shell Scripts** | `shell_script_automation` | BATS tests, ShellCheck | `./workflow.sh --smart-execution` |
| **Node.js API** | `nodejs_api` | Jest, ESLint, no UI | `./workflow.sh --smart-execution --parallel` |
| **Node.js CLI** | `nodejs_cli` | Jest, CLI docs, no UI | `./workflow.sh --smart-execution` |
| **React SPA** | `react_spa` | Jest+RTL, **UX analysis** | `./workflow.sh --smart-execution --parallel` |
| **Static Site** | `static_website` | HTML lint, **UX checks** | `./workflow.sh --smart-execution` |
| **Python** | `python_app` | pytest, pylint | `./workflow.sh --smart-execution --parallel` |
| **Generic** | `generic` | Basic checks | `./workflow.sh` |

### Best Practices

1. **Always use** `--smart-execution` for regular development
2. **Add** `--parallel` for larger projects
3. **Configure** `.workflow-config.yaml` for your tech stack
4. **Review** metrics after each run for insights
5. **Enable** AI caching (default) for token savings
6. **Use** `--auto` for CI/CD pipelines

---

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

For complete documentation, see:
- **Main README**: [README.md](../../README.md)
- **Project Reference**: [docs/PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md) - Authoritative source for features and modules
- **Performance Benchmarks**: [docs/reference/performance-benchmarks.md](../reference/performance-benchmarks.md) - Detailed methodology and raw data
- **Architecture Guide**: [docs/developer-guide/architecture.md](../developer-guide/architecture.md) - System design and patterns
- **Troubleshooting**: [docs/user-guide/troubleshooting.md](troubleshooting.md)
- **Feature Guide**: [docs/user-guide/feature-guide.md](feature-guide.md)
- **FAQ**: [docs/user-guide/faq.md](faq.md)
