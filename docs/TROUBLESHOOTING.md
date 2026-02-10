# Troubleshooting Guide

**Version**: 1.0.0  
**Last Updated**: 2026-02-10

This guide provides solutions to common issues when using AI Workflow Automation.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Execution Problems](#execution-problems)
- [AI Integration Issues](#ai-integration-issues)
- [Performance Issues](#performance-issues)
- [Configuration Problems](#configuration-problems)
- [Git and Version Control](#git-and-version-control)
- [Testing Issues](#testing-issues)
- [Documentation Generation](#documentation-generation)
- [Advanced Diagnostics](#advanced-diagnostics)

---

## Installation Issues

### Prerequisites Not Met

**Symptoms**: 
- Error: "Bash version 4.0+ required"
- Error: "Git not found"
- Error: "Node.js not found"

**Solution**:
```bash
# Check Bash version (need 4.0+)
bash --version

# Check Git installation
git --version

# Check Node.js installation (need 25.2.1+)
node --version

# Run comprehensive health check
./src/workflow/lib/health_check.sh
```

**Fix for macOS** (ships with Bash 3.2):
```bash
# Install Bash 4+ using Homebrew
brew install bash

# Update shell path
which bash  # Should show /usr/local/bin/bash or /opt/homebrew/bin/bash
```

### Submodule Issues

**Symptoms**:
- Error: ".workflow_core/config not found"
- Missing configuration files

**Solution**:
```bash
# Initialize and update submodules
git submodule update --init --recursive

# Verify submodule status
git submodule status

# Force update if needed
git submodule update --init --recursive --force
```

---

## Execution Problems

### Workflow Hangs or Freezes

**Symptoms**:
- Workflow stops responding
- No progress for extended period
- Process appears stuck

**Diagnosis**:
```bash
# Check running processes
ps aux | grep execute_tests_docs_workflow

# Check system resources
top -n 1 | head -20

# Review logs
tail -f src/workflow/logs/workflow_$(date +%Y%m%d)_*/execution.log
```

**Solution**:
```bash
# 1. Cancel with Ctrl+C
# 2. Resume from checkpoint
./src/workflow/execute_tests_docs_workflow.sh

# Or force fresh start (no resume)
./src/workflow/execute_tests_docs_workflow.sh --no-resume
```

### Permission Denied Errors

**Symptoms**:
- Error: "Permission denied" when running scripts
- Cannot write to directories

**Solution**:
```bash
# Make scripts executable
chmod +x src/workflow/execute_tests_docs_workflow.sh
chmod +x src/workflow/lib/*.sh
chmod +x src/workflow/steps/*.sh

# Check directory permissions
ls -la src/workflow/

# Fix ownership if needed (replace USER with your username)
sudo chown -R $USER:$USER /path/to/ai_workflow
```

### Step Execution Failures

**Symptoms**:
- Specific step fails repeatedly
- Error: "Step X failed with exit code 1"

**Diagnosis**:
```bash
# Check step-specific log
cat src/workflow/logs/workflow_*/step_X_*.log

# Review health check report
cat src/workflow/backlog/workflow_*/WORKFLOW_HEALTH_CHECK.md

# Check step status
grep "Step X" src/workflow/logs/workflow_*/execution.log
```

**Solution**:
```bash
# Skip problematic step temporarily
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2,4,5  # Skip step 3

# Run only the failing step
./src/workflow/execute_tests_docs_workflow.sh --steps 3

# Use dry run to preview
./src/workflow/execute_tests_docs_workflow.sh --dry-run
```

---

## AI Integration Issues

### Copilot CLI Not Found

**Symptoms**:
- Error: "GitHub Copilot CLI not found"
- Warning: "Copilot CLI not available, skipping AI analysis"

**Solution**:
```bash
# Install GitHub Copilot CLI
npm install -g @githubnext/github-copilot-cli

# Verify installation
gh copilot --version

# Check authentication
gh auth status
```

### Authentication Failures

**Symptoms**:
- Error: "Copilot CLI is not authenticated"
- Warning: "GitHub Copilot CLI is not authenticated"

**Solution**:
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status

# Test Copilot access
gh copilot explain "echo hello"
```

### AI Response Timeouts

**Symptoms**:
- Warning: "AI batch analysis timed out after Xs"
- Slow AI responses

**Solution**:
```bash
# Increase timeout in configuration
# Edit .workflow-config.yaml:
ai:
  timeout: 300  # Increase from default 180s

# Check network connectivity
ping api.github.com

# Use caching to reduce API calls
./src/workflow/execute_tests_docs_workflow.sh  # Caching enabled by default

# Clear cache if responses seem stale
rm -rf src/workflow/.ai_cache/*
```

### AI Cache Issues

**Symptoms**:
- Using outdated cached responses
- Cache index corruption

**Solution**:
```bash
# Clear AI cache
rm -rf src/workflow/.ai_cache/*

# Disable caching temporarily
./src/workflow/execute_tests_docs_workflow.sh --no-ai-cache

# Validate cache structure
ls -la src/workflow/.ai_cache/
cat src/workflow/.ai_cache/index.json | jq .
```

---

## Performance Issues

### Workflow Takes Too Long

**Symptoms**:
- Execution time > 20 minutes
- Simple changes take as long as complex ones

**Solution**:
```bash
# Enable smart execution (40-85% faster)
./src/workflow/execute_tests_docs_workflow.sh --smart-execution

# Enable parallel execution (33% faster)
./src/workflow/execute_tests_docs_workflow.sh --parallel

# Enable ML optimization (15-30% additional improvement)
./src/workflow/execute_tests_docs_workflow.sh --ml-optimize

# Combined optimization (up to 93% faster)
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage

# Use workflow templates for common scenarios
./templates/workflows/docs-only.sh    # 3-4 minutes
./templates/workflows/test-only.sh    # 8-10 minutes
```

### Memory or CPU Issues

**Symptoms**:
- System becomes slow
- Out of memory errors

**Solution**:
```bash
# Disable parallel execution
./src/workflow/execute_tests_docs_workflow.sh  # No --parallel flag

# Monitor resource usage
watch -n 1 'ps aux | grep execute_tests'

# Limit parallel jobs
# Edit src/workflow/lib/workflow_optimization.sh
# Change MAX_PARALLEL_JOBS value

# Run without ML optimization
./src/workflow/execute_tests_docs_workflow.sh  # No --ml-optimize
```

---

## Configuration Problems

### Configuration Wizard Fails

**Symptoms**:
- Error: "Configuration wizard failed"
- Invalid configuration file generated

**Solution**:
```bash
# Remove invalid configuration
rm .workflow-config.yaml

# Run wizard again
./src/workflow/execute_tests_docs_workflow.sh --init-config

# Manually create minimal config
cat > .workflow-config.yaml << EOF
project:
  name: "my-project"
  kind: "generic"
tech_stack:
  primary_language: "shell"
EOF
```

### Tech Stack Detection Issues

**Symptoms**:
- Wrong technology detected
- Missing dependencies

**Solution**:
```bash
# View detected tech stack
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# Manually specify in .workflow-config.yaml
tech_stack:
  primary_language: "python"
  frameworks:
    - "flask"
  testing:
    framework: "pytest"
    command: "pytest tests/"

# Re-detect tech stack
rm .workflow-config.yaml
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

### Project Kind Mismatch

**Symptoms**:
- Inappropriate steps executed
- Wrong AI prompts used

**Solution**:
```bash
# Check current project kind
grep "project.kind" .workflow-config.yaml

# Set correct project kind
# Edit .workflow-config.yaml:
project:
  kind: "nodejs_api"  # Options: shell_automation, nodejs_api, python_app, etc.

# View available project kinds
cat .workflow_core/config/project_kinds.yaml
```

---

## Git and Version Control

### Uncommitted Changes Warnings

**Symptoms**:
- Warning: "Uncommitted changes detected"
- Workflow refuses to proceed

**Solution**:
```bash
# Commit changes before running
git add .
git commit -m "Your commit message"

# Or stash changes temporarily
git stash
./src/workflow/execute_tests_docs_workflow.sh
git stash pop

# Force execution with uncommitted changes (not recommended)
# Use --auto flag at your own risk
```

### Git Hooks Conflicts

**Symptoms**:
- Pre-commit hook fails
- Commits rejected

**Solution**:
```bash
# Test hooks without committing
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# Temporarily bypass hooks (for debugging only)
git commit --no-verify -m "Debug commit"

# Reinstall hooks
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Remove workflow hooks
rm .git/hooks/pre-commit
```

---

## Testing Issues

### Tests Fail After Workflow

**Symptoms**:
- Tests pass before workflow
- Tests fail after workflow execution

**Diagnosis**:
```bash
# Check what changed
git diff

# Review test execution log
cat src/workflow/logs/workflow_*/step_3_test_execution.log

# Run tests manually
npm test  # or pytest, ./run_tests.sh, etc.
```

**Solution**:
```bash
# Revert changes if needed
git checkout -- path/to/changed/file

# Review and fix test issues
# Check test_results/ directory for detailed reports

# Skip test step temporarily
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2,4,5  # Skip step 3
```

### Test Coverage Reports Missing

**Symptoms**:
- No coverage report generated
- Coverage data incomplete

**Solution**:
```bash
# Check test command configuration
grep "testing.command" .workflow-config.yaml

# Verify coverage tool installed
npm list --depth=0 | grep coverage  # For Node.js
pip list | grep coverage            # For Python

# Run tests with coverage manually
npm test -- --coverage  # Node.js
pytest --cov            # Python
```

---

## Documentation Generation

### Documentation Not Generated

**Symptoms**:
- Expected documentation files missing
- Empty documentation files

**Solution**:
```bash
# Enable auto-documentation
./src/workflow/execute_tests_docs_workflow.sh --generate-docs

# Check documentation analysis
cat src/workflow/backlog/workflow_*/DOCUMENTATION_ANALYSIS.md

# Run Step 0b: Bootstrap Documentation
./src/workflow/execute_tests_docs_workflow.sh --steps bootstrap_docs

# Verify technical_writer persona available
grep "technical_writer" .workflow_core/config/ai_helpers.yaml
```

### Documentation Links Broken

**Symptoms**:
- Links return 404
- Cross-references invalid

**Solution**:
```bash
# Validate documentation links
python3 scripts/check_doc_links.py

# Fix links automatically
python3 scripts/check_doc_links.py --fix

# Validate documentation structure
python3 .workflow_core/scripts/validate_structure.py docs/
```

---

## Advanced Diagnostics

### Enable Debug Logging

```bash
# Set debug mode
export DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh

# Enable verbose output
export VERBOSE=1
./src/workflow/execute_tests_docs_workflow.sh

# Trace execution
bash -x ./src/workflow/execute_tests_docs_workflow.sh 2>&1 | tee debug.log
```

### Capture Execution Metrics

```bash
# View current metrics
cat src/workflow/metrics/current_run.json | jq .

# View historical metrics
cat src/workflow/metrics/history.jsonl | jq .

# Check ML optimization status
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# View pipeline configuration
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline
```

### Cleanup Artifacts

```bash
# Clean old artifacts (30+ days)
./scripts/cleanup_artifacts.sh --all --older-than 30

# Clean logs only
./scripts/cleanup_artifacts.sh --logs --older-than 7

# Dry run to preview
./scripts/cleanup_artifacts.sh --all --dry-run

# Emergency cleanup (keep only last 3 runs)
find src/workflow/backlog -type d -name "workflow_*" | \
  sort -r | tail -n +4 | xargs rm -rf
```

### Reset to Clean State

```bash
# 1. Backup important files
cp -r src/workflow/backlog backlog_backup
cp -r src/workflow/logs logs_backup

# 2. Clean all generated artifacts
rm -rf src/workflow/.ai_cache
rm -rf src/workflow/.checkpoints
rm -rf src/workflow/logs/*
rm -rf src/workflow/backlog/*
rm -rf src/workflow/metrics/*

# 3. Reset configuration
rm .workflow-config.yaml

# 4. Reinitialize
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

---

## Getting Help

If you've tried the solutions above and still have issues:

1. **Check Logs**:
   ```bash
   # Most recent execution log
   ls -lt src/workflow/logs/workflow_* | head -1
   
   # View full execution log
   cat src/workflow/logs/workflow_$(date +%Y%m%d)_*/execution.log
   ```

2. **Review Health Check**:
   ```bash
   cat src/workflow/backlog/workflow_*/WORKFLOW_HEALTH_CHECK.md
   ```

3. **Check Documentation**:
   - [Project Reference](PROJECT_REFERENCE.md) - Complete feature list
   - [Getting Started](getting-started/GETTING_STARTED.md) - Basics
   - [Configuration Reference](CONFIGURATION_REFERENCE.md) - All options

4. **Report Issues**:
   - GitHub Issues: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
   - Include: Version, OS, error messages, logs
   - See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines

5. **Community Support**:
   - Check existing issues for similar problems
   - Review [CHANGELOG.md](../CHANGELOG.md) for version-specific issues
   - See [MAINTAINERS.md](MAINTAINERS.md) for contact information

---

## Quick Diagnostics Checklist

Run through this checklist before reporting issues:

- [ ] Bash version 4.0+ installed: `bash --version`
- [ ] Git installed: `git --version`
- [ ] Node.js installed: `node --version`
- [ ] GitHub Copilot CLI installed: `gh copilot --version`
- [ ] Authenticated with GitHub: `gh auth status`
- [ ] Submodules initialized: `git submodule status`
- [ ] Scripts executable: `ls -l src/workflow/execute_tests_docs_workflow.sh`
- [ ] Health check passes: `./src/workflow/lib/health_check.sh`
- [ ] No uncommitted changes: `git status`
- [ ] Configuration valid: `cat .workflow-config.yaml`
- [ ] Logs reviewed: `cat src/workflow/logs/workflow_*/execution.log`

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
