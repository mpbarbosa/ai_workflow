# Step Migration Report: v3.x → v4.0.0

## Migration Summary

- **Date**: $(date +%Y-%m-%d\ %H:%M:%S)
- **Script**: migrate_to_named_steps.sh
- **Purpose**: Rename step files from numbered to descriptive names

## Files Renamed

| Old File | New File | Old Function | New Function |
|----------|----------|--------------|--------------|
| step_0a_version_update.sh | version_update.sh | step0a_version_update | version_update |
| step_00_analyze.sh | pre_analysis.sh | step0_analyze_changes | pre_analysis |
| step_0b_bootstrap_docs.sh | bootstrap_documentation.sh | step0b_bootstrap_documentation | bootstrap_documentation |
| step_01_documentation.sh | documentation_updates.sh | step1_update_documentation | documentation_updates |
| step_01_5_api_coverage.sh | api_coverage_analysis.sh | step1_5_api_coverage_analysis | api_coverage_analysis |
| step_02_consistency.sh | consistency_analysis.sh | step2_check_consistency | consistency_analysis |
| step_02_5_doc_optimize.sh | documentation_optimization.sh | step2_5_doc_optimization | documentation_optimization |
| step_03_script_refs.sh | script_reference_validation.sh | step3_validate_script_references | script_reference_validation |
| step_04_config_validation.sh | config_validation.sh | step4_config_validation | config_validation |
| step_05_directory.sh | directory_validation.sh | step5_validate_directory | directory_validation |
| step_06_test_review.sh | test_review.sh | step6_review_tests | test_review |
| step_07_test_gen.sh | test_generation.sh | step7_generate_tests | test_generation |
| step_08_test_exec.sh | test_execution.sh | step8_execute_tests | test_execution |
| step_09_dependencies.sh | dependency_validation.sh | step9_validate_dependencies | dependency_validation |
| step_10_code_quality.sh | code_quality_validation.sh | step10_code_quality_validation | code_quality_validation |
| step_11_5_context.sh | context_analysis.sh | step10_context_analysis | context_analysis |
| step_11_deployment_gate.sh | deployment_gate.sh | step11_deployment_gate | deployment_gate |
| step_12_git.sh | git_finalization.sh | step12_git_finalization | git_finalization |
| step_13_markdown_lint.sh | markdown_linting.sh | step13_markdown_linting | markdown_linting |
| step_14_prompt_engineer.sh | prompt_engineer_analysis.sh | step14_prompt_engineer_analysis | prompt_engineer_analysis |
| step_15_ux_analysis.sh | ux_analysis.sh | step15_ux_analysis | ux_analysis |

## Next Steps

1. **Test the migration**:
   ```bash
   cd src/workflow
   ./test_modules.sh
   ```

2. **Update main workflow script**:
   - Source new `lib/step_registry.sh` and `lib/step_loader.sh`
   - Replace hardcoded step execution with registry/loader
   - Update all references to old step names

3. **Update documentation**:
   - Update README.md
   - Update API_STEP_MODULES.md
   - Update PROJECT_REFERENCE.md

4. **Commit changes**:
   ```bash
   git add -A
   git commit -m "feat: migrate to descriptive step names (v4.0.0)
   
   BREAKING CHANGE: Step files and functions renamed
   - Removed numeric prefixes from step files
   - Updated function names to match file names
   - Execution order now defined in .workflow-config.yaml
   
   Migration: See MIGRATION_REPORT_*.md for details"
   ```

## Configuration Required

Add workflow section to `.workflow-config.yaml`:

```yaml
workflow:
  settings:
    auto_mode: false
    parallel_execution: true
    smart_execution: true
    
  steps:
    - name: pre_analysis
      module: pre_analysis.sh
      function: pre_analysis
      enabled: true
      dependencies: []
    
    # ... see .workflow_core/config/.workflow-config.yaml.template for full example
```

## Rollback Instructions

If you need to rollback:

```bash
# Restore from backup
cp -r backups/pre-migration-YYYYMMDD_HHMMSS/steps/* src/workflow/steps/

# Unstage changes
git reset HEAD src/workflow/steps/

# Reset files
git checkout -- src/workflow/steps/
```
