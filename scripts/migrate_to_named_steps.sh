#!/bin/bash
set -euo pipefail

################################################################################
# Step Migration Script: v3.x → v4.0.0
# Purpose: Rename all step files from numbered to descriptive names
#
# This script:
#   1. Renames step files using git mv (preserves history)
#   2. Updates function names inside files
#   3. Creates a backup before migration
#   4. Generates a migration report
#
# Usage:
#   ./scripts/migrate_to_named_steps.sh [--dry-run]
#
# WARNING: This is a breaking change. Ensure you have backups!
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STEPS_DIR="$WORKFLOW_ROOT/src/workflow/steps"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run]"
            echo ""
            echo "Migrate step files from v3.x numbered naming to v4.0 descriptive naming"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --help       Show this help message"
            exit 0
            ;;
    esac
done

# Step mapping: old_file:new_file:old_function:new_function
declare -a STEP_MIGRATIONS=(
    "step_0a_version_update.sh:version_update.sh:step0a_version_update:version_update"
    "step_00_analyze.sh:pre_analysis.sh:step0_analyze_changes:pre_analysis"
    "step_0b_bootstrap_docs.sh:bootstrap_documentation.sh:step0b_bootstrap_documentation:bootstrap_documentation"
    "step_01_documentation.sh:documentation_updates.sh:step1_update_documentation:documentation_updates"
    "step_01_5_api_coverage.sh:api_coverage_analysis.sh:step1_5_api_coverage_analysis:api_coverage_analysis"
    "step_02_consistency.sh:consistency_analysis.sh:step2_check_consistency:consistency_analysis"
    "step_02_5_doc_optimize.sh:documentation_optimization.sh:step2_5_doc_optimization:documentation_optimization"
    "step_03_script_refs.sh:script_reference_validation.sh:step3_validate_script_references:script_reference_validation"
    "step_04_config_validation.sh:config_validation.sh:step4_config_validation:config_validation"
    "step_05_directory.sh:directory_validation.sh:step5_validate_directory:directory_validation"
    "step_06_test_review.sh:test_review.sh:step6_review_tests:test_review"
    "step_07_test_gen.sh:test_generation.sh:step7_generate_tests:test_generation"
    "step_08_test_exec.sh:test_execution.sh:step8_execute_tests:test_execution"
    "step_09_dependencies.sh:dependency_validation.sh:step9_validate_dependencies:dependency_validation"
    "step_10_code_quality.sh:code_quality_validation.sh:step10_code_quality_validation:code_quality_validation"
    "step_11_5_context.sh:context_analysis.sh:step10_context_analysis:context_analysis"
    "step_11_deployment_gate.sh:deployment_gate.sh:step11_deployment_gate:deployment_gate"
    "step_12_git.sh:git_finalization.sh:step12_git_finalization:git_finalization"
    "step_13_markdown_lint.sh:markdown_linting.sh:step13_markdown_linting:markdown_linting"
    "step_14_prompt_engineer.sh:prompt_engineer_analysis.sh:step14_prompt_engineer_analysis:prompt_engineer_analysis"
    "step_15_ux_analysis.sh:ux_analysis.sh:step15_ux_analysis:ux_analysis"
)

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if in git repository
    if ! git -C "$WORKFLOW_ROOT" rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository: $WORKFLOW_ROOT"
        exit 1
    fi
    print_success "Git repository detected"
    
    # Check for uncommitted changes
    if ! git -C "$WORKFLOW_ROOT" diff --quiet; then
        print_warning "You have uncommitted changes"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Migration cancelled"
            exit 0
        fi
    fi
    
    # Check if steps directory exists
    if [[ ! -d "$STEPS_DIR" ]]; then
        print_error "Steps directory not found: $STEPS_DIR"
        exit 1
    fi
    print_success "Steps directory found"
    
    echo ""
}

# Create backup
create_backup() {
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY-RUN] Would create backup"
        return 0
    fi
    
    print_header "Creating Backup"
    
    local backup_dir="$WORKFLOW_ROOT/backups/pre-migration-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Copy steps directory
    cp -r "$STEPS_DIR" "$backup_dir/"
    
    print_success "Backup created: $backup_dir"
    echo ""
}

# Rename step files
rename_step_files() {
    print_header "Renaming Step Files"
    
    local renamed_count=0
    local skipped_count=0
    
    for migration in "${STEP_MIGRATIONS[@]}"; do
        IFS=: read -r old_file new_file old_func new_func <<< "$migration"
        
        local old_path="$STEPS_DIR/$old_file"
        local new_path="$STEPS_DIR/$new_file"
        
        # Check if old file exists
        if [[ ! -f "$old_path" ]]; then
            print_warning "File not found (skipping): $old_file"
            ((skipped_count++)) || true
            continue
        fi
        
        # Check if new file already exists
        if [[ -f "$new_path" ]] && [[ "$old_path" != "$new_path" ]]; then
            print_warning "Target already exists (skipping): $new_file"
            ((skipped_count++)) || true
            continue
        fi
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would rename: $old_file → $new_file"
        else
            # Use git mv to preserve history
            if git -C "$WORKFLOW_ROOT" mv "$old_path" "$new_path" 2>/dev/null; then
                print_success "Renamed: $old_file → $new_file"
                ((renamed_count++)) || true
            else
                # Fallback to regular mv if git mv fails
                mv "$old_path" "$new_path"
                git -C "$WORKFLOW_ROOT" add "$new_path"
                print_success "Moved: $old_file → $new_file (git add)"
                ((renamed_count++)) || true
            fi
        fi
    done
    
    echo ""
    print_info "Renamed: $renamed_count files"
    print_info "Skipped: $skipped_count files"
    echo ""
}

# Update function names inside files
update_function_names() {
    print_header "Updating Function Names"
    
    local updated_count=0
    
    for migration in "${STEP_MIGRATIONS[@]}"; do
        IFS=: read -r old_file new_file old_func new_func <<< "$migration"
        
        local file_path="$STEPS_DIR/$new_file"
        
        # Skip if file doesn't exist
        [[ ! -f "$file_path" ]] && continue
        
        # Check if old function name exists in file
        if ! grep -q "$old_func" "$file_path" 2>/dev/null; then
            continue
        fi
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would update function: $old_func → $new_func in $new_file"
        else
            # Update function name
            sed -i "s/${old_func}/${new_func}/g" "$file_path"
            print_success "Updated function: $old_func → $new_func in $new_file"
            ((updated_count++)) || true
        fi
    done
    
    echo ""
    print_info "Updated: $updated_count functions"
    echo ""
}

# Rename associated lib directories
rename_lib_directories() {
    print_header "Renaming Associated Library Directories"
    
    local renamed_count=0
    
    # Map of old directory names to new names
    declare -A lib_dir_map=(
        ["step_01_lib"]="documentation_updates_lib"
        ["step_02_lib"]="consistency_analysis_lib"
        ["step_02_5_lib"]="documentation_optimization_lib"
        ["step_06_lib"]="test_review_lib"
        ["step_07_lib"]="test_generation_lib"
        ["step_0b_lib"]="bootstrap_documentation_lib"
        ["step_11_lib"]="deployment_gate_lib"
        ["step_01_5_lib"]="api_coverage_analysis_lib"
    )
    
    for old_dir in "${!lib_dir_map[@]}"; do
        local new_dir="${lib_dir_map[$old_dir]}"
        local old_path="$STEPS_DIR/$old_dir"
        local new_path="$STEPS_DIR/$new_dir"
        
        # Check if directory exists
        if [[ ! -d "$old_path" ]]; then
            continue
        fi
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would rename: $old_dir → $new_dir"
        else
            if git -C "$WORKFLOW_ROOT" mv "$old_path" "$new_path" 2>/dev/null; then
                print_success "Renamed: $old_dir → $new_dir"
                ((renamed_count++)) || true
            fi
        fi
    done
    
    echo ""
    print_info "Renamed: $renamed_count library directories"
    echo ""
}

# Generate migration report
generate_report() {
    print_header "Migration Report"
    
    local report_file="$WORKFLOW_ROOT/MIGRATION_REPORT_$(date +%Y%m%d_%H%M%S).md"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY-RUN] Would generate report: $report_file"
        return 0
    fi
    
    cat > "$report_file" << 'EOFEOF'
# Step Migration Report: v3.x → v4.0.0

## Migration Summary

- **Date**: $(date +%Y-%m-%d\ %H:%M:%S)
- **Script**: migrate_to_named_steps.sh
- **Purpose**: Rename step files from numbered to descriptive names

## Files Renamed

| Old File | New File | Old Function | New Function |
|----------|----------|--------------|--------------|
EOFEOF
    
    for migration in "${STEP_MIGRATIONS[@]}"; do
        IFS=: read -r old_file new_file old_func new_func <<< "$migration"
        echo "| $old_file | $new_file | $old_func | $new_func |" >> "$report_file"
    done
    
    cat >> "$report_file" << 'EOFEOF'

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
EOFEOF
    
    print_success "Migration report generated: $report_file"
    echo ""
}

# Main execution
main() {
    echo ""
    print_header "AI Workflow Step Migration: v3.x → v4.0.0"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    check_prerequisites
    create_backup
    rename_step_files
    rename_lib_directories
    update_function_names
    generate_report
    
    print_header "Migration Complete"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "This was a dry run. Run without --dry-run to apply changes."
    else
        print_success "Step files have been renamed successfully!"
        print_warning "Remember to:"
        echo "  1. Test the migration: ./src/workflow/test_modules.sh"
        echo "  2. Update main workflow script to use step_registry/step_loader"
        echo "  3. Update documentation"
        echo "  4. Commit changes with appropriate message"
    fi
    
    echo ""
}

# Run main function
main
