# Getting Started with AI Workflow Automation

**Version**: 4.1.0  
**Last Updated**: 2026-02-10  
**Prerequisites**: Bash 4.0+, Git, Node.js 25.2.1+, GitHub Copilot CLI

## Table of Contents

- [Quick Start (5 Minutes)](#quick-start-5-minutes)
- [Installation Options](#installation-options)
- [Basic Workflows](#basic-workflows)
- [Configuration](#configuration)
- [Command-Line Options](#command-line-options)
- [Performance Optimization](#performance-optimization)
- [AI Features](#ai-features)
- [Interactive Step Skipping](#interactive-step-skipping)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)
- [FAQ](#faq)

---

## Quick Start (5 Minutes)

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/mpbarbosa/ai_workflow.git
cd ai_workflow

# Run health check
./src/workflow/lib/health_check.sh
```

### 2. First Run (On This Project)

```bash
# Run with all optimizations (recommended)
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```

**Expected Duration**: 2-4 minutes for documentation-only changes, 10-15 minutes for full changes.

### 3. Understanding the Output

The workflow creates several artifacts:

```
src/workflow/
├── backlog/                 # Execution reports
│   └── workflow_YYYYMMDD_HHMMSS/
│       ├── step_00_analysis.md
│       ├── step_01_analyze_documentation.md
│       └── ... (18 steps total)
├── logs/                    # Detailed logs
├── metrics/                 # Performance data
│   └── current_run.json
└── summaries/              # AI-generated summaries
```

## Real-World Tutorial

### Scenario 1: Adding a New Feature

You're adding a new feature to your project. Here's how to use the workflow:

```bash
# Step 1: Make your code changes
vim src/my_new_feature.js

# Step 2: Run workflow with smart execution
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto-commit

# Step 3: Review the generated documentation
cat src/workflow/backlog/workflow_*/step_02_documentation_update.md

# Step 4: Review test recommendations
cat src/workflow/backlog/workflow_*/step_05_test_creation.md
```

**What Happens**:
1. **Step 0**: Analyzes your changes (detects code changes in `src/`)
2. **Step 2**: AI updates documentation based on code changes
3. **Step 5**: AI generates test cases
4. **Step 7**: Runs existing tests
5. **Step 15**: Updates version and generates summary
6. **Auto-commit**: Commits docs, tests, and code with smart messages

### Scenario 2: Documentation-Only Update

You want to improve your README without touching code:

```bash
# Edit documentation
vim README.md

# Run docs-only workflow template (fastest)
./templates/workflows/docs-only.sh

# Or with main script
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel
```

**Duration**: 2-3 minutes (85% faster than full run)

**Skipped Steps**: Code analysis, test creation, UX analysis (automatically detected)

### Scenario 3: Test Development

You're writing tests for existing code:

```bash
# Create test file
vim tests/test_my_feature.js

# Run test-only workflow
./templates/workflows/test-only.sh
```

**What Happens**:
- Validates test structure
- Runs test suite
- Generates coverage report
- Provides test improvement recommendations

## Common Workflows

### Daily Development Workflow

```bash
# 1. Start your work
git checkout -b feature/new-thing

# 2. Make changes
vim src/my_feature.sh

# 3. Run workflow (validates as you go)
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto-commit

# 4. Review and commit
git log -1  # See auto-generated commit
git push origin feature/new-thing
```

### Pre-Commit Validation

```bash
# Install pre-commit hooks (one-time setup)
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Now every commit automatically validates:
git commit -m "Add new feature"
# -> Validates in < 1 second
# -> Blocks commit if critical issues found
```

### Working on External Projects

```bash
# Run on any project
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/other/project \
  --smart-execution \
  --parallel

# Or configure the external project
cd /path/to/other/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

## Understanding Results

### Reading the Backlog

Each step generates a markdown report in `backlog/workflow_TIMESTAMP/`:

```markdown
# Step 02: Documentation Update

## Changes Made
- Updated README.md with new feature section
- Added API documentation for `process_data()`
- Updated CHANGELOG.md

## AI Recommendations
- Consider adding usage example for `process_data()`
- Update migration guide for v2.0.0

## Validation
✓ All documentation files validated
✓ No broken links detected
✓ Code examples tested
```

### Metrics Dashboard

```bash
# View last run metrics
cat src/workflow/metrics/current_run.json

# Example output:
{
  "total_duration": 180,
  "steps_executed": 12,
  "steps_skipped": 6,
  "optimization_savings": "75%",
  "cache_hits": 8,
  "cache_misses": 4
}
```

### Performance Optimization

Check what optimizations are working:

```bash
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Output:
# ML Optimization Status
# ======================
# Historical runs: 15
# Prediction accuracy: 87%
# Avg time savings: 42%
# Recommendations:
#   - Smart execution: ENABLED ✓
#   - Parallel execution: ENABLED ✓
#   - ML optimization: AVAILABLE (use --ml-optimize)
#   - ML optimization: AVAILABLE (use --ml-optimize)
```

## Interactive Step Skipping

**NEW in v4.1.0**: You can now skip steps interactively without re-running the workflow.

### How It Works

When the workflow pauses to ask if you want to continue to the next step, you can:

- **Press ENTER**: Continue to the next step normally
- **Press SPACE**: Skip the next step (show "⏭️  Next step will be skipped")

### Examples

```bash
# Run workflow with interactive prompts (not in --auto mode)
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel

# At each continue prompt, you can:
# >>> Continue to next step? [yes/no/skip] 
# Press: SPACE to skip next step
#        ENTER to continue normally
```

### Behavior Details

- **One-time skip**: Skips only the immediately following step
- **Not available in auto mode**: When using `--auto` flag, interactive skip is disabled
- **Works with all workflows**: Compatible with smart execution, parallel, and ML optimization
- **No step number needed**: Works with both numbered and named steps

### Use Cases

```bash
# Scenario 1: Skip UX analysis on familiar projects
./src/workflow/execute_tests_docs_workflow.sh
# At UX analysis prompt → SPACE to skip

# Scenario 2: Skip code quality checks for documentation-only changes
./src/workflow/execute_tests_docs_workflow.sh
# At code quality prompt → SPACE to skip

# Scenario 3: Manual step selection for precise control
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_review,test_execution
# Use --steps for more fine-grained control
```

## Next Steps

### Customize for Your Project

```bash
# Run configuration wizard
./src/workflow/execute_tests_docs_workflow.sh --init-config

# Interactive prompts:
# - Project type (nodejs, python, shell, etc.)
# - Test framework
# - Documentation standards
# - CI/CD integration
```

### Integrate with CI/CD

See [Integration Guide](../guides/INTEGRATION_GUIDE.md) or [CI/CD Integration](../operations/CI_CD_INTEGRATION.md) for:
- GitHub Actions integration
- GitLab CI integration
- Jenkins integration
- Pre-commit hooks

### Advanced Usage

- [Command-Line Reference](../user-guide/COMMAND_LINE_REFERENCE.md) - All options
- [Feature Guide](../user-guide/feature-guide.md) - Advanced features
- [Performance Tuning](../user-guide/PERFORMANCE_TUNING.md) - Optimization strategies
- [Performance Optimization Deep Dive](../operations/PERFORMANCE_OPTIMIZATION.md) - Advanced tuning
- [Troubleshooting](../user-guide/troubleshooting.md) - Common issues

## See Also

### Next Steps
- **[Quick Reference](../QUICK_REFERENCE.md)** - One-page cheat sheet
- **[Project Reference](../PROJECT_REFERENCE.md)** - Complete feature list
- **[User Guide](../user-guide/USER_GUIDE.md)** - Comprehensive guide

### Operations & CI/CD
- **[CI/CD Integration](../operations/CI_CD_INTEGRATION.md)** - GitHub Actions, GitLab, Jenkins
- **[Performance Deep Dive](../operations/PERFORMANCE_OPTIMIZATION.md)** - Profiling and benchmarking

### Feature Guides
- **[Audio Notifications](../guides/AUDIO_NOTIFICATIONS_SETUP.md)** - Sound alerts setup
- **[Git Commit Tracking](../guides/GIT_COMMIT_TRACKING.md)** - Multi-commit validation
- **[Pre-Commit Hooks](../guides/PRECOMMIT_HOOKS_SETUP.md)** - Git hook integration

### Developer Resources
- **[Developer Onboarding](../developer-guide/DEVELOPER_ONBOARDING_GUIDE.md)** - Contributing guide
- **[API Reference](../api/COMPLETE_API_REFERENCE.md)** - Complete API docs
- **[Architecture](../architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md)** - System design

---

## FAQ

**Q: How long does a typical run take?**  
A: 2-4 minutes for docs-only, 10-15 minutes for full changes, 15-20 minutes for comprehensive feature work. With ML optimization: 1.5-7 minutes.

**Q: Do I need GitHub Copilot?**  
A: GitHub Copilot CLI is required for AI features (documentation generation, test recommendations, UX analysis). Without it, the workflow runs basic validations only.

**Q: Can I run this on any project?**  
A: Yes! Use `--target /path/to/project` or run from within any project directory.

**Q: What if I don't want auto-commit?**  
A: Don't use `--auto-commit` flag. Review changes manually with `git status` and commit yourself.

**Q: How do I skip certain steps?**  
A: You have two options:
  1. **Interactive skipping** (NEW v4.1.0): Press space bar at continue prompts to skip the next step
  2. **Pre-planned skipping**: Use `--steps 0,2,5,7` to run only specific steps, or let smart execution auto-skip based on changes

## Getting Help

- **Documentation**: [docs/README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **API Reference**: [docs/reference/api/API_REFERENCE.md](api/API_REFERENCE.md)
- **Examples**: [docs/guides/user/example-projects.md](user-guide/example-projects.md)
