# Workflow Cookbook - Practical Recipes and Patterns

**Version**: v4.0.0  
**Last Updated**: 2026-02-08

This cookbook provides practical, copy-paste ready recipes for common workflow automation scenarios. Each recipe includes context, step-by-step instructions, and expected outcomes.

## Table of Contents

- [Quick Start Recipes](#quick-start-recipes)
- [Development Workflows](#development-workflows)
- [Documentation Workflows](#documentation-workflows)
- [Testing Workflows](#testing-workflows)
- [Quality Assurance Workflows](#quality-assurance-workflows)
- [CI/CD Integration](#cicd-integration)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting Recipes](#troubleshooting-recipes)
- [Advanced Patterns](#advanced-patterns)
- [Custom Workflows](#custom-workflows)

---

## Quick Start Recipes

### Recipe 1: First-Time Setup

**When**: Setting up AI Workflow Automation on a new project  
**Time**: ~5 minutes  
**Prerequisites**: Bash 4.0+, Git, Node.js 16+

**Steps**:

```bash
# 1. Clone the workflow automation repository
cd ~/projects
git clone https://github.com/mpbarbosa/ai_workflow.git

# 2. Navigate to your project
cd /path/to/your/project

# 3. Run health check to verify prerequisites
~/projects/ai_workflow/src/workflow/lib/health_check.sh

# 4. Initialize project configuration (interactive wizard)
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config

# 5. Run your first workflow (dry-run mode for safety)
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --dry-run

# 6. Review what would happen, then run for real
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

**Expected Output**:
- `.workflow-config.yaml` created in your project root
- Pre-flight checks pass
- Dry-run shows workflow plan
- First real run completes successfully (~23 minutes baseline)

**Next Steps**:
- Review generated reports in `src/workflow/backlog/workflow_TIMESTAMP/`
- Check git diff to see what was changed
- Commit the workflow artifacts

---

### Recipe 2: Running on Different Project

**When**: You want to run workflow on a different project  
**Time**: ~23 minutes (baseline)  
**Prerequisites**: Workflow already set up

**Option A: Using --target flag (Recommended)**

```bash
# From workflow directory
cd ~/projects/ai_workflow

# Run on target project
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/target/project

# With optimizations
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/target/project \
  --smart-execution \
  --parallel
```

**Option B: Change directory**

```bash
# Navigate to target project
cd /path/to/target/project

# Run workflow from there
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel
```

**Key Difference**:
- `--target`: Artifacts stored in target project's `.ai_workflow/` directory
- No `--target`: Artifacts stored in current directory's `src/workflow/` subdirectory

---

### Recipe 3: Quick Documentation Update

**When**: You just updated README or docs/ and want quick validation  
**Time**: ~3-4 minutes  
**Template**: `templates/workflows/docs-only.sh`

**Steps**:

```bash
# Using pre-configured template
cd ~/projects/ai_workflow
./templates/workflows/docs-only.sh

# Or manual command (v4.0.0: use step names)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps pre_analysis,documentation_updates,consistency_analysis,directory_validation,markdown_linting \
  --smart-execution \
  --parallel \
  --auto-commit

# Legacy numeric syntax also supported
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,4,12 \
  --smart-execution \
  --parallel \
  --auto-commit
```

**What it does**:
- pre_analysis (Step 0): Tech stack detection, git state
- documentation_updates (Step 1): AI review
- consistency_analysis (Step 2): Cross-references
- directory_validation (Step 4): Structure validation
- markdown_linting (Step 12): Markdown quality

**Skips**:
- Testing (Steps 5-7)
- Dependencies (Step 8)
- Code quality (Step 9)
- Context analysis (Step 10)
- Git finalization (Step 11) - using --auto-commit instead

**Expected Duration**: 3-4 minutes (85% faster than full workflow)

---

## Development Workflows

### Recipe 4: Feature Development Flow

**When**: Developing a new feature with code, tests, and docs  
**Time**: ~15-20 minutes  
**Template**: `templates/workflows/feature.sh`

**Full Flow**:

```bash
# 1. Start feature development
git checkout -b feature/user-authentication

# 2. Write your code
# ... make changes to src/ ...

# 3. Write tests
# ... add tests in tests/ ...

# 4. Update documentation
# ... update README.md, docs/ ...

# 5. Run full workflow
~/projects/ai_workflow/templates/workflows/feature.sh

# Or with manual options
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto-commit

# 6. Review AI recommendations
cat src/workflow/backlog/workflow_*/step_*_*.md

# 7. Push to remote
git push origin feature/user-authentication

# 8. Create pull request
gh pr create --title "Feature: User authentication" --body "..."
```

**What it validates**:
- ✅ Documentation complete and consistent
- ✅ Tests exist and pass
- ✅ Code quality meets standards
- ✅ Dependencies are up-to-date
- ✅ No broken references or links

**Artifacts Created**:
- Execution reports (15 step reports in backlog/)
- Test results (pass/fail/coverage)
- Code quality report
- Dependency analysis
- Git commit with comprehensive message

---

### Recipe 5: Bug Fix Workflow

**When**: Fixing a bug with test and documentation  
**Time**: ~10-14 minutes

**Steps**:

```bash
# 1. Start bug fix branch
git checkout -b fix/login-validation-bug

# 2. Fix the bug
vim src/auth/login.js

# 3. Add/update tests
vim tests/auth/login.test.js

# 4. Update changelog
vim CHANGELOG.md

# 5. Run focused workflow (no test generation needed)
# v4.0.0: Use descriptive step names
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps pre_analysis,documentation_updates,consistency_analysis,test_review,test_execution,code_quality_validation,git_finalization \
  --auto

# Legacy numeric syntax
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,5,7,9,11 \
  --auto

# Steps explained:
# pre_analysis (0): Pre-analysis
# documentation_updates (1): Documentation updates (CHANGELOG)
# consistency_analysis (2): Consistency check
# test_review (5): Test review (validate existing tests)
# test_execution (7): Test execution (run all tests)
# code_quality_validation (9): Code quality check
# git_finalization (11): Git finalization

# 6. Verify tests pass
npm test

# 7. Commit and push
git push origin fix/login-validation-bug
```

**Pro Tip**: Skip Step 6 (test generation) for bug fixes since you're modifying existing tests, not creating new ones.

---

### Recipe 6: Refactoring Workflow

**When**: Refactoring code without changing functionality  
**Time**: ~18-20 minutes

**Steps**:

```bash
# 1. Create refactoring branch
git checkout -b refactor/user-service-simplify

# 2. Refactor code
# ... restructure code ...

# 3. Run workflow with heavy quality focus
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,5,7,9,10,11 \
  --smart-execution

# Steps explained:
# 0: Pre-analysis
# 5: Test review (ensure tests still valid)
# 7: Test execution (verify no regressions)
# 9: Code quality (validate improved structure)
# 10: Context analysis (architectural consistency)
# 11: Git finalization

# 4. Verify no test failures
cat src/workflow/backlog/workflow_*/step_07_test_execution.md

# 5. Review code quality improvements
cat src/workflow/backlog/workflow_*/step_09_code_quality.md

# 6. Commit with detailed message
# Git commit message auto-generated in Step 11
```

**Key Focus**: Steps 7 (test execution) and 9 (code quality) are critical for refactoring validation.

---

## Documentation Workflows

### Recipe 7: API Documentation Update

**When**: Updated API endpoints and need to update documentation  
**Time**: ~5-6 minutes

**Steps**:

```bash
# 1. Update API code
vim src/api/v2/users.js

# 2. Update API documentation
vim docs/api/users.md

# 3. Run documentation-focused workflow
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,3,12 \
  --parallel

# Steps:
# 0: Pre-analysis
# 1: Documentation updates
# 2: Consistency validation
# 3: Script reference validation (API examples)
# 12: Markdown linting

# 4. Review AI suggestions
cat src/workflow/backlog/workflow_*/step_01_documentation_analysis.md

# 5. Check for broken API examples
cat src/workflow/backlog/workflow_*/step_03_script_validation.md

# 6. Manual commit (review changes first)
git add docs/api/users.md
git commit -m "docs(api): update users endpoint documentation"
```

**AI Review Focus**: Documentation specialist persona checks for:
- API examples accuracy
- Parameter documentation completeness
- Response format documentation
- Error cases documented

---

### Recipe 8: README Enhancement

**When**: Major README.md overhaul  
**Time**: ~4-5 minutes

**Steps**:

```bash
# 1. Update README
vim README.md

# 2. Run docs-only with AI review
~/projects/ai_workflow/templates/workflows/docs-only.sh --ai-batch

# With AI batch mode, the workflow:
# - Uses AI for comprehensive documentation review
# - Auto-generates commit message
# - No manual intervention needed

# 3. Review AI recommendations
cat src/workflow/backlog/workflow_*/step_01_documentation_analysis.md

# Expected AI feedback:
# - Structure suggestions (headings, sections)
# - Missing sections (installation, usage, etc.)
# - Broken links or references
# - Code examples validation
# - Writing clarity improvements

# 4. Make recommended improvements
vim README.md

# 5. Re-run to validate
~/projects/ai_workflow/templates/workflows/docs-only.sh --auto-commit
```

**Pro Tip**: Use `--ai-batch` for AI-powered review, then `--auto-commit` for quick finalization.

---

### Recipe 9: Multi-File Documentation Update

**When**: Updated 10+ documentation files across docs/  
**Time**: ~6-8 minutes

**Steps**:

```bash
# 1. Make documentation changes
vim docs/guides/*.md
vim docs/reference/*.md
vim docs/developer-guide/*.md

# 2. Run parallel documentation workflow
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,4,12 \
  --parallel \
  --ai-batch

# Parallel execution benefit:
# Steps 1,2,4,12 run simultaneously for 6-8 min total
# (vs 15-20 min sequential)

# 3. Check consistency across files
cat src/workflow/backlog/workflow_*/step_02_consistency_analysis.md

# Common issues detected:
# - Version mismatches across files
# - Broken cross-references
# - Outdated feature mentions
# - Inconsistent terminology

# 4. Fix issues and re-run
# ... fix detected issues ...
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 2 \
  --auto-commit
```

**Performance**: Parallel mode reduces time from 15-20 min to 6-8 min (60% faster).

---

## Testing Workflows

### Recipe 10: Test Development Workflow

**When**: Writing new tests for existing code  
**Time**: ~8-10 minutes  
**Template**: `templates/workflows/test-only.sh`

**Steps**:

```bash
# 1. Identify untested code
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,5 \
  --auto

# Step 5 output shows:
# - Current test coverage (e.g., 72%)
# - Files with < 80% coverage
# - Untested functions/classes

# 2. Review coverage gaps
cat src/workflow/backlog/workflow_*/step_05_test_review.md

# 3. Generate test recommendations
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 6 \
  --auto

# Step 6 creates test stubs for gaps

# 4. Implement tests
# ... fill in generated test stubs ...

# 5. Run full test workflow
~/projects/ai_workflow/templates/workflows/test-only.sh

# Runs: Steps 0,5,6,7,9
# - 5: Review tests
# - 6: Generate additional tests
# - 7: Execute all tests
# - 9: Code quality check

# 6. Verify coverage improved
npm test -- --coverage
```

**Expected Coverage Improvement**: 10-20% increase per iteration.

---

### Recipe 11: Test Execution with Retry

**When**: Tests are flaky, need to verify stability  
**Time**: ~5-8 minutes per run

**Steps**:

```bash
# 1. Run test execution step
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 7 \
  --auto

# 2. If tests fail, check report
cat src/workflow/backlog/workflow_*/step_07_test_execution.md

# Report shows:
# - Failed test names
# - Error messages
# - Stack traces

# 3. Fix failing tests
vim tests/failing-test.test.js

# 4. Re-run from checkpoint
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --resume-from 7

# Skips Steps 0-6 (already completed)
# Runs only Step 7 and onwards

# 5. Verify all pass
grep -A 10 "Test Results" src/workflow/backlog/workflow_*/step_07_test_execution.md
```

**Pro Tip**: Use `--resume-from` to skip successful steps and only re-run failed ones.

---

### Recipe 12: Integration Test Workflow

**When**: Running slow integration tests separately  
**Time**: Variable (depends on test suite)

**Steps**:

```bash
# 1. Configure test command for integration tests
cat > .workflow-config.yaml << EOF
tech_stack:
  test_framework: jest
  test_command: npm run test:integration
EOF

# 2. Run test workflow
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,7 \
  --auto

# Step 7 uses configured test command
# Runs: npm run test:integration

# 3. Check results
cat src/workflow/backlog/workflow_*/step_07_test_execution.md

# 4. If failures, get AI analysis
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 7 \
  --ai-batch

# AI analyzes:
# - Failure patterns
# - Root cause suggestions
# - Debugging recommendations
```

**Configuration Tip**: Use separate `.workflow-config.yaml` for different test suites (unit vs integration).

---

## Quality Assurance Workflows

### Recipe 13: Pre-Commit Quality Check

**When**: Before committing, ensure quality standards met  
**Time**: ~8-10 minutes

**Steps**:

```bash
# 1. Make changes
git add -A

# 2. Run quality-focused workflow
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,7,8,9,12 \
  --auto

# Steps:
# 0: Pre-analysis (change detection)
# 7: Test execution (all tests must pass)
# 8: Dependency validation (no vulnerabilities)
# 9: Code quality (linting, complexity)
# 12: Markdown linting (documentation)

# 3. Check for any issues
for report in src/workflow/backlog/workflow_*/step_{07,08,09,12}_*.md; do
  echo "=== $(basename $report) ==="
  grep -A 5 "Issues Found\|Errors\|Warnings" "$report" || echo "✅ No issues"
  echo ""
done

# 4. If all clear, commit
git commit -m "Your commit message"

# 5. If issues found, fix them
# ... address issues ...
# Re-run workflow
```

**Fail-Fast**: Stops at first failure, saving time if tests fail early.

---

### Recipe 14: Dependency Audit

**When**: Monthly dependency check or before release  
**Time**: ~3-5 minutes

**Steps**:

```bash
# 1. Run dependency validation
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,8 \
  --auto

# Step 8 checks:
# - Outdated dependencies
# - Security vulnerabilities (npm audit)
# - Version compatibility
# - Unused dependencies

# 2. Review findings
cat src/workflow/backlog/workflow_*/step_08_dependency_analysis.md

# 3. Update dependencies if recommended
npm update

# 4. Re-run to verify
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,8,7 \
  --auto

# Includes Step 7 to verify tests still pass after updates

# 5. Commit updates
git add package.json package-lock.json
git commit -m "chore(deps): update dependencies"
```

**Security Focus**: Step 8 automatically runs `npm audit` if available, catching CVEs early.

---

### Recipe 15: Code Review Prep

**When**: Preparing code for review (pre-PR)  
**Time**: ~15-18 minutes

**Steps**:

```bash
# 1. Ensure branch is up-to-date
git fetch origin
git rebase origin/main

# 2. Run comprehensive quality check
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,7,8,9,10 \
  --ai-batch

# Steps for review prep:
# 1: Documentation complete
# 2: Docs consistent
# 7: All tests pass
# 8: Dependencies clean
# 9: Code quality excellent
# 10: Architecture coherent

# 3. Generate PR description from context analysis
cat src/workflow/backlog/workflow_*/step_10_context_analysis.md

# Use AI summary as PR description template

# 4. Address any AI recommendations
cat src/workflow/backlog/workflow_*/step_09_code_quality.md

# Common AI suggestions:
# - Refactor complex functions
# - Add error handling
# - Improve naming
# - Add comments for complex logic

# 5. Final validation
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --auto-commit

# 6. Create pull request
gh pr create \
  --title "Feature: User authentication" \
  --body-file src/workflow/backlog/workflow_*/step_10_context_analysis.md
```

**Pro Tip**: Use Step 10 (context analysis) output as your PR description - it's AI-generated and comprehensive.

---

## CI/CD Integration

### Recipe 16: GitHub Actions Integration

**When**: Automate workflow in CI/CD pipeline  
**Time**: ~20-25 minutes (CI environment)

**Setup**:

```yaml
# .github/workflows/ai-workflow.yml
name: AI Workflow Automation

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  ai-workflow:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for git analysis
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Checkout AI Workflow
        uses: actions/checkout@v3
        with:
          repository: mpbarbosa/ai_workflow
          path: ai_workflow
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Run AI Workflow
        run: |
          ./ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
            --auto \
            --smart-execution \
            --parallel \
            --no-ai-cache
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: workflow-reports
          path: |
            src/workflow/backlog/
            src/workflow/logs/
            src/workflow/metrics/
      
      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync(
              'src/workflow/backlog/workflow_latest/step_10_context_analysis.md',
              'utf8'
            );
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## AI Workflow Analysis\n\n${summary}`
            });
```

**Key Considerations**:
- Use `--auto` flag (no interactive prompts)
- Use `--no-ai-cache` (fresh environment each run)
- Upload artifacts for debugging
- Comment summary on PRs

---

### Recipe 17: GitLab CI Integration

**When**: Using GitLab for CI/CD  
**Time**: ~20-25 minutes

**Setup**:

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - test
  - quality

ai-workflow:
  stage: validate
  image: node:18
  timeout: 30 minutes
  
  before_script:
    - apt-get update && apt-get install -y git bash
    - npm ci
    - git clone https://github.com/mpbarbosa/ai_workflow.git
  
  script:
    - |
      ./ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
        --auto \
        --smart-execution \
        --parallel
  
  artifacts:
    when: always
    paths:
      - src/workflow/backlog/
      - src/workflow/logs/
      - src/workflow/metrics/
    expire_in: 1 week
  
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

ai-workflow-nightly:
  extends: ai-workflow
  stage: quality
  
  script:
    - |
      ./ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
        --auto \
        --ml-optimize \
        --multi-stage
  
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  
  artifacts:
    reports:
      metrics: src/workflow/metrics/summary.md
```

---

### Recipe 18: Pre-Commit Hook Integration

**When**: Run fast checks before every commit  
**Time**: ~1-2 seconds (v3.0.0)

**Setup**:

```bash
# 1. Install pre-commit hooks
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Creates:
# .git/hooks/pre-commit (fast validation checks)

# 2. Test hooks without committing
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --test-hooks

# 3. Make changes and commit
git add src/api/users.js
git commit -m "feat(api): add user validation"

# Pre-commit hook runs automatically:
# ✓ Check shell scripts syntax
# ✓ Check JSON/YAML syntax
# ✓ Check markdown syntax
# ✓ Verify test infrastructure
# ✓ Check for debug statements
# Total: < 1 second

# 4. If hook fails
# ERROR: Syntax error in src/api/users.js
# Fix the issue and retry commit

# 5. Temporarily skip hooks (emergency)
git commit --no-verify -m "WIP: temporary commit"
```

**Hook Validations** (v3.0.0):
- Syntax validation (shell, JSON, YAML, markdown)
- Test infrastructure check
- Debug statement detection
- Large file detection (> 1MB)
- Executable permission check

---

## Performance Optimization

### Recipe 19: Smart Execution for Docs Changes

**When**: Only documentation changed, need fast validation  
**Time**: ~2-3 minutes (85% faster)

**Steps**:

```bash
# 1. Make doc changes
vim README.md docs/guide.md

# 2. Commit changes
git add README.md docs/guide.md
git commit -m "docs: update user guide"

# 3. Run with smart execution
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel

# Smart execution detects:
# - CHANGE_IMPACT="Low" (docs only)
# - Automatically skips Steps 5-7 (testing)
# - Automatically skips Step 8 (dependencies, no package.json change)

# Runs only:
# ✓ Step 0: Pre-analysis
# ✓ Step 1: Documentation updates
# ✓ Step 2: Consistency check
# ✓ Step 4: Directory structure
# ✓ Step 9: Code quality (lightweight)
# ✓ Step 10-12: Finalization
# ⏭️ Steps 5-8: Skipped

# Total: ~2-3 minutes vs 23 minutes baseline
```

**Performance Gain**: 85% faster (2-3 min vs 23 min).

---

### Recipe 20: ML-Optimized Execution

**When**: You have 10+ historical workflow runs  
**Time**: ~10-11 minutes (52% faster)

**Steps**:

```bash
# 1. Check ML system status
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Output:
# ML Optimization Status: ✅ Ready
# Training runs: 15
# Model accuracy: 87%
# Recommended: Use --ml-optimize

# 2. Run with ML optimization
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --ml-optimize \
  --smart-execution \
  --parallel

# ML predictions:
# - Predicts step durations (±10% accuracy)
# - Recommends step skip/run decisions
# - Optimizes parallel execution order
# - Suggests early termination if low-value

# 3. Review ML predictions
cat src/workflow/metrics/ml_predictions.json

# {
#   "predicted_duration": 630,
#   "actual_duration": 658,
#   "accuracy": 95.7%,
#   "steps_skipped": [5,6,8],
#   "optimization_gain": "52%"
# }
```

**Requirements**: 10+ historical runs for model training  
**Performance Gain**: 15-30% additional improvement over smart+parallel

---

### Recipe 21: Multi-Stage Pipeline

**When**: Want progressive validation (v2.8.0+)  
**Time**: Stage 1: ~5 min, Stage 2: ~10 min, Stage 3: ~23 min

**Steps**:

```bash
# 1. Run with multi-stage enabled
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --smart-execution \
  --parallel

# Execution flow:
# 
# Stage 1: Quick Validation (80% of runs stop here)
# ✓ Step 0: Pre-analysis
# ✓ Step 1: Documentation
# ✓ Step 2: Consistency
# ✓ Step 7: Test execution
# Duration: ~5 minutes
# 
# Decision: Stop or continue?
# If Stage 1 passes and low impact → Stop ✅
# If Stage 1 fails or high impact → Continue to Stage 2
#
# Stage 2: Comprehensive Analysis
# ✓ Steps 3,4,5,6: Validation & test generation
# ✓ Steps 8,9: Dependencies & quality
# Duration: +5 minutes (10 min total)
#
# Decision: Stop or continue?
# If Stage 2 passes → Stop ✅
# If critical issues → Continue to Stage 3
#
# Stage 3: Deep Analysis (rare, <5% of runs)
# ✓ Step 10: Context analysis
# ✓ Step 13: Prompt engineering
# ✓ Step 14: UX analysis
# Duration: +13 minutes (23 min total)

# 2. View pipeline configuration
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --show-pipeline

# 3. Force all stages (override intelligent stopping)
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --manual-trigger
```

**Success Rate**: 80%+ workflows complete in Stage 1 (~5 minutes)

---

## Troubleshooting Recipes

### Recipe 22: Debugging Failed Workflow

**When**: Workflow fails and you need to understand why  
**Time**: ~5-10 minutes investigation

**Steps**:

```bash
# 1. Identify failed step
grep "ERROR\|FAILED" src/workflow/logs/workflow_*/workflow_execution.log

# Output:
# [2026-01-31 02:15:30] [ERROR] Step 5: Test Review - failed

# 2. Check step-specific log
cat src/workflow/logs/workflow_*/step_05_test_review.log

# 3. Check step report
cat src/workflow/backlog/workflow_*/step_05_test_review.md

# 4. Common failure causes and fixes:

# Cause: Test framework not installed
# Fix:
npm install --save-dev jest
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --resume-from 5

# Cause: No tests found
# Fix: Create test directory
mkdir -p tests
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --resume-from 5

# Cause: Copilot CLI not available
# Fix: Skip AI features
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --auto --resume-from 5

# Cause: Git state issues
# Fix: Refresh git cache
git add -A
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --resume-from 5

# 5. Enable verbose mode for detailed debugging
VERBOSE=true ~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --resume-from 5
```

---

### Recipe 23: Recovering from Checkpoint

**When**: Workflow interrupted, need to resume  
**Time**: Depends on where it stopped

**Steps**:

```bash
# 1. Check for checkpoint
ls -la src/workflow/.checkpoints/

# Output:
# workflow_20260131_020000.checkpoint

# 2. View checkpoint details
cat src/workflow/.checkpoints/workflow_20260131_020000.checkpoint

# LAST_COMPLETED_STEP="5"
# WORKFLOW_RUN_ID="workflow_20260131_020000"

# 3. Resume automatically (default behavior)
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Output:
# INFO: Found checkpoint at step 5
# INFO: Resuming from step 6

# 4. Or manually specify resume point
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --resume-from 6

# 5. Force fresh start (ignore checkpoint)
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --no-resume

# 6. After successful completion
# Checkpoint is automatically deleted
```

**Auto-Resume**: By default, workflow automatically detects and resumes from checkpoints.

---

### Recipe 24: Clearing Caches

**When**: Caches corrupted or outdated data  
**Time**: < 1 minute

**Steps**:

```bash
# 1. Clear AI response cache
rm -rf src/workflow/.ai_cache/*

# 2. Clear analysis cache
rm -rf src/workflow/.analysis_cache/*

# 3. Clear checkpoints
rm -rf src/workflow/.checkpoints/*

# 4. Clear metrics (caution: loses history)
rm -rf src/workflow/metrics/*

# 5. Clear all workflow artifacts (nuclear option)
rm -rf src/workflow/{backlog,logs,summaries,metrics}/*
rm -rf src/workflow/.{ai_cache,analysis_cache,checkpoints}/*

# 6. Run workflow fresh
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# 7. Selective cache clear (recommended)
# Clear only AI cache for specific persona
rm -f src/workflow/.ai_cache/*documentation_specialist*.txt

# Clear only old logs (keep latest 5)
cd src/workflow/logs
ls -t | tail -n +6 | xargs rm -rf
```

**Best Practice**: Clear caches monthly or when behavior seems stale.

---

### Recipe 25: Fixing Merge Conflicts in Artifacts

**When**: Multiple team members running workflow, artifacts conflict  
**Time**: ~2-3 minutes

**Steps**:

```bash
# 1. Pull latest changes
git pull origin main

# Conflict in:
# src/workflow/backlog/workflow_20260131_020000/step_01_documentation_analysis.md

# 2. Strategy: Accept remote artifacts (they're regenerated)
git checkout --theirs src/workflow/backlog/
git checkout --theirs src/workflow/logs/
git checkout --theirs src/workflow/metrics/

# 3. Re-run workflow to regenerate fresh artifacts
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --auto-commit

# 4. Alternative: Ignore workflow artifacts in .gitignore
cat >> .gitignore << EOF
# AI Workflow artifacts (regenerated)
src/workflow/backlog/
src/workflow/logs/
src/workflow/summaries/
src/workflow/.ai_cache/
src/workflow/.checkpoints/
EOF

git add .gitignore
git commit -m "chore: ignore workflow artifacts"
```

**Recommendation**: Add workflow artifacts to `.gitignore` for multi-developer teams.

---

## Advanced Patterns

### Recipe 26: Custom Step Selection

**When**: Need specific validation workflow  
**Time**: Variable

**Pattern**: Quality-Only Check

```bash
# Run only quality-related steps
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,8,9,10 \
  --auto

# Steps:
# 0: Pre-analysis (required)
# 8: Dependencies
# 9: Code quality
# 10: Context analysis
```

**Pattern**: Documentation + Tests Only

```bash
# Run docs and tests, skip code quality
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,5,6,7,12 \
  --parallel
```

**Pattern**: Git Finalization Only

```bash
# Skip all analysis, just commit changes
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 11 \
  --auto
```

**Pattern**: Pre-Commit Validation

```bash
# Fast validation before commit
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,7,9 \
  --auto

# Takes ~5 minutes:
# - Pre-analysis (change detection)
# - Test execution (all tests must pass)
# - Code quality (linting)
```

---

### Recipe 27: Environment-Specific Configuration

**When**: Different workflows for dev/staging/prod  
**Time**: Setup once, use indefinitely

**Setup**:

```bash
# 1. Create environment-specific configs
cat > .workflow-config.dev.yaml << EOF
project:
  kind: nodejs_api
workflow:
  skip_steps: [8, 13, 14]  # Skip dependencies, prompt eng, UX
tech_stack:
  test_command: npm run test:unit
EOF

cat > .workflow-config.staging.yaml << EOF
project:
  kind: nodejs_api
workflow:
  skip_steps: [13, 14]  # Skip prompt eng, UX only
tech_stack:
  test_command: npm run test:integration
EOF

cat > .workflow-config.prod.yaml << EOF
project:
  kind: nodejs_api
workflow:
  skip_steps: [6, 13, 14]  # Skip test generation
tech_stack:
  test_command: npm run test:all
EOF

# 2. Use environment-specific config
ENV=dev
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --config-file .workflow-config.$ENV.yaml

# 3. Or set via environment variable
export WORKFLOW_CONFIG=.workflow-config.staging.yaml
~/projects/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

---

### Recipe 28: Batch Processing Multiple Projects

**When**: Managing multiple projects with same workflow  
**Time**: ~25 minutes per project

**Script**:

```bash
#!/bin/bash
# batch-workflow.sh

WORKFLOW_HOME=~/projects/ai_workflow
PROJECTS=(
  ~/projects/api-gateway
  ~/projects/user-service
  ~/projects/payment-service
  ~/projects/notification-service
)

for project in "${PROJECTS[@]}"; do
  echo "=========================================="
  echo "Processing: $project"
  echo "=========================================="
  
  cd "$project"
  
  # Run workflow on each project
  $WORKFLOW_HOME/src/workflow/execute_tests_docs_workflow.sh \
    --smart-execution \
    --parallel \
    --auto-commit \
    --target "$project"
  
  # Check exit code
  if [[ $? -eq 0 ]]; then
    echo "✅ $project: Success"
  else
    echo "❌ $project: Failed"
  fi
  
  echo ""
done

echo "Batch processing complete"
```

**Usage**:

```bash
chmod +x batch-workflow.sh
./batch-workflow.sh
```

---

### Recipe 29: Conditional Workflow Based on Branch

**When**: Different workflows for feature branches vs main  
**Time**: Variable

**Script**:

```bash
#!/bin/bash
# smart-workflow.sh

WORKFLOW_HOME=~/projects/ai_workflow
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" == "main" ]]; then
  echo "📦 Main branch: Full workflow with all validations"
  
  $WORKFLOW_HOME/src/workflow/execute_tests_docs_workflow.sh \
    --ml-optimize \
    --multi-stage \
    --parallel \
    --auto-commit

elif [[ "$CURRENT_BRANCH" == feature/* ]]; then
  echo "🚀 Feature branch: Development workflow"
  
  $WORKFLOW_HOME/templates/workflows/feature.sh --auto

elif [[ "$CURRENT_BRANCH" == fix/* ]]; then
  echo "🐛 Fix branch: Test-focused workflow"
  
  $WORKFLOW_HOME/src/workflow/execute_tests_docs_workflow.sh \
    --steps 0,5,7,9,11 \
    --auto

elif [[ "$CURRENT_BRANCH" == docs/* ]]; then
  echo "📝 Docs branch: Documentation workflow"
  
  $WORKFLOW_HOME/templates/workflows/docs-only.sh --auto

else
  echo "🔧 Other branch: Basic validation"
  
  $WORKFLOW_HOME/src/workflow/execute_tests_docs_workflow.sh \
    --steps 0,7,9 \
    --auto
fi
```

---

## Custom Workflows

### Recipe 30: Creating Custom Workflow Template

**When**: Need reusable workflow for specific use case  
**Time**: 10 minutes to create, instant to use

**Steps**:

```bash
# 1. Create template directory
mkdir -p ~/my-workflows

# 2. Create custom workflow
cat > ~/my-workflows/api-development.sh << 'EOF'
#!/bin/bash
# API Development Workflow
# Purpose: Validate API changes with focus on tests and docs
set -euo pipefail

WORKFLOW_HOME=~/projects/ai_workflow

echo "🔌 API Development Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Focus: API docs, integration tests, code quality"
echo "Duration: ~12-15 minutes"
echo ""

"${WORKFLOW_HOME}/src/workflow/execute_tests_docs_workflow.sh" \
    --steps 0,1,3,5,7,9,11 \
    --smart-execution \
    --auto-commit \
    "$@"

# Steps explained:
# 0: Pre-analysis
# 1: Documentation (API docs)
# 3: Script validation (API examples)
# 5: Test review
# 7: Test execution (integration tests)
# 9: Code quality
# 11: Git finalization
EOF

chmod +x ~/my-workflows/api-development.sh

# 3. Use custom workflow
cd ~/projects/my-api
~/my-workflows/api-development.sh

# 4. Create more templates
cat > ~/my-workflows/hotfix.sh << 'EOF'
#!/bin/bash
# Hotfix Workflow - Fast validation for emergency fixes
set -euo pipefail

WORKFLOW_HOME=~/projects/ai_workflow

echo "🚨 Hotfix Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Focus: Tests + immediate commit"
echo "Duration: ~5 minutes"
echo ""

"${WORKFLOW_HOME}/src/workflow/execute_tests_docs_workflow.sh" \
    --steps 0,7,11 \
    --auto \
    "$@"
EOF

chmod +x ~/my-workflows/hotfix.sh
```

---

## Best Practices Summary

### DO's ✅

1. **Use Smart Execution** for faster iterations (`--smart-execution`)
2. **Enable Parallel Execution** when possible (`--parallel`)
3. **Use Templates** for common workflows (`templates/workflows/*.sh`)
4. **Review AI Recommendations** in backlog reports
5. **Commit Workflow Artifacts** or add to `.gitignore`
6. **Use Checkpoints** to resume after failures
7. **Monitor Metrics** to identify performance bottlenecks
8. **Configure Project Kind** in `.workflow-config.yaml` for better AI context
9. **Use `--target` Flag** when running on different projects
10. **Enable Auto-Commit** for non-interactive workflows (`--auto-commit`)

### DON'Ts ❌

1. **Don't Skip Tests** in production workflows
2. **Don't Ignore AI Recommendations** without review
3. **Don't Run Full Workflow** for docs-only changes (use smart execution)
4. **Don't Commit Without Review** (unless using --auto-commit intentionally)
5. **Don't Mix Manual and Auto Modes** (causes confusion)
6. **Don't Delete Metrics** without backup (loses optimization data)
7. **Don't Run Without Pre-Flight** checks (`--no-preflight` not recommended)
8. **Don't Use Outdated Checkpoints** (clear if > 24 hours old)
9. **Don't Ignore Test Failures** (fix immediately, not "later")
10. **Don't Run on Dirty Working Directory** without committing or stashing

---

## Related Documentation

- **Step Modules API**: `docs/reference/API_STEP_MODULES.md`
- **Orchestrators API**: `docs/reference/API_ORCHESTRATORS.md`
- **Data Flow**: `docs/reference/DATA_FLOW.md`
- **CLI Options**: `docs/reference/cli-options.md`
- **Troubleshooting**: `docs/guides/TROUBLESHOOTING.md`
- **Quick Start**: `docs/user-guide/quick-start.md`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`

---

**Document Version**: 1.0.0  
**Workflow Version: v4.0.0  
**Last Updated**: 2026-01-31
