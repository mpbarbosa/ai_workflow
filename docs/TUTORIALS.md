# AI Workflow Automation - Tutorials

**Version**: v3.1.0  
**Hands-on tutorials** for real-world scenarios

---

## 📚 Table of Contents

1. [Tutorial 1: First-Time Setup](#tutorial-1-first-time-setup)
2. [Tutorial 2: Running Your First Workflow](#tutorial-2-running-your-first-workflow)
3. [Tutorial 3: Optimizing for Speed](#tutorial-3-optimizing-for-speed)
4. [Tutorial 4: Documentation-Only Workflow](#tutorial-4-documentation-only-workflow)
5. [Tutorial 5: Test Development Workflow](#tutorial-5-test-development-workflow)
6. [Tutorial 6: CI/CD Integration](#tutorial-6-cicd-integration)
7. [Tutorial 7: Using Pre-Commit Hooks](#tutorial-7-using-pre-commit-hooks)
8. [Tutorial 8: ML Optimization Setup](#tutorial-8-ml-optimization-setup)
9. [Tutorial 9: Custom Configuration](#tutorial-9-custom-configuration)
10. [Tutorial 10: Troubleshooting Common Issues](#tutorial-10-troubleshooting-common-issues)

---

## Tutorial 1: First-Time Setup

**Goal**: Install and verify the workflow system  
**Time**: 5 minutes  
**Prerequisites**: Bash 4.0+, Git, Node.js 25.2.1+

### Step 1: Clone the Repository

```bash
# Clone from GitHub
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Or clone via HTTPS
git clone https://github.com/mpbarbosa/ai_workflow.git
cd ai_workflow
```

### Step 2: Verify Prerequisites

```bash
# Check Bash version (need 4.0+)
bash --version

# Check Git
git --version

# Check Node.js
node --version

# Check GitHub Copilot CLI (required for AI features)
gh copilot --version
```

**If Copilot CLI is missing:**
```bash
# Install GitHub CLI
brew install gh  # macOS
# or
sudo apt install gh  # Linux

# Install Copilot extension
gh extension install github/gh-copilot
```

### Step 3: Run Health Check

```bash
# Comprehensive system validation
./src/workflow/lib/health_check.sh

# Expected output:
# ✅ Bash version: 5.x.x
# ✅ Git available
# ✅ Node.js available
# ✅ GitHub Copilot CLI available
# ✅ All dependencies satisfied
```

### Step 4: Run Initial Tests

```bash
# Run all test suites
./tests/run_all_tests.sh

# Or run specific test categories
./tests/run_all_tests.sh --unit         # Unit tests
./tests/run_all_tests.sh --integration  # Integration tests
```

### Step 5: Test on Sample Project

```bash
# Self-test: Run workflow on itself
./src/workflow/execute_tests_docs_workflow.sh \
  --dry-run \
  --verbose

# Review what would happen without making changes
```

### ✅ Success Criteria
- All health checks pass
- Tests run successfully
- Dry run completes without errors

---

## Tutorial 2: Running Your First Workflow

**Goal**: Execute a complete workflow on a project  
**Time**: 25 minutes (baseline), 3-5 minutes (optimized)  
**Prerequisites**: Completed Tutorial 1

### Scenario: Validating Documentation

You have a project with documentation that needs validation.

### Step 1: Prepare Your Project

```bash
# Navigate to your project
cd /path/to/your/project

# Ensure it's a git repository
git init  # if not already initialized
git add .
git commit -m "Initial commit"
```

### Step 2: Run Basic Workflow

```bash
# Standard execution with prompts
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# The workflow will:
# 1. Analyze your project structure
# 2. Detect technology stack
# 3. Validate documentation
# 4. Check code quality
# 5. Verify tests
# 6. Generate reports
```

### Step 3: Review Results

```bash
# Check execution logs
ls -la /path/to/ai_workflow/src/workflow/logs/

# View latest report
cat /path/to/ai_workflow/src/workflow/backlog/workflow_*/step*_*.md

# Check metrics
cat /path/to/ai_workflow/src/workflow/metrics/current_run.json
```

### Step 4: Run Optimized

```bash
# Much faster on subsequent runs
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Typical performance:
# First run: 23 minutes (baseline)
# Second run (no changes): 2-3 minutes (85-90% faster)
```

### ✅ Success Criteria
- Workflow completes all steps
- Reports generated in backlog/
- Metrics collected
- No critical errors

---

## Tutorial 3: Optimizing for Speed

**Goal**: Achieve maximum performance (70-93% faster)  
**Time**: 30 minutes setup, then permanent benefits  
**Prerequisites**: Completed Tutorial 2

### Strategy: Multi-Level Optimization

#### Level 1: Smart Execution (40-85% faster)

```bash
# Analyzes changes and skips unnecessary steps
./execute_tests_docs_workflow.sh --smart-execution

# Example: Only docs changed
# Skips: Code quality checks, test generation, UX analysis
# Runs: Documentation validation, finalization
```

**When to use**: Incremental changes to specific areas

#### Level 2: Parallel Execution (33% faster)

```bash
# Runs independent steps simultaneously
./execute_tests_docs_workflow.sh --parallel

# Steps run in parallel:
# - Documentation analysis + Code quality
# - Test validation + UX analysis
# - Multiple AI personas concurrently
```

**When to use**: Multi-core systems with adequate memory

#### Level 3: Combined Smart + Parallel (57-90% faster)

```bash
# Best of both worlds
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Example results:
# Documentation only: 23 min → 2.3 min (90% faster)
# Code changes: 23 min → 10 min (57% faster)
```

**When to use**: Always (recommended default)

#### Level 4: ML Optimization (70-93% faster)

```bash
# Requires 10+ historical runs for training
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --auto

# Check ML system status
./execute_tests_docs_workflow.sh --show-ml-status

# Expected output:
# ✅ ML models available
# ✅ Sufficient training data (15 runs)
# ✅ Predictions enabled
# Average accuracy: 92%
```

**When to use**: After accumulating 10+ runs

#### Level 5: Multi-Stage Pipeline (80%+ in 2 stages)

```bash
# Progressive validation with early exit
./execute_tests_docs_workflow.sh \
  --multi-stage \
  --smart-execution \
  --parallel \
  --auto

# Stage 1: Critical checks (5 min)
# Stage 2: Standard validation (8 min)  
# Stage 3: Deep analysis (10 min) - rarely needed

# 80%+ of runs complete in Stage 1-2
```

**When to use**: CI/CD pipelines, pre-commit validation

### ✅ Success Criteria
- Execution time reduced by 70%+
- All quality checks still pass
- Consistent results vs baseline
- ML predictions accurate (90%+)

---

## Tutorial 4: Documentation-Only Workflow

**Goal**: Fast documentation validation and updates  
**Time**: 3-4 minutes  
**Prerequisites**: Completed Tutorial 1

### Use Case
You've updated README files, API docs, or user guides and need quick validation without running full workflow.

### Option 1: Pre-Built Template

```bash
# Fastest method - uses workflow template
cd /path/to/your/project
/path/to/ai_workflow/templates/workflows/docs-only.sh

# This template automatically:
# - Runs Step 0: Pre-analysis
# - Runs Step 2: Documentation validation
# - Runs Step 5: Consistency checks
# - Runs Step 15: Finalization
# - Skips all code and test steps
```

### Option 2: Custom Step Selection

```bash
# Manual step selection
./execute_tests_docs_workflow.sh \
  --steps 0,2,5,15 \
  --smart-execution \
  --auto

# Explanation:
# Step 0: Analyze changes
# Step 2: Validate documentation
# Step 5: Check consistency
# Step 15: Generate reports
```

### Option 3: Bootstrap New Documentation (v3.1.0, UPDATED v4.0.1)

```bash
# Generate comprehensive docs from scratch (with necessity-first evaluation)
./execute_tests_docs_workflow.sh \
  --steps 0b \
  --auto

# Step 0b evaluates necessity FIRST, then creates (if needed):
# - README.md
# - API documentation
# - Architecture guides
# - User guides
# - Developer documentation
# Note: Will skip generation if documentation is already adequate
```

### Step-by-Step: Documentation Workflow

```bash
# 1. Make documentation changes
vim docs/README.md

# 2. Run docs-only validation
/path/to/ai_workflow/templates/workflows/docs-only.sh

# 3. Review AI suggestions
cat /path/to/ai_workflow/src/workflow/backlog/workflow_*/step_02_*.md

# 4. Apply recommended fixes
# (Apply suggestions from report)

# 5. Verify changes
git diff docs/

# 6. Commit if satisfied
git add docs/
git commit -m "docs: Update README based on AI review"
```

### ✅ Success Criteria
- Documentation validated in 3-4 minutes
- AI suggestions applied
- Consistency checks pass
- No broken links or formatting issues

---

## Tutorial 5: Test Development Workflow

**Goal**: Develop and validate tests efficiently  
**Time**: 8-10 minutes  
**Prerequisites**: Completed Tutorial 1

### Use Case
You're implementing TDD or adding test coverage and need rapid feedback.

### Option 1: Pre-Built Template

```bash
# Use test-only workflow template
cd /path/to/your/project
/path/to/ai_workflow/templates/workflows/test-only.sh

# Runs:
# - Step 0: Analysis
# - Step 3: Code quality
# - Step 4: Test strategy
# - Step 7: Test validation
# - Step 8: Test enhancement
# - Step 15: Finalization
```

### Option 2: Custom Configuration

```bash
# Configure test framework first
./execute_tests_docs_workflow.sh --init-config

# Interactive wizard will ask:
# - Primary language? javascript
# - Test framework? jest
# - Test command? npm test
# - Coverage command? npm run test:coverage

# Then run test workflow
./execute_tests_docs_workflow.sh \
  --steps 0,3,4,7,8,15 \
  --smart-execution \
  --auto
```

### TDD Workflow Example

```bash
# 1. Write failing test
cat > tests/user.test.js << 'EOF'
describe('User', () => {
  it('should create user with valid email', () => {
    const user = new User('test@example.com');
    expect(user.email).toBe('test@example.com');
  });
});
EOF

# 2. Run workflow to verify test fails
/path/to/ai_workflow/templates/workflows/test-only.sh

# 3. Implement feature
cat > src/user.js << 'EOF'
class User {
  constructor(email) {
    this.email = email;
  }
}
module.exports = User;
EOF

# 4. Run workflow to verify test passes
/path/to/ai_workflow/templates/workflows/test-only.sh

# 5. Get AI suggestions for improvement
cat src/workflow/backlog/workflow_*/step_08_*.md
```

### ✅ Success Criteria
- Tests execute successfully
- Coverage metrics collected
- AI suggests test improvements
- TDD cycle validated (< 10 minutes)

---

## Tutorial 6: CI/CD Integration

**Goal**: Automate workflow in CI/CD pipeline  
**Time**: 15 minutes setup  
**Prerequisites**: Completed Tutorial 2, CI/CD system access

### GitHub Actions Integration

```yaml
# .github/workflows/ai-workflow.yml
name: AI Workflow Automation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validation:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for change detection
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '25.2.1'
      
      - name: Install GitHub Copilot CLI
        run: |
          gh extension install github/gh-copilot || true
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Clone AI Workflow
        run: |
          git clone https://github.com/mpbarbosa/ai_workflow.git /tmp/ai_workflow
      
      - name: Run Workflow
        run: |
          /tmp/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
            --auto \
            --smart-execution \
            --parallel \
            --ml-optimize \
            --multi-stage \
            --no-resume
        env:
          TARGET_PROJECT: ${{ github.workspace }}
      
      - name: Upload Reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: workflow-reports
          path: /tmp/ai_workflow/src/workflow/backlog/workflow_*
      
      - name: Upload Metrics
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: workflow-metrics
          path: /tmp/ai_workflow/src/workflow/metrics/
```

### GitLab CI Integration

```yaml
# .gitlab-ci.yml
stages:
  - validate

ai_workflow:
  stage: validate
  image: node:25.2.1
  
  before_script:
    - apt-get update && apt-get install -y bash git
    - git clone https://github.com/mpbarbosa/ai_workflow.git /tmp/ai_workflow
  
  script:
    - |
      /tmp/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
        --auto \
        --smart-execution \
        --parallel \
        --multi-stage
  
  artifacts:
    when: always
    paths:
      - /tmp/ai_workflow/src/workflow/backlog/
      - /tmp/ai_workflow/src/workflow/metrics/
    expire_in: 30 days
  
  only:
    - main
    - develop
    - merge_requests
```

### Jenkins Integration

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        AI_WORKFLOW = '/tmp/ai_workflow'
    }
    
    stages {
        stage('Setup') {
            steps {
                sh 'git clone https://github.com/mpbarbosa/ai_workflow.git ${AI_WORKFLOW}'
            }
        }
        
        stage('Run Workflow') {
            steps {
                sh """
                    ${AI_WORKFLOW}/src/workflow/execute_tests_docs_workflow.sh \
                        --auto \
                        --smart-execution \
                        --parallel \
                        --ml-optimize \
                        --multi-stage
                """
            }
        }
        
        stage('Archive Results') {
            steps {
                archiveArtifacts artifacts: "${AI_WORKFLOW}/src/workflow/backlog/**", allowEmptyArchive: true
                archiveArtifacts artifacts: "${AI_WORKFLOW}/src/workflow/metrics/**", allowEmptyArchive: true
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

### ✅ Success Criteria
- CI/CD runs workflow automatically
- Reports generated and archived
- Failures halt pipeline
- Execution time < 10 minutes

---

## Tutorial 7: Using Pre-Commit Hooks

**Goal**: Catch issues before committing  
**Time**: 5 minutes setup  
**Prerequisites**: Completed Tutorial 1

### Installation

```bash
# Navigate to your project
cd /path/to/your/project

# Install hooks
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Expected output:
# ✅ Pre-commit hook installed: .git/hooks/pre-commit
# ✅ Commit-msg hook installed: .git/hooks/commit-msg
# ✅ Pre-push hook installed: .git/hooks/pre-push
```

### Test Hooks

```bash
# Test without committing
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --test-hooks

# Make a test change
echo "# Test" >> README.md
git add README.md

# Try to commit (hooks will run)
git commit -m "test: Update README"

# Hooks validate:
# ✅ No syntax errors
# ✅ Tests pass
# ✅ Documentation valid
# ✅ Commit message format
# Total time: < 1 second
```

### Hook Behavior

**Pre-commit hook validates:**
- Bash syntax (shellcheck)
- JavaScript syntax (eslint)
- Python syntax (flake8)
- Documentation links
- Test commands

**Commit-msg hook validates:**
- Conventional commit format
- Message length
- Required sections

**Pre-push hook validates:**
- All tests pass
- No merge conflicts
- Branch protection

### Bypass Hooks (Emergency)

```bash
# Skip hooks for urgent fix
git commit --no-verify -m "hotfix: Critical security patch"

# Not recommended for regular use
```

### ✅ Success Criteria
- Hooks installed and active
- Validation completes < 1 second
- Invalid commits blocked
- Valid commits allowed

---

## Tutorial 8: ML Optimization Setup

**Goal**: Enable predictive workflow optimization  
**Time**: 10 minutes setup + 10 historical runs  
**Prerequisites**: Completed Tutorial 3

### Prerequisites Check

```bash
# Check if ML optimization available
./execute_tests_docs_workflow.sh --show-ml-status

# Output if not ready:
# ⚠️  ML models not available
# ⚠️  Insufficient training data (3/10 runs)
# ℹ️  Run 7 more workflows to enable ML optimization
```

### Accumulate Training Data

```bash
# Run workflow 10 times with normal usage
for i in {1..10}; do
  echo "Training run $i/10"
  ./execute_tests_docs_workflow.sh \
    --auto \
    --smart-execution \
    --parallel
  
  # Make small changes between runs
  echo "# Update $i" >> README.md
  git add README.md
  git commit -m "docs: Training run $i"
done
```

### Verify ML System

```bash
# Check status after 10+ runs
./execute_tests_docs_workflow.sh --show-ml-status

# Expected output:
# ✅ ML models available
# ✅ Training data: 15 runs
# ✅ Predictions enabled
# Average accuracy: 92%
# Last trained: 2026-02-08 02:15:30
```

### Enable ML Optimization

```bash
# Run with ML predictions
./execute_tests_docs_workflow.sh \
  --ml-optimize \
  --smart-execution \
  --parallel \
  --auto

# System will:
# - Predict step durations
# - Recommend optimal execution order
# - Adjust resource allocation
# - Skip likely-no-op steps
# - Provide 15-30% additional improvement
```

### Monitor ML Performance

```bash
# Check prediction accuracy
cat src/workflow/metrics/ml_predictions.json

# Sample output:
{
  "predictions": [
    {"step": 0, "predicted_duration": 45, "actual": 43, "accuracy": 95.6},
    {"step": 2, "predicted_duration": 180, "actual": 175, "accuracy": 97.2}
  ],
  "overall_accuracy": 92.3
}
```

### ✅ Success Criteria
- ML models trained (10+ runs)
- Predictions accurate (90%+)
- Additional 15-30% speedup
- Automatic optimization recommendations

---

## Tutorial 9: Custom Configuration

**Goal**: Configure workflow for your project  
**Time**: 10 minutes  
**Prerequisites**: Completed Tutorial 1

### Interactive Configuration

```bash
# Run configuration wizard
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config

# Wizard prompts:
# 1. Project name? my-awesome-project
# 2. Project type? nodejs_api
# 3. Primary language? javascript
# 4. Test framework? jest
# 5. Test command? npm test
# 6. Coverage command? npm run test:coverage
# 7. Build command? npm run build
# 8. Lint command? npm run lint

# Creates: .workflow-config.yaml
```

### Manual Configuration

```yaml
# .workflow-config.yaml
project:
  kind: nodejs_api
  name: my-awesome-project
  description: RESTful API with Express

tech_stack:
  primary_language: javascript
  frameworks:
    - express
    - jest
  tools:
    - eslint
    - prettier

test:
  command: npm test
  framework: jest
  coverage_command: npm run test:coverage
  coverage_threshold: 80

build:
  command: npm run build
  output_dir: dist/

quality:
  linter: eslint
  formatter: prettier
  rules:
    - .eslintrc.js

documentation:
  auto_generate: true
  formats:
    - markdown
    - jsdoc
  output_dir: docs/

optimization:
  smart_execution: true
  parallel_execution: true
  ml_optimize: true
  ai_cache: true
  cache_ttl: 86400  # 24 hours
```

### Verify Configuration

```bash
# Display detected configuration
./execute_tests_docs_workflow.sh --show-tech-stack

# Output:
# Project: my-awesome-project (nodejs_api)
# Language: javascript
# Frameworks: express, jest
# Test command: npm test
# Build command: npm run build
# Documentation: auto-generate enabled
```

### Override Configuration

```bash
# Use different config file
./execute_tests_docs_workflow.sh --config-file .custom-config.yaml

# Override specific settings
./execute_tests_docs_workflow.sh \
  --config-file .custom-config.yaml \
  --parallel \
  --no-ai-cache
```

### ✅ Success Criteria
- Configuration created successfully
- Tech stack detected correctly
- Commands execute properly
- Workflow adapts to configuration

---

## Tutorial 10: Troubleshooting Common Issues

**Goal**: Diagnose and fix common problems  
**Time**: Variable  
**Prerequisites**: Any tutorial

### Issue 1: Copilot CLI Not Available

**Symptom**: "GitHub Copilot CLI not available"

**Solution**:
```bash
# Check if gh is installed
gh --version

# Install if missing (macOS)
brew install gh

# Install if missing (Linux)
sudo apt install gh

# Install Copilot extension
gh extension install github/gh-copilot

# Authenticate
gh auth login

# Verify
gh copilot --version
```

### Issue 2: Permission Denied

**Symptom**: "Permission denied: ./execute_tests_docs_workflow.sh"

**Solution**:
```bash
# Make script executable
chmod +x ./execute_tests_docs_workflow.sh

# Also fix library modules
chmod +x ./src/workflow/lib/*.sh
chmod +x ./src/workflow/steps/*.sh
```

### Issue 3: Stale Cache Issues

**Symptom**: "AI returning outdated responses"

**Solution**:
```bash
# Clear AI cache
rm -rf src/workflow/.ai_cache/*

# Or disable caching temporarily
./execute_tests_docs_workflow.sh --no-ai-cache

# Or reduce TTL in config
# .workflow-config.yaml:
# optimization:
#   cache_ttl: 3600  # 1 hour instead of 24
```

### Issue 4: Checkpoint Resume Problems

**Symptom**: "Cannot resume from checkpoint" or "Stuck at step X"

**Solution**:
```bash
# Force fresh start
./execute_tests_docs_workflow.sh --no-resume

# Clear checkpoints
rm -rf src/workflow/.checkpoints/*

# If step fails repeatedly, skip it
./execute_tests_docs_workflow.sh --steps 0,2,5,15  # Skip problematic steps
```

### Issue 5: Slow Performance

**Symptom**: "Workflow takes 20+ minutes"

**Solution**:
```bash
# Enable all optimizations
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto

# Check system resources
top  # Ensure adequate CPU/memory

# Check metrics for bottlenecks
cat src/workflow/metrics/current_run.json | jq '.steps[] | select(.duration > 300)'

# If specific step is slow, investigate logs
cat src/workflow/logs/workflow_*/step_XX_*.log
```

### Issue 6: Test Failures

**Symptom**: "Tests failing in workflow but pass locally"

**Solution**:
```bash
# Check environment differences
./execute_tests_docs_workflow.sh --verbose

# Verify test command
cat .workflow-config.yaml | grep "test:"

# Run tests manually in same environment
cd /path/to/project
npm test  # or your test command

# Check for missing dependencies
npm install  # or equivalent

# Review test logs
cat src/workflow/logs/workflow_*/step_07_*.log
```

### Issue 7: AI Errors

**Symptom**: "AI request failed" or "API error"

**Solution**:
```bash
# Check Copilot status
gh copilot --version

# Test AI directly
echo "Explain this code: console.log('test')" | gh copilot explain

# Check rate limits
gh api rate_limit

# If rate limited, disable AI temporarily
./execute_tests_docs_workflow.sh --skip-ai

# Or increase retry delays in code
# (Advanced: modify lib/ai_helpers.sh)
```

### Issue 8: Git Issues

**Symptom**: "Dirty working directory" or "Uncommitted changes"

**Solution**:
```bash
# Check git status
git status

# Stash changes if needed
git stash

# Run workflow
./execute_tests_docs_workflow.sh --auto

# Restore changes
git stash pop

# Or commit changes first
git add .
git commit -m "WIP: Before workflow"
```

### Issue 9: Configuration Not Detected

**Symptom**: "Cannot detect project kind" or "Unknown framework"

**Solution**:
```bash
# Manually specify configuration
./execute_tests_docs_workflow.sh --init-config

# Or create config manually
cat > .workflow-config.yaml << 'EOF'
project:
  kind: nodejs_api
  name: my-project
tech_stack:
  primary_language: javascript
test:
  command: npm test
EOF

# Verify detection
./execute_tests_docs_workflow.sh --show-tech-stack
```

### Issue 10: Memory Issues

**Symptom**: "Out of memory" or system slows down

**Solution**:
```bash
# Disable parallel execution
./execute_tests_docs_workflow.sh --smart-execution  # No --parallel

# Reduce concurrent AI calls
# Edit .workflow-config.yaml:
# optimization:
#   max_parallel_ai_calls: 2  # Default is 4

# Clear old logs and metrics
rm -rf src/workflow/logs/workflow_202601*
rm -rf src/workflow/backlog/workflow_202601*

# Monitor memory usage
watch -n 1 'free -h'
```

### Getting Help

**If issues persist:**

1. **Check logs**: `cat src/workflow/logs/workflow_*/error.log`
2. **Run health check**: `./src/workflow/lib/health_check.sh`
3. **Enable verbose mode**: `./execute_tests_docs_workflow.sh --verbose`
4. **Review documentation**: [docs/guides/user/troubleshooting.md](user-guide/troubleshooting.md)
5. **Open issue**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)

### ✅ Success Criteria
- Issue identified correctly
- Solution applied successfully
- Workflow runs without errors
- Root cause understood

---

## Next Steps

After completing these tutorials:

1. **Explore Advanced Features**: [docs/guides/user/feature-guide.md](user-guide/feature-guide.md)
2. **Read API Documentation**: [docs/reference/api/API_REFERENCE.md](api/API_REFERENCE.md)
3. **Contribute**: [CONTRIBUTING.md](../CONTRIBUTING.md)
4. **Join Community**: GitHub Discussions

---

**For more information**, see:
- [Quick Reference](QUICK_REFERENCE.md) - Command cheat sheet
- [User Guide](user-guide/USER_GUIDE.md) - Comprehensive guide
- [API Reference](api/API_REFERENCE.md) - Developer documentation
- [Project Reference](PROJECT_REFERENCE.md) - Complete feature list
