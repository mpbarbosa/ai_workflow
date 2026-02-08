#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Deployment Validator Module
# Version: 1.0.0
# Purpose: Pre-deployment validation and dry-run checks
#
# Features:
#   - Environment variable validation
#   - Dependency checking (npm, pip, etc.)
#   - Configuration file validation
#   - Build artifact verification
#   - Port availability checking
#   - Database connection validation
#   - API endpoint health checks
#   - Security audit (secrets detection)
#   - Tech-stack aware validation
#
# Integration: Can be used as Step 17 or in CI/CD pipelines
################################################################################

# Set defaults
DEPLOYMENT_REPORT_DIR="${WORKFLOW_HOME:-$(pwd)}/deployment_reports"
REQUIRED_ENV_VARS=()
OPTIONAL_ENV_VARS=()

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize deployment validator
init_deployment_validator() {
    mkdir -p "$DEPLOYMENT_REPORT_DIR"
    
    # Source tech stack detection if available
    local lib_dir="${WORKFLOW_HOME}/lib"
    if [[ -f "${lib_dir}/tech_stack.sh" ]]; then
        source "${lib_dir}/tech_stack.sh"
    fi
    
    print_info "Deployment validator initialized"
    return 0
}

# ==============================================================================
# ENVIRONMENT VALIDATION
# ==============================================================================

# Check if required environment variables are set
# Args: $@ = list of required environment variable names
# Returns: Count of missing variables
check_required_env_vars() {
    local missing_count=0
    local missing_vars=()
    
    for var in "$@"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
            ((missing_count++))
        fi
    done
    
    if [[ $missing_count -gt 0 ]]; then
        print_error "Missing required environment variables: ${missing_vars[*]}"
        return $missing_count
    else
        print_success "All required environment variables are set"
        return 0
    fi
}

# Load environment variables from file
# Args: $1 = env file path (e.g., .env)
# Returns: Count of loaded variables
load_env_file() {
    local env_file="$1"
    local loaded_count=0
    
    [[ ! -f "$env_file" ]] && { print_error "Environment file not found: $env_file"; return 1; }
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
        # Remove quotes from value
        value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
        
        # Export variable
        export "$key"="$value"
        ((loaded_count++))
    done < "$env_file"
    
    print_info "Loaded $loaded_count environment variables from $env_file"
    return 0
}

# Validate environment configuration
# Args: $1 = environment name (dev, staging, production)
validate_environment_config() {
    local env_name="${1:-production}"
    local errors=0
    
    print_info "Validating ${env_name} environment configuration..."
    
    # Check for environment-specific config files
    local config_files=(
        ".env"
        ".env.${env_name}"
        "config/${env_name}.yaml"
        "config/${env_name}.json"
    )
    
    local found_config=false
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            print_success "Found configuration: $config_file"
            found_config=true
        fi
    done
    
    if ! $found_config; then
        print_warning "No environment-specific configuration files found"
    fi
    
    # Environment-specific checks
    case "$env_name" in
        production|prod)
            # Production must have stricter requirements
            REQUIRED_ENV_VARS+=(
                "NODE_ENV"
                "DATABASE_URL"
            )
            
            # Check NODE_ENV is set to production
            if [[ "${NODE_ENV:-}" != "production" ]]; then
                print_error "NODE_ENV must be 'production' for production deployment"
                ((errors++))
            fi
            
            # Check for development dependencies
            if [[ -f "package.json" ]] && grep -q '"devDependencies"' package.json; then
                print_warning "Production build should not include devDependencies"
            fi
            ;;
        staging|stage)
            REQUIRED_ENV_VARS+=("NODE_ENV")
            ;;
        development|dev)
            # Development can be more lenient
            ;;
    esac
    
    return $errors
}

# ==============================================================================
# DEPENDENCY VALIDATION
# ==============================================================================

# Check Node.js dependencies
# Returns: 0 if valid, 1 if issues found
validate_node_dependencies() {
    [[ ! -f "package.json" ]] && return 0
    
    print_info "Validating Node.js dependencies..."
    
    local errors=0
    
    # Check if node_modules exists
    if [[ ! -d "node_modules" ]]; then
        print_error "node_modules not found - run 'npm install' first"
        ((errors++))
        return $errors
    fi
    
    # Check for outdated packages
    if command -v npm &>/dev/null; then
        local outdated=$(npm outdated --json 2>/dev/null || echo "{}")
        local outdated_count=$(echo "$outdated" | jq 'length' 2>/dev/null || echo 0)
        
        if [[ $outdated_count -gt 0 ]]; then
            print_warning "Found $outdated_count outdated packages"
            echo "$outdated" | jq -r 'to_entries[] | "  - \(.key): \(.value.current) → \(.value.latest)"' 2>/dev/null || true
        fi
    fi
    
    # Check for security vulnerabilities
    if command -v npm &>/dev/null; then
        print_info "Running security audit..."
        if npm audit --audit-level=high --production 2>&1 | grep -q "found 0 vulnerabilities"; then
            print_success "No high/critical vulnerabilities found"
        else
            print_error "Security vulnerabilities detected"
            npm audit --audit-level=high --production 2>&1 | head -20
            ((errors++))
        fi
    fi
    
    return $errors
}

# Check Python dependencies
# Returns: 0 if valid, 1 if issues found
validate_python_dependencies() {
    [[ ! -f "requirements.txt" ]] && [[ ! -f "Pipfile" ]] && [[ ! -f "pyproject.toml" ]] && return 0
    
    print_info "Validating Python dependencies..."
    
    local errors=0
    local python_cmd=""
    
    # Find Python command
    if command -v python3 &>/dev/null; then
        python_cmd="python3"
    elif command -v python &>/dev/null; then
        python_cmd="python"
    else
        print_error "Python not found"
        return 1
    fi
    
    # Check if virtualenv is activated
    if [[ -z "${VIRTUAL_ENV:-}" ]]; then
        print_warning "No virtual environment activated"
    fi
    
    # Check requirements.txt
    if [[ -f "requirements.txt" ]]; then
        while IFS= read -r requirement; do
            [[ "$requirement" =~ ^#.*$ || -z "$requirement" ]] && continue
            
            local package=$(echo "$requirement" | sed -E 's/([a-zA-Z0-9_-]+).*/\1/')
            
            if ! $python_cmd -c "import $package" 2>/dev/null; then
                print_error "Missing package: $package"
                ((errors++))
            fi
        done < requirements.txt
    fi
    
    # Check for security issues with pip-audit (if available)
    if command -v pip-audit &>/dev/null; then
        print_info "Running security audit..."
        if ! pip-audit --desc 2>&1; then
            print_warning "Security issues detected in Python dependencies"
        fi
    fi
    
    return $errors
}

# Validate dependencies based on tech stack
# Returns: 0 if valid, 1 if issues found
validate_dependencies() {
    local errors=0
    
    print_info "Validating project dependencies..."
    
    # Node.js/JavaScript
    if [[ -f "package.json" ]]; then
        validate_node_dependencies || ((errors+=$?))
    fi
    
    # Python
    if [[ -f "requirements.txt" ]] || [[ -f "Pipfile" ]] || [[ -f "pyproject.toml" ]]; then
        validate_python_dependencies || ((errors+=$?))
    fi
    
    # Go
    if [[ -f "go.mod" ]]; then
        if command -v go &>/dev/null; then
            print_info "Validating Go dependencies..."
            if go mod verify 2>&1; then
                print_success "Go dependencies verified"
            else
                print_error "Go dependency verification failed"
                ((errors++))
            fi
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        print_success "All dependencies validated"
    else
        print_error "Dependency validation failed with $errors errors"
    fi
    
    return $errors
}

# ==============================================================================
# CONFIGURATION VALIDATION
# ==============================================================================

# Validate JSON configuration file
# Args: $1 = file path
# Returns: 0 if valid, 1 if invalid
validate_json_config() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    if command -v jq &>/dev/null; then
        if jq empty "$file" 2>/dev/null; then
            print_success "Valid JSON: $file"
            return 0
        else
            print_error "Invalid JSON: $file"
            return 1
        fi
    else
        print_warning "jq not available - skipping JSON validation"
        return 0
    fi
}

# Validate YAML configuration file
# Args: $1 = file path
# Returns: 0 if valid, 1 if invalid
validate_yaml_config() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    if command -v yamllint &>/dev/null; then
        if yamllint "$file" 2>&1; then
            print_success "Valid YAML: $file"
            return 0
        else
            print_error "Invalid YAML: $file"
            return 1
        fi
    elif command -v python3 &>/dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>&1; then
            print_success "Valid YAML: $file"
            return 0
        else
            print_error "Invalid YAML: $file"
            return 1
        fi
    else
        print_warning "YAML validation tools not available - skipping"
        return 0
    fi
}

# Validate all configuration files
# Returns: Count of invalid config files
validate_config_files() {
    local errors=0
    
    print_info "Validating configuration files..."
    
    # Find and validate JSON files
    while IFS= read -r json_file; do
        validate_json_config "$json_file" || ((errors++))
    done < <(find . -name "*.json" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)
    
    # Find and validate YAML files
    while IFS= read -r yaml_file; do
        validate_yaml_config "$yaml_file" || ((errors++))
    done < <(find . \( -name "*.yaml" -o -name "*.yml" \) -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)
    
    return $errors
}

# ==============================================================================
# BUILD & ARTIFACT VALIDATION
# ==============================================================================

# Validate build artifacts exist
# Returns: 0 if valid, 1 if missing artifacts
validate_build_artifacts() {
    print_info "Validating build artifacts..."
    
    local errors=0
    local expected_artifacts=()
    
    # Detect build artifacts based on project type
    if [[ -f "package.json" ]]; then
        if [[ -d "dist" ]]; then
            expected_artifacts+=("dist")
        fi
        if [[ -d "build" ]]; then
            expected_artifacts+=("build")
        fi
    fi
    
    if [[ -f "setup.py" ]]; then
        if [[ -d "dist" ]]; then
            expected_artifacts+=("dist")
        fi
    fi
    
    if [[ ${#expected_artifacts[@]} -eq 0 ]]; then
        print_warning "No build artifacts expected (or project doesn't require build)"
        return 0
    fi
    
    for artifact in "${expected_artifacts[@]}"; do
        if [[ -d "$artifact" ]] && [[ -n "$(ls -A "$artifact" 2>/dev/null)" ]]; then
            print_success "Build artifact exists: $artifact"
        else
            print_error "Missing or empty build artifact: $artifact"
            ((errors++))
        fi
    done
    
    return $errors
}

# ==============================================================================
# RUNTIME VALIDATION
# ==============================================================================

# Check port availability
# Args: $1 = port number
# Returns: 0 if available, 1 if in use
check_port_available() {
    local port="$1"
    
    if command -v nc &>/dev/null; then
        if nc -z localhost "$port" 2>/dev/null; then
            print_error "Port $port is already in use"
            return 1
        else
            print_success "Port $port is available"
            return 0
        fi
    elif command -v lsof &>/dev/null; then
        if lsof -i ":$port" &>/dev/null; then
            print_error "Port $port is already in use"
            return 1
        else
            print_success "Port $port is available"
            return 0
        fi
    else
        print_warning "Cannot check port availability (nc or lsof not found)"
        return 0
    fi
}

# Check database connection
# Args: $1 = database URL (optional, uses DATABASE_URL env var)
# Returns: 0 if connected, 1 if failed
check_database_connection() {
    local db_url="${1:-${DATABASE_URL:-}}"
    
    [[ -z "$db_url" ]] && { print_warning "No database URL provided"; return 0; }
    
    print_info "Checking database connection..."
    
    # Parse database type from URL
    if [[ "$db_url" =~ ^postgres ]]; then
        if command -v psql &>/dev/null; then
            if psql "$db_url" -c "SELECT 1" &>/dev/null; then
                print_success "PostgreSQL connection successful"
                return 0
            else
                print_error "PostgreSQL connection failed"
                return 1
            fi
        fi
    elif [[ "$db_url" =~ ^mysql ]]; then
        if command -v mysql &>/dev/null; then
            if mysql "$db_url" -e "SELECT 1" &>/dev/null; then
                print_success "MySQL connection successful"
                return 0
            else
                print_error "MySQL connection failed"
                return 1
            fi
        fi
    fi
    
    print_warning "Cannot validate database connection (client not available)"
    return 0
}

# ==============================================================================
# SECURITY VALIDATION
# ==============================================================================

# Check for secrets in code
# Returns: Count of potential secrets found
check_for_secrets() {
    print_info "Scanning for potential secrets..."
    
    local secrets_found=0
    local patterns=(
        "password[[:space:]]*=[[:space:]]*['\"][^'\"]{3,}"
        "api[_-]?key[[:space:]]*=[[:space:]]*['\"][^'\"]{3,}"
        "secret[[:space:]]*=[[:space:]]*['\"][^'\"]{3,}"
        "token[[:space:]]*=[[:space:]]*['\"][^'\"]{3,}"
        "private[_-]?key[[:space:]]*=[[:space:]]*['\"][^'\"]{3,}"
    )
    
    for pattern in "${patterns[@]}"; do
        local matches=$(grep -rE "$pattern" . \
            --include="*.js" --include="*.ts" --include="*.py" --include="*.sh" \
            --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=vendor \
            2>/dev/null || true)
        
        if [[ -n "$matches" ]]; then
            ((secrets_found++))
            print_error "Potential secret found:"
            echo "$matches" | head -3
        fi
    done
    
    if [[ $secrets_found -eq 0 ]]; then
        print_success "No obvious secrets found in code"
    else
        print_error "Found $secrets_found potential secrets - review before deployment!"
    fi
    
    return $secrets_found
}

# ==============================================================================
# COMPREHENSIVE DEPLOYMENT VALIDATION
# ==============================================================================

# Run complete deployment validation
# Args: $1 = environment name (optional, default: production)
# Returns: 0 if ready, 1 if issues found
run_deployment_validation() {
    local env_name="${1:-production}"
    local report_file="${DEPLOYMENT_REPORT_DIR}/deployment_validation_$(date +%Y%m%d_%H%M%S).md"
    
    print_info "Running comprehensive deployment validation for ${env_name}..."
    
    init_deployment_validator
    
    local total_errors=0
    
    # Environment validation
    validate_environment_config "$env_name" || ((total_errors+=$?))
    
    # Dependency validation
    validate_dependencies || ((total_errors+=$?))
    
    # Configuration validation
    validate_config_files || ((total_errors+=$?))
    
    # Build artifacts
    validate_build_artifacts || ((total_errors+=$?))
    
    # Security check
    check_for_secrets || ((total_errors+=$?))
    
    # Runtime checks (if applicable)
    if [[ -n "${PORT:-}" ]]; then
        check_port_available "${PORT}" || ((total_errors+=$?))
    fi
    
    if [[ -n "${DATABASE_URL:-}" ]]; then
        check_database_connection || ((total_errors+=$?))
    fi
    
    # Generate report
    cat > "$report_file" << EOF
# Deployment Validation Report

**Environment**: ${env_name}
**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Status**: $( [[ $total_errors -eq 0 ]] && echo "✅ READY FOR DEPLOYMENT" || echo "❌ ISSUES FOUND ($total_errors)" )

---

## Summary

$( [[ $total_errors -eq 0 ]] && echo "All validation checks passed. The application is ready for deployment." || echo "Validation found $total_errors issues. Please address them before deployment." )

---

*Generated by Deployment Validator Module v1.0.0*
EOF
    
    print_info "Validation report: $report_file"
    
    if [[ $total_errors -eq 0 ]]; then
        print_success "✅ All checks passed - ready for deployment!"
        return 0
    else
        print_error "❌ Deployment validation failed with $total_errors issues"
        return 1
    fi
}

# Export functions
export -f init_deployment_validator
export -f check_required_env_vars
export -f load_env_file
export -f validate_environment_config
export -f validate_node_dependencies
export -f validate_python_dependencies
export -f validate_dependencies
export -f validate_json_config
export -f validate_yaml_config
export -f validate_config_files
export -f validate_build_artifacts
export -f check_port_available
export -f check_database_connection
export -f check_for_secrets
export -f run_deployment_validation
