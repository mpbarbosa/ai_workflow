# Workflow Steps Directory

This directory contains the modular step implementations for the AI Workflow Automation system's 13-step pipeline.

## Purpose

Each step module is a self-contained unit responsible for a specific phase of the workflow automation process. Steps are executed in sequence by the main orchestrator (`execute_tests_docs_workflow.sh`) and can be selectively run using the `--steps` command-line option.

## Step Numbering Scheme

Steps are numbered sequentially from 00 to 13, following this convention:
- **00-03**: Pre-flight analysis and documentation validation
- **04-07**: Testing and execution phases
- **08-10**: Quality assurance and analysis
- **11-13**: Finalization, linting, and meta-analysis

The numbering allows for:
- Clear execution order
- Easy identification in logs and reports
- Selective execution via `--steps` option
- Dependency resolution in parallel execution mode

## Step Modules

### Analysis & Documentation (00-03)

**step_00_analyze.sh** - Pre-flight Analysis
- Project structure validation
- Tech stack detection (v2.3.0+)
- Prerequisites verification
- Environment readiness check

**step_01_documentation.sh** - Documentation Updates
- AI-powered documentation review
- README and guide updates
- Documentation consistency checks
- Uses `documentation_specialist` persona

**step_02_consistency.sh** - Cross-Reference Validation
- Documentation cross-reference validation
- Link integrity checks
- Reference consistency verification
- Uses `consistency_analyst` persona

**step_03_script_refs.sh** - Script Reference Validation
- Script path validation
- Command reference verification
- Example code validation
- Uses `script_validator` persona

### Testing (04-07)

**step_04_directory.sh** - Directory Structure Validation
- Project structure verification
- Required directory checks
- File organization validation
- Uses `directory_validator` persona

**step_05_test_review.sh** - Test Coverage Review
- Test coverage analysis
- Missing test identification
- Test quality assessment
- Uses `test_engineer` persona

**step_06_test_gen.sh** - Test Case Generation
- AI-powered test generation
- Test case recommendations
- Coverage gap filling
- Uses `test_engineer` persona

**step_07_test_exec.sh** - Test Execution
- Automated test execution
- Test result collection
- Failure analysis
- Uses `test_execution_analyst` persona

### Quality & Analysis (08-10)

**step_08_dependencies.sh** - Dependency Validation
- Dependency graph analysis
- Version compatibility checks
- Security vulnerability scanning
- Uses `dependency_analyst` and `security_analyst` personas

**step_09_code_quality.sh** - Code Quality Checks
- Code style validation
- Best practices verification
- Architecture review
- Uses `code_reviewer` persona

**step_10_context.sh** - Context Analysis
- Contextual understanding
- Cross-cutting concerns analysis
- Integration verification
- Uses `context_analyst` persona

### Finalization (11-13)

**step_11_git.sh** - Git Operations and Finalization
- Git status checks
- Commit preparation
- Branch management
- Uses `git_specialist` persona

**step_12_markdown_lint.sh** - Markdown Linting
- Markdown formatting validation
- Style consistency checks
- Documentation quality assurance
- Uses `markdown_linter` persona

**step_13_prompt_engineer.sh** - Prompt Engineer Analysis ⭐ NEW v2.3.1
- AI persona prompt quality analysis
- Token efficiency optimization
- Prompt improvement recommendations
- GitHub issue generation for improvements
- Uses `prompt_engineer` persona
- **Scope**: Only runs on `bash-automation-framework` projects (ai_workflow itself)

## Step Module Structure

Each step module follows a standard structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Module header with purpose and dependencies
# ...

# Required function: Validate prerequisites
validate_step_XX() {
    # Check if step should run
    # Validate dependencies
    # Return 0 if ready, 1 if should skip
}

# Required function: Execute step logic
execute_step_XX() {
    # Main step implementation
    # AI integration if needed
    # Report generation
    # Return 0 on success, non-zero on failure
}

# Optional: Step-specific helper functions
```

## Step Dependencies

Steps have execution dependencies managed by the dependency graph:

```
step_00 (analyze) → All other steps
step_01-04,13    → Independent (can run in parallel)
step_05          → step_04
step_06          → step_05
step_07          → step_06
step_08-10       → Independent (can run in parallel)
step_11          → All previous steps
step_12          → step_01
step_13          → step_00 (can run early in parallel with other validation steps)
```

View the full dependency graph: `./execute_tests_docs_workflow.sh --show-graph`

## Selective Step Execution

Run specific steps using the `--steps` option:

```bash
# Run only documentation steps
./execute_tests_docs_workflow.sh --steps 0,1,2,3

# Run only testing pipeline
./execute_tests_docs_workflow.sh --steps 5,6,7

# Run pre-flight and finalization
./execute_tests_docs_workflow.sh --steps 0,11

# Run single step (with dependencies)
./execute_tests_docs_workflow.sh --steps 8
```

## Smart Execution

With `--smart-execution`, steps are automatically skipped based on change detection:

- Documentation-only changes: Skip test execution steps (5-7)
- Code-only changes: Skip documentation consistency (2)
- No relevant changes: Skip to finalization (11-12)

Performance impact: 40-90% faster depending on change scope

## Parallel Execution

With `--parallel`, independent steps run simultaneously:

- Steps 1-4,13 can run in parallel (if no dependencies blocked)
- Steps 8-10 can run in parallel
- Performance impact: ~33% faster

## AI Integration

Steps integrate with GitHub Copilot CLI using specialized personas defined in `src/workflow/config/ai_helpers.yaml`. Each step:

1. Checks Copilot availability
2. Selects appropriate persona
3. Makes AI calls with context
4. Caches responses (24-hour TTL)
5. Generates reports in backlog

AI caching reduces token usage by 60-80%.

## Output and Reports

Each step generates:

- **Execution logs**: `src/workflow/logs/workflow_TIMESTAMP/step_XX_*.log`
- **Step reports**: `src/workflow/backlog/workflow_TIMESTAMP/step_XX_*.md`
- **AI summaries**: `src/workflow/summaries/workflow_TIMESTAMP/` (if AI enabled)
- **Metrics**: `src/workflow/metrics/current_run.json`

## Testing Step Modules

Test individual steps:

```bash
# Source the step module
source src/workflow/steps/step_XX_name.sh

# Test validation function
if validate_step_XX; then
    echo "Step ready to run"
fi

# Test execution (in test environment)
execute_step_XX
```

Integration tests are located in `tests/integration/`.

## Adding a New Step

To add a new step to the workflow:

1. **Create step file**: `step_XX_name.sh` (follow numbering convention)
2. **Implement required functions**: `validate_step_XX()`, `execute_step_XX()`
3. **Add dependencies**: Update `src/workflow/lib/dependency_graph.sh`
4. **Register step**: Update main orchestrator's step list
5. **Add AI persona** (if needed): Update `config/ai_helpers.yaml`
6. **Write tests**: Add to `tests/integration/`
7. **Document**: Update this README and workflow analysis docs

## Best Practices

1. **Idempotency**: Steps should be safely re-runnable
2. **Error handling**: Always return appropriate exit codes
3. **Progress reporting**: Use colored output for user feedback
4. **Change awareness**: Check if step work is needed before execution
5. **AI integration**: Cache responses, handle Copilot unavailability
6. **Logging**: Write detailed logs to workflow log directory
7. **Cleanup**: Remove temporary files on completion

## Performance Considerations

- Steps should complete in < 5 minutes individually
- Use AI caching for repeated operations
- Leverage change detection to skip unnecessary work
- Design for parallel execution where possible
- Monitor metrics to identify slow steps

## Related Documentation

- **Main orchestrator**: `src/workflow/execute_tests_docs_workflow.sh`
- **Workflow README**: `src/workflow/README.md`
- **AI Integration**: `src/workflow/lib/ai_helpers.sh`
- **Dependency graph**: `src/workflow/lib/dependency_graph.sh`
- **Technical analysis**: `docs/workflow-automation/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md`
- **Module inventory**: `docs/workflow-automation/WORKFLOW_MODULE_INVENTORY.md`

## Support

For issues with specific steps:
1. Check execution logs in `src/workflow/logs/`
2. Review step report in backlog directory
3. Run step validation: `validate_step_XX`
4. Test in isolation with `--steps XX`
5. Check dependency graph: `--show-graph`
