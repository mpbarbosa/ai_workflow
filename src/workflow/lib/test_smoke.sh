#!/bin/bash
set -euo pipefail

################################################################################
# Test Smoke Test Module
# Purpose: Quick validation of test infrastructure before full workflow
# Part of: Tests & Documentation Workflow Automation v2.6.1
# Version: 1.0.1
################################################################################

# Perform a quick smoke test of the test infrastructure
# Returns: 0 if tests can run, 1 if there are issues
# Args: none (uses global TEST_COMMAND or auto-detects)
smoke_test_infrastructure() {
    local test_dir="${TARGET_DIR:-$PROJECT_ROOT}"
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    print_info "🔍 Running test infrastructure smoke test..."
    
    # Check if we're in the right directory
    if [[ ! -d "$test_dir" ]]; then
        print_error "Test directory not found: $test_dir"
        return 1
    fi
    
    cd "$test_dir" || return 1
    
    # Get test command
    local test_cmd=""
    if command -v get_test_command &>/dev/null; then
        test_cmd=$(get_test_command)
    elif [[ -n "${TEST_COMMAND:-}" ]]; then
        test_cmd="${TEST_COMMAND}"
    else
        # Auto-detect based on language
        case "$language" in
            javascript|typescript)
                if [[ -f "package.json" ]]; then
                    if grep -q '"test"' package.json 2>/dev/null; then
                        test_cmd="npm test"
                    else
                        print_warning "No test script found in package.json"
                        return 1
                    fi
                fi
                ;;
            python)
                if [[ -f "pytest.ini" ]] || [[ -f "setup.py" ]]; then
                    test_cmd="pytest --collect-only"
                elif command -v python -m unittest discover &>/dev/null; then
                    test_cmd="python -m unittest discover --start-directory tests --pattern '*test*.py' --quiet"
                fi
                ;;
            bash)
                print_info "Bash project - no test framework required"
                return 0
                ;;
            *)
                print_warning "Unknown language: $language - skipping smoke test"
                return 0
                ;;
        esac
    fi
    
    if [[ -z "$test_cmd" ]]; then
        print_warning "No test command configured"
        return 1
    fi
    
    # Check test dependencies
    print_info "Checking test dependencies..."
    case "$language" in
        javascript|typescript)
            if [[ ! -d "node_modules" ]]; then
                print_error "node_modules not found. Run 'npm install' first."
                return 1
            fi
            
            # Check if test runner is installed
            local test_runner=""
            if grep -q '"jest"' package.json 2>/dev/null; then
                test_runner="jest"
            elif grep -q '"mocha"' package.json 2>/dev/null; then
                test_runner="mocha"
            elif grep -q '"vitest"' package.json 2>/dev/null; then
                test_runner="vitest"
            fi
            
            if [[ -n "$test_runner" ]] && [[ ! -d "node_modules/$test_runner" ]]; then
                print_error "Test runner '$test_runner' not installed"
                return 1
            fi
            ;;
        python)
            if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
                print_error "Python not found in PATH"
                return 1
            fi
            
            if [[ "$test_cmd" == *"pytest"* ]] && ! command -v pytest &>/dev/null; then
                print_error "pytest not installed"
                return 1
            fi
            ;;
    esac
    
    # Try a dry run / list tests
    print_info "Validating test command: $test_cmd"
    local smoke_cmd=""
    
    case "$language" in
        javascript|typescript)
            # Jest: list tests without running
            if [[ "$test_cmd" == *"jest"* ]]; then
                smoke_cmd="${test_cmd} --listTests --silent"
            # Mocha: dry run
            elif [[ "$test_cmd" == *"mocha"* ]]; then
                smoke_cmd="${test_cmd} --dry-run"
            # Vitest: list files
            elif [[ "$test_cmd" == *"vitest"* ]]; then
                smoke_cmd="${test_cmd} --run --reporter=verbose --maxWorkers=1 --bail=1"
            # Generic npm test - try to validate package.json
            else
                if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
                    print_success "Test script found in package.json"
                    return 0
                fi
            fi
            ;;
        python)
            # pytest: collect only
            if [[ "$test_cmd" == *"pytest"* ]]; then
                smoke_cmd="${test_cmd} --collect-only -q"
            # unittest: list tests
            elif [[ "$test_cmd" == *"unittest"* ]]; then
                # unittest discover with pattern
                smoke_cmd="$test_cmd"
            fi
            ;;
    esac
    
    if [[ -n "$smoke_cmd" ]]; then
        print_info "Running: $smoke_cmd"
        local output
        local exit_code=0
        
        # Run with timeout
        if output=$(timeout 10 bash -c "$smoke_cmd" 2>&1); then
            exit_code=$?
        else
            exit_code=$?
        fi
        
        if [[ $exit_code -eq 0 ]]; then
            # Count tests found
            local test_count=0
            if [[ "$output" =~ ([0-9]+)\ test ]]; then
                test_count="${BASH_REMATCH[1]}"
            fi
            
            if [[ $test_count -gt 0 ]]; then
                print_success "✓ Found $test_count test(s) - infrastructure OK"
            else
                print_success "✓ Test infrastructure validated"
            fi
            return 0
        else
            print_error "Test infrastructure validation failed"
            echo "Output:"
            echo "$output" | head -20
            return 1
        fi
    fi
    
    # If we couldn't run a smoke test but have a test command, assume it's OK
    print_info "✓ Test command configured: $test_cmd"
    print_info "  (Will run full validation in Step 7)"
    return 0
}

# Export functions
export -f smoke_test_infrastructure

################################################################################
# Module initialized
################################################################################
