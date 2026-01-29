#!/usr/bin/env bash
################################################################################
# Automated Project Version Bump Script
# Purpose: Bump semantic version in target project with AI assistance
# Part of: AI Workflow Automation v2.7.0
# Version: 2.0.0
# Usage: ./bump_project_version.sh [options]
################################################################################

set -euo pipefail

# Script directory and library paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Source required libraries
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/ai_helpers.sh"
source "${LIB_DIR}/version_bump.sh"

# Default values
BUMP_TYPE="auto"
TARGET_DIR="${TARGET_PROJECT_ROOT:-.}"
AUTO_COMMIT=false
INTERACTIVE=true
PRERELEASE_ID=""

################################################################################
# Functions
################################################################################

print_usage() {
    cat << EOF
${BLUE}Automated Project Version Bump${RESET}

${YELLOW}Usage:${RESET}
    $0 [options]

${YELLOW}Options:${RESET}
    --type TYPE        Bump type: major|minor|patch|auto (default: auto)
    --target DIR       Target project directory (default: current or \$TARGET_PROJECT_ROOT)
    --prerelease ID    Prerelease identifier (e.g., alpha, beta, rc)
    --auto-commit      Automatically commit version bump
    --yes              Skip confirmations (non-interactive)
    --help             Show this help message

${YELLOW}Examples:${RESET}
    # Auto-detect bump type and commit
    $0 --auto-commit

    # Specific bump type with prerelease
    $0 --type minor --prerelease alpha --auto-commit

    # Target specific project
    $0 --target /path/to/project --type patch

${YELLOW}Description:${RESET}
    This script automatically bumps the semantic version in your project
    using intelligent detection of project type and version management tools.
    
    Supported project types:
    - Node.js (npm, yarn)
    - Python (poetry, setuptools)
    - Rust (cargo)
    - Go modules
    - Manual (generic projects)
    
    The script can use AI (GitHub Copilot CLI) to analyze changes and
    recommend the appropriate bump type, or use heuristics based on
    conventional commits and change statistics.

${YELLOW}Version Bump Rules:${RESET}
    - ${GREEN}auto${RESET}:  AI or heuristic analysis determines bump type
    - ${GREEN}major${RESET}: Breaking changes (X.0.0)
    - ${GREEN}minor${RESET}: New features (X.Y.0)
    - ${GREEN}patch${RESET}: Bug fixes (X.Y.Z)

EOF
}

# Parse command-line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                BUMP_TYPE="$2"
                shift 2
                ;;
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --prerelease)
                PRERELEASE_ID="$2"
                shift 2
                ;;
            --auto-commit)
                AUTO_COMMIT=true
                shift
                ;;
            --yes|-y)
                INTERACTIVE=false
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

# Validate bump type
validate_bump_type() {
    case "$BUMP_TYPE" in
        auto|major|minor|patch|premajor|preminor|prepatch|prerelease)
            return 0
            ;;
        *)
            print_error "Invalid bump type: $BUMP_TYPE"
            print_info "Valid types: auto, major, minor, patch, premajor, preminor, prepatch, prerelease"
            return 1
            ;;
    esac
}

# Main workflow
main() {
    parse_arguments "$@"
    
    # Validate inputs
    if ! validate_bump_type; then
        exit 1
    fi
    
    # Check target directory
    if [[ ! -d "$TARGET_DIR" ]]; then
        print_error "Target directory does not exist: $TARGET_DIR"
        exit 1
    fi
    
    cd "$TARGET_DIR" || exit 1
    
    print_header "Automated Project Version Bump"
    print_info "Target project: $(pwd)"
    print_info "Bump type: $BUMP_TYPE"
    [[ -n "$PRERELEASE_ID" ]] && print_info "Prerelease: $PRERELEASE_ID"
    echo ""
    
    # Get current version
    local current_version
    if ! current_version=$(get_current_version "$TARGET_DIR"); then
        print_error "Could not detect current version in project"
        print_info "Make sure package.json, pyproject.toml, Cargo.toml, or .workflow-config.yaml exists"
        exit 1
    fi
    
    print_info "Current version: ${CYAN}${current_version}${NC}"
    
    # Determine bump type if auto
    local final_bump_type="$BUMP_TYPE"
    if [[ "$BUMP_TYPE" == "auto" ]]; then
        echo ""
        print_info "Analyzing changes to determine bump type..."
        
        # Try AI first if available
        if check_copilot_available && [[ "$INTERACTIVE" == true ]]; then
            print_info "Using AI to analyze changes..."
            
            # Build analysis prompt
            local git_stats
            git_stats=$(git diff --cached --shortstat 2>/dev/null || git diff --shortstat 2>/dev/null || echo "No changes")
            
            local changed_files
            changed_files=$(git diff --name-only 2>/dev/null | head -20 | paste -sd, -)
            
            local recent_commits
            recent_commits=$(git log --oneline -10 2>/dev/null || echo "No recent commits")
            
            local ai_prompt="You are a semantic versioning expert. Analyze these changes and recommend a version bump type.

## Git Statistics
${git_stats}

## Changed Files
${changed_files}

## Recent Commits
${recent_commits}

Based on semantic versioning rules:
- MAJOR (X.0.0): Breaking changes, removed features, incompatible API changes
- MINOR (X.Y.0): New features, enhancements, backward-compatible additions
- PATCH (X.Y.Z): Bug fixes, documentation, refactoring, performance improvements

Respond with ONLY: major, minor, or patch"
            
            local ai_response
            if ai_response=$(echo "$ai_prompt" | copilot -p 2>/dev/null); then
                final_bump_type=$(echo "$ai_response" | grep -oE "(major|minor|patch)" | head -1)
                if [[ -n "$final_bump_type" ]]; then
                    print_success "AI recommends: ${GREEN}${final_bump_type}${NC}"
                else
                    print_warning "Could not parse AI response, using heuristics"
                    final_bump_type=$(determine_bump_type_from_git "$TARGET_DIR")
                fi
            else
                print_warning "AI unavailable, using heuristics"
                final_bump_type=$(determine_bump_type_from_git "$TARGET_DIR")
            fi
        else
            final_bump_type=$(determine_bump_type_from_git "$TARGET_DIR")
            print_info "Heuristic recommends: ${CYAN}${final_bump_type}${NC}"
        fi
    fi
    
    # Calculate new version
    local new_version
    new_version=$(calculate_new_version "$current_version" "$final_bump_type" "$PRERELEASE_ID")
    
    echo ""
    print_info "Version change: ${CYAN}${current_version}${NC} → ${GREEN}${new_version}${NC}"
    print_info "Bump type: ${YELLOW}${final_bump_type}${NC}"
    echo ""
    
    # Confirm if interactive
    if [[ "$INTERACTIVE" == true ]]; then
        read -p "$(echo -e "${YELLOW}Proceed with version bump? [y/N]:${NC} ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Version bump cancelled"
            exit 0
        fi
    fi
    
    # Perform version bump
    print_info "Bumping version..."
    if ! automated_version_bump "$final_bump_type" "$TARGET_DIR" "$AUTO_COMMIT" "$PRERELEASE_ID"; then
        print_error "Version bump failed"
        exit 1
    fi
    
    # Success
    echo ""
    print_success "✅ Version bumped successfully: ${current_version} → ${new_version}"
    
    if [[ "$AUTO_COMMIT" == true ]]; then
        print_success "✅ Changes committed to git"
    else
        print_info "💡 Changes not committed. Run 'git add' and 'git commit' to save."
    fi
    
    # Show what changed
    echo ""
    print_info "Modified files:"
    git diff --name-only 2>/dev/null | grep -E "package\.json|pyproject\.toml|Cargo\.toml|\.workflow-config\.yaml" | while read -r file; do
        echo "  - $file"
    done
    
    echo ""
    print_success "Done!"
}

################################################################################
# Entry Point
################################################################################

main "$@"
