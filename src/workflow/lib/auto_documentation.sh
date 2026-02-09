#!/bin/bash
set -euo pipefail

################################################################################
# Auto-Documentation Module
# Version: 3.0.1
# Purpose: Automatically generate documentation from workflow execution
#
# Features:
#   - Extract workflow summaries to structured reports
#   - Auto-generate CHANGELOG.md from commits
#   - Create workflow execution reports
#   - Generate API documentation
#   - Maintain documentation history
#
# Output Directories:
#   - docs/workflow-reports/     Workflow execution summaries
#   - docs/changelog/             Versioned changelog entries
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
DOCS_DIR="${PROJECT_ROOT:-$(pwd)}/docs"
WORKFLOW_REPORTS_DIR="${DOCS_DIR}/workflow-reports"
CHANGELOG_DIR="${DOCS_DIR}/changelog"
CHANGELOG_FILE="${PROJECT_ROOT:-$(pwd)}/CHANGELOG.md"

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a AUTO_DOC_TEMP_FILES=()

# Register temp file for cleanup
track_auto_doc_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && AUTO_DOC_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for auto documentation
cleanup_auto_documentation_files() {
    local file
    for file in "${AUTO_DOC_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    AUTO_DOC_TEMP_FILES=()
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize auto-documentation system
init_auto_documentation() {
    # Create directory structure
    mkdir -p "$WORKFLOW_REPORTS_DIR"
    mkdir -p "$CHANGELOG_DIR"
    
    print_info "Auto-documentation system initialized"
    return 0
}

# ==============================================================================
# WORKFLOW REPORT GENERATION
# ==============================================================================

# Generate workflow execution report
# Args: $1 = workflow_run_id, $2 = status (success/failure)
generate_workflow_report() {
    local run_id="$1"
    local status="${2:-unknown}"
    
    local report_file="${WORKFLOW_REPORTS_DIR}/${run_id}_report.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Extract data from workflow artifacts
    local backlog_dir="${BACKLOG_RUN_DIR:-}"
    local summaries_dir="${SUMMARIES_RUN_DIR:-}"
    local metrics_file="${METRICS_DIR}/current_run.json"
    
    # Generate report
    cat > "$report_file" << EOF
# Workflow Execution Report

**Run ID**: ${run_id}
**Timestamp**: ${timestamp}
**Status**: ${status}
**Project**: ${PROJECT_ROOT}

---

## Executive Summary

EOF

    # Add metrics summary if available
    if [[ -f "$metrics_file" ]]; then
        local duration=$(jq -r '.workflow.duration_seconds // 0' "$metrics_file" 2>/dev/null || echo "0")
        local steps_completed=$(jq -r '.workflow.steps_completed // 0' "$metrics_file" 2>/dev/null || echo "0")
        local steps_failed=$(jq -r '.workflow.steps_failed // 0' "$metrics_file" 2>/dev/null || echo "0")
        local steps_skipped=$(jq -r '.workflow.steps_skipped // 0' "$metrics_file" 2>/dev/null || echo "0")
        
        local duration_min=$((duration / 60))
        
        cat >> "$report_file" << EOF
- **Duration**: ${duration_min}m (${duration}s)
- **Steps Completed**: ${steps_completed}
- **Steps Failed**: ${steps_failed}
- **Steps Skipped**: ${steps_skipped}
- **Success Rate**: $(echo "scale=1; $steps_completed * 100 / ($steps_completed + $steps_failed)" | bc 2>/dev/null || echo "N/A")%

EOF
    fi
    
    # Add change summary
    cat >> "$report_file" << EOF
## Changes Analyzed

EOF
    
    if [[ -d "$backlog_dir" ]]; then
        local change_file="${backlog_dir}/CHANGE_IMPACT_ANALYSIS.md"
        if [[ -f "$change_file" ]]; then
            sed -n '/^## /,/^---/p' "$change_file" >> "$report_file"
        fi
    fi
    
    # Add step summaries
    cat >> "$report_file" << EOF

---

## Step Execution Summary

EOF
    
    if [[ -d "$summaries_dir" ]]; then
        for summary_file in "$summaries_dir"/step*_summary.md; do
            [[ -f "$summary_file" ]] || continue
            
            local step_name=$(basename "$summary_file" .md | sed 's/step[0-9]*_//' | sed 's/_summary//' | tr '_' ' ')
            local step_status=$(grep "^\*\*Status:\*\*" "$summary_file" | sed 's/.*Status:\*\* //')
            
            echo "- **${step_name}**: ${step_status}" >> "$report_file"
        done
    fi
    
    # Add issues found
    if [[ -d "$backlog_dir" ]]; then
        cat >> "$report_file" << EOF

---

## Issues Identified

EOF
        
        local issue_count=0
        for issue_file in "$backlog_dir"/step*.md; do
            [[ -f "$issue_file" ]] || continue
            ((issue_count++))
            
            local step_name=$(basename "$issue_file" .md | sed 's/step[0-9]*_//' | tr '_' ' ')
            echo "### ${step_name}" >> "$report_file"
            echo "" >> "$report_file"
            
            # Extract first few lines of issues
            sed -n '/^## Issues/,/^---/p' "$issue_file" | head -20 >> "$report_file"
            echo "" >> "$report_file"
        done
        
        if [[ $issue_count -eq 0 ]]; then
            echo "✅ No issues identified during this workflow execution." >> "$report_file"
        fi
    fi
    
    # Add performance metrics
    if [[ -f "$metrics_file" ]]; then
        cat >> "$report_file" << EOF

---

## Performance Metrics

EOF
        
        # Extract key metrics
        jq -r '.steps | to_entries[] | "- **Step \(.key)**: \(.value.duration_seconds)s (\(.value.status))"' "$metrics_file" 2>/dev/null >> "$report_file" || true
    fi
    
    # Add footer
    cat >> "$report_file" << EOF

---

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')  
**Workflow Version**: ${SCRIPT_VERSION:-unknown}  
**Auto-Generated by**: AI Workflow Automation
EOF
    
    print_success "Workflow report generated: $report_file"
    echo "$report_file"
}

# ==============================================================================
# CHANGELOG AUTO-GENERATION
# ==============================================================================

# Generate CHANGELOG.md from git commits
# Args: $1 = since_tag (optional, default: last tag)
generate_changelog() {
    local since_tag="${1:-}"
    
    # If no tag specified, get the last tag
    if [[ -z "$since_tag" ]]; then
        since_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    fi
    
    # Determine version for this changelog
    local current_version="${SCRIPT_VERSION:-unreleased}"
    local changelog_date=$(date '+%Y-%m-%d')
    
    # Create temporary file for new entries
    local temp_file=$(mktemp)
    track_auto_doc_temp "$temp_file"
    
    cat > "$temp_file" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [${current_version}] - ${changelog_date}

EOF
    
    # Parse commits and categorize
    local commits=""
    if [[ -n "$since_tag" ]]; then
        commits=$(git log "${since_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")
    else
        commits=$(git log -20 --pretty=format:"%s" 2>/dev/null || echo "")
    fi
    
    # Categorize commits
    local added=()
    local changed=()
    local fixed=()
    local removed=()
    local deprecated=()
    local security=()
    
    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue
        
        case "$commit" in
            *"feat:"*|*"feature:"*|*"add:"*)
                added+=("$commit")
                ;;
            *"fix:"*|*"bug:"*|*"bugfix:"*)
                fixed+=("$commit")
                ;;
            *"change:"*|*"update:"*|*"refactor:"*)
                changed+=("$commit")
                ;;
            *"remove:"*|*"delete:"*)
                removed+=("$commit")
                ;;
            *"deprecate:"*)
                deprecated+=("$commit")
                ;;
            *"security:"*|*"vuln:"*)
                security+=("$commit")
                ;;
            *)
                changed+=("$commit")
                ;;
        esac
    done <<< "$commits"
    
    # Write sections
    if [[ ${#added[@]} -gt 0 ]]; then
        echo "### Added" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${added[@]}"; do
            # Clean up commit message
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [[ ${#changed[@]} -gt 0 ]]; then
        echo "### Changed" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${changed[@]}"; do
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [[ ${#fixed[@]} -gt 0 ]]; then
        echo "### Fixed" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${fixed[@]}"; do
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [[ ${#deprecated[@]} -gt 0 ]]; then
        echo "### Deprecated" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${deprecated[@]}"; do
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [[ ${#removed[@]} -gt 0 ]]; then
        echo "### Removed" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${removed[@]}"; do
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    if [[ ${#security[@]} -gt 0 ]]; then
        echo "### Security" >> "$temp_file"
        echo "" >> "$temp_file"
        for item in "${security[@]}"; do
            local clean_msg=$(echo "$item" | sed 's/^[a-z]*: *//' | sed 's/^- *//')
            echo "- ${clean_msg}" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi
    
    # If CHANGELOG.md exists, append to it
    if [[ -f "$CHANGELOG_FILE" ]]; then
        # Check if this version already exists
        if grep -q "## \[${current_version}\]" "$CHANGELOG_FILE"; then
            print_warning "Version ${current_version} already exists in CHANGELOG.md"
            rm "$temp_file"
            return 1
        fi
        
        # Insert new version after the header
        local header_lines=$(grep -n "^# Changelog" "$CHANGELOG_FILE" | head -1 | cut -d: -f1)
        if [[ -n "$header_lines" ]]; then
            # Skip to after the header and format description
            local insert_line=$((header_lines + 4))
            
            # Create backup
            cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.bak"
            
            # Insert new version
            head -n "$insert_line" "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.new"
            tail -n +4 "$temp_file" >> "${CHANGELOG_FILE}.new"
            tail -n +$((insert_line + 1)) "$CHANGELOG_FILE" >> "${CHANGELOG_FILE}.new"
            
            mv "${CHANGELOG_FILE}.new" "$CHANGELOG_FILE"
        else
            # No header found, create new file
            cat "$temp_file" > "$CHANGELOG_FILE"
        fi
    else
        # Create new CHANGELOG.md
        cat "$temp_file" > "$CHANGELOG_FILE"
    fi
    
    rm "$temp_file"
    
    print_success "CHANGELOG.md updated with version ${current_version}"
    echo "$CHANGELOG_FILE"
}

# ==============================================================================
# API DOCUMENTATION GENERATION
# ==============================================================================

# Generate API documentation from function comments
# Args: $1 = source_file or directory
generate_api_docs() {
    local source="$1"
    local api_docs_dir="${DOCS_DIR}/api"
    
    mkdir -p "$api_docs_dir"
    
    if [[ -f "$source" ]]; then
        # Single file
        generate_file_api_docs "$source" "$api_docs_dir"
    elif [[ -d "$source" ]]; then
        # Directory - process all .sh files
        find "$source" -name "*.sh" -type f | while read -r file; do
            generate_file_api_docs "$file" "$api_docs_dir"
        done
    else
        print_error "Source not found: $source"
        return 1
    fi
    
    print_success "API documentation generated in: $api_docs_dir"
}

# Generate API docs for a single file
# Args: $1 = source_file, $2 = output_dir
generate_file_api_docs() {
    local source_file="$1"
    local output_dir="$2"
    
    local basename=$(basename "$source_file" .sh)
    local output_file="${output_dir}/${basename}.md"
    
    # Extract module header and function documentation
    cat > "$output_file" << EOF
# ${basename} - API Documentation

**Source**: \`${source_file}\`  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')

---

## Module Description

EOF
    
    # Extract module header comment
    sed -n '/^################################################################################/,/^################################################################################/p' "$source_file" | \
        grep -v "^#####" | sed 's/^# //' >> "$output_file"
    
    echo "" >> "$output_file"
    echo "---" >> "$output_file"
    echo "" >> "$output_file"
    echo "## Functions" >> "$output_file"
    echo "" >> "$output_file"
    
    # Extract function documentation
    awk '
        /^# [A-Za-z_]/ {
            if (in_comment) {
                comment = comment $0 "\n"
            } else {
                in_comment = 1
                comment = $0 "\n"
            }
            next
        }
        /^[A-Za-z_][A-Za-z0-9_]*\(\)/ {
            if (in_comment) {
                print "### " $1
                print ""
                print comment
                print ""
                print "```bash"
                print $0
                # Print function body (first few lines)
                body_lines = 0
                while (getline && body_lines < 10) {
                    print
                    body_lines++
                    if (/^}/) break
                }
                print "```"
                print ""
                print "---"
                print ""
                in_comment = 0
                comment = ""
            }
        }
        // {
            if (!match($0, /^#/) && !match($0, /^[A-Za-z_]/)) {
                in_comment = 0
            }
        }
    ' "$source_file" >> "$output_file"
    
    print_info "Generated API docs: $output_file"
}

# ==============================================================================
# DOCUMENTATION QUALITY CHECKS
# ==============================================================================

# Validate documentation completeness
validate_documentation() {
    local issues=0
    
    print_header "Documentation Validation"
    
    # Check required files exist
    local required_files=(
        "README.md"
        "CHANGELOG.md"
        "docs/PROJECT_REFERENCE.md"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
            print_success "✅ ${file} exists"
        else
            print_error "❌ ${file} missing"
            ((issues++))
        fi
    done
    
    # Check for outdated timestamps
    local one_month_ago=$(date -d "1 month ago" +%s 2>/dev/null || date -v-1m +%s)
    
    for file in "${PROJECT_ROOT}/docs"/*.md; do
        [[ -f "$file" ]] || continue
        
        local file_time=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file")
        if [[ $file_time -lt $one_month_ago ]]; then
            print_warning "⚠️  $(basename "$file") not updated in 30+ days"
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        print_success "Documentation validation passed"
        return 0
    else
        print_error "Documentation validation found $issues issues"
        return 1
    fi
}

# ==============================================================================
# INTEGRATION HOOKS
# ==============================================================================

# Hook: Generate documentation after workflow completion
on_workflow_complete_docs() {
    local status="$1"
    local run_id="${WORKFLOW_RUN_ID:-$(date +%Y%m%d_%H%M%S)}"
    
    print_header "Auto-Generating Documentation"
    
    # Generate workflow report
    if generate_workflow_report "$run_id" "$status"; then
        print_success "Workflow report generated"
    fi
    
    # Optionally update changelog
    if [[ "${AUTO_UPDATE_CHANGELOG:-false}" == "true" ]]; then
        if generate_changelog; then
            print_success "CHANGELOG.md updated"
        fi
    fi
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f init_auto_documentation
export -f generate_workflow_report
export -f generate_changelog
export -f generate_api_docs
export -f generate_file_api_docs
export -f validate_documentation
export -f on_workflow_complete_docs
export -f track_auto_doc_temp
export -f cleanup_auto_documentation_files

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_auto_documentation_files EXIT INT TERM

################################################################################
# End of Auto-Documentation Module
################################################################################
