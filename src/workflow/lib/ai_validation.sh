#!/bin/bash
set -euo pipefail

################################################################################
# AI Validation Module
# Purpose: Copilot CLI detection, authentication, and validation
# Extracted from: ai_helpers.sh (Module Decomposition)
# Part of: Tests & Documentation Workflow Automation v2.4.0
################################################################################

# ==============================================================================
# COPILOT CLI DETECTION AND VALIDATION
# ==============================================================================

# Check if Copilot CLI is available
# Returns: 0 if available, 1 if not
is_copilot_available() {
    command -v copilot &> /dev/null
}

# Check if Copilot CLI is authenticated
# Returns: 0 if authenticated, 1 if not
is_copilot_authenticated() {
    if ! is_copilot_available; then
        return 1
    fi
    
    # Test authentication by running a simple command
    # Redirect stderr to capture authentication errors
    local auth_test
    auth_test=$(copilot --version 2>&1)
    
    # Check for authentication error messages
    if echo "$auth_test" | grep -q "No authentication information found"; then
        return 1
    fi
    
    return 0
}

# Validate Copilot CLI and provide user feedback
# Usage: validate_copilot_cli
validate_copilot_cli() {
    if ! is_copilot_available; then
        print_warning "GitHub Copilot CLI not found"
        print_info "Install with: npm install -g @githubnext/github-copilot-cli"
        return 1
    fi
    
    if ! is_copilot_authenticated; then
        print_warning "GitHub Copilot CLI is not authenticated"
        print_info "Authentication options:"
        print_info "  • Run 'copilot' and use the '/login' command"
        print_info "  • Set COPILOT_GITHUB_TOKEN, GH_TOKEN, or GITHUB_TOKEN environment variable"
        print_info "  • Run 'gh auth login' to authenticate with GitHub CLI"
        return 1
    fi
    
    print_success "GitHub Copilot CLI detected and authenticated"
    return 0
}

# Validate AI response for completeness
# Usage: validate_ai_response <response_file> <expected_sections>
# Returns: 0 if valid, 1 if not
validate_ai_response() {
    local response_file="$1"
    local expected_sections="$2"  # Space-separated list
    
    if [[ ! -f "$response_file" ]]; then
        print_error "AI response file not found: $response_file"
        return 1
    fi
    
    if [[ ! -s "$response_file" ]]; then
        print_error "AI response file is empty: $response_file"
        return 1
    fi
    
    # Check for expected sections if provided
    if [[ -n "$expected_sections" ]]; then
        local missing_sections=()
        for section in $expected_sections; do
            if ! grep -q "$section" "$response_file"; then
                missing_sections+=("$section")
            fi
        done
        
        if [[ ${#missing_sections[@]} -gt 0 ]]; then
            print_warning "AI response missing expected sections: ${missing_sections[*]}"
            return 1
        fi
    fi
    
    return 0
}

# Check if AI features should be enabled
# Usage: should_enable_ai
# Returns: 0 if should enable, 1 if not
should_enable_ai() {
    # Check if explicitly disabled
    if [[ "${DISABLE_AI:-false}" == "true" ]]; then
        return 1
    fi
    
    # Check if Copilot is available
    if ! is_copilot_available; then
        return 1
    fi
    
    # Check authentication in non-AUTO mode
    if [[ "${AUTO_MODE:-false}" != "true" ]]; then
        if ! is_copilot_authenticated; then
            return 1
        fi
    fi
    
    return 0
}
