#!/bin/bash
set -euo pipefail

################################################################################
# Step 4: AI-Powered Directory Structure Validation & Organization
# Purpose: Validate project directory structure, organize misplaced docs, and verify architecture
# Part of: Tests & Documentation Workflow Automation v2.3.1
# Version: 2.2.0 (Added automatic documentation organization)
################################################################################

# Module version information
readonly STEP4_VERSION="2.2.0"
readonly STEP4_VERSION_MAJOR=2
readonly STEP4_VERSION_MINOR=2
readonly STEP4_VERSION_PATCH=0

# Function to organize misplaced documentation files
# Finds all documentation files outside the docs/ folder and categorizes them
organize_misplaced_documentation() {
    local misplaced_count=0
    local organized_count=0
    
    # Ensure docs directory exists
    [[ ! -d "docs" ]] && mkdir -p "docs"
    
    # Find all markdown files in project root (excluding certain patterns)
    local doc_files=()
    while IFS= read -r file; do
        # Skip README.md, CHANGELOG.md, LICENSE.md, CONTRIBUTING.md in root
        local basename
        basename=$(basename "$file")
        if [[ "$basename" =~ ^(README|CHANGELOG|LICENSE|CONTRIBUTING|CODE_OF_CONDUCT)\.md$ ]]; then
            continue
        fi
        doc_files+=("$file")
        ((misplaced_count++))
    done < <(find . -maxdepth 1 -type f -name "*.md" 2>/dev/null)
    
    if [[ $misplaced_count -eq 0 ]]; then
        print_success "No misplaced documentation files found in project root"
        return 0
    fi
    
    print_warning "Found ${misplaced_count} documentation files in project root"
    
    # Categorize files by analyzing their content and filename
    declare -A categories=(
        ["workflow"]="docs/workflow-automation"
        ["test"]="docs/testing"
        ["guide"]="docs/guides"
        ["reference"]="docs/reference"
        ["architecture"]="docs/architecture"
        ["report"]="docs/reports"
        ["bugfix"]="docs/reports/bugfixes"
        ["implementation"]="docs/reports/implementation"
        ["analysis"]="docs/reports/analysis"
        ["uncategorized"]="docs/archive"
    )
    
    # Create category directories
    for dir in "${categories[@]}"; do
        mkdir -p "$dir"
    done
    
    # Categorize and move files
    for file in "${doc_files[@]}"; do
        local filename
        filename=$(basename "$file")
        local category="uncategorized"
        
        # Categorize by filename patterns
        if [[ "$filename" =~ (WORKFLOW|EXECUTION|ORCHESTRAT|PIPELINE|AUTOMATION) ]]; then
            category="workflow"
        elif [[ "$filename" =~ (TEST|COVERAGE|SPEC) ]]; then
            category="test"
        elif [[ "$filename" =~ (BUGFIX|FIX|ISSUE|BUG) ]]; then
            category="bugfix"
        elif [[ "$filename" =~ (IMPLEMENTATION|COMPLETE|SUMMARY|MIGRATION|REFACTOR) ]]; then
            category="implementation"
        elif [[ "$filename" =~ (ANALYSIS|REPORT|VALIDATION|REVIEW|AUDIT) ]]; then
            category="analysis"
        elif [[ "$filename" =~ (GUIDE|HOWTO|TUTORIAL|QUICK|REFERENCE) ]]; then
            category="guide"
        elif [[ "$filename" =~ (ARCHITECTURE|DESIGN|PATTERN|STRUCTURE) ]]; then
            category="architecture"
        elif [[ "$filename" =~ (DELIVERABLE|CHECKLIST|PHASE|RECOMMENDATION) ]]; then
            category="report"
        fi
        
        # Determine target directory
        local target_dir="${categories[$category]}"
        local target_file="${target_dir}/${filename}"
        
        # Check if file already exists in target
        if [[ -f "$target_file" ]]; then
            print_warning "  Skipping ${filename} - already exists in ${target_dir}"
            continue
        fi
        
        # Move file
        if [[ "$DRY_RUN" == true ]]; then
            print_info "  [DRY RUN] Would move: ${filename} → ${target_dir}/"
        else
            if mv "$file" "$target_file" 2>/dev/null; then
                print_success "  Moved: ${filename} → ${target_dir}/"
                ((organized_count++))
            else
                print_error "  Failed to move: ${filename}"
            fi
        fi
    done
    
    # Summary
    if [[ $organized_count -gt 0 ]]; then
        print_success "Organized ${organized_count} of ${misplaced_count} documentation files"
        echo "Doc organization: ${organized_count} files moved" >> "$structure_issues_file"
    elif [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would organize ${misplaced_count} documentation files"
    else
        print_warning "No files were organized (all may already exist in target locations)"
    fi
}

export -f organize_misplaced_documentation

# Main step function - validates directory structure with AI assistance
# Returns: 0 for success, 1 for failure
step4_validate_directory_structure() {
    print_step "4" "Validate Directory Structure"
    
    cd "$PROJECT_ROOT" || return 1
    
    local issues=0
    local structure_issues_file
    structure_issues_file=$(mktemp)
    TEMP_FILES+=("$structure_issues_file")
    
    # PHASE 1: Automated directory structure detection (ADAPTIVE - Phase 3)
    local language="${PRIMARY_LANGUAGE:-javascript}"
    print_info "Phase 1: Automated directory structure detection (${language})..."
    
    # Get exclude patterns from tech stack
    local exclude_patterns=""
    if command -v get_exclude_patterns &>/dev/null; then
        exclude_patterns=$(get_exclude_patterns | tr '\n' '|' | sed 's/|$//')
    else
        # Fallback exclude patterns
        exclude_patterns="node_modules|.git|coverage|__pycache__|.venv"
    fi
    
    # Check 1: Generate current directory structure
    print_info "Generating directory inventory (excluding: ${exclude_patterns})..."
    local dir_tree=""
    if command -v tree &> /dev/null; then
        dir_tree=$(tree -d -L 3 -I "${exclude_patterns}" --noreport 2>/dev/null || true)
    else
        # Fallback: use find if tree is not available
        local exclude_find=""
        IFS='|' read -ra PATTERNS <<< "$exclude_patterns"
        for pattern in "${PATTERNS[@]}"; do
            exclude_find+=" ! -path \"*/${pattern}/*\""
        done
        dir_tree=$(eval "find . -maxdepth 3 -type d ${exclude_find}" | sort)
    fi
    
    # Check 2: Validate expected critical directories exist
    print_info "Validating critical directories..."
    
    # Determine expected directories based on project configuration
    local critical_dirs=()
    
    # Check if we have tech stack configuration
    if [[ -f ".workflow-config.yaml" ]] && command -v yq &>/dev/null; then
        # Load source, test, and docs dirs from config
        # Note: yq syntax varies - try both versions (mikefarah's yq uses 'e' flag, kislyuk's doesn't)
        local config_src_dirs=$(yq '.structure.source_dirs[]' .workflow-config.yaml 2>/dev/null || yq e '.structure.source_dirs[]' .workflow-config.yaml 2>/dev/null)
        local config_test_dirs=$(yq '.structure.test_dirs[]' .workflow-config.yaml 2>/dev/null || yq e '.structure.test_dirs[]' .workflow-config.yaml 2>/dev/null)
        local config_docs_dirs=$(yq '.structure.docs_dirs[]' .workflow-config.yaml 2>/dev/null || yq e '.structure.docs_dirs[]' .workflow-config.yaml 2>/dev/null)
        
        # Add to critical dirs if they exist in config (strip quotes from yq output)
        [[ -n "$config_src_dirs" ]] && while read -r dir; do dir=$(echo "$dir" | tr -d '"'); [[ -n "$dir" ]] && critical_dirs+=("$dir"); done <<< "$config_src_dirs"
        [[ -n "$config_test_dirs" ]] && while read -r dir; do dir=$(echo "$dir" | tr -d '"'); [[ -n "$dir" ]] && critical_dirs+=("$dir"); done <<< "$config_test_dirs"
        [[ -n "$config_docs_dirs" ]] && while read -r dir; do dir=$(echo "$dir" | tr -d '"'); [[ -n "$dir" ]] && critical_dirs+=("$dir"); done <<< "$config_docs_dirs"
    else
        # Fallback: use generic defaults appropriate for most projects
        # Only include .github as it's common across all project types
        critical_dirs=(".github")
        
        # Add common directories if they exist (non-critical)
        [[ -d "src" ]] && critical_dirs+=("src")
        [[ -d "docs" ]] && critical_dirs+=("docs")
        [[ -d "lib" ]] && critical_dirs+=("lib")
        [[ -d "bin" ]] && critical_dirs+=("bin")
        [[ -d "tests" ]] && critical_dirs+=("tests")
        [[ -d "test" ]] && critical_dirs+=("test")
    fi
    
    local missing_critical=0
    
    # Only validate if we have critical dirs defined
    if [[ ${#critical_dirs[@]} -gt 0 ]]; then
        for dir in "${critical_dirs[@]}"; do
            if [[ ! -d "$dir" ]]; then
                print_warning "Expected directory missing: $dir"
                echo "Missing expected: $dir" >> "$structure_issues_file"
                ((missing_critical++))
                ((issues++))
            fi
        done
    else
        print_info "No critical directories defined, skipping validation"
    fi
    
    # Check 3: Identify undocumented directories
    print_info "Checking for undocumented directories..."
    local undocumented_dirs=0
    
    # Check if directories are mentioned in documentation
    if [[ -f "README.md" ]] || [[ -f ".github/copilot-instructions.md" ]]; then
        while IFS= read -r dir; do
            [[ -z "$dir" || "$dir" == "." ]] && continue
            local dir_name
            dir_name=$(basename "$dir")
            
            # Skip common/expected directories
            [[ "$dir_name" =~ ^(node_modules|\.git|coverage|\.vscode)$ ]] && continue
            
            # Check if directory is documented
            local is_documented=false
            if [[ -f "README.md" ]] && grep -q "$dir_name" "README.md" 2>/dev/null; then
                is_documented=true
            fi
            if [[ -f ".github/copilot-instructions.md" ]] && grep -q "$dir_name" ".github/copilot-instructions.md" 2>/dev/null; then
                is_documented=true
            fi
            
            if [[ "$is_documented" == false ]]; then
                print_warning "Undocumented directory: $dir"
                echo "Undocumented: $dir" >> "$structure_issues_file"
                ((undocumented_dirs++))
                ((issues++))
            fi
        done < <(find . -maxdepth 2 -type d ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" ! -path "*/.vscode" | tail -n +2)
    fi
    
    # Check 4: Validate structure consistency with documented structure
    print_info "Validating structure against documentation..."
    local doc_structure_mismatch=0
    
    # Extract directory structure from copilot-instructions if it exists
    if [[ -f ".github/copilot-instructions.md" ]]; then
        # Look for directory structure documentation
        if grep -q "directory structure\|Directory Structure\|File Structure" ".github/copilot-instructions.md" 2>/dev/null; then
            # Use config-defined directories or auto-detected ones
            local key_dirs=()
            if [[ ${#critical_dirs[@]} -gt 0 ]]; then
                key_dirs=("${critical_dirs[@]}")
            fi
            
            for dir in "${key_dirs[@]}"; do
                if grep -q "$dir" ".github/copilot-instructions.md" 2>/dev/null; then
                    if [[ ! -d "$dir" ]]; then
                        print_warning "Documented directory not found: $dir"
                        echo "Doc mismatch: $dir (documented but missing)" >> "$structure_issues_file"
                        ((doc_structure_mismatch++))
                        ((issues++))
                    fi
                fi
            done
        fi
    fi
    
    # PHASE 1.5: Document Organization - Find and categorize misplaced documentation files
    print_info "Phase 1.5: Organizing misplaced documentation files..."
    organize_misplaced_documentation
    
    # PHASE 2: AI-powered architectural analysis
    print_info "Phase 2: Preparing AI-powered architectural analysis..."
    
    # Gather directory metadata
    local dir_count
    dir_count=$(find . -maxdepth 3 -type d ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" | wc -l)
    local structure_issues_content
    structure_issues_content=$(cat "$structure_issues_file" 2>/dev/null || echo "   No automated issues detected")
    
    # Get directory tree for AI analysis
    local dir_tree
    dir_tree=$(tree -L 3 -d -I 'node_modules|.git|coverage' 2>/dev/null || find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/coverage/*' | head -50)
    
    # Build comprehensive architectural analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step4_directory_prompt \
        "$dir_count" \
        "${CHANGE_SCOPE}" \
        "$missing_critical" \
        "$undocumented_dirs" \
        "$doc_structure_mismatch" \
        "$structure_issues_content" \
        "$dir_tree")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Directory Structure Validation Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with directory structure validation prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to validate directory structure?" "y"; then
            # Save prompt to temporary file for tracking
            local temp_prompt_file
            temp_prompt_file=$(mktemp)
            TEMP_FILES+=("$temp_prompt_file")
            echo "$copilot_prompt" > "$temp_prompt_file"
            
            # Invoke Copilot CLI
            print_info "Starting Copilot CLI session..."
            
            # Create log file with unique timestamp
            local log_timestamp
            log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
            local log_file="${LOGS_RUN_DIR}/step4_copilot_directory_validation_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "4" "Directory_Structure_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Save step results using shared library
    # Handle critical directory failures specially
    if [[ $missing_critical -gt 0 ]]; then
        print_error "Critical: $missing_critical critical directories missing!"
        local failure_msg="CRITICAL: ${missing_critical} critical directories missing. Found ${issues} total structural issues requiring immediate attention."
        save_step_summary "4" "Directory_Structure_Validation" "$failure_msg" "❌"
        
        # Build detailed critical issues
        local step_issues="### Directory Structure Issues Found

**Total Issues:** ${issues}
**Missing Critical Directories:** ${missing_critical}

"
        if [[ -f "$structure_issues_file" && -s "$structure_issues_file" ]]; then
            step_issues+="### Details

\`\`\`
$(cat "$structure_issues_file")
\`\`\`
"
        fi
        save_step_issues "4" "Directory_Structure_Validation" "$step_issues"
    else
        save_step_results \
            "4" \
            "Directory_Structure_Validation" \
            "$issues" \
            "Directory structure valid in automated checks" \
            "Found ${issues} structural issues. Review missing or misorganized directories." \
            "$structure_issues_file" \
            "$dir_count"
    fi
    
    update_workflow_status "step4" "✅"
}

# Export step function
export -f step4_validate_directory_structure
