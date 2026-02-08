# AI Workflow Automation - User Guide

**Version**: v3.1.0  
**Last Updated**: 2026-02-08

Welcome! This guide will help you use the AI Workflow Automation system to improve your software projects, regardless of your technical background.

## Table of Contents

1. [What is AI Workflow Automation?](#what-is-ai-workflow-automation)
2. [Who Should Use This?](#who-should-use-this)
3. [What Can It Do?](#what-can-it-do)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Quick Start](#quick-start)
7. [Common Workflows](#common-workflows)
8. [Understanding Results](#understanding-results)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)
11. [FAQ](#faq)

---

## What is AI Workflow Automation?

AI Workflow Automation is an intelligent assistant that helps maintain and improve software projects by:

- **Analyzing documentation** for completeness and accuracy
- **Reviewing code quality** and suggesting improvements
- **Checking tests** and generating missing ones
- **Validating configurations** for common errors
- **Ensuring accessibility** in web applications

Think of it as having an experienced developer review your project automatically!

---

## Who Should Use This?

This tool is designed for:

- **Solo Developers**: Get expert feedback on your code
- **Small Teams**: Maintain consistent quality standards
- **Technical Writers**: Keep documentation up-to-date
- **Project Managers**: Understand project health
- **QA Engineers**: Identify testing gaps

**No advanced programming required** - the tool guides you through everything!

---

## What Can It Do?

### Core Capabilities

✅ **Documentation Analysis**
- Finds outdated or missing documentation
- Suggests improvements for clarity
- Checks examples for accuracy

✅ **Code Quality Checks**
- Reviews code for common issues
- Suggests best practices
- Identifies potential bugs

✅ **Test Coverage**
- Analyzes existing tests
- Generates missing tests
- Runs test suites automatically

✅ **Accessibility Checking** (for web apps)
- Validates WCAG 2.1 compliance
- Checks color contrast
- Reviews keyboard navigation

✅ **Dependency Management**
- Checks for outdated packages
- Identifies security vulnerabilities
- Validates version compatibility

### Performance Features

⚡ **Smart Execution**: Only runs checks relevant to your changes (40-85% faster)  
⚡ **Parallel Processing**: Multiple checks run simultaneously (33% faster)  
⚡ **AI Caching**: Reuses recent AI analysis to save time (60-80% faster)

---

## Prerequisites

Before using the tool, ensure you have:

### Required Software

1. **Bash 4.0+** (usually pre-installed on macOS/Linux)
   ```bash
   bash --version
   ```

2. **Git** (version control)
   ```bash
   git --version
   ```

3. **GitHub Copilot CLI** (AI integration)
   ```bash
   gh copilot --version
   ```
   
   > **Don't have Copilot?** Install with: `gh extension install github/gh-copilot`

4. **Node.js 25.2.1+** (for JavaScript projects)
   ```bash
   node --version
   ```

### Optional Software

- **Python 3.8+** (for Python projects)
- **Docker** (for containerized projects)

---

## Installation

### Step 1: Clone Repository

```bash
# Using SSH (recommended)
git clone git@github.com:mpbarbosa/ai_workflow.git

# Or using HTTPS
git clone https://github.com/mpbarbosa/ai_workflow.git

cd ai_workflow
```

### Step 2: Verify Installation

```bash
# Run health check
./src/workflow/lib/health_check.sh
```

You should see:
```
✓ Bash version OK
✓ Git available
✓ GitHub Copilot CLI available
✓ Node.js version OK
All checks passed!
```

### Step 3: Test on Sample Project

```bash
# Test the workflow on itself
./src/workflow/execute_tests_docs_workflow.sh \
  --dry-run \
  --steps 0,1,2
```

This shows what the workflow would do without making changes.

---

## Quick Start

### Your First Workflow Run

Let's run the workflow on your project!

#### Option 1: Run from Your Project Directory

```bash
# Navigate to your project
cd /path/to/your/project

# Run the workflow with smart features
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```

#### Option 2: Use --target Flag

```bash
# Run from anywhere
cd ai_workflow

./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/your/project \
  --smart-execution \
  --parallel \
  --auto
```

### What Happens During Execution?

1. **Pre-Analysis**: Detects what changed in your project
2. **Documentation Check**: Analyzes README, guides, API docs
3. **Code Review**: Checks code quality and style
4. **Test Analysis**: Reviews test coverage
5. **Final Report**: Generates summary with recommendations

**Duration**: 3-23 minutes depending on project size and changes

---

## Common Workflows

### Workflow 1: Documentation-Only Update

**Use Case**: You only changed documentation

```bash
cd /path/to/your/project

# Fast documentation-only workflow (3-4 minutes)
/path/to/ai_workflow/templates/workflows/docs-only.sh
```

**What it does**:
- Analyzes documentation quality
- Checks cross-references
- Validates markdown syntax
- Suggests improvements

---

### Workflow 2: Test Development

**Use Case**: You want to improve test coverage

```bash
cd /path/to/your/project

# Test-focused workflow (8-10 minutes)
/path/to/ai_workflow/templates/workflows/test-only.sh
```

**What it does**:
- Reviews existing tests
- Identifies untested code
- Generates missing tests
- Runs test suites
- Reports coverage

---

### Workflow 3: Feature Development

**Use Case**: You added new features or made code changes

```bash
cd /path/to/your/project

# Complete workflow (15-20 minutes)
/path/to/ai_workflow/templates/workflows/feature.sh
```

**What it does**:
- Full documentation analysis
- Code quality review
- Test generation and execution
- Dependency checking
- UX analysis (for web apps)

---

### Workflow 4: Pre-Commit Check

**Use Case**: Quick validation before committing

```bash
# Install hooks once
./src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Now hooks run automatically on git commit!
git add .
git commit -m "Your changes"
# → Hooks validate your changes (< 1 second)
```

**What it checks**:
- Syntax errors
- Broken links
- Test failures
- Lint errors

---

## Understanding Results

After workflow execution, you'll find results in:

### 1. Execution Reports

Location: `src/workflow/.ai_workflow/backlog/workflow_YYYYMMDD_HHMMSS/`

**Key Files**:
- `CHANGE_IMPACT_ANALYSIS.md` - What changed and impact assessment
- `step01_documentation_analysis.md` - Documentation issues
- `step06_test_review.md` - Test coverage analysis
- `step10_code_quality.md` - Code quality assessment
- `step15_ux_analysis.md` - UX/accessibility report (web apps)

### 2. Metrics Dashboard

Location: `src/workflow/metrics/current_run.json`

**View metrics**:
```bash
cat src/workflow/metrics/current_run.json | jq '.'
```

**Key Metrics**:
- `duration_seconds`: Total execution time
- `steps_completed`: Number of steps run
- `success_rate`: Percentage of successful steps

### 3. Generated Summaries

Location: `src/workflow/summaries/workflow_YYYYMMDD_HHMMSS/`

**AI-generated summaries** of findings and recommendations.

---

## Troubleshooting

### Problem: "GitHub Copilot CLI not available"

**Solution**:
```bash
# Install Copilot CLI
gh extension install github/gh-copilot

# Verify installation
gh copilot --version
```

---

### Problem: "Permission denied" errors

**Solution**:
```bash
# Make script executable
chmod +x /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Run again
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/project
```

---

### Problem: Workflow takes too long

**Solution**: Enable optimizations!

```bash
# Fastest execution
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --auto
```

**Expected speedup**: 40-93% faster depending on changes

---

### Problem: AI responses seem cached/stale

**Solution**: Disable AI caching

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --no-ai-cache \
  --target /path/to/project
```

---

### Problem: Step fails repeatedly

**Solution**: Skip problematic step

```bash
# Run all steps except step 5
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,3,4,6,7,8,9,10 \
  --target /path/to/project
```

---

### Problem: Want to start fresh (ignore checkpoints)

**Solution**: Use --no-resume flag

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --no-resume \
  --target /path/to/project
```

---

## Best Practices

### 1. Run Regularly

**Recommended frequency**:
- After major changes: Full workflow
- Daily development: Smart execution
- Before commits: Pre-commit hooks

```bash
# Daily development workflow
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```

---

### 2. Review AI Suggestions

**Don't blindly accept all recommendations!**

- Read the analysis reports
- Understand why changes are suggested
- Apply changes that make sense for your project

---

### 3. Use Dry Run for Learning

**Practice without making changes**:

```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --dry-run \
  --target /path/to/project
```

This shows what **would** happen without modifying files.

---

### 4. Check Metrics Regularly

**Monitor workflow performance**:

```bash
# View recent runs
cat src/workflow/metrics/history.jsonl | tail -5 | jq '.'

# Average duration
cat src/workflow/metrics/history.jsonl | \
  jq -s 'map(.duration_seconds) | add / length'
```

---

### 5. Leverage Templates

**Use workflow templates for common tasks**:

```bash
# Documentation work
./templates/workflows/docs-only.sh

# Test development
./templates/workflows/test-only.sh

# Feature development
./templates/workflows/feature.sh
```

**Benefit**: Pre-configured optimal settings for specific tasks

---

## FAQ

### Q: Do I need to be a programmer to use this?

**A**: No! Basic command-line knowledge is helpful, but the tool provides clear instructions and error messages. Follow the examples in this guide.

---

### Q: Will the workflow modify my code automatically?

**A**: Only if you use `--auto` flag. By default, it runs in **interactive mode** and asks for confirmation before making changes.

**Safe mode** (asks before changes):
```bash
./src/workflow/execute_tests_docs_workflow.sh
```

**Automatic mode** (no prompts):
```bash
./src/workflow/execute_tests_docs_workflow.sh --auto
```

---

### Q: Can I run this on any programming language?

**A**: Yes! The workflow supports:
- JavaScript/TypeScript (Node.js)
- Python
- Shell scripts
- Go
- Ruby
- Java
- And more...

The tool automatically detects your project's tech stack.

---

### Q: How much does it cost?

**A**: The workflow itself is **free and open-source** (MIT License). However, it uses **GitHub Copilot CLI**, which requires a GitHub Copilot subscription ($10/month for individuals, free for students).

---

### Q: Is my code sent to external servers?

**A**: The workflow uses **GitHub Copilot CLI**, which sends code snippets to GitHub's AI service for analysis. If you have privacy concerns:

1. Review GitHub Copilot's privacy policy
2. Use `--no-ai` flag to skip AI-powered steps
3. Run only automated checks (linting, testing)

---

### Q: What if I don't have GitHub Copilot?

**A**: Some features will be disabled:
- ❌ AI-powered documentation analysis
- ❌ AI code review
- ❌ AI test generation
- ✅ Syntax validation (works)
- ✅ Test execution (works)
- ✅ Dependency checking (works)
- ✅ Markdown linting (works)

---

### Q: Can I customize which checks run?

**A**: Absolutely! Use `--steps` flag:

```bash
# Run only steps 0, 1, 2, 10
./src/workflow/execute_tests_docs_workflow.sh \
  --steps 0,1,2,10 \
  --target /path/to/project
```

**Common combinations**:
- `--steps 0,1,2` - Documentation only
- `--steps 6,7,8` - Testing only
- `--steps 10,13` - Code quality + markdown lint

---

### Q: How do I report bugs or request features?

**A**: Open an issue on GitHub:

1. Visit: https://github.com/mpbarbosa/ai_workflow/issues
2. Click "New Issue"
3. Describe the problem or feature request
4. Include workflow logs if reporting a bug

---

### Q: Can I contribute to the project?

**A**: Yes! Contributions are welcome:

1. Read [CONTRIBUTING.md](../../CONTRIBUTING.md)
2. Fork the repository
3. Make your changes
4. Submit a pull request

---

## Getting Help

### Documentation Resources

- **Quick Reference**: [README.md](../../README.md)
- **Project Reference**: [docs/PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md)
- **API Documentation**: [docs/api/README.md](../api/README.md)
- **Developer Guide**: [docs/developer-guide/MODULE_DEVELOPMENT.md](../developer-guide/MODULE_DEVELOPMENT.md)

### Command-Line Help

```bash
# Show all options
./src/workflow/execute_tests_docs_workflow.sh --help

# Show version
./src/workflow/execute_tests_docs_workflow.sh --version

# Show tech stack detection
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack

# Show ML optimization status
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status
```

### Community Support

- **GitHub Issues**: https://github.com/mpbarbosa/ai_workflow/issues
- **GitHub Discussions**: https://github.com/mpbarbosa/ai_workflow/discussions
- **Email**: mpbarbosa@gmail.com

---

## Next Steps

Now that you understand the basics:

1. ✅ **Install the tool** following the installation section
2. ✅ **Run your first workflow** on a test project
3. ✅ **Review the results** and understand the reports
4. ✅ **Integrate into daily workflow** using templates or hooks
5. ✅ **Customize for your needs** with specific step combinations

**Happy automating! 🚀**

---

## Version History

- **v3.1.0** (2026-01-30): Audio notifications, bootstrap documentation (step 0b)
- **v3.0.0** (2026-01-28): Pre-commit hooks, enhanced dependency graph
- **v2.9.0** (2025-12-30): Auto-documentation generation
- **v2.8.0** (2025-12-26): Multi-stage pipeline
- **v2.7.0** (2025-12-25): ML optimization
- **v2.6.0** (2025-12-24): Auto-commit, workflow templates, IDE integration

See [CHANGELOG.md](../../CHANGELOG.md) for complete history.
