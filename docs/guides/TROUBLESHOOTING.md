# Troubleshooting Guide - AI Workflow Automation

**Version**: v3.0.0  
**Last Updated**: 2026-01-31

This guide helps resolve common issues with the AI Workflow Automation system.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Common Issues](#common-issues)
  - [Installation & Setup](#installation--setup)
  - [Execution Failures](#execution-failures)
  - [AI & Caching Issues](#ai--caching-issues)
  - [Performance Problems](#performance-problems)
  - [File & Permission Errors](#file--permission-errors)
- [Error Messages](#error-messages)
- [Debug Mode](#debug-mode)
- [Getting Help](#getting-help)

---

## Quick Diagnostics

### Run Health Check

```bash
cd /path/to/ai_workflow
./src/workflow/lib/health_check.sh
```

**What it checks**:
- Required tools (bash, git, gh, jq, yq)
- GitHub Copilot CLI authentication
- Directory permissions
- Configuration files

### Check System Status

```bash
./src/workflow/execute_tests_docs_workflow.sh --version
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status
```

---

## Common Issues

### Installation & Setup

#### Issue: "Bash version too old"

**Error Message**:
```
ERROR: Bash 4.0+ required (found 3.2.57)
```

**Solution**:
```bash
# macOS
brew install bash
# Add to /etc/shells: /usr/local/bin/bash
chsh -s /usr/local/bin/bash

# Linux
sudo apt-get install bash  # Usually already latest
```

**Verification**:
```bash
bash --version  # Should show 4.0+
```

---

#### Issue: "GitHub Copilot CLI not found"

**Error Message**:
```
ERROR: GitHub Copilot CLI (gh) not installed
```

**Solution**:
```bash
# Install GitHub CLI
brew install gh  # macOS
sudo apt install gh  # Ubuntu/Debian

# Authenticate
gh auth login

# Install Copilot extension
gh extension install github/gh-copilot

# Verify
gh copilot --version
```

**Alternative**: Disable AI features
```bash
export AI_CACHE_ENABLED=false
# Workflow will skip AI-dependent steps
```

---

#### Issue: "jq command not found"

**Error Message**:
```
jq: Bad JSON in --slurpfile current: Could not open file
```

**Solution**:
```bash
# Install jq
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu/Debian
sudo yum install jq  # RHEL/CentOS

# Verify
jq --version
```

---

#### Issue: "Configuration file not found"

**Error Message**:
```
WARNING: .workflow-config.yaml not found
```

**Solution**:
```bash
# Initialize configuration
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config

# Or create manually
cat > .workflow-config.yaml << 'EOF'
project:
  name: "my-project"
  kind: "nodejs_api"

tech_stack:
  primary_language: "javascript"
  test_framework: "jest"
  
test:
  command: "npm test"
  coverage_threshold: 80
EOF
```

---

### Execution Failures

#### Issue: "Permission denied" when creating files

**Error Message**:
```
mkdir: cannot create directory '.ai_workflow': Permission denied
```

**Solution**:
```bash
# Check permissions
ls -ld /path/to/project
ls -ld /path/to/project/.ai_workflow

# Fix ownership
sudo chown -R $USER:$USER /path/to/project

# Check disk space
df -h /path/to/project
```

**Workaround**: Use different target directory
```bash
./execute_tests_docs_workflow.sh --target ~/writable/directory
```

---

#### Issue: "Metrics file missing" (current_run.json)

**Error Message**:
```
jq: Bad JSON in --slurpfile current: Could not open /path/to/current_run.json
```

**Cause**: Metrics initialization failed or file was deleted during execution.

**Solution**: This is now automatically handled in v3.0.0. If you see this error:

```bash
# 1. Check if directory exists
ls -la .ai_workflow/metrics/

# 2. Verify update to metrics.sh (should include auto-creation)
grep -A3 "Ensure metrics file exists" src/workflow/lib/metrics.sh

# 3. If not updated, pull latest version
git pull origin main
```

**Workaround**: Create minimal file manually
```bash
mkdir -p .ai_workflow/metrics
echo '{"workflow_run_id": "", "steps": {}}' > .ai_workflow/metrics/current_run.json
```

---

#### Issue: "Test execution failed" with 0% coverage

**Error Message**:
```
⚠️  WARNING: Test suite executed with failures (0/1 passed, 1 failed)
✅ Coverage: Lines 0%, Branches 0%
```

**Diagnosis**:
```bash
# 1. Check test command
cat .workflow-config.yaml | grep -A2 "test:"

# 2. Run tests manually
npm test  # or your test command
pytest -v
cargo test

# 3. Check test file locations
find . -name "*test*" -o -name "*spec*"
```

**Solution**:
```bash
# Fix test command in config
vim .workflow-config.yaml

# Update to correct command
test:
  command: "npm run test:unit"  # or correct command
  coverage_command: "npm run test:coverage"
```

**Common Test Issues**:
- Wrong test directory in config
- Missing test dependencies: `npm install` or `pip install -r requirements.txt`
- Test framework not installed: `npm install --save-dev jest` or `pip install pytest`

---

#### Issue: "Step validation failed"

**Error Message**:
```
ERROR: Step 2 validation failed - missing required inputs
```

**Diagnosis**:
```bash
# Check what failed
cat .ai_workflow/logs/workflow_*/step2_*.log

# View backlog report
cat .ai_workflow/backlog/workflow_*/step2_*.md
```

**Solution**:
```bash
# Run specific step with debug
DEBUG=true ./execute_tests_docs_workflow.sh --steps 2

# Or skip problematic step temporarily
./execute_tests_docs_workflow.sh --skip-steps 2
```

---

### AI & Caching Issues

#### Issue: "AI response empty or garbled"

**Symptoms**: AI-generated files are empty or contain error messages.

**Diagnosis**:
```bash
# 1. Test Copilot directly
gh copilot explain "How does this work?"

# 2. Check authentication
gh auth status

# 3. Check rate limits
gh api rate_limit
```

**Solution**:
```bash
# Re-authenticate
gh auth logout
gh auth login

# Clear and disable cache temporarily
rm -rf .ai_workflow/.ai_cache
export AI_CACHE_ENABLED=false
./execute_tests_docs_workflow.sh
```

---

#### Issue: "Cache hit but response wrong"

**Symptoms**: AI returns cached response that doesn't match current code.

**Cause**: Prompt is identical but context changed.

**Solution**:
```bash
# Clear cache
rm -rf .ai_workflow/.ai_cache

# Or reduce cache TTL in code
# Edit src/workflow/lib/ai_cache.sh:
CACHE_TTL=3600  # 1 hour instead of 24
```

**Prevention**: Include relevant context in prompts (file names, git commit)

---

#### Issue: "AI cache cleanup failing"

**Error Message**:
```
WARNING: Failed to cleanup expired cache entries
```

**Solution**:
```bash
# 1. Check cache directory permissions
ls -la .ai_workflow/.ai_cache/

# 2. Fix permissions
chmod 755 .ai_workflow/.ai_cache
chmod 644 .ai_workflow/.ai_cache/*

# 3. Manual cleanup
find .ai_workflow/.ai_cache -name "*.cache" -mtime +1 -delete
```

---

### Performance Problems

#### Issue: "Workflow running slowly"

**Expected Times**:
- Documentation only: 3-4 minutes (with --smart-execution)
- Code changes: 10-14 minutes
- Full changes: 15-20 minutes

**Diagnosis**:
```bash
# Check metrics
cat .ai_workflow/metrics/current_run.json | jq .

# View historical performance
cat .ai_workflow/metrics/history.jsonl | tail -5
```

**Solutions**:

**1. Enable Smart Execution** (40-85% faster)
```bash
./execute_tests_docs_workflow.sh --smart-execution
```

**2. Enable Parallel Execution** (33% faster)
```bash
./execute_tests_docs_workflow.sh --parallel
```

**3. Enable ML Optimization** (15-30% additional improvement, requires 10+ runs)
```bash
./execute_tests_docs_workflow.sh --ml-optimize --smart-execution --parallel
```

**4. Use Multi-Stage Pipeline** (80% of runs complete in first 2 stages)
```bash
./execute_tests_docs_workflow.sh --multi-stage
```

**5. Check AI Cache Hit Rate**
```bash
# Should be 60-80% on subsequent runs
grep "cache_hit" .ai_workflow/logs/workflow_*/main.log | wc -l
```

---

#### Issue: "Parallel execution not working"

**Symptoms**: Steps run sequentially despite --parallel flag.

**Diagnosis**:
```bash
# Check dependency graph
./execute_tests_docs_workflow.sh --show-graph
```

**Causes**:
- All steps have dependencies (can't parallelize)
- Only 1 CPU core available
- Steps in same dependency group

**Solution**: Use workflow templates optimized for parallelization
```bash
./templates/workflows/feature.sh  # Pre-configured for parallelization
```

---

#### Issue: "ML optimization not available"

**Error Message**:
```
ℹ️  ML optimization requires 10+ historical workflow runs
```

**Solution**:
```bash
# Check run count
wc -l .ai_workflow/metrics/history.jsonl

# Run workflow 10 times to collect data
for i in {1..10}; do
    ./execute_tests_docs_workflow.sh --auto
    sleep 60
done

# Then enable ML
./execute_tests_docs_workflow.sh --ml-optimize
```

---

### File & Permission Errors

#### Issue: "Cannot write to .workflow_core"

**Error Message**:
```
fatal: not a git repository: .workflow_core
```

**Cause**: Submodule not initialized or corrupted.

**Solution**:
```bash
# Initialize submodule
git submodule update --init --recursive

# Or clone fresh
cd /path/to/ai_workflow
rm -rf .workflow_core
git submodule update --init --recursive
```

---

#### Issue: "Logs directory full"

**Symptoms**: Disk space warning, old logs taking space.

**Solution**:
```bash
# Check log size
du -sh .ai_workflow/logs/

# Keep last 10 runs, delete older
cd .ai_workflow/logs
ls -t | tail -n +11 | xargs rm -rf

# Or clean all logs
rm -rf .ai_workflow/logs/workflow_*
rm -rf .ai_workflow/backlog/workflow_*
```

**Automate Cleanup**: Add to crontab
```bash
# Clean logs older than 30 days
0 2 * * * find /path/to/project/.ai_workflow/logs -type d -mtime +30 -exec rm -rf {} +
```

---

#### Issue: "Git operations failing"

**Error Messages**:
```
fatal: not a git repository
error: Your local changes would be overwritten
```

**Solutions**:

**Not a git repository**:
```bash
cd /path/to/project
git init
git add .
git commit -m "Initial commit"
```

**Uncommitted changes**:
```bash
# Commit changes first
git add .
git commit -m "WIP: before workflow"

# Or stash
git stash
./execute_tests_docs_workflow.sh
git stash pop
```

**Detached HEAD state**:
```bash
git checkout main  # or your branch
./execute_tests_docs_workflow.sh
```

---

## Error Messages

### Fatal Errors

#### `ERROR: METRICS_DIR not set`

**Cause**: `init_metrics()` called before `validate_parsed_arguments()`.

**Fix**: Ensure proper initialization order in main script:
```bash
parse_arguments "$@"
validate_parsed_arguments  # Sets METRICS_DIR
init_metrics               # Now safe
```

---

#### `ERROR: Workflow run failed at step X`

**Diagnosis**:
```bash
# View step log
cat .ai_workflow/logs/workflow_*/stepX_*.log

# View step report
cat .ai_workflow/backlog/workflow_*/stepX_*.md
```

**Solutions**:
- Check prerequisites for that step
- Review error message in log
- Try running step in isolation: `--steps X`

---

### Warning Messages

#### `WARNING: AI cache disabled`

**Cause**: `AI_CACHE_ENABLED=false` or cache initialization failed.

**Impact**: Higher token usage, slower AI calls.

**Fix**:
```bash
export AI_CACHE_ENABLED=true
rm -rf .ai_workflow/.ai_cache  # Clear corrupted cache
./execute_tests_docs_workflow.sh
```

---

#### `WARNING: Project kind not detected`

**Impact**: Generic prompts used instead of project-specific ones.

**Fix**:
```bash
# Manually specify in config
cat >> .workflow-config.yaml << EOF
project:
  kind: "nodejs_api"  # or your project type
EOF
```

---

#### `WARNING: Test coverage below threshold`

**Cause**: Coverage is below configured threshold (default 80%).

**Solutions**:
1. **Improve tests**: Add more test cases
2. **Adjust threshold**: Edit `.workflow-config.yaml`:
   ```yaml
   test:
     coverage_threshold: 70  # Lower threshold
   ```
3. **Continue anyway**: Use `--force` flag

---

## Debug Mode

### Enable Debug Logging

```bash
# Method 1: Environment variable
export DEBUG=true
./execute_tests_docs_workflow.sh

# Method 2: Flag (if implemented)
./execute_tests_docs_workflow.sh --debug

# Method 3: Set in code
DEBUG=true ./execute_tests_docs_workflow.sh
```

### Debug Output Locations

```
.ai_workflow/logs/workflow_YYYYMMDD_HHMMSS/
├── main.log           # Main execution log
├── step0_*.log        # Individual step logs
├── step1_*.log
└── ...
```

### Verbose AI Prompts

```bash
# View AI prompts being sent
export AI_DEBUG=true
./execute_tests_docs_workflow.sh
# AI prompts will be logged to console
```

---

## Advanced Diagnostics

### Check Module Loading

```bash
# Test module sourcing
bash -x src/workflow/execute_tests_docs_workflow.sh --dry-run 2>&1 | grep "source"
```

### Validate Step Dependencies

```bash
# Check dependency graph
./execute_tests_docs_workflow.sh --show-graph

# Export to GraphViz
./execute_tests_docs_workflow.sh --show-graph | dot -Tpng > graph.png
```

### Test Individual Modules

```bash
cd src/workflow/lib

# Test specific module
./test_enhancements.sh
./test_batch_operations.sh
./test_session_manager.sh

# Run all library tests
for test_file in test_*.sh; do
    bash "$test_file"
done
```

---

## Performance Profiling

### Profile Step Execution

```bash
# Run with metrics enabled (default)
./execute_tests_docs_workflow.sh --auto

# View step timings
cat .ai_workflow/metrics/current_run.json | jq '.steps | to_entries | .[] | {step: .key, duration: .value.duration_seconds}'
```

### Profile AI Calls

```bash
# Check AI cache hit rate
grep -c "cache_hit=true" .ai_workflow/logs/workflow_*/main.log
grep -c "cache_hit=false" .ai_workflow/logs/workflow_*/main.log

# Calculate hit rate
hits=$(grep -c "cache_hit=true" .ai_workflow/logs/workflow_*/main.log)
total=$(grep -c "cache_hit" .ai_workflow/logs/workflow_*/main.log)
echo "Cache hit rate: $(echo "scale=2; $hits * 100 / $total" | bc)%"
```

---

## Getting Help

### Check Documentation

1. **Quick Start**: `docs/guides/QUICK_START.md`
2. **API Reference**: `docs/reference/API_REFERENCE.md`
3. **Architecture**: `docs/architecture/ARCHITECTURE_GUIDE.md`
4. **Configuration**: `docs/reference/configuration.md`

### Run Health Check

```bash
./src/workflow/lib/health_check.sh
```

### Collect Debug Information

```bash
# Create debug bundle
mkdir -p /tmp/workflow_debug
cp -r .ai_workflow/logs /tmp/workflow_debug/
cp -r .ai_workflow/metrics /tmp/workflow_debug/
cp .workflow-config.yaml /tmp/workflow_debug/ 2>/dev/null || true
tar -czf workflow_debug.tar.gz -C /tmp workflow_debug
echo "Debug bundle: workflow_debug.tar.gz"
```

### Report Issues

When reporting issues, include:

1. **Version**: `./execute_tests_docs_workflow.sh --version`
2. **Environment**: OS, Bash version, tool versions
3. **Command**: Exact command that failed
4. **Logs**: Relevant log snippets
5. **Configuration**: .workflow-config.yaml (sanitized)
6. **Expected vs Actual**: What you expected to happen vs what happened

### Common Support Requests

**"Workflow stuck at step X"**
```bash
# Check for hanging processes
ps aux | grep workflow
# Kill if needed: kill <PID>

# Check logs for infinite loop
tail -f .ai_workflow/logs/workflow_*/main.log
```

**"Can't authenticate with GitHub"**
```bash
gh auth logout
gh auth login
gh auth token | head -c 10  # Verify token exists
```

**"Performance regression after update"**
```bash
# Compare metrics
cat .ai_workflow/metrics/history.jsonl | tail -5 | jq .duration_seconds

# Check for disabled optimizations
grep -i "smart\|parallel\|ml" .ai_workflow/logs/workflow_*/main.log
```

---

## Quick Reference

### Essential Commands

```bash
# Diagnose
./src/workflow/lib/health_check.sh

# Test run (no changes)
./execute_tests_docs_workflow.sh --dry-run

# Fresh start (ignore checkpoints)
./execute_tests_docs_workflow.sh --no-resume

# Run specific steps
./execute_tests_docs_workflow.sh --steps 0,2,5

# Fast execution
./execute_tests_docs_workflow.sh --smart-execution --parallel --auto

# Debug mode
DEBUG=true ./execute_tests_docs_workflow.sh
```

### Log Locations

```
.ai_workflow/
├── logs/workflow_*/     # Execution logs
├── backlog/workflow_*/  # Step reports
├── metrics/            # Performance data
└── .ai_cache/          # AI response cache
```

### Configuration Files

```
.workflow-config.yaml          # Project config
.workflow_core/config/         # System config (submodule)
  ├── ai_helpers.yaml         # AI prompts
  ├── project_kinds.yaml      # Project types
  └── paths.yaml              # Path config
```

---

## Preventive Measures

### 1. Pre-Flight Checks

Always run before important executions:
```bash
./src/workflow/lib/health_check.sh
git status  # Ensure clean state
```

### 2. Backup Before Major Changes

```bash
git commit -am "Before workflow execution"
# Or create branch
git checkout -b workflow-test-$(date +%Y%m%d)
```

### 3. Test on Sample Project

Before using on production:
```bash
# Clone test project
git clone https://github.com/user/test-project
cd test-project

# Run workflow
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --dry-run
```

### 4. Keep Workflow Updated

```bash
cd /path/to/ai_workflow
git pull origin main
git submodule update --init --recursive
```

### 5. Monitor Disk Space

```bash
df -h
du -sh .ai_workflow/*
```

---

**Need More Help?** See [CONTRIBUTING.md](../../CONTRIBUTING.md) for community support options.

**Last Updated**: 2026-01-31  
**Version**: v3.0.0
