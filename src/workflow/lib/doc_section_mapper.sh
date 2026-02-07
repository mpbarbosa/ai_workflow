#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Documentation Section Mapper
# Purpose: Map changed files to specific documentation sections
# Version: 1.0.0
# Created: 2026-02-07
################################################################################

# ==============================================================================
# SECTION MAPPING
# ==============================================================================

# Map changed file to affected documentation sections
# Args: $1 - changed file path, $2 - project kind
# Returns: List of "doc_file:section_id" (one per line)
# Usage: sections=$(map_file_to_doc_sections "src/workflow/lib/metrics.sh" "nodejs_api")
map_file_to_doc_sections() {
    local changed_file="$1"
    local project_kind="${2:-unknown}"
    local sections=()
    
    case "$changed_file" in
        # Configuration files
        .workflow-config.yaml)
            sections+=("docs/reference/configuration.md:#workflow-configuration")
            sections+=("docs/PROJECT_REFERENCE.md:#key-statistics")
            ;;
            
        .workflow_core/config/ai_helpers.yaml)
            sections+=("docs/api/CONFIG_REFERENCE.md:#ai-helpers")
            sections+=("docs/PROJECT_REFERENCE.md:#ai-integration")
            ;;
            
        .workflow_core/config/project_kinds.yaml)
            sections+=("docs/api/CONFIG_REFERENCE.md:#project-kinds")
            sections+=("docs/PROJECT_REFERENCE.md:#project-intelligence")
            ;;
            
        .workflow_core/config/paths.yaml)
            sections+=("docs/api/CONFIG_REFERENCE.md:#paths")
            ;;
            
        # Library modules - Core
        src/workflow/lib/ai_helpers.sh)
            sections+=("docs/api/core/ai_helpers.md")
            sections+=("docs/api/API_REFERENCE.md:#ai-helpers")
            sections+=("docs/PROJECT_REFERENCE.md:#core-modules")
            ;;
            
        src/workflow/lib/metrics.sh)
            sections+=("docs/api/core/metrics.md")
            sections+=("docs/api/API_REFERENCE.md:#metrics")
            sections+=("docs/PROJECT_REFERENCE.md:#core-modules")
            ;;
            
        src/workflow/lib/workflow_optimization.sh)
            sections+=("docs/api/core/workflow_optimization.md")
            sections+=("docs/PROJECT_REFERENCE.md:#performance-optimization")
            ;;
            
        src/workflow/lib/change_detection.sh)
            sections+=("docs/api/core/change_detection.md")
            sections+=("docs/PROJECT_REFERENCE.md:#core-modules")
            ;;
            
        # Library modules - Supporting
        src/workflow/lib/*.sh)
            local module=$(basename "$changed_file" .sh)
            sections+=("docs/api/supporting/${module}.md")
            sections+=("docs/api/API_REFERENCE.md:#supporting-modules")
            sections+=("docs/PROJECT_REFERENCE.md:#supporting-modules")
            ;;
            
        # Step modules
        src/workflow/steps/step_*.sh)
            local step_num=$(basename "$changed_file" | grep -oE 'step_[0-9]+[a-z]?' | sed 's/step_//')
            sections+=("docs/reference/API_STEP_MODULES.md:#step-${step_num}")
            sections+=("docs/PROJECT_REFERENCE.md:#workflow-pipeline")
            ;;
            
        # Orchestrators
        src/workflow/orchestrators/*.sh)
            sections+=("docs/reference/API_ORCHESTRATORS.md")
            sections+=("docs/PROJECT_REFERENCE.md:#orchestrators")
            ;;
            
        # Examples
        examples/*)
            sections+=("docs/user-guide/examples.md")
            sections+=("docs/INTEGRATION.md")
            ;;
            
        # Tests
        tests/unit/*.sh)
            sections+=("docs/developer-guide/testing.md:#unit-tests")
            sections+=("docs/PROJECT_REFERENCE.md:#test-coverage")
            ;;
            
        tests/integration/*.sh)
            sections+=("docs/developer-guide/testing.md:#integration-tests")
            sections+=("docs/PROJECT_REFERENCE.md:#test-coverage")
            ;;
            
        # Templates
        templates/*)
            sections+=("docs/user-guide/templates.md")
            sections+=("docs/PROJECT_REFERENCE.md:#developer-experience")
            ;;
            
        # Scripts
        scripts/*.sh|scripts/*.py)
            sections+=("docs/developer-guide/scripts.md")
            ;;
    esac
    
    # Project-specific mappings
    case "$project_kind" in
        nodejs_api|nodejs_cli|nodejs_library)
            [[ "$changed_file" == "package.json" ]] && \
                sections+=("docs/reference/dependencies.md:#npm-packages")
            ;;
            
        python_api|python_cli|python_library)
            [[ "$changed_file" == "requirements.txt" ]] && \
                sections+=("docs/reference/dependencies.md:#python-packages")
            [[ "$changed_file" == "setup.py" ]] && \
                sections+=("docs/reference/dependencies.md:#setup-configuration")
            ;;
            
        shell_script_automation)
            [[ "$changed_file" =~ \.sh$ ]] && \
                sections+=("docs/reference/scripts.md")
            ;;
    esac
    
    # Output all sections
    printf '%s\n' "${sections[@]}"
}

# Map multiple files to documentation sections
# Args: $1 - newline-separated list of files, $2 - project kind
# Returns: Deduplicated list of "doc_file:section_id"
map_files_to_sections() {
    local files="$1"
    local project_kind="${2:-unknown}"
    local all_sections=()
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        local file_sections
        file_sections=$(map_file_to_doc_sections "$file" "$project_kind")
        
        while IFS= read -r section; do
            [[ -z "$section" ]] && continue
            all_sections+=("$section")
        done <<< "$file_sections"
    done <<< "$files"
    
    # Deduplicate and sort
    printf '%s\n' "${all_sections[@]}" | sort -u
}

# ==============================================================================
# SECTION QUERIES
# ==============================================================================

# Get all documentation sections in a file
# Args: $1 - documentation file path
# Returns: List of section IDs (without #)
get_doc_sections() {
    local doc_file="$1"
    
    [[ ! -f "$doc_file" ]] && return 1
    
    # Extract all heading IDs (## Section Name -> section-name)
    grep -E '^##+ ' "$doc_file" | \
        sed 's/^##*[[:space:]]*//' | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9-]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//; s/-$//'
}

# Count total documentation sections across all docs
# Returns: Total number of sections
count_total_doc_sections() {
    local total=0
    
    while IFS= read -r doc_file; do
        [[ ! -f "$doc_file" ]] && continue
        local count
        count=$(get_doc_sections "$doc_file" 2>/dev/null | wc -l)
        total=$((total + count))
    done < <(find docs -name "*.md" 2>/dev/null)
    
    echo "$total"
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Check if incremental documentation should be used
# Args: $1 - project kind
# Returns: 0 if should use incremental, 1 otherwise
should_use_incremental_docs() {
    local project_kind="${1:-unknown}"
    
    # Skip for unknown projects
    [[ "$project_kind" == "unknown" ]] && return 1
    
    # Skip if not in git repo
    git rev-parse --git-dir &>/dev/null || return 1
    
    # Require at least 2 commits
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    [[ $commit_count -ge 2 ]] || return 1
    
    return 0
}

# Calculate percentage savings
# Args: $1 - total sections, $2 - affected sections
# Returns: Percentage saved
calculate_section_savings() {
    local total="$1"
    local affected="$2"
    
    [[ $total -eq 0 ]] && echo "0" && return
    
    local savings=$((100 - (affected * 100 / total)))
    echo "$savings"
}

# Export functions for testing
export -f map_file_to_doc_sections
export -f map_files_to_sections
export -f get_doc_sections
export -f count_total_doc_sections
export -f should_use_incremental_docs
export -f calculate_section_savings

################################################################################
# Documentation Section Mapper - Complete
################################################################################
