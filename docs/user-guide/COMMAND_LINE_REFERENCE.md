# Complete Command-Line Reference

**Version**: 4.0.1  
**Last Updated**: 2026-02-09

## Table of Contents

- [Synopsis](#synopsis)
- [Basic Usage](#basic-usage)
- [Options Reference](#options-reference)
- [Execution Modes](#execution-modes)
- [Optimization Options](#optimization-options)
- [Configuration Options](#configuration-options)
- [Output Control](#output-control)
- [Advanced Features](#advanced-features)
- [Examples](#examples)

---

## Synopsis

```bash
execute_tests_docs_workflow.sh [OPTIONS]

# Quick templates
./templates/workflows/docs-only.sh      # Documentation workflow
./templates/workflows/test-only.sh      # Test development workflow
./templates/workflows/feature.sh        # Full feature workflow
```

---

## Basic Usage

### Run on Current Directory

```bash
# Navigate to your project
cd /path/to/your/project

# Run workflow
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

### Target Different Project

```bash
# Run from anywhere
./execute_tests_docs_workflow.sh --target /path/to/project

# Target with auto mode
./execute_tests_docs_workflow.sh --target /path/to/project --auto
```

### Quick Start (Recommended)

```bash
# Full automation with all optimizations
./execute_tests_docs_workflow.sh \
  --auto \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto-commit
```

---

## Options Reference

### Core Options

#### `--help`, `-h`
Display help message and exit.

```bash
./execute_tests_docs_workflow.sh --help
```

#### `--version`, `-v`
Display version information and exit.

```bash
./execute_tests_docs_workflow.sh --version
# Output: AI Workflow Automation v3.1.0
```

#### `--target <path>`
Specify target project directory.

```bash
# Run on external project
./execute_tests_docs_workflow.sh --target /path/to/project

# Multiple projects
for proj in project1 project2 project3; do
    ./execute_tests_docs_workflow.sh --target "$proj" --auto
done
```

**Behavior**:
- Sets `TARGET_PROJECT` environment variable
- All artifacts stored in `${TARGET_PROJECT}/.ai_workflow/`
- Workflow runs from target directory context

---

## Execution Modes

### `--auto`
Automatic mode - skip all interactive prompts.

```bash
./execute_tests_docs_workflow.sh --auto
```

**Behavior**:
- No user interaction required
- Automatic step continuation
- Suitable for CI/CD pipelines
- Default answers for all prompts

**Use Cases**:
- Continuous integration
- Automated testing
- Scheduled workflows
- Batch processing

### `--interactive`
Interactive mode - prompt for each step (default).

```bash
./execute_tests_docs_workflow.sh --interactive
```

**Behavior**:
- Pause after each step
- Display step results
- Ask for confirmation to continue
- Allow manual inspection

**Use Cases**:
- Development workflow
- Step-by-step validation
- Learning the system
- Debugging

### `--dry-run`
Preview execution without making changes.

```bash
./execute_tests_docs_workflow.sh --dry-run
```

**Behavior**:
- Shows what would be executed
- No file modifications
- No Git operations
- No AI calls (uses cached responses if available)
- Displays step plan

**Use Cases**:
- Validate configuration
- Preview workflow
- Test new features
- Understand execution plan

---

## Optimization Options

### `--smart-execution`
Enable intelligent step skipping based on changes.

```bash
./execute_tests_docs_workflow.sh --smart-execution
```

**How It Works**:
1. Analyzes Git changes
2. Classifies change type (docs-only, tests-only, full-stack)
3. Skips unnecessary steps

**Performance**:
- **Docs-only**: 85% faster (23min → 3.5min)
- **Tests-only**: 35% faster
- **Code changes**: 40% faster

**Example**:
```bash
# Only changed README.md
git add README.md
./execute_tests_docs_workflow.sh --smart-execution

# Result: Skips tests, runs only documentation steps
```

### `--parallel`
Execute independent steps simultaneously.

```bash
./execute_tests_docs_workflow.sh --parallel
```

**How It Works**:
1. Analyzes step dependencies
2. Identifies parallelizable groups
3. Executes steps concurrently using fork/join

**Performance**: 33% faster (23min → 15.5min)

**Parallelizable Steps**:
- Step 2 (docs) + Step 5 (tests) - No dependencies
- Step 3 (validation) + Step 6 (test validation) - Independent

**Resource Usage**: Increased CPU and memory during parallel execution

### `--ml-optimize`
Enable ML-driven optimization (requires 10+ historical runs).

```bash
./execute_tests_docs_workflow.sh --ml-optimize
```

**How It Works**:
1. Loads historical execution data
2. Predicts step durations
3. Provides smart recommendations
4. Auto-adjusts timeouts

**Performance**: Additional 15-30% improvement

**Requirements**:
- Minimum 10 completed workflow runs
- ML data stored in `.ml_data/`
- More data = better accuracy

**Example**:
```bash
# Check ML status
./execute_tests_docs_workflow.sh --show-ml-status

# Output:
# ML Optimization Status
# ├── Historical Runs: 25
# ├── Model Accuracy: 87%
# └── Status: Ready
```

### `--multi-stage`
Use progressive 3-stage pipeline.

```bash
./execute_tests_docs_workflow.sh --multi-stage
```

**How It Works**:
1. **Stage 1 (Quick)**: Fast validation (80% complete here)
2. **Stage 2 (Standard)**: Standard checks (15% continue)
3. **Stage 3 (Full)**: Complete validation (5% need this)

**Auto-Progression**:
- Stage 1 failure = Stop
- Stage 1 success + high confidence = Stop
- Stage 2 needed = Auto-continue
- Manual override with `--manual-trigger`

**Performance**: Optimized for fast feedback

### `--manual-trigger`
Force all stages in multi-stage mode.

```bash
./execute_tests_docs_workflow.sh --multi-stage --manual-trigger
```

**Behavior**: Runs all 3 stages regardless of stage 1 results

### `--parallel-tracks`
**Version**: v2.6.0  
Enable 3-track parallel execution for maximum performance.

```bash
./execute_tests_docs_workflow.sh --parallel-tracks --auto
```

**How It Works**:
- Divides workflow into 3 independent execution tracks
- Each track runs in parallel process
- Automatically manages dependencies between tracks
- Maximum CPU utilization

**Performance**: Up to 50% faster than standard `--parallel` mode

**Resource Requirements**:
- Minimum 4 CPU cores (optimal: 8+ cores)
- 8GB+ RAM
- Fast SSD storage

**Tracks**:
1. **Track 1**: Documentation and analysis steps
2. **Track 2**: Code review and test execution
3. **Track 3**: Quality checks and finalization

**Example**:
```bash
# Maximum performance mode
./execute_tests_docs_workflow.sh \
  --parallel-tracks \
  --smart-execution \
  --ml-optimize \
  --auto
```

### `--no-fast-track`
**Version**: v5.0.0  
Disable docs-only fast track optimization.

```bash
./execute_tests_docs_workflow.sh --no-fast-track
```

**Use Cases**:
- Force full pipeline execution
- Validate all steps even for doc-only changes
- Testing and debugging
- Release validation

**Behavior**: Disables automatic step skipping for documentation-only changes

---

## Configuration Options

### `--init-config`
Run interactive configuration wizard.

```bash
./execute_tests_docs_workflow.sh --init-config
```

**What It Does**:
1. Detects tech stack
2. Identifies project type
3. Configures test commands
4. Sets quality standards
5. Creates `.workflow-config.yaml`

**Example Session**:
```
Detecting tech stack...
✓ Found: Node.js 20.10.0
✓ Found: package.json (npm project)

Project type: nodejs_api

Test command: npm test
Build command: npm run build
Quality gates: ESLint, Prettier, Jest coverage

Save to .workflow-config.yaml? [Y/n]: y
✓ Configuration saved
```

### `--show-tech-stack`
Display detected technology stack.

```bash
./execute_tests_docs_workflow.sh --show-tech-stack
```

**Example Output**:
```
Technology Stack Detection
├── Primary Language: JavaScript
├── Runtime: Node.js 20.10.0
├── Package Manager: npm 10.2.3
├── Test Framework: Jest 29.7.0
├── Build Tool: webpack 5.89.0
└── Project Type: nodejs_api
```

### `--config-file <path>`
Use custom configuration file.

```bash
./execute_tests_docs_workflow.sh --config-file .my-config.yaml
```

**Use Cases**:
- Multiple configurations per project
- Environment-specific settings
- Testing different configurations

### `--show-config`
Display current configuration.

```bash
./execute_tests_docs_workflow.sh --show-config
```

**Output**: Complete configuration with sources (defaults, file, CLI overrides)

---

## Step Control

### `--steps <list>`
Execute specific steps only.

```bash
# Run specific steps (comma-separated)
./execute_tests_docs_workflow.sh --steps 0,2,5,7

# Run range
./execute_tests_docs_workflow.sh --steps 0-5

# Run single step
./execute_tests_docs_workflow.sh --steps 3
```

**Use Cases**:
- Test specific functionality
- Skip problematic steps
- Quick iterations
- Debugging

**Example**:
```bash
# Only run documentation steps
./execute_tests_docs_workflow.sh --steps 0,2,3,4,11,12

# Only run test steps
./execute_tests_docs_workflow.sh --steps 0,5,6,7
```

### `--skip-steps <list>`
Skip specific steps.

```bash
./execute_tests_docs_workflow.sh --skip-steps 5,6,7

# Skip tests but run everything else
```

### `--no-resume`
Ignore checkpoints and start fresh.

```bash
./execute_tests_docs_workflow.sh --no-resume
```

**Behavior**:
- Ignores existing checkpoint data
- Starts from step 0
- Useful after failed runs
- Clean slate execution

---

## AI & Cache Options

### `--no-ai-cache`
Disable AI response caching.

```bash
./execute_tests_docs_workflow.sh --no-ai-cache
```

**When to Use**:
- Testing AI responses
- Forcing fresh analysis
- Debugging AI issues
- After prompt changes

**Note**: Caching is enabled by default (24h TTL, 60-80% token reduction)

### `--clear-ai-cache`
Clear AI response cache before execution.

```bash
./execute_tests_docs_workflow.sh --clear-ai-cache
```

**Effect**: Removes all cached responses in `.ai_cache/`

### `--force-model <model-name>`
**Version**: v3.2.11  
Override default AI model selection for all steps.

```bash
./execute_tests_docs_workflow.sh --force-model gpt-4-turbo
```

**Supported Models**:
- `gpt-4` - OpenAI GPT-4 (high quality, slower)
- `gpt-4-turbo` - OpenAI GPT-4 Turbo (faster)
- `gpt-3.5-turbo` - OpenAI GPT-3.5 (fast, lower cost)
- `claude-3-opus` - Anthropic Claude 3 Opus
- `claude-3-sonnet` - Anthropic Claude 3 Sonnet

**Use Cases**:
- Testing different model performance
- Cost optimization
- Quality vs. speed tradeoffs
- Specific model requirements

**Example**:
```bash
# Use faster model for quick validation
./execute_tests_docs_workflow.sh \
  --force-model gpt-3.5-turbo \
  --steps documentation_updates \
  --auto
```

### `--show-model-plan`
**Version**: v3.2.11  
Preview AI model assignments without executing workflow.

```bash
./execute_tests_docs_workflow.sh --show-model-plan
```

**Output Example**:
```
AI Model Plan:
├── Step 2 (Documentation): gpt-4 (recommended)
├── Step 4 (Code Review): gpt-4-turbo (fast)
├── Step 5 (Test Generation): gpt-4 (high quality)
└── Step 7 (Quality Check): gpt-3.5-turbo (efficient)

Total estimated tokens: 125,000
Estimated cost: $2.50
```

**Use Cases**:
- Cost estimation before execution
- Model selection planning
- Debugging model assignments

---

## Git & Version Control

### `--auto-commit`
Automatically commit workflow artifacts.

```bash
./execute_tests_docs_workflow.sh --auto-commit
```

**What Gets Committed**:
- Documentation updates
- Test files
- Source code changes (AI-suggested)
- Workflow reports

**Commit Message**: Auto-generated based on changes

**Example**:
```
docs: Update README.md and API documentation

- Updated installation instructions
- Added new API endpoints documentation
- Fixed typos in user guide

Generated by AI Workflow v3.1.0
Run ID: 20260207_174530
```

### `--install-hooks`
Install Git pre-commit hooks.

```bash
./execute_tests_docs_workflow.sh --install-hooks
```

**Installed Hooks**:
- `pre-commit` - Fast validation checks (< 1 second) (v3.0.0)
  - File syntax validation
  - Basic linting
  - Commit message format
  - Prevent broken commits

**Location**: `.git/hooks/pre-commit`

### `--test-hooks`
Test pre-commit hooks without committing.

```bash
./execute_tests_docs_workflow.sh --test-hooks
```

**Output**: Validation results without Git commit

### `--last-commits <N>`
**Version**: v3.3.0  
Analyze last N commits from HEAD for change detection.

```bash
# Analyze last 5 commits plus uncommitted changes
./execute_tests_docs_workflow.sh --last-commits 5
```

**How It Works**:
1. Analyzes commits from `HEAD~N` to `HEAD`
2. Includes uncommitted changes in working directory
3. Uses combined changes for smart execution decisions
4. Stores commit hashes in workflow metadata

**Use Cases**:
- Multi-commit feature branches
- Release validation across commits
- Historical change analysis
- Comprehensive testing after rebase

**Example**:
```bash
# Validate last 10 commits before release
./execute_tests_docs_workflow.sh \
  --last-commits 10 \
  --validate-release \
  --smart-execution
```

### `--validate-release`
**Version**: v3.3.0  
Enable deployment readiness gate (Step 11).

```bash
./execute_tests_docs_workflow.sh --validate-release
```

**Validation Checks**:
- All tests passing
- Documentation complete
- No TODO/FIXME in production code
- Version numbers consistent
- CHANGELOG updated
- Git tags present
- Build succeeds

**Behavior**: 
- Enables Step 11 (normally skipped)
- Fails workflow if validation fails
- Generates deployment readiness report

**Alias**: `--deployment-check`

**Example**:
```bash
# Pre-release validation
./execute_tests_docs_workflow.sh \
  --validate-release \
  --last-commits 20 \
  --auto
```

---

## Reporting & Visualization

### `--show-graph`
Display dependency graph.

```bash
./execute_tests_docs_workflow.sh --show-graph
```

**Example Output**:
```
Step Dependency Graph
├── step_00_analyze
│   ├── step_01_validate (depends on step_00)
│   └── step_02_update_docs (depends on step_00)
├── step_01_validate
│   └── step_03_validate_docs (depends on step_01)
├── step_02_update_docs
│   ├── step_03_validate_docs (depends on step_02)
│   └── step_04_review (depends on step_02)
...
```

### `--export-graph <format>`
Export dependency graph to file.

```bash
# Export as JSON
./execute_tests_docs_workflow.sh --export-graph json

# Export as DOT (Graphviz)
./execute_tests_docs_workflow.sh --export-graph dot

# Export as Mermaid
./execute_tests_docs_workflow.sh --export-graph mermaid
```

**Output Files**:
- `dependency_graph.json`
- `dependency_graph.dot`
- `dependency_graph.mmd`

### `--show-pipeline`
Display multi-stage pipeline configuration.

```bash
./execute_tests_docs_workflow.sh --show-pipeline
```

**Output**:
```
Multi-Stage Pipeline Configuration

Stage 1: Quick Validation
├── step_00_analyze
├── step_01_validate
└── step_02_update_docs
Duration: ~3 minutes

Stage 2: Standard Validation
├── step_05_run_tests
├── step_06_validate_tests
└── step_08_code_quality
Duration: ~8 minutes

Stage 3: Full Validation
├── step_09_ux_analysis
├── step_10_security_review
└── step_11_integration_test
Duration: ~12 minutes
```

### `--show-ml-status`
Display ML optimization system status.

```bash
./execute_tests_docs_workflow.sh --show-ml-status
```

**Output**:
```
ML Optimization Status
├── Historical Runs: 25
├── Model Trained: Yes
├── Last Training: 2026-02-06 12:30:45
├── Accuracy: 87%
├── Predictions Available: Yes
└── Recommendations: Ready
```

---

## Documentation Generation

### `--generate-docs`
Auto-generate project documentation.

```bash
./execute_tests_docs_workflow.sh --generate-docs
```

**Generated Docs**:
- Project overview
- Setup instructions
- API documentation (from code)
- Architecture overview
- Contributing guide

### `--update-changelog`
Update CHANGELOG.md automatically.

```bash
./execute_tests_docs_workflow.sh --update-changelog
```

**Behavior**:
- Analyzes Git commits since last release
- Groups by type (feat, fix, docs, etc.)
- Generates formatted changelog entry
- Appends to CHANGELOG.md

### `--generate-api-docs`
Generate API documentation from source code.

```bash
./execute_tests_docs_workflow.sh --generate-api-docs
```

**Supported**:
- JSDoc (JavaScript/TypeScript)
- Docstrings (Python)
- GoDoc (Go)
- Javadoc (Java)
- Shell function headers (Bash)

---

## Output Control

### `--verbose`, `-v`
Enable verbose output.

```bash
./execute_tests_docs_workflow.sh --verbose
```

**Shows**:
- Detailed step execution
- Command outputs
- Debug information
- Timing details

### `--quiet`, `-q`
Minimal output (errors only).

```bash
./execute_tests_docs_workflow.sh --quiet
```

**Use Cases**:
- CI/CD pipelines
- Cron jobs
- Log reduction
- Focus on errors only

### `--log-file <path>`
Write logs to specific file.

```bash
./execute_tests_docs_workflow.sh --log-file /var/log/workflow.log
```

**Default**: `.ai_workflow/logs/workflow_TIMESTAMP/execution.log`

---

## Examples

### Development Workflow

```bash
# Quick documentation update
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --auto

# Full feature development
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto-commit

# Test-driven development
./execute_tests_docs_workflow.sh \
  --steps 5,6,7 \
  --auto
```

### CI/CD Integration

```bash
# GitHub Actions
./execute_tests_docs_workflow.sh \
  --auto \
  --smart-execution \
  --parallel \
  --quiet

# GitLab CI
./execute_tests_docs_workflow.sh \
  --auto \
  --no-resume \
  --log-file ci.log

# Jenkins
./execute_tests_docs_workflow.sh \
  --auto \
  --multi-stage \
  --export-graph json
```

### Performance Optimization

```bash
# Maximum speed
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto

# With auto-commit
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --ml-optimize \
  --multi-stage \
  --auto \
  --auto-commit
```

### Debugging

```bash
# Dry run with verbose output
./execute_tests_docs_workflow.sh \
  --dry-run \
  --verbose

# Single step debugging
./execute_tests_docs_workflow.sh \
  --steps 5 \
  --interactive \
  --verbose \
  --no-ai-cache

# Force fresh start
./execute_tests_docs_workflow.sh \
  --no-resume \
  --no-ai-cache \
  --clear-checkpoints
```

### External Project Management

```bash
# Multiple projects
for project in /projects/*; do
    ./execute_tests_docs_workflow.sh \
      --target "$project" \
      --auto \
      --smart-execution \
      --log-file "${project}/workflow.log"
done

# Specific project
./execute_tests_docs_workflow.sh \
  --target /path/to/client-project \
  --config-file client-config.yaml \
  --auto \
  --auto-commit
```

---

## Environment Variables

Can be used instead of command-line options:

```bash
# Set execution mode
export WORKFLOW_AUTO=true
export WORKFLOW_DRY_RUN=false

# Set optimization
export SMART_EXECUTION=true
export PARALLEL_EXECUTION=true
export ML_OPTIMIZE=true

# Set paths
export TARGET_PROJECT=/path/to/project
export CONFIG_FILE=.workflow-config.yaml

# Run with environment
./execute_tests_docs_workflow.sh
```

---

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Configuration error
- `3` - Validation error
- `4` - Step execution failed
- `5` - User interrupted (Ctrl+C)
- `6` - Dependency missing
- `7` - Git operation failed
- `8` - AI operation failed

---

## Related Documentation

- [Quick Start Guide](quick-start.md)
- [Feature Guide](feature-guide.md)
- [Workflow Templates](../templates/workflows/README.md)
- [Configuration Guide](../developer-guide/configuration.md)
- [API Reference](../api/README.md)
