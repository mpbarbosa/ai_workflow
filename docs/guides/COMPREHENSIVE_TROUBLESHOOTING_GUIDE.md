# Comprehensive Troubleshooting Guide

**Version**: v4.0.0  
**Last Updated**: 2026-02-08

## Overview

This guide provides solutions to common issues, debugging techniques, and diagnostic procedures for the AI Workflow Automation system.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Common Issues](#common-issues)
- [Installation Problems](#installation-problems)
- [Configuration Issues](#configuration-issues)
- [Execution Failures](#execution-failures)
- [AI Integration Problems](#ai-integration-problems)
- [Performance Issues](#performance-issues)
- [Git Integration Problems](#git-integration-problems)
- [Advanced Debugging](#advanced-debugging)

---

## Quick Diagnostics

### Health Check

Run the built-in health check to diagnose system issues:

```bash
./src/workflow/lib/health_check.sh
```

**Output Example**:
```
✓ Bash version: 5.1.16 (Required: 4.0+)
✓ Git available: 2.39.0
✓ Node.js available: 25.2.1
✓ GitHub Copilot CLI available
✓ Copilot authenticated
✓ Configuration file found
✓ All required directories exist
```

### System Requirements Check

```bash
# Check Bash version
bash --version

# Check Git
git --version

# Check GitHub Copilot CLI
gh copilot --version

# Check authentication
gh auth status
```

### Log Inspection

```bash
# View latest workflow log
tail -f logs/workflow_$(ls -t logs/ | head -1)/workflow.log

# Search for errors
grep -i "error" logs/workflow_*/workflow.log

# Search for warnings
grep -i "warning" logs/workflow_*/workflow.log
```

---

## Common Issues

### Issue: "Command not found: gh"

**Symptoms**: Workflow fails at AI steps
```
Error: gh: command not found
```

**Cause**: GitHub CLI not installed

**Solution**:
```bash
# On Ubuntu/Debian
sudo apt install gh

# On macOS
brew install gh

# On other systems, see: https://cli.github.com/manual/installation

# Authenticate after installation
gh auth login
```

---

### Issue: "Copilot CLI not authenticated"

**Symptoms**: AI calls fail with authentication error
```
Error: You are not authenticated with GitHub Copilot
```

**Cause**: GitHub Copilot CLI not authenticated

**Solution**:
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status

# Test Copilot access
gh copilot explain "echo hello"
```

---

### Issue: "Configuration file not found"

**Symptoms**: Workflow exits immediately
```
Error: Configuration file .workflow-config.yaml not found
```

**Cause**: Project not configured

**Solution**:
```bash
# Run configuration wizard
./execute_tests_docs_workflow.sh --init-config

# Or create manually
cat > .workflow-config.yaml << 'EOF'
project:
  name: "My Project"
  kind: "nodejs_api"
tech_stack:
  primary_language: "javascript"
  test_command: "npm test"
EOF
```

---

### Issue: "Permission denied"

**Symptoms**: Cannot execute workflow script
```
bash: ./execute_tests_docs_workflow.sh: Permission denied
```

**Cause**: Script not executable

**Solution**:
```bash
# Make executable
chmod +x src/workflow/execute_tests_docs_workflow.sh

# Or run with bash
bash src/workflow/execute_tests_docs_workflow.sh
```

---

### Issue: Checkpoint Resume Fails

**Symptoms**: Workflow doesn't resume from checkpoint
```
Warning: Checkpoint file corrupted, starting fresh
```

**Cause**: Corrupted checkpoint data

**Solution**:
```bash
# Remove checkpoint and restart
rm -f .workflow_state/checkpoint.json
./execute_tests_docs_workflow.sh

# Or force fresh start
./execute_tests_docs_workflow.sh --no-resume
```

---

### Issue: Steps Not Skipping (Smart Execution)

**Symptoms**: All steps run despite --smart-execution
```
Info: Smart execution enabled
Running step 1...
Running step 2...
[All steps run]
```

**Cause**: Large change set or git detection failure

**Solution**:
```bash
# Verify git status
git status

# Check change detection
./src/workflow/lib/change_detection.sh

# Debug smart execution
DEBUG=true ./execute_tests_docs_workflow.sh --smart-execution
```

---

### Issue: Parallel Execution Not Working

**Symptoms**: Steps run sequentially despite --parallel
```
Info: Parallel execution enabled
Running step 2 [sequential]
Running step 3 [sequential]
```

**Cause**: Dependencies prevent parallelization or insufficient independent steps

**Solution**:
```bash
# View dependency graph
./execute_tests_docs_workflow.sh --show-graph

# Check which steps can run in parallel
grep "can_run_parallel: true" .workflow_core/config/workflow_steps.yaml

# Verify no conflicting dependencies
```

---

## Installation Problems

### Issue: Submodule Not Initialized

**Symptoms**: Configuration files missing
```
Error: .workflow_core/config/ directory not found
```

**Cause**: Git submodules not initialized

**Solution**:
```bash
# Initialize submodules
git submodule init
git submodule update

# Or clone with submodules
git clone --recursive git@github.com:mpbarbosa/ai_workflow.git
```

---

### Issue: Missing Dependencies

**Symptoms**: Various command failures

**Solution**:
```bash
# Install required tools
sudo apt install bash git jq yq

# On macOS
brew install bash git jq yq

# Verify installation
bash --version
git --version
jq --version
yq --version
```

---

## Configuration Issues

### Issue: Invalid YAML Syntax

**Symptoms**: Configuration parsing fails
```
Error: Invalid YAML in .workflow-config.yaml
```

**Solution**:
```bash
# Validate YAML syntax
yamllint .workflow-config.yaml

# Or use online validator
# https://www.yamllint.com/

# Check for common issues:
# - Incorrect indentation
# - Missing quotes
# - Invalid characters
```

---

### Issue: Project Kind Not Detected

**Symptoms**: Generic prompts instead of project-specific
```
Warning: Could not detect project kind, using generic
```

**Solution**:
```bash
# Explicitly set project kind in config
cat >> .workflow-config.yaml << 'EOF'
project:
  kind: "nodejs_api"
EOF

# Or re-run configuration wizard
./execute_tests_docs_workflow.sh --init-config

# View available project kinds
cat .workflow_core/config/project_kinds.yaml
```

---

### Issue: Test Command Not Working

**Symptoms**: Step 5 (test execution) fails
```
Error: Test command failed with exit code 127
```

**Solution**:
```bash
# Test command directly
npm test

# Update configuration
yq eval '.tech_stack.test_command = "npm test"' -i .workflow-config.yaml

# Verify configuration
yq eval '.tech_stack.test_command' .workflow-config.yaml
```

---

## Execution Failures

### Issue: Step Fails with "Command not found"

**Symptoms**: Specific step fails
```
Step 5: Test Execution
Error: npm: command not found
```

**Cause**: Required tool not in PATH

**Solution**:
```bash
# Check if tool is installed
which npm

# Add to PATH
export PATH="/path/to/tool:$PATH"

# Or install the tool
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
```

---

### Issue: Out of Memory

**Symptoms**: Process killed
```
Killed
Step execution failed
```

**Cause**: Insufficient memory

**Solution**:
```bash
# Check memory usage
free -h

# Run with reduced parallelism
# Disable parallel execution temporarily
./execute_tests_docs_workflow.sh --smart-execution

# Or limit step selection
./execute_tests_docs_workflow.sh --steps documentation_updates,test_execution
```

---

### Issue: Timeout Errors

**Symptoms**: Steps hang or timeout
```
Error: Step exceeded maximum execution time (600s)
```

**Solution**:
```bash
# Increase timeout in step module
# Edit the specific step file
vim src/workflow/steps/step_name.sh

# Find timeout value and increase
# STEP_TIMEOUT=900  # Increase to 15 minutes

# Or skip the problematic step
./execute_tests_docs_workflow.sh --steps 0,1,2,4,5,6
```

---

## AI Integration Problems

### Issue: AI Cache Not Working

**Symptoms**: All AI calls are fresh (no cache hits)
```
AI Cache Stats:
  Hit Rate: 0%
  Total Calls: 20
  Cache Hits: 0
```

**Cause**: Cache disabled or corrupted

**Solution**:
```bash
# Check cache configuration
yq eval '.ai.cache_enabled' .workflow-config.yaml

# Enable caching
export AI_CACHE_ENABLED=true

# Clear corrupted cache
rm -rf .ai_cache/
./execute_tests_docs_workflow.sh

# Verify cache directory
ls -la .ai_cache/
```

---

### Issue: AI Responses Are Low Quality

**Symptoms**: Generated content is not helpful

**Cause**: Inadequate context or persona configuration

**Solution**:
```bash
# Verify project kind is set correctly
yq eval '.project.kind' .workflow-config.yaml

# Check AI configuration
cat .workflow_core/config/ai_helpers.yaml

# Ensure primary_language is set
yq eval '.tech_stack.primary_language' .workflow-config.yaml

# Try with fresh cache
./execute_tests_docs_workflow.sh --no-ai-cache
```

---

### Issue: Rate Limiting

**Symptoms**: AI calls fail with rate limit errors
```
Error: Rate limit exceeded (429)
```

**Cause**: Too many API calls

**Solution**:
```bash
# Wait before retrying
sleep 60

# Enable caching to reduce calls
export AI_CACHE_ENABLED=true

# Use selective step execution
./execute_tests_docs_workflow.sh --steps 1,5

# Check rate limit status
gh api rate_limit
```

---

## Performance Issues

### Issue: Workflow Too Slow

**Symptoms**: Full workflow takes 30+ minutes

**Solution**:
```bash
# Enable all optimizations
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage

# Check metrics to identify slow steps
cat metrics/current_run.json | jq '.steps'

# Use workflow templates
./templates/workflows/docs-only.sh  # 3-4 min
./templates/workflows/test-only.sh  # 8-10 min
```

---

### Issue: Step 1 Too Slow

**Symptoms**: Documentation analysis takes 10+ minutes

**Cause**: Not using Step 1 optimization (v3.2.0+)

**Solution**:
```bash
# Step 1 optimization is automatic in v3.2.0+
# Verify version
cat src/workflow/steps/documentation_updates.sh | grep VERSION

# Check for incremental processing
ls -la .analysis_cache/

# Force cache clear if needed
rm -rf .analysis_cache/
```

---

### Issue: High CPU Usage

**Symptoms**: System becomes unresponsive

**Cause**: Too many parallel processes

**Solution**:
```bash
# Reduce parallelism
export MAX_PARALLEL_STEPS=2

# Or disable parallel execution
./execute_tests_docs_workflow.sh --smart-execution

# Monitor CPU usage
top -p $(pgrep -f execute_tests_docs_workflow)
```

---

## Git Integration Problems

### Issue: Auto-Commit Not Working

**Symptoms**: Changes not committed automatically

**Cause**: Auto-commit not enabled or no changes detected

**Solution**:
```bash
# Enable auto-commit
./execute_tests_docs_workflow.sh --auto-commit

# Or set in config
yq eval '.git.auto_commit = true' -i .workflow-config.yaml

# Check for uncommitted changes
git status

# Verify git configuration
git config user.name
git config user.email
```

---

### Issue: Pre-Commit Hooks Failing

**Symptoms**: Git commits are rejected
```
Pre-commit hook failed
Commit aborted
```

**Cause**: Validation checks failing

**Solution**:
```bash
# Test hooks
./execute_tests_docs_workflow.sh --test-hooks

# View hook output
cat .git/hooks/pre-commit.log

# Bypass hooks (temporary)
git commit --no-verify -m "message"

# Fix validation issues
./execute_tests_docs_workflow.sh --steps 1,2,3
```

---

### Issue: Merge Conflicts in Workflow Artifacts

**Symptoms**: Git conflicts in backlog or metrics

**Cause**: Multiple workflow runs on different branches

**Solution**:
```bash
# Artifacts should not be tracked in git
# Add to .gitignore
cat >> .gitignore << 'EOF'
/backlog/
/logs/
/metrics/
/.ai_cache/
/.analysis_cache/
/.workflow_state/
EOF

# Remove from git
git rm -r --cached backlog/ logs/ metrics/
git commit -m "Remove workflow artifacts from tracking"
```

---

## Advanced Debugging

### Enable Debug Mode

```bash
# Method 1: CLI flag
./execute_tests_docs_workflow.sh --debug --verbose

# Method 2: Environment variable
export DEBUG=true
export VERBOSE=true
./execute_tests_docs_workflow.sh

# Method 3: Bash tracing
./execute_tests_docs_workflow.sh --trace
# Or
bash -x src/workflow/execute_tests_docs_workflow.sh
```

### Trace Specific Functions

```bash
# Add debug output to specific function
vim src/workflow/lib/module.sh

# Add debug statements
function_name() {
    [[ "$DEBUG" == "true" ]] && echo "DEBUG: Entering function_name with args: $*" >&2
    # ... function code ...
    [[ "$DEBUG" == "true" ]] && echo "DEBUG: Exiting function_name" >&2
}
```

### Inspect Workflow State

```bash
# View current session
cat .workflow_state/current_session.json | jq .

# View checkpoint
cat .workflow_state/checkpoint.json | jq .

# View metrics
cat metrics/current_run.json | jq .

# View cache index
cat .ai_cache/index.json | jq .
```

### Monitor System Resources

```bash
# Monitor workflow process
watch -n 1 'ps aux | grep execute_tests_docs_workflow'

# Monitor memory
watch -n 1 free -h

# Monitor disk I/O
iotop -o

# Monitor file handles
lsof -p $(pgrep -f execute_tests_docs_workflow)
```

### Debugging AI Calls

```bash
# Enable AI debugging
export AI_DEBUG=true

# View AI prompts
export SAVE_AI_PROMPTS=true
# Prompts saved to: .ai_cache/prompts/

# View AI responses
export SAVE_AI_RESPONSES=true
# Responses saved to: .ai_cache/responses/

# Test AI call directly
source src/workflow/lib/ai_helpers.sh
ai_call "documentation_specialist" "Test prompt" "output.md"
```

### Step-by-Step Execution

```bash
# Run one step at a time
./execute_tests_docs_workflow.sh --steps documentation_updates
# Check output
./execute_tests_docs_workflow.sh --steps consistency_check
# Continue step by step

# Or use interactive mode
./execute_tests_docs_workflow.sh --interactive
```

### Analyzing Logs

```bash
# Find all errors
find logs/ -name "*.log" -exec grep -H "ERROR" {} \;

# Find all warnings
find logs/ -name "*.log" -exec grep -H "WARN" {} \;

# Timeline analysis
cat logs/workflow_*/workflow.log | grep "^[0-9]" | sort

# Step duration analysis
grep "Step.*completed in" logs/workflow_*/workflow.log
```

---

## Getting Help

### Collect Diagnostic Information

```bash
# Run diagnostic script
./scripts/collect_diagnostics.sh

# This generates: diagnostics_TIMESTAMP.tar.gz
# Contains:
# - System information
# - Configuration files (sanitized)
# - Recent logs
# - Error reports
```

### Report an Issue

When reporting issues, include:

1. **System Information**:
   ```bash
   bash --version
   git --version
   gh --version
   uname -a
   ```

2. **Configuration** (sanitized):
   ```bash
   cat .workflow-config.yaml
   ```

3. **Error Output**:
   ```bash
   tail -100 logs/workflow_*/workflow.log
   ```

4. **Steps to Reproduce**:
   - Command executed
   - Options used
   - Expected vs actual behavior

5. **Metrics** (if relevant):
   ```bash
   cat metrics/current_run.json
   ```

### Community Support

- **GitHub Issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Documentation**: [docs/](../)
- **FAQ**: [user-guide/faq.md](../user-guide/faq.md)

---

## Preventive Measures

### Regular Maintenance

```bash
# Clean old cache entries
rm -rf .ai_cache/old_*
rm -rf .analysis_cache/old_*

# Archive old logs
./scripts/archive_logs.sh

# Update system
git pull
git submodule update --remote
```

### Best Practices

1. **Keep Dependencies Updated**
   ```bash
   # Update GitHub CLI
   gh version --upgrade
   ```

2. **Monitor Disk Space**
   ```bash
   df -h
   # Clean if needed
   ./scripts/cleanup.sh
   ```

3. **Regular Health Checks**
   ```bash
   # Run weekly
   ./src/workflow/lib/health_check.sh
   ```

4. **Backup Important Data**
   ```bash
   # Backup configuration
   cp .workflow-config.yaml .workflow-config.yaml.backup
   ```

---

## See Also

- [User Guide](../user-guide/usage.md)
- [FAQ](../user-guide/faq.md)
- [Configuration Reference](COMPLETE_CONFIGURATION_REFERENCE.md)
- [Installation Guide](../user-guide/installation.md)

---

**Maintained by**: AI Workflow Automation Team  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
