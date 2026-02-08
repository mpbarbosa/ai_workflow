#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 4: Configuration Validation
# Purpose: Validate configuration files for syntax, security, and best practices
# Part of: Tests & Documentation Workflow Automation v3.2.7
# Version: 1.0.0 (Configuration Files as 4th Category Feature)
################################################################################

# Module version information
readonly STEP4_VERSION="1.0.0"
readonly STEP4_VERSION_MAJOR=1
readonly STEP4_VERSION_MINOR=0
readonly STEP4_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP4_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==============================================================================
# CONFIGURATION FILE DISCOVERY
# ==============================================================================

# Discover configuration files in the project
# Usage: discover_config_files
# Returns: List of configuration files (one per line)
discover_config_files() {
    local modified_files=$(git diff --name-only HEAD 2>/dev/null || echo "")
    local staged_files=$(git diff --cached --name-only 2>/dev/null || echo "")
    local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
    
    # Combine all changed files
    local all_changes=$(echo -e "${modified_files}\n${staged_files}\n${untracked_files}" | sort -u | grep -v '^$')
    
    # Filter for configuration files using FILE_PATTERNS from change_detection.sh
    local config_files=""
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Check if file matches config patterns
        if [[ "$file" =~ \.(json|yaml|yml|toml|ini)$ ]] || \
           [[ "$file" =~ ^\.editorconfig$ ]] || \
           [[ "$file" =~ ^\.gitignore$ ]] || \
           [[ "$file" =~ ^\.nvmrc$ ]] || \
           [[ "$file" =~ ^\.node-version$ ]] || \
           [[ "$file" =~ ^\.mdlrc$ ]] || \
           [[ "$file" =~ ^\.env\.example$ ]] || \
           [[ "$file" =~ ^Dockerfile$ ]] || \
           [[ "$file" =~ ^docker-compose.*\.yml$ ]] || \
           [[ "$file" =~ ^\.dockerignore$ ]] || \
           [[ "$file" =~ ^Makefile$ ]] || \
           [[ "$file" =~ ^Jenkinsfile$ ]] || \
           [[ "$file" =~ \.github/workflows/.*\.ya?ml$ ]] || \
           [[ "$file" =~ \.circleci/config\.yml$ ]] || \
           [[ "$file" =~ ^\.gitlab-ci\.yml$ ]]; then
            config_files="${config_files}${file}"$'\n'
        fi
    done <<< "$all_changes"
    
    echo -n "$config_files"
}

# Count configuration files
# Usage: count_config_files
# Returns: Number of config files
count_config_files() {
    local config_files="$1"
    [[ -z "$config_files" ]] && echo "0" && return 0
    echo "$config_files" | grep -c . || echo "0"
}

# ==============================================================================
# SYNTAX VALIDATION
# ==============================================================================

# Validate JSON syntax
# Usage: validate_json <file>
# Returns: 0 if valid, 1 if invalid
validate_json() {
    local file="$1"
    
    if ! jq empty "$file" 2>/dev/null; then
        echo "ERROR: Invalid JSON syntax in $file" >&2
        return 1
    fi
    
    return 0
}

# Validate YAML syntax
# Usage: validate_yaml <file>
# Returns: 0 if valid, 1 if invalid
validate_yaml() {
    local file="$1"
    
    # Try using yq if available, otherwise use python
    if command -v yq &>/dev/null; then
        if ! yq eval '.' "$file" >/dev/null 2>&1; then
            echo "ERROR: Invalid YAML syntax in $file" >&2
            return 1
        fi
    elif command -v python3 &>/dev/null; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            echo "ERROR: Invalid YAML syntax in $file" >&2
            return 1
        fi
    else
        echo "WARNING: Cannot validate YAML - yq/python3 not available" >&2
        return 0
    fi
    
    return 0
}

# Validate TOML syntax  
# Usage: validate_toml <file>
# Returns: 0 if valid, 1 if invalid
validate_toml() {
    local file="$1"
    
    if command -v python3 &>/dev/null; then
        if ! python3 -c "import tomli if hasattr(__builtins__, 'tomli') else __import__('tomllib'); tomli.load(open('$file', 'rb')) if hasattr(__builtins__, 'tomli') else __import__('tomllib').load(open('$file', 'rb'))" 2>/dev/null; then
            # Try toml module if tomli/tomllib not available
            if ! python3 -c "import toml; toml.load('$file')" 2>/dev/null; then
                echo "ERROR: Invalid TOML syntax in $file" >&2
                return 1
            fi
        fi
    else
        echo "WARNING: Cannot validate TOML - python3 not available" >&2
        return 0
    fi
    
    return 0
}

# Validate configuration file syntax
# Usage: validate_config_syntax <file>
# Returns: 0 if valid, 1 if invalid
validate_config_syntax() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 0
    
    local extension="${file##*.}"
    
    case "$extension" in
        json)
            validate_json "$file"
            ;;
        yaml|yml)
            validate_yaml "$file"
            ;;
        toml)
            validate_toml "$file"
            ;;
        ini|editorconfig|gitignore|nvmrc|node-version|mdlrc|env)
            # Simple format - just check if readable
            [[ -r "$file" ]] && return 0 || return 1
            ;;
        *)
            # Unknown format - assume valid
            return 0
            ;;
    esac
}

# ==============================================================================
# SECURITY SCANNING
# ==============================================================================

# Check for exposed secrets in configuration files
# Usage: check_for_secrets <file>
# Returns: List of potential secrets found
check_for_secrets() {
    local file="$1"
    local findings=""
    
    # Common secret patterns
    local -a patterns=(
        'api[_-]?key.*[=:][[:space:]]*["\047]?[A-Za-z0-9_-]{20,}["\047]?'
        'secret.*[=:][[:space:]]*["\047]?[A-Za-z0-9_-]{20,}["\047]?'
        'password.*[=:][[:space:]]*["\047]?[^"\047\s]{8,}["\047]?'
        'token.*[=:][[:space:]]*["\047]?[A-Za-z0-9_-]{20,}["\047]?'
        'private[_-]?key.*[=:][[:space:]]*["\047]?[A-Za-z0-9_-]{20,}["\047]?'
        'aws[_-]?access[_-]?key'
        'sk_live_[A-Za-z0-9]+'  # Stripe secret key
        'ghp_[A-Za-z0-9]+'       # GitHub personal access token
    )
    
    for pattern in "${patterns[@]}"; do
        if grep -qiE "$pattern" "$file" 2>/dev/null; then
            local matches=$(grep -inE "$pattern" "$file" | head -3)
            findings="${findings}SECURITY: Potential secret detected in $file"$'\n'"$matches"$'\n\n'
        fi
    done
    
    echo -n "$findings"
}

# ==============================================================================
# AI-POWERED VALIDATION
# ==============================================================================

# Build AI prompt for configuration validation
# Usage: build_config_validation_prompt <config_files> <project_kind>
# Returns: Formatted prompt
build_config_validation_prompt() {
    local config_files="$1"
    local project_kind="${2:-generic}"
    local tech_stack="${3:-unknown}"
    
    local config_count=$(count_config_files "$config_files")
    local config_list=$(echo "$config_files" | head -20)  # Limit for readability
    
    # Read configuration_specialist_prompt from YAML
    local yaml_file="${STEP4_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        print_error "AI helpers configuration not found: $yaml_file"
        return 1
    fi
    
    # Extract role (using role_prefix + behavioral_guidelines pattern)
    local role=$(awk '
        /^configuration_specialist_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ && !/^[[:space:]]/ { exit }
        in_section && /^[[:space:]]{2}role_prefix:[[:space:]]*\|/ { in_role=1; next }
        in_section && in_role {
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_role=0; next }
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file" | sed '/^$/d')
    
    # Extract task template
    local task=$(awk '
        /^configuration_specialist_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ && !/^[[:space:]]/ { exit }
        in_section && /^[[:space:]]{2}task_template:[[:space:]]*\|/ { in_task=1; next }
        in_section && in_task {
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_task=0; next }
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file")
    
    # Extract approach
    local approach=$(awk '
        /^configuration_specialist_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ && !/^[[:space:]]/ { exit }
        in_section && /^[[:space:]]{2}approach:[[:space:]]*\|/ { in_approach=1; next }
        in_section && in_approach {
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_approach=0; next }
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file")
    
    # Substitute template variables
    task=$(echo "$task" | sed -e "s/{config_files_list}/$config_list/g" \
                               -e "s/{project_kind}/$project_kind/g" \
                               -e "s/{tech_stack}/$tech_stack/g" \
                               -e "s/{config_count}/$config_count/g")
    
    # Build full prompt
    cat <<EOF
$role

$task

$approach
EOF
}

# Run AI-powered configuration validation
# Usage: run_ai_config_validation <config_files> <output_file>
# Returns: 0 on success, 1 on failure
run_ai_config_validation() {
    local config_files="$1"
    local output_file="$2"
    local project_kind="${3:-generic}"
    local tech_stack="${4:-unknown}"
    
    if [[ -z "$config_files" ]]; then
        echo "No configuration files to validate" > "$output_file"
        return 0
    fi
    
    # Build prompt
    local prompt=$(build_config_validation_prompt "$config_files" "$project_kind" "$tech_stack")
    
    # Prepare context with file contents
    local context=""
    while IFS= read -r file; do
        [[ -z "$file" || ! -f "$file" ]] && continue
        
        context="${context}## File: $file"$'\n\n'
        context="${context}\`\`\`"$'\n'
        context="${context}$(cat "$file" | head -100)"  # Limit to 100 lines per file
        context="${context}"$'\n\`\`\`\n\n'
    done <<< "$config_files"
    
    # Call AI
    local full_prompt="${prompt}"$'\n\n'"## Configuration Files"$'\n\n'"${context}"
    
    echo "$full_prompt" | gh copilot ask --stdin > "$output_file" 2>&1 || {
        print_error "AI validation failed"
        return 1
    }
    
    return 0
}

# ==============================================================================
# MAIN ORCHESTRATOR
# ==============================================================================

step4_validate_configuration() {
    print_step "4" "Validate Configuration Files"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Phase 1: Discover configuration files
    print_info "Discovering configuration files..."
    local config_files=$(discover_config_files)
    local config_count=$(count_config_files "$config_files")
    
    if [[ $config_count -eq 0 ]]; then
        print_info "No configuration files changed - skipping validation"
        return 0
    fi
    
    print_info "Found $config_count configuration file(s) to validate"
    
    # Phase 2: Syntax validation
    print_info "Validating syntax..."
    local syntax_errors=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        print_info "  Checking $file..."
        if ! validate_config_syntax "$file"; then
            ((syntax_errors++))
        fi
    done <<< "$config_files"
    
    if [[ $syntax_errors -gt 0 ]]; then
        print_warning "Found $syntax_errors syntax error(s) in configuration files"
    else
        print_success "All configuration files have valid syntax"
    fi
    
    # Phase 3: Security scanning
    print_info "Scanning for security issues..."
    local security_findings=""
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        local findings=$(check_for_secrets "$file")
        if [[ -n "$findings" ]]; then
            security_findings="${security_findings}${findings}"
        fi
    done <<< "$config_files"
    
    if [[ -n "$security_findings" ]]; then
        print_warning "Security scan found potential issues:"
        echo "$security_findings"
    else
        print_success "No security issues detected"
    fi
    
    # Phase 4: AI-powered validation
    print_info "Running AI-powered validation..."
    
    local validation_output="${BACKLOG_RUN_DIR}/step_04_config_validation.md"
    mkdir -p "${BACKLOG_RUN_DIR}"
    
    # Get project context
    local project_kind="${PROJECT_KIND:-generic}"
    local tech_stack="${PRIMARY_LANGUAGE:-unknown}"
    
    if run_ai_config_validation "$config_files" "$validation_output" "$project_kind" "$tech_stack"; then
        print_success "AI validation complete"
        print_info "Report saved to: $validation_output"
    else
        print_warning "AI validation failed - continuing with manual checks"
    fi
    
    # Phase 5: Generate summary
    local summary_file="${BACKLOG_RUN_DIR}/step_04_summary.md"
    cat > "$summary_file" <<EOF
# Step 4: Configuration Validation Summary

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Files Validated:** $config_count

## Files Checked

$(echo "$config_files" | sed 's/^/- /')

## Validation Results

- **Syntax Errors:** $syntax_errors
- **Security Findings:** $(echo "$security_findings" | grep -c "SECURITY:" || echo "0")

## Next Steps

$(if [[ $syntax_errors -gt 0 ]]; then
    echo "- ⚠️ Fix syntax errors before committing"
fi)
$(if [[ -n "$security_findings" ]]; then
    echo "- ⚠️ Review security findings and remove any exposed secrets"
fi)
$(if [[ $syntax_errors -eq 0 && -z "$security_findings" ]]; then
    echo "- ✅ All validation checks passed"
fi)

See \`step_04_config_validation.md\` for detailed AI analysis.
EOF
    
    print_info "Summary saved to: $summary_file"
    
    # Return error if critical issues found
    if [[ $syntax_errors -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# Export functions
export -f discover_config_files count_config_files
export -f validate_json validate_yaml validate_toml validate_config_syntax
export -f check_for_secrets
export -f build_config_validation_prompt run_ai_config_validation
export -f step4_validate_configuration
