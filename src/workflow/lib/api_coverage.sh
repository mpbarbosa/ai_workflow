#!/usr/bin/env bash
set -euo pipefail

################################################################################
# API Coverage Checker Module
# Version: 1.0.0
# Purpose: Verify API documentation completeness
#
# Features:
#   - Extract public functions/methods from source code
#   - Parse API documentation from markdown and JSDoc/docstrings
#   - Cross-reference documented vs actual APIs
#   - Support for multiple languages (bash, python, javascript, etc.)
#   - Generate coverage reports with missing/undocumented APIs
#   - Tech-stack aware analysis
#
# Integration: Used by Step 5 (Documentation Enhancement)
################################################################################

# Set defaults
API_CACHE_DIR="${WORKFLOW_HOME:-$(pwd)}/.api_cache"

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize API coverage system
init_api_coverage() {
    mkdir -p "$API_CACHE_DIR"
    
    # Source tech stack detection if available
    local lib_dir="${WORKFLOW_HOME}/lib"
    if [[ -f "${lib_dir}/tech_stack.sh" ]]; then
        source "${lib_dir}/tech_stack.sh"
    fi
    
    print_info "API coverage checker initialized"
    return 0
}

# ==============================================================================
# SOURCE CODE API EXTRACTION
# ==============================================================================

# Extract public functions from Bash scripts
# Args: $1 = file path
# Output: Function names, one per line
extract_bash_functions() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract function definitions (various formats)
    # Format 1: function name() { }
    # Format 2: name() { }
    # Exclude private functions (starting with _)
    grep -E '^[[:space:]]*(function[[:space:]]+)?[a-zA-Z][a-zA-Z0-9_-]*[[:space:]]*\(\)' "$file" 2>/dev/null | \
        sed -E 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z][a-zA-Z0-9_-]*)[[:space:]]*\(\).*/\2/' | \
        grep -v '^_' || true
}

# Extract public functions from Python files
# Args: $1 = file path
# Output: Function/method names, one per line
extract_python_functions() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract function and method definitions
    # Exclude private functions/methods (starting with _)
    grep -E '^[[:space:]]*(def|async def)[[:space:]]+[a-zA-Z][a-zA-Z0-9_]*' "$file" 2>/dev/null | \
        sed -E 's/^[[:space:]]*(def|async def)[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*).*/\2/' | \
        grep -v '^_' || true
}

# Extract public functions from JavaScript/TypeScript files
# Args: $1 = file path
# Output: Function names, one per line
extract_javascript_functions() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract various function formats:
    # - function name()
    # - export function name()
    # - const name = function()
    # - const name = () =>
    # - async function name()
    # Exclude private (starting with _)
    {
        grep -E '^[[:space:]]*(export[[:space:]]+)?(async[[:space:]]+)?function[[:space:]]+[a-zA-Z]' "$file" 2>/dev/null | \
            sed -E 's/^[[:space:]]*(export[[:space:]]+)?(async[[:space:]]+)?function[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*).*/\3/'
        grep -E '^[[:space:]]*(export[[:space:]]+)?const[[:space:]]+[a-zA-Z][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*(async[[:space:]]+)?(\(|function)' "$file" 2>/dev/null | \
            sed -E 's/^[[:space:]]*(export[[:space:]]+)?const[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*).*/\2/'
        grep -E '^[[:space:]]*(export[[:space:]]+)?class[[:space:]]+[a-zA-Z]' "$file" 2>/dev/null | \
            sed -E 's/^[[:space:]]*(export[[:space:]]+)?class[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*).*/\2/'
    } | grep -v '^_' || true
}

# Extract public methods from Go files
# Args: $1 = file path
# Output: Function names, one per line
extract_go_functions() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract exported functions (capitalized first letter)
    grep -E '^func[[:space:]]+[A-Z]' "$file" 2>/dev/null | \
        sed -E 's/^func[[:space:]]+([A-Z][a-zA-Z0-9_]*).*/\1/' || true
}

# Extract public methods from Java files
# Args: $1 = file path
# Output: Method names, one per line
extract_java_methods() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract public methods
    grep -E '^[[:space:]]*(public|protected)[[:space:]]+(static[[:space:]]+)?[a-zA-Z]' "$file" 2>/dev/null | \
        grep -oE '[a-zA-Z][a-zA-Z0-9_]*[[:space:]]*\(' | \
        sed 's/[[:space:]]*(//' || true
}

# Extract APIs from source files based on language
# Args: $1 = file path, $2 = language (optional, auto-detected)
# Output: API names, one per line
extract_source_apis() {
    local file="$1"
    local language="${2:-}"
    
    [[ ! -f "$file" ]] && return 1
    
    # Auto-detect language if not provided
    if [[ -z "$language" ]]; then
        case "$file" in
            *.sh|*.bash) language="bash" ;;
            *.py) language="python" ;;
            *.js|*.jsx|*.mjs) language="javascript" ;;
            *.ts|*.tsx) language="typescript" ;;
            *.go) language="go" ;;
            *.java) language="java" ;;
            *) return 1 ;;
        esac
    fi
    
    # Extract based on language
    case "$language" in
        bash|sh)
            extract_bash_functions "$file"
            ;;
        python|python3)
            extract_python_functions "$file"
            ;;
        javascript|js|typescript|ts)
            extract_javascript_functions "$file"
            ;;
        go)
            extract_go_functions "$file"
            ;;
        java)
            extract_java_methods "$file"
            ;;
        *)
            print_warning "Unsupported language for API extraction: $language"
            return 1
            ;;
    esac
}

# ==============================================================================
# DOCUMENTATION API EXTRACTION
# ==============================================================================

# Extract documented APIs from markdown files
# Args: $1 = file path
# Output: API names, one per line
extract_documented_apis_markdown() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Extract function/method names from:
    # - ### functionName
    # - #### functionName()
    # - `functionName()`
    # - **functionName**
    {
        grep -E '^#{2,4}[[:space:]]+`?[a-zA-Z][a-zA-Z0-9_-]*(\(\))?`?' "$file" 2>/dev/null | \
            sed -E 's/^#{2,4}[[:space:]]+`?([a-zA-Z][a-zA-Z0-9_-]*)(\(\))?`?.*/\1/'
        
        # Extract from function signature blocks
        grep -E '^[[:space:]]*[a-zA-Z][a-zA-Z0-9_-]*\(' "$file" 2>/dev/null | \
            sed -E 's/^[[:space:]]*([a-zA-Z][a-zA-Z0-9_-]*)\(.*/\1/'
    } | sort -u || true
}

# Extract documented APIs from JSDoc comments in JavaScript/TypeScript
# Args: $1 = file path
# Output: API names, one per line
extract_documented_apis_jsdoc() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Look for JSDoc blocks with @function, @method, or @name tags
    grep -B2 -E '@(function|method|name)[[:space:]]+[a-zA-Z]' "$file" 2>/dev/null | \
        grep -E '@(function|method|name)[[:space:]]+[a-zA-Z]' | \
        sed -E 's/.*@(function|method|name)[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*).*/\2/' | \
        sort -u || true
}

# Extract documented APIs from Python docstrings
# Args: $1 = file path
# Output: API names, one per line
extract_documented_apis_python() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Functions with docstrings have """ or ''' after def
    awk '
        /^[[:space:]]*(def|async def)[[:space:]]+[a-zA-Z]/ {
            match($0, /[[:space:]]*(def|async def)[[:space:]]+([a-zA-Z][a-zA-Z0-9_]*)/, arr)
            func = arr[2]
            getline
            if ($0 ~ /^[[:space:]]*("""|\047\047\047)/) {
                if (func !~ /^_/) print func
            }
        }
    ' "$file" | sort -u || true
}

# Extract documented APIs from Go comments
# Args: $1 = file path
# Output: API names, one per line
extract_documented_apis_go() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Look for functions with doc comments (// FunctionName ...)
    awk '
        /^\/\/ [A-Z]/ {
            match($0, /^\/\/ ([A-Z][a-zA-Z0-9_]*)/, arr)
            func = arr[1]
            getline
            if ($0 ~ /^func[[:space:]]+/ func) {
                print func
            }
        }
    ' "$file" | sort -u || true
}

# ==============================================================================
# COVERAGE ANALYSIS
# ==============================================================================

# Analyze API coverage for a single file
# Args: $1 = source file, $2 = docs directory, $3 = output file
# Returns: Count of undocumented APIs
analyze_file_api_coverage() {
    local source_file="$1"
    local docs_dir="$2"
    local output_file="$3"
    local undocumented_count=0
    
    # Extract APIs from source
    local source_apis=$(extract_source_apis "$source_file")
    [[ -z "$source_apis" ]] && return 0
    
    local source_api_count=$(echo "$source_apis" | wc -l)
    
    # Find related documentation
    local base_name=$(basename "$source_file" | sed 's/\.[^.]*$//')
    local doc_files=()
    
    # Look for related markdown files
    if [[ -d "$docs_dir" ]]; then
        while IFS= read -r doc_file; do
            doc_files+=("$doc_file")
        done < <(find "$docs_dir" -name "*${base_name}*.md" -o -name "API.md" -o -name "api.md" -o -name "README.md" 2>/dev/null || true)
    fi
    
    # Also check for inline documentation
    local inline_apis=""
    case "$source_file" in
        *.js|*.ts|*.jsx|*.tsx)
            inline_apis=$(extract_documented_apis_jsdoc "$source_file")
            ;;
        *.py)
            inline_apis=$(extract_documented_apis_python "$source_file")
            ;;
        *.go)
            inline_apis=$(extract_documented_apis_go "$source_file")
            ;;
    esac
    
    # Extract all documented APIs
    local documented_apis=""
    for doc_file in "${doc_files[@]}"; do
        documented_apis+=$'\n'$(extract_documented_apis_markdown "$doc_file")
    done
    documented_apis+=$'\n'$inline_apis
    documented_apis=$(echo "$documented_apis" | sort -u)
    
    # Find undocumented APIs
    while IFS= read -r api; do
        [[ -z "$api" ]] && continue
        
        if ! echo "$documented_apis" | grep -qx "$api"; then
            echo "${source_file}: Undocumented API: ${api}" >> "$output_file"
            ((undocumented_count++))
        fi
    done <<< "$source_apis"
    
    # Calculate coverage
    if [[ $source_api_count -gt 0 ]]; then
        local documented_count=$((source_api_count - undocumented_count))
        local coverage=$((100 * documented_count / source_api_count))
        print_info "$(basename "$source_file"): ${coverage}% API coverage (${documented_count}/${source_api_count})"
    fi
    
    return $undocumented_count
}

# Analyze API coverage for all source files
# Args: $1 = source directory, $2 = docs directory, $3 = output report file
# Returns: Total count of undocumented APIs
analyze_project_api_coverage() {
    local source_dir="$1"
    local docs_dir="${2:-docs}"
    local report_file="$3"
    local total_undocumented=0
    local total_apis=0
    local files_analyzed=0
    
    print_info "Analyzing API coverage..."
    
    init_api_coverage
    
    # Find all source files based on tech stack
    local file_patterns=()
    
    # Detect primary language if tech_stack.sh is available
    if declare -f detect_primary_language &>/dev/null; then
        local primary_lang=$(detect_primary_language 2>/dev/null || echo "")
        case "$primary_lang" in
            bash)
                file_patterns=("*.sh" "*.bash")
                ;;
            python)
                file_patterns=("*.py")
                ;;
            javascript|typescript)
                file_patterns=("*.js" "*.ts" "*.jsx" "*.tsx")
                ;;
            go)
                file_patterns=("*.go")
                ;;
            java)
                file_patterns=("*.java")
                ;;
            *)
                # Default: check common languages
                file_patterns=("*.sh" "*.py" "*.js" "*.ts" "*.go" "*.java")
                ;;
        esac
    else
        file_patterns=("*.sh" "*.py" "*.js" "*.ts" "*.go" "*.java")
    fi
    
    # Analyze each source file
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r source_file; do
            ((files_analyzed++))
            
            local undocumented=0
            analyze_file_api_coverage "$source_file" "$docs_dir" "$report_file" || undocumented=$?
            ((total_undocumented += undocumented))
            
            # Count total APIs
            local apis=$(extract_source_apis "$source_file")
            if [[ -n "$apis" ]]; then
                local count=$(echo "$apis" | wc -l)
                ((total_apis += count))
            fi
        done < <(find "$source_dir" -name "$pattern" -type f \
            ! -path "*/node_modules/*" \
            ! -path "*/.git/*" \
            ! -path "*/vendor/*" \
            ! -path "*/test/*" \
            ! -path "*/tests/*" \
            2>/dev/null || true)
    done
    
    # Calculate overall coverage
    if [[ $total_apis -gt 0 ]]; then
        local documented_apis=$((total_apis - total_undocumented))
        local coverage=$((100 * documented_apis / total_apis))
        
        print_info "Overall API coverage: ${coverage}% (${documented_apis}/${total_apis} documented)"
        
        if [[ $coverage -lt 80 ]]; then
            print_warning "API coverage is below 80% threshold"
        else
            print_success "API coverage meets quality standards"
        fi
    else
        print_warning "No APIs found for analysis"
    fi
    
    return $total_undocumented
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Generate API coverage summary report
# Args: $1 = report file, $2 = output summary file, $3 = total APIs, $4 = undocumented APIs
generate_api_coverage_summary() {
    local report_file="$1"
    local summary_file="$2"
    local total_apis="${3:-0}"
    local undocumented="${4:-0}"
    
    local documented=$((total_apis - undocumented))
    local coverage=0
    [[ $total_apis -gt 0 ]] && coverage=$((100 * documented / total_apis))
    
    cat > "$summary_file" << EOF
# API Coverage Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Total APIs**: $total_apis
**Documented**: $documented
**Undocumented**: $undocumented
**Coverage**: ${coverage}%

## Coverage Status

EOF
    
    if [[ $coverage -ge 90 ]]; then
        echo "✅ **Excellent** - Coverage meets high quality standards (≥90%)" >> "$summary_file"
    elif [[ $coverage -ge 80 ]]; then
        echo "✓ **Good** - Coverage meets minimum standards (≥80%)" >> "$summary_file"
    elif [[ $coverage -ge 60 ]]; then
        echo "⚠️  **Fair** - Coverage needs improvement (60-79%)" >> "$summary_file"
    else
        echo "❌ **Poor** - Coverage is critically low (<60%)" >> "$summary_file"
    fi
    
    cat >> "$summary_file" << EOF

## Recommendations

EOF
    
    if [[ $undocumented -gt 0 ]]; then
        cat >> "$summary_file" << EOF
1. Document the ${undocumented} missing APIs listed below
2. Add inline documentation (JSDoc, docstrings, comments) to source files
3. Create or update API reference documentation in \`docs/\`
4. Consider using automated documentation generators

EOF
    else
        echo "🎉 All public APIs are documented! Maintain this standard for new APIs." >> "$summary_file"
    fi
    
    if [[ -f "$report_file" ]] && [[ -s "$report_file" ]]; then
        cat >> "$summary_file" << EOF

## Undocumented APIs

\`\`\`
$(cat "$report_file")
\`\`\`

EOF
    fi
    
    cat >> "$summary_file" << EOF
---

*Generated by API Coverage Checker Module v1.0.0*
EOF
    
    print_info "API coverage summary generated: $summary_file"
}

# Export functions
export -f init_api_coverage
export -f extract_bash_functions
export -f extract_python_functions
export -f extract_javascript_functions
export -f extract_go_functions
export -f extract_java_methods
export -f extract_source_apis
export -f extract_documented_apis_markdown
export -f extract_documented_apis_jsdoc
export -f extract_documented_apis_python
export -f extract_documented_apis_go
export -f analyze_file_api_coverage
export -f analyze_project_api_coverage
export -f generate_api_coverage_summary
