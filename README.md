# AI Workflow Automation

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/mpbarbosa/ai_workflow/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Code Quality](https://img.shields.io/badge/quality-B%2B%20(87%2F100)-brightgreen.svg)](src/COMPREHENSIVE_CODE_QUALITY_REPORT.md)
[![Tests](https://img.shields.io/badge/tests-37%2B%20passing-brightgreen.svg)](tests/)
[![Documentation](https://img.shields.io/badge/docs-comprehensive-blue.svg)](docs/)
[![Test Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](tests/)
[![Shell Scripts](https://img.shields.io/badge/shell-bash%204.0%2B-blue.svg)](https://www.gnu.org/software/bash/)
[![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen.svg)](https://github.com/mpbarbosa/ai_workflow/graphs/commit-activity)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Intelligent workflow automation system for validating and enhancing documentation, code, and tests with AI support.

**Migrated from**: mpbarbosa_site repository (2025-12-18)  
**Version**: v3.0.0  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)

## Overview

This repository provides a comprehensive, modular workflow automation system that leverages AI to maintain code quality, documentation consistency, and test coverage across software projects.

### Key Features

> 📋 See [Project Reference](docs/PROJECT_REFERENCE.md) for complete feature list, module inventory, and version history.

**Highlights**:
- **17-Step Automated Pipeline** with checkpoint resume
- **62 Library Modules** + **17 Step Modules** + **4 Orchestrators**
- **14 AI Personas** with GitHub Copilot CLI integration
- **Smart Execution**: 40-85% faster (change-based step skipping)
- **Parallel Execution**: 33% faster (independent steps run simultaneously)
- **AI Response Caching**: 60-80% token reduction
- **Pre-Commit Hooks** (NEW v2.10.0): Fast validation checks to prevent broken commits
- **Auto-Documentation** (v2.9.0): Generate reports and CHANGELOG from workflow execution
- **Multi-Stage Pipeline** (v2.8.0): Progressive validation with 3-stage intelligent execution
- **ML Optimization** (v2.7.0): Predictive workflow intelligence with 15-30% additional improvement
- **Auto-Commit Workflow** (v2.6.0): Automatic artifact commits with intelligent message generation
- **Workflow Templates** (v2.6.0): Docs-only, test-only, and feature development templates
- **IDE Integration** (v2.6.0): VS Code tasks with keyboard shortcuts
- **UX Analysis** (v2.4.0): Accessibility checking with WCAG 2.1
- **100% Test Coverage**: 37+ automated tests
- **Code Quality**: B+ (87/100) with comprehensive assessment

## Quick Start

### Running on This Repository

```bash
# Clone repository
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Run all tests
./tests/run_all_tests.sh

# Run specific test suites
./tests/run_all_tests.sh --unit          # Unit tests only
./tests/run_all_tests.sh --integration   # Integration tests only

# Test the workflow on itself (self-testing - recommended first step)
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel
```

> **💡 Tip**: The best way to understand the workflow is to run it on itself or on a test project.

### Applying to Target Projects

To use this workflow on other projects (e.g., mpbarbosa_site):

```bash
# Option 1: Run from project directory (default behavior)
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Option 2: Use --target flag from anywhere
cd ai_workflow
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/project \
  --smart-execution \
  --parallel \
  --auto

# Option 3: Force fresh start (ignore checkpoints)
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --no-resume \
  --auto

# Option 4: With dependency visualization
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --show-graph

# Option 5: Configure project interactively
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --init-config

# Option 6: Show tech stack configuration
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
  --show-tech-stack

# Option 7: Use workflow templates (NEW v2.6.0)
./templates/workflows/docs-only.sh    # Documentation changes only (3-4 min)
./templates/workflows/test-only.sh    # Test development (8-10 min)
./templates/workflows/feature.sh      # Full feature workflow (15-20 min)

# Option 8: Auto-commit workflow artifacts (NEW v2.6.0)
./src/workflow/execute_tests_docs_workflow.sh --auto-commit

# Option 9: ML-driven optimization (NEW v2.7.0)
# Requires 10+ historical workflow runs for accurate predictions
./src/workflow/execute_tests_docs_workflow.sh \
  --ml-optimize \
  --smart-execution \
  --parallel \
  --auto

# Option 10: Check ML system status (NEW v2.7.0)
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status

# Option 11: VS Code integration (v2.6.0)
# Press Ctrl+Shift+B in VS Code to access 10 pre-configured tasks
cp -r ai_workflow/src/workflow /path/to/target/project/src/
cd /path/to/target/project
./src/workflow/execute_tests_docs_workflow.sh

# Option 12: Multi-stage pipeline (NEW v2.8.0)
# Progressive validation: 80%+ of runs complete in first 2 stages
./src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --smart-execution \
  --parallel

# Option 13: View pipeline configuration (NEW v2.8.0)
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline

# Option 14: Force all stages (NEW v2.8.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --multi-stage \
  --manual-trigger
```

**Performance Tips**:
- Use `--multi-stage` for intelligent progressive validation
- Use `--smart-execution` for 40-85% faster execution
- Use `--parallel` for 33% additional speed improvement
- Use `--ml-optimize` for 15-30% ML-driven improvements (requires 10+ runs)
- **📊 See [Performance Benchmarks](docs/reference/performance-benchmarks.md) for detailed methodology and raw data**
- AI responses cached automatically (60-80% token savings)
- Checkpoint resume enabled by default (use `--no-resume` for fresh start)
- Combined optimizations: Up to 90% faster for simple changes

## Documentation

**📚 Complete Documentation** - See [docs/README.md](docs/README.md) and [docs/PROJECT_REFERENCE.md](docs/PROJECT_REFERENCE.md) ⭐

### Quick Start
- **[docs/ROADMAP.md](docs/ROADMAP.md)**: Future plans and development roadmap
- **[docs/reference/target-project-feature.md](docs/reference/target-project-feature.md)**: --target option guide
- **[docs/reference/target-option-quick-reference.md](docs/reference/target-option-quick-reference.md)**: Quick reference
- **[docs/reference/init-config-wizard.md](docs/reference/init-config-wizard.md)**: Configuration wizard guide

### Technical Documentation
- **[docs/design/adr/](docs/design/adr/)**: Architecture Decision Records (modular architecture, YAML config, orchestrators)
- **[docs/reference/workflow-diagrams.md](docs/reference/workflow-diagrams.md)**: Visual diagrams for complex workflows
- **[docs/RELEASE_NOTES_v2.6.0.md](docs/RELEASE_NOTES_v2.6.0.md)**: Latest release notes
- **[docs/workflow-automation/](docs/workflow-automation/)**: Comprehensive workflow documentation
- **[src/workflow/README.md](src/workflow/README.md)**: Module API reference
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)**: Complete system reference for GitHub Copilot

## Repository Structure

```
ai_workflow/
├── .github/                       # GitHub configuration
│   └── workflows/                 # CI/CD workflows
├── docs/                          # Comprehensive documentation
│   ├── design/adr/                # Architecture Decision Records
│   ├── reference/                 # Reference documentation
│   ├── workflow-automation/       # Workflow system docs
│   └── PROJECT_REFERENCE.md       # Authoritative project reference
├── examples/                      # Usage examples and demonstrations
│   └── using_new_features.sh      # Feature demonstration script
├── scripts/                       # Utility scripts
│   └── validate_line_counts.sh    # Documentation validation
├── src/workflow/                  # Workflow automation system
│   ├── execute_tests_docs_workflow.sh  # Main orchestrator (2,009 lines)
│   ├── lib/                       # 32 library modules (14,993 lines)
│   ├── steps/                     # 15 step modules (4,777 lines)
│   ├── config/                    # YAML configuration
│   └── backlog/                   # Execution history
├── templates/                     # Reusable templates
│   └── workflow_config/           # Workflow configuration templates
├── tests/                         # Comprehensive test suite
│   ├── fixtures/                  # Test data and mock files
│   ├── unit/                      # Unit tests (4 tests)
│   ├── integration/               # Integration tests (5 tests)
│   └── run_all_tests.sh           # Master test runner
└── README.md                      # This file
```

## Prerequisites

- Bash 4.0+
- Git
- Node.js v25.2.1+ (for test execution in target projects)
- GitHub Copilot CLI (optional, for AI features)

## CI/CD Integration

The repository includes GitHub Actions workflows for automated testing and validation:

### Workflows

- **Test Suite** (`.github/workflows/test.yml`): Runs all unit and integration tests on push/PR
- **Documentation Validation** (`.github/workflows/docs.yml`): Validates documentation consistency
- **Line Count Validation** (`.github/workflows/validate-line-counts.yml`): Ensures README accuracy

### Running Locally

```bash
# Run all tests (mirrors CI environment)
./tests/run_all_tests.sh

# Validate documentation
./scripts/validate_line_counts.sh

# Run specific test types
./tests/run_all_tests.sh --unit          # Unit tests
./tests/run_all_tests.sh --integration   # Integration tests
```

### Development Testing

The workflow includes dedicated test scripts for validation:

```bash
# Test Step 1 refactoring
./src/workflow/test_step01_refactoring.sh

# Test Step 1 simple scenarios
./src/workflow/test_step01_simple.sh

# Run all step-specific tests
for test in src/workflow/test_step*.sh; do
    echo "Running $test..."
    bash "$test"
done
```

**Available Test Suites**:
- `test_step01_refactoring.sh` - Validates Step 1 modular architecture
- `test_step01_simple.sh` - Basic Step 1 functionality tests

See [Testing Guide](docs/developer-guide/testing.md) for comprehensive test documentation.

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### MIT License Summary

- ✅ **Commercial use** - Use in commercial projects
- ✅ **Modification** - Modify the source code
- ✅ **Distribution** - Distribute copies
- ✅ **Private use** - Use privately
- ℹ️  **License and copyright notice** - Include with all copies

**Copyright © 2025 mpbarbosa**

---

## Authors and Maintainers

### Primary Author & Maintainer

**Marcelo Pereira Barbosa** ([@mpbarbosa](https://github.com/mpbarbosa))
- Email: mpbarbosa@gmail.com
- GitHub: [github.com/mpbarbosa](https://github.com/mpbarbosa)
- Role: Project creator, lead developer, and maintainer

### Project Information

- **Created**: 2025-12-14
- **Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
- **Migrated From**: mpbarbosa_site (2025-12-18)
- **Current Version**: v3.0.0 (2026-01-28)

### Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Code contributions
- Documentation improvements
- Bug reports
- Feature requests
- Testing

### Support

- **Issues**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mpbarbosa/ai_workflow/discussions)
- **Security**: Report vulnerabilities via GitHub Security Advisories

### Acknowledgments

- Built with [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli)
- Inspired by workflow automation best practices
- Community feedback and contributions

---

## Related Projects and Ecosystem

### Similar Workflow Automation Tools

This project fits into the broader ecosystem of workflow automation and documentation tools. Here are some related projects you might find useful:

#### Workflow Automation
- **[pre-commit](https://github.com/pre-commit/pre-commit)** - Framework for managing git pre-commit hooks
  - **Comparison**: Focuses on pre-commit hooks; AI Workflow provides full 15-step pipeline
  - **Use Together**: Use pre-commit for immediate checks, AI Workflow for comprehensive validation

- **[GitHub Actions](https://github.com/features/actions)** - CI/CD platform by GitHub
  - **Comparison**: Cloud-based CI/CD; AI Workflow is local-first with optional CI integration
  - **Use Together**: Run AI Workflow in GitHub Actions for automated checks

- **[Taskfile](https://github.com/go-task/task)** - Task runner alternative to Make
  - **Comparison**: General task automation; AI Workflow specialized for docs/code/tests
  - **Use Together**: Use Taskfile to orchestrate AI Workflow execution

#### Documentation Tools
- **[MkDocs](https://github.com/mkdocs/mkdocs)** - Static site generator for documentation
  - **Comparison**: Documentation rendering; AI Workflow validates and enhances docs
  - **Use Together**: AI Workflow validates, MkDocs publishes

- **[Vale](https://github.com/errata-ai/vale)** - Linter for prose and documentation
  - **Comparison**: Style/grammar checking; AI Workflow provides AI-powered analysis
  - **Use Together**: Vale for style, AI Workflow for consistency and correctness

- **[doctoc](https://github.com/thlorenz/doctoc)** - Generates table of contents for markdown
  - **Comparison**: TOC generation; AI Workflow comprehensive doc validation
  - **Use Together**: doctoc for TOCs, AI Workflow for validation

#### Code Quality Tools
- **[ShellCheck](https://github.com/koalaman/shellcheck)** - Shell script static analysis
  - **Comparison**: Shell script linting; AI Workflow broader validation
  - **Use Together**: ShellCheck for scripts, AI Workflow for full project

- **[SonarQube](https://github.com/SonarSource/sonarqube)** - Code quality and security
  - **Comparison**: Enterprise quality platform; AI Workflow developer-focused
  - **Use Together**: SonarQube for teams, AI Workflow for individuals

#### AI-Powered Tools
- **[GitHub Copilot](https://github.com/features/copilot)** - AI pair programmer
  - **Comparison**: Code generation; AI Workflow uses Copilot for validation/analysis
  - **Use Together**: Copilot writes code, AI Workflow validates it

- **[ChatGPT](https://openai.com/chatgpt)** - AI assistant
  - **Comparison**: General AI; AI Workflow specialized for workflows
  - **Use Together**: ChatGPT for questions, AI Workflow for automation

### Key Differentiators

What makes AI Workflow unique:

1. **AI-Native**: 14 specialized AI personas using GitHub Copilot CLI
2. **Comprehensive**: 15-step pipeline covering docs, code, tests, and UX
3. **Modular**: 33 library modules + 15 step modules (26.5K+ lines)
4. **Performance**: Smart execution (40-85% faster), parallel execution (33% faster)
5. **Developer Experience**: Auto-commit workflow, pre-configured templates, IDE integration (v2.6.0)
6. **Intelligent**: Change detection, dependency analysis, AI response caching
7. **Local-First**: Runs on your machine, optional CI/CD integration
8. **Shell-Based**: Bash scripts, no heavy dependencies
9. **Open Source**: MIT licensed, community-driven

### Complementary Tools

These tools work well alongside AI Workflow:

**Before AI Workflow**:
- Use `pre-commit` for immediate syntax checks
- Use `ShellCheck` for shell script linting
- Use `Vale` for prose style checking

**With AI Workflow**:
- Comprehensive validation and enhancement
- AI-powered analysis and suggestions
- Automated test generation and execution

**After AI Workflow**:
- Use `MkDocs` or similar to publish validated documentation
- Use `GitHub Actions` to run AI Workflow in CI/CD
- Use `SonarQube` for enterprise-level quality tracking

### Inspiration and Acknowledgments

AI Workflow was inspired by:
- **GitHub Copilot CLI** - AI-powered command line interface
- **Make/Taskfile** - Task automation patterns
- **pre-commit** - Git hook management approach
- **Unix Philosophy** - Small, composable tools
- **DevOps Best Practices** - Automation, validation, continuous improvement

### Community and Ecosystem

**Related Resources**:
- [Awesome Shell](https://github.com/alebcay/awesome-shell) - Curated shell tools
- [Awesome Bash](https://github.com/awesome-lists/awesome-bash) - Bash resources
- [Awesome Documentation](https://github.com/PharkMillups/beautiful-docs) - Documentation tools

**Discussion Forums**:
- [GitHub Discussions](https://github.com/mpbarbosa/ai_workflow/discussions) - Project-specific
- [Reddit r/bash](https://reddit.com/r/bash) - Shell scripting
- [Stack Overflow](https://stackoverflow.com/questions/tagged/bash) - Technical Q&A

### Contributing to Ecosystem

We encourage ecosystem integration:
- **Plugin System** (future): Extend AI Workflow with custom steps
- **Integration Guides**: Help us document integration with other tools
- **Community Tools**: Share your AI Workflow extensions
- **Feedback**: Tell us what tools you want to integrate with

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

---

For detailed architecture information, see [Architecture Decision Records](docs/design/adr/) and [PROJECT_REFERENCE.md](docs/PROJECT_REFERENCE.md)
