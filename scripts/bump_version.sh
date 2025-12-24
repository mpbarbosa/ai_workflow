#!/usr/bin/env bash
################################################################################
# Version Bump Script
# Purpose: Automatically bump version numbers across all project files
# Usage: ./scripts/bump_version.sh <new_version>
# Example: ./scripts/bump_version.sh 2.5.0
################################################################################

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Files to update
declare -a FILES_TO_UPDATE=(
    "src/workflow/execute_tests_docs_workflow.sh"
    "README.md"
    ".github/copilot-instructions.md"
)

################################################################################
# Functions
################################################################################

print_usage() {
    cat << EOF
${BLUE}Version Bump Script${RESET}

${YELLOW}Usage:${RESET}
    $0 <new_version>

${YELLOW}Example:${RESET}
    $0 2.5.0

${YELLOW}Description:${RESET}
    Automatically bumps version numbers across all project files:
    - src/workflow/execute_tests_docs_workflow.sh
    - README.md
    - .github/copilot-instructions.md

${YELLOW}Version Format:${RESET}
    MAJOR.MINOR.PATCH (e.g., 2.5.0)

    MAJOR: Breaking changes
    MINOR: New features (backward compatible)
    PATCH: Bug fixes (backward compatible)
EOF
}

validate_version() {
    local version="$1"
    
    # Check format: X.Y.Z
    if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid version format: ${version}${RESET}" >&2
        echo -e "${YELLOW}Expected format: MAJOR.MINOR.PATCH (e.g., 2.5.0)${RESET}" >&2
        return 1
    fi
    
    return 0
}

get_current_version() {
    # Extract current version from main script
    grep -Po '(?<=# Version: )[0-9]+\.[0-9]+\.[0-9]+' \
        "${PROJECT_ROOT}/src/workflow/execute_tests_docs_workflow.sh" | head -1
}

backup_file() {
    local filepath="$1"
    cp "${filepath}" "${filepath}.backup"
}

restore_file() {
    local filepath="$1"
    mv "${filepath}.backup" "${filepath}"
}

update_file() {
    local filepath="$1"
    local new_version="$2"
    
    echo -e "${BLUE}Updating:${RESET} ${filepath}"
    
    # Backup file
    backup_file "${filepath}"
    
    # Update based on file type
    case "${filepath}" in
        *execute_tests_docs_workflow.sh)
            # Update: # Version: X.Y.Z
            sed -i "s/^# Version: [0-9]\+\.[0-9]\+\.[0-9]\+/# Version: ${new_version}/" "${filepath}"
            ;;
        *README.md)
            # Update: **Version**: vX.Y.Z
            sed -i "s/\*\*Version\*\*: v[0-9]\+\.[0-9]\+\.[0-9]\+/**Version**: v${new_version}/" "${filepath}"
            ;;
        *.github/copilot-instructions.md)
            # Update: **Version**: vX.Y.Z or X.Y.Z
            sed -i "s/\*\*Version\*\*: v\?[0-9]\+\.[0-9]\+\.[0-9]\+/**Version**: ${new_version}/" "${filepath}"
            ;;
    esac
    
    # Verify update
    if grep -q "${new_version}" "${filepath}"; then
        echo -e "  ${GREEN}✓ Updated successfully${RESET}"
        rm "${filepath}.backup"
        return 0
    else
        echo -e "  ${RED}✗ Update failed${RESET}" >&2
        restore_file "${filepath}"
        return 1
    fi
}

show_diff() {
    local filepath="$1"
    
    if [[ -f "${filepath}.backup" ]]; then
        echo -e "\n${BLUE}Changes in ${filepath}:${RESET}"
        diff -u "${filepath}.backup" "${filepath}" || true
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Check arguments
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        print_usage
        exit 0
    fi
    
    local new_version="$1"
    
    # Validate version format
    if ! validate_version "${new_version}"; then
        exit 1
    fi
    
    # Get current version
    local current_version=$(get_current_version)
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}  Version Bump${RESET}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}Current Version:${RESET} v${current_version}"
    echo -e "  ${YELLOW}New Version:${RESET}     v${new_version}"
    echo -e ""
    
    # Confirm
    read -p "Continue with version bump? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted.${RESET}"
        exit 0
    fi
    
    # Update files
    echo -e "\n${BLUE}Updating files...${RESET}\n"
    
    local failed=0
    for file in "${FILES_TO_UPDATE[@]}"; do
        local filepath="${PROJECT_ROOT}/${file}"
        
        if [[ ! -f "${filepath}" ]]; then
            echo -e "${YELLOW}⚠️  File not found: ${file}${RESET}"
            continue
        fi
        
        if ! update_file "${filepath}" "${new_version}"; then
            ((failed++))
        fi
    done
    
    # Summary
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    if [[ ${failed} -eq 0 ]]; then
        echo -e "${GREEN}✅ Version bumped successfully: v${current_version} → v${new_version}${RESET}"
        echo -e ""
        echo -e "${YELLOW}Next steps:${RESET}"
        echo -e "  1. Review changes: git diff"
        echo -e "  2. Run tests: ./tests/run_all_tests.sh"
        echo -e "  3. Create release notes: docs/RELEASE_NOTES_v${new_version}.md"
        echo -e "  4. Commit: git add -A && git commit -m 'chore: Release v${new_version}'"
        echo -e "  5. Tag: git tag -a v${new_version} -m 'Release v${new_version}'"
        echo -e ""
    else
        echo -e "${RED}❌ Version bump failed: ${failed} file(s) not updated${RESET}"
        exit 1
    fi
}

main "$@"
