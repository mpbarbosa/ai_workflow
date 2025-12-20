# AI Workflow Automation

Intelligent workflow automation system for validating and enhancing documentation, code, and tests with AI support.

**Migrated from**: mpbarbosa_site repository (2025-12-18)  
**Version**: v2.3.1  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)

## Overview

This repository provides a comprehensive, modular workflow automation system that leverages AI to maintain code quality, documentation consistency, and test coverage across software projects.

### Key Features

- **13-Step Automated Pipeline**: Complete workflow from analysis to finalization
- **20 Library Modules**: Modular architecture with AI caching and advanced optimization (19 .sh modules + 1 .yaml config)
- **AI Integration**: GitHub Copilot CLI with 13 specialized personas
- **Smart Execution** (v2.3): Skip steps based on change detection (40-85% faster)
- **Parallel Execution** (v2.3): Run independent steps simultaneously (33% faster)
- **AI Response Caching** (v2.3): Reduce token usage by 60-80%
- **Target Project Support** (v2.3): Run on any project with --target option
- **Checkpoint Resume** (v2.3): Automatic workflow continuation (use --no-resume to disable)
- **Prompt Engineering** (v2.3.1): Analyze and improve AI persona prompts (Step 13 - ai_workflow only)
- **Metrics Collection**: Automatic performance tracking and historical analysis
- **Dependency Visualization**: Interactive graph showing execution flow
- **100% Test Coverage**: 37+ automated tests ensure reliability

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
```

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

# Option 7: Copy workflow to target project
cp -r ai_workflow/src/workflow /path/to/target/project/src/
cd /path/to/target/project
./src/workflow/execute_tests_docs_workflow.sh
```

**Performance Tips**:
- Use `--smart-execution` for 40-85% faster execution
- Use `--parallel` for 33% additional speed improvement
- AI responses cached automatically (60-80% token savings)
- Checkpoint resume enabled by default (use `--no-resume` for fresh start)
- Combined optimizations: Up to 90% faster for simple changes

## Documentation

- **[MIGRATION_README.md](MIGRATION_README.md)**: Migration details and architecture overview
- **[docs/workflow-automation/](docs/workflow-automation/)**: Comprehensive documentation
- **[src/workflow/README.md](src/workflow/README.md)**: Module API reference

## Repository Structure

```
ai_workflow/
├── docs/                          # Comprehensive documentation
│   ├── workflow-automation/       # Workflow system docs
│   ├── TECH_STACK_ADAPTIVE_FRAMEWORK.md  # Tech stack detection
│   └── PROJECT_KIND_ADAPTIVE_FRAMEWORK_PHASED_PLAN.md  # Project kind detection
├── src/workflow/                  # Workflow automation system
│   ├── execute_tests_docs_workflow.sh  # Main orchestrator (4,740 lines)
│   ├── lib/                       # 20 library modules (5,548 lines: 19 .sh + 1 .yaml)
│   ├── steps/                     # 13 step modules (3,200 lines)
│   ├── config/                    # YAML configuration
│   └── backlog/                   # Execution history
├── tests/                         # Comprehensive test suite
│   ├── unit/                      # Unit tests (4 tests)
│   ├── integration/               # Integration tests (5 tests)
│   └── run_all_tests.sh          # Master test runner
├── MIGRATION_README.md            # Migration documentation
└── README.md                      # This file
```

## Prerequisites

- Bash 4.0+
- Git
- Node.js v25.2.1+ (for test execution in target projects)
- GitHub Copilot CLI (optional, for AI features)

## License

[Same as parent project]

---

For detailed information, see [MIGRATION_README.md](MIGRATION_README.md)
