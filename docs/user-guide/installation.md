# Installation Guide

## Prerequisites

- **Bash**: Version 4.0 or higher
- **Git**: Version 2.0 or higher
- **Node.js**: Version 25.2.1 or higher (for AI Copilot CLI)
- **GitHub Copilot CLI**: For AI-powered features

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/mpbarbosa/ai_workflow.git
cd ai_workflow
```

### 2. Verify Prerequisites

```bash
# Run health check
./src/workflow/lib/health_check.sh
```

### 3. Initial Configuration

```bash
# Run configuration wizard (optional)
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

### 4. Test Installation

```bash
# Run on a sample project
cd examples/nodejs-api
../../src/workflow/execute_tests_docs_workflow.sh --dry-run
```

## Post-Installation

- Review [Quick Start Guide](quick-start.md) for usage examples
- See [Usage Guide](usage.md) for detailed CLI options
- Check [Troubleshooting](troubleshooting.md) if you encounter issues

## Updating

```bash
cd ai_workflow
git pull origin main
```

For detailed upgrade instructions, see [Migration Guide](migration-guide.md).
