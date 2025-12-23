#!/usr/bin/env bash
set -euo pipefail

#
# tech_stack.sh - Tech Stack Detection and Configuration Management
#
# This module provides tech stack auto-detection, configuration file parsing,
# and adaptive workflow behavior based on project technology stack.
#
# Version: 2.0.0 (Phase 3 - Workflow Integration)
# Supports: JavaScript, Python, Go, Java, Ruby, Rust, C/C++, Bash
#
# Dependencies:
#   - config.sh (YAML parsing)
#   - colors.sh (output formatting)
#   - utils.sh (logging)
#
# Usage:
#   source lib/tech_stack.sh
#   init_tech_stack
#   echo "$PRIMARY_LANGUAGE"
#   test_cmd=$(get_test_command)
#   execute_language_command "$test_cmd"

set -euo pipefail

# Global configuration cache
declare -A TECH_STACK_CONFIG
declare -A TECH_STACK_CACHE
declare -A LANGUAGE_CONFIDENCE

# Exported variables (set by init_tech_stack)
export PRIMARY_LANGUAGE=""
export BUILD_SYSTEM=""
export TEST_FRAMEWORK=""
export TEST_COMMAND=""
export LINT_COMMAND=""
export INSTALL_COMMAND=""

# Detection confidence thresholds
readonly CONFIDENCE_HIGH=80
readonly CONFIDENCE_MEDIUM=60
readonly CONFIDENCE_LOW=40

#######################################
# Initialize tech stack system
# Loads config file or auto-detects tech stack
# Globals:
#   TECH_STACK_CONFIG
#   PRIMARY_LANGUAGE
#   TECH_STACK_CONFIG_FILE (optional)
# Arguments:
#   None
# Returns:
#   0 on success, 1 on failure
#######################################
init_tech_stack() {
    print_info "Initializing tech stack detection..."
    
    # Save current directory and change to PROJECT_ROOT for detection
    local original_dir="$(pwd)"
    if [[ -n "${PROJECT_ROOT:-}" ]] && [[ -d "$PROJECT_ROOT" ]]; then
        cd "$PROJECT_ROOT" || return 1
    fi
    
    # Use custom config file if specified via --config-file
    if [[ -n "${TECH_STACK_CONFIG_FILE:-}" ]]; then
        if [[ -f "$TECH_STACK_CONFIG_FILE" ]]; then
            print_info "Using specified config file: $TECH_STACK_CONFIG_FILE"
            if load_tech_stack_config "$TECH_STACK_CONFIG_FILE"; then
                cd "$original_dir" || true
                print_success "Loaded configuration from $TECH_STACK_CONFIG_FILE"
                print_tech_stack_summary
                return 0
            else
                print_warning "Failed to load config, falling back to auto-detection"
            fi
        else
            cd "$original_dir" || true
            print_error "Specified config file not found: $TECH_STACK_CONFIG_FILE"
            return 1
        fi
    fi
    
    # Try to load config file
    if [[ -f ".workflow-config.yaml" ]]; then
        print_info "Found .workflow-config.yaml"
        if load_tech_stack_config ".workflow-config.yaml"; then
            cd "$original_dir" || true
            print_success "Loaded configuration from .workflow-config.yaml"
            print_tech_stack_summary
            return 0
        else
            print_warning "Failed to load config, falling back to auto-detection"
        fi
    elif [[ -f ".workflow-config.yml" ]]; then
        print_info "Found .workflow-config.yml"
        if load_tech_stack_config ".workflow-config.yml"; then
            cd "$original_dir" || true
            print_success "Loaded configuration from .workflow-config.yml"
            print_tech_stack_summary
            return 0
        else
            print_warning "Failed to load config, falling back to auto-detection"
        fi
    fi
    
    # Auto-detect tech stack
    print_info "No configuration found, auto-detecting tech stack..."
    if detect_tech_stack; then
        local confidence=$(get_confidence_score "$PRIMARY_LANGUAGE")
        cd "$original_dir" || true
        print_success "Auto-detected: $PRIMARY_LANGUAGE (${confidence}% confidence)"
        print_tech_stack_summary
        
        # Prompt user if confidence is low
        if [[ $confidence -lt $CONFIDENCE_HIGH ]]; then
            print_warning "Detection confidence is ${confidence}% (below ${CONFIDENCE_HIGH}%)"
            print_info "Consider creating a configuration file for better accuracy"
            print_info "Run: ./execute_tests_docs_workflow.sh --init-config"
        fi
        
        return 0
    else
        cd "$original_dir" || true
        print_error "Tech stack detection failed"
        print_info "Falling back to default: JavaScript/Node.js"
        load_default_tech_stack
        return 0
    fi
}

#######################################
# Load tech stack configuration from YAML file
# Globals:
#   TECH_STACK_CONFIG
#   PRIMARY_LANGUAGE
# Arguments:
#   $1 - Path to config file
# Returns:
#   0 on success, 1 on failure
#######################################
load_tech_stack_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        print_error "Config file not found: $config_file"
        return 1
    fi
    
    # Parse YAML config file using config.sh functions
    if ! parse_yaml_config "$config_file"; then
        print_error "Failed to parse config file"
        return 1
    fi
    
    # Extract tech stack properties
    TECH_STACK_CONFIG[primary_language]=$(get_config_value "tech_stack.primary_language" "")
    TECH_STACK_CONFIG[build_system]=$(get_config_value "tech_stack.build_system" "")
    TECH_STACK_CONFIG[test_framework]=$(get_config_value "tech_stack.test_framework" "")
    TECH_STACK_CONFIG[test_command]=$(get_config_value "tech_stack.test_command" "")
    TECH_STACK_CONFIG[lint_command]=$(get_config_value "tech_stack.lint_command" "")
    TECH_STACK_CONFIG[linter]=$(get_config_value "tech_stack.linter" "")
    
    # Extract structure properties
    TECH_STACK_CONFIG[source_dirs]=$(get_config_value "structure.source_dirs" "src")
    TECH_STACK_CONFIG[test_dirs]=$(get_config_value "structure.test_dirs" "tests")
    TECH_STACK_CONFIG[docs_dirs]=$(get_config_value "structure.docs_dirs" "docs")
    TECH_STACK_CONFIG[exclude_dirs]=$(get_config_value "structure.exclude_dirs" "")
    
    # Extract dependency properties
    TECH_STACK_CONFIG[package_file]=$(get_config_value "dependencies.package_file" "")
    TECH_STACK_CONFIG[lock_file]=$(get_config_value "dependencies.lock_file" "")
    TECH_STACK_CONFIG[install_command]=$(get_config_value "dependencies.install_command" "")
    
    # Extract AI prompt properties
    TECH_STACK_CONFIG[language_context]=$(get_config_value "ai_prompts.language_context" "")
    
    # Validate required fields
    if [[ -z "${TECH_STACK_CONFIG[primary_language]}" ]]; then
        print_error "Required field 'tech_stack.primary_language' is missing"
        return 1
    fi
    
    # Export to environment
    export_tech_stack_variables
    
    # Cache for performance
    init_tech_stack_cache
    
    log_to_workflow "INFO" "Loaded tech stack config: ${PRIMARY_LANGUAGE}/${BUILD_SYSTEM}"
    
    return 0
}

#######################################
# Parse YAML config file
# This is a simple YAML parser for our config format
# Globals:
#   None
# Arguments:
#   $1 - Path to YAML file
# Returns:
#   0 on success, 1 on failure
#######################################
parse_yaml_config() {
    local yaml_file="$1"
    
    # For Phase 1, we'll use a simple approach
    # Phase 2 can integrate with yq or more sophisticated parsing
    
    # Check if file is valid YAML (basic check)
    if ! grep -q ":" "$yaml_file"; then
        print_error "Invalid YAML format"
        return 1
    fi
    
    # Store file path for get_config_value to use
    TECH_STACK_CONFIG[_config_file]="$yaml_file"
    
    return 0
}

#######################################
# Get configuration value from parsed YAML
# Globals:
#   TECH_STACK_CONFIG
# Arguments:
#   $1 - Config key (dot notation, e.g., "tech_stack.primary_language")
#   $2 - Default value (optional)
# Returns:
#   Config value or default
#######################################
get_config_value() {
    local key="$1"
    local default="${2:-}"
    local config_file="${TECH_STACK_CONFIG[_config_file]}"
    
    if [[ -z "$config_file" ]] || [[ ! -f "$config_file" ]]; then
        echo "$default"
        return 0
    fi
    
    # Convert dot notation to YAML path
    # e.g., "tech_stack.primary_language" -> find "primary_language:" under "tech_stack:"
    local value=""
    
    # Simple YAML parser for our use case
    if [[ "$key" == *"."* ]]; then
        local section="${key%%.*}"
        local field="${key#*.}"
        
        # Find value in section
        value=$(awk -v section="$section" -v field="$field" '
            BEGIN { in_section=0 }
            $0 ~ "^" section ":" { in_section=1; next }
            in_section && /^[^ ]/ { in_section=0 }
            in_section && $0 ~ "^[[:space:]]+" field ":" {
                sub(/^[[:space:]]+/, "")
                sub(/^[^:]+:[[:space:]]*/, "")
                gsub(/"/, "")
                gsub(/'\''/, "")
                print
                exit
            }
        ' "$config_file")
    else
        # Top-level field
        value=$(awk -v field="$key" '
            $0 ~ "^" field ":" {
                sub(/^[^:]+:[[:space:]]*/, "")
                gsub(/"/, "")
                gsub(/'\''/, "")
                print
                exit
            }
        ' "$config_file")
    fi
    
    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

#######################################
# Auto-detect project tech stack
# Globals:
#   PRIMARY_LANGUAGE
#   LANGUAGE_CONFIDENCE
# Arguments:
#   None
# Returns:
#   0 on success, 1 on failure
#######################################
detect_tech_stack() {
    print_info "Scanning project for tech stack indicators..."
    
    # Phase 2: Support all 8 languages
    
    # Detect all languages
    LANGUAGE_CONFIDENCE[javascript]=$(detect_javascript_project)
    LANGUAGE_CONFIDENCE[python]=$(detect_python_project)
    LANGUAGE_CONFIDENCE[go]=$(detect_go_project)
    LANGUAGE_CONFIDENCE[java]=$(detect_java_project)
    LANGUAGE_CONFIDENCE[ruby]=$(detect_ruby_project)
    LANGUAGE_CONFIDENCE[rust]=$(detect_rust_project)
    LANGUAGE_CONFIDENCE[cpp]=$(detect_cpp_project)
    LANGUAGE_CONFIDENCE[bash]=$(detect_bash_project)
    
    # Select primary language (highest score)
    local max_score=0
    local detected_language=""
    
    for lang in javascript python go java ruby rust cpp bash; do
        local score=${LANGUAGE_CONFIDENCE[$lang]}
        if [[ $score -gt $max_score ]]; then
            max_score=$score
            detected_language=$lang
        fi
    done
    
    if [[ $max_score -eq 0 ]]; then
        print_warning "No tech stack detected"
        return 1
    fi
    
    PRIMARY_LANGUAGE="$detected_language"
    
    # Set defaults based on detected language
    # Also update TECH_STACK_CONFIG array for export_tech_stack_variables()
    case "$PRIMARY_LANGUAGE" in
        javascript)
            BUILD_SYSTEM="npm"
            TEST_FRAMEWORK="jest"
            TEST_COMMAND="npm test"
            LINT_COMMAND="npm run lint"
            INSTALL_COMMAND="npm install"
            TECH_STACK_CONFIG[primary_language]="javascript"
            TECH_STACK_CONFIG[build_system]="npm"
            TECH_STACK_CONFIG[test_framework]="jest"
            TECH_STACK_CONFIG[test_command]="npm test"
            TECH_STACK_CONFIG[lint_command]="npm run lint"
            TECH_STACK_CONFIG[install_command]="npm install"
            TECH_STACK_CONFIG[package_file]="package.json"
            ;;
        python)
            BUILD_SYSTEM="pip"
            TEST_FRAMEWORK="pytest"
            TEST_COMMAND="pytest"
            LINT_COMMAND="pylint src/"
            INSTALL_COMMAND="pip install -r requirements.txt"
            TECH_STACK_CONFIG[primary_language]="python"
            TECH_STACK_CONFIG[build_system]="pip"
            TECH_STACK_CONFIG[test_framework]="pytest"
            TECH_STACK_CONFIG[test_command]="pytest"
            TECH_STACK_CONFIG[lint_command]="pylint src/"
            TECH_STACK_CONFIG[install_command]="pip install -r requirements.txt"
            TECH_STACK_CONFIG[package_file]="requirements.txt"
            ;;
        go)
            BUILD_SYSTEM="go mod"
            TEST_FRAMEWORK="go test"
            TEST_COMMAND="go test ./..."
            LINT_COMMAND="golangci-lint run"
            INSTALL_COMMAND="go mod download"
            TECH_STACK_CONFIG[primary_language]="go"
            TECH_STACK_CONFIG[build_system]="go mod"
            TECH_STACK_CONFIG[test_framework]="go test"
            TECH_STACK_CONFIG[test_command]="go test ./..."
            TECH_STACK_CONFIG[lint_command]="golangci-lint run"
            TECH_STACK_CONFIG[install_command]="go mod download"
            TECH_STACK_CONFIG[package_file]="go.mod"
            ;;
        java)
            BUILD_SYSTEM="maven"
            TEST_FRAMEWORK="junit"
            TEST_COMMAND="mvn test"
            LINT_COMMAND="mvn checkstyle:check"
            INSTALL_COMMAND="mvn install"
            TECH_STACK_CONFIG[primary_language]="java"
            TECH_STACK_CONFIG[build_system]="maven"
            TECH_STACK_CONFIG[test_framework]="junit"
            TECH_STACK_CONFIG[test_command]="mvn test"
            TECH_STACK_CONFIG[lint_command]="mvn checkstyle:check"
            TECH_STACK_CONFIG[install_command]="mvn install"
            TECH_STACK_CONFIG[package_file]="pom.xml"
            ;;
        ruby)
            BUILD_SYSTEM="bundler"
            TEST_FRAMEWORK="rspec"
            TEST_COMMAND="bundle exec rspec"
            LINT_COMMAND="rubocop"
            INSTALL_COMMAND="bundle install"
            TECH_STACK_CONFIG[primary_language]="ruby"
            TECH_STACK_CONFIG[build_system]="bundler"
            TECH_STACK_CONFIG[test_framework]="rspec"
            TECH_STACK_CONFIG[test_command]="bundle exec rspec"
            TECH_STACK_CONFIG[lint_command]="rubocop"
            TECH_STACK_CONFIG[install_command]="bundle install"
            TECH_STACK_CONFIG[package_file]="Gemfile"
            ;;
        rust)
            BUILD_SYSTEM="cargo"
            TEST_FRAMEWORK="cargo test"
            TEST_COMMAND="cargo test"
            LINT_COMMAND="cargo clippy"
            INSTALL_COMMAND="cargo fetch"
            TECH_STACK_CONFIG[primary_language]="rust"
            TECH_STACK_CONFIG[build_system]="cargo"
            TECH_STACK_CONFIG[test_framework]="cargo test"
            TECH_STACK_CONFIG[test_command]="cargo test"
            TECH_STACK_CONFIG[lint_command]="cargo clippy"
            TECH_STACK_CONFIG[install_command]="cargo fetch"
            TECH_STACK_CONFIG[package_file]="Cargo.toml"
            ;;
        cpp)
            BUILD_SYSTEM="cmake"
            TEST_FRAMEWORK="gtest"
            TEST_COMMAND="ctest --test-dir build"
            LINT_COMMAND="clang-tidy src/*.cpp"
            INSTALL_COMMAND="cmake -B build && cmake --build build"
            TECH_STACK_CONFIG[primary_language]="cpp"
            TECH_STACK_CONFIG[build_system]="cmake"
            TECH_STACK_CONFIG[test_framework]="gtest"
            TECH_STACK_CONFIG[test_command]="ctest --test-dir build"
            TECH_STACK_CONFIG[lint_command]="clang-tidy src/*.cpp"
            TECH_STACK_CONFIG[install_command]="cmake -B build && cmake --build build"
            TECH_STACK_CONFIG[package_file]="CMakeLists.txt"
            ;;
        bash)
            BUILD_SYSTEM="none"
            TEST_FRAMEWORK="bats"
            TEST_COMMAND="bats tests/"
            LINT_COMMAND="shellcheck *.sh"
            INSTALL_COMMAND="echo 'No installation needed'"
            TECH_STACK_CONFIG[primary_language]="bash"
            TECH_STACK_CONFIG[build_system]="none"
            TECH_STACK_CONFIG[test_framework]="bats"
            TECH_STACK_CONFIG[test_command]="bats tests/"
            TECH_STACK_CONFIG[lint_command]="shellcheck *.sh"
            TECH_STACK_CONFIG[install_command]="echo 'No installation needed'"
            TECH_STACK_CONFIG[package_file]=""
            ;;
    esac
    
    # Export variables
    export_tech_stack_variables
    
    # Cache
    init_tech_stack_cache
    
    log_to_workflow "INFO" "Detected tech stack: ${PRIMARY_LANGUAGE}/${BUILD_SYSTEM} (confidence: ${max_score}%)"
    
    return 0
}

#######################################
# Detect JavaScript/Node.js project
# Returns:
#   Confidence score (0-100)
#######################################
detect_javascript_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "package.json" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "package-lock.json" ]]; then
        score=$((score + 20))
    fi
    
    if [[ -d "node_modules" ]]; then
        score=$((score + 10))
    fi
    
    # Config files
    if [[ -f ".eslintrc" ]] || [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.json" ]]; then
        score=$((score + 10))
    fi
    
    if [[ -f "jest.config.js" ]] || [[ -f "jest.config.json" ]]; then
        score=$((score + 5))
    fi
    
    # Count JavaScript files - search deeper to catch organized projects
    local js_count=0
    js_count=$(find . -maxdepth 5 -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.mjs" \) \
               2>/dev/null | grep -v "node_modules" | grep -v ".git" | wc -l)
    
    if [[ $js_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $js_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $js_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Python project
# Returns:
#   Confidence score (0-100)
#######################################
detect_python_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "requirements.txt" ]]; then
        score=$((score + 40))
    fi
    
    if [[ -f "pyproject.toml" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "setup.py" ]]; then
        score=$((score + 35))
    fi
    
    if [[ -f "Pipfile" ]]; then
        score=$((score + 40))
    fi
    
    # Lock files
    if [[ -f "poetry.lock" ]]; then
        score=$((score + 20))
    fi
    
    if [[ -f "Pipfile.lock" ]]; then
        score=$((score + 20))
    fi
    
    # Virtual environment
    if [[ -d "venv" ]] || [[ -d ".venv" ]]; then
        score=$((score + 10))
    fi
    
    # Config files
    if [[ -f "pytest.ini" ]] || [[ -f "setup.cfg" ]]; then
        score=$((score + 5))
    fi
    
    # Count Python files - search deeper to catch organized projects
    local py_count=0
    py_count=$(find . -maxdepth 5 -type f -name "*.py" 2>/dev/null | \
               grep -v "__pycache__" | grep -v "venv" | grep -v ".venv" | grep -v ".git" | wc -l)
    
    if [[ $py_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $py_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $py_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Go project
# Returns:
#   Confidence score (0-100)
#######################################
detect_go_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "go.mod" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "go.sum" ]]; then
        score=$((score + 30))
    fi
    
    if [[ -f "Gopkg.toml" ]]; then
        score=$((score + 40))
    fi
    
    if [[ -f "Gopkg.lock" ]]; then
        score=$((score + 20))
    fi
    
    # Directories
    if [[ -d "vendor" ]]; then
        score=$((score + 10))
    fi
    
    # Config files
    if [[ -f ".golangci.yml" ]] || [[ -f ".golangci.yaml" ]]; then
        score=$((score + 5))
    fi
    
    # Count Go files
    local go_count=0
    go_count=$(find . -maxdepth 2 -type f -name "*.go" ! -path "*/vendor/*" 2>/dev/null | wc -l)
    
    if [[ $go_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $go_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $go_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Java project
# Returns:
#   Confidence score (0-100)
#######################################
detect_java_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "pom.xml" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "settings.gradle" ]]; then
        score=$((score + 20))
    fi
    
    if [[ -f "build.xml" ]]; then
        score=$((score + 40))
    fi
    
    # Directories
    if [[ -d "target" ]]; then
        score=$((score + 10))
    fi
    
    if [[ -d ".gradle" ]]; then
        score=$((score + 10))
    fi
    
    # Config files
    if [[ -f "checkstyle.xml" ]]; then
        score=$((score + 5))
    fi
    
    # Count Java files
    local java_count=0
    java_count=$(find . -maxdepth 3 -type f -name "*.java" ! -path "*/target/*" ! -path "*/.gradle/*" 2>/dev/null | wc -l)
    
    if [[ $java_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $java_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $java_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Ruby project
# Returns:
#   Confidence score (0-100)
#######################################
detect_ruby_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "Gemfile" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "Gemfile.lock" ]]; then
        score=$((score + 30))
    fi
    
    # Gemspec files
    local gemspec_count=0
    gemspec_count=$(find . -maxdepth 1 -type f -name "*.gemspec" 2>/dev/null | wc -l)
    if [[ $gemspec_count -gt 0 ]]; then
        score=$((score + 40))
    fi
    
    # Directories
    if [[ -d "vendor/bundle" ]]; then
        score=$((score + 10))
    fi
    
    if [[ -d ".bundle" ]]; then
        score=$((score + 5))
    fi
    
    # Config files
    if [[ -f ".rubocop.yml" ]]; then
        score=$((score + 5))
    fi
    
    if [[ -f "Rakefile" ]]; then
        score=$((score + 5))
    fi
    
    if [[ -f "config.ru" ]]; then
        score=$((score + 5))
    fi
    
    # Count Ruby files
    local rb_count=0
    rb_count=$(find . -maxdepth 2 -type f -name "*.rb" ! -path "*/vendor/*" 2>/dev/null | wc -l)
    
    if [[ $rb_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $rb_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $rb_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Rust project
# Returns:
#   Confidence score (0-100)
#######################################
detect_rust_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "Cargo.toml" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "Cargo.lock" ]]; then
        score=$((score + 30))
    fi
    
    # Directories
    if [[ -d "target" ]]; then
        score=$((score + 10))
    fi
    
    if [[ -d "src" ]] && [[ -f "Cargo.toml" ]]; then
        score=$((score + 5))
    fi
    
    # Config files
    if [[ -f "rustfmt.toml" ]] || [[ -f ".rustfmt.toml" ]]; then
        score=$((score + 5))
    fi
    
    if [[ -f "clippy.toml" ]]; then
        score=$((score + 3))
    fi
    
    # Count Rust files
    local rs_count=0
    rs_count=$(find . -maxdepth 3 -type f -name "*.rs" ! -path "*/target/*" 2>/dev/null | wc -l)
    
    if [[ $rs_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $rs_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $rs_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect C/C++ project
# Returns:
#   Confidence score (0-100)
#######################################
detect_cpp_project() {
    local score=0
    
    # High confidence signals
    if [[ -f "CMakeLists.txt" ]]; then
        score=$((score + 50))
    fi
    
    if [[ -f "Makefile" ]]; then
        score=$((score + 40))
    fi
    
    if [[ -f "configure.ac" ]] || [[ -f "configure.in" ]]; then
        score=$((score + 30))
    fi
    
    if [[ -f "meson.build" ]]; then
        score=$((score + 40))
    fi
    
    # Directories
    if [[ -d "build" ]] || [[ -d "cmake-build-debug" ]]; then
        score=$((score + 10))
    fi
    
    # Config files
    if [[ -f ".clang-format" ]]; then
        score=$((score + 5))
    fi
    
    if [[ -f ".clang-tidy" ]]; then
        score=$((score + 5))
    fi
    
    if [[ -f "compile_commands.json" ]]; then
        score=$((score + 5))
    fi
    
    # Count C/C++ files
    local cpp_count=0
    cpp_count=$(find . -maxdepth 3 -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.h" -o -name "*.hpp" \) ! -path "*/build/*" 2>/dev/null | wc -l)
    
    if [[ $cpp_count -gt 10 ]]; then
        score=$((score + 15))
    elif [[ $cpp_count -gt 5 ]]; then
        score=$((score + 10))
    elif [[ $cpp_count -gt 0 ]]; then
        score=$((score + 5))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Detect Bash/Shell project
# Returns:
#   Confidence score (0-100)
#######################################
detect_bash_project() {
    local score=0
    
    # Config files (strong signals for shell projects)
    if [[ -f ".shellcheckrc" ]]; then
        score=$((score + 30))
    fi
    
    if [[ -f "shfmt.conf" ]]; then
        score=$((score + 20))
    fi
    
    # Count shell files - search deeper (maxdepth 5) to catch lib/ and steps/ subdirectories
    local sh_count=0
    sh_count=$(find . -maxdepth 5 -type f \( -name "*.sh" -o -name "*.bash" \) 2>/dev/null | \
               grep -v "node_modules" | grep -v ".git" | grep -v "vendor" | wc -l)
    
    # Scoring based on shell script count
    if [[ $sh_count -gt 30 ]]; then
        score=$((score + 50))  # Large shell project (like this workflow automation)
    elif [[ $sh_count -gt 15 ]]; then
        score=$((score + 45))
    elif [[ $sh_count -gt 10 ]]; then
        score=$((score + 40))
    elif [[ $sh_count -gt 5 ]]; then
        score=$((score + 30))
    elif [[ $sh_count -gt 2 ]]; then
        score=$((score + 20))
    elif [[ $sh_count -gt 0 ]]; then
        score=$((score + 10))
    fi
    
    # Boost score if there are shell scripts in organized directories (lib/, bin/, scripts/)
    if find . -type d -name "lib" -o -name "bin" -o -name "scripts" 2>/dev/null | grep -q .; then
        local organized_scripts=0
        organized_scripts=$(find . -type f -name "*.sh" \( -path "*/lib/*" -o -path "*/bin/*" -o -path "*/scripts/*" \) 2>/dev/null | wc -l)
        if [[ $organized_scripts -gt 10 ]]; then
            score=$((score + 20))  # Well-organized shell project
        elif [[ $organized_scripts -gt 5 ]]; then
            score=$((score + 15))
        elif [[ $organized_scripts -gt 0 ]]; then
            score=$((score + 10))
        fi
    fi
    
    # Test files (bats or test_*.sh pattern)
    local test_count=0
    test_count=$(find . -maxdepth 5 -type f \( -name "*.bats" -o -name "test_*.sh" \) 2>/dev/null | wc -l)
    if [[ $test_count -gt 5 ]]; then
        score=$((score + 15))
    elif [[ $test_count -gt 0 ]]; then
        score=$((score + 10))
    fi
    
    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi
    
    echo "$score"
}

#######################################
# Get confidence score for a language
# Arguments:
#   $1 - Language name
# Returns:
#   Confidence score (0-100)
#######################################
get_confidence_score() {
    local language="$1"
    echo "${LANGUAGE_CONFIDENCE[$language]:-0}"
}

#######################################
# Load default tech stack (JavaScript/Node.js)
# Maintains backward compatibility with v2.4.0
# Globals:
#   PRIMARY_LANGUAGE
#   BUILD_SYSTEM
# Returns:
#   0
#######################################
load_default_tech_stack() {
    print_info "Loading default tech stack: JavaScript/Node.js"
    
    PRIMARY_LANGUAGE="javascript"
    BUILD_SYSTEM="npm"
    TEST_FRAMEWORK="jest"
    TEST_COMMAND="npm test"
    LINT_COMMAND="npm run lint"
    INSTALL_COMMAND="npm install"
    
    TECH_STACK_CONFIG[primary_language]="javascript"
    TECH_STACK_CONFIG[build_system]="npm"
    TECH_STACK_CONFIG[test_framework]="jest"
    TECH_STACK_CONFIG[package_file]="package.json"
    
    export_tech_stack_variables
    init_tech_stack_cache
    
    log_to_workflow "INFO" "Using default tech stack: JavaScript/npm"
    
    return 0
}

#######################################
# Export tech stack variables to environment
# Globals:
#   PRIMARY_LANGUAGE
#   BUILD_SYSTEM
# Returns:
#   0
#######################################
export_tech_stack_variables() {
    export PRIMARY_LANGUAGE="${TECH_STACK_CONFIG[primary_language]:-javascript}"
    export BUILD_SYSTEM="${TECH_STACK_CONFIG[build_system]:-npm}"
    export TEST_FRAMEWORK="${TECH_STACK_CONFIG[test_framework]:-jest}"
    export TEST_COMMAND="${TECH_STACK_CONFIG[test_command]:-npm test}"
    export LINT_COMMAND="${TECH_STACK_CONFIG[lint_command]:-npm run lint}"
    export INSTALL_COMMAND="${TECH_STACK_CONFIG[install_command]:-npm install}"
    
    return 0
}

#######################################
# Initialize tech stack cache for performance
# Globals:
#   TECH_STACK_CACHE
# Returns:
#   0
#######################################
init_tech_stack_cache() {
    TECH_STACK_CACHE[primary_language]="$PRIMARY_LANGUAGE"
    TECH_STACK_CACHE[build_system]="$BUILD_SYSTEM"
    TECH_STACK_CACHE[test_framework]="$TEST_FRAMEWORK"
    TECH_STACK_CACHE[test_command]="$TEST_COMMAND"
    TECH_STACK_CACHE[lint_command]="$LINT_COMMAND"
    TECH_STACK_CACHE[install_command]="$INSTALL_COMMAND"
    
    return 0
}

#######################################
# Get tech stack property
# Arguments:
#   $1 - Property name
#   $2 - Default value (optional)
# Returns:
#   Property value
#######################################
get_tech_stack_property() {
    local property="$1"
    local default="${2:-}"
    
    # Check cache first
    if [[ -n "${TECH_STACK_CACHE[$property]:-}" ]]; then
        echo "${TECH_STACK_CACHE[$property]}"
        return 0
    fi
    
    # Check config
    if [[ -n "${TECH_STACK_CONFIG[$property]:-}" ]]; then
        echo "${TECH_STACK_CONFIG[$property]}"
        return 0
    fi
    
    echo "$default"
}

#######################################
# Print tech stack summary
# Globals:
#   PRIMARY_LANGUAGE
#   BUILD_SYSTEM
# Returns:
#   0
#######################################
print_tech_stack_summary() {
    # Use color variables if available, otherwise plain text
    local cyan="${COLOR_CYAN:-}"
    local reset="${COLOR_RESET:-}"
    
    echo ""
    print_header "Tech Stack Configuration"
    echo ""
    echo "  ${cyan}Primary Language:${reset} $PRIMARY_LANGUAGE"
    echo "  ${cyan}Build System:${reset}     $BUILD_SYSTEM"
    echo "  ${cyan}Test Framework:${reset}   $TEST_FRAMEWORK"
    
    if [[ -n "${TECH_STACK_CONFIG[package_file]:-}" ]]; then
        echo "  ${cyan}Package File:${reset}     ${TECH_STACK_CONFIG[package_file]}"
    fi
    
    local confidence=$(get_confidence_score "$PRIMARY_LANGUAGE")
    if [[ $confidence -gt 0 ]]; then
        echo "  ${cyan}Detection Confidence:${reset} ${confidence}%"
    fi
    
    echo ""
    
    return 0
}

#######################################
# Check if language is supported
# Arguments:
#   $1 - Language name
# Returns:
#   0 if supported, 1 if not
#######################################
is_language_supported() {
    local language="$1"
    
    # Phase 2: All 8 languages supported
    case "$language" in
        javascript|python|go|java|ruby|rust|cpp|bash)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#######################################
# Get list of supported languages
# Returns:
#   Space-separated list of languages
#######################################
get_supported_languages() {
    # Phase 2: All 8 languages
    echo "javascript python go java ruby rust cpp bash"
}

#######################################
# Get source file extensions for current language
# Returns:
#   Space-separated list of extensions (e.g., ".js .jsx .ts")
#######################################
get_source_extensions() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    case "$language" in
        javascript)
            echo ".js .jsx .mjs .cjs .ts .tsx"
            ;;
        python)
            echo ".py .pyw .pyx"
            ;;
        go)
            echo ".go"
            ;;
        java)
            echo ".java"
            ;;
        ruby)
            echo ".rb .rake .gemspec"
            ;;
        rust)
            echo ".rs"
            ;;
        cpp)
            echo ".c .cpp .cc .cxx .h .hpp .hxx"
            ;;
        bash)
            echo ".sh .bash"
            ;;
        *)
            echo ".js .jsx .ts"  # Default to JavaScript
            ;;
    esac
}

#######################################
# Get test file patterns for current language
# Returns:
#   Space-separated list of patterns
#######################################
get_test_patterns() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    case "$language" in
        javascript)
            echo "*.test.js *.spec.js *.test.ts *.spec.ts"
            ;;
        python)
            echo "test_*.py *_test.py"
            ;;
        go)
            echo "*_test.go"
            ;;
        java)
            echo "*Test.java *Tests.java Test*.java"
            ;;
        ruby)
            echo "*_spec.rb test_*.rb"
            ;;
        rust)
            echo "tests/*"
            ;;
        cpp)
            echo "*_test.cpp test_*.cpp *_test.c test_*.c"
            ;;
        bash)
            echo "*_test.sh test_*.sh *.bats"
            ;;
        *)
            echo "*.test.js *.spec.js"  # Default to JavaScript
            ;;
    esac
}

#######################################
# Get exclude directory patterns for current language
# Returns:
#   Space-separated list of directories to exclude
#######################################
get_exclude_patterns() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    case "$language" in
        javascript)
            echo "node_modules dist build coverage .next out"
            ;;
        python)
            echo "venv .venv __pycache__ .pytest_cache dist build *.egg-info"
            ;;
        go)
            echo "vendor bin pkg"
            ;;
        java)
            echo "target build .gradle out"
            ;;
        ruby)
            echo "vendor/bundle .bundle tmp log"
            ;;
        rust)
            echo "target"
            ;;
        cpp)
            echo "build cmake-build-debug .deps obj"
            ;;
        bash)
            echo ""  # Bash typically has no exclude dirs
            ;;
        *)
            echo "node_modules dist build"  # Default to JavaScript
            ;;
    esac
}

#######################################
# Find source files for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   List of source files (one per line)
#######################################
find_source_files() {
    local extensions=$(get_source_extensions)
    local exclude_patterns=$(get_exclude_patterns)
    
    # Build find command with extensions
    local find_cmd="find . -type f"
    
    # Add extension filters
    local first=true
    find_cmd="$find_cmd \("
    for ext in $extensions; do
        if [[ "$first" == "true" ]]; then
            find_cmd="$find_cmd -name \"*${ext}\""
            first=false
        else
            find_cmd="$find_cmd -o -name \"*${ext}\""
        fi
    done
    find_cmd="$find_cmd \)"
    
    # Add exclude patterns
    for exclude in $exclude_patterns; do
        find_cmd="$find_cmd ! -path \"*/${exclude}/*\""
    done
    
    # Execute find command
    eval "$find_cmd" 2>/dev/null | sort
}

#######################################
# Find test files for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   List of test files (one per line)
#######################################
find_test_files() {
    local patterns=$(get_test_patterns)
    local exclude_patterns=$(get_exclude_patterns)
    
    # Build find command with patterns
    local find_cmd="find . -type f"
    
    # Add test file patterns
    local first=true
    find_cmd="$find_cmd \("
    for pattern in $patterns; do
        if [[ "$first" == "true" ]]; then
            find_cmd="$find_cmd -name \"${pattern}\""
            first=false
        else
            find_cmd="$find_cmd -o -name \"${pattern}\""
        fi
    done
    find_cmd="$find_cmd \)"
    
    # Add exclude patterns
    for exclude in $exclude_patterns; do
        find_cmd="$find_cmd ! -path \"*/${exclude}/*\""
    done
    
    # Execute find command
    eval "$find_cmd" 2>/dev/null | sort
}

#######################################
# Get language-specific command
# Arguments:
#   $1 - Command type (install, test, lint, build, clean)
# Returns:
#   Command string
#######################################
get_language_command() {
    local cmd_type="$1"
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    # Try to return cached command if available
    case "$cmd_type" in
        install)
            if [[ -n "${INSTALL_COMMAND:-}" ]]; then
                echo "${INSTALL_COMMAND}"
                return 0
            fi
            # Fallback: hardcoded commands by language
            case "$language" in
                javascript) echo "npm install" ;;
                python) echo "pip install -r requirements.txt" ;;
                go) echo "go mod download" ;;
                java) echo "mvn install" ;;
                ruby) echo "bundle install" ;;
                rust) echo "cargo fetch" ;;
                cpp) echo "cmake -B build && cmake --build build" ;;
                bash) echo "echo 'No installation needed'" ;;
                *) echo "" ;;
            esac
            ;;
        test)
            if [[ -n "${TEST_COMMAND:-}" ]]; then
                echo "${TEST_COMMAND}"
                return 0
            fi
            # Fallback: hardcoded commands by language
            case "$language" in
                javascript) echo "npm test" ;;
                python) echo "pytest" ;;
                go) echo "go test ./..." ;;
                java) echo "mvn test" ;;
                ruby) echo "bundle exec rspec" ;;
                rust) echo "cargo test" ;;
                cpp) echo "ctest --test-dir build" ;;
                bash) echo "bats tests/" ;;
                *) echo "" ;;
            esac
            ;;
        test_verbose)
            # Verbose test commands
            case "$language" in
                javascript) echo "npm test -- --verbose" ;;
                python) echo "pytest -v" ;;
                go) echo "go test -v ./..." ;;
                java) echo "mvn test -X" ;;
                ruby) echo "bundle exec rspec --format documentation" ;;
                rust) echo "cargo test -- --nocapture" ;;
                cpp) echo "ctest --test-dir build --verbose" ;;
                bash) echo "bats -t tests/" ;;
                *) echo "" ;;
            esac
            ;;
        test_coverage)
            # Test coverage commands
            case "$language" in
                javascript) echo "npm test -- --coverage" ;;
                python) echo "pytest --cov" ;;
                go) echo "go test -cover ./..." ;;
                java) echo "mvn test jacoco:report" ;;
                ruby) echo "bundle exec rspec --coverage" ;;
                rust) echo "cargo tarpaulin" ;;
                cpp) echo "ctest --test-dir build --coverage" ;;
                bash) echo "echo 'Coverage not available for bash'" ;;
                *) echo "" ;;
            esac
            ;;
        lint)
            if [[ -n "${LINT_COMMAND:-}" ]]; then
                echo "${LINT_COMMAND}"
                return 0
            fi
            # Fallback: hardcoded commands by language
            case "$language" in
                javascript) echo "npm run lint" ;;
                python) echo "pylint src/" ;;
                go) echo "golangci-lint run" ;;
                java) echo "mvn checkstyle:check" ;;
                ruby) echo "rubocop" ;;
                rust) echo "cargo clippy" ;;
                cpp) echo "clang-tidy src/*.cpp" ;;
                bash) echo "shellcheck *.sh" ;;
                *) echo "" ;;
            esac
            ;;
        format)
            # Code formatting commands
            case "$language" in
                javascript) echo "npm run format" ;;
                python) echo "black src/" ;;
                go) echo "go fmt ./..." ;;
                java) echo "mvn formatter:format" ;;
                ruby) echo "rubocop -a" ;;
                rust) echo "cargo fmt" ;;
                cpp) echo "clang-format -i src/*.cpp" ;;
                bash) echo "shfmt -w *.sh" ;;
                *) echo "" ;;
            esac
            ;;
        type_check)
            # Type checking commands
            case "$language" in
                javascript) echo "tsc --noEmit" ;;
                python) echo "mypy src/" ;;
                go) echo "go vet ./..." ;;
                java) echo "echo 'Type checking built-in'" ;;
                ruby) echo "sorbet tc" ;;
                rust) echo "cargo check" ;;
                cpp) echo "echo 'Type checking built-in'" ;;
                bash) echo "echo 'No type checking for bash'" ;;
                *) echo "" ;;
            esac
            ;;
        build)
            # Build commands
            case "$language" in
                javascript) echo "npm run build" ;;
                python) echo "python setup.py build" ;;
                go) echo "go build ./..." ;;
                java) echo "mvn package" ;;
                ruby) echo "bundle exec rake build" ;;
                rust) echo "cargo build" ;;
                cpp) echo "cmake --build build" ;;
                bash) echo "echo 'No build needed'" ;;
                *) echo "" ;;
            esac
            ;;
        clean)
            # Clean commands
            case "$language" in
                javascript) echo "rm -rf node_modules dist build" ;;
                python) echo "find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true" ;;
                go) echo "go clean" ;;
                java) echo "mvn clean" ;;
                ruby) echo "rm -rf vendor/bundle .bundle" ;;
                rust) echo "cargo clean" ;;
                cpp) echo "rm -rf build" ;;
                bash) echo "echo 'No cleanup needed'" ;;
                *) echo "" ;;
            esac
            ;;
        *)
            echo ""
            ;;
    esac
}

#######################################
# Execute a language-specific command with error handling
# Arguments:
#   $1 - Command to execute
# Returns:
#   0 on success, 1 on failure
#######################################
# Get install command for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Install command string
#######################################
get_install_command() {
    get_language_command "install"
}

#######################################
# Get test command for current language
# Globals:
#   PRIMARY_LANGUAGE
#   TEST_COMMAND (if set manually)
# Returns:
#   Test command string
#######################################
get_test_command() {
    # Use manually configured command if available
    if [[ -n "${TEST_COMMAND:-}" ]]; then
        echo "$TEST_COMMAND"
        return 0
    fi
    
    get_language_command "test"
}

#######################################
# Get test command with verbose output
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Verbose test command string
#######################################
get_test_verbose_command() {
    get_language_command "test_verbose"
}

#######################################
# Get test coverage command
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Test coverage command string
#######################################
get_test_coverage_command() {
    get_language_command "test_coverage"
}

#######################################
# Get lint command for current language
# Globals:
#   PRIMARY_LANGUAGE
#   LINT_COMMAND (if set manually)
# Returns:
#   Lint command string
#######################################
get_lint_command() {
    # Use manually configured command if available
    if [[ -n "${LINT_COMMAND:-}" ]]; then
        echo "$LINT_COMMAND"
        return 0
    fi
    
    get_language_command "lint"
}

#######################################
# Get format command for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Format command string
#######################################
get_format_command() {
    get_language_command "format"
}

#######################################
# Get build command for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Build command string
#######################################
get_build_command() {
    get_language_command "build"
}

#######################################
# Get clean command for current language
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Clean command string
#######################################
get_clean_command() {
    get_language_command "clean"
}

#######################################
# Execute a language-specific command
# Arguments:
#   $1 - Command to execute
#   $2 - Optional description for logging
# Returns:
#   0 on success, 1 on failure
#######################################
execute_language_command() {
    local cmd="$1"
    local description="${2:-Command}"
    
    if [[ -z "$cmd" ]]; then
        print_warning "No command specified for: $description"
        return 0
    fi
    
    print_info "Executing $description: $cmd"
    
    if eval "$cmd"; then
        print_success "$description completed successfully"
        return 0
    else
        local exit_code=$?
        print_error "$description failed (exit code: $exit_code)"
        return $exit_code
    fi
}

# Export functions for use in other modules
export -f init_tech_stack
export -f load_tech_stack_config
export -f detect_tech_stack
export -f get_tech_stack_property
export -f is_language_supported
export -f get_supported_languages
export -f print_tech_stack_summary
export -f get_source_extensions
export -f get_test_patterns
export -f get_exclude_patterns
export -f find_source_files
export -f find_test_files
export -f get_language_command
export -f get_install_command
export -f get_test_command
export -f get_test_verbose_command
export -f get_test_coverage_command
export -f get_lint_command
export -f get_format_command
export -f get_build_command
export -f get_clean_command
export -f execute_language_command
