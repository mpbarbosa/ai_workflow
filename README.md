# AI Workflow Automation

Intelligent workflow automation system for validating and enhancing documentation, code, and tests with AI support.

**Migrated from**: mpbarbosa_site repository (2025-12-18)  
**Version**: v2.1.0  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)

## Overview

This repository provides a comprehensive, modular workflow automation system that leverages AI to maintain code quality, documentation consistency, and test coverage across software projects.

### Key Features

- **13-Step Automated Pipeline**: Complete workflow from analysis to finalization
- **17 Library Modules**: Modular architecture with AI caching and advanced optimization
- **AI Integration**: GitHub Copilot CLI with 13 specialized personas + response caching
- **Smart Execution** (v2.3): Skip steps based on change detection (40-85% faster)
- **Parallel Execution** (v2.3): Run independent steps simultaneously (33% faster)
- **AI Response Caching** (v2.3): Reduce token usage by 60-80%
- **Metrics Collection**: Automatic performance tracking and historical analysis
- **Dependency Visualization**: Interactive graph showing execution flow
- **100% Test Coverage**: 37 automated tests ensure reliability

## Quick Start

### Running on This Repository

```bash
# Clone repository
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Run workflow tests
cd shell_scripts/workflow/lib
./test_enhancements.sh
```

### Applying to Target Projects

To use this workflow on other projects (e.g., mpbarbosa_site):

```bash
# Option 1: Run from project directory (default behavior)
cd /path/to/your/project
/path/to/ai_workflow/shell_scripts/workflow/execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto

# Option 2: Use --target flag from anywhere
cd ai_workflow
./shell_scripts/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/project \
  --smart-execution \
  --parallel \
  --auto

# Option 3: With dependency visualization
cd /path/to/your/project
/path/to/ai_workflow/shell_scripts/workflow/execute_tests_docs_workflow.sh \
  --show-graph

# Option 4: Copy workflow to target project
cp -r ai_workflow/shell_scripts/workflow /path/to/target/project/shell_scripts/
cd /path/to/target/project
./shell_scripts/workflow/execute_tests_docs_workflow.sh
```

**Performance Tips**:
- Use `--smart-execution` for 40-85% faster execution
- Use `--parallel` for 33% additional speed improvement
- AI responses cached automatically (60-80% token savings)
- Combined optimizations: Up to 90% faster for simple changes

## Documentation

- **[MIGRATION_README.md](MIGRATION_README.md)**: Migration details and architecture overview
- **[docs/workflow-automation/](docs/workflow-automation/)**: Comprehensive documentation
- **[shell_scripts/workflow/README.md](shell_scripts/workflow/README.md)**: Module API reference

## Repository Structure

```
ai_workflow/
├── docs/workflow-automation/      # Complete workflow documentation
├── shell_scripts/workflow/        # Workflow automation system
│   ├── execute_tests_docs_workflow.sh  # Main orchestrator (4,740 lines)
│   ├── lib/                       # 16 library modules (5,548 lines)
│   ├── steps/                     # 13 step modules (3,200 lines)
│   ├── config/                    # YAML configuration
│   └── backlog/                   # Execution history
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
