# Migration Guide: v3.x → v4.0.0

## Overview

Version 4.0.0 introduces **configuration-driven step execution**, eliminating the need to renumber files and functions when modifying workflow steps.

**Key Benefits**:
- 📝 Descriptive step names (e.g., `documentation_updates.sh` instead of `step_01_documentation.sh`)
- 🔧 Configure execution order in YAML (no more hardcoded sequences)
- ⚡ Add/remove/reorder steps without touching code
- 🔄 100% backward compatible (automatic legacy mode)

## Breaking Changes

### Step File Names

All step files have been renamed from numbered to descriptive names:

| v3.x File | v4.0 File |
|-----------|-----------|
| `step_00_analyze.sh` | `pre_analysis.sh` |
| `step_01_documentation.sh` | `documentation_updates.sh` |
| `step_01_5_api_coverage.sh` | `api_coverage_analysis.sh` |
| `step_02_consistency.sh` | `consistency_analysis.sh` |
| `step_02_5_doc_optimize.sh` | `documentation_optimization.sh` |
| `step_03_script_refs.sh` | `script_reference_validation.sh` |
| `step_04_config_validation.sh` | `config_validation.sh` |
| `step_05_directory.sh` | `directory_validation.sh` |
| `step_06_test_review.sh` | `test_review.sh` |
| `step_07_test_gen.sh` | `test_generation.sh` |
| `step_08_test_exec.sh` | `test_execution.sh` |
| `step_09_dependencies.sh` | `dependency_validation.sh` |
| `step_10_code_quality.sh` | `code_quality_validation.sh` |
| `step_11_5_context.sh` | `context_analysis.sh` |
| `step_11_deployment_gate.sh` | `deployment_gate.sh` |
| `step_12_git.sh` | `git_finalization.sh` |
| `step_13_markdown_lint.sh` | `markdown_linting.sh` |
| `step_14_prompt_engineer.sh` | `prompt_engineer_analysis.sh` |
| `step_15_ux_analysis.sh` | `ux_analysis.sh` |
| `version_update.sh` | `version_update.sh` | ✅ Already descriptive (Step 0a) |
| `bootstrap_docs.sh` | `bootstrap_documentation.sh` |

### Function Names

Step functions no longer have numeric prefixes:

```bash
# v3.x
step1_update_documentation() { ... }
step8_execute_tests() { ... }

# v4.0
documentation_updates() { ... }
test_execution() { ... }
```

### Library Directories

Associated library directories have been renamed:

```bash
step_01_lib/          → documentation_updates_lib/
step_01_5_lib/        → api_coverage_analysis_lib/
step_02_lib/          → consistency_analysis_lib/
step_02_5_lib/        → documentation_optimization_lib/
step_06_lib/          → test_review_lib/
step_07_lib/          → test_generation_lib/
step_0b_lib/          → bootstrap_documentation_lib/
step_11_lib/          → deployment_gate_lib/
```

## What Still Works (Backward Compatibility)

### CLI Arguments ✅

```bash
# Old syntax (v3.x) - STILL WORKS
./execute_tests_docs_workflow.sh --steps 0,1,8

# New syntax (v4.0) - NOW AVAILABLE
./execute_tests_docs_workflow.sh --steps bootstrap_documentation,documentation_updates,test_execution

# Mixed syntax - ALSO WORKS
./execute_tests_docs_workflow.sh --steps 0,documentation_updates,8
```

### Legacy Mode ✅

If your `.workflow-config.yaml` doesn't have a `workflow:` section, v4.0 automatically runs in **legacy mode**:

```
⚠️  WARNING: No workflow section found in .workflow-config.yaml
ℹ️  Using legacy step execution mode (v3.x compatibility)
✅ Loaded 21 legacy steps
```

This ensures existing installations work without changes.

## Migration Path

### Option 1: No Action Required (Legacy Mode)

If you're satisfied with v3.x behavior, **do nothing**. Your workflow will continue working in legacy mode.

### Option 2: Migrate to v4.0 (Recommended)

To use new features (custom step order, conditional steps):

#### Step 1: Add Workflow Configuration

Add to your `.workflow-config.yaml`:

```yaml
workflow:
  settings:
    auto_mode: false
    parallel_execution: true
    smart_execution: true
    
  steps:
    # Pre-processing steps
    - name: bootstrap_documentation
      module: bootstrap_documentation.sh
      function: bootstrap_documentation
      enabled: true
      dependencies: []
      description: "Generate initial documentation from code"
      
    - name: documentation_updates
      module: documentation_updates.sh
      function: documentation_updates
      enabled: true
      dependencies: [bootstrap_documentation]
      description: "Update and validate documentation"
      ai_persona: "documentation_specialist"
      
    # ... see .workflow_core/config/.workflow-config.yaml.template for complete example
```

#### Step 2: Test Configuration

```bash
# Verify step registry loads
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Expected output:
# ✅ Step definitions loaded from .workflow-config.yaml
# ✅ Resolved execution order for 21 steps
```

#### Step 3: Use New Step Names

```bash
# Use descriptive names instead of numbers
./src/workflow/execute_tests_docs_workflow.sh \
  --steps documentation_updates,test_execution,git_finalization
```

## New Features in v4.0

### 1. Configuration-Driven Execution

Define step order in YAML instead of code:

```yaml
workflow:
  steps:
    - name: my_custom_step
      module: my_custom_step.sh
      function: my_custom_step
      enabled: true
      dependencies: [pre_analysis]
```

### 2. Conditional Steps

Disable steps without editing code:

```yaml
- name: ux_analysis
  enabled: false  # Skip this step
```

### 3. Custom Dependencies

Control execution order:

```yaml
- name: test_execution
  dependencies: [test_generation, dependency_validation]
  description: "Execute test suite"
```

### 4. Step Selection by Name

```bash
# Much more readable than numbers!
--steps bootstrap_documentation,documentation_updates,test_execution
```

### 5. Mixed Syntax Support

```bash
# Use what you remember
--steps 0,documentation_updates,8,test_execution,git_finalization
```

## Troubleshooting

### Issue: "Command not found" errors

**Cause**: Old scripts/workflows calling numbered functions

**Fix**: Update any custom scripts:

```bash
# Old
step1_update_documentation

# New
documentation_updates
```

### Issue: Module not found errors

**Cause**: Custom scripts referencing old file paths

**Fix**: Update paths in your scripts:

```bash
# Old
source "${WORKFLOW_ROOT}/steps/step_01_documentation.sh"

# New
source "${WORKFLOW_ROOT}/steps/documentation_updates.sh"
```

### Issue: Want to rollback

**Recovery**: Restore from backup (created by migration script):

```bash
# Find backup directory
ls -la backups/

# Restore
cp -r backups/pre-migration-YYYYMMDD_HHMMSS/steps/* src/workflow/steps/
git checkout -- src/workflow/steps/
```

## Support

- **Full Mapping**: See `MIGRATION_REPORT_*.md` in your installation
- **Configuration Template**: `.workflow_core/config/.workflow-config.yaml.template`
- **Issues**: https://github.com/mpbarbosa/ai_workflow/issues

## Recommended Next Steps

1. ✅ Read this guide
2. ✅ Test in legacy mode (automatic)
3. ✅ Add workflow section to config (when ready)
4. ✅ Start using step names in CLI
5. ✅ Customize step order as needed

**Migration is optional and gradual. Legacy mode ensures nothing breaks.**
