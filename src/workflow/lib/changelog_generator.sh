#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Enhanced Changelog Generator Module
# Version: 2.0.0
# Purpose: Advanced changelog generation from conventional commits
#
# Features:
#   - Conventional commit parsing (feat, fix, docs, style, refactor, etc.)
#   - Semantic versioning integration
#   - Breaking change detection
#   - Scope-based grouping
#   - Multi-language commit message support
#   - GitHub/GitLab issue linking
#   - Changelog validation and formatting
#   - Release notes generation
#
# Integration: Used by Step 16 (Version Update) and auto-documentation
################################################################################

# Set defaults
CHANGELOG_FILE="${PROJECT_ROOT:-$(pwd)}/CHANGELOG.md"
CHANGELOG_TEMPLATE="${WORKFLOW_HOME:-$(pwd)}/templates/CHANGELOG_TEMPLATE.md"

# Conventional commit types
declare -A COMMIT_TYPES=(
    ["feat"]="Added"
    ["fix"]="Fixed"
    ["docs"]="Documentation"
    ["style"]="Style"
    ["refactor"]="Changed"
    ["perf"]="Performance"
    ["test"]="Tests"
    ["build"]="Build"
    ["ci"]="CI/CD"
    ["chore"]="Maintenance"
    ["revert"]="Reverted"
)

# ==============================================================================
# COMMIT PARSING
# ==============================================================================

# Parse a conventional commit message
# Args: $1 = commit message
# Output: Format "type|scope|description|breaking|body"
parse_conventional_commit() {
    local commit="$1"
    
    # Pattern: type(scope)!: description
    # or: type: description
    # or: type!: description (breaking change)
    
    local type=""
    local scope=""
    local description=""
    local breaking="false"
    local body=""
    
    # Check for breaking change indicator
    if [[ "$commit" =~ ! ]]; then
        breaking="true"
    fi
    
    # Extract type and scope
    # Pattern: type(scope)!: description or type: description or type!: description
    local pattern1='^([a-z]+)[(]([^)]+)[)]!?:[[:space:]]*(.+)$'
    local pattern2='^([a-z]+)!?:[[:space:]]*(.+)$'
    
    if [[ "$commit" =~ $pattern1 ]]; then
        type="${BASH_REMATCH[1]}"
        scope="${BASH_REMATCH[2]}"
        description="${BASH_REMATCH[3]}"
    elif [[ "$commit" =~ $pattern2 ]]; then
        type="${BASH_REMATCH[1]}"
        description="${BASH_REMATCH[2]}"
    else
        # Non-conventional commit, treat as "other"
        type="other"
        description="$commit"
    fi
    
    # Check for breaking change in description
    if [[ "$description" =~ BREAKING[[:space:]]CHANGE ]]; then
        breaking="true"
    fi
    
    echo "${type}|${scope}|${description}|${breaking}|${body}"
}

# Parse all commits since a reference
# Args: $1 = since reference (tag, commit, or empty for all), $2 = until reference (default: HEAD)
# Output: Parsed commit data, one per line
parse_commits_since() {
    local since="${1:-}"
    local until="${2:-HEAD}"
    
    local git_range=""
    if [[ -n "$since" ]]; then
        git_range="${since}..${until}"
    else
        # Get last 50 commits if no reference
        git_range="${until}"
    fi
    
    # Get commits with full message
    git log "$git_range" --pretty=format:"%H%n%s%n%b%n---END---" 2>/dev/null | \
    awk -v RS="---END---" -v ORS="" '
        NF {
            # First line is hash, second is subject, rest is body
            split($0, lines, "\n")
            hash = lines[1]
            subject = lines[2]
            body = ""
            for (i=3; i<=length(lines); i++) {
                if (lines[i] != "") {
                    body = body lines[i] "\n"
                }
            }
            print subject "\n"
        }
    '
}

# ==============================================================================
# CHANGELOG GENERATION
# ==============================================================================

# Generate changelog section for a version
# Args: $1 = version, $2 = date, $3 = since reference
# Output: Changelog markdown section
generate_changelog_section() {
    local version="$1"
    local date="$2"
    local since="${3:-}"
    
    # Parse all commits
    declare -A sections
    sections["Added"]=""
    sections["Fixed"]=""
    sections["Changed"]=""
    sections["Removed"]=""
    sections["Deprecated"]=""
    sections["Security"]=""
    sections["Performance"]=""
    sections["Documentation"]=""
    sections["Tests"]=""
    sections["Build"]=""
    sections["CI/CD"]=""
    sections["Maintenance"]=""
    sections["Breaking Changes"]=""
    sections["Other"]=""
    
    while IFS= read -r commit_msg; do
        [[ -z "$commit_msg" ]] && continue
        
        # Parse commit
        local parsed=$(parse_conventional_commit "$commit_msg")
        IFS='|' read -r type scope description breaking body <<< "$parsed"
        
        # Determine section
        local section="${COMMIT_TYPES[$type]:-Other}"
        
        # Format entry
        local entry="- "
        [[ -n "$scope" ]] && entry+="**${scope}**: "
        entry+="${description}"
        
        # Add to appropriate section
        if [[ "$breaking" == "true" ]]; then
            sections["Breaking Changes"]+="${entry}"$'\n'
        fi
        
        sections["$section"]+="${entry}"$'\n'
    done < <(parse_commits_since "$since")
    
    # Generate output
    cat << EOF
## [${version}] - ${date}

EOF
    
    # Output sections in standard order
    local ordered_sections=(
        "Breaking Changes"
        "Added"
        "Changed"
        "Deprecated"
        "Removed"
        "Fixed"
        "Security"
        "Performance"
        "Documentation"
        "Tests"
        "Build"
        "CI/CD"
        "Maintenance"
    )
    
    for section in "${ordered_sections[@]}"; do
        if [[ -n "${sections[$section]}" ]]; then
            echo "### ${section}"
            echo ""
            echo "${sections[$section]}"
        fi
    done
    
    # Add other commits if any
    if [[ -n "${sections[Other]}" ]]; then
        echo "### Other Changes"
        echo ""
        echo "${sections[Other]}"
    fi
}

# Generate complete changelog
# Args: $1 = since tag (optional), $2 = version (optional), $3 = output file (optional)
generate_enhanced_changelog() {
    local since_tag="${1:-}"
    local version="${2:-}"
    local output_file="${3:-$CHANGELOG_FILE}"
    
    # Auto-detect version if not provided
    if [[ -z "$version" ]]; then
        if [[ -f "package.json" ]] && command -v jq &>/dev/null; then
            version=$(jq -r '.version // "unreleased"' package.json)
        elif [[ -f "setup.py" ]]; then
            version=$(grep -oP 'version\s*=\s*["\x27]\K[^"\x27]+' setup.py | head -1 || echo "unreleased")
        else
            version="${SCRIPT_VERSION:-unreleased}"
        fi
    fi
    
    # Auto-detect last tag if not provided
    if [[ -z "$since_tag" ]]; then
        since_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    fi
    
    local date=$(date '+%Y-%m-%d')
    
    # Check if changelog exists
    local existing_changelog=""
    if [[ -f "$output_file" ]]; then
        existing_changelog=$(cat "$output_file")
        # Backup existing changelog
        cp "$output_file" "${output_file}.backup"
    fi
    
    # Generate header
    cat > "$output_file" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
    
    # Generate new section
    generate_changelog_section "$version" "$date" "$since_tag" >> "$output_file"
    
    # Append existing entries (excluding header and current version)
    if [[ -n "$existing_changelog" ]]; then
        echo "" >> "$output_file"
        echo "$existing_changelog" | \
            sed -n '/^## \[/,$p' | \
            grep -v "^## \[${version}\]" || true
    fi
    
    print_success "Enhanced changelog generated: $output_file"
    return 0
}

# ==============================================================================
# CHANGELOG VALIDATION
# ==============================================================================

# Validate changelog format
# Args: $1 = changelog file path
# Returns: 0 if valid, 1 if invalid
validate_changelog() {
    local file="${1:-$CHANGELOG_FILE}"
    local errors=0
    
    [[ ! -f "$file" ]] && { print_error "Changelog file not found: $file"; return 1; }
    
    # Check for required header
    if ! grep -q "^# Changelog" "$file"; then
        print_error "Changelog missing required '# Changelog' header"
        ((errors++))
    fi
    
    # Check for Keep a Changelog reference
    if ! grep -q "Keep a Changelog" "$file"; then
        print_warning "Changelog should reference keepachangelog.com format"
    fi
    
    # Check for semantic versioning reference
    if ! grep -q "Semantic Versioning" "$file"; then
        print_warning "Changelog should reference semver.org"
    fi
    
    # Check for version sections
    if ! grep -q "^## \[" "$file"; then
        print_error "Changelog has no version sections"
        ((errors++))
    fi
    
    # Validate version format
    while IFS= read -r line; do
        if [[ "$line" =~ ^\#\#[[:space:]]\[([^]]+)\][[:space:]]-[[:space:]]([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
            local ver="${BASH_REMATCH[1]}"
            local date="${BASH_REMATCH[2]}"
            
            # Check semantic version format (allow "unreleased")
            if [[ "$ver" != "Unreleased" ]] && ! [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
                print_error "Invalid version format: $ver (should be X.Y.Z)"
                ((errors++))
            fi
            
            # Check date format
            if ! date -d "$date" &>/dev/null; then
                print_error "Invalid date format: $date (should be YYYY-MM-DD)"
                ((errors++))
            fi
        fi
    done < <(grep "^## \[" "$file")
    
    if [[ $errors -eq 0 ]]; then
        print_success "Changelog validation passed"
        return 0
    else
        print_error "Changelog validation failed with $errors errors"
        return 1
    fi
}

# ==============================================================================
# RELEASE NOTES GENERATION
# ==============================================================================

# Generate release notes from changelog
# Args: $1 = version, $2 = output file (optional)
generate_release_notes() {
    local version="$1"
    local output_file="${2:-}"
    
    [[ ! -f "$CHANGELOG_FILE" ]] && { print_error "Changelog not found"; return 1; }
    
    # Extract section for this version
    local release_notes=$(sed -n "/^## \[${version}\]/,/^## \[/p" "$CHANGELOG_FILE" | sed '$d')
    
    if [[ -z "$release_notes" ]]; then
        print_error "Version $version not found in changelog"
        return 1
    fi
    
    # Format for GitHub/GitLab releases
    local formatted_notes="# Release ${version}"$'\n\n'
    formatted_notes+="$release_notes"
    
    if [[ -n "$output_file" ]]; then
        echo "$formatted_notes" > "$output_file"
        print_success "Release notes generated: $output_file"
    else
        echo "$formatted_notes"
    fi
    
    return 0
}

# ==============================================================================
# INTEGRATION HELPERS
# ==============================================================================

# Update changelog before version bump
# Args: $1 = new version
update_changelog_for_release() {
    local new_version="$1"
    
    # Get last tag
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    # Generate changelog
    generate_enhanced_changelog "$last_tag" "$new_version"
    
    # Validate
    validate_changelog
    
    return 0
}

# Suggest next version based on commits
# Returns: suggested version (major.minor.patch)
suggest_next_version() {
    local current_version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")
    
    # Parse current version
    IFS='.' read -r major minor patch <<< "$current_version"
    
    # Check commits since last tag
    local has_breaking=false
    local has_features=false
    local has_fixes=false
    
    while IFS= read -r commit_msg; do
        local parsed=$(parse_conventional_commit "$commit_msg")
        IFS='|' read -r type scope description breaking body <<< "$parsed"
        
        [[ "$breaking" == "true" ]] && has_breaking=true
        [[ "$type" == "feat" ]] && has_features=true
        [[ "$type" == "fix" ]] && has_fixes=true
    done < <(parse_commits_since "v${current_version}")
    
    # Determine version bump
    if $has_breaking; then
        echo "$((major + 1)).0.0"
    elif $has_features; then
        echo "${major}.$((minor + 1)).0"
    elif $has_fixes; then
        echo "${major}.${minor}.$((patch + 1))"
    else
        echo "$current_version"
    fi
}

# Export functions
export -f parse_conventional_commit
export -f parse_commits_since
export -f generate_changelog_section
export -f generate_enhanced_changelog
export -f validate_changelog
export -f generate_release_notes
export -f update_changelog_for_release
export -f suggest_next_version
