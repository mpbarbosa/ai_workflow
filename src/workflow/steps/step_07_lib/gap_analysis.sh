#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 7 Gap Analysis Module
# Purpose: Language-aware detection of untested code
# Part of: Step 7 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.7
################################################################################

# Find untested code files based on language
# Usage: find_untested_files_step6 [language]
# Returns: List of untested files
find_untested_files_step6() {
    local language="${1:-${PRIMARY_LANGUAGE:-javascript}}"
    local source_dir="."
    local untested=()
    
    case "$language" in
        javascript|typescript)
            source_dir="scripts"
            [[ ! -d "$source_dir" ]] && source_dir="src"
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                local file_name=$(basename "$code_file" .js)
                local test_file_1="__tests__/${file_name}.test.js"
                local test_file_2="__tests__/${file_name}.spec.js"
                if [[ ! -f "$test_file_1" ]] && [[ ! -f "$test_file_2" ]]; then
                    echo "$code_file"
                fi
            done < <(fast_find "$source_dir" "*.js" 5 "node_modules" ".git" "coverage" 2>/dev/null || true)
            ;;
        python)
            source_dir="src"
            [[ ! -d "$source_dir" ]] && source_dir="."
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                [[ "$code_file" == *"__init__.py" ]] && continue
                [[ "$code_file" == *"test_"* ]] && continue
                [[ "$code_file" == *"_test.py" ]] && continue
                local file_dir=$(dirname "$code_file")
                local file_name=$(basename "$code_file" .py)
                local test_file="${file_dir}/test_${file_name}.py"
                [[ ! -f "$test_file" ]] && echo "$code_file"
            done < <(fast_find "$source_dir" "*.py" 10 "__pycache__" ".git" 2>/dev/null || true)
            ;;
        go)
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                [[ "$code_file" == *"_test.go" ]] && continue
                local test_file="${code_file%.go}_test.go"
                [[ ! -f "$test_file" ]] && echo "$code_file"
            done < <(fast_find "." "*.go" 10 "vendor" ".git" 2>/dev/null || true)
            ;;
        *)
            # Fallback
            echo ""
            ;;
    esac
}

# Count untested files
# Usage: count_untested_files_step6 <untested_files>
count_untested_files_step6() {
    local untested_files="$1"
    [[ -z "$untested_files" ]] && echo "0" || echo "$untested_files" | wc -l
}

export -f find_untested_files_step6
export -f count_untested_files_step6
