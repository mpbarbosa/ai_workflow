#!/usr/bin/env bash
set -euo pipefail

# Project Kind Detection Module
# Version: 1.0.0
# Purpose: Detect project kind/type based on file structure and markers
#
# This module provides functions to automatically detect the kind of project
# being analyzed (e.g., shell automation, Node.js API, website, etc.)
#
# Dependencies:
#   - file_operations.sh
#   - utils.sh
#   - tech_stack_detection.sh
#
# API:
#   detect_project_kind()           - Main detection function
#   get_project_kind_config()       - Get configuration for detected kind
#   validate_project_kind()         - Validate project matches expected kind
#   list_supported_project_kinds()  - List all supported project kinds

set -euo pipefail

# Module metadata
readonly PROJECT_KIND_MODULE_VERSION="1.0.0"
readonly PROJECT_KIND_MODULE_NAME="project_kind_detection"

# Source dependencies (avoid circular dependencies by checking if already loaded)
# Use local variable to avoid overwriting global SCRIPT_DIR
_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! declare -f log_message >/dev/null 2>&1; then
    source "${_MODULE_DIR}/utils.sh" 2>/dev/null || true
fi

if ! declare -f safe_read_file >/dev/null 2>&1; then
    source "${_MODULE_DIR}/file_operations.sh" 2>/dev/null || true
fi

# Note: tech_stack_detection is optional - only use if available
# Avoid sourcing to prevent circular dependencies during module loading

# Project kind definitions with detection patterns
declare -gA PROJECT_KIND_PATTERNS=(
    ["shell_automation"]="src/workflow lib/*.sh bin/*.sh scripts/*.sh"
    ["nodejs_api"]="src/routes src/controllers src/models package.json server.js app.js index.js"
    ["nodejs_cli"]="bin/ package.json cli.js index.js"
    ["nodejs_library"]="src/ lib/ package.json index.js"
    ["static_website"]="index.html css/ js/ assets/ images/"
    ["react_spa"]="src/App.jsx src/App.tsx package.json public/index.html"
    ["vue_spa"]="src/App.vue package.json public/index.html"
    ["python_api"]="app.py main.py requirements.txt src/ api/"
    ["python_cli"]="setup.py pyproject.toml src/ bin/"
    ["python_library"]="setup.py pyproject.toml src/ __init__.py"
    ["documentation"]="docs/ README.md *.md mkdocs.yml"
)

# Project kind characteristics
declare -gA PROJECT_KIND_CHARACTERISTICS=(
    ["shell_automation"]="executable_focus,script_heavy,no_build,test_framework_optional"
    ["nodejs_api"]="server_runtime,requires_build,test_framework_required,dependency_heavy"
    ["nodejs_cli"]="executable_focus,requires_build,test_framework_required,binary_output"
    ["nodejs_library"]="library_focus,requires_build,test_framework_required,npm_publish"
    ["static_website"]="no_runtime,no_build,browser_target,asset_heavy"
    ["react_spa"]="client_runtime,requires_build,test_framework_required,browser_target"
    ["vue_spa"]="client_runtime,requires_build,test_framework_required,browser_target"
    ["python_api"]="server_runtime,optional_build,test_framework_required,dependency_heavy"
    ["python_cli"]="executable_focus,optional_build,test_framework_required,binary_output"
    ["python_library"]="library_focus,optional_build,test_framework_required,pypi_publish"
    ["documentation"]="no_runtime,optional_build,static_generation,content_focus"
)

# Project kind workflow configurations
declare -gA PROJECT_KIND_WORKFLOW_CONFIG=(
    ["shell_automation"]="skip_build:true,skip_install:true,focus_steps:0,1,2,3,4,5,7,9"
    ["nodejs_api"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["nodejs_cli"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["nodejs_library"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["static_website"]="skip_build:true,skip_install:true,focus_steps:0,1,2,4,9"
    ["react_spa"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["vue_spa"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["python_api"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["python_cli"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["python_library"]="skip_build:false,skip_install:false,focus_steps:0,1,2,5,6,7,8,9"
    ["documentation"]="skip_build:true,skip_install:true,focus_steps:0,1,2,12"
)

#######################################
# Detect the kind/type of project
# Arguments:
#   $1 - Project directory path (optional, defaults to current directory)
# Returns:
#   0 on success, 1 on error
# Outputs:
#   JSON object with detection results
#######################################
detect_project_kind() {
    local project_dir="${1:-.}"
    local detection_result=""
    local detected_kind="unknown"
    local confidence=0
    local matched_patterns=()
    local tech_stack=""
    
    # Change to project directory
    if ! cd "$project_dir" 2>/dev/null; then
        echo '{"error":"Invalid project directory","kind":"unknown","confidence":0}'
        return 1
    fi
    
    # Detect tech stack first for additional context
    if command -v detect_tech_stack &>/dev/null; then
        tech_stack=$(detect_tech_stack 2>/dev/null || echo "")
    fi
    
    # Score each project kind based on pattern matches
    declare -A kind_scores
    declare -A kind_specificity
    
    for kind in "${!PROJECT_KIND_PATTERNS[@]}"; do
        local patterns="${PROJECT_KIND_PATTERNS[$kind]}"
        local score=0
        local matched=0
        local total=0
        local specificity=0
        
        # Check each pattern for this kind
        IFS=' ' read -ra pattern_array <<< "$patterns"
        for pattern in "${pattern_array[@]}"; do
            ((total++))
            if [[ -e "$pattern" ]] || compgen -G "$pattern" > /dev/null 2>&1; then
                # Weight score based on pattern specificity
                # More specific patterns (longer paths, specific files) get higher scores
                local pattern_weight=10
                if [[ "$pattern" == *"/"* ]]; then
                    ((pattern_weight += 5))  # Directory structure bonus
                fi
                if [[ "$pattern" != *"*"* ]]; then
                    ((pattern_weight += 5))  # Specific file (non-wildcard) bonus
                fi
                
                ((score += pattern_weight))
                ((matched++))
                ((specificity += ${#pattern}))  # Longer patterns are more specific
                matched_patterns+=("$pattern")
            fi
        done
        
        # Calculate confidence as percentage of matched patterns
        if [[ $total -gt 0 ]]; then
            local match_percentage=$((matched * 100 / total))
            score=$((score + match_percentage))
        fi
        
        kind_scores[$kind]=$score
        kind_specificity[$kind]=$specificity
    done
    
    # Find the kind with highest score (use specificity as tiebreaker)
    local max_score=0
    local max_specificity=0
    for kind in "${!kind_scores[@]}"; do
        local score=${kind_scores[$kind]}
        local spec=${kind_specificity[$kind]:-0}
        if [[ $score -gt $max_score ]] || ([[ $score -eq $max_score ]] && [[ $spec -gt $max_specificity ]]); then
            max_score=$score
            max_specificity=$spec
            detected_kind=$kind
        fi
    done
    
    # Calculate confidence (0-100)
    if [[ $max_score -gt 0 ]]; then
        confidence=$((max_score > 100 ? 100 : max_score))
    fi
    
    # Build JSON result
    local characteristics="${PROJECT_KIND_CHARACTERISTICS[$detected_kind]:-}"
    local workflow_config="${PROJECT_KIND_WORKFLOW_CONFIG[$detected_kind]:-}"
    
    cat <<EOF
{
  "kind": "$detected_kind",
  "confidence": $confidence,
  "matched_patterns": [$(printf '"%s",' "${matched_patterns[@]}" | sed 's/,$//')],
  "characteristics": "$characteristics",
  "workflow_config": "$workflow_config",
  "tech_stack": ${tech_stack:-"null"},
  "detection_version": "$PROJECT_KIND_MODULE_VERSION",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    return 0
}

#######################################
# Get configuration for a specific project kind
# Arguments:
#   $1 - Project kind name
#   $2 - Config key (optional, returns all if not specified)
# Returns:
#   0 on success, 1 on error
# Outputs:
#   Configuration value or JSON object
#######################################
get_project_kind_config() {
    local kind="${1:-}"
    local config_key="${2:-}"
    
    if [[ -z "$kind" ]]; then
        echo "Error: Project kind required" >&2
        return 1
    fi
    
    if [[ ! -v PROJECT_KIND_WORKFLOW_CONFIG[$kind] ]]; then
        echo "Error: Unknown project kind: $kind" >&2
        return 1
    fi
    
    local config="${PROJECT_KIND_WORKFLOW_CONFIG[$kind]}"
    
    if [[ -z "$config_key" ]]; then
        # Return full config as JSON
        echo "$config" | awk -F',' '{
            printf "{"
            for(i=1; i<=NF; i++) {
                split($i, kv, ":")
                printf "\"%s\":\"%s\"", kv[1], kv[2]
                if(i < NF) printf ","
            }
            printf "}"
        }'
    else
        # Return specific config value
        echo "$config" | grep -oP "${config_key}:\K[^,]+" || echo ""
    fi
    
    return 0
}

#######################################
# Validate if project matches expected kind
# Arguments:
#   $1 - Expected project kind
#   $2 - Project directory (optional, defaults to current)
#   $3 - Minimum confidence threshold (optional, defaults to 50)
# Returns:
#   0 if matches, 1 if doesn't match or error
# Outputs:
#   Validation message
#######################################
validate_project_kind() {
    local expected_kind="${1:-}"
    local project_dir="${2:-.}"
    local min_confidence="${3:-50}"
    
    if [[ -z "$expected_kind" ]]; then
        echo "Error: Expected project kind required" >&2
        return 1
    fi
    
    # Detect actual project kind
    local detection_result
    detection_result=$(detect_project_kind "$project_dir")
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to detect project kind" >&2
        return 1
    fi
    
    # Parse detection result
    local detected_kind
    local confidence
    detected_kind=$(echo "$detection_result" | grep -oP '"kind":\s*"\K[^"]+')
    confidence=$(echo "$detection_result" | grep -oP '"confidence":\s*\K[0-9]+')
    
    # Validate
    if [[ "$detected_kind" == "$expected_kind" ]] && [[ $confidence -ge $min_confidence ]]; then
        echo "✓ Project validated as '$expected_kind' with ${confidence}% confidence"
        return 0
    else
        echo "✗ Project kind mismatch: expected '$expected_kind', detected '$detected_kind' (${confidence}% confidence)"
        return 1
    fi
}

#######################################
# List all supported project kinds
# Returns:
#   0 on success
# Outputs:
#   JSON array of supported project kinds with metadata
#######################################
list_supported_project_kinds() {
    echo "["
    
    local first=true
    for kind in "${!PROJECT_KIND_PATTERNS[@]}"; do
        [[ "$first" == false ]] && echo ","
        first=false
        
        local patterns="${PROJECT_KIND_PATTERNS[$kind]}"
        local characteristics="${PROJECT_KIND_CHARACTERISTICS[$kind]}"
        local workflow_config="${PROJECT_KIND_WORKFLOW_CONFIG[$kind]}"
        
        cat <<EOF
  {
    "kind": "$kind",
    "patterns": [$(echo "$patterns" | awk '{for(i=1;i<=NF;i++) printf "\"%s\"%s", $i, (i<NF?",":"")}')],
    "characteristics": "$characteristics",
    "workflow_config": "$workflow_config"
  }
EOF
    done
    
    echo ""
    echo "]"
    
    return 0
}

#######################################
# Get human-readable description of project kind
# Arguments:
#   $1 - Project kind name
# Returns:
#   0 on success, 1 on error
# Outputs:
#   Description string
#######################################
get_project_kind_description() {
    local kind="${1:-}"
    
    case "$kind" in
        shell_automation)
            echo "Shell Script Automation Project - Bash/shell-based automation and tooling"
            ;;
        nodejs_api)
            echo "Node.js API Server - REST/GraphQL API with server runtime"
            ;;
        nodejs_cli)
            echo "Node.js CLI Application - Command-line tool built with Node.js"
            ;;
        nodejs_library)
            echo "Node.js Library - Reusable npm package/library"
            ;;
        static_website)
            echo "Static Website - HTML/CSS/JS website without build process"
            ;;
        react_spa)
            echo "React Single Page Application - React-based web application"
            ;;
        vue_spa)
            echo "Vue.js Single Page Application - Vue.js-based web application"
            ;;
        python_api)
            echo "Python API Server - Flask/FastAPI/Django REST API"
            ;;
        python_cli)
            echo "Python CLI Application - Command-line tool built with Python"
            ;;
        python_library)
            echo "Python Library - Reusable Python package/library"
            ;;
        documentation)
            echo "Documentation Project - Markdown/docs-focused project"
            ;;
        unknown)
            echo "Unknown Project Kind - Could not determine project type"
            ;;
        *)
            echo "Error: Unknown project kind: $kind" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Export functions for use in other modules
export -f detect_project_kind
export -f get_project_kind_config
export -f validate_project_kind
export -f list_supported_project_kinds
export -f get_project_kind_description
