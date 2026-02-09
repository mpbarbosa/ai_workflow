# Workflow Templates

Pre-configured workflow templates for common development scenarios.

## Available Templates

### 1. Documentation-Only Workflow

**File**: `docs-only.sh`  
**Steps**: 0, 1, 2, 4, 12  
**Duration**: ~3-4 minutes  
**Use Case**: Documentation updates, README changes, guide improvements

```bash
./templates/workflows/docs-only.sh
```

**What it does**:
- Pre-analyzes changes
- Updates documentation
- Checks consistency
- Validates directory structure
- Lints markdown files

### 2. Test-Only Workflow

**File**: `test-only.sh`  
**Steps**: 0, 5, 6, 7, 9  
**Duration**: ~8-10 minutes  
**Use Case**: Test development, test fixes, adding test coverage

```bash
./templates/workflows/test-only.sh
```

**What it does**:
- Pre-analyzes changes
- Reviews existing tests
- Generates new tests
- Executes test suite
- Validates code quality

### 3. Feature Development Workflow

**File**: `feature.sh`  
**Steps**: All steps  
**Duration**: ~15-20 minutes  
**Use Case**: Feature development, major changes, releases

```bash
./templates/workflows/feature.sh
```

**What it does**:
- Full documentation validation
- Complete test suite
- Code quality checks
- Dependency validation
- Git finalization

## Features

All templates include:
- ✅ **Smart Execution** - Automatically skips unnecessary steps
- ✅ **Parallel Processing** - Runs independent steps simultaneously
- ✅ **Auto-commit** - Automatically commits workflow artifacts
- ✅ **Performance Optimized** - Uses all v2.6.0 optimizations

## Usage

### Basic Usage

```bash
# Run template directly
./templates/workflows/docs-only.sh

# Pass additional arguments
./templates/workflows/test-only.sh --verbose

# Disable auto-commit
./templates/workflows/feature.sh --no-auto-commit
```

### Advanced Usage

#### Development Workflows

```bash
# Quick docs check before committing
./templates/workflows/docs-only.sh --dry-run

# Test-driven development cycle
./templates/workflows/test-only.sh --steps test_generation,test_execution

# Pre-release validation
./templates/workflows/feature.sh --no-resume --ml-optimize
```

#### Team Collaboration

```bash
# Review documentation before PR
git checkout feature-branch
./templates/workflows/docs-only.sh
git push

# Validate tests in CI/CD
./templates/workflows/test-only.sh --no-auto-commit

# Release preparation
./templates/workflows/feature.sh --generate-docs --update-changelog
```

#### Integration with Other Tools

```bash
# Run after code generation
copilot suggest --code | tee new-feature.sh
./templates/workflows/feature.sh

# Combine with git hooks
# In .git/hooks/pre-push:
./templates/workflows/docs-only.sh --dry-run

# Integration with make
# In Makefile:
docs:
    ./templates/workflows/docs-only.sh
```

### Real-World Use Cases

#### Use Case 1: Documentation Sprint

**Scenario**: Updating all documentation for a new release

```bash
# Day 1: Initial documentation updates
./templates/workflows/docs-only.sh

# Day 2: Review and iterate
./templates/workflows/docs-only.sh --steps documentation_updates,consistency_analysis

# Day 3: Final validation
./templates/workflows/feature.sh --steps documentation_optimization,markdown_linting
```

**Expected time**: 3-4 min per iteration

#### Use Case 2: Test Coverage Improvement

**Scenario**: Increasing test coverage from 60% to 80%

```bash
# Step 1: Generate missing tests
./templates/workflows/test-only.sh --steps test_generation

# Step 2: Review and execute new tests
./templates/workflows/test-only.sh --steps test_execution

# Step 3: Validate quality gates
./templates/workflows/feature.sh --steps test_execution,code_quality_validation
```

**Expected time**: 8-10 min per iteration

#### Use Case 3: Feature Branch Development

**Scenario**: Developing a new feature with full validation

```bash
# Create feature branch
git checkout -b feature/new-feature

# Initial implementation
# ... make code changes ...

# Full validation cycle
./templates/workflows/feature.sh

# Review and commit
git add -A
git commit -m "feat: implement new feature"
git push origin feature/new-feature
```

**Expected time**: 15-20 min

#### Use Case 4: Hotfix Process

**Scenario**: Quick bug fix with minimal validation

```bash
# Create hotfix branch
git checkout -b hotfix/critical-bug

# Fix the bug
# ... make changes ...

# Quick validation (docs + tests only)
./templates/workflows/docs-only.sh
./templates/workflows/test-only.sh

# Or use custom steps
./src/workflow/execute_tests_docs_workflow.sh \
  --steps test_execution,code_quality_validation \
  --smart-execution

# Commit and deploy
git add -A
git commit -m "fix: critical bug in validation"
```

**Expected time**: 5-8 min

### VS Code Integration

Templates are integrated with VS Code tasks:

1. Press `Ctrl+Shift+P` (Cmd+Shift+P on Mac)
2. Type "Tasks: Run Task"
3. Select a workflow template

Or use keyboard shortcuts:
- `Ctrl+Shift+B` - Run default task (Full Run)

## Customization

### Create Custom Template

```bash
cp templates/workflows/docs-only.sh templates/workflows/my-custom.sh
# Edit to customize steps and options
chmod +x templates/workflows/my-custom.sh
```

### Template Structure

```bash
#!/bin/bash
set -euo pipefail

# Locate workflow
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Run workflow with custom options
"${WORKFLOW_ROOT}/src/workflow/execute_tests_docs_workflow.sh" \
    --steps X,Y,Z \
    --smart-execution \
    --parallel \
    --auto-commit \
    "$@"
```

## IDE Integration

### VS Code

Templates are pre-configured in `.vscode/tasks.json`:
- AI Workflow: Documentation Only
- AI Workflow: Test Only
- AI Workflow: Feature Development
- AI Workflow: Auto-commit
- AI Workflow: Metrics Dashboard

### JetBrains IDEs (IntelliJ, WebStorm, etc.)

Create External Tools:
1. Settings → Tools → External Tools
2. Add new tool
3. Program: `$ProjectFileDir$/templates/workflows/docs-only.sh`
4. Working directory: `$ProjectFileDir$`

### Vim/Neovim

Add to your `.vimrc` or `init.vim`:

```vim
" AI Workflow commands
command! WorkflowDocs :!./templates/workflows/docs-only.sh
command! WorkflowTests :!./templates/workflows/test-only.sh
command! WorkflowFull :!./templates/workflows/feature.sh
```

## Performance Expectations

### Execution Times

| Template | Steps | Baseline | With Smart Execution | Improvement |
|----------|-------|----------|---------------------|-------------|
| docs-only | 5 | 3-4 min | 2-3 min | 33-40% faster |
| test-only | 5 | 8-10 min | 6-8 min | 25-30% faster |
| feature | 23 | 15-20 min | 10-15 min | 33-40% faster |

### Performance by Change Type

| Template | Docs Only | Code Only | Mixed Changes |
|----------|-----------|-----------|---------------|
| docs-only | 2.3 min ✅ | N/A | 3.5 min |
| test-only | N/A | 6 min ✅ | 8 min |
| feature | 10 min | 14 min | 15.5 min ✅ |

**Legend**:
- ✅ = Optimal use case
- Smart execution automatically detects change types
- All times include parallel processing

## Auto-commit Behavior

All templates enable auto-commit by default. Committed artifacts include:
- Documentation files (`docs/**/*.md`)
- README files
- Test files (`tests/**/*.sh`)
- Source files (`src/**/*.sh`)
- Configuration files

**Excluded from auto-commit**:
- Log files (`.log`)
- Temporary files (`.tmp`)
- Backlog files (`.ai_workflow/backlog/**`)
- Node modules
- Coverage reports

## Troubleshooting

### Common Issues

#### Template Not Found

```bash
# Ensure templates are executable
chmod +x templates/workflows/*.sh

# Run from project root
cd /path/to/ai_workflow
./templates/workflows/docs-only.sh
```

#### Auto-commit Not Working

```bash
# Check git status
git status

# Verify you're in a git repository
git rev-parse --git-dir

# Disable auto-commit if needed
./templates/workflows/docs-only.sh --no-auto-commit
```

#### Wrong Steps Executed

Templates use fixed step configurations. To customize:

```bash
# Run workflow directly with custom steps
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2
```

#### Performance Issues

```bash
# Check system resources
top

# Disable parallel processing if needed
./templates/workflows/feature.sh --no-parallel

# Clear AI cache to free memory
rm -rf src/workflow/.ai_cache/
```

#### CI/CD Integration Issues

See the CI/CD Integration section below for platform-specific troubleshooting.

## CI/CD Integration

### GitHub Actions

```yaml
name: AI Workflow - Documentation

on:
  push:
    paths:
      - 'docs/**'
      - '**.md'
  pull_request:
    paths:
      - 'docs/**'
      - '**.md'

jobs:
  docs-workflow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run docs-only workflow
        run: |
          cd /path/to/ai_workflow
          ./templates/workflows/docs-only.sh
      - name: Commit changes
        run: |
          git config user.name "AI Workflow Bot"
          git config user.email "bot@example.com"
          git add -A
          git commit -m "docs: AI workflow updates" || true
```

### GitLab CI

```yaml
workflow:docs:
  stage: validate
  only:
    changes:
      - docs/**
      - "**.md"
  script:
    - cd /path/to/ai_workflow
    - ./templates/workflows/docs-only.sh
  artifacts:
    paths:
      - docs/
    expire_in: 1 week
```

### Jenkins

```groovy
pipeline {
    agent any
    
    stages {
        stage('Documentation Workflow') {
            when {
                changeset "docs/**"
            }
            steps {
                sh './templates/workflows/docs-only.sh'
            }
        }
        
        stage('Test Workflow') {
            when {
                changeset "tests/**"
            }
            steps {
                sh './templates/workflows/test-only.sh'
            }
        }
        
        stage('Full Workflow') {
            when {
                branch 'main'
            }
            steps {
                sh './templates/workflows/feature.sh'
            }
        }
    }
}
```

### Docker Integration

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    jq \
    nodejs \
    npm

# Copy AI workflow
COPY . /app/ai_workflow
WORKDIR /app/ai_workflow

# Run workflow template
CMD ["./templates/workflows/feature.sh"]
```

### Travis CI

```yaml
language: bash

script:
  - ./templates/workflows/feature.sh

jobs:
  include:
    - name: "Documentation"
      if: type = pull_request
      script: ./templates/workflows/docs-only.sh
    - name: "Tests"
      if: branch = develop
      script: ./templates/workflows/test-only.sh
```

### Best Practices for CI/CD

1. **Use appropriate templates**:
   - docs-only for documentation PRs
   - test-only for test changes
   - feature for releases

2. **Cache workflow artifacts**:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: |
         src/workflow/.ai_cache/
         src/workflow/metrics/
       key: workflow-${{ hashFiles('src/**/*.sh') }}
   ```

3. **Set timeouts**:
   ```yaml
   timeout-minutes: 30  # feature.sh max time
   ```

4. **Use conditional execution**:
   - Only run on relevant file changes
   - Skip in draft PRs
   - Run full workflow on main/master only

5. **Monitor performance**:
   ```bash
   # Save metrics for analysis
   cp src/workflow/metrics/current_run.json artifacts/
   ```

## See Also

- Main Workflow: `src/workflow/execute_tests_docs_workflow.sh`
- Usage Patterns: `CONTRIBUTING.md` (Workflow Usage Patterns section)
- VS Code Tasks: `.vscode/tasks.json`
- Auto-commit Module: `src/workflow/lib/auto_commit.sh`

---

**Version**: v2.6.0  
**Created**: 2025-12-24  
**Part of**: AI Workflow Automation - Developer Experience Enhancements
