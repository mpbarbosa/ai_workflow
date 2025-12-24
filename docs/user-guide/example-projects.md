# Example Projects Guide

**Version**: v2.4.0  
**Last Updated**: 2025-12-23

## Overview

This guide demonstrates how to use the AI Workflow Automation system with example projects. While the repository contains a basic usage example, this document provides comprehensive guidance for testing the workflow across different project types.

## Included Examples

### Basic Feature Demo

**Location**: `examples/using_new_features.sh`

Demonstrates v2.3.1 feature improvements:
- Edit operations with fuzzy matching
- Documentation template validation
- Phase-level timing

**Usage**:
```bash
cd /home/mpb/Documents/GitHub/ai_workflow
./examples/using_new_features.sh
```

## Testing on Real Projects

### Self-Testing (Recommended First Step)

The best way to understand the workflow is to run it on itself:

```bash
cd /home/mpb/Documents/GitHub/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel
```

**What this demonstrates**:
- Shell script project (project_kind: shell_automation)
- Documentation-heavy repository
- Complex modular architecture
- All 15 workflow steps in action

### Node.js Project Example

For testing with Node.js projects:

```bash
# Clone a sample Node.js project
git clone https://github.com/example/nodejs-api /tmp/test-nodejs-api
cd /tmp/test-nodejs-api

# Run workflow from remote location
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --target /tmp/test-nodejs-api \
  --smart-execution \
  --parallel
```

**Expected behavior**:
- Auto-detects Node.js project
- Runs Jest/Mocha tests (Step 7)
- Validates package.json (Step 8)
- Checks API documentation (Step 1)

### Python Project Example

For testing with Python projects:

```bash
# Clone a sample Python project
git clone https://github.com/example/python-api /tmp/test-python-api
cd /tmp/test-python-api

# Run workflow
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --target /tmp/test-python-api \
  --init-config  # Configure pytest settings
```

**Expected behavior**:
- Auto-detects Python project
- Runs pytest (Step 7)
- Validates requirements.txt (Step 8)
- Checks docstrings (Step 1)

### React SPA Example

For testing with React single-page applications:

```bash
# Clone a sample React project
git clone https://github.com/example/react-spa /tmp/test-react-spa
cd /tmp/test-react-spa

# Run workflow with UX analysis
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --target /tmp/test-react-spa \
  --smart-execution \
  --parallel
```

**Expected behavior**:
- Auto-detects React project
- Runs Jest + React Testing Library (Step 7)
- **UX/Accessibility analysis (Step 14)** ✨ NEW in v2.4.0
- Component documentation validation (Step 1)

## Creating Your Own Test Projects

### Minimal Test Project Structure

Create a minimal project to test specific features:

```bash
mkdir -p /tmp/test-minimal/{src,docs,tests}
cd /tmp/test-minimal

# Initialize git
git init

# Create minimal files
cat > README.md << 'EOF'
# Test Project
Simple test project for workflow validation.
EOF

cat > src/main.sh << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF

cat > tests/test_main.sh << 'EOF'
#!/bin/bash
# Test main.sh
source src/main.sh
EOF

# Create workflow config
cat > .workflow-config.yaml << 'EOF'
version: "2.4.0"
project:
  kind: shell_automation
  name: test-minimal
tech_stack:
  primary_language: bash
  test_command: "./tests/test_main.sh"
EOF

# Commit initial state
git add -A
git commit -m "Initial commit"

# Run workflow
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --target /tmp/test-minimal \
  --smart-execution
```

## Example Project Types

### 1. Shell Script Automation

**Characteristics**:
- Primary language: Bash
- Test framework: BATS or custom
- Heavy documentation
- Module-based architecture

**Example configuration** (`.workflow-config.yaml`):
```yaml
version: "2.4.0"
project:
  kind: shell_automation
  name: my-shell-project
tech_stack:
  primary_language: bash
  test_command: "bats tests/"
  test_framework: bats
workflow:
  steps:
    enabled: [0,1,2,3,4,5,6,7,8,9,10,11,12,13]
    skip: [14]  # No UI
```

### 2. Node.js API

**Characteristics**:
- Primary language: JavaScript/TypeScript
- Test framework: Jest/Mocha
- API documentation (OpenAPI/Swagger)
- Dependency management (package.json)

**Example configuration**:
```yaml
version: "2.4.0"
project:
  kind: nodejs_api
  name: my-api
tech_stack:
  primary_language: javascript
  test_command: "npm test"
  test_framework: jest
workflow:
  steps:
    enabled: [0,1,2,3,4,5,6,7,8,9,10,11,12,13]
    skip: [14]  # No UI
```

### 3. React SPA

**Characteristics**:
- Primary language: JavaScript/TypeScript + JSX
- Test framework: Jest + React Testing Library
- UI components
- Accessibility requirements

**Example configuration**:
```yaml
version: "2.4.0"
project:
  kind: react_spa
  name: my-spa
tech_stack:
  primary_language: javascript
  test_command: "npm test"
  test_framework: jest
workflow:
  steps:
    enabled: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]  # All steps including UX
```

### 4. Python API

**Characteristics**:
- Primary language: Python
- Test framework: pytest
- API documentation
- Dependency management (requirements.txt)

**Example configuration**:
```yaml
version: "2.4.0"
project:
  kind: python_api
  name: my-python-api
tech_stack:
  primary_language: python
  test_command: "pytest"
  test_framework: pytest
workflow:
  steps:
    enabled: [0,1,2,3,4,5,6,7,8,9,10,11,12,13]
    skip: [14]  # No UI
```

### 5. Static Website

**Characteristics**:
- Primary language: HTML/CSS/JavaScript
- No backend code
- UI/UX focus
- Accessibility critical

**Example configuration**:
```yaml
version: "2.4.0"
project:
  kind: static_website
  name: my-website
tech_stack:
  primary_language: html
  test_command: ""  # No tests
workflow:
  steps:
    enabled: [0,1,2,12,14]  # Docs, markdown, UX only
    skip: [3,4,5,6,7,8,9,10,11,13]
```

## Testing Specific Features

### Testing Smart Execution

```bash
cd /path/to/project

# Make documentation-only changes
echo "## New Section" >> README.md
git add README.md
git commit -m "docs: update README"

# Run with smart execution
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution

# Expected: Only steps 0,1,2,12 execute (85% faster)
```

### Testing Parallel Execution

```bash
cd /path/to/project

# Run with parallel execution
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --parallel \
  --show-graph  # Shows parallel groups

# Expected: Steps in Group 1 run simultaneously
```

### Testing AI Caching

```bash
cd /path/to/project

# First run (cold cache)
time /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Second run (warm cache)
time /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Expected: 60-80% faster AI calls on second run
```

### Testing Checkpoint Resume

```bash
cd /path/to/project

# Start workflow
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Interrupt with Ctrl+C after Step 5

# Resume automatically
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Expected: Continues from Step 6

# Or force fresh start
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --no-resume
```

### Testing UX Analysis (v2.4.0)

```bash
cd /path/to/react-project

# Run with UX analysis
/home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 14  # Run only UX analysis

# Expected: 
# - Detects React components
# - Analyzes accessibility
# - Generates UX report in backlog/
```

## Performance Benchmarking

### Baseline vs Optimized

```bash
cd /path/to/project

# Baseline (no optimizations)
time /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Optimized (all features)
time /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Compare metrics
cat src/workflow/metrics/current_run.json
```

## Troubleshooting

### Workflow Fails on Example Project

1. Check prerequisites:
   ```bash
   /home/mpb/Documents/GitHub/ai_workflow/src/workflow/lib/health_check.sh
   ```

2. Verify project structure:
   ```bash
   tree -L 2 /path/to/project
   ```

3. Run in dry-run mode:
   ```bash
   /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
     --target /path/to/project \
     --dry-run
   ```

### AI Integration Issues

1. Verify Copilot CLI:
   ```bash
   gh copilot --version
   ```

2. Test AI manually:
   ```bash
   source /home/mpb/Documents/GitHub/ai_workflow/src/workflow/lib/ai_helpers.sh
   check_copilot_available
   ```

3. Disable AI caching if needed:
   ```bash
   /home/mpb/Documents/GitHub/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
     --no-ai-cache
   ```

## Community Example Projects

Want to contribute example projects? See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

**Suggested examples**:
- [ ] Node.js Express API with OpenAPI docs
- [ ] Python Flask API with Sphinx docs
- [ ] React SPA with Storybook
- [ ] Vue.js SPA with component docs
- [ ] Static site with 11ty
- [ ] Documentation site with VitePress

## Related Documentation

- [Quick Start Guide](../../README.md)
- [Project Kind Framework](../design/project-kind-framework.md)
- [Tech Stack Configuration](../archive/TECH_STACK_PHASE3_COMPLETION.md)
- [Target Project Option](../reference/target-project-feature.md)
- [Performance Optimization](../archive/PHASE2_COMPLETION.md)

## Support

For issues with example projects:
1. Check [Troubleshooting Guide](troubleshooting.md)
2. Review execution logs in `src/workflow/logs/`
3. Consult [FAQ](faq.md)
4. Open an issue on GitHub

---

**Last Updated**: 2025-12-23  
**Version**: v2.4.0
