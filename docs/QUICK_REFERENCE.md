# AI Workflow Automation - Quick Reference

**Version**: v4.0.0  
**One-Page Cheat Sheet** for common operations

---

## 🚀 Quick Start

```bash
# Run workflow on current project
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Run on different project
./execute_tests_docs_workflow.sh --target /path/to/project

# Full optimization (recommended)
./execute_tests_docs_workflow.sh --smart-execution --parallel --auto
```

---

## 📋 Common Commands

### Basic Execution
```bash
# Standard run with prompts
./execute_tests_docs_workflow.sh

# Automatic mode (no prompts)
./execute_tests_docs_workflow.sh --auto

# Dry run (preview only)
./execute_tests_docs_workflow.sh --dry-run

# Force fresh start
./execute_tests_docs_workflow.sh --no-resume
```

### Performance Options
```bash
# Smart execution (skip unnecessary steps)
./execute_tests_docs_workflow.sh --smart-execution

# Parallel execution (run steps simultaneously)
./execute_tests_docs_workflow.sh --parallel

# ML optimization (requires 10+ runs)
./execute_tests_docs_workflow.sh --ml-optimize

# Multi-stage pipeline
./execute_tests_docs_workflow.sh --multi-stage

# Combined (best performance)
./execute_tests_docs_workflow.sh --smart-execution --parallel --ml-optimize --auto
```

### Workflow Templates
```bash
# Documentation only (3-4 min)
./templates/workflows/docs-only.sh

# Tests only (8-10 min)
./templates/workflows/test-only.sh

# Full feature development (15-20 min)
./templates/workflows/feature.sh
```

### Selective Execution
```bash
# Run specific steps by name (NEW v4.0.0)
./execute_tests_docs_workflow.sh --steps documentation_updates,test_execution,git_finalization

# Run specific steps by index (legacy)
./execute_tests_docs_workflow.sh --steps 0,2,3,5

# Mixed syntax - combine names and indices (NEW v4.0.0)
./execute_tests_docs_workflow.sh --steps 0,documentation_updates,test_execution,12

# Skip AI steps
./execute_tests_docs_workflow.sh --skip-ai

# Disable AI caching
./execute_tests_docs_workflow.sh --no-ai-cache
```

### Configuration
```bash
# Initialize project configuration
./execute_tests_docs_workflow.sh --init-config

# Show detected tech stack
./execute_tests_docs_workflow.sh --show-tech-stack

# Use custom config file
./execute_tests_docs_workflow.sh --config-file .my-config.yaml
```

### Pre-Commit Hooks (v3.0.0)
```bash
# Install pre-commit hooks
./execute_tests_docs_workflow.sh --install-hooks

# Test hooks without committing
./execute_tests_docs_workflow.sh --test-hooks
```

### Documentation Generation (v2.9.0)
```bash
# Generate documentation reports
./execute_tests_docs_workflow.sh --generate-docs

# Update CHANGELOG automatically
./execute_tests_docs_workflow.sh --update-changelog

# Generate API docs
./execute_tests_docs_workflow.sh --generate-api-docs

# All documentation features
./execute_tests_docs_workflow.sh --generate-docs --update-changelog --generate-api-docs
```

### Auto-Commit (v2.6.0)
```bash
# Automatically commit workflow artifacts
./execute_tests_docs_workflow.sh --auto-commit
```

### Visualization & Diagnostics
```bash
# Show dependency graph
./execute_tests_docs_workflow.sh --show-graph

# View pipeline configuration
./execute_tests_docs_workflow.sh --show-pipeline

# Show ML optimization status
./execute_tests_docs_workflow.sh --show-ml-status

# List available steps
./execute_tests_docs_workflow.sh --list-steps

# Health check
./src/workflow/lib/health_check.sh
```

---

## 🎯 Common Workflows

### Daily Development
```bash
# Fast iteration on documentation
./templates/workflows/docs-only.sh

# Code + tests development (v4.0.0: use step names)
./execute_tests_docs_workflow.sh --steps pre_analysis,config_validation,directory_validation,test_generation,test_execution --smart-execution

# Legacy numeric syntax also works
./execute_tests_docs_workflow.sh --steps 0,3,4,7,8 --smart-execution
```

### Pre-Release
```bash
# Full validation with all checks
./execute_tests_docs_workflow.sh --auto --no-resume

# With auto-commit and docs generation
./execute_tests_docs_workflow.sh --auto --auto-commit --generate-docs --update-changelog
```

### CI/CD Pipeline
```bash
# Fast automated validation
./execute_tests_docs_workflow.sh --auto --smart-execution --parallel --no-resume

# With quality gates
./execute_tests_docs_workflow.sh --auto --ml-optimize --multi-stage
```

### Troubleshooting
```bash
# Verbose logging
./execute_tests_docs_workflow.sh --verbose

# Dry run to preview
./execute_tests_docs_workflow.sh --dry-run --verbose

# Skip problematic steps (v4.0.0: use step names)
./execute_tests_docs_workflow.sh --steps pre_analysis,consistency_analysis,directory_validation,code_quality_validation,version_update

# Legacy numeric syntax
./execute_tests_docs_workflow.sh --steps 0,2,5,10,15
```

---

## 📊 Performance Characteristics

| Mode | Time (docs) | Time (code) | Time (full) | Savings |
|------|-------------|-------------|-------------|---------|
| Baseline | 23 min | 23 min | 23 min | 0% |
| Smart | 3.5 min | 14 min | 23 min | 40-85% |
| Parallel | 15.5 min | 15.5 min | 15.5 min | 33% |
| Combined | 2.3 min | 10 min | 15.5 min | 57-90% |
| With ML | 1.5 min | 6-7 min | 10-11 min | 70-93% |

---

## 🔧 Configuration Files

### Primary Files
- `.workflow-config.yaml` - Project configuration
- `.workflow_core/config/ai_helpers.yaml` - AI prompt templates
- `.workflow_core/config/paths.yaml` - Path configuration
- `.workflow_core/config/project_kinds.yaml` - Project type definitions

### Configuration Example
```yaml
# .workflow-config.yaml
project:
  kind: nodejs_api
  name: my-project

tech_stack:
  primary_language: javascript
  frameworks:
    - express
    - jest

test:
  command: npm test
  framework: jest
```

---

## 📁 Important Directories

```
src/workflow/
├── execute_tests_docs_workflow.sh  # Main entry point
├── lib/                            # 73 library modules
├── steps/                          # 20 step modules
├── orchestrators/                  # 4 orchestrators
├── backlog/                        # Execution reports
├── logs/                           # Execution logs
├── metrics/                        # Performance data
├── .ai_cache/                      # AI response cache
└── .checkpoints/                   # Resume data

docs/
├── PROJECT_REFERENCE.md            # Single source of truth
├── api/                            # API documentation
├── user-guide/                     # User guides
├── developer-guide/                # Developer docs
└── architecture/                   # System architecture
```

---

## 🆘 Troubleshooting Quick Fixes

```bash
# Copilot CLI not available
gh copilot --version  # Install if missing

# Permission denied
chmod +x ./execute_tests_docs_workflow.sh

# Stale cache issues
rm -rf src/workflow/.ai_cache/*

# Stuck checkpoint
rm -rf src/workflow/.checkpoints/*

# Reset metrics
rm -rf src/workflow/metrics/*

# Clear logs
rm -rf src/workflow/logs/*
```

---

## 🔗 Essential Links

- **Full Documentation**: [docs/README.md](README.md)
- **Project Reference**: [docs/PROJECT_REFERENCE.md](PROJECT_REFERENCE.md)
- **User Guide**: [docs/user-guide/USER_GUIDE.md](user-guide/USER_GUIDE.md)
- **API Reference**: [docs/api/API_REFERENCE.md](api/API_REFERENCE.md)
- **Developer Guide**: [docs/developer-guide/contributing.md](developer-guide/contributing.md)
- **Tutorials**: [docs/TUTORIALS.md](TUTORIALS.md)

---

## 💡 Pro Tips

1. **Start with templates**: Use `./templates/workflows/` for common scenarios
2. **Enable smart execution**: Saves 40-85% on partial changes
3. **Use ML optimization**: After 10+ runs, enables predictive improvements
4. **Multi-stage pipeline**: 80%+ of runs complete in first 2 stages
5. **AI caching**: Automatically reduces token usage 60-80%
6. **Auto-commit**: Combine with `--generate-docs` for complete automation
7. **Pre-commit hooks**: Catch issues before they break the build
8. **Dry run first**: Preview changes before committing

---

**For detailed information**, see [Complete Documentation](README.md)
