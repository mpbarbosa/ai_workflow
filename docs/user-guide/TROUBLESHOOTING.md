# Troubleshooting Guide - AI Workflow Automation

**Version**: 4.0.0  
**Last Updated**: 2026-02-08

> 📋 **Quick Help**: Common issues and solutions for AI Workflow Automation

## Table of Contents

1. [Common Issues](#common-issues)
2. [Diagnostic Tools](#diagnostic-tools)
3. [Error Messages](#error-messages)
4. [Performance Issues](#performance-issues)
5. [AI-Related Issues](#ai-related-issues)
6. [Git Issues](#git-issues)
7. [Configuration Issues](#configuration-issues)
8. [Getting Help](#getting-help)

## Common Issues

### Workflow Won't Start

**Symptom**: Workflow fails immediately on startup

**Possible Causes**:
1. Missing prerequisites
2. Invalid configuration
3. Insufficient permissions
4. Corrupted checkpoints

**Solutions**:

```bash
# 1. Check prerequisites
cd /path/to/ai_workflow
./src/workflow/lib/health_check.sh

# 2. Validate configuration
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# 3. Force fresh start (ignore checkpoints)
./src/workflow/execute_tests_docs_workflow.sh --no-resume

# 4. Check permissions
ls -la src/workflow/execute_tests_docs_workflow.sh
# Should show: -rwxr-xr-x

# Fix if needed:
chmod +x src/workflow/execute_tests_docs_workflow.sh
```

### Step Execution Fails

**Symptom**: Specific step fails during execution

**Diagnostic Steps**:

```bash
# 1. Check logs for the failed step
cd src/workflow/logs
ls -lt | head -5  # Find latest log directory
tail -100 workflow_YYYYMMDD_HHMMSS/step_XX_*.log

# 2. Check step output in backlog
cd src/workflow/backlog
ls -lt | head -5  # Find latest execution
cat workflow_YYYYMMDD_HHMMSS/step*_*.md

# 3. Run step in isolation
./src/workflow/execute_tests_docs_workflow.sh --steps XX --dry-run
```

**Common Step Failures**:

**Step 0: Analysis fails**
- **Cause**: Git repository issues
- **Solution**: Ensure you're in a valid git repository
  ```bash
  git status  # Should work without errors
  git log -1  # Should show recent commit
  ```

**Step 2: Documentation validation fails**
- **Cause**: Malformed markdown or missing files
- **Solution**: Check markdown syntax
  ```bash
  # Validate markdown files
  find docs -name "*.md" -exec bash -c 'echo "Checking: $0" && cat "$0" > /dev/null' {} \;
  ```

**Step 5: Test execution fails**
- **Cause**: Test command not configured or tests failing
- **Solution**: Configure test command in `.workflow-config.yaml`
  ```yaml
  tech_stack:
    test_command: "npm test"  # or "pytest", "./run_tests.sh", etc.
  ```

### AI Integration Issues

**Symptom**: AI calls fail or timeout

**Solution 1: Verify Copilot CLI**
```bash
# Check if Copilot CLI is available
which gh
gh copilot --version

# Test AI connection
gh copilot explain "git status"
```

**Solution 2: Check AI Cache**
```bash
# View cache status
ls -lh src/workflow/.ai_cache/
cat src/workflow/.ai_cache/index.json | jq '.stats'

# Clear cache if corrupted
rm -rf src/workflow/.ai_cache/*
```

**Solution 3: Disable AI Caching**
```bash
# Run without caching
./src/workflow/execute_tests_docs_workflow.sh --no-ai-cache
```

### Checkpoint Resume Issues

**Symptom**: Workflow doesn't resume from checkpoint or resumes incorrectly

**Solutions**:

```bash
# 1. Check checkpoint state
ls -la src/workflow/.checkpoints/
cat src/workflow/.checkpoints/last_checkpoint.json

# 2. Clear checkpoints and restart
rm -rf src/workflow/.checkpoints/*
./src/workflow/execute_tests_docs_workflow.sh

# 3. Disable checkpoint resume
./src/workflow/execute_tests_docs_workflow.sh --no-resume
```

### Permission Denied Errors

**Symptom**: "Permission denied" when running workflow

**Solutions**:

```bash
# 1. Make scripts executable
chmod +x src/workflow/execute_tests_docs_workflow.sh
chmod +x src/workflow/steps/*.sh
chmod +x src/workflow/lib/*.sh

# 2. Check directory permissions
ls -ld src/workflow/backlog src/workflow/logs src/workflow/metrics

# 3. Fix directory permissions
chmod 755 src/workflow/{backlog,logs,metrics}

# 4. Check file ownership
ls -la src/workflow/ | head -10
# If owned by different user, fix:
# sudo chown -R $(whoami):$(whoami) src/workflow/
```

## Diagnostic Tools

### Health Check

Comprehensive system health check:

```bash
cd /path/to/ai_workflow
./src/workflow/lib/health_check.sh

# Expected output:
# ✓ Bash version: 4.4.22
# ✓ Git installed
# ✓ Node.js installed
# ✓ jq installed
# ✓ GitHub CLI installed
# ✓ All required directories exist
```

### Show Tech Stack

Display detected technology stack:

```bash
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# Output shows:
# - Primary language
# - Frameworks detected
# - Test frameworks
# - Build tools
# - Package managers
```

### Dry Run Mode

Preview execution without running steps:

```bash
# See what would run
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Preview specific steps
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,2,5 \
  --dry-run
```

### Show Dependency Graph

Visualize step dependencies:

```bash
./src/workflow/execute_tests_docs_workflow.sh --show-graph

# Output shows step execution order and dependencies
```

### ML System Status

Check machine learning optimization status:

```bash
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Shows:
# - Historical run count
# - Prediction accuracy
# - Recommended optimizations
```

### Pipeline Configuration

View multi-stage pipeline configuration:

```bash
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline

# Shows stages and step assignments
```

## Error Messages

### "GitHub Copilot CLI not found"

**Message**: 
```
ERROR: GitHub Copilot CLI (gh copilot) not available
```

**Cause**: GitHub CLI not installed or Copilot extension not enabled

**Solution**:
```bash
# Install GitHub CLI
# macOS:
brew install gh

# Linux (Debian/Ubuntu):
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate and enable Copilot
gh auth login
gh extension install github/gh-copilot
```

### "Not in a Git repository"

**Message**:
```
ERROR: Current directory is not a Git repository
```

**Solution**:
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"

# Or navigate to git repository
cd /path/to/your/git/repo
```

### "Configuration file not found"

**Message**:
```
WARNING: .workflow-config.yaml not found, using defaults
```

**Solution**:
```bash
# Run configuration wizard
./src/workflow/execute_tests_docs_workflow.sh --init-config

# Or manually create configuration
cp .workflow_core/config/workflow-config-template.yaml .workflow-config.yaml
# Edit .workflow-config.yaml
```

### "Step X not found"

**Message**:
```
ERROR: Step configuration not found for: step_name
```

**Cause**: Invalid step name or missing step module

**Solution**:
```bash
# Check available steps
ls -1 src/workflow/steps/*.sh

# Use correct step name (v4.0.0+)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution

# Or use numeric indices (legacy)
./src/workflow/execute_tests_docs_workflow.sh --steps 0,2,5
```

### "Insufficient disk space"

**Message**:
```
ERROR: Insufficient disk space in /path/to/dir
```

**Solution**:
```bash
# Check disk usage
df -h .

# Clean up old artifacts
rm -rf src/workflow/backlog/workflow_20*
rm -rf src/workflow/logs/workflow_20*

# Clear AI cache
rm -rf src/workflow/.ai_cache/*

# Clear ML data
rm -rf .ml_data/*
```

## Performance Issues

### Workflow Running Slowly

**Symptoms**:
- Execution takes longer than expected
- Steps seem to hang
- High CPU or memory usage

**Solutions**:

**1. Enable Smart Execution**
```bash
./src/workflow/execute_tests_docs_workflow.sh --smart-execution
# Skips unnecessary steps based on changes
```

**2. Enable Parallel Execution**
```bash
./src/workflow/execute_tests_docs_workflow.sh --parallel
# Runs independent steps simultaneously
```

**3. Use Multi-Stage Pipeline**
```bash
./src/workflow/execute_tests_docs_workflow.sh --multi-stage
# Progressive validation, early exit on errors
```

**4. Enable ML Optimization**
```bash
./src/workflow/execute_tests_docs_workflow.sh --ml-optimize
# Requires 10+ historical runs
```

**5. Use Workflow Templates**
```bash
# For documentation only (3-4 min)
./templates/workflows/docs-only.sh

# For tests only (8-10 min)
./templates/workflows/test-only.sh
```

**6. Check AI Cache Hit Rate**
```bash
# View cache statistics
cat src/workflow/.ai_cache/index.json | jq '.stats'

# If hit rate is low, cache may need time to build
```

### High Memory Usage

**Symptom**: System runs out of memory during execution

**Solutions**:

```bash
# 1. Disable parallel execution
./src/workflow/execute_tests_docs_workflow.sh
# (Don't use --parallel)

# 2. Run specific steps only
./src/workflow/execute_tests_docs_workflow.sh --steps 0,2,5

# 3. Clear cache before running
rm -rf src/workflow/.ai_cache/*

# 4. Monitor memory usage
# In another terminal:
watch -n 5 'ps aux | grep execute_tests_docs_workflow | grep -v grep'
```

### AI Calls Timing Out

**Symptom**: AI calls take too long or timeout

**Solutions**:

```bash
# 1. Check network connectivity
ping github.com

# 2. Use smaller model for faster responses
# Edit .workflow-config.yaml:
# ai:
#   model: "gpt-4-turbo"  # Faster than o1-preview

# 3. Reduce AI call frequency
# Skip AI-heavy steps:
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,2,5,12  # Skip AI review steps

# 4. Check GitHub API rate limits
gh api rate_limit
```

## AI-Related Issues

### AI Responses Are Irrelevant

**Symptom**: AI generates incorrect or off-topic content

**Solutions**:

```bash
# 1. Clear AI cache
rm -rf src/workflow/.ai_cache/*

# 2. Update project configuration
./src/workflow/execute_tests_docs_workflow.sh --init-config
# Ensure project_kind and primary_language are correct

# 3. Check AI prompts configuration
cat .workflow_core/config/ai_helpers.yaml | grep -A 10 "documentation_specialist"

# 4. Verify project kind detection
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
```

### AI Cache Not Working

**Symptom**: Low cache hit rate, duplicate AI calls

**Solutions**:

```bash
# 1. Check cache directory
ls -la src/workflow/.ai_cache/
cat src/workflow/.ai_cache/index.json

# 2. Verify cache permissions
chmod 755 src/workflow/.ai_cache
chmod 644 src/workflow/.ai_cache/*

# 3. Clear and rebuild cache
rm -rf src/workflow/.ai_cache/*
mkdir -p src/workflow/.ai_cache
echo '{"entries":{},"stats":{"hits":0,"misses":0,"size":0}}' > src/workflow/.ai_cache/index.json

# 4. Check cache configuration
# Cache TTL is 24 hours by default
# Responses are cached by SHA256 hash of prompt
```

### ML Predictions Inaccurate

**Symptom**: Step duration predictions are wrong

**Solutions**:

```bash
# 1. Check ML data availability
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Need 10+ historical runs for accurate predictions

# 2. Clear ML data and retrain
rm -rf .ml_data/*
# Run workflow 10+ times to rebuild training data

# 3. Disable ML optimization temporarily
./src/workflow/execute_tests_docs_workflow.sh
# (Don't use --ml-optimize)
```

## Git Issues

### Merge Conflicts in Workflow Artifacts

**Symptom**: Git merge conflicts in `backlog/` or `logs/`

**Solution**:
```bash
# These are temporary artifacts, safe to delete
git checkout --theirs src/workflow/backlog/
git checkout --theirs src/workflow/logs/

# Or prefer your version:
git checkout --ours src/workflow/backlog/

# Better: Don't commit these directories
# Add to .gitignore:
echo "src/workflow/backlog/workflow_*" >> .gitignore
echo "src/workflow/logs/workflow_*" >> .gitignore
```

### Auto-Commit Creates Too Many Commits

**Symptom**: Workflow creates excessive commits

**Solutions**:

```bash
# 1. Don't use --auto-commit for every run
./src/workflow/execute_tests_docs_workflow.sh
# (Without --auto-commit)

# 2. Manually review and commit
git add docs/ tests/ src/
git commit -m "workflow: update documentation and tests"

# 3. Squash workflow commits
git rebase -i HEAD~10
# Mark workflow commits as 'squash'
```

### Pre-Commit Hooks Failing

**Symptom**: Git commit rejected by pre-commit hook

**Solutions**:

```bash
# 1. Check what's failing
.git/hooks/pre-commit
# Review output

# 2. Fix issues before committing
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# 3. Temporarily bypass hooks (not recommended)
git commit --no-verify -m "message"

# 4. Update hooks
./src/workflow/execute_tests_docs_workflow.sh --install-hooks
```

## Configuration Issues

### Tech Stack Not Detected

**Symptom**: Workflow doesn't detect project type or language

**Solution**:

```bash
# 1. Show detected tech stack
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# 2. Manually configure
./src/workflow/execute_tests_docs_workflow.sh --init-config

# 3. Edit configuration file
vi .workflow-config.yaml

# Set explicitly:
project:
  kind: "nodejs_api"  # or shell_automation, python_app, etc.
tech_stack:
  primary_language: "javascript"
  test_command: "npm test"
```

### Custom Configuration Not Loaded

**Symptom**: Changes to `.workflow-config.yaml` not taking effect

**Solutions**:

```bash
# 1. Verify config file location
ls -la .workflow-config.yaml
# Should be in project root

# 2. Check config syntax
cat .workflow-config.yaml | grep -v '^#' | grep -v '^$'
# Ensure valid YAML

# 3. Validate config with yq or python
python -c "import yaml; yaml.safe_load(open('.workflow-config.yaml'))"

# 4. Use custom config file
./src/workflow/execute_tests_docs_workflow.sh \
  --config-file /path/to/custom-config.yaml
```

### Step Configuration Not Found (v4.0.0+)

**Symptom**: "Step configuration not found" error

**Solution**:

```bash
# 1. Check available step names
cat .workflow_core/config/workflow_steps.yaml | grep "^  - id:"

# 2. Use correct step names
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution

# 3. Update to v4.0.0+ syntax
# OLD: --steps 2,5
# NEW: --steps documentation_updates,test_execution

# See migration guide:
cat docs/MIGRATION_GUIDE_v4.0.md
```

## Getting Help

### Information to Provide When Reporting Issues

When opening an issue, include:

1. **Version Information**:
   ```bash
   cat src/workflow/execute_tests_docs_workflow.sh | grep "^VERSION="
   git log -1 --format="%H %s"
   ```

2. **Environment**:
   ```bash
   bash --version
   git --version
   node --version
   gh --version
   uname -a
   ```

3. **Configuration**:
   ```bash
   cat .workflow-config.yaml
   ./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
   ```

4. **Error Logs**:
   ```bash
   # Last execution log
   cd src/workflow/logs
   ls -lt | head -2
   tail -100 workflow_YYYYMMDD_HHMMSS/*.log
   ```

5. **Execution Context**:
   ```bash
   # Command that failed
   ./src/workflow/execute_tests_docs_workflow.sh --options-used
   
   # Project structure
   tree -L 2 -I 'node_modules|.git'
   ```

### Debug Mode

Enable verbose logging:

```bash
# Set DEBUG environment variable
export DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh

# Or enable in script
bash -x ./src/workflow/execute_tests_docs_workflow.sh 2>&1 | tee debug.log
```

### Self-Diagnosis Script

Run comprehensive diagnostics:

```bash
# Create diagnostic report
cat > diagnose.sh << 'EOF'
#!/bin/bash
echo "=== AI Workflow Diagnostics ==="
echo
echo "1. Version Information:"
grep "^VERSION=" src/workflow/execute_tests_docs_workflow.sh
git log -1 --format="%H %s"
echo
echo "2. Environment:"
bash --version | head -1
git --version
node --version 2>/dev/null || echo "Node.js not installed"
gh --version 2>/dev/null || echo "GitHub CLI not installed"
echo
echo "3. Directory Structure:"
ls -la src/workflow/{.ai_cache,.checkpoints,backlog,logs,metrics} 2>/dev/null
echo
echo "4. Recent Logs:"
ls -lt src/workflow/logs/ | head -5
echo
echo "5. Configuration:"
cat .workflow-config.yaml 2>/dev/null || echo "No .workflow-config.yaml found"
echo
echo "6. Disk Space:"
df -h .
echo
echo "=== End Diagnostics ==="
EOF

chmod +x diagnose.sh
./diagnose.sh > diagnostics.txt 2>&1
cat diagnostics.txt
```

### Support Channels

1. **Documentation**: Check [DOCUMENTATION_HUB.md](DOCUMENTATION_HUB.md)
2. **GitHub Issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
3. **Discussions**: [github.com/mpbarbosa/ai_workflow/discussions](https://github.com/mpbarbosa/ai_workflow/discussions)
4. **Email**: maintainers listed in [MAINTAINERS.md](MAINTAINERS.md)

---

**Last Updated**: 2026-02-08  
**Version**: 4.0.0  
**Maintainer**: Marcelo Pereira Barbosa (@mpbarbosa)
