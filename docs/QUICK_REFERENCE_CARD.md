# AI Workflow Automation - Quick Reference Card

**Version**: v4.1.0  
**Last Updated**: 2026-02-10  
**Print-Friendly**: Yes

This is a condensed reference for quick lookups. For complete documentation, see [Project Reference](PROJECT_REFERENCE.md).

---

## 🚀 Quick Start

```bash
# Clone and setup
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow
git submodule update --init --recursive
./src/workflow/lib/health_check.sh

# Basic usage (from project directory)
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Or use --target
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/project
```

---

## 📋 Common Commands

### Fast Workflows (Templates)

```bash
./templates/workflows/docs-only.sh     # 3-4 min - documentation only
./templates/workflows/test-only.sh     # 8-10 min - test development
./templates/workflows/feature.sh       # 15-20 min - feature development
```

### Optimized Execution

```bash
# Smart + Parallel (recommended)
./execute_tests_docs_workflow.sh --smart-execution --parallel

# Full optimization
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto

# With auto-commit
./execute_tests_docs_workflow.sh --smart-execution --parallel --auto-commit
```

### Selective Steps

```bash
# By descriptive names (v4.0.0+)
./execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution,git_finalization

# By numbers (legacy)
./execute_tests_docs_workflow.sh --steps 0,2,3,12

# Mixed syntax
./execute_tests_docs_workflow.sh --steps 0,documentation_updates,12
```

### Configuration

```bash
./execute_tests_docs_workflow.sh --init-config        # Run wizard
./execute_tests_docs_workflow.sh --show-tech-stack    # View detected tech
./execute_tests_docs_workflow.sh --show-pipeline      # View pipeline
./execute_tests_docs_workflow.sh --show-ml-status     # ML optimization status
```

### Hooks & Testing

```bash
./execute_tests_docs_workflow.sh --install-hooks      # Install pre-commit hooks
./execute_tests_docs_workflow.sh --test-hooks         # Test hooks
./execute_tests_docs_workflow.sh --dry-run            # Preview execution
```

---

## 🎯 Step Quick Reference

| Step | Name | Description | AI Persona |
|------|------|-------------|------------|
| 0 | Pre-Analyze | Pre-flight checks, change detection | - |
| 0a | Pre-Process | Pre-processing setup | - |
| 0b | Bootstrap Docs | Generate docs from scratch | technical_writer |
| 1 | Documentation Analysis | Analyze documentation | documentation_specialist |
| 2 | Documentation Updates | Update documentation | documentation_specialist |
| 3 | Test Execution | Run tests | test_engineer |
| 4 | Test Coverage | Coverage review | test_engineer |
| 5 | Code Quality | Code quality checks | code_reviewer |
| 6 | Link Validation | Validate doc links | - |
| 7 | Context Validation | Validate context blocks | - |
| 8 | API Documentation | API doc validation | documentation_specialist |
| 9 | Examples Validation | Validate code examples | - |
| 10 | Config Validation | Configuration checks | configuration_specialist |
| 11 | Health Check | System health check | - |
| 11.7 | Front-End Analysis | Technical implementation review | front_end_developer |
| 12 | Git Operations | Git finalization | - |
| 13 | Summary | Generate workflow summary | - |
| 14 | Final Validation | Final validation checks | - |
| 15 | UX Analysis | User experience review | ui_ux_designer |
| 16 | Post-Process | Post-processing cleanup | - |

---

## 🔧 Command-Line Options

### Execution Mode

| Option | Description |
|--------|-------------|
| `--auto` | Non-interactive mode (for CI/CD) |
| `--dry-run` | Preview without execution |
| `--no-resume` | Force fresh start (ignore checkpoints) |

### Optimization

| Option | Description | Speed Gain |
|--------|-------------|------------|
| `--smart-execution` | Skip unnecessary steps | 40-85% |
| `--parallel` | Run independent steps simultaneously | 33% |
| `--ml-optimize` | ML-driven optimization | 15-30% |
| `--multi-stage` | Progressive validation | 20-40% |

### Step Selection

| Option | Description |
|--------|-------------|
| `--steps <list>` | Run specific steps (names or numbers) |
| `--skip <list>` | Skip specific steps |

### Documentation

| Option | Description |
|--------|-------------|
| `--generate-docs` | Auto-generate documentation |
| `--update-changelog` | Update CHANGELOG.md |
| `--generate-api-docs` | Generate API documentation |

### Git & Hooks

| Option | Description |
|--------|-------------|
| `--auto-commit` | Automatically commit artifacts |
| `--install-hooks` | Install pre-commit hooks |
| `--test-hooks` | Test hooks without committing |

### Cache

| Option | Description |
|--------|-------------|
| `--no-ai-cache` | Disable AI response caching |
| `--clear-cache` | Clear AI cache before run |

### Targeting

| Option | Description |
|--------|-------------|
| `--target <path>` | Run on specified project path |

### Information

| Option | Description |
|--------|-------------|
| `--show-tech-stack` | Display detected tech stack |
| `--show-pipeline` | View pipeline configuration |
| `--show-ml-status` | ML optimization status |
| `--show-graph` | Display dependency graph |
| `--version` | Show version information |
| `--help` | Display help message |

---

## 📁 Directory Structure

```
src/workflow/
├── execute_tests_docs_workflow.sh    # Main entry point
├── lib/                              # 81 library modules
│   ├── ai_helpers.sh                # AI integration
│   ├── change_detection.sh          # Change analysis
│   ├── metrics.sh                   # Performance metrics
│   └── ...
├── steps/                            # 22 step modules
│   ├── pre_analyze.sh               # Step 0
│   ├── documentation_updates.sh     # Step 2
│   └── ...
├── orchestrators/                    # 4 orchestrators
│   ├── pre_flight.sh
│   ├── validation.sh
│   └── ...
├── .ai_cache/                        # AI response cache
├── backlog/                          # Execution history
├── logs/                             # Execution logs
├── metrics/                          # Performance data
└── summaries/                        # AI summaries

.workflow_core/config/                # Configuration (submodule)
├── paths.yaml
├── ai_helpers.yaml                   # AI prompt templates
├── ai_prompts_project_kinds.yaml
└── workflow_steps.yaml
```

---

## 🎨 AI Personas (17 Total)

| Persona | Purpose | Used In |
|---------|---------|---------|
| **documentation_specialist** | Documentation analysis | Steps 1, 2, 8 |
| **code_reviewer** | Code quality checks | Step 5 |
| **test_engineer** | Test coverage analysis | Steps 3, 4 |
| **technical_writer** | Doc generation | Step 0b |
| **front_end_developer** | Front-end review | Step 11.7 |
| **ui_ux_designer** | UX analysis | Step 15 |
| **security_analyst** | Security review | Custom steps |
| **performance_engineer** | Performance review | Custom steps |
| **configuration_specialist** | Config validation | Step 10 |
| **devops_engineer** | DevOps review | Custom steps |
| **database_expert** | Database review | Custom steps |
| **technical_lead** | Architecture review | Custom steps |
| **qa_engineer** | Quality assurance | Custom steps |
| **release_manager** | Release planning | Custom steps |
| **integration_specialist** | Integration review | Custom steps |
| **accessibility_expert** | Accessibility review | Custom steps |
| **api_architect** | API design review | Custom steps |

---

## ⚡ Performance Characteristics

### Execution Times

| Change Type | Baseline | Smart | Parallel | Combined | + ML |
|-------------|----------|-------|----------|----------|------|
| **Docs Only** | 23 min | 3.5 min | 15.5 min | 2.3 min | **1.5 min** |
| **Code Changes** | 23 min | 14 min | 15.5 min | 10 min | **6-7 min** |
| **Full Changes** | 23 min | 23 min | 15.5 min | 15.5 min | **10-11 min** |

### Cache Statistics

- **AI Cache Hit Rate**: 60-80% (after first run)
- **Token Reduction**: 60-80% (with caching)
- **Cache TTL**: 24 hours (configurable)

---

## 🔍 Troubleshooting Quick Fixes

### Common Issues

| Issue | Solution |
|-------|----------|
| **Workflow hangs** | Press `Ctrl+C`, then resume: `./execute_tests_docs_workflow.sh` |
| **Permission denied** | `chmod +x src/workflow/execute_tests_docs_workflow.sh` |
| **Copilot not found** | `npm install -g @githubnext/github-copilot-cli` |
| **Authentication failed** | `gh auth login` |
| **Submodule missing** | `git submodule update --init --recursive` |
| **Step fails** | Check logs: `cat src/workflow/logs/workflow_*/step_*_*.log` |
| **Cache issues** | Clear cache: `rm -rf src/workflow/.ai_cache/*` |

### Debug Mode

```bash
# Enable debug output
export DEBUG=1
./execute_tests_docs_workflow.sh

# Enable verbose mode
export VERBOSE=1
./execute_tests_docs_workflow.sh

# Full trace
bash -x ./execute_tests_docs_workflow.sh 2>&1 | tee debug.log
```

---

## 📊 Configuration Files

### Primary Config: `.workflow-config.yaml`

```yaml
project:
  name: "my-project"
  kind: "nodejs_api"  # or shell_automation, react_spa, python_app, etc.

tech_stack:
  primary_language: "javascript"
  frameworks:
    - "express"
  testing:
    framework: "jest"
    command: "npm test"

optimization:
  smart_execution: true
  parallel: true
  ml_optimize: true

ai:
  timeout: 180
  cache_enabled: true
  cache_ttl: 86400
```

### Project Kinds

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
- `documentation` - Documentation projects
- `generic` - Generic projects

---

## 🧪 Testing

```bash
# Run all tests
./tests/run_all_tests.sh

# Run specific suites
./tests/run_all_tests.sh --unit
./tests/run_all_tests.sh --integration
./tests/run_all_tests.sh --e2e

# Test specific module
./src/workflow/lib/test_ai_helpers.sh
./src/workflow/lib/test_change_detection.sh
```

---

## 📦 Utility Scripts

```bash
# Cleanup artifacts
./scripts/cleanup_artifacts.sh --all --older-than 30

# Validate documentation
python3 scripts/check_doc_links.py
python3 .workflow_core/scripts/validate_structure.py docs/

# Version management
./scripts/bump_version.sh <new-version>
./scripts/standardize_dates.sh
```

---

## 🌐 CI/CD Integration

### GitHub Actions

```yaml
- name: Run AI Workflow
  run: |
    ./src/workflow/execute_tests_docs_workflow.sh \
      --auto --smart-execution --parallel
```

### GitLab CI

```yaml
ai_workflow:
  script:
    - ./src/workflow/execute_tests_docs_workflow.sh --auto --smart-execution
```

### Jenkins

```groovy
stage('AI Workflow') {
    steps {
        sh './src/workflow/execute_tests_docs_workflow.sh --auto --parallel'
    }
}
```

---

## 🔗 Key Resources

### Documentation

- **[Project Reference](PROJECT_REFERENCE.md)** - Complete feature list
- **[Getting Started](getting-started/GETTING_STARTED.md)** - Basics
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues
- **[FAQ](FAQ.md)** - Frequently asked questions
- **[Module Dev Guide](MODULE_DEVELOPMENT_GUIDE.md)** - Creating modules
- **[Testing Guide](TESTING_BEST_PRACTICES.md)** - Testing best practices
- **[Advanced Scenarios](ADVANCED_USAGE_SCENARIOS.md)** - Complex use cases
- **[Integration Guide](INTEGRATION_GUIDE.md)** - CI/CD integration

### API Reference

- **[Module API Reference](MODULE_API_REFERENCE.md)** - All 81 modules
- **[API Examples](API_EXAMPLES.md)** - Code examples
- **[Script Reference](../src/workflow/SCRIPT_REFERENCE.md)** - Script API

### Guides

- **[ML Optimization](ML_OPTIMIZATION_GUIDE.md)** - ML features
- **[Multi-Stage Pipeline](MULTI_STAGE_PIPELINE_GUIDE.md)** - Pipeline stages
- **[Configuration Reference](CONFIGURATION_REFERENCE.md)** - All options
- **[Migration Guide](MIGRATION_GUIDE_v4.0.md)** - Version migration

---

## 🆘 Getting Help

### Health Check

```bash
./src/workflow/lib/health_check.sh
cat src/workflow/backlog/workflow_*/WORKFLOW_HEALTH_CHECK.md
```

### View Logs

```bash
# Latest execution log
ls -lt src/workflow/logs/workflow_* | head -1

# View log
cat src/workflow/logs/workflow_$(date +%Y%m%d)_*/execution.log
```

### Metrics

```bash
# Current run metrics
cat src/workflow/metrics/current_run.json | jq .

# Historical metrics
cat src/workflow/metrics/history.jsonl | jq .
```

### Support

- **GitHub Issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Documentation**: All docs in `docs/` directory
- **Email**: mpbarbosa@gmail.com

---

## 🎯 Version Information

**Current Version**: v4.1.0  
**Release Date**: 2026-02-10  
**License**: MIT  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))

### Recent Versions

- **v4.1.0** (2026-02-10) - Interactive step skipping
- **v4.0.1** (2026-02-08) - Front-end & UX analysis
- **v4.0.0** (2026-02-08) - Configuration-driven steps
- **v3.3.0** (2026-02-08) - Git commit hash tracking
- **v3.1.0** (2026-01-18) - Audio notifications + bootstrap docs
- **v3.0.0** (2026-01-15) - Pre-commit hooks

See [CHANGELOG.md](../CHANGELOG.md) for complete history.

---

## 💡 Tips & Tricks

1. **First run is slower** - AI cache needs to warm up, ML needs training data
2. **Use smart execution** - Saves 40-85% execution time
3. **Enable parallel execution** - 33% faster on multi-core systems
4. **ML optimization requires 10+ runs** - But provides 15-30% additional improvement
5. **Multi-stage pipeline** - 80%+ of runs complete in first 2 stages
6. **AI caching reduces costs** - 60-80% token reduction
7. **Use workflow templates** - Fastest way to run common scenarios
8. **Pre-commit hooks** - Catch issues early (< 1 second validation)
9. **Interactive skip (v4.1.0)** - Press space bar at continue prompts
10. **Auto-commit saves time** - Automatically commit workflow artifacts

---

## 🚨 Important Notes

- **Bash 4.0+ required** (macOS ships with 3.2 - use Homebrew)
- **GitHub Copilot CLI subscription needed** for AI features
- **Core workflow runs without AI** - Just skip AI analysis steps
- **100% test coverage** maintained
- **Configuration-driven steps** (v4.0.0) - Use descriptive names
- **Checkpoint resume** - Automatically continues from failures
- **Artifact cleanup** recommended every 30 days

---

**Print this page for quick reference!**

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Format**: Quick Reference Card  
**Pages**: 1-4 (when printed)
