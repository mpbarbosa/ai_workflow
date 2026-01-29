#!/usr/bin/env bash
################################################################################
# Version Bump Library
# Purpose: Automated semantic version bumping for target projects
# Part of: AI Workflow Automation v3.0.0
# Version: 1.0.0
################################################################################

set -euo pipefail

# Module version (only declare if not already set)
if [[ -z "${VERSION_BUMP_VERSION:-}" ]]; then
    readonly VERSION_BUMP_VERSION="1.0.0"
fi

################################################################################
# Core Functions
################################################################################

# Detect project type and available version management tools
# Returns: package_manager (npm|yarn|poetry|cargo|go|manual)
detect_version_tool() {
    local project_root="${1:-.}"
    
    # Node.js projects
    if [[ -f "$project_root/package.json" ]]; then
        if command -v npm &>/dev/null; then
            echo "npm"
            return 0
        elif command -v yarn &>/dev/null; then
            echo "yarn"
            return 0
        fi
    fi
    
    # Python projects
    if [[ -f "$project_root/pyproject.toml" ]]; then
        if command -v poetry &>/dev/null; then
            echo "poetry"
            return 0
        fi
    fi
    
    # Rust projects
    if [[ -f "$project_root/Cargo.toml" ]]; then
        if command -v cargo &>/dev/null; then
            echo "cargo"
            return 0
        fi
    fi
    
    # Go projects
    if [[ -f "$project_root/go.mod" ]]; then
        echo "go"
        return 0
    fi
    
    # Fallback to manual
    echo "manual"
}

# Get current project version
# Args: $1 - project root path
# Returns: current version string
get_current_version() {
    local project_root="${1:-.}"
    local version=""
    
    # Try package.json (Node.js)
    if [[ -f "$project_root/package.json" ]]; then
        version=$(grep '"version"' "$project_root/package.json" | head -1 | sed 's/.*"version"[^"]*"\([^"]*\)".*/\1/')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Try pyproject.toml (Python)
    if [[ -f "$project_root/pyproject.toml" ]]; then
        version=$(grep '^version' "$project_root/pyproject.toml" | head -1 | sed 's/.*version[^"]*"\([^"]*\)".*/\1/')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Try Cargo.toml (Rust)
    if [[ -f "$project_root/Cargo.toml" ]]; then
        version=$(grep '^version' "$project_root/Cargo.toml" | head -1 | sed 's/.*version[^"]*"\([^"]*\)".*/\1/')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi
    
    # Try .workflow-config.yaml
    if [[ -f "$project_root/.workflow-config.yaml" ]]; then
        if command -v yq &>/dev/null; then
            version=$(yq '.project.version' "$project_root/.workflow-config.yaml" 2>/dev/null || yq e '.project.version' "$project_root/.workflow-config.yaml" 2>/dev/null)
            if [[ -n "$version" && "$version" != "null" ]]; then
                echo "$version"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Bump version using appropriate tool
# Args: $1 - bump type (major|minor|patch|premajor|preminor|prepatch|prerelease)
#       $2 - project root path
#       $3 - pre-release identifier (optional, e.g., "alpha", "beta")
# Returns: 0 on success, 1 on failure
bump_version_with_tool() {
    local bump_type="$1"
    local project_root="${2:-.}"
    local prerelease_id="${3:-}"
    local tool
    tool=$(detect_version_tool "$project_root")
    
    cd "$project_root" || return 1
    
    case "$tool" in
        npm)
            print_info "Using npm to bump version: $bump_type"
            if [[ -n "$prerelease_id" ]]; then
                npm version "$bump_type" --preid="$prerelease_id" --no-git-tag-version
            else
                npm version "$bump_type" --no-git-tag-version
            fi
            ;;
        yarn)
            print_info "Using yarn to bump version: $bump_type"
            if [[ -n "$prerelease_id" ]]; then
                yarn version --"$bump_type" --preid "$prerelease_id" --no-git-tag-version
            else
                yarn version --"$bump_type" --no-git-tag-version
            fi
            ;;
        poetry)
            print_info "Using poetry to bump version: $bump_type"
            poetry version "$bump_type"
            ;;
        cargo)
            print_info "Using cargo to bump version: $bump_type"
            # cargo doesn't have built-in version bump, use manual
            local current_version new_version
            current_version=$(get_current_version "$project_root")
            new_version=$(calculate_new_version "$current_version" "$bump_type" "$prerelease_id")
            sed -i "s/^version = \"${current_version}\"/version = \"${new_version}\"/" Cargo.toml
            ;;
        go)
            print_warning "Go modules don't have version in go.mod. Skipping version bump."
            return 0
            ;;
        manual)
            print_info "Using manual version bump: $bump_type"
            local current_version new_version
            current_version=$(get_current_version "$project_root")
            new_version=$(calculate_new_version "$current_version" "$bump_type" "$prerelease_id")
            manual_version_update "$project_root" "$current_version" "$new_version"
            ;;
        *)
            print_error "Unknown version tool: $tool"
            return 1
            ;;
    esac
    
    return 0
}

# Calculate new version from current version and bump type
# Args: $1 - current version
#       $2 - bump type (major|minor|patch)
#       $3 - prerelease identifier (optional)
# Returns: new version string
calculate_new_version() {
    local current="$1"
    local bump_type="$2"
    local prerelease_id="${3:-}"
    
    # Strip prerelease suffix if exists
    local base_version="${current%%-*}"
    local major minor patch
    IFS='.' read -r major minor patch <<< "$base_version"
    
    # Remove any non-numeric suffix from patch
    patch="${patch%%[^0-9]*}"
    
    case "$bump_type" in
        major|premajor)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor|preminor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch|prepatch|prerelease)
            patch=$((patch + 1))
            ;;
        *)
            echo "$current"
            return 0
            ;;
    esac
    
    local new_version="${major}.${minor}.${patch}"
    
    # Add prerelease identifier if specified
    if [[ -n "$prerelease_id" ]]; then
        new_version="${new_version}-${prerelease_id}"
    fi
    
    echo "$new_version"
}

# Manually update version in common files
# Args: $1 - project root
#       $2 - old version
#       $3 - new version
manual_version_update() {
    local project_root="$1"
    local old_version="$2"
    local new_version="$3"
    local updated=false
    
    # Update package.json
    if [[ -f "$project_root/package.json" ]]; then
        sed -i "s/\"version\": \"${old_version}\"/\"version\": \"${new_version}\"/" "$project_root/package.json"
        print_success "Updated package.json"
        updated=true
    fi
    
    # Update pyproject.toml
    if [[ -f "$project_root/pyproject.toml" ]]; then
        sed -i "s/^version = \"${old_version}\"/version = \"${new_version}\"/" "$project_root/pyproject.toml"
        print_success "Updated pyproject.toml"
        updated=true
    fi
    
    # Update Cargo.toml
    if [[ -f "$project_root/Cargo.toml" ]]; then
        sed -i "s/^version = \"${old_version}\"/version = \"${new_version}\"/" "$project_root/Cargo.toml"
        print_success "Updated Cargo.toml"
        updated=true
    fi
    
    # Update .workflow-config.yaml
    if [[ -f "$project_root/.workflow-config.yaml" ]]; then
        if command -v yq &>/dev/null; then
            yq -i ".project.version = \"${new_version}\"" "$project_root/.workflow-config.yaml" 2>/dev/null || \
            yq e ".project.version = \"${new_version}\"" -i "$project_root/.workflow-config.yaml" 2>/dev/null
            print_success "Updated .workflow-config.yaml"
            updated=true
        fi
    fi
    
    [[ "$updated" == true ]] && return 0 || return 1
}

# Commit version bump changes
# Args: $1 - new version
#       $2 - project root
# Returns: 0 on success
commit_version_bump() {
    local new_version="$1"
    local project_root="${2:-.}"
    
    cd "$project_root" || return 1
    
    # Stage version files
    local version_files=()
    [[ -f "package.json" ]] && version_files+=("package.json")
    [[ -f "pyproject.toml" ]] && version_files+=("pyproject.toml")
    [[ -f "Cargo.toml" ]] && version_files+=("Cargo.toml")
    [[ -f "Cargo.lock" ]] && version_files+=("Cargo.lock")
    [[ -f ".workflow-config.yaml" ]] && version_files+=(".workflow-config.yaml")
    
    if [[ ${#version_files[@]} -eq 0 ]]; then
        print_warning "No version files to commit"
        return 1
    fi
    
    # Stage files
    git add "${version_files[@]}"
    
    # Commit
    git commit -m "chore: bump version to ${new_version}" --no-verify 2>/dev/null || {
        print_warning "Nothing to commit (version may already be updated)"
        return 0
    }
    
    print_success "Committed version bump: ${new_version}"
    return 0
}

# Main function: Automated version bump workflow
# Args: $1 - bump type (major|minor|patch|auto)
#       $2 - project root path
#       $3 - auto commit (true|false)
#       $4 - prerelease identifier (optional)
# Returns: 0 on success
automated_version_bump() {
    local bump_type="${1:-auto}"
    local project_root="${2:-.}"
    local auto_commit="${3:-false}"
    local prerelease_id="${4:-}"
    
    print_info "Starting automated version bump workflow..."
    print_info "Project: $project_root"
    print_info "Bump type: $bump_type"
    
    # Get current version
    local current_version
    if ! current_version=$(get_current_version "$project_root"); then
        print_error "Could not detect current version"
        return 1
    fi
    
    print_info "Current version: $current_version"
    
    # If auto, determine bump type using heuristics
    if [[ "$bump_type" == "auto" ]]; then
        print_info "Auto-detecting bump type from git changes..."
        bump_type=$(determine_bump_type_from_git "$project_root")
        print_info "Detected bump type: $bump_type"
    fi
    
    # Preserve existing prerelease identifier if not specified
    if [[ -z "$prerelease_id" && "$current_version" =~ -([a-z]+) ]]; then
        prerelease_id="${BASH_REMATCH[1]}"
        print_info "Preserving prerelease identifier: $prerelease_id"
    fi
    
    # Bump version
    if ! bump_version_with_tool "$bump_type" "$project_root" "$prerelease_id"; then
        print_error "Version bump failed"
        return 1
    fi
    
    # Get new version
    local new_version
    if ! new_version=$(get_current_version "$project_root"); then
        print_error "Could not detect new version after bump"
        return 1
    fi
    
    print_success "Version bumped: ${current_version} → ${new_version}"
    
    # Auto commit if requested
    if [[ "$auto_commit" == "true" ]]; then
        print_info "Auto-committing version bump..."
        commit_version_bump "$new_version" "$project_root"
    fi
    
    return 0
}

# Determine bump type from git changes (heuristic)
# Args: $1 - project root
# Returns: major|minor|patch
determine_bump_type_from_git() {
    local project_root="${1:-.}"
    
    cd "$project_root" || return 1
    
    # Get git statistics
    local stats
    stats=$(git diff --cached --shortstat 2>/dev/null || git diff --shortstat 2>/dev/null || echo "")
    
    local insertions deletions
    insertions=$(echo "$stats" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    deletions=$(echo "$stats" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    
    # Get file count
    local modified_count
    modified_count=$(git diff --name-only 2>/dev/null | wc -l)
    
    # Check commit messages for conventional commits
    local recent_commits
    recent_commits=$(git log --oneline -10 2>/dev/null || echo "")
    
    # Major: Breaking changes or many files
    if echo "$recent_commits" | grep -qi "BREAKING CHANGE\|breaking:" || \
       [[ $deletions -gt 500 ]] || [[ $modified_count -gt 20 ]]; then
        echo "major"
        return 0
    fi
    
    # Minor: New features or significant additions
    if echo "$recent_commits" | grep -qi "^feat\|feature:" || \
       [[ $insertions -gt 100 ]]; then
        echo "minor"
        return 0
    fi
    
    # Patch: Bug fixes, docs, tests
    echo "patch"
}

################################################################################
# Export Functions
################################################################################

export -f detect_version_tool
export -f get_current_version
export -f bump_version_with_tool
export -f calculate_new_version
export -f manual_version_update
export -f commit_version_bump
export -f automated_version_bump
export -f determine_bump_type_from_git
