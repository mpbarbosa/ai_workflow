#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 6 Test Discovery Module
# Purpose: Language-aware test file discovery and inventory
# Part of: Step 6 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.7
################################################################################

# ==============================================================================
# TEST FILE DISCOVERY (LANGUAGE-AWARE)
# ==============================================================================

# Discover test files based on project language
# Usage: discover_test_files_step6 [language]
# Returns: List of test files
discover_test_files_step6() {
    local language="${1:-${PRIMARY_LANGUAGE:-javascript}}"
    
    case "$language" in
        javascript|typescript)
            fast_find "." "*.test.js" 10 "node_modules" ".git" "coverage"
            fast_find "." "*.spec.js" 10 "node_modules" ".git" "coverage"
            fast_find "." "*.test.ts" 10 "node_modules" ".git" "coverage"
            ;;
        python)
            fast_find "." "test_*.py" 10 "__pycache__" ".git" "coverage"
            fast_find "." "*_test.py" 10 "__pycache__" ".git" "coverage"
            ;;
        go)
            fast_find "." "*_test.go" 10 "vendor" ".git"
            ;;
        java)
            fast_find "." "*Test.java" 10 "target" ".git"
            fast_find "." "*Tests.java" 10 "target" ".git"
            ;;
        ruby)
            fast_find "." "*_spec.rb" 10 "vendor" ".git"
            fast_find "." "*_test.rb" 10 "vendor" ".git"
            ;;
        rust)
            fast_find "tests" "*.rs" 10 "target" ".git"
            ;;
        cpp)
            fast_find "." "*_test.cpp" 10 "build" ".git"
            fast_find "." "*_test.cc" 10 "build" ".git"
            ;;
        bash)
            fast_find "." "*.bats" 10 ".git"
            fast_find "tests" "test_*.sh" 10 ".git"
            ;;
        *)
            # Fallback to JavaScript
            fast_find "." "*.test.js" 10 "node_modules" ".git" "coverage"
            fast_find "." "*.spec.js" 10 "node_modules" ".git" "coverage"
            ;;
    esac | sort -u
}

# Count test files
# Usage: count_test_files_step6 <test_files>
# Returns: Count of test files
count_test_files_step6() {
    local test_files="$1"
    
    if [[ -z "$test_files" ]]; then
        echo "0"
    else
        echo "$test_files" | grep -c "test\|spec" || echo "0"
    fi
}

# ==============================================================================
# TEST INVENTORY
# ==============================================================================

# Create test inventory with metadata
# Usage: create_test_inventory_step6 <test_files>
# Returns: Inventory report
create_test_inventory_step6() {
    local test_files="$1"
    local count
    count=$(count_test_files_step6 "$test_files")
    
    if [[ $count -eq 0 ]]; then
        echo "No test files found"
        return 1
    fi
    
    echo "Test File Inventory ($count files):"
    echo ""
    echo "$test_files" | while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local size
        size=$(wc -l < "$file" 2>/dev/null || echo "?")
        echo "  • $file ($size lines)"
    done
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f discover_test_files_step6
export -f count_test_files_step6
export -f create_test_inventory_step6
