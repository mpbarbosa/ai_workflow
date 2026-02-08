#!/bin/bash
set -euo pipefail

################################################################################
# Step 0: Pre-Analysis - Analyzing Recent Changes
# Purpose: Analyze git state and capture change context before workflow execution (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.6.1
# Version: 3.0.8 (Added test infrastructure smoke test)
################################################################################

# Source test smoke test module
STEP0_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${STEP0_DIR}/../lib/test_smoke.sh" ]]; then
    source "${STEP0_DIR}/../lib/test_smoke.sh"
fi

# Main step function - analyzes recent changes and sets workflow context
# Returns: 0 for success
step0_analyze_changes() {
    print_step "0" "Pre-Analysis - Analyzing Recent Changes"
    cd "$PROJECT_ROOT" || return 1
    
    # Use cached git state (performance optimization)
    local commits_ahead
    local modified_files
    commits_ahead=$(get_git_commits_ahead)
    modified_files=$(get_git_total_changes)
    
    print_info "Commits ahead of remote: $commits_ahead"
    print_info "Modified files: $modified_files"
    
    # Tech Stack Detection Report (Phase 3)
    if [[ -n "${PRIMARY_LANGUAGE:-}" ]]; then
        print_info "Detected language: $PRIMARY_LANGUAGE"
        print_info "Build system: ${BUILD_SYSTEM:-none}"
        print_info "Test framework: ${TEST_FRAMEWORK:-none}"
    else
        print_info "Tech stack: Not yet initialized"
    fi
    
    # Project Kind Detection (Phase 1 - Project Kind Awareness)
    # Priority: 1. Config file, 2. Auto-detection
    if declare -f get_project_kind >/dev/null 2>&1; then
        local config_kind
        config_kind=$(get_project_kind "$PROJECT_ROOT" 2>/dev/null || echo "")
        
        if [[ -n "$config_kind" ]] && [[ "$config_kind" != "null" ]]; then
            # Use configured project kind
            export PROJECT_KIND="$config_kind"
            export PROJECT_KIND_CONFIDENCE=100
            local kind_desc
            kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
            print_success "Project kind from config: $kind_desc (configured)"
        elif declare -f detect_project_kind >/dev/null 2>&1; then
            # Auto-detect if not configured
            print_info "No project kind in config, auto-detecting..."
            local project_kind_result
            project_kind_result=$(detect_project_kind "$PROJECT_ROOT" 2>/dev/null || echo '{"kind":"unknown","confidence":0}')
            
            export PROJECT_KIND=$(echo "$project_kind_result" | grep -oP '"kind":\s*"\K[^"]+' || echo "unknown")
            export PROJECT_KIND_CONFIDENCE=$(echo "$project_kind_result" | grep -oP '"confidence":\s*\K[0-9]+' || echo "0")
            
            if [[ "$PROJECT_KIND" != "unknown" ]] && [[ $PROJECT_KIND_CONFIDENCE -gt 50 ]]; then
                local kind_desc
                kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
                print_info "Auto-detected project kind: $kind_desc (${PROJECT_KIND_CONFIDENCE}% confidence)"
            else
                print_info "Project kind: Could not determine with confidence"
            fi
        fi
    elif declare -f detect_project_kind >/dev/null 2>&1; then
        # Fallback to auto-detection only
        print_info "Detecting project kind..."
        local project_kind_result
        project_kind_result=$(detect_project_kind "$PROJECT_ROOT" 2>/dev/null || echo '{"kind":"unknown","confidence":0}')
        
        export PROJECT_KIND=$(echo "$project_kind_result" | grep -oP '"kind":\s*"\K[^"]+' || echo "unknown")
        export PROJECT_KIND_CONFIDENCE=$(echo "$project_kind_result" | grep -oP '"confidence":\s*\K[0-9]+' || echo "0")
        
        if [[ "$PROJECT_KIND" != "unknown" ]] && [[ $PROJECT_KIND_CONFIDENCE -gt 50 ]]; then
            local kind_desc
            kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
            print_info "Project kind: $kind_desc (${PROJECT_KIND_CONFIDENCE}% confidence)"
        else
            print_info "Project kind: Could not determine with confidence"
        fi
    fi
    
    # TEST INFRASTRUCTURE SMOKE TEST (NEW in v2.6.1)
    # Quick validation to catch test issues early (saves 30+ minutes on failures)
    local smoke_test_status="⚠️ Skipped"
    local smoke_test_details="Test smoke test not run"
    
    if declare -f smoke_test_infrastructure >/dev/null 2>&1; then
        print_info ""
        print_info "=== Test Infrastructure Pre-Validation ==="
        
        if smoke_test_infrastructure; then
            smoke_test_status="✅ Passed"
            smoke_test_details="Test infrastructure validated successfully"
            print_success "Test infrastructure validation passed"
        else
            smoke_test_status="❌ Failed"
            smoke_test_details="Test infrastructure validation failed - check logs"
            print_warning "Test infrastructure validation failed"
            print_warning "This may cause failures in Step 7 (Test Execution)"
            print_warning "Consider fixing test setup before continuing workflow"
            
            if [[ "${AUTO_MODE:-false}" != "true" ]]; then
                read -r -p "Continue anyway? (y/N): " continue_choice
                if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
                    print_error "Workflow aborted by user"
                    return 1
                fi
            fi
        fi
        print_info "=========================================="
        print_info ""
    fi
    
    # AI MODEL SELECTION ANALYSIS (NEW in v3.2.0)
    # Intelligent model selection based on change complexity
    local model_selection_status="⚠️ Skipped"
    local model_selection_details="Model selection not run"
    
    # Check if model selector module is available
    if [[ -f "${STEP0_DIR}/../lib/model_selector.sh" ]]; then
        source "${STEP0_DIR}/../lib/model_selector.sh"
        
        # Check if model selection is enabled (default: true)
        local enable_model_selection="${ENABLE_MODEL_SELECTION:-true}"
        
        if [[ "$enable_model_selection" == "true" ]]; then
            print_info ""
            print_info "=== AI Model Selection Analysis ==="
            
            # Classify files by nature
            local classified_files=$(classify_files_by_nature)
            local code_files=$(echo "$classified_files" | cut -d'|' -f1)
            local doc_files=$(echo "$classified_files" | cut -d'|' -f2)
            local test_files=$(echo "$classified_files" | cut -d'|' -f3)
            local config_files=$(echo "$classified_files" | cut -d'|' -f4)
            
            # Count files
            local code_count=$(echo "$code_files" | wc -w)
            local docs_count=$(echo "$doc_files" | wc -w)
            local tests_count=$(echo "$test_files" | wc -w)
            
            print_info "Change classification:"
            print_info "  • Code files: $code_count"
            print_info "  • Documentation: $docs_count"
            print_info "  • Tests: $tests_count"
            
            # Calculate complexities
            print_info ""
            print_info "Calculating complexity scores..."
            
            local code_complexity=$(calculate_code_complexity "$code_files")
            local docs_complexity=$(calculate_docs_complexity "$doc_files")
            local tests_complexity=$(calculate_tests_complexity "$test_files")
            
            # Extract scores and tiers
            local code_score=$(echo "$code_complexity" | jq -r '.score' 2>/dev/null || echo "0")
            local code_tier=$(echo "$code_complexity" | jq -r '.tier' 2>/dev/null || echo "low")
            local docs_score=$(echo "$docs_complexity" | jq -r '.score' 2>/dev/null || echo "0")
            local docs_tier=$(echo "$docs_complexity" | jq -r '.tier' 2>/dev/null || echo "low")
            local tests_score=$(echo "$tests_complexity" | jq -r '.score' 2>/dev/null || echo "0")
            local tests_tier=$(echo "$tests_complexity" | jq -r '.tier' 2>/dev/null || echo "low")
            
            print_info "Complexity analysis:"
            print_info "  • Code: $code_score → $(echo $code_tier | tr '[:lower:]' '[:upper:]')"
            print_info "  • Documentation: $docs_score → $(echo $docs_tier | tr '[:lower:]' '[:upper:]')"
            print_info "  • Tests: $tests_score → $(echo $tests_tier | tr '[:lower:]' '[:upper:]')"
            
            # Generate model definitions
            print_info ""
            print_info "Generating model assignments..."
            
            local model_definitions=$(generate_model_definitions "$code_files" "$doc_files" "$test_files")
            
            # Save to file
            if save_model_definitions "$model_definitions"; then
                model_selection_status="✅ Complete"
                model_selection_details="Model definitions generated and saved"
                print_success "Model definitions saved: .ai_workflow/model_definitions.json"
                
                # Display key model assignments
                print_info ""
                print_info "Key model assignments:"
                local step1_model=$(echo "$model_definitions" | jq -r '.model_definitions.step_01_documentation.model' 2>/dev/null || echo "N/A")
                local step5_model=$(echo "$model_definitions" | jq -r '.model_definitions.step_05_test_review.model' 2>/dev/null || echo "N/A")
                local step9_model=$(echo "$model_definitions" | jq -r '.model_definitions.step_09_code_quality.model' 2>/dev/null || echo "N/A")
                
                print_info "  • Step 1 (Documentation): $step1_model"
                print_info "  • Step 5 (Test Review): $step5_model"
                print_info "  • Step 9 (Code Quality): $step9_model"
                
                # Check for override
                if [[ -n "${FORCE_MODEL:-}" ]]; then
                    print_warning "⚠️  Model override active: All steps will use '$FORCE_MODEL'"
                fi
            else
                model_selection_status="❌ Failed"
                model_selection_details="Failed to save model definitions"
                print_warning "Failed to save model definitions - using defaults"
            fi
            
            print_info "=========================================="
            print_info ""
        else
            print_info "Model selection disabled in configuration"
        fi
    fi
    
    export ANALYSIS_COMMITS=$commits_ahead
    export ANALYSIS_MODIFIED=$modified_files
    
    # Auto-detect change scope based on modified files (v2.7.0 enhancement)
    local modified_list
    modified_list=$(git diff --name-only HEAD~${commits_ahead} HEAD 2>/dev/null || echo "")
        
        local docs_changed=0
        local tests_changed=0
        local src_changed=0
        local config_changed=0
        
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            
            # Skip workflow artifacts
            [[ "$file" =~ ^\.ai_workflow/ ]] && continue
            [[ "$file" =~ ^src/workflow/(backlog|logs|summaries|metrics|\.checkpoints|\.ai_cache)/ ]] && continue
            
            if [[ "$file" =~ ^docs/|README\.md$|CHANGELOG\.md$|\.md$ ]]; then
                ((docs_changed++)) || true
            elif [[ "$file" =~ ^tests?/|^test/|test.*\.(sh|js|py|go|rb)$|_test\.(sh|js|py|go|rb)$|\.test\.(sh|js|py|go|rb)$ ]]; then
                ((tests_changed++)) || true
            elif [[ "$file" =~ \.(yaml|yml|json|toml|ini|conf|config)$ ]]; then
                ((config_changed++)) || true
            elif [[ "$file" =~ ^src/|^lib/|\.sh$|\.js$|\.py$|\.go$|\.rb$|\.java$|\.rs$ ]]; then
                ((src_changed++)) || true
            fi
        done <<< "$modified_list"
        
        # Determine primary change scope
        if [[ $docs_changed -gt 0 ]] && [[ $tests_changed -eq 0 ]] && [[ $src_changed -eq 0 ]]; then
            CHANGE_SCOPE="documentation-only"
        elif [[ $tests_changed -gt 0 ]] && [[ $docs_changed -eq 0 ]] && [[ $src_changed -eq 0 ]]; then
            CHANGE_SCOPE="tests-only"
        elif [[ $src_changed -gt 0 ]] && [[ $tests_changed -eq 0 ]] && [[ $docs_changed -eq 0 ]]; then
            CHANGE_SCOPE="source-code"
        elif [[ $config_changed -gt 0 ]] && [[ $src_changed -eq 0 ]] && [[ $tests_changed -eq 0 ]] && [[ $docs_changed -eq 0 ]]; then
            CHANGE_SCOPE="configuration"
        elif [[ $src_changed -gt 0 ]] && [[ $tests_changed -gt 0 ]] && [[ $docs_changed -gt 0 ]]; then
            CHANGE_SCOPE="full-stack"
        elif [[ $src_changed -gt 0 ]] && [[ $tests_changed -gt 0 ]]; then
            CHANGE_SCOPE="code-and-tests"
        elif [[ $src_changed -gt 0 ]] && [[ $docs_changed -gt 0 ]]; then
            CHANGE_SCOPE="code-and-docs"
        elif [[ $modified_files -eq 0 ]]; then
            CHANGE_SCOPE="no-changes"
        else
            CHANGE_SCOPE="mixed-changes"
        fi
    
    # Export for use in subsequent steps (v2.7.0 fix)
    export CHANGE_SCOPE
    
    print_success "Pre-analysis complete (Scope: $CHANGE_SCOPE)"
    
    # Save step summary
    save_step_summary "0" "Pre_Analysis" "Analyzed ${modified_files} modified files across ${commits_ahead} commits. Change scope: ${CHANGE_SCOPE}. Test smoke test: ${smoke_test_status}. Repository state captured for workflow context." "✅"
    
    # Save pre-analysis data to backlog
    local step_issues
    local tech_stack_info=""
    if [[ -n "${PRIMARY_LANGUAGE:-}" ]]; then
        tech_stack_info="
### Tech Stack

**Language:** ${PRIMARY_LANGUAGE}
**Build System:** ${BUILD_SYSTEM:-none}
**Test Framework:** ${TEST_FRAMEWORK:-none}
**Package File:** ${TECH_STACK_CONFIG[package_file]:-none}
"
    fi
    
    local project_kind_info=""
    if [[ -n "${PROJECT_KIND:-}" ]] && [[ "${PROJECT_KIND}" != "unknown" ]]; then
        local kind_desc
        kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
        project_kind_info="
### Project Kind

**Type:** ${kind_desc}
**Confidence:** ${PROJECT_KIND_CONFIDENCE}%
**Identifier:** ${PROJECT_KIND}
"
    fi
    
    local smoke_test_info="
### Test Infrastructure Pre-Validation

**Status:** ${smoke_test_status}
**Details:** ${smoke_test_details}

This early validation helps catch test infrastructure issues before Step 7, potentially saving 30+ minutes of workflow execution time.
"
    
    step_issues="### Repository Analysis

**Commits Ahead:** ${commits_ahead}
**Modified Files:** ${modified_files}
**Change Scope:** ${CHANGE_SCOPE}
${tech_stack_info}${project_kind_info}${smoke_test_info}

### Modified Files List

\`\`\`
$(get_git_status_output)
\`\`\`
"
    save_step_issues "0" "Pre_Analysis" "$step_issues"
    
    update_workflow_status "step0" "✅"
}

# Export step function
export -f step0_analyze_changes
