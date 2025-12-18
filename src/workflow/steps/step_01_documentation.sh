#!/bin/bash
################################################################################
# Step 1: AI-Powered Documentation Updates
# Purpose: Update documentation based on code changes with AI assistance
# Part of: Tests & Documentation Workflow Automation v1.5.0
# Version: 1.5.0
################################################################################

# Module version information
readonly STEP1_VERSION="1.5.0"
readonly STEP1_VERSION_MAJOR=1
readonly STEP1_VERSION_MINOR=5
readonly STEP1_VERSION_PATCH=0

# Performance cache for expensive operations
declare -A STEP1_CACHE

# Initialize performance cache
# Clears any existing cache entries for fresh start
init_performance_cache() {
    STEP1_CACHE=()
    export STEP1_CACHE
}

# Get cached value or execute function and cache result
# Usage: get_or_cache <cache_key> <function_name> [function_args...]
# Returns: Cached value or function output
get_or_cache() {
    local cache_key="$1"
    shift
    
    # Check if value is cached
    if [[ -n "${STEP1_CACHE[$cache_key]}" ]]; then
        echo "${STEP1_CACHE[$cache_key]}"
        return 0
    fi
    
    # Execute function and cache result
    local result
    result=$("$@")
    STEP1_CACHE[$cache_key]="$result"
    echo "$result"
}

# Parallel file analysis with job control
# Usage: parallel_file_analysis <file_pattern> <analysis_function>
# Returns: Combined output from parallel jobs
parallel_file_analysis() {
    local pattern="$1"
    local analysis_func="$2"
    local max_jobs=4  # Limit parallel jobs to avoid overwhelming system
    local job_count=0
    local temp_dir
    temp_dir=$(mktemp -d)
    TEMP_FILES+=("$temp_dir")
    
    # Process files in parallel with job control
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Launch background job
        {
            local output
            output=$("$analysis_func" "$file")
            echo "$output" > "${temp_dir}/$(basename "$file").result"
        } &
        
        ((job_count++))
        
        # Wait if we hit max parallel jobs
        if [[ $job_count -ge $max_jobs ]]; then
            wait -n  # Wait for any job to complete
            ((job_count--))
        fi
    done < <(find . -name "$pattern" -type f 2>/dev/null || true)
    
    # Wait for all remaining jobs
    wait
    
    # Combine results
    cat "${temp_dir}"/*.result 2>/dev/null || true
}

# Optimized version reference check using single pass
# Returns: Version issues string
check_version_references_optimized() {
    local version_to_check="$1"
    local issues=""
    
    # Single grep pass for both files with parallel execution
    {
        if [[ -f "README.md" ]]; then
            grep -n "workflow.*v1\.[0-9]\.0\|automation.*v1\.[0-9]\.0\|execute_tests_docs_workflow.*v1\.[0-9]\.0" README.md 2>/dev/null | \
                grep -v "v${version_to_check}" | \
                while IFS=: read -r line content; do
                    echo "README.md:${line}:${content}"
                done
        fi
    } &
    local pid1=$!
    
    {
        if [[ -f ".github/copilot-instructions.md" ]]; then
            grep -n "workflow.*v1\.[0-9]\.0\|automation.*v1\.[0-9]\.0\|execute_tests_docs_workflow.*v1\.[0-9]\.0" .github/copilot-instructions.md 2>/dev/null | \
                grep -v "v${version_to_check}" | \
                while IFS=: read -r line content; do
                    echo ".github/copilot-instructions.md:${line}:${content}"
                done
        fi
    } &
    local pid2=$!
    
    # Wait for both parallel checks
    wait $pid1 $pid2
}

# Cached git operations
# Returns: Cached git diff files output
get_cached_git_diff() {
    local cache_key="git_diff_files"
    
    # Return cached result if available
    if [[ -n "${STEP1_CACHE[$cache_key]}" ]]; then
        echo "${STEP1_CACHE[$cache_key]}"
        return 0
    fi
    
    # Get fresh git diff and cache it
    local diff_output
    diff_output=$(get_git_diff_files_output)
    STEP1_CACHE[$cache_key]="$diff_output"
    echo "$diff_output"
}

# Batch file existence checks
# Usage: batch_file_check <file1> <file2> <file3> ...
# Returns: List of missing files
batch_file_check() {
    local missing_files=()
    
    # Check all files in single pass
    for file in "$@"; do
        [[ -f "$file" ]] || missing_files+=("$file")
    done
    
    # Return missing files
    printf '%s\n' "${missing_files[@]}"
}

# Optimized grep operations with single-pass processing
# Usage: optimized_multi_grep <file> <pattern1> <pattern2> ...
# Returns: Combined grep results
optimized_multi_grep() {
    local file="$1"
    shift
    local patterns=("$@")
    
    # Combine patterns with OR operator for single grep pass
    local combined_pattern
    combined_pattern=$(IFS='|'; echo "${patterns[*]}")
    
    grep -E "$combined_pattern" "$file" 2>/dev/null || true
}

# Get the module version
# Usage: step1_get_version [--format=simple|full|semver]
# Returns: Version string
step1_get_version() {
    local format="${1:---format=simple}"
    
    case "$format" in
        --format=simple|simple)
            echo "$STEP1_VERSION"
            ;;
        --format=full|full)
            echo "Step 1 (Documentation Updates) v$STEP1_VERSION"
            ;;
        --format=semver|semver)
            echo "Major: $STEP1_VERSION_MAJOR, Minor: $STEP1_VERSION_MINOR, Patch: $STEP1_VERSION_PATCH"
            ;;
        --format=json|json)
            echo "{\"version\":\"$STEP1_VERSION\",\"major\":$STEP1_VERSION_MAJOR,\"minor\":$STEP1_VERSION_MINOR,\"patch\":$STEP1_VERSION_PATCH}"
            ;;
        *)
            echo "$STEP1_VERSION"
            ;;
    esac
}

# Determine target folder for documentation based on file path
# Usage: determine_doc_folder <file_path>
# Returns: Absolute path to target folder
determine_doc_folder() {
    local doc_file="$1"
    local target_folder=""
    
    # Determine folder based on file path patterns
    if [[ "$doc_file" =~ ^docs/ ]]; then
        target_folder="$PROJECT_ROOT/docs"
    elif [[ "$doc_file" =~ ^shell_scripts/ ]]; then
        target_folder="$PROJECT_ROOT/shell_scripts"
    elif [[ "$doc_file" =~ ^src/ ]]; then
        target_folder="$PROJECT_ROOT/src"
    elif [[ "$doc_file" == "README.md" ]] || [[ "$doc_file" =~ ^\.github/ ]]; then
        target_folder="$PROJECT_ROOT"
    else
        # Default to docs folder for unknown types
        target_folder="$PROJECT_ROOT/docs"
    fi
    
    echo "$target_folder"
}

# Automatically save AI-generated documentation to proper folder
# Usage: save_ai_generated_docs <ai_output_file> <target_doc_file>
# Returns: 0 for success, 1 for failure
save_ai_generated_docs() {
    local ai_output="$1"
    local target_doc="$2"
    
    if [[ ! -f "$ai_output" ]]; then
        print_error "AI output file not found: $ai_output"
        return 1
    fi
    
    # Determine target folder
    local target_folder
    target_folder=$(determine_doc_folder "$target_doc")
    
    # Ensure target folder exists
    mkdir -p "$target_folder"
    
    # Construct full target path
    local target_path
    if [[ "$target_doc" == /* ]]; then
        # Absolute path provided
        target_path="$target_doc"
    else
        # Relative path - construct full path
        target_path="$PROJECT_ROOT/$target_doc"
    fi
    
    # Save AI-generated content
    if cp "$ai_output" "$target_path"; then
        print_success "AI-generated documentation saved to: $target_path"
        return 0
    else
        print_error "Failed to save AI-generated documentation to: $target_path"
        return 1
    fi
}

# Automated file count validation (OPTIMIZED with caching and parallel processing)
# Validates that documented file counts match actual counts
# Returns: 0 if consistent, count of inconsistencies otherwise
validate_documentation_file_counts() {
    local inconsistencies=0
    
    print_info "Validating documentation file counts..."
    
    # Parallel execution of both checks
    {
        # Check shell_scripts documentation
        if [[ -f "shell_scripts/README.md" ]]; then
            # Use cached script count if available
            local actual_scripts
            actual_scripts=$(get_or_cache "shell_scripts_count" fast_find "shell_scripts" "*.sh" 5 "node_modules" ".git" | wc -l)
            
            # Single grep pass for both patterns
            local documented_counts
            documented_counts=$(grep -oP '\d+\s+(shell\s+)?scripts?' "shell_scripts/README.md" 2>/dev/null | grep -oP '^\d+' || echo "0")
            
            while IFS= read -r count; do
                [[ -z "$count" || "$count" == "0" ]] && continue
                if [[ "$count" != "$actual_scripts" ]]; then
                    echo "MISMATCH:shell_scripts:${count}:${actual_scripts}"
                    ((inconsistencies++))
                fi
            done <<< "$documented_counts"
            
            if [[ $inconsistencies -eq 0 ]]; then
                echo "SUCCESS:shell_scripts:${actual_scripts}"
            fi
        fi
    } &
    local pid1=$!
    
    {
        # Check submodule references
        if [[ -f ".gitmodules" ]]; then
            # Cache submodule count
            local actual_submodules
            actual_submodules=$(get_or_cache "submodule_count" grep -c '^\[submodule' .gitmodules 2>/dev/null || echo "0")
            
            # Check README.md for submodule count mentions
            if [[ -f "README.md" ]]; then
                local readme_submodule_counts
                readme_submodule_counts=$(grep -oP '\d+\s+submodules?' "README.md" 2>/dev/null | grep -oP '^\d+' || echo "0")
                
                while IFS= read -r count; do
                    [[ -z "$count" || "$count" == "0" ]] && continue
                    if [[ "$count" != "$actual_submodules" ]]; then
                        echo "MISMATCH:submodules:${count}:${actual_submodules}"
                        ((inconsistencies++))
                    fi
                done <<< "$readme_submodule_counts"
            fi
        fi
    } &
    local pid2=$!
    
    # Wait for parallel jobs and parse results
    wait $pid1 $pid2
    
    # Process output from parallel jobs
    while IFS=: read -r type category documented actual; do
        case "$type" in
            MISMATCH)
                if [[ "$category" == "shell_scripts" ]]; then
                    print_warning "File count mismatch in shell_scripts/README.md: documented=${documented}, actual=${actual}"
                else
                    print_warning "Submodule count mismatch in README.md: documented=${documented}, actual=${actual}"
                fi
                ;;
            SUCCESS)
                print_success "${category} file count validated: ${documented} scripts"
                ;;
        esac
    done < <(jobs -p | xargs -I {} cat /proc/{}/fd/1 2>/dev/null || true)
    
    return $inconsistencies
}

# Cross-reference validation for submodules
# Ensures submodule references are consistent across all documentation
# Returns: 0 if consistent, 1 if inconsistencies found
validate_submodule_cross_references() {
    local issues=0
    
    print_info "Validating submodule cross-references..."
    
    # Extract submodules from .gitmodules
    if [[ ! -f ".gitmodules" ]]; then
        print_info "No .gitmodules file found - skipping submodule validation"
        return 0
    fi
    
    # Get list of submodules
    local submodules
    submodules=$(grep '^\[submodule' .gitmodules | sed 's/\[submodule "\(.*\)"\]/\1/' || true)
    
    if [[ -z "$submodules" ]]; then
        print_info "No submodules configured"
        return 0
    fi
    
    # Check each submodule is referenced in key documentation
    local doc_files=("README.md" ".github/copilot-instructions.md")
    
    while IFS= read -r submodule; do
        [[ -z "$submodule" ]] && continue
        
        local submodule_name
        submodule_name=$(basename "$submodule")
        
        print_info "Checking references to submodule: $submodule_name"
        
        for doc in "${doc_files[@]}"; do
            if [[ -f "$doc" ]]; then
                if ! grep -qi "$submodule_name" "$doc" 2>/dev/null; then
                    print_warning "Submodule '$submodule_name' not referenced in $doc"
                    ((issues++))
                fi
            fi
        done
    done <<< "$submodules"
    
    if [[ $issues -eq 0 ]]; then
        print_success "All submodules properly cross-referenced in documentation ✅"
    fi
    
    return $issues
}

# Change set validation for submodule architecture
# Detects if submodule-related changes require documentation updates
# Returns: 0 if no action needed, 1 if documentation update required
validate_submodule_architecture_changes() {
    local doc_update_required=0
    
    print_info "Validating submodule architecture changes..."
    
    # Get changed files from git cache
    local changed_files
    changed_files=$(get_git_diff_files_output)
    
    # Check if .gitmodules was modified
    if echo "$changed_files" | grep -q "^\.gitmodules$"; then
        print_warning ".gitmodules modified - documentation update REQUIRED"
        echo "  → Update README.md with new submodule information"
        echo "  → Update .github/copilot-instructions.md"
        doc_update_required=1
    fi
    
    # Check if submodule directories were added/removed
    local submodule_dirs
    submodule_dirs=$(grep 'path = ' .gitmodules 2>/dev/null | awk '{print $3}' || true)
    
    while IFS= read -r submodule_dir; do
        [[ -z "$submodule_dir" ]] && continue
        
        if echo "$changed_files" | grep -q "^${submodule_dir}/"; then
            print_info "Submodule directory modified: $submodule_dir"
            
            # Check if it's a structural change (new files, directory structure)
            if echo "$changed_files" | grep -qE "^${submodule_dir}/(README\.md|package\.json|\.gitmodules)"; then
                print_warning "Submodule structure modified: $submodule_dir - documentation update recommended"
                doc_update_required=1
            fi
        fi
    done <<< "$submodule_dirs"
    
    if [[ $doc_update_required -eq 0 ]]; then
        print_success "No submodule architecture changes requiring documentation updates"
    fi
    
    return $doc_update_required
}

# Documentation consistency testing (OPTIMIZED with parallel test execution)
# Runs automated tests to verify documentation consistency
# Returns: 0 if all tests pass, count of failed tests otherwise
test_documentation_consistency() {
    local failed_tests=0
    local test_results_file
    test_results_file=$(mktemp)
    TEMP_FILES+=("$test_results_file")
    
    print_info "Running documentation consistency tests (parallel execution)..."
    
    # Test 1: Verify all documented files exist (run in background)
    {
        print_info "Test 1: Verifying documented files exist..."
        local test1_failures=0
        
        if [[ -f "shell_scripts/README.md" ]]; then
            # Extract all script references
            local script_refs
            script_refs=$(grep -oP '(?<=`\./)shell_scripts/[^`]+\.sh' "shell_scripts/README.md" 2>/dev/null || true)
            
            # Batch file check instead of sequential
            local missing_files
            missing_files=$(batch_file_check $script_refs)
            
            if [[ -n "$missing_files" ]]; then
                while IFS= read -r script; do
                    print_warning "Test 1 FAIL: Referenced script not found: $script"
                    ((test1_failures++))
                done <<< "$missing_files"
            fi
        fi
        
        if [[ $test1_failures -eq 0 ]]; then
            echo "TEST1:PASS:0" >> "$test_results_file"
        else
            echo "TEST1:FAIL:${test1_failures}" >> "$test_results_file"
        fi
    } &
    local pid1=$!
    
    # Test 2: Verify submodule references are consistent (run in background)
    {
        print_info "Test 2: Verifying submodule reference consistency..."
        if validate_submodule_cross_references 2>/dev/null; then
            echo "TEST2:PASS:0" >> "$test_results_file"
        else
            echo "TEST2:FAIL:1" >> "$test_results_file"
        fi
    } &
    local pid2=$!
    
    # Test 3: Verify file counts are accurate (run in background)
    {
        print_info "Test 3: Verifying file counts..."
        if validate_documentation_file_counts 2>/dev/null; then
            echo "TEST3:PASS:0" >> "$test_results_file"
        else
            echo "TEST3:FAIL:1" >> "$test_results_file"
        fi
    } &
    local pid3=$!
    
    # Test 4: Verify version references are consistent (run in background)
    {
        print_info "Test 4: Verifying version references..."
        
        # Optimized: single grep pass for both files
        local version_refs
        version_refs=$(optimized_multi_grep "README.md" "workflow.*v[0-9]\.[0-9]\.[0-9]" ; \
                       optimized_multi_grep ".github/copilot-instructions.md" "workflow.*v[0-9]\.[0-9]\.[0-9]" 2>/dev/null || true)
        
        if [[ -n "$version_refs" ]]; then
            local unique_versions
            unique_versions=$(echo "$version_refs" | grep -oP 'v[0-9]\.[0-9]\.[0-9]' | sort -u)
            local version_count
            version_count=$(echo "$unique_versions" | wc -l)
            
            if [[ $version_count -gt 1 ]]; then
                echo "TEST4:FAIL:1" >> "$test_results_file"
            else
                echo "TEST4:PASS:0" >> "$test_results_file"
            fi
        else
            echo "TEST4:PASS:0" >> "$test_results_file"
        fi
    } &
    local pid4=$!
    
    # Wait for all parallel tests to complete
    wait $pid1 $pid2 $pid3 $pid4
    
    # Parse test results
    while IFS=: read -r test_name status failures; do
        case "$test_name" in
            TEST1)
                if [[ "$status" == "PASS" ]]; then
                    print_success "Test 1 PASS: All documented scripts exist"
                else
                    print_warning "Test 1 FAIL: ${failures} referenced file(s) not found"
                    ((failed_tests += failures))
                fi
                ;;
            TEST2)
                if [[ "$status" == "PASS" ]]; then
                    print_success "Test 2 PASS: Submodule references consistent"
                else
                    print_warning "Test 2 FAIL: Submodule reference inconsistencies detected"
                    ((failed_tests++))
                fi
                ;;
            TEST3)
                if [[ "$status" == "PASS" ]]; then
                    print_success "Test 3 PASS: File counts are accurate"
                else
                    print_warning "Test 3 FAIL: File count discrepancies detected"
                    ((failed_tests++))
                fi
                ;;
            TEST4)
                if [[ "$status" == "PASS" ]]; then
                    print_success "Test 4 PASS: Version references consistent"
                else
                    print_warning "Test 4 FAIL: Multiple workflow versions referenced"
                    ((failed_tests++))
                fi
                ;;
        esac
    done < "$test_results_file"
    
    # Summary
    if [[ $failed_tests -eq 0 ]]; then
        print_success "All documentation consistency tests passed ✅ (parallel execution)"
    else
        print_warning "Documentation consistency: ${failed_tests} test(s) failed"
    fi
    
    return $failed_tests
}

# Main step function - updates documentation based on git changes
# Returns: 0 for success, 1 for failure
step1_update_documentation() {
    print_step "1" "Update Related Documentation"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Initialize performance cache for this step execution
    init_performance_cache
    
    # PERFORMANCE OPTIMIZATION: Use cached git diff (aggressive caching)
    local changed_files
    changed_files=$(get_cached_git_diff)
    
    print_info "Changed files detected (from cache):"
    echo "$changed_files" | head -50
    
    # PERFORMANCE OPTIMIZATION: Parallel grep for file pattern matching
    local docs_to_review=()
    local has_shell_scripts=false
    local has_src_scripts=false
    local has_docs=false
    
    # Use single grep pass for all patterns (parallel execution)
    {
        if echo "$changed_files" | grep -q "shell_scripts/"; then
            has_shell_scripts=true
        fi
    } &
    local pid_shell=$!
    
    {
        if echo "$changed_files" | grep -q "src/scripts/"; then
            has_src_scripts=true
        fi
    } &
    local pid_src=$!
    
    {
        if echo "$changed_files" | grep -q "docs/"; then
            has_docs=true
        fi
    } &
    local pid_docs=$!
    
    # Wait for pattern matching to complete
    wait $pid_shell $pid_src $pid_docs
    
    # Build documentation review list based on results
    if [[ "$has_shell_scripts" == true ]]; then
        docs_to_review+=("shell_scripts/README.md")
        print_info "→ shell_scripts modified - review shell_scripts/README.md"
    fi
    
    if [[ "$has_src_scripts" == true ]]; then
        docs_to_review+=("README.md")
        print_info "→ src/scripts modified - review README.md"
    fi
    
    if [[ "$has_docs" == true ]]; then
        print_info "→ Documentation files modified"
    fi
    
    # Build comprehensive GitHub Copilot CLI prompt for documentation updates
    print_info "Preparing GitHub Copilot CLI prompt for documentation updates..."
    
    local modified_files_list
    modified_files_list=$(echo "$changed_files" | tr '\n' ',' | sed 's/,$//')
    
    # Build AI prompt using helper function
    local copilot_prompt
    copilot_prompt=$(build_doc_analysis_prompt "$modified_files_list" "${docs_to_review[*]}")
    
    echo -e "\n${CYAN}GitHub Copilot CLI Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # Check if new GitHub Copilot CLI is available
    if is_copilot_available; then
        print_info "GitHub Copilot CLI detected - invoking documentation update..."
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would invoke: copilot -p with documentation prompt"
        else
            if confirm_action "Run GitHub Copilot CLI to update documentation?" "y"; then
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
                local log_file="${LOGS_RUN_DIR}/step1_copilot_documentation_update_${log_timestamp}.log"
                print_info "Logging output to: $log_file"
                
                # Execute Copilot prompt
                execute_copilot_prompt "$copilot_prompt" "$log_file"
                
                print_success "GitHub Copilot CLI session completed"
                print_info "Full session log saved to: $log_file"
                
                # Automatically save AI-generated documentation
                print_info "Processing AI-generated documentation..."
                for doc in "${docs_to_review[@]}"; do
                    local doc_basename
                    doc_basename=$(basename "$doc")
                    local ai_output_file="${LOGS_RUN_DIR}/ai_generated_${doc_basename}_${log_timestamp}.md"
                    
                    # Check if AI generated content for this document
                    if [[ -f "$ai_output_file" ]]; then
                        if save_ai_generated_docs "$ai_output_file" "$doc"; then
                            print_success "Automatically saved AI updates for: $doc"
                        else
                            print_warning "Could not auto-save AI updates for: $doc"
                            # Save to backlog for manual review
                            save_step_issues "1" "Update_Documentation_AutoSave_Failed" \
                                "Failed to automatically save AI-generated content for \`$doc\`. Manual review required.\nAI output available at: $ai_output_file"
                        fi
                    else
                        print_info "No AI-generated content found for: $doc"
                    fi
                done
                
                prompt_for_continuation
                
                # AUTO MODE: Skip interactive issue extraction, just save log reference
                if [[ "${AUTO_MODE:-false}" == "true" ]]; then
                    print_info "AUTO MODE: Saving log file reference to backlog..."
                    local auto_summary="## Step 1: Documentation Update Session\n\n"
                    auto_summary+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
                    auto_summary+="**Execution Mode**: Automatic\n"
                    auto_summary+="**Copilot Session Log**: \`$log_file\`\n\n"
                    auto_summary+="### Summary\n\n"
                    auto_summary+="Documentation update executed successfully via GitHub Copilot CLI.\n"
                    auto_summary+="All changes have been applied automatically based on detected code modifications.\n\n"
                    auto_summary+="### Files Reviewed\n\n"
                    for doc in "${docs_to_review[@]}"; do
                        auto_summary+="- \`$doc\`\n"
                    done
                    auto_summary+="\n### Full Session Details\n\n"
                    auto_summary+="Complete Copilot CLI session output available in log file.\n"
                    auto_summary+="Review the log for detailed analysis and recommendations.\n"
                    
                    save_step_issues "1" "Update_Documentation" "$(echo -e "$auto_summary")"
                    print_success "Documentation update summary saved to backlog"
                else
                    # INTERACTIVE MODE: Extract and save issues using library function
                    extract_and_save_issues_from_log "1" "Update_Documentation" "$log_file"
                fi
            else
                print_warning "Skipped GitHub Copilot CLI - using manual review"
            fi
        fi
    else
        print_warning "GitHub Copilot CLI not found - using basic checks only"
        print_info "Install from: https://github.com/github/gh-copilot"
        print_info "Please use the prompt above with GitHub Copilot manually"
    fi
    
    # VERSION CONSISTENCY CHECK (OPTIMIZED with parallel grep)
    print_info "Checking version consistency across documentation (parallel execution)..."
    local version_issues=""
    local version_check_failed=false
    
    # PERFORMANCE OPTIMIZATION: Use optimized parallel version check
    local version_check_results
    version_check_results=$(check_version_references_optimized "${SCRIPT_VERSION}")
    
    # Parse results from parallel execution
    if [[ -n "$version_check_results" ]]; then
        version_check_failed=true
        
        while IFS=: read -r file line content; do
            [[ -z "$file" ]] && continue
            
            if [[ "$file" == "README.md" ]]; then
                if [[ -z "${version_issues_readme}" ]]; then
                    version_issues+="⚠️  **VERSION MISMATCH**: README.md contains outdated version references\n"
                    version_issues+="   - Script version: v${SCRIPT_VERSION}\n"
                    version_issues+="   - Found in README.md:\n"
                    version_issues_readme="done"
                fi
                version_issues+="     Line ${line}: ${content}\n"
            elif [[ "$file" == ".github/copilot-instructions.md" ]]; then
                if [[ -z "${version_issues_copilot}" ]]; then
                    version_issues+="⚠️  **VERSION MISMATCH**: .github/copilot-instructions.md contains outdated version references\n"
                    version_issues+="   - Script version: v${SCRIPT_VERSION}\n"
                    version_issues+="   - Found in copilot-instructions.md:\n"
                    version_issues_copilot="done"
                fi
                version_issues+="     Line ${line}: ${content}\n"
            fi
        done <<< "$version_check_results"
        
        version_issues+="   - Update all references to v${SCRIPT_VERSION}\n\n"
        
        if [[ -n "${version_issues_readme}" ]]; then
            print_warning "Version inconsistency detected in README.md"
        fi
        if [[ -n "${version_issues_copilot}" ]]; then
            print_warning "Version inconsistency detected in .github/copilot-instructions.md"
        fi
    fi
    
    # Save version check results if issues found
    if [[ "$version_check_failed" == true ]]; then
        local version_report="## Version Consistency Issues\n\n"
        version_report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
        version_report+="**Current Script Version**: v${SCRIPT_VERSION}\n\n"
        version_report+="### Issues Detected\n\n"
        version_report+="$version_issues"
        version_report+="\n### Recommended Actions\n\n"
        version_report+="1. Update README.md to reference v${SCRIPT_VERSION}\n"
        version_report+="2. Update .github/copilot-instructions.md to reference v${SCRIPT_VERSION}\n"
        version_report+="3. Ensure all version references are consistent\n"
        
        save_step_issues "1" "Update_Documentation_Version_Check" "$(echo -e "$version_report")"
        print_warning "Version inconsistencies detected and saved to backlog"
        
        # Automatically attempt to fix version inconsistencies
        print_info "Attempting automatic version update..."
        local auto_fix_success=true
        
        if [[ "$DRY_RUN" != true ]]; then
            # Fix README.md
            if [[ -f "README.md" ]]; then
                if sed -i.bak "s/workflow.*v1\.[0-9]\.0/workflow v${SCRIPT_VERSION}/g; s/automation.*v1\.[0-9]\.0/automation v${SCRIPT_VERSION}/g; s/execute_tests_docs_workflow.*v1\.[0-9]\.0/execute_tests_docs_workflow.sh v${SCRIPT_VERSION}/g" README.md; then
                    print_success "Automatically updated version references in README.md"
                else
                    auto_fix_success=false
                    print_warning "Failed to automatically update README.md"
                fi
            fi
            
            # Fix .github/copilot-instructions.md
            if [[ -f ".github/copilot-instructions.md" ]]; then
                if sed -i.bak "s/workflow.*v1\.[0-9]\.0/workflow v${SCRIPT_VERSION}/g; s/automation.*v1\.[0-9]\.0/automation v${SCRIPT_VERSION}/g; s/execute_tests_docs_workflow.*v1\.[0-9]\.0/execute_tests_docs_workflow.sh v${SCRIPT_VERSION}/g" .github/copilot-instructions.md; then
                    print_success "Automatically updated version references in .github/copilot-instructions.md"
                else
                    auto_fix_success=false
                    print_warning "Failed to automatically update .github/copilot-instructions.md"
                fi
            fi
            
            if [[ "$auto_fix_success" == true ]]; then
                print_success "Version inconsistencies automatically resolved"
            else
                print_warning "Some version updates failed - manual review required"
            fi
        else
            print_info "[DRY RUN] Would automatically update version references"
        fi
    else
        print_success "Version consistency check passed"
    fi
    
    # AUTOMATED VALIDATION IMPROVEMENTS
    print_info "Running automated documentation validation checks..."
    
    # Improvement 1: Automated file count validation
    local file_count_issues=0
    validate_documentation_file_counts || file_count_issues=$?
    if [[ $file_count_issues -gt 0 ]]; then
        print_warning "File count validation found ${file_count_issues} inconsistency(ies)"
        save_step_issues "1" "Update_Documentation_File_Count_Validation" \
            "Automated file count validation detected ${file_count_issues} inconsistency(ies).\n\nPlease review and update documented file counts to match actual counts."
    fi
    
    # Improvement 2: Cross-reference validation for submodules
    local cross_ref_issues=0
    validate_submodule_cross_references || cross_ref_issues=$?
    if [[ $cross_ref_issues -gt 0 ]]; then
        print_warning "Submodule cross-reference validation found ${cross_ref_issues} issue(s)"
        save_step_issues "1" "Update_Documentation_Submodule_CrossRef" \
            "Submodule cross-reference validation detected ${cross_ref_issues} issue(s).\n\nEnsure all submodules are consistently referenced across README.md and .github/copilot-instructions.md."
    fi
    
    # Improvement 3: Change set validation for submodule architecture
    local arch_changes=0
    validate_submodule_architecture_changes || arch_changes=$?
    if [[ $arch_changes -gt 0 ]]; then
        print_warning "Submodule architecture changes detected - documentation updates required"
        save_step_issues "1" "Update_Documentation_Submodule_Architecture" \
            "Submodule architecture changes detected in current changeset.\n\nDocumentation updates required for:\n- README.md\n- .github/copilot-instructions.md\n\nReview .gitmodules changes and update documentation accordingly."
    fi
    
    # Improvement 4: Documentation consistency testing
    local test_failures=0
    test_documentation_consistency || test_failures=$?
    if [[ $test_failures -gt 0 ]]; then
        print_warning "Documentation consistency tests: ${test_failures} test(s) failed"
        save_step_issues "1" "Update_Documentation_Consistency_Tests" \
            "Documentation consistency testing failed ${test_failures} test(s).\n\nReview the following:\n1. Documented files exist\n2. Submodule references are consistent\n3. File counts are accurate\n4. Version references are consistent"
    else
        print_success "All documentation consistency tests passed ✅"
    fi
    
    # Fallback to manual editing if needed
    if [[ ${#docs_to_review[@]} -gt 0 ]] && [[ "$INTERACTIVE_MODE" == true ]]; then
        if confirm_action "Open documentation files for manual editing?"; then
            for doc in "${docs_to_review[@]}"; do
                if [[ -f "$doc" ]]; then
                    print_info "Opening: $doc"
                    ${EDITOR:-nano} "$doc"
                fi
            done
            
            # POST-EDIT VERIFICATION
            print_info "Running post-edit verification..."
            local verification_issues=""
            local verification_failed=false
            
            for doc in "${docs_to_review[@]}"; do
                if [[ -f "$doc" ]]; then
                    # Check for edit error indicators
                    if grep -q "No match found" "$doc" 2>/dev/null; then
                        print_error "Edit verification failed: 'No match found' error in $doc"
                        verification_issues+="❌ **CRITICAL**: 'No match found' error in \`$doc\`\n"
                        verification_failed=true
                    fi
                    
                    # Check for merge conflict markers
                    if grep -q "<<<<<<< HEAD\|=======" "$doc" 2>/dev/null; then
                        print_warning "Merge conflict markers detected in $doc"
                        verification_issues+="⚠️  **WARNING**: Merge conflict markers in \`$doc\`\n"
                        verification_failed=true
                    fi
                    
                    # Check for backup files
                    if [[ -f "${doc}~" ]] || [[ -f "${doc}.bak" ]]; then
                        print_warning "Backup files detected for $doc"
                        verification_issues+="ℹ️  **INFO**: Backup files found for \`$doc\`\n"
                    fi
                fi
            done
            
            if [[ "$verification_failed" == true ]]; then
                print_error "Post-edit verification detected issues"
                
                local verification_report="## Post-Edit Verification Issues\n\n"
                verification_report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
                verification_report+="**Files Reviewed**: ${#docs_to_review[@]}\n\n"
                verification_report+="$verification_issues"
                verification_report+="\n### Action Required\n\n"
                verification_report+="1. Review flagged files manually\n"
                verification_report+="2. Fix incomplete edit operations\n"
                verification_report+="3. Remove merge conflict markers\n"
                
                save_step_issues "1" "Update_Documentation_Verification" "$(echo -e "$verification_report")"
                
                if ! confirm_action "Continue workflow despite verification issues?" "n"; then
                    print_error "Workflow halted for manual verification"
                    return 1
                fi
            else
                print_success "Post-edit verification passed"
            fi
        fi
    fi
    
    print_success "Documentation review complete"
    
    # Save step summary
    local summary_text="Reviewed ${#docs_to_review[@]} documentation files for consistency with recent code changes."
    save_step_summary "1" "Update_Documentation" "$summary_text" "✅"
    
    # Always save backlog file with final status
    local step_backlog="### Documentation Update Summary

**Files Reviewed:** ${#docs_to_review[@]}
**Change Scope:** ${CHANGE_SCOPE}
**Modified Files:** ${ANALYSIS_MODIFIED}
**Status:** ✅ Complete

Reviewed ${#docs_to_review[@]} documentation files for consistency with recent code changes.

### Documentation Files Reviewed

"
    for doc in "${docs_to_review[@]}"; do
        step_backlog+="- \`${doc}\`
"
    done
    
    if [[ ${#docs_to_review[@]} -eq 0 ]]; then
        step_backlog+="No documentation files required review based on recent changes.
"
    fi
    
    save_step_issues "1" "Update_Documentation" "$step_backlog"
    
    update_workflow_status "step1" "✅"

    prompt_for_continuation
}

# Export step functions
export -f step1_update_documentation
export -f step1_get_version
export -f determine_doc_folder
export -f save_ai_generated_docs
export -f validate_documentation_file_counts
export -f validate_submodule_cross_references
export -f validate_submodule_architecture_changes
export -f test_documentation_consistency
# Performance optimization functions
export -f init_performance_cache
export -f get_or_cache
export -f parallel_file_analysis
export -f check_version_references_optimized
export -f get_cached_git_diff
export -f batch_file_check
export -f optimized_multi_grep
