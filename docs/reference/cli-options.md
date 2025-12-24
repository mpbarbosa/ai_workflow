# CLI Options Reference

Complete reference for all command-line options in the AI Workflow Automation system.

## Basic Usage

```bash
./execute_tests_docs_workflow.sh [OPTIONS]
```

## Options

### Project Selection

**`--target PATH`**
- Specifies the target project directory
- Default: Current working directory
- Example: `--target /path/to/project`
- See: [Target Project Feature Guide](target-project-feature.md)

### Execution Control

**`--auto`**
- Non-interactive mode, uses defaults for all prompts
- Recommended for CI/CD pipelines
- Example: `--auto`

**`--dry-run`**
- Preview execution without making changes
- Shows which steps would run
- Example: `--dry-run`

**`--steps STEPS`**
- Execute only specific steps
- Comma-separated step numbers
- Example: `--steps 0,2,3,5`

**`--no-resume`**
- Ignore checkpoints and start fresh
- Forces complete workflow execution
- Example: `--no-resume`

### Optimization

**`--smart-execution`**
- Skip unnecessary steps based on change detection
- 40-85% faster for targeted changes
- See: [Smart Execution Guide](smart-execution.md)

**`--parallel`**
- Run independent steps simultaneously
- 33% faster execution
- See: [Parallel Execution Guide](parallel-execution.md)

**`--no-ai-cache`**
- Disable AI response caching
- Forces fresh AI calls
- Default: Caching enabled
- See: [AI Cache Configuration](ai-cache-configuration.md)

### Visualization

**`--show-graph`**
- Display step dependency graph
- Useful for understanding workflow
- Example: `--show-graph`

### Configuration

**`--init-config`**
- Run configuration wizard
- Interactive setup for tech stack
- See: [Init Config Wizard](init-config-wizard.md)

**`--show-tech-stack`**
- Display detected technology stack
- Example: `--show-tech-stack`

**`--config-file FILE`**
- Use custom configuration file
- Default: `.workflow-config.yaml`
- Example: `--config-file my-config.yaml`

### Information

**`--help`**
- Display help message
- Example: `--help`

**`--version`**
- Display version information
- Example: `--version`

## Common Usage Patterns

### Development

```bash
# Fast iteration with optimizations
./execute_tests_docs_workflow.sh --smart-execution --parallel
```

### CI/CD

```bash
# Non-interactive with optimizations
./execute_tests_docs_workflow.sh --auto --smart-execution --parallel
```

### Debugging

```bash
# Preview with specific steps
./execute_tests_docs_workflow.sh --dry-run --steps 0,2,3
```

### Fresh Start

```bash
# Force complete execution
./execute_tests_docs_workflow.sh --no-resume --no-ai-cache
```

## See Also

- [Quick Start Guide](../user-guide/quick-start.md)
- [Usage Guide](../user-guide/usage.md)
- [Performance Benchmarks](performance-benchmarks.md)
