# Frequently Asked Questions (FAQ)

**Version**: 1.0.0  
**Last Updated**: 2026-02-10

Quick answers to common questions about AI Workflow Automation.

## Table of Contents

- [General Questions](#general-questions)
- [Getting Started](#getting-started)
- [Features & Capabilities](#features--capabilities)
- [Performance & Optimization](#performance--optimization)
- [AI Integration](#ai-integration)
- [Configuration](#configuration)
- [Workflow Execution](#workflow-execution)
- [Testing](#testing)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing & Support](#contributing--support)

---

## General Questions

### What is AI Workflow Automation?

AI Workflow Automation is an intelligent system that validates and enhances documentation, code, and tests using AI. It provides a 23-step automated pipeline with smart execution, parallel processing, and AI response caching.

**Key Features**:
- 23-step automated workflow
- 17 AI personas
- Smart execution (40-85% faster)
- 100% test coverage
- Pre-commit hooks

### Who should use this?

**Ideal for**:
- Software development teams maintaining large codebases
- Individual developers seeking automated quality checks
- Projects requiring consistent documentation
- Teams using GitHub Copilot CLI
- CI/CD pipelines needing automated validation

### What are the prerequisites?

**Required**:
- Bash 4.0+
- Git
- Node.js 25.2.1+ (for JavaScript projects)
- GitHub Copilot CLI (for AI features)

**Optional**:
- Python 3.8+ (for Python projects)
- pytest, npm, or other test frameworks

### Is it free to use?

Yes, this project is MIT licensed and free to use. However:
- **GitHub Copilot CLI** requires a GitHub Copilot subscription
- AI features won't work without Copilot, but core workflow features will

### Does it work on Windows?

Primary support is for **Linux and macOS**. Windows support options:
- **WSL2** (Windows Subsystem for Linux) - Recommended
- **Git Bash** - Partial support, Bash 4.0+ required
- **Cygwin** - May work but untested

---

## Getting Started

### How do I install it?

```bash
# Clone repository
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Initialize submodules
git submodule update --init --recursive

# Run health check
./src/workflow/lib/health_check.sh

# Test on itself
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel
```

See [Getting Started Guide](getting-started/GETTING_STARTED.md) for details.

### How do I apply it to my project?

**Two options**:

**Option 1**: Run from project directory (default)
```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

**Option 2**: Use `--target` option
```bash
cd /path/to/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/your/project
```

### How long does it take to run?

**Depends on optimization**:
- **Full workflow**: ~23 minutes (baseline)
- **Smart execution**: 3-14 minutes (40-85% faster)
- **Combined optimization**: 1.5-11 minutes (up to 93% faster)

**Template shortcuts**:
- **Docs-only**: 3-4 minutes
- **Test-only**: 8-10 minutes
- **Feature**: 15-20 minutes

### What if I just want to try it quickly?

Use workflow templates for specific scenarios:

```bash
# Documentation changes only (fastest)
./templates/workflows/docs-only.sh

# Test development
./templates/workflows/test-only.sh

# Full feature development
./templates/workflows/feature.sh
```

---

## Features & Capabilities

### What are AI personas?

AI personas are specialized roles (17 total) that provide context-specific analysis:

- **documentation_specialist** - Documentation analysis
- **code_reviewer** - Code quality checks
- **test_engineer** - Test coverage analysis
- **front_end_developer** - Front-end implementation review
- **ui_ux_designer** - User experience analysis
- **technical_writer** - Documentation generation
- **security_analyst** - Security review
- ...and 10 more

See [AI Personas Guide](reference/AI_PERSONAS_GUIDE.md) for complete list.

### What is smart execution?

Smart execution skips unnecessary steps based on change detection:

- **Documentation-only changes**: Skip test and build steps (85% faster)
- **Code changes**: Run all relevant steps
- **Test changes**: Focus on test execution

Enable with: `--smart-execution`

### What is parallel execution?

Parallel execution runs independent steps simultaneously:

- Steps 1, 2, 3 can run in parallel
- 33% faster on average
- Requires multi-core CPU

Enable with: `--parallel`

### What is ML optimization?

ML optimization uses machine learning to predict step durations and recommend optimizations:

- Requires 10+ historical workflow runs
- 15-30% additional improvement
- Learns from your project patterns

Enable with: `--ml-optimize`

### What are workflow templates?

Pre-configured scripts for common scenarios:

- **docs-only.sh** - Documentation updates
- **test-only.sh** - Test development
- **feature.sh** - Feature development

Located in `templates/workflows/`

### What are pre-commit hooks?

Fast validation checks (< 1 second) that run before commits:

- Syntax validation
- Documentation checks
- Basic quality checks
- Prevents broken commits

Install with: `--install-hooks`

### What is checkpoint resume?

Automatic continuation from last completed step on failure:

- No need to restart from beginning
- Saves time on failures
- State preserved across runs

Disable with: `--no-resume`

---

## Performance & Optimization

### How can I make it faster?

**Use combined optimization**:
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto
```

**Expected improvements**:
- Documentation-only: ~93% faster (23min → 1.5min)
- Code changes: ~70% faster (23min → 7min)
- Full changes: ~52% faster (23min → 11min)

### Why is the first run slow?

First run baseline:
- No AI cache (cold start)
- No ML training data
- Full validation on all files

**Subsequent runs are much faster**:
- AI responses cached (60-80% reduction)
- ML predictions available (after 10 runs)
- Smart execution enabled

### How does AI caching work?

**Automatic caching**:
- Responses cached for 24 hours
- SHA256 hash-based keys
- Automatic cleanup
- 60-80% token reduction

**Cache location**: `src/workflow/.ai_cache/`

Disable with: `--no-ai-cache`

### What is multi-stage pipeline?

Progressive validation with 3 stages:

1. **Stage 1** (Core): Critical checks (5-7 min)
2. **Stage 2** (Extended): Additional validation (3-5 min)
3. **Stage 3** (Finalization): Final steps (2-3 min)

**80%+ of runs complete in first 2 stages**

Enable with: `--multi-stage`

---

## AI Integration

### Do I need GitHub Copilot?

**For AI features**: Yes, GitHub Copilot CLI subscription required

**Without Copilot**:
- Core workflow still runs
- No AI analysis or recommendations
- Manual review required

### How do I authenticate Copilot CLI?

```bash
# Install Copilot CLI
npm install -g @githubnext/github-copilot-cli

# Authenticate
gh auth login

# Verify
gh auth status
gh copilot explain "echo hello"
```

### How much does Copilot API usage cost?

Copilot CLI is included in GitHub Copilot subscription:
- **Individual**: $10/month or $100/year
- **Business**: $19/user/month

AI caching reduces token usage by 60-80%.

### Can I use a different AI provider?

Currently, only GitHub Copilot CLI is supported. Future versions may support:
- OpenAI API
- Anthropic Claude
- Local LLMs

See [ROADMAP.md](ROADMAP.md) for planned features.

### What if AI requests timeout?

**Increase timeout**:
```yaml
# .workflow-config.yaml
ai:
  timeout: 300  # Increase from default 180s
```

**Or skip AI steps**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --steps 0,3,4,12
```

---

## Configuration

### How do I configure my project?

**Interactive wizard** (recommended):
```bash
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

**Manual configuration**:
```yaml
# .workflow-config.yaml
project:
  name: "my-project"
  kind: "nodejs_api"

tech_stack:
  primary_language: "javascript"
  frameworks:
    - "express"
  
testing:
  framework: "jest"
  command: "npm test"
```

See [Configuration Reference](CONFIGURATION_REFERENCE.md) for all options.

### What project kinds are supported?

**12+ project types**:
- `shell_automation` - Shell script projects
- `nodejs_api` - Node.js API servers
- `nodejs_cli` - Node.js CLI tools
- `nodejs_library` - Node.js libraries
- `static_website` - Static HTML/CSS/JS
- `react_spa` - React single-page apps
- `vue_spa` - Vue.js apps
- `python_api` - Python API servers
- `python_cli` - Python CLI tools
- `python_library` - Python libraries
- `documentation` - Documentation-only projects
- `generic` - Generic projects

### How is tech stack detected?

**Automatic detection** based on:
- Package managers (`package.json`, `requirements.txt`, etc.)
- Frameworks (React, Vue, Django, Flask, etc.)
- Configuration files (`.eslintrc`, `pytest.ini`, etc.)
- Directory structure (`src/`, `tests/`, etc.)

**Override detection**:
```yaml
tech_stack:
  primary_language: "python"
  frameworks: ["flask"]
```

### Can I customize AI prompts?

AI prompts are defined in:
- `.workflow_core/config/ai_helpers.yaml` - Base prompts
- `.workflow_core/config/ai_prompts_project_kinds.yaml` - Project-specific prompts

**Custom prompts**: Edit these files or create project-specific overrides in `.workflow-config.yaml`

---

## Workflow Execution

### How do I run specific steps only?

**Use descriptive names** (v4.0.0+):
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution,git_finalization
```

**Or numeric indices** (legacy):
```bash
./src/workflow/execute_tests_docs_workflow.sh --steps 0,3,4,12
```

**Mixed syntax** (v4.0.0+):
```bash
./src/workflow/execute_tests_docs_workflow.sh --steps 0,documentation_updates,12
```

### What do the 23 steps do?

**Key steps** (see [Project Reference](PROJECT_REFERENCE.md) for complete list):
- **Step 0**: Pre-flight checks and change analysis
- **Step 0a**: Pre-processing and setup
- **Step 0b**: Bootstrap documentation (generate from scratch)
- **Step 1**: Documentation analysis
- **Step 2**: Documentation updates
- **Step 3**: Test execution
- **Step 4**: Test coverage review
- **Step 5**: Code quality analysis
- **Step 11.7**: Front-end development analysis
- **Step 15**: UX/accessibility analysis
- **Step 16**: Post-processing and cleanup

### How do I skip a step interactively?

**NEW in v4.1.0**: Press **space bar** at continue prompts to skip the next step

```
Continue with Step 5? (Y/n/space to skip next step):
[Press space] → Step 5 skipped
```

### What is auto mode?

Auto mode runs without user interaction:

```bash
./src/workflow/execute_tests_docs_workflow.sh --auto
```

**Use cases**:
- CI/CD pipelines
- Scheduled runs
- Automated testing

### How do I see what will run?

**Dry run mode**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --dry-run
```

Shows:
- Steps that will execute
- Steps that will be skipped
- Estimated duration
- Dependencies

### Can I auto-commit the results?

**Yes** (v2.6.0+):
```bash
./src/workflow/execute_tests_docs_workflow.sh --auto-commit
```

Automatically commits:
- Documentation updates
- Test changes
- Generated reports
- With intelligent commit messages

---

## Testing

### How do I run tests?

**Run all tests**:
```bash
./tests/run_all_tests.sh
```

**Run specific suites**:
```bash
./tests/run_all_tests.sh --unit          # Unit tests only
./tests/run_all_tests.sh --integration   # Integration tests only
```

**Run individual tests**:
```bash
./src/workflow/lib/test_ai_helpers.sh
./src/workflow/lib/test_change_detection.sh
```

### What testing frameworks are supported?

**Detected automatically**:
- **Node.js**: Jest, Mocha, Ava, Tape
- **Python**: pytest, unittest, nose
- **Shell**: Custom test framework
- **Ruby**: RSpec
- **Go**: go test

**Manual configuration**:
```yaml
testing:
  framework: "jest"
  command: "npm test"
  coverage_command: "npm test -- --coverage"
```

### How is test coverage calculated?

**Coverage tools** (auto-detected):
- **JavaScript**: Istanbul/nyc, Jest coverage
- **Python**: coverage.py, pytest-cov
- **Go**: go test -cover

**Reports generated**:
- `test-results/coverage/` - Coverage reports
- `backlog/workflow_*/TEST_COVERAGE_REPORT.md` - Analysis

### What if my tests fail?

**Workflow behavior**:
1. Captures test failures
2. Generates failure report
3. Creates health check report
4. Allows you to fix and resume

**Recovery**:
```bash
# Fix tests
vim tests/my_test.js

# Resume workflow
./src/workflow/execute_tests_docs_workflow.sh
```

---

## Documentation

### What documentation is generated?

**Automatic generation**:
- **CHANGELOG.md** - Version history updates
- **API documentation** - Code reference docs
- **Workflow reports** - Execution summaries
- **Health check reports** - Status and failures
- **Test reports** - Coverage and results

### How do I bootstrap documentation?

**Step 0b: Bootstrap Documentation** (v3.1.0+):
```bash
# Run bootstrap step only
./src/workflow/execute_tests_docs_workflow.sh --steps bootstrap_docs

# Or include in full workflow (runs automatically if docs missing)
./src/workflow/execute_tests_docs_workflow.sh
```

Uses **technical_writer** AI persona to generate comprehensive documentation from scratch.

### How do I update CHANGELOG automatically?

**Enable auto-documentation** (v2.9.0+):
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --generate-docs \
  --update-changelog
```

Generates:
- Version bump entries
- Feature descriptions
- Bug fixes
- Breaking changes

### Where are workflow artifacts stored?

**Artifact locations**:
- **Logs**: `src/workflow/logs/workflow_YYYYMMDD_HHMMSS/`
- **Reports**: `src/workflow/backlog/workflow_YYYYMMDD_HHMMSS/`
- **Metrics**: `src/workflow/metrics/`
- **Cache**: `src/workflow/.ai_cache/`
- **Test results**: `test-results/`

**Cleanup old artifacts**:
```bash
./scripts/cleanup_artifacts.sh --all --older-than 30
```

---

## Troubleshooting

### Workflow hangs or freezes - what do I do?

1. **Cancel**: Press `Ctrl+C`
2. **Check logs**: `cat src/workflow/logs/workflow_*/execution.log`
3. **Resume**: `./src/workflow/execute_tests_docs_workflow.sh`
4. **Force fresh start**: `./src/workflow/execute_tests_docs_workflow.sh --no-resume`

See [Troubleshooting Guide](TROUBLESHOOTING.md) for detailed solutions.

### How do I debug issues?

**Enable debug mode**:
```bash
export DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh

# Or trace execution
bash -x ./src/workflow/execute_tests_docs_workflow.sh 2>&1 | tee debug.log
```

**Check health**:
```bash
./src/workflow/lib/health_check.sh
cat src/workflow/backlog/workflow_*/WORKFLOW_HEALTH_CHECK.md
```

### Where can I find help?

**Documentation**:
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues
- [Project Reference](PROJECT_REFERENCE.md) - Complete reference
- [Getting Started](getting-started/GETTING_STARTED.md) - Basics

**Community**:
- **Issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Discussions**: GitHub Discussions (planned)
- **Maintainer**: mpbarbosa@gmail.com

---

## Contributing & Support

### How can I contribute?

**Ways to contribute**:
- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation
- Write tests

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### What license is this under?

**MIT License** - Free to use, modify, and distribute.

See [LICENSE](../LICENSE) for full text.

### How do I report a bug?

1. **Check existing issues**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
2. **Gather information**:
   - Version: `grep version README.md`
   - OS: `uname -a`
   - Error messages
   - Logs
3. **Create issue** with template
4. Include reproduction steps

### Can I request features?

**Yes!** Open a feature request:
- [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
- Label: "enhancement"
- Describe use case and benefits

See [ROADMAP.md](ROADMAP.md) for planned features.

### How often is this updated?

**Release schedule**:
- **Patch releases**: As needed (bug fixes)
- **Minor releases**: ~1-2 months (features)
- **Major releases**: ~3-6 months (breaking changes)

**Recent activity**:
- v4.1.0 (2026-02-10) - Interactive step skipping
- v4.0.1 (2026-02-08) - Front-end & UX analysis
- v4.0.0 (2026-02-08) - Configuration-driven steps
- v3.3.0 (2026-02-08) - Git commit hash tracking

See [CHANGELOG.md](../CHANGELOG.md) for complete history.

---

## Quick Reference

### Common Commands

```bash
# Basic usage
./src/workflow/execute_tests_docs_workflow.sh

# Optimized execution
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel

# Full optimization
./src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution --parallel --ml-optimize --multi-stage --auto

# Specific steps (v4.0.0+)
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution

# Dry run
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Initialize configuration
./src/workflow/execute_tests_docs_workflow.sh --init-config

# Install pre-commit hooks
./src/workflow/execute_tests_docs_workflow.sh --install-hooks
```

### Useful Scripts

```bash
# Run all tests
./tests/run_all_tests.sh

# Health check
./src/workflow/lib/health_check.sh

# Clean artifacts
./scripts/cleanup_artifacts.sh --all --older-than 30

# Validate documentation
python3 scripts/check_doc_links.py
```

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))

**Related Documentation**:
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Project Reference](PROJECT_REFERENCE.md)
- [Getting Started](getting-started/GETTING_STARTED.md)
- [Configuration Reference](CONFIGURATION_REFERENCE.md)
