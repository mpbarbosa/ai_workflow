#!/bin/bash
################################################################################
# Step 11.7: Front-End Development Analysis
# Purpose: Analyze front-end code for technical implementation, performance, and architecture
# Part of: Tests & Documentation Workflow Automation v4.0.1
# Version: 1.0.4
# Scope: Only runs for projects with front-end components (React, Vue, Angular, Svelte, etc.)
# AI Persona: front_end_developer_prompt
################################################################################

# Only set strict error handling if not in test mode
if [[ "${BASH_SOURCE[0]}" != *"test"* ]] && [[ -z "${TEST_MODE:-}" ]]; then
    set -euo pipefail
fi

# Module version information
readonly STEP11_7_VERSION="1.0.4"
readonly STEP11_7_VERSION_MAJOR=1
readonly STEP11_7_VERSION_MINOR=0
readonly STEP11_7_VERSION_PATCH=0

# Determine script directory and project root
STEP11_7_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP11_7_DIR}/../lib"

# Source required dependencies if not already loaded
if ! type -t print_info &>/dev/null; then
    # shellcheck source=../lib/colors.sh
    source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
    # shellcheck source=../lib/utils.sh
    source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
fi

# Source AI helpers for prompt building and execution
if ! type -t execute_copilot_prompt &>/dev/null; then
    # shellcheck source=../lib/ai_helpers.sh
    source "${WORKFLOW_LIB_DIR}/ai_helpers.sh" 2>/dev/null || true
fi

# Define fallback functions if still not available (for standalone usage)
if ! type -t print_info &>/dev/null; then
    print_info() { echo "ℹ️  $1"; }
    print_success() { echo "✅ $1"; }
    print_warning() { echo "⚠️  WARNING: $1"; }
    print_error() { echo "❌ ERROR: $1" >&2; }
fi

# ==============================================================================
# FRONT-END DETECTION FUNCTIONS
# ==============================================================================

# Check if project has front-end code
# Returns: 0 if front-end detected, 1 otherwise
has_frontend_code() {
    local project_kind="${PROJECT_KIND:-unknown}"
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    # Normalize project_kind: convert hyphens to underscores for consistent matching
    project_kind="${project_kind//-/_}"
    
    print_info "Detecting front-end code in project kind: $project_kind"
    
    # Check project kind first (known front-end projects)
    case "$project_kind" in
        react_spa|vue_spa|client_spa|static_website|web_application)
            print_info "Project kind '$project_kind' is front-end focused"
            return 0
            ;;
        shell_automation|nodejs_library|python_library|python_cli)
            print_info "Project kind '$project_kind' typically has no front-end code"
            return 1
            ;;
    esac
    
    # For other project kinds, detect front-end by file patterns
    print_info "Detecting front-end code by file patterns..."
    
    # Check for React/JSX/TSX files
    if find "$target_dir" -type f \( -name "*.jsx" -o -name "*.tsx" \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
        ! -path "*/build/*" 2>/dev/null | grep -q .; then
        print_info "React/JSX/TSX components detected"
        return 0
    fi
    
    # Check for Vue files
    if find "$target_dir" -type f -name "*.vue" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | grep -q .; then
        print_info "Vue components detected"
        return 0
    fi
    
    # Check for Angular
    if [[ -f "${target_dir}/angular.json" ]]; then
        print_info "Angular project detected"
        return 0
    fi
    
    # Check for Svelte
    if find "$target_dir" -type f -name "*.svelte" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | grep -q .; then
        print_info "Svelte components detected"
        return 0
    fi
    
    # Check for front-end frameworks in package.json
    if [[ -f "${target_dir}/package.json" ]]; then
        if grep -qE '"(react|vue|angular|svelte|preact|lit|solid-js)"' "${target_dir}/package.json"; then
            print_info "Front-end framework detected in package.json"
            return 0
        fi
    fi
    
    # Check for significant CSS/HTML (static website)
    local html_count css_count
    html_count=$(find "$target_dir" -type f -name "*.html" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
        ! -path "*/build/*" 2>/dev/null | wc -l)
    css_count=$(find "$target_dir" -type f -name "*.css" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
        ! -path "*/build/*" 2>/dev/null | wc -l)
    
    if [[ $html_count -gt 2 ]] && [[ $css_count -gt 1 ]]; then
        print_info "Static website detected (${html_count} HTML, ${css_count} CSS files)"
        return 0
    fi
    
    print_info "No front-end code detected"
    return 1
}

# Check if this step should run based on project configuration
# Returns: 0 if should run, 1 if should skip
should_run_frontend_dev_step() {
    local project_kind="${PROJECT_KIND:-unknown}"
    local step_relevance=""
    
    # Check step relevance configuration
    if command -v get_step_relevance &>/dev/null; then
        step_relevance=$(get_step_relevance "$project_kind" "step_11_7_frontend_dev" 2>/dev/null || echo "optional")
    else
        step_relevance="optional"
    fi
    
    print_info "Step 11.7 relevance for '$project_kind': $step_relevance"
    
    # Skip if explicitly marked as skip
    if [[ "$step_relevance" == "skip" ]]; then
        print_info "Step 11.7 skipped (marked as skip for this project kind)"
        return 1
    fi
    
    # Check for front-end code
    if has_frontend_code; then
        print_success "Front-End Development Analysis will run - front-end code detected"
        return 0
    else
        print_info "Front-End Development Analysis skipped - no front-end code detected"
        return 1
    fi
}

# ==============================================================================
# FRONT-END FILE DISCOVERY
# ==============================================================================

# Find front-end related files in the project
# Returns: List of front-end files (one per line)
find_frontend_files() {
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    local frontend_files=()
    
    print_info "Discovering front-end files..."
    
    # Find React/JSX/TSX files
    while IFS= read -r -d '' file; do
        frontend_files+=("$file")
    done < <(find "$target_dir" -type f \( -name "*.jsx" -o -name "*.tsx" \) \
             ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
             ! -path "*/build/*" -print0 2>/dev/null || true)
    
    # Find Vue files
    while IFS= read -r -d '' file; do
        frontend_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.vue" \
             ! -path "*/node_modules/*" ! -path "*/.git/*" -print0 2>/dev/null || true)
    
    # Find Svelte files
    while IFS= read -r -d '' file; do
        frontend_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.svelte" \
             ! -path "*/node_modules/*" ! -path "*/.git/*" -print0 2>/dev/null || true)
    
    # Find JavaScript files in src/components or similar
    while IFS= read -r -d '' file; do
        frontend_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.js" \
             \( -path "*/src/components/*" -o -path "*/components/*" -o -path "*/src/pages/*" \) \
             ! -path "*/node_modules/*" ! -path "*/.git/*" -print0 2>/dev/null || true)
    
    # Find TypeScript files in src/components or similar
    while IFS= read -r -d '' file; do
        frontend_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.ts" \
             \( -path "*/src/components/*" -o -path "*/components/*" -o -path "*/src/pages/*" \) \
             ! -path "*/node_modules/*" ! -path "*/.git/*" ! -name "*.d.ts" -print0 2>/dev/null || true)
    
    # Print files (limit to first 100 for performance)
    printf '%s\n' "${frontend_files[@]}" | head -100
}

# ==============================================================================
# FRONT-END CODE ANALYSIS
# ==============================================================================

# Analyze front-end code structure
# Returns: JSON object with analysis summary
analyze_frontend_structure() {
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    print_info "Analyzing front-end code structure..."
    
    # Count files by type
    local jsx_count tsx_count vue_count svelte_count css_count
    jsx_count=$(find "$target_dir" -name "*.jsx" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    tsx_count=$(find "$target_dir" -name "*.tsx" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    vue_count=$(find "$target_dir" -name "*.vue" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    svelte_count=$(find "$target_dir" -name "*.svelte" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    css_count=$(find "$target_dir" -name "*.css" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    
    # Detect framework
    local framework="Unknown"
    if [[ $tsx_count -gt 0 ]] || [[ $jsx_count -gt 0 ]]; then
        framework="React"
    elif [[ $vue_count -gt 0 ]]; then
        framework="Vue"
    elif [[ $svelte_count -gt 0 ]]; then
        framework="Svelte"
    elif [[ -f "${target_dir}/angular.json" ]]; then
        framework="Angular"
    fi
    
    # Detect build tools
    local build_tool="Unknown"
    if [[ -f "${target_dir}/vite.config.js" ]] || [[ -f "${target_dir}/vite.config.ts" ]]; then
        build_tool="Vite"
    elif [[ -f "${target_dir}/webpack.config.js" ]]; then
        build_tool="Webpack"
    elif grep -q '"create-react-app"' "${target_dir}/package.json" 2>/dev/null; then
        build_tool="Create React App"
    elif [[ -f "${target_dir}/next.config.js" ]]; then
        build_tool="Next.js"
    fi
    
    # Detect state management
    local state_mgmt="Unknown"
    if [[ -f "${target_dir}/package.json" ]]; then
        if grep -q '"redux"' "${target_dir}/package.json"; then
            state_mgmt="Redux"
        elif grep -q '"zustand"' "${target_dir}/package.json"; then
            state_mgmt="Zustand"
        elif grep -q '"jotai"' "${target_dir}/package.json"; then
            state_mgmt="Jotai"
        elif grep -q '"recoil"' "${target_dir}/package.json"; then
            state_mgmt="Recoil"
        elif grep -q '"vuex"' "${target_dir}/package.json"; then
            state_mgmt="Vuex"
        elif grep -q '"pinia"' "${target_dir}/package.json"; then
            state_mgmt="Pinia"
        fi
    fi
    
    # Output summary
    cat << EOF
{
  "framework": "$framework",
  "build_tool": "$build_tool",
  "state_management": "$state_mgmt",
  "component_counts": {
    "jsx": $jsx_count,
    "tsx": $tsx_count,
    "vue": $vue_count,
    "svelte": $svelte_count
  },
  "css_files": $css_count
}
EOF
}

# ==============================================================================
# AI-POWERED FRONT-END ANALYSIS
# ==============================================================================

# Build front-end development prompt
# Usage: build_frontend_dev_prompt <frontend_files> <structure_analysis>
build_frontend_dev_prompt() {
    local frontend_files="$1"
    local structure_analysis="$2"
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    local project_kind="${PROJECT_KIND:-unknown}"
    
    print_info "Building front-end development analysis prompt..."
    
    # Extract framework from structure analysis
    local framework
    framework=$(echo "$structure_analysis" | grep -o '"framework": "[^"]*"' | cut -d'"' -f4)
    
    # Count files
    local file_count
    file_count=$(echo "$frontend_files" | wc -l)
    
    # Get recent changes if available
    local recent_changes="No recent changes detected"
    if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
        recent_changes=$(git diff --name-only HEAD~1..HEAD 2>/dev/null | grep -E '\.(jsx|tsx|vue|svelte|js|ts|css)$' | head -20 || echo "No recent changes")
    fi
    
    # Build the prompt
    cat << EOF
**Role**: Senior Front-End Developer (Technical Implementation Focus)

**Context**: Analyze front-end code for technical implementation quality, performance, and architecture.

**Project Information**:
- Project Type: ${project_kind}
- Framework: ${framework}
- Target Directory: ${target_dir}
- Front-End Files Found: ${file_count}

**Structure Analysis**:
${structure_analysis}

**Recent Changes**:
${recent_changes}

**Files to Analyze** (sample):
${frontend_files}

**YOUR ANALYSIS SHOULD COVER**:

1. **Component Architecture**
   - Component composition and reusability
   - Props drilling and component coupling
   - Component size and complexity
   - Shared component opportunities

2. **Code Quality**
   - Type safety (TypeScript usage, prop types)
   - Error boundary implementation
   - Code organization and file structure
   - Naming conventions and consistency

3. **Performance**
   - Unnecessary re-renders
   - Code splitting and lazy loading
   - Bundle size optimization
   - Memoization opportunities (useMemo, React.memo, etc.)

4. **State Management**
   - State architecture patterns
   - Local vs global state decisions
   - State update patterns
   - Side effect handling

5. **Accessibility Implementation**
   - ARIA attributes usage
   - Semantic HTML structure
   - Keyboard navigation support
   - Focus management

6. **Testing**
   - Test coverage for components
   - Testing patterns (unit, integration, e2e)
   - Mock/stub strategies
   - Test maintainability

7. **Build Configuration**
   - Build tool optimization
   - Environment configuration
   - Asset optimization
   - Source maps and debugging

8. **Best Practices**
   - Framework-specific patterns
   - Modern JavaScript/TypeScript features
   - Security considerations
   - Cross-browser compatibility

**OUTPUT FORMAT**:

# Front-End Development Analysis Report

## Executive Summary
[Brief overview with priority counts: X critical issues, Y improvements, Z optimizations]

## Critical Issues
[Issues that must be addressed - bugs, security, major performance problems]

## Architecture & Design
[Component structure, patterns, organization]

## Performance Optimizations
[Specific optimizations with impact estimates]

## Code Quality Improvements
[Refactoring opportunities, type safety, testing]

## Accessibility Enhancements
[WCAG compliance, keyboard navigation, screen reader support]

## Recommendations
[Prioritized action items with implementation guidance]

**Focus on technical implementation quality - NOT visual design or user experience** (that's handled by Step 15: UX Analysis).
EOF
}

# Execute front-end development analysis with AI
# Usage: run_frontend_dev_analysis <frontend_files> <structure_analysis>
run_frontend_dev_analysis() {
    local frontend_files="$1"
    local structure_analysis="$2"
    
    print_info "Preparing front-end development analysis..."
    
    # Build prompt
    local prompt
    prompt=$(build_frontend_dev_prompt "$frontend_files" "$structure_analysis")
    
    # Create log file
    local log_timestamp
    log_timestamp=$(date +%Y%m%d_%H%M%S)
    local log_file="${LOGS_RUN_DIR:-./logs}/step11_7_frontend_dev_${log_timestamp}.log"
    
    # Display prompt preview
    echo ""
    echo -e "${CYAN}Front-End Development Analysis Prompt Preview:${NC}"
    echo -e "${YELLOW}Framework: $(echo "$structure_analysis" | grep -o '"framework": "[^"]*"' | cut -d'"' -f4)${NC}"
    echo -e "${YELLOW}Files to analyze: $(echo "$frontend_files" | wc -l)${NC}\n"
    
    # Check dry run
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        print_info "[DRY RUN] Would invoke Copilot with front-end development analysis prompt"
        print_info "[DRY RUN] Prompt saved to: $log_file"
        echo "$prompt" > "$log_file"
        return 0
    fi
    
    # Confirm execution
    if ! confirm_action "Run AI-powered front-end development analysis?" "y"; then
        print_warning "Skipped front-end development analysis"
        return 1
    fi
    
    # Execute with AI
    print_info "Starting AI front-end development analysis..."
    print_info "Logging output to: $log_file"
    
    if command -v execute_copilot_prompt &>/dev/null; then
        # Use modern AI helpers approach
        execute_copilot_prompt "$prompt" "$log_file" "step11_7" "front_end_developer"
    else
        # Fallback: direct Copilot CLI execution
        print_warning "execute_copilot_prompt not found, using fallback"
        copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee "$log_file"
    fi
    
    print_success "Front-end development analysis completed"
    print_info "Full analysis log saved to: $log_file"
    
    # Extract issues if helper available
    if command -v extract_and_save_issues_from_log &>/dev/null; then
        extract_and_save_issues_from_log "11.7" "Frontend_Dev" "$log_file"
    fi
    
    return 0
}

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main step function for front-end development analysis
# Returns: 0 for success (including skip), 1 for failure
step11_7_frontend_dev_analysis() {
    print_step "11.7" "Front-End Development Analysis"
    
    # Check if step should run
    if ! should_run_frontend_dev_step; then
        print_info "Step 11.7: Front-End Development Analysis - SKIPPED (no front-end code)"
        return 0
    fi
    
    # Find front-end files
    print_info "Phase 1: Discovering front-end files..."
    local frontend_files
    frontend_files=$(find_frontend_files)
    
    if [[ -z "$frontend_files" ]]; then
        print_warning "No front-end files found to analyze"
        return 0
    fi
    
    local file_count
    file_count=$(echo "$frontend_files" | wc -l)
    print_success "Found ${file_count} front-end files to analyze"
    
    # Analyze structure
    print_info "Phase 2: Analyzing front-end code structure..."
    local structure_analysis
    structure_analysis=$(analyze_frontend_structure)
    
    print_info "Structure Analysis:"
    echo "$structure_analysis" | grep -E '"(framework|build_tool|state_management)"' | sed 's/^/  /'
    
    # Run AI analysis
    print_info "Phase 3: Running AI-powered front-end development analysis..."
    if run_frontend_dev_analysis "$frontend_files" "$structure_analysis"; then
        print_success "Step 11.7: Front-End Development Analysis - COMPLETED"
        return 0
    else
        print_warning "Step 11.7: Front-End Development Analysis - SKIPPED by user"
        return 0
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f has_frontend_code
export -f should_run_frontend_dev_step
export -f find_frontend_files
export -f analyze_frontend_structure
export -f build_frontend_dev_prompt
export -f run_frontend_dev_analysis
export -f step11_7_frontend_dev_analysis

# ==============================================================================
# VERSION INFORMATION
# ==============================================================================

step11_7_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP11_7_VERSION"
            ;;
        semver)
            echo "${STEP11_7_VERSION_MAJOR}.${STEP11_7_VERSION_MINOR}.${STEP11_7_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 11.7: Front-End Development Analysis v${STEP11_7_VERSION}"
            echo "  AI Persona: front_end_developer_prompt"
            echo "  Scope: React, Vue, Angular, Svelte, and static websites"
            ;;
    esac
}

export -f step11_7_get_version

# Execute main function if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    step11_7_frontend_dev_analysis
fi
