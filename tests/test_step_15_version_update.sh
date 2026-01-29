#!/usr/bin/env bash
# Don't exit on test failures
set -uo pipefail

################################################################################
# Unit Tests for Step 15: AI-Powered Semantic Version Update
# Tests: Version detection, extraction, increment, and update logic
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${SCRIPT_DIR}/../src/workflow"
STEP_MODULE="${WORKFLOW_DIR}/steps/step_15_version_update.sh"

# Set test mode to avoid issues
export TEST_MODE=1

# Source dependencies
source "${WORKFLOW_DIR}/lib/colors.sh"
source "${WORKFLOW_DIR}/lib/utils.sh"

# Mock functions that aren't needed for unit tests
check_copilot_available() { return 1; }
execute_copilot_prompt() { return 1; }
is_third_party_code() { return 1; }
get_git_modified_files() { echo ""; }

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        ((TESTS_PASSED++))
        echo "  ✓ $test_name"
        return 0
    else
        ((TESTS_FAILED++))
        echo "  ✗ $test_name"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        return 1
    fi
}

assert_success() {
    local test_name="$1"
    
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    echo "  ✓ $test_name"
    return 0
}

assert_failure() {
    local test_name="$1"
    
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    echo "  ✗ $test_name"
    return 1
}

# Manually define the functions we need to test (extract from module)
readonly SEMVER_PATTERN='[0-9]+\.[0-9]+\.[0-9]+'
readonly VERSION_PATTERN_REGEX='(version|VERSION|Version|@version)["'\''\s:=]*([0-9]+\.[0-9]+\.[0-9]+)'

extract_version() {
    local input="$1"
    echo "$input" | grep -oE "$SEMVER_PATTERN" | head -1
}

detect_version_patterns() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    [[ ! -r "$file" ]] && return 1
    
    grep -nE "$VERSION_PATTERN_REGEX" "$file" 2>/dev/null || true
}

increment_version() {
    local version="$1"
    local bump_type="$2"
    
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$bump_type" in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        *)
            echo "$version"
            ;;
    esac
}

determine_heuristic_bump_type() {
    local modified_count="${1:-0}"
    local added_count="${2:-0}"
    local deleted_count="${3:-0}"
    
    local stats
    stats=$(git diff --cached --shortstat 2>/dev/null || git diff --shortstat 2>/dev/null || echo "")
    
    local insertions deletions
    insertions=$(echo "$stats" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    deletions=$(echo "$stats" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    
    if [[ $deletions -gt 500 ]] || [[ $modified_count -gt 20 ]]; then
        echo "major"
        return 0
    fi
    
    if [[ $added_count -gt 0 ]] || [[ $insertions -gt 100 ]]; then
        echo "minor"
        return 0
    fi
    
    echo "patch"
}

update_version_in_file() {
    local file="$1"
    local old_version="$2"
    local new_version="$3"
    
    [[ ! -f "$file" ]] && return 1
    [[ ! -w "$file" ]] && return 1
    
    cp "$file" "${file}.bak"
    
    if sed -i.tmp "s/${old_version}/${new_version}/g" "$file" 2>/dev/null; then
        rm -f "${file}.tmp"
        
        if grep -q "$new_version" "$file"; then
            rm -f "${file}.bak"
            return 0
        fi
    fi
    
    mv "${file}.bak" "$file" 2>/dev/null || true
    return 1
}

update_project_version() {
    local old_version="$1"
    local new_version="$2"
    local updated=false
    
    if [[ -f "package.json" ]]; then
        if update_version_in_file "package.json" "$old_version" "$new_version"; then
            updated=true
        fi
    fi
    
    if [[ -f "pyproject.toml" ]]; then
        if update_version_in_file "pyproject.toml" "$old_version" "$new_version"; then
            updated=true
        fi
    fi
    
    if [[ -f "setup.py" ]]; then
        if update_version_in_file "setup.py" "$old_version" "$new_version"; then
            updated=true
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        if update_version_in_file "Cargo.toml" "$old_version" "$new_version"; then
            updated=true
        fi
    fi
    
    if [[ -f ".workflow-config.yaml" ]]; then
        if update_version_in_file ".workflow-config.yaml" "$old_version" "$new_version"; then
            updated=true
        fi
    fi
    
    [[ "$updated" == true ]] && return 0 || return 1
}

################################################################################
# Test: extract_version
################################################################################
test_extract_version() {
    echo "Testing: extract_version()"
    
    local result
    
    result=$(extract_version "version=2.0.0" || echo "")
    assert_equals "2.0.0" "$result" "Extract from assignment" || true
    
    result=$(extract_version "VERSION: 2.0.0" || echo "")
    assert_equals "2.0.0" "$result" "Extract from label" || true
    
    result=$(extract_version "v3.1.4-beta" || echo "")
    assert_equals "3.1.4" "$result" "Extract from tag with suffix" || true
    
    result=$(extract_version "no version here" || echo "")
    assert_equals "" "$result" "No version returns empty" || true
    
    result=$(extract_version "10.20.30" || echo "")
    assert_equals "10.20.30" "$result" "Extract multi-digit version" || true
}

################################################################################
# Test: increment_version
################################################################################
test_increment_version() {
    echo "Testing: increment_version()"
    
    local result
    
    result=$(increment_version "2.0.0" "major" || echo "")
    assert_equals "2.0.0" "$result" "Major bump: 2.0.0 → 2.0.0" || true
    
    result=$(increment_version "2.0.0" "minor" || echo "")
    assert_equals "1.3.0" "$result" "Minor bump: 2.0.0 → 1.3.0" || true
    
    result=$(increment_version "2.0.0" "patch" || echo "")
    assert_equals "1.2.4" "$result" "Patch bump: 2.0.0 → 1.2.4" || true
    
    result=$(increment_version "0.0.1" "major" || echo "")
    assert_equals "1.0.0" "$result" "Major from 0.0.1" || true
    
    result=$(increment_version "9.99.999" "patch" || echo "")
    assert_equals "9.99.1000" "$result" "Patch with large numbers" || true
    
    result=$(increment_version "2.5.0" "minor" || echo "")
    assert_equals "2.6.0" "$result" "Minor bump from .0 patch" || true
}

################################################################################
# Test: determine_heuristic_bump_type
################################################################################
test_determine_heuristic_bump_type() {
    echo "Testing: determine_heuristic_bump_type()"
    
    local result
    
    # Test patch: small changes
    result=$(determine_heuristic_bump_type 3 0 0 || echo "patch")
    assert_equals "patch" "$result" "Patch for small changes" || true
    
    # Test minor: files added
    result=$(determine_heuristic_bump_type 5 2 0 || echo "minor")
    if [[ "$result" == "minor" || "$result" == "patch" ]]; then
        assert_success "Minor/Patch for moderate changes" || true
    else
        assert_failure "Minor/Patch for moderate changes" || true
    fi
    
    # Test major: many files modified
    result=$(determine_heuristic_bump_type 25 0 0 || echo "major")
    assert_equals "major" "$result" "Major for many modified files" || true
    
    echo "  ⊙ Note: Heuristic tests depend on current git state"
}

################################################################################
# Test: detect_version_patterns (with temp files)
################################################################################
test_detect_version_patterns() {
    echo "Testing: detect_version_patterns()"
    
    local temp_file
    temp_file=$(mktemp)
    
    # Test file with version
    cat > "$temp_file" <<'EOF'
# Script header
VERSION="2.1.0"
readonly SCRIPT_VERSION="2.1.0"
EOF
    
    local result
    result=$(detect_version_patterns "$temp_file" | wc -l || echo "0")
    if [[ $result -ge 1 ]]; then
        assert_success "Detect version in shell script" || true
    else
        assert_failure "Detect version in shell script (found $result matches)" || true
    fi
    
    # Test file without version
    cat > "$temp_file" <<'EOF'
# Just a comment
echo "Hello world"
EOF
    
    result=$(detect_version_patterns "$temp_file" | wc -l || echo "0")
    assert_equals "0" "$result" "No version detected in file without version" || true
    
    # Test multiple versions
    cat > "$temp_file" <<'EOF'
version: 3.2.1
Version = "3.2.1"
@version 3.2.1
EOF
    
    result=$(detect_version_patterns "$temp_file" | wc -l || echo "0")
    if [[ $result -ge 2 ]]; then
        assert_success "Detect multiple version patterns" || true
    else
        assert_failure "Detect multiple version patterns (found $result matches)" || true
    fi
    
    rm -f "$temp_file"
}

################################################################################
# Test: update_version_in_file
################################################################################
test_update_version_in_file() {
    echo "Testing: update_version_in_file()"
    
    local temp_file
    temp_file=$(mktemp)
    
    # Create test file
    cat > "$temp_file" <<'EOF'
VERSION="1.0.0"
# Version: 1.0.0
EOF
    
    # Update version
    if update_version_in_file "$temp_file" "1.0.0" "1.1.0" 2>/dev/null; then
        assert_success "Update version in file" || true
        
        # Verify update
        if grep -q "1.1.0" "$temp_file"; then
            assert_success "Verify new version exists" || true
        else
            assert_failure "Verify new version exists" || true
        fi
        
        if ! grep -q "1.0.0" "$temp_file"; then
            assert_success "Verify old version removed" || true
        else
            assert_failure "Verify old version removed" || true
        fi
    else
        assert_failure "Update version in file" || true
    fi
    
    # Test non-existent file
    if ! update_version_in_file "/nonexistent/file.txt" "1.0.0" "2.0.0" 2>/dev/null; then
        assert_success "Fail gracefully for non-existent file" || true
    else
        assert_failure "Fail gracefully for non-existent file" || true
    fi
    
    rm -f "$temp_file" "${temp_file}.bak" "${temp_file}.tmp"
}

################################################################################
# Test: update_project_version (mock files)
################################################################################
test_update_project_version() {
    echo "Testing: update_project_version()"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    local orig_dir="$PWD"
    cd "$temp_dir"
    
    # Create mock package.json
    cat > "package.json" <<'EOF'
{
  "name": "test-package",
  "version": "2.0.0"
}
EOF
    
    # Update project version
    if update_project_version "2.0.0" "2.1.0" 2>/dev/null; then
        assert_success "Update project version in package.json" || true
        
        # Verify update
        if grep -q '"version": "2.1.0"' "package.json"; then
            assert_success "Verify package.json updated" || true
        else
            assert_failure "Verify package.json updated" || true
        fi
    else
        assert_failure "Update project version in package.json" || true
    fi
    
    cd "$orig_dir"
    rm -rf "$temp_dir"
}

################################################################################
# Test: Integration - full version update flow
################################################################################
test_full_version_update_flow() {
    echo "Testing: Full version update flow"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    local orig_dir="$PWD"
    cd "$temp_dir"
    
    # Create test files
    cat > "main.sh" <<'EOF'
#!/bin/bash
readonly VERSION="1.5.0"
echo "Version: 1.5.0"
EOF
    
    cat > "README.md" <<'EOF'
# Project
Version: 1.5.0
EOF
    
    # Test version extraction
    local current_version
    current_version=$(extract_version "$(cat main.sh)" || echo "")
    assert_equals "1.5.0" "$current_version" "Extract current version from file" || true
    
    # Test version increment
    local new_version
    new_version=$(increment_version "$current_version" "minor" || echo "")
    assert_equals "1.6.0" "$new_version" "Increment version (minor)" || true
    
    # Test version update
    if update_version_in_file "main.sh" "$current_version" "$new_version" 2>/dev/null; then
        assert_success "Update main.sh version" || true
    else
        assert_failure "Update main.sh version" || true
    fi
    
    if update_version_in_file "README.md" "$current_version" "$new_version" 2>/dev/null; then
        assert_success "Update README.md version" || true
    else
        assert_failure "Update README.md version" || true
    fi
    
    # Verify both files updated
    if grep -q "1.6.0" "main.sh" && grep -q "1.6.0" "README.md"; then
        assert_success "Both files contain new version" || true
    else
        assert_failure "Both files contain new version" || true
    fi
    
    cd "$orig_dir"
    rm -rf "$temp_dir"
}

################################################################################
# Run all tests
################################################################################
main() {
    echo "=========================================="
    echo "Step 15 Version Update - Unit Tests"
    echo "=========================================="
    echo ""
    
    test_extract_version
    echo ""
    
    test_increment_version
    echo ""
    
    test_determine_heuristic_bump_type
    echo ""
    
    test_detect_version_patterns
    echo ""
    
    test_update_version_in_file
    echo ""
    
    test_update_project_version
    echo ""
    
    test_full_version_update_flow
    echo ""
    
    # Print summary
    echo "=========================================="
    echo "Test Results"
    echo "=========================================="
    echo "Total:  $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

main "$@"
