# Pre-Commit Hooks Setup Guide

**Version**: v4.0.0 (Feature introduced in v3.0.0)  
**Last Updated**: 2026-02-08  
**Related Documentation**: [Debugging Workflows](DEBUGGING_WORKFLOWS.md), [Development Setup](../developer-guide/development-setup.md)

## Overview

Pre-commit hooks (v3.0.0+) provide fast validation checks (< 1 second) to prevent broken commits before they enter your Git history. This guide covers installation, configuration, customization, and troubleshooting of pre-commit hooks for AI Workflow.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [What Hooks Validate](#what-hooks-validate)
4. [Configuration](#configuration)
5. [Bypass Hooks](#bypass-hooks)
6. [Customization](#customization)
7. [Testing Hooks](#testing-hooks)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## Quick Start

### Install Pre-Commit Hooks

```bash
# Automatic installation (recommended)
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Output:
# ✓ Pre-commit hook installed
# ✓ Hooks configured for project type: shell_script_automation
# ✓ Fast validation enabled (< 1 second)
```

### Test Hooks

```bash
# Test hooks without committing
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# Output:
# 🔍 Running pre-commit checks...
#   Checking shell syntax... ✓
#   Checking YAML files... ✓
#   Checking for TODOs... ✓
# ✓ All checks passed (0.8s)
```

### Make a Commit

```bash
# Hooks run automatically on commit
git add file.sh
git commit -m "Update feature"

# Hook output appears before commit:
# 🔍 Running pre-commit checks...
#   Checking shell syntax... ✓
# ✓ All checks passed (0.6s)
# [main abc1234] Update feature
```

---

## Installation

### Automatic Installation (Recommended)

```bash
# Install hooks with automatic project type detection
cd /path/to/your/project
./path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --install-hooks
```

**What happens**:
1. Detects project type (shell, nodejs, python, etc.)
2. Generates optimized pre-commit hook at `.git/hooks/pre-commit`
3. Makes hook executable (`chmod +x`)
4. Configures project-specific checks

**Supported Project Types**:
- `shell_script_automation`: ShellCheck validation
- `nodejs_api`, `nodejs_cli`, `nodejs_library`: Node.js + ESLint checks
- `python_api`, `python_cli`, `python_library`: Python + pylint/flake8 checks
- `static_website`, `client_spa`, `react_spa`, `vue_spa`: HTML/CSS/JS validation
- `generic`: Basic syntax checks only

### Manual Installation

```bash
# 1. Copy hook template
cp templates/hooks/pre-commit .git/hooks/pre-commit

# 2. Make executable
chmod +x .git/hooks/pre-commit

# 3. Test installation
.git/hooks/pre-commit
```

### Verify Installation

```bash
# Check hook exists and is executable
ls -la .git/hooks/pre-commit

# Expected output:
# -rwxr-xr-x 1 user user 2048 Feb 08 22:30 .git/hooks/pre-commit

# Test hook manually
.git/hooks/pre-commit
```

---

## What Hooks Validate

Pre-commit hooks perform **fast validation checks** (< 1 second) on staged files only.

### Universal Checks (All Projects)

| Check | Tool | What It Does | Performance |
|-------|------|--------------|-------------|
| **YAML Syntax** | `yamllint` | Validates YAML files | < 0.2s |
| **Trailing Whitespace** | `git diff` | Checks for trailing spaces | < 0.1s |
| **Large Files** | `git diff` | Warns about files > 10MB | < 0.1s |
| **Merge Conflicts** | `grep` | Detects conflict markers | < 0.1s |
| **TODO Comments** | `grep` | Flags TODO/FIXME (warning only) | < 0.1s |

### Project-Specific Checks

#### Shell Script Projects
```bash
# ShellCheck validation
shellcheck -x file.sh

# Bash syntax check
bash -n file.sh
```

#### Node.js Projects
```bash
# JavaScript/TypeScript syntax
node --check file.js

# ESLint (if configured)
eslint file.js --max-warnings=0

# Prettier (if configured)
prettier --check file.js
```

#### Python Projects
```bash
# Python syntax
python -m py_compile file.py

# Pylint (if configured)
pylint file.py --errors-only

# Flake8 (if configured)
flake8 file.py
```

#### React/Vue Projects
```bash
# Component validation
eslint *.jsx *.vue

# Type checking (TypeScript)
tsc --noEmit
```

### Example Hook Output

**Success**:
```
🔍 Running pre-commit checks...
  Checking shell syntax... ✓
  Checking YAML files... ✓
  Checking for large files... ✓
  Checking for merge conflicts... ✓
✓ All checks passed (0.7s)
```

**Failure**:
```
🔍 Running pre-commit checks...
  Checking shell syntax... ✗
  
✗ Pre-commit checks failed (0.8s)

Shell syntax errors in src/workflow/lib/new_module.sh:
  Line 42: missing closing quote
  Line 58: unmatched )

Fix errors and try again, or bypass with: git commit --no-verify
```

---

## Configuration

### Configure Hook Behavior

Edit `.git/hooks/pre-commit` to customize checks:

```bash
# Enable/disable specific checks
ENABLE_SHELLCHECK=true
ENABLE_ESLINT=true
ENABLE_TODO_CHECK=false  # Disable TODO warnings

# Configure thresholds
MAX_FILE_SIZE_MB=10
MAX_LINE_LENGTH=120

# Configure tools
SHELLCHECK_OPTS="-x -s bash"
ESLINT_MAX_WARNINGS=0
```

### Project-Specific Configuration

Create `.pre-commit-config.yaml` in project root:

```yaml
# AI Workflow Pre-Commit Configuration
version: 1.0.0

# Enable/disable checks
checks:
  syntax: true
  yaml: true
  large_files: true
  merge_conflicts: true
  todos: false  # Don't fail on TODOs

# Tool-specific settings
tools:
  shellcheck:
    enabled: true
    options: "-x -s bash"
    exclude: ["vendor/", "node_modules/"]
  
  eslint:
    enabled: true
    max_warnings: 0
    config: ".eslintrc.json"
  
  prettier:
    enabled: false
  
  pylint:
    enabled: true
    options: "--errors-only"

# File size limits
limits:
  max_file_size_mb: 10
  max_line_length: 120

# Performance tuning
performance:
  timeout_seconds: 5
  parallel_checks: true
```

**Apply configuration**:
```bash
# Regenerate hooks with new config
./src/workflow/execute_tests_docs_workflow.sh --install-hooks
```

---

## Bypass Hooks

### Temporary Bypass

```bash
# Skip hooks for single commit
git commit --no-verify -m "Emergency fix"

# Or use shorthand
git commit -n -m "Emergency fix"
```

**When to bypass**:
- ✅ Emergency hotfixes
- ✅ Work-in-progress commits (use with caution)
- ✅ Known issues being fixed in next commit
- ❌ To skip validation permanently (DON'T DO THIS)

### Disable Hooks Permanently

```bash
# Remove hook file
rm .git/hooks/pre-commit

# Or make non-executable
chmod -x .git/hooks/pre-commit
```

**Warning**: Disabling hooks permanently is **not recommended**. Use bypass (`--no-verify`) for exceptional cases only.

### Bypass Specific Checks

Edit `.git/hooks/pre-commit` to disable individual checks:

```bash
# Comment out specific check
# if command -v shellcheck >/dev/null 2>&1; then
#     echo -ne "  Checking shell syntax... "
#     ...
# fi
```

---

## Customization

### Add Custom Checks

Edit `.git/hooks/pre-commit` to add new checks:

```bash
# Add after existing checks, before the "FAILED" check

# ==============================================================================
# CUSTOM CHECKS
# ==============================================================================

# Check for hardcoded secrets
echo -ne "  Checking for secrets... "
if git diff --cached | grep -E "(password|api_key|secret)" >/dev/null; then
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Potential hardcoded secrets detected${NC}"
    FAILED=true
else
    echo -e "${GREEN}✓${NC}"
fi

# Check documentation exists for new functions
echo -ne "  Checking function documentation... "
if git diff --cached --name-only --diff-filter=A | grep '\.sh$' | while read -r file; do
    # Check if new functions have comments
    if grep -E "^function [a-zA-Z_]+" "$file" | while read -r func; do
        func_name=$(echo "$func" | awk '{print $2}')
        if ! grep -B5 "$func_name" "$file" | grep -q "^#"; then
            echo -e "\n${YELLOW}Warning: Function $func_name in $file lacks documentation${NC}"
        fi
    done
fi; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
fi
```

### Project-Specific Hook Templates

Create custom hook templates for different project types:

```bash
# templates/hooks/pre-commit-nodejs
#!/usr/bin/env bash
set -euo pipefail

# Node.js specific checks
echo "🔍 Running Node.js pre-commit checks..."

# Check package.json syntax
if ! jq '.' package.json >/dev/null 2>&1; then
    echo "✗ Invalid package.json"
    exit 1
fi

# Run tests (if fast)
if npm run test:fast >/dev/null 2>&1; then
    echo "✓ Fast tests passed"
else
    echo "✗ Fast tests failed"
    exit 1
fi

echo "✓ All Node.js checks passed"
```

**Install custom template**:
```bash
cp templates/hooks/pre-commit-nodejs .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

## Testing Hooks

### Test Without Committing

```bash
# Dry-run mode (v3.0.0+)
./src/workflow/execute_tests_docs_workflow.sh --test-hooks

# Or run hook directly
.git/hooks/pre-commit
```

**Expected output**:
```
🔍 Running pre-commit checks...
  Checking shell syntax... ✓
  Checking YAML files... ✓
  Checking for large files... ✓
  Checking for merge conflicts... ✓
  Checking for TODOs... ⚠ (2 found)
✓ All checks passed (0.8s)
```

### Test Specific Scenarios

#### Test with Syntax Error

```bash
# Create file with syntax error
echo "function test() { echo 'unclosed" > test.sh

# Stage file
git add test.sh

# Run hook (should fail)
.git/hooks/pre-commit

# Expected output:
# ✗ Shell syntax errors detected
# Exit code: 1
```

#### Test with Large File

```bash
# Create large file
dd if=/dev/zero of=large.bin bs=1M count=15

# Stage file
git add large.bin

# Run hook (should warn)
.git/hooks/pre-commit

# Expected output:
# ⚠ Large file detected: large.bin (15MB)
```

### Automated Hook Testing

Create test suite for hooks:

```bash
#!/bin/bash
# test_precommit_hooks.sh

set -euo pipefail

echo "Testing pre-commit hooks..."

# Test 1: Valid files pass
git add valid_file.sh
if .git/hooks/pre-commit; then
    echo "✓ Test 1 passed: Valid files"
else
    echo "✗ Test 1 failed"
    exit 1
fi

# Test 2: Syntax errors fail
echo "function bad() { echo 'unclosed" > bad.sh
git add bad.sh
if ! .git/hooks/pre-commit 2>/dev/null; then
    echo "✓ Test 2 passed: Syntax errors detected"
else
    echo "✗ Test 2 failed: Syntax errors not detected"
    exit 1
fi

# Clean up
git reset HEAD bad.sh
rm bad.sh

echo "✓ All hook tests passed"
```

---

## Troubleshooting

### Issue: Hook Not Running

**Symptoms**:
- Commits succeed without hook output
- No validation messages

**Diagnosis**:
```bash
# Check hook exists
ls -la .git/hooks/pre-commit

# Check hook is executable
stat -c '%A' .git/hooks/pre-commit  # Should show -rwxr-xr-x

# Test hook manually
.git/hooks/pre-commit
```

**Solutions**:
```bash
# Reinstall hooks
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Make executable if missing
chmod +x .git/hooks/pre-commit

# Verify no bypass flag
git config --get-all core.hooksPath  # Should be empty or .git/hooks
```

---

### Issue: Hook Fails with "Command Not Found"

**Symptoms**:
```
./pre-commit: line 42: shellcheck: command not found
```

**Solutions**:
```bash
# Install missing tool
sudo apt install shellcheck  # Linux
brew install shellcheck      # macOS

# Or disable check in hook
# Edit .git/hooks/pre-commit:
if command -v shellcheck >/dev/null 2>&1; then
    # Check only if available
fi
```

---

### Issue: Hook Hangs or Takes Too Long

**Symptoms**:
- Hook runs for > 5 seconds
- Commit appears frozen

**Diagnosis**:
```bash
# Run hook with timing
time .git/hooks/pre-commit

# Check for slow operations
bash -x .git/hooks/pre-commit 2>&1 | grep "^+"
```

**Solutions**:
```bash
# Add timeout to hook checks
timeout 5s shellcheck file.sh || echo "Timeout"

# Disable slow checks
# Comment out expensive operations in .git/hooks/pre-commit

# Run checks in parallel
git diff --cached --name-only | xargs -P4 -I{} shellcheck {}
```

---

### Issue: False Positives

**Symptoms**:
- Hook fails on valid code
- Overly strict checks

**Solutions**:
```bash
# Adjust tool configuration
# For ShellCheck: Add .shellcheckrc
disable=SC2034  # Disable specific warnings

# For ESLint: Update .eslintrc.json
{
  "rules": {
    "no-console": "warn"  # Change to warning
  }
}

# Or bypass specific files
# In .git/hooks/pre-commit:
if [[ ! "$file" =~ vendor/ ]]; then
    shellcheck "$file"
fi
```

---

### Issue: Hook Exits with Code 1 but No Error Message

**Diagnosis**:
```bash
# Run hook with debug mode
bash -x .git/hooks/pre-commit

# Check error handling
grep "exit 1" .git/hooks/pre-commit
```

**Solutions**:
```bash
# Add error logging to hook
exec 2> .git/hooks/pre-commit.log

# Or improve error messages
echo -e "${RED}Error in check X${NC}" >&2
exit 1
```

---

## Best Practices

### 1. Keep Hooks Fast (< 1 second)

```bash
# ✅ GOOD: Fast checks
shellcheck file.sh                # Syntax only
grep -l "TODO" file.sh            # Simple search
git diff --check                  # Whitespace check

# ❌ BAD: Slow operations
npm test                          # Full test suite (use CI)
shellcheck -x **/*.sh             # All files (check staged only)
heavy_linter --deep-analysis      # Expensive analysis
```

**Rule**: Pre-commit hooks should validate syntax and simple rules only. Full tests belong in CI/CD.

---

### 2. Check Staged Files Only

```bash
# ✅ GOOD: Check staged files
git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' | xargs shellcheck

# ❌ BAD: Check all files
find . -name "*.sh" -exec shellcheck {} \;
```

**Why**: Only staged files will be committed. Checking all files is wasteful.

---

### 3. Provide Clear Error Messages

```bash
# ✅ GOOD: Helpful message
echo -e "${RED}Shell syntax errors in $file:${NC}"
shellcheck "$file"
echo -e "${YELLOW}Fix with: shellcheck $file${NC}"

# ❌ BAD: Cryptic message
echo "Error"
exit 1
```

---

### 4. Make Checks Optional

```bash
# ✅ GOOD: Graceful degradation
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck file.sh
else
    echo "⚠ ShellCheck not installed, skipping"
fi

# ❌ BAD: Hard requirement
shellcheck file.sh  # Fails if not installed
```

---

### 5. Document Bypass Procedures

Add to project README:

```markdown
## Bypassing Pre-Commit Hooks

In exceptional cases, bypass hooks with:

```bash
git commit --no-verify -m "Message"
```

**Only use for**:
- Emergency hotfixes
- Known issues being addressed
- Work-in-progress (with caution)
```

---

### 6. Version Control Hooks

```bash
# Store hook templates in version control
templates/hooks/
├── pre-commit           # Base template
├── pre-commit-nodejs    # Node.js projects
├── pre-commit-python    # Python projects
└── README.md            # Hook documentation

# Install from template
cp templates/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Do NOT commit** `.git/hooks/` directly - it's user-specific.

---

### 7. Test Hooks in CI

```yaml
# .github/workflows/test.yml
- name: Test Pre-Commit Hooks
  run: |
    ./src/workflow/execute_tests_docs_workflow.sh --test-hooks
```

---

## Advanced Configuration

### Multi-Stage Hooks

Run checks in stages (fast → slow):

```bash
# Stage 1: Instant checks (< 0.1s)
echo -ne "Stage 1: Instant checks... "
if ! git diff --check; then
    echo "✗ Whitespace errors"
    exit 1
fi
echo "✓"

# Stage 2: Fast checks (< 0.5s)
echo -ne "Stage 2: Syntax checks... "
# ... shellcheck, node --check, etc.
echo "✓"

# Stage 3: Optional checks (< 1s)
echo -ne "Stage 3: Linting... "
# ... eslint, pylint, etc.
echo "✓"
```

---

### Parallel Check Execution

```bash
# Run checks in parallel for speed
(shellcheck file1.sh &)
(node --check file2.js &)
(python -m py_compile file3.py &)
wait  # Wait for all to complete
```

---

### Hook Performance Monitoring

```bash
# Add timing to each check
check_start=$(date +%s%3N)
shellcheck file.sh
check_end=$(date +%s%3N)
echo "ShellCheck: $((check_end - check_start))ms"
```

---

## Related Documentation

- **[Debugging Workflows](DEBUGGING_WORKFLOWS.md)** - Debugging techniques
- **[Development Setup](../developer-guide/development-setup.md)** - Prerequisites
- **[Contributing Guide](../developer-guide/contributing.md)** - Development workflow
- **[Git Best Practices](../developer-guide/git-workflow.md)** - Git workflow

---

## Additional Resources

- **Git Hooks Documentation**: https://git-scm.com/docs/githooks
- **Pre-Commit Framework**: https://pre-commit.com/ (alternative approach)
- **ShellCheck**: https://www.shellcheck.net/
- **ESLint**: https://eslint.org/

---

**Version History**:
- v4.0.0 (2026-02-08): Initial pre-commit hooks guide
- v3.0.0 (2026-01-15): Pre-commit hooks feature introduced
