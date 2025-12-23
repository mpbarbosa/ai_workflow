#!/usr/bin/env bash
set -euo pipefail

#
# config_wizard.sh - Interactive Configuration Wizard
#
# Provides an interactive wizard to create .workflow-config.yaml files
# for the Tech Stack Adaptive Framework.
#
# Version: 1.0.0
# Date: 2025-12-18
#
# Usage:
#   source lib/config_wizard.sh
#   run_config_wizard

set -euo pipefail

# Color codes for wizard UI
readonly WIZARD_CYAN='\033[0;36m'
readonly WIZARD_GREEN='\033[0;32m'
readonly WIZARD_YELLOW='\033[1;33m'
readonly WIZARD_RED='\033[0;31m'
readonly WIZARD_BLUE='\033[0;34m'
readonly WIZARD_BOLD='\033[1m'
readonly WIZARD_RESET='\033[0m'

# Wizard state
declare -A WIZARD_CONFIG

#######################################
# Print wizard header
#######################################
wizard_header() {
    clear
    echo -e "${WIZARD_CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║           AI Workflow Automation - Configuration Wizard          ║
║                                                                   ║
║                          Version 1.0.0                            ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${WIZARD_RESET}"
    echo ""
}

#######################################
# Print wizard step header
# Arguments:
#   $1 - Step number
#   $2 - Total steps
#   $3 - Step title
#######################################
wizard_step() {
    local step="$1"
    local total="$2"
    local title="$3"
    
    echo ""
    echo -e "${WIZARD_BOLD}${WIZARD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${WIZARD_RESET}"
    echo -e "${WIZARD_BOLD}Step ${step}/${total}: ${title}${WIZARD_RESET}"
    echo -e "${WIZARD_BOLD}${WIZARD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${WIZARD_RESET}"
    echo ""
}

#######################################
# Confirm prompt (yes/no)
# Arguments:
#   $1 - Prompt message
# Returns:
#   0 for yes, 1 for no
#######################################
confirm_prompt() {
    local prompt="$1"
    local response
    
    # Use /dev/tty for direct terminal interaction
    echo -en "${WIZARD_YELLOW}${prompt} [y/N]: ${WIZARD_RESET}" >/dev/tty
    read -r response </dev/tty
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Text input prompt
# Arguments:
#   $1 - Prompt message
#   $2 - Default value (optional)
# Outputs:
#   User input or default
#######################################
input_prompt() {
    local prompt="$1"
    local default="${2:-}"
    local response
    
    # Use /dev/tty for direct terminal interaction
    if [[ -n "$default" ]]; then
        echo -en "${WIZARD_YELLOW}${prompt} [${default}]: ${WIZARD_RESET}" >/dev/tty
    else
        echo -en "${WIZARD_YELLOW}${prompt}: ${WIZARD_RESET}" >/dev/tty
    fi
    
    read -r response </dev/tty
    
    if [[ -z "$response" ]] && [[ -n "$default" ]]; then
        echo "$default"
    else
        echo "$response"
    fi
}

#######################################
# Select from list
# Arguments:
#   $1 - Prompt message
#   $@ - Options
# Outputs:
#   Selected option
#######################################
select_prompt() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo ""
    echo -e "${WIZARD_CYAN}${prompt}${WIZARD_RESET}"
    echo ""
    
    local i=1
    for option in "${options[@]}"; do
        echo -e "  ${WIZARD_BOLD}${i})${WIZARD_RESET} ${option}"
        ((i++))
    done
    
    echo ""
    local selection
    while true; do
        echo -e -n "${WIZARD_YELLOW}Enter selection [1-${#options[@]}]: ${WIZARD_RESET}"
        read -r selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#options[@]} ]]; then
            echo "${options[$((selection-1))]}"
            return 0
        else
            echo -e "${WIZARD_RED}Invalid selection. Please try again.${WIZARD_RESET}"
        fi
    done
}

#######################################
# Main wizard: Welcome screen
#######################################
wizard_welcome() {
    wizard_header
    
    echo -e "${WIZARD_GREEN}Welcome to the AI Workflow Automation Configuration Wizard!${WIZARD_RESET}"
    echo ""
    echo "This wizard will help you create a .workflow-config.yaml file for your project."
    echo "The configuration file enables language-specific workflow optimization."
    echo ""
    echo -e "${WIZARD_BOLD}What this wizard will do:${WIZARD_RESET}"
    echo "  • Auto-detect your project's technology stack"
    echo "  • Gather project information"
    echo "  • Configure build and test commands"
    echo "  • Generate a complete .workflow-config.yaml file"
    echo ""
    
    if ! confirm_prompt "Ready to begin?"; then
        echo -e "${WIZARD_YELLOW}Wizard cancelled.${WIZARD_RESET}"
        exit 0
    fi
}

#######################################
# Step 1: Auto-detect tech stack
#######################################
wizard_detect_project() {
    wizard_step 1 5 "Technology Stack Detection"
    
    echo "Analyzing project structure..."
    echo ""
    
    # Run detection (suppress internal print_info/print_success messages for cleaner wizard output)
    # The wizard provides its own user-friendly status messages
    detect_tech_stack >/dev/null 2>&1
    
    local detected_lang="${PRIMARY_LANGUAGE:-javascript}"
    local confidence=$(get_confidence_score "$detected_lang")
    
    echo -e "${WIZARD_GREEN}✓ Detection complete!${WIZARD_RESET}"
    echo ""
    echo -e "  Detected Language: ${WIZARD_BOLD}${detected_lang}${WIZARD_RESET}"
    echo "  Confidence:        ${confidence}%"
    echo "  Build System:      ${BUILD_SYSTEM}"
    echo "  Test Framework:    ${TEST_FRAMEWORK}"
    echo ""
    
    if confirm_prompt "Is this correct?"; then
        WIZARD_CONFIG[primary_language]="$detected_lang"
        WIZARD_CONFIG[build_system]="$BUILD_SYSTEM"
        WIZARD_CONFIG[test_framework]="$TEST_FRAMEWORK"
        echo -e "${WIZARD_GREEN}✓ Using detected configuration${WIZARD_RESET}"
    else
        echo ""
        echo "Let's configure manually..."
        
        local selected_lang
        selected_lang=$(select_prompt "Select your primary language:" \
            "javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
        
        WIZARD_CONFIG[primary_language]="$selected_lang"
        
        # Set defaults based on language
        case "$selected_lang" in
            javascript)
                WIZARD_CONFIG[build_system]="npm"
                WIZARD_CONFIG[test_framework]="jest"
                ;;
            python)
                WIZARD_CONFIG[build_system]="pip"
                WIZARD_CONFIG[test_framework]="pytest"
                ;;
            go)
                WIZARD_CONFIG[build_system]="go mod"
                WIZARD_CONFIG[test_framework]="go test"
                ;;
            java)
                WIZARD_CONFIG[build_system]="maven"
                WIZARD_CONFIG[test_framework]="junit"
                ;;
            ruby)
                WIZARD_CONFIG[build_system]="bundler"
                WIZARD_CONFIG[test_framework]="rspec"
                ;;
            rust)
                WIZARD_CONFIG[build_system]="cargo"
                WIZARD_CONFIG[test_framework]="cargo test"
                ;;
            cpp)
                WIZARD_CONFIG[build_system]="cmake"
                WIZARD_CONFIG[test_framework]="gtest"
                ;;
            bash)
                WIZARD_CONFIG[build_system]="none"
                WIZARD_CONFIG[test_framework]="bats"
                ;;
        esac
        
        echo -e "${WIZARD_GREEN}✓ Language set to: ${selected_lang}${WIZARD_RESET}"
    fi
}

#######################################
# Step 2: Project information
#######################################
wizard_project_info() {
    wizard_step 2 5 "Project Information"
    
    local project_name
    local project_desc
    
    # Try to get project name from package file
    local default_name=""
    if [[ -f "package.json" ]]; then
        default_name=$(jq -r '.name // ""' package.json 2>/dev/null || echo "")
    elif [[ -f "Cargo.toml" ]]; then
        default_name=$(grep -m1 '^name' Cargo.toml | cut -d'"' -f2 2>/dev/null || echo "")
    elif [[ -f "go.mod" ]]; then
        default_name=$(grep -m1 '^module' go.mod | awk '{print $2}' 2>/dev/null || echo "")
    fi
    
    if [[ -z "$default_name" ]]; then
        default_name=$(basename "$PWD")
    fi
    
    project_name=$(input_prompt "Project name" "$default_name")
    project_desc=$(input_prompt "Project description (optional)" "")
    
    WIZARD_CONFIG[project_name]="$project_name"
    WIZARD_CONFIG[project_description]="$project_desc"
    
    echo ""
    echo -e "${WIZARD_GREEN}✓ Project information saved${WIZARD_RESET}"
}

#######################################
# Step 3: Project structure
#######################################
wizard_project_structure() {
    wizard_step 3 5 "Project Structure"
    
    echo "Configure your project directory structure..."
    echo ""
    
    # Source directories
    local default_src="src"
    case "${WIZARD_CONFIG[primary_language]}" in
        java) default_src="src/main/java" ;;
        cpp) default_src="src include" ;;
        bash) default_src="bin lib" ;;
    esac
    
    local source_dirs
    source_dirs=$(input_prompt "Source directories (space-separated)" "$default_src")
    WIZARD_CONFIG[source_dirs]="$source_dirs"
    
    # Test directories
    local default_test="tests"
    case "${WIZARD_CONFIG[primary_language]}" in
        javascript) default_test="tests __tests__" ;;
        java) default_test="src/test/java" ;;
        go) default_test="." ;;
        rust) default_test="tests" ;;
    esac
    
    local test_dirs
    test_dirs=$(input_prompt "Test directories (space-separated)" "$default_test")
    WIZARD_CONFIG[test_dirs]="$test_dirs"
    
    # Docs directories
    local docs_dirs
    docs_dirs=$(input_prompt "Documentation directories (space-separated)" "docs")
    WIZARD_CONFIG[docs_dirs]="$docs_dirs"
    
    echo ""
    echo -e "${WIZARD_GREEN}✓ Project structure configured${WIZARD_RESET}"
}

#######################################
# Step 4: Commands configuration
#######################################
wizard_commands() {
    wizard_step 4 5 "Build & Test Commands"
    
    echo "Configure commands for your project..."
    echo ""
    
    local lang="${WIZARD_CONFIG[primary_language]}"
    
    # Test command
    local default_test=""
    case "$lang" in
        javascript) default_test="npm test" ;;
        python) default_test="pytest" ;;
        go) default_test="go test ./..." ;;
        java) default_test="mvn test" ;;
        ruby) default_test="bundle exec rspec" ;;
        rust) default_test="cargo test" ;;
        cpp) default_test="ctest --test-dir build" ;;
        bash) default_test="bats tests/" ;;
    esac
    
    local test_cmd
    test_cmd=$(input_prompt "Test command" "$default_test")
    WIZARD_CONFIG[test_command]="$test_cmd"
    
    # Lint command
    local default_lint=""
    case "$lang" in
        javascript) default_lint="npm run lint" ;;
        python) default_lint="pylint src/" ;;
        go) default_lint="golangci-lint run" ;;
        java) default_lint="mvn checkstyle:check" ;;
        ruby) default_lint="rubocop" ;;
        rust) default_lint="cargo clippy" ;;
        cpp) default_lint="clang-tidy src/*.cpp" ;;
        bash) default_lint="shellcheck *.sh" ;;
    esac
    
    local lint_cmd
    lint_cmd=$(input_prompt "Lint command (optional)" "$default_lint")
    WIZARD_CONFIG[lint_command]="$lint_cmd"
    
    echo ""
    echo -e "${WIZARD_GREEN}✓ Commands configured${WIZARD_RESET}"
}

#######################################
# Step 5: Preview and save
#######################################
wizard_preview_and_save() {
    wizard_step 5 5 "Review & Save"
    
    echo "Here's your configuration:"
    echo ""
    echo -e "${WIZARD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${WIZARD_RESET}"
    
    # Generate YAML content
    local yaml_content
    yaml_content=$(cat << EOF
# AI Workflow Automation Configuration
# Generated by Configuration Wizard on $(date '+%Y-%m-%d %H:%M:%S')

project:
  name: "${WIZARD_CONFIG[project_name]}"
EOF
)
    
    if [[ -n "${WIZARD_CONFIG[project_description]:-}" ]]; then
        yaml_content+=$(cat << EOF

  description: "${WIZARD_CONFIG[project_description]}"
EOF
)
    fi
    
    yaml_content+=$(cat << EOF

tech_stack:
  primary_language: "${WIZARD_CONFIG[primary_language]}"
  build_system: "${WIZARD_CONFIG[build_system]}"
  test_framework: "${WIZARD_CONFIG[test_framework]}"
  test_command: "${WIZARD_CONFIG[test_command]}"
EOF
)
    
    if [[ -n "${WIZARD_CONFIG[lint_command]:-}" ]]; then
        yaml_content+=$(cat << EOF

  lint_command: "${WIZARD_CONFIG[lint_command]}"
EOF
)
    fi
    
    yaml_content+=$(cat << EOF

structure:
  source_dirs:
EOF
)
    
    for dir in ${WIZARD_CONFIG[source_dirs]}; do
        yaml_content+=$(cat << EOF

    - $dir
EOF
)
    done
    
    yaml_content+=$(cat << EOF

  test_dirs:
EOF
)
    
    for dir in ${WIZARD_CONFIG[test_dirs]}; do
        yaml_content+=$(cat << EOF

    - $dir
EOF
)
    done
    
    yaml_content+=$(cat << EOF

  docs_dirs:
EOF
)
    
    for dir in ${WIZARD_CONFIG[docs_dirs]}; do
        yaml_content+=$(cat << EOF

    - $dir
EOF
)
    done
    
    # Display preview
    echo "$yaml_content" | head -50
    echo -e "${WIZARD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${WIZARD_RESET}"
    echo ""
    
    if confirm_prompt "Save this configuration to .workflow-config.yaml?"; then
        echo "$yaml_content" > .workflow-config.yaml
        echo ""
        echo -e "${WIZARD_GREEN}✓ Configuration saved successfully!${WIZARD_RESET}"
        echo ""
        echo -e "File created: ${WIZARD_BOLD}.workflow-config.yaml${WIZARD_RESET}"
        echo ""
        echo "You can now run the workflow with:"
        echo -e "  ${WIZARD_CYAN}./execute_tests_docs_workflow.sh --auto${WIZARD_RESET}"
        echo ""
        return 0
    else
        echo ""
        echo -e "${WIZARD_YELLOW}Configuration not saved.${WIZARD_RESET}"
        if confirm_prompt "Run wizard again?"; then
            run_config_wizard
        fi
        return 1
    fi
}

#######################################
# Main wizard entry point
#######################################
run_config_wizard() {
    # Initialize wizard config
    unset WIZARD_CONFIG
    declare -gA WIZARD_CONFIG
    
    # Check if config already exists
    if [[ -f ".workflow-config.yaml" ]]; then
        echo ""
        echo -e "${WIZARD_YELLOW}⚠️  Warning: .workflow-config.yaml already exists!${WIZARD_RESET}"
        echo ""
        if ! confirm_prompt "Overwrite existing configuration?"; then
            echo -e "${WIZARD_YELLOW}Wizard cancelled.${WIZARD_RESET}"
            return 1
        fi
    fi
    
    # Run wizard steps
    wizard_welcome
    wizard_detect_project
    wizard_project_info
    wizard_project_structure
    wizard_commands
    wizard_preview_and_save
    
    return 0
}

# Export main function
export -f run_config_wizard
