#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Version Validation Module
# Purpose: Validate version bump for deployment readiness (optional check)
# Part of: Step 11 - Deployment Readiness Gate
################################################################################

# ==============================================================================
# VERSION BUMP VALIDATION
# ==============================================================================

# Check if version was bumped since last tag
# Returns: 0 if version bumped, 1 if no bump detected
check_version_bump() {
    # Detect version files based on project type
    local version_files=()
    
    # Node.js
    [[ -f "${PROJECT_ROOT}/package.json" ]] && version_files+=("${PROJECT_ROOT}/package.json")
    
    # Python
    [[ -f "${PROJECT_ROOT}/setup.py" ]] && version_files+=("${PROJECT_ROOT}/setup.py")
    [[ -f "${PROJECT_ROOT}/pyproject.toml" ]] && version_files+=("${PROJECT_ROOT}/pyproject.toml")
    [[ -f "${PROJECT_ROOT}/__version__.py" ]] && version_files+=("${PROJECT_ROOT}/__version__.py")
    
    # Ruby
    [[ -f "${PROJECT_ROOT}/Gemfile" ]] && version_files+=("${PROJECT_ROOT}/Gemfile")
    
    # Go
    [[ -f "${PROJECT_ROOT}/go.mod" ]] && version_files+=("${PROJECT_ROOT}/go.mod")
    
    # Generic version files
    [[ -f "${PROJECT_ROOT}/VERSION" ]] && version_files+=("${PROJECT_ROOT}/VERSION")
    [[ -f "${PROJECT_ROOT}/version.txt" ]] && version_files+=("${PROJECT_ROOT}/version.txt")
    
    # If no version files found, check for version in source code
    if [[ ${#version_files[@]} -eq 0 ]]; then
        print_warning "No standard version files detected"
        return 1
    fi
    
    # Get current version from files
    local current_version=""
    current_version=$(extract_current_version "${version_files[0]}")
    
    if [[ -z "$current_version" ]]; then
        print_warning "Could not extract current version"
        return 1
    fi
    
    # Get last git tag
    local last_tag
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    if [[ -z "$last_tag" ]]; then
        # No tags exist - check if version file was modified
        if check_version_file_modified "${version_files[@]}"; then
            return 0
        else
            print_warning "No git tags found and version file not recently modified"
            return 1
        fi
    fi
    
    # Compare current version with last tag
    local tag_version
    tag_version=$(echo "$last_tag" | sed 's/^v//; s/^V//')
    
    if [[ "$current_version" != "$tag_version" ]]; then
        return 0
    fi
    
    # Version matches last tag - check if version file was modified after tag
    if check_version_file_modified_since_tag "$last_tag" "${version_files[@]}"; then
        return 0
    fi
    
    print_warning "Version ($current_version) matches last tag ($last_tag)"
    return 1
}

# Extract current version from version file
# Args: $1 = version file path
# Returns: Version string
extract_current_version() {
    local version_file="$1"
    local version=""
    
    case "$(basename "$version_file")" in
        package.json)
            version=$(grep -oP '"version"\s*:\s*"\K[^"]+' "$version_file" 2>/dev/null || echo "")
            ;;
        setup.py)
            version=$(grep -oP 'version\s*=\s*["\x27]\K[^"\x27]+' "$version_file" 2>/dev/null || echo "")
            ;;
        pyproject.toml)
            version=$(grep -oP '^version\s*=\s*["\x27]\K[^"\x27]+' "$version_file" 2>/dev/null || echo "")
            ;;
        VERSION|version.txt)
            version=$(cat "$version_file" 2>/dev/null | tr -d '[:space:]' || echo "")
            ;;
        *)
            # Try generic pattern
            version=$(grep -oP '[0-9]+\.[0-9]+\.[0-9]+' "$version_file" 2>/dev/null | head -1 || echo "")
            ;;
    esac
    
    echo "$version"
}

# Check if version file was modified recently
# Args: $@ = version file paths
# Returns: 0 if modified, 1 if not
check_version_file_modified() {
    local version_files=("$@")
    
    for file in "${version_files[@]}"; do
        # Check git status
        if git diff --name-only HEAD 2>/dev/null | grep -q "$(basename "$file")"; then
            return 0
        fi
        
        # Check staged changes
        if git diff --cached --name-only 2>/dev/null | grep -q "$(basename "$file")"; then
            return 0
        fi
        
        # Check modification time (within last 7 days)
        if [[ -f "$file" ]]; then
            local mtime
            mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo "0")
            local now
            now=$(date +%s)
            local days_old=$(( (now - mtime) / 86400 ))
            
            if [[ $days_old -le 7 ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

# Check if version file was modified since last tag
# Args: $1 = tag name, $@ = version file paths
# Returns: 0 if modified since tag, 1 if not
check_version_file_modified_since_tag() {
    local tag="$1"
    shift
    local version_files=("$@")
    
    for file in "${version_files[@]}"; do
        local changes
        changes=$(git diff "$tag" HEAD -- "$file" 2>/dev/null | wc -l)
        
        if [[ $changes -gt 0 ]]; then
            return 0
        fi
    done
    
    return 1
}

# Get version information summary
# Returns: Multi-line string with version details
get_version_info() {
    local info=""
    
    # Current version from package.json
    if [[ -f "${PROJECT_ROOT}/package.json" ]]; then
        local version
        version=$(extract_current_version "${PROJECT_ROOT}/package.json")
        info+="Current version (package.json): ${version}\n"
    fi
    
    # Last git tag
    local last_tag
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
    info+="Last git tag: ${last_tag}\n"
    
    # Commits since last tag
    if [[ "$last_tag" != "none" ]]; then
        local commits_since
        commits_since=$(git rev-list ${last_tag}..HEAD --count 2>/dev/null || echo "0")
        info+="Commits since last tag: ${commits_since}\n"
    fi
    
    echo -e "$info"
}

# Export functions
export -f check_version_bump extract_current_version check_version_file_modified
export -f check_version_file_modified_since_tag get_version_info
