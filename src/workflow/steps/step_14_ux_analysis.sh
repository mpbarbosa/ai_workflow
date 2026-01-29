#!/bin/bash
################################################################################
# Step 14: UX Analysis
# Purpose: Analyze UI code for bugs, usability issues, and suggest improvements
# Part of: Tests & Documentation Workflow Automation v3.0.0
# Version: 1.0.0
# Scope: Only runs for projects with UI components (web apps, SPAs, static sites)
################################################################################

# Only set strict error handling if not in test mode
if [[ "${BASH_SOURCE[0]}" != *"test"* ]] && [[ -z "${TEST_MODE:-}" ]]; then
    set -euo pipefail
fi

# Module version information
readonly STEP14_VERSION="1.0.0"
readonly STEP14_VERSION_MAJOR=1
readonly STEP14_VERSION_MINOR=0
readonly STEP14_VERSION_PATCH=0

# Determine script directory and project root
STEP14_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP14_DIR}/../lib"

# Source required dependencies if not already loaded
if ! type -t print_info &>/dev/null; then
    # shellcheck source=../lib/colors.sh
    source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
    # shellcheck source=../lib/utils.sh
    source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
fi

# Define fallback functions if still not available (for standalone usage)
if ! type -t print_info &>/dev/null; then
    print_info() { echo "ℹ️  $1"; }
    print_success() { echo "✅ $1"; }
    print_warning() { echo "⚠️  WARNING: $1"; }
    print_error() { echo "❌ ERROR: $1" >&2; }
fi

# ==============================================================================
# UI DETECTION FUNCTIONS
# ==============================================================================

# Check if project has UI components
# Returns: 0 if UI detected, 1 otherwise
has_ui_components() {
    local project_kind="${PROJECT_KIND:-unknown}"
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    # Normalize project_kind: convert hyphens to underscores for consistent matching
    project_kind="${project_kind//-/_}"
    
    # Check project kind first
    case "$project_kind" in
        react_spa|vue_spa|client_spa|static_website|web_application|documentation_site)
            print_info "Project kind '$project_kind' has UI components"
            return 0
            ;;
        shell_automation|nodejs_library|python_library)
            print_info "Project kind '$project_kind' typically has no UI"
            return 1
            ;;
    esac
    
    # For other project kinds, detect UI by file patterns
    print_info "Detecting UI components by file patterns..."
    
    # Check for React/JSX files
    if compgen -G "${target_dir}/**/*.jsx" > /dev/null 2>&1 || \
       compgen -G "${target_dir}/**/*.tsx" > /dev/null 2>&1 || \
       [[ -f "${target_dir}/src/App.jsx" ]] || \
       [[ -f "${target_dir}/src/App.tsx" ]]; then
        print_info "React/JSX UI components detected"
        return 0
    fi
    
    # Check for Vue files
    if compgen -G "${target_dir}/**/*.vue" > /dev/null 2>&1 || \
       [[ -f "${target_dir}/src/App.vue" ]]; then
        print_info "Vue UI components detected"
        return 0
    fi
    
    # Check for static website (HTML + CSS)
    if [[ -f "${target_dir}/index.html" ]] && \
       ( compgen -G "${target_dir}/**/*.css" > /dev/null 2>&1 || \
         [[ -d "${target_dir}/css" ]] || \
         [[ -d "${target_dir}/styles" ]] ); then
        print_info "Static website UI detected"
        return 0
    fi
    
    # Check for Angular
    if [[ -f "${target_dir}/angular.json" ]]; then
        print_info "Angular UI detected"
        return 0
    fi
    
    # Check for terminal UI libraries
    if [[ -f "${target_dir}/package.json" ]]; then
        if grep -qE '"(blessed|ink|terminal-kit|chalk-animation)"' "${target_dir}/package.json"; then
            print_info "Terminal UI (TUI) detected"
            return 0
        fi
    fi
    
    print_info "No UI components detected"
    return 1
}

# Check if this step should run based on project configuration
# Returns: 0 if should run, 1 if should skip
should_run_ux_analysis_step() {
    local project_kind="${PROJECT_KIND:-unknown}"
    local step_relevance=""
    
    # Check step relevance configuration
    if command -v get_step_relevance &>/dev/null; then
        step_relevance=$(get_step_relevance "$project_kind" "step_14_ux_analysis" 2>/dev/null || echo "optional")
    else
        step_relevance="optional"
    fi
    
    print_info "Step 14 relevance for '$project_kind': $step_relevance"
    
    # Skip if explicitly marked as skip
    if [[ "$step_relevance" == "skip" ]]; then
        print_info "Step 14 skipped (marked as skip for this project kind)"
        return 1
    fi
    
    # Check for UI components
    if has_ui_components; then
        print_success "UX Analysis will run - UI components detected"
        return 0
    else
        print_info "UX Analysis skipped - no UI components detected"
        return 1
    fi
}

# ==============================================================================
# UI FILE DISCOVERY
# ==============================================================================

# Find UI-related files in the project
# Returns: List of UI files (one per line)
find_ui_files() {
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    local ui_files=()
    
    # Find React/JSX/TSX files
    while IFS= read -r -d '' file; do
        ui_files+=("$file")
    done < <(find "$target_dir" -type f \( -name "*.jsx" -o -name "*.tsx" \) \
             ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
             ! -path "*/build/*" -print0 2>/dev/null || true)
    
    # Find Vue files
    while IFS= read -r -d '' file; do
        ui_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.vue" \
             ! -path "*/node_modules/*" ! -path "*/.git/*" -print0 2>/dev/null || true)
    
    # Find HTML files
    while IFS= read -r -d '' file; do
        ui_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.html" \
             ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
             ! -path "*/build/*" -print0 2>/dev/null || true)
    
    # Find CSS files
    while IFS= read -r -d '' file; do
        ui_files+=("$file")
    done < <(find "$target_dir" -type f -name "*.css" \
             ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
             ! -path "*/build/*" -print0 2>/dev/null || true)
    
    # Print files (limit to first 50 for performance)
    printf '%s\n' "${ui_files[@]}" | head -50
}

# ==============================================================================
# AI-POWERED UX ANALYSIS
# ==============================================================================

# Build UX analysis prompt
# Usage: build_ux_analysis_prompt <project_kind> <ui_files_summary>
build_ux_analysis_prompt() {
    local project_kind="$1"
    local ui_files_summary="$2"
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    # Get UX Designer persona from configuration
    local persona_role=""
    local persona_task=""
    local persona_approach=""
    
    # Try to load from ai_prompts_project_kinds.yaml
    local ai_prompts_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_prompts_project_kinds.yaml"
    if [[ -f "$ai_prompts_file" ]]; then
        # Extract role, task_context, and approach for ux_designer persona
        persona_role=$(awk -v kind="$project_kind" '
            $0 ~ "^" kind ":" {found=1}
            found && /^  ux_designer:/ {in_ux=1}
            in_ux && /^    role:/ {
                match($0, /role:[[:space:]]*"(.+)"/, arr)
                print arr[1]
                exit
            }
            /^[a-z_]+:/ && in_ux {exit}
        ' "$ai_prompts_file")
        
        persona_task=$(awk -v kind="$project_kind" '
            $0 ~ "^" kind ":" {found=1}
            found && /^  ux_designer:/ {in_ux=1}
            in_ux && /^    task_context:/ {in_task=1; next}
            in_task && /^    approach:/ {exit}
            in_task && /^      / {sub(/^      /, ""); print}
            /^  [a-z_]+:/ && in_task {exit}
        ' "$ai_prompts_file")
        
        persona_approach=$(awk -v kind="$project_kind" '
            $0 ~ "^" kind ":" {found=1}
            found && /^  ux_designer:/ {in_ux=1}
            in_ux && /^    approach:/ {in_approach=1; next}
            in_approach && /^  [a-z_]+:/ {exit}
            in_approach && /^      / {sub(/^      /, ""); print}
        ' "$ai_prompts_file")
    fi
    
    # Fallback to default if persona not found
    if [[ -z "$persona_role" ]]; then
        persona_role="You are a senior UX/UI Designer and Frontend Specialist with expertise in user experience design, accessibility standards (WCAG 2.1 AA/AAA), responsive design, and modern frontend frameworks."
    fi
    
    if [[ -z "$persona_task" ]]; then
        persona_task="Analyze the UI code for usability issues, accessibility violations, visual design inconsistencies, and provide actionable improvement recommendations."
    fi
    
    if [[ -z "$persona_approach" ]]; then
        persona_approach="- Identify accessibility issues\n- Check usability problems\n- Review visual consistency\n- Assess interaction patterns\n- Prioritize improvements by impact"
    fi
    
    # Build complete prompt
    cat << EOF
**Role**: ${persona_role}

**Task**: ${persona_task}

**Project Context**:
- Project Type: ${project_kind}
- Target Directory: ${target_dir}
- UI Files Found: ${ui_files_summary}

**Your Analysis Should Cover**:
1. **Accessibility Issues** (WCAG 2.1 violations)
   - Missing ARIA labels and semantic HTML
   - Color contrast problems
   - Keyboard navigation issues
   - Screen reader compatibility

2. **Usability Problems**
   - Confusing navigation or information architecture
   - Unclear call-to-action buttons
   - Missing or poor error messages
   - Inconsistent interaction patterns
   - Poor mobile experience

3. **Visual Design Issues**
   - Inconsistent spacing and alignment
   - Typography problems
   - Color scheme inconsistencies
   - Layout and responsive design issues

4. **Component Architecture**
   - Reusability opportunities
   - Design system consistency
   - Component complexity

5. **Performance & Perception**
   - Loading states and user feedback
   - Animation and transition issues
   - Perceived performance problems

**Approach**: ${persona_approach}

**Output Format**:
Provide your analysis in the following markdown format:

# UX Analysis Report

## Executive Summary
[Brief overview of findings with counts: X critical issues, Y warnings, Z recommendations]

## Critical Issues
[Issues that severely impact user experience - must fix]

### Issue 1: [Title]
- **Category**: [Accessibility/Usability/Visual/Performance]
- **Severity**: Critical
- **Location**: [File path and line number if possible]
- **Description**: [What's wrong]
- **Impact**: [How it affects users]
- **Recommendation**: [How to fix it]

## Warnings
[Issues that should be addressed but aren't blocking]

## Improvement Suggestions
[Nice-to-have enhancements ranked by impact]

## Next Development Steps
[Prioritized list of recommended actions]

1. **Quick Wins** (1-2 hours): [List]
2. **Short Term** (1 week): [List]
3. **Long Term** (1 month+): [List]

## Design Patterns to Consider
[Modern UX patterns that could improve the experience]

---

Please analyze the UI files and provide your detailed assessment.
EOF
}

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main step function - performs UX analysis
# Returns: 0 for success, 1 for failure
step14_ux_analysis() {
    print_step "14" "UX Analysis"
    
    # Check if this step should run
    if ! should_run_ux_analysis_step; then
        print_info "Step 14: UX Analysis skipped (no UI components)"
        
        # Create minimal backlog entry
        local backlog_file="${BACKLOG_RUN_DIR}/step_14_ux_analysis.md"
        cat > "$backlog_file" << EOF
# Step 14: UX Analysis - SKIPPED

**Status**: ⏭️ Skipped
**Reason**: No UI components detected in this project
**Date**: $(date '+%Y-%m-%d %H:%M:%S')

## Summary

This step was skipped because the project does not contain UI components that require UX analysis.

Project types that skip this step:
- API-only backends
- CLI tools without TUI
- Libraries without UI components
- Shell script automation

Project types that run this step:
- React/Vue/Angular SPAs
- Static websites
- Documentation sites
- Web applications
- Projects with terminal UI (TUI)

## Recommendation

If your project does have UI components that were not detected, please:
1. Check that UI files are in standard locations
2. Update the project kind in \`.workflow-config.yaml\`
3. Manually run Step 14 if needed

EOF
        
        print_success "Step 14 completed (skipped - no UI)"
        return 0
    fi
    
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    cd "$target_dir" || {
        print_error "Failed to change to target directory: $target_dir"
        return 1
    }
    
    local project_kind="${PROJECT_KIND:-generic}"
    local ux_report=$(mktemp)
    local ai_output=$(mktemp)
    TEMP_FILES+=("$ux_report" "$ai_output")
    
    print_info "Analyzing UI components for project type: $project_kind"
    
    # Phase 1: Discover UI files
    print_info "Phase 1: Discovering UI files..."
    local ui_files
    ui_files=$(find_ui_files)
    local ui_file_count
    ui_file_count=$(echo "$ui_files" | grep -c . || echo "0")
    
    if [[ $ui_file_count -eq 0 ]]; then
        print_warning "No UI files found to analyze"
        echo "No UI files found for analysis" > "$ux_report"
        return 0
    fi
    
    print_success "Found $ui_file_count UI files to analyze"
    
    # Create UI files summary for prompt
    local ui_files_summary
    ui_files_summary=$(echo "$ui_files" | head -20 | sed 's|^|  - |')
    if [[ $ui_file_count -gt 20 ]]; then
        ui_files_summary="${ui_files_summary}\n  ... and $((ui_file_count - 20)) more files"
    fi
    
    # Phase 2: Build AI prompt
    print_info "Phase 2: Building UX analysis prompt..."
    local ux_prompt
    ux_prompt=$(build_ux_analysis_prompt "$project_kind" "$ui_files_summary")
    
    # Phase 3: Call AI for analysis (if available)
    print_info "Phase 3: Performing AI-powered UX analysis..."
    
    if command -v execute_copilot_prompt &>/dev/null && type -t validate_copilot_cli &>/dev/null && validate_copilot_cli; then
        print_info "Using AI for UX analysis..."
        
        # Create log file for AI output
        local log_timestamp
        log_timestamp=$(date +%Y%m%d_%H%M%S)_$$
        local log_file="${LOGS_RUN_DIR:-./logs}/step14_copilot_ux_analysis_${log_timestamp}.log"
        
        # Call AI with ux_designer persona using execute_copilot_prompt
        if execute_copilot_prompt "$ux_prompt" "$log_file" "step14" "ux_designer"; then
            cp "$log_file" "$ux_report"
            print_success "AI UX analysis completed"
        else
            print_warning "AI analysis failed, falling back to automated checks"
            perform_automated_ux_checks > "$ux_report"
        fi
    else
        print_info "AI not available, performing automated UX checks..."
        perform_automated_ux_checks > "$ux_report"
    fi
    
    # Phase 4: Generate backlog report
    print_info "Phase 4: Generating UX analysis report..."
    local backlog_file="${BACKLOG_RUN_DIR}/step_14_ux_analysis.md"
    
    cat > "$backlog_file" << EOF
# Step 14: UX Analysis Report

**Status**: ✅ Completed
**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Project Type**: ${project_kind}
**UI Files Analyzed**: ${ui_file_count}

---

EOF
    
    # Append AI analysis or automated checks
    cat "$ux_report" >> "$backlog_file"
    
    cat >> "$backlog_file" << EOF

---

## Analysis Metadata

- **Step Version**: ${STEP14_VERSION}
- **Analysis Method**: $(if command -v execute_copilot_prompt &>/dev/null && type -t validate_copilot_cli &>/dev/null && validate_copilot_cli; then echo "AI-Powered"; else echo "Automated Checks"; fi)
- **Target Directory**: ${target_dir}
- **UI Files Scanned**: ${ui_file_count}

## Next Steps

1. Review the issues identified above
2. Prioritize fixes based on severity and user impact
3. Create GitHub issues for tracking improvements
4. Update UI components with recommended changes
5. Re-run Step 14 to validate improvements

EOF
    
    # Phase 5: Generate summary
    local summary_file="${SUMMARIES_RUN_DIR}/step_14_ux_analysis.md"
    local issue_count
    issue_count=$(grep -c "^###" "$ux_report" || echo "0")
    
    cat > "$summary_file" << EOF
# Step 14: UX Analysis - Summary

✅ **Status**: Completed

**Findings**: Analyzed ${ui_file_count} UI files and identified ${issue_count} UX issues/recommendations

**Key Highlights**:
- UI components detected in ${project_kind} project
- Full analysis available in backlog report
- Recommendations prioritized by user impact

**Next Action**: Review UX analysis report in backlog directory

EOF
    
    print_success "Step 14: UX Analysis completed"
    print_info "Report saved to: $backlog_file"
    print_info "Summary saved to: $summary_file"
    
    return 0
}

# ==============================================================================
# AUTOMATED UX CHECKS (FALLBACK)
# ==============================================================================

# Perform basic automated UX checks when AI is not available
# Returns: Formatted markdown report
perform_automated_ux_checks() {
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    cat << 'EOF'
# UX Analysis Report (Automated Checks)

## Executive Summary

Automated accessibility and usability checks performed. AI-powered analysis is recommended for comprehensive UX review.

## Automated Checks Performed

### 1. HTML Semantic Structure
EOF
    
    # Check for semantic HTML in HTML files
    local html_files
    html_files=$(find "$target_dir" -type f -name "*.html" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)
    
    if [[ -n "$html_files" ]]; then
        echo ""
        echo "**HTML Files Found**: $(echo "$html_files" | wc -l)"
        echo ""
        
        # Check for basic semantic tags
        local has_nav=$(echo "$html_files" | xargs grep -l "<nav" 2>/dev/null | wc -l || echo "0")
        local has_main=$(echo "$html_files" | xargs grep -l "<main" 2>/dev/null | wc -l || echo "0")
        local has_header=$(echo "$html_files" | xargs grep -l "<header" 2>/dev/null | wc -l || echo "0")
        local has_footer=$(echo "$html_files" | xargs grep -l "<footer" 2>/dev/null | wc -l || echo "0")
        
        echo "- Navigation tags (\`<nav>\`): $has_nav files"
        echo "- Main content tags (\`<main>\`): $has_main files"
        echo "- Header tags (\`<header>\`): $has_header files"
        echo "- Footer tags (\`<footer>\`): $has_footer files"
    fi
    
    cat << 'EOF'

### 2. Image Accessibility

EOF
    
    # Check for images without alt text
    if [[ -n "$html_files" ]]; then
        local img_without_alt
        img_without_alt=$(echo "$html_files" | xargs grep -n "<img" 2>/dev/null | grep -v "alt=" | wc -l || echo "0")
        
        if [[ $img_without_alt -gt 0 ]]; then
            echo "⚠️ **Warning**: Found $img_without_alt \`<img>\` tags potentially missing alt text"
            echo ""
            echo "**Recommendation**: Add descriptive alt text to all images for accessibility"
        else
            echo "✅ All images appear to have alt attributes"
        fi
    fi
    
    cat << 'EOF'

### 3. Form Accessibility

EOF
    
    # Check for form labels
    if [[ -n "$html_files" ]]; then
        local forms=$(echo "$html_files" | xargs grep -c "<form" 2>/dev/null | grep -v ":0$" | wc -l 2>/dev/null || echo "0")
        forms=$(echo "$forms" | tr -d '[:space:]')  # Remove whitespace
        local labels=$(echo "$html_files" | xargs grep -c "<label" 2>/dev/null | grep -v ":0$" | wc -l 2>/dev/null || echo "0")
        labels=$(echo "$labels" | tr -d '[:space:]')  # Remove whitespace
        
        echo "- Forms found: ${forms:-0}"
        echo "- Labels found: ${labels:-0}"
        
        if [[ ${forms:-0} -gt 0 ]] && [[ ${labels:-0} -eq 0 ]]; then
            echo ""
            echo "⚠️ **Warning**: Forms detected without labels - add \`<label>\` tags for accessibility"
        fi
    fi
    
    cat << 'EOF'

## Recommendations

### Quick Wins (Priority: High)

1. **Add Alt Text**: Ensure all images have descriptive alt attributes
2. **Semantic HTML**: Use semantic tags (\`<nav>\`, \`<main>\`, \`<header>\`, \`<footer>\`)
3. **Form Labels**: Associate labels with form inputs using \`for\` attribute
4. **ARIA Labels**: Add aria-label where visual labels aren't appropriate

### Accessibility Standards

- Follow WCAG 2.1 Level AA guidelines
- Test with screen readers (NVDA, JAWS, VoiceOver)
- Ensure keyboard navigation works
- Verify color contrast ratios (4.5:1 for normal text)

### Next Steps

For comprehensive UX analysis:
1. Install and configure GitHub Copilot CLI
2. Re-run Step 14 with AI-powered analysis
3. Consider professional accessibility audit
4. Implement automated accessibility testing (e.g., axe-core, pa11y)

---

**Note**: This is an automated check. AI-powered analysis will provide more detailed insights and recommendations.
EOF
}

# Export main function for workflow execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced by the main workflow, not executed directly."
    exit 1
fi
