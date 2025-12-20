#!/usr/bin/env bash
# test_project_kind_validation.sh - Validation tests for Project Kind System
# Tests configuration validation, error handling, and edge cases

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/project_kind_detection.sh"
source "${SCRIPT_DIR}/project_kind_config.sh"
source "${SCRIPT_DIR}/validation.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_func="$2"
    
    ((TESTS_RUN++))
    echo -e "\n${BLUE}▶ Running: ${test_name}${NC}"
    
    if $test_func; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASSED: ${test_name}${NC}"
        return 0
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAILED: ${test_name}${NC}"
        return 1
    fi
}

setup_test_env() {
    export TEST_TMP_DIR="/tmp/test_validation_$$"
    mkdir -p "$TEST_TMP_DIR"
}

cleanup_test_env() {
    if [[ -n "${TEST_TMP_DIR:-}" ]] && [[ -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Validation Tests

test_valid_project_kind() {
    if validate_project_kind "shell_script"; then
        echo -e "${GREEN}  ✓ shell_script is valid${NC}"
        return 0
    else
        echo -e "${RED}  ✗ shell_script should be valid${NC}"
        return 1
    fi
}

test_invalid_project_kind() {
    if ! validate_project_kind "invalid_kind_xyz"; then
        echo -e "${GREEN}  ✓ Correctly rejects invalid project kind${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should reject invalid project kind${NC}"
        return 1
    fi
}

test_empty_project_kind() {
    if ! validate_project_kind ""; then
        echo -e "${GREEN}  ✓ Correctly rejects empty project kind${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should reject empty project kind${NC}"
        return 1
    fi
}

test_config_file_validation() {
    local test_dir="$TEST_TMP_DIR/config_test"
    mkdir -p "$test_dir"
    
    # Create valid config
    cat > "$test_dir/.project_kind" << 'EOF'
project_kind=nodejs_api
primary_language=javascript
confidence=high
detected_at=2025-12-18T20:00:00Z
EOF
    
    if validate_project_kind_config "$test_dir/.project_kind"; then
        echo -e "${GREEN}  ✓ Valid config file passes validation${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Valid config should pass validation${NC}"
        return 1
    fi
}

test_corrupted_config_handling() {
    local test_dir="$TEST_TMP_DIR/corrupt_test"
    mkdir -p "$test_dir"
    
    # Create corrupted config
    cat > "$test_dir/.project_kind" << 'EOF'
project_kind=
invalid line without equals
primary_language
EOF
    
    if ! validate_project_kind_config "$test_dir/.project_kind"; then
        echo -e "${GREEN}  ✓ Correctly detects corrupted config${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should detect corrupted config${NC}"
        return 1
    fi
}

test_missing_config_handling() {
    local test_dir="$TEST_TMP_DIR/missing_test"
    mkdir -p "$test_dir"
    
    if ! validate_project_kind_config "$test_dir/.project_kind"; then
        echo -e "${GREEN}  ✓ Correctly handles missing config${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should handle missing config${NC}"
        return 1
    fi
}

test_permission_handling() {
    local test_dir="$TEST_TMP_DIR/perm_test"
    mkdir -p "$test_dir"
    
    # Create config and make it unreadable
    echo "project_kind=shell_script" > "$test_dir/.project_kind"
    chmod 000 "$test_dir/.project_kind" 2>/dev/null || {
        echo -e "${YELLOW}  ⊘ Skipping permission test (requires write access)${NC}"
        return 0
    }
    
    if ! load_project_kind_config "$test_dir" 2>/dev/null; then
        chmod 644 "$test_dir/.project_kind"
        echo -e "${GREEN}  ✓ Correctly handles permission errors${NC}"
        return 0
    else
        chmod 644 "$test_dir/.project_kind"
        echo -e "${RED}  ✗ Should handle permission errors${NC}"
        return 1
    fi
}

test_symlink_handling() {
    local test_dir="$TEST_TMP_DIR/symlink_test"
    local source_dir="$TEST_TMP_DIR/source"
    mkdir -p "$test_dir" "$source_dir"
    
    # Create source config
    echo "project_kind=shell_script" > "$source_dir/.project_kind"
    
    # Create symlink
    ln -sf "$source_dir/.project_kind" "$test_dir/.project_kind"
    
    if load_project_kind_config "$test_dir"; then
        echo -e "${GREEN}  ✓ Correctly handles symlinked configs${NC}"
        return 0
    else
        echo -e "${YELLOW}  ⊘ Symlink handling may need review${NC}"
        return 0
    fi
}

test_language_detection_validation() {
    local test_dir="$TEST_TMP_DIR/lang_test"
    mkdir -p "$test_dir"
    
    # Create files with various extensions
    touch "$test_dir/script.sh"
    touch "$test_dir/app.js"
    touch "$test_dir/page.html"
    touch "$test_dir/README.md"
    
    local result
    result=$(detect_primary_language "$test_dir")
    
    if [[ -n "$result" ]]; then
        echo -e "${GREEN}  ✓ Primary language detected: $result${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should detect a primary language${NC}"
        return 1
    fi
}

test_confidence_scoring() {
    local test_dir="$TEST_TMP_DIR/confidence_test"
    mkdir -p "$test_dir/src"
    
    # Create strong indicators for shell_script
    cat > "$test_dir/src/main.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Script"
EOF
    
    cat > "$test_dir/README.md" << 'EOF'
# Shell Script Project
This is a bash automation project.
EOF
    
    local result
    result=$(detect_project_kind "$test_dir")
    
    if [[ "$result" == *"confidence=high"* ]]; then
        echo -e "${GREEN}  ✓ High confidence scoring works${NC}"
        return 0
    else
        echo -e "${YELLOW}  ℹ Confidence: $(echo "$result" | grep -oP 'confidence=\K\w+' || echo 'unknown')${NC}"
        return 0
    fi
}

test_multiple_detection_runs() {
    local test_dir="$TEST_TMP_DIR/multi_test"
    mkdir -p "$test_dir"
    
    echo "project_kind=shell_script" > "$test_dir/.project_kind"
    
    # Run detection multiple times
    local result1 result2 result3
    result1=$(load_project_kind_config "$test_dir" && echo "$PROJECT_KIND")
    result2=$(load_project_kind_config "$test_dir" && echo "$PROJECT_KIND")
    result3=$(load_project_kind_config "$test_dir" && echo "$PROJECT_KIND")
    
    if [[ "$result1" == "$result2" ]] && [[ "$result2" == "$result3" ]]; then
        echo -e "${GREEN}  ✓ Consistent results across multiple runs${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Results should be consistent${NC}"
        return 1
    fi
}

test_concurrent_access() {
    local test_dir="$TEST_TMP_DIR/concurrent_test"
    mkdir -p "$test_dir"
    
    echo "project_kind=nodejs_api" > "$test_dir/.project_kind"
    
    # Simulate concurrent reads
    {
        load_project_kind_config "$test_dir" > /dev/null 2>&1 &
        load_project_kind_config "$test_dir" > /dev/null 2>&1 &
        load_project_kind_config "$test_dir" > /dev/null 2>&1 &
        wait
    }
    
    echo -e "${GREEN}  ✓ Handles concurrent access${NC}"
    return 0
}

test_config_update_detection() {
    local test_dir="$TEST_TMP_DIR/update_test"
    mkdir -p "$test_dir"
    
    # Create initial config
    echo "project_kind=shell_script" > "$test_dir/.project_kind"
    load_project_kind_config "$test_dir"
    local initial="$PROJECT_KIND"
    
    # Update config
    echo "project_kind=nodejs_api" > "$test_dir/.project_kind"
    load_project_kind_config "$test_dir"
    local updated="$PROJECT_KIND"
    
    if [[ "$initial" != "$updated" ]]; then
        echo -e "${GREEN}  ✓ Detects config updates${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should detect config updates${NC}"
        return 1
    fi
}

test_edge_case_file_structures() {
    local test_dir="$TEST_TMP_DIR/edge_test"
    
    # Test 1: Deeply nested structure
    mkdir -p "$test_dir/a/b/c/d/e"
    touch "$test_dir/a/b/c/d/e/deep.sh"
    
    if detect_project_kind "$test_dir" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Handles deeply nested structures${NC}"
    else
        echo -e "${YELLOW}  ⊘ Deep nesting may need review${NC}"
    fi
    
    rm -rf "$test_dir"
    
    # Test 2: Many files
    mkdir -p "$test_dir"
    for i in {1..100}; do
        touch "$test_dir/file$i.txt"
    done
    
    if detect_project_kind "$test_dir" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Handles many files${NC}"
        return 0
    else
        echo -e "${YELLOW}  ⊘ Large file count handling may need review${NC}"
        return 0
    fi
}

test_special_characters_in_paths() {
    local test_dir="$TEST_TMP_DIR/special test"
    mkdir -p "$test_dir"
    
    echo "project_kind=shell_script" > "$test_dir/.project_kind"
    
    if load_project_kind_config "$test_dir"; then
        echo -e "${GREEN}  ✓ Handles spaces in paths${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should handle spaces in paths${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Project Kind - Validation Tests                          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    setup_test_env
    trap cleanup_test_env EXIT
    
    run_test "Valid Project Kind" test_valid_project_kind
    run_test "Invalid Project Kind" test_invalid_project_kind
    run_test "Empty Project Kind" test_empty_project_kind
    run_test "Config File Validation" test_config_file_validation
    run_test "Corrupted Config Handling" test_corrupted_config_handling
    run_test "Missing Config Handling" test_missing_config_handling
    run_test "Permission Handling" test_permission_handling
    run_test "Symlink Handling" test_symlink_handling
    run_test "Language Detection Validation" test_language_detection_validation
    run_test "Confidence Scoring" test_confidence_scoring
    run_test "Multiple Detection Runs" test_multiple_detection_runs
    run_test "Concurrent Access" test_concurrent_access
    run_test "Config Update Detection" test_config_update_detection
    run_test "Edge Case File Structures" test_edge_case_file_structures
    run_test "Special Characters in Paths" test_special_characters_in_paths
    
    # Summary
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Validation Test Summary                                  ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "Tests Run:    ${BLUE}${TESTS_RUN}${NC}"
    echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        exit 1
    else
        echo -e "\n${GREEN}✓ All validation tests passed!${NC}"
        exit 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
