# Library Function Documentation Guide

**Version**: 4.0.1  
**Last Updated**: 2026-02-10  
**Purpose**: Standard format for documenting shell functions in library modules

## Overview

This guide establishes the documentation standard for all functions in `src/workflow/lib/*.sh` modules. Consistent documentation enables developers to quickly understand function behavior, parameters, and usage patterns.

## Documentation Template

Every public function should include this header comment block:

```bash
#######################################
# Brief one-line description of what the function does
#
# Detailed description (if needed):
# - Additional context
# - Important behavior notes
# - Performance considerations
#
# Globals:
#   VAR_NAME - Description of how this global is used (read/write/modify)
#
# Arguments:
#   $1 - Parameter name and description
#   $2 - Parameter name and description (optional)
#
# Outputs:
#   Writes progress messages to stdout
#   Writes error messages to stderr
#
# Returns:
#   0 - Success
#   1 - Failure (with specific condition)
#   2 - Another failure condition
#
# Example:
#   if function_name "param1" "param2"; then
#     echo "Success"
#   fi
#######################################
function_name() {
  local param1="$1"
  local param2="${2:-default_value}"
  
  # Implementation
}
```

## Real-World Examples

### Example 1: Simple Utility Function

```bash
#######################################
# Check if a file exists and is readable
#
# Arguments:
#   $1 - Path to file to check
#
# Returns:
#   0 - File exists and is readable
#   1 - File does not exist or is not readable
#
# Example:
#   if is_file_readable "/path/to/file.txt"; then
#     process_file "/path/to/file.txt"
#   fi
#######################################
is_file_readable() {
  local filepath="$1"
  [[ -f "$filepath" && -r "$filepath" ]]
}
```

### Example 2: Function with Globals and Output

```bash
#######################################
# Initialize AI response cache system
#
# Creates cache directory structure and loads existing cache index.
# Cache uses SHA256 hashing for keys and 24-hour TTL for entries.
#
# Globals:
#   AI_CACHE_DIR - Sets to ~/.ai_workflow/cache (creates if missing)
#   AI_CACHE_INDEX - Sets to $AI_CACHE_DIR/index.json
#   AI_CACHE_ENABLED - Sets to 1 if cache initialized successfully
#
# Outputs:
#   Writes cache initialization status to stdout
#   Writes errors to stderr if cache creation fails
#
# Returns:
#   0 - Cache initialized successfully
#   1 - Failed to create cache directory
#   2 - Failed to load cache index
#
# Example:
#   if init_ai_cache; then
#     echo "Cache ready for use"
#   else
#     echo "Falling back to uncached mode"
#   fi
#######################################
init_ai_cache() {
  AI_CACHE_DIR="${HOME}/.ai_workflow/cache"
  AI_CACHE_INDEX="${AI_CACHE_DIR}/index.json"
  
  # Create cache directory
  if ! mkdir -p "$AI_CACHE_DIR"; then
    echo "ERROR: Failed to create cache directory: $AI_CACHE_DIR" >&2
    return 1
  fi
  
  # Initialize or load cache index
  if [[ ! -f "$AI_CACHE_INDEX" ]]; then
    echo '{}' > "$AI_CACHE_INDEX"
  fi
  
  if ! [[ -r "$AI_CACHE_INDEX" ]]; then
    echo "ERROR: Cannot read cache index: $AI_CACHE_INDEX" >&2
    return 2
  fi
  
  AI_CACHE_ENABLED=1
  echo "AI cache initialized: $AI_CACHE_DIR"
  return 0
}
```

### Example 3: Complex Function with Multiple Paths

```bash
#######################################
# Execute AI call with caching and retry logic
#
# Calls GitHub Copilot CLI with specified persona and prompt. Caches
# responses for 24 hours. Automatically retries on transient failures.
#
# Globals:
#   AI_CACHE_ENABLED - Checks if caching is available
#   AI_RETRY_COUNT - Number of retry attempts (default: 3)
#
# Arguments:
#   $1 - AI persona name (e.g., "documentation_specialist")
#   $2 - Prompt text to send to AI
#   $3 - Output file path for AI response
#
# Outputs:
#   Writes AI response to specified output file
#   Writes cache hit/miss info to stdout
#   Writes retry attempts and errors to stderr
#
# Returns:
#   0 - AI call succeeded (cached or fresh)
#   1 - Invalid persona name
#   2 - Copilot CLI not available
#   3 - Max retries exceeded
#   4 - Output file write failed
#
# Example:
#   if ai_call "code_reviewer" "Review this code" "output.md"; then
#     cat "output.md"
#   else
#     echo "AI call failed after retries"
#   fi
#######################################
ai_call() {
  local persona="$1"
  local prompt="$2"
  local output_file="$3"
  
  # Validate persona
  if ! is_valid_persona "$persona"; then
    echo "ERROR: Invalid persona: $persona" >&2
    return 1
  fi
  
  # Check Copilot availability
  if ! is_copilot_available; then
    echo "ERROR: GitHub Copilot CLI not available" >&2
    return 2
  fi
  
  # Try cache first
  if [[ "$AI_CACHE_ENABLED" == "1" ]]; then
    if get_cached_response "$persona" "$prompt" "$output_file"; then
      echo "Cache hit for prompt (hash: $(generate_cache_key "$prompt"))"
      return 0
    fi
  fi
  
  # Make fresh AI call with retry
  local attempt=1
  local max_attempts="${AI_RETRY_COUNT:-3}"
  
  while [[ $attempt -le $max_attempts ]]; do
    if execute_copilot_call "$persona" "$prompt" "$output_file"; then
      cache_ai_response "$persona" "$prompt" "$output_file"
      echo "AI call succeeded on attempt $attempt"
      return 0
    fi
    
    echo "WARNING: AI call failed, attempt $attempt/$max_attempts" >&2
    ((attempt++))
    sleep $((2 ** attempt))  # Exponential backoff
  done
  
  echo "ERROR: AI call failed after $max_attempts attempts" >&2
  return 3
}
```

### Example 4: Validation Function

```bash
#######################################
# Validate project configuration file
#
# Checks if .workflow-config.yaml exists and contains required fields.
# Validates YAML syntax and required keys (project.kind, tech_stack).
#
# Globals:
#   PROJECT_ROOT - Uses to locate config file
#
# Arguments:
#   $1 - Path to config file (optional, defaults to .workflow-config.yaml)
#
# Outputs:
#   Writes validation errors to stderr
#   Writes validation success to stdout
#
# Returns:
#   0 - Config valid
#   1 - Config file not found
#   2 - Invalid YAML syntax
#   3 - Missing required fields
#   4 - Invalid project.kind value
#
# Example:
#   if validate_config ".workflow-config.yaml"; then
#     load_config
#   else
#     echo "Config validation failed"
#     exit 1
#   fi
#######################################
validate_config() {
  local config_file="${1:-.workflow-config.yaml}"
  
  # Check existence
  if [[ ! -f "$config_file" ]]; then
    echo "ERROR: Config file not found: $config_file" >&2
    return 1
  fi
  
  # Validate YAML syntax
  if ! yq eval '.' "$config_file" >/dev/null 2>&1; then
    echo "ERROR: Invalid YAML syntax in $config_file" >&2
    return 2
  fi
  
  # Check required fields
  local required_fields=("project.kind" "tech_stack.primary_language")
  for field in "${required_fields[@]}"; do
    if ! yq eval ".$field" "$config_file" | grep -qv "null"; then
      echo "ERROR: Missing required field: $field" >&2
      return 3
    fi
  done
  
  # Validate project.kind
  local valid_kinds=("shell_automation" "nodejs_api" "python_app" "react_spa")
  local project_kind
  project_kind=$(yq eval '.project.kind' "$config_file")
  
  if ! printf '%s\n' "${valid_kinds[@]}" | grep -qx "$project_kind"; then
    echo "ERROR: Invalid project.kind: $project_kind" >&2
    echo "Valid values: ${valid_kinds[*]}" >&2
    return 4
  fi
  
  echo "✓ Config validation passed: $config_file"
  return 0
}
```

## Documentation Standards

### Required Elements

1. **Brief Description** (1 line): What the function does
2. **Detailed Description** (optional): Additional context, behavior, performance notes
3. **Globals**: All global variables read or modified
4. **Arguments**: Each positional parameter with description
5. **Outputs**: Where the function writes (stdout, stderr, files)
6. **Returns**: All possible return codes with meanings
7. **Example**: Working code snippet showing usage

### Optional Elements

- **See Also**: Related functions
- **Dependencies**: External commands required (jq, yq, gh)
- **Performance**: Time complexity, memory usage for heavy functions
- **Security**: Security considerations for functions handling sensitive data

### Style Guidelines

1. **Use imperative mood**: "Initialize cache" not "Initializes cache"
2. **Be specific**: "Writes JSON to stdout" not "Outputs data"
3. **Document edge cases**: Empty inputs, missing files, network errors
4. **Keep examples short**: 2-5 lines, runnable without modification
5. **Use consistent formatting**: Match the template structure exactly

## Migration Path

### Step 1: Audit Current Documentation

```bash
# Find functions without documentation
cd src/workflow/lib
for file in *.sh; do
  echo "=== $file ==="
  grep -E "^[a-z_]+\(\)" "$file" | while read -r func; do
    func_name="${func%()}"
    if ! grep -B5 "^$func" "$file" | grep -q "^#"; then
      echo "  Missing docs: $func_name"
    fi
  done
done
```

### Step 2: Add Documentation Incrementally

Priority order:
1. **Core modules** (12 modules): ai_helpers.sh, change_detection.sh, metrics.sh, etc.
2. **High-traffic modules**: Functions called >10 times across codebase
3. **Public API functions**: Functions used in step modules or external scripts
4. **Internal utilities**: Helper functions with complex logic

### Step 3: Validate Documentation

```bash
# Check documentation completeness
./scripts/validate_function_docs.sh src/workflow/lib/

# Expected output:
# ✓ ai_helpers.sh: 44/44 functions documented (100%)
# ✓ metrics.sh: 20/20 functions documented (100%)
# ✗ new_module.sh: 5/10 functions documented (50%)
```

## Tools and Automation

### Extract Function Signatures

```bash
# Generate function list for a module
extract_functions() {
  local module="$1"
  grep -E "^(function [a-z_]+|^[a-z_]+\(\))" "$module" | \
    sed 's/function //;s/().*$//' | \
    sort
}

# Usage
extract_functions src/workflow/lib/ai_helpers.sh
```

### Check Documentation Coverage

```bash
# Count documented vs undocumented functions
check_doc_coverage() {
  local module="$1"
  local total=0
  local documented=0
  
  while IFS= read -r func_line; do
    ((total++))
    func_name="${func_line%()}"
    if grep -B10 "^$func_line" "$module" | grep -q "^#######"; then
      ((documented++))
    fi
  done < <(grep -E "^[a-z_]+\(\)" "$module")
  
  echo "$documented/$total functions documented ($((documented * 100 / total))%)"
}
```

### Generate Documentation Stub

```bash
# Create documentation template for undocumented functions
generate_doc_stub() {
  local func_name="$1"
  cat <<EOF
#######################################
# TODO: Add brief description
#
# Arguments:
#   \$1 - TODO: Describe parameter
#
# Returns:
#   0 - Success
#   1 - Failure
#
# Example:
#   ${func_name} "param"
#######################################
EOF
}
```

## Common Patterns

### Pattern 1: Validation Functions

Always document:
- What is being validated
- All validation rules
- Specific error return codes for each validation failure

### Pattern 2: Configuration Functions

Always document:
- Global variables set/read
- Default values
- Configuration file format

### Pattern 3: Git Operations

Always document:
- Git commands executed
- Side effects (staging, committing)
- Safety checks (clean working tree)

### Pattern 4: AI Functions

Always document:
- AI persona used
- Prompt construction
- Caching behavior
- Retry logic

## Review Checklist

Before marking function documentation complete:

- [ ] One-line description is clear and imperative
- [ ] All parameters documented with types and constraints
- [ ] All global variables listed with read/write status
- [ ] All return codes documented with meanings
- [ ] Example is runnable and demonstrates common usage
- [ ] Edge cases documented (empty input, missing files, etc.)
- [ ] Performance notes added for O(n²) or slower functions
- [ ] Security notes added for functions handling secrets/credentials

## References

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)
- [ShellCheck](https://www.shellcheck.net/) - Linting tool
- [bashate](https://github.com/openstack/bashate) - Style checker

## See Also

- [Module Development Guide](MODULE_DEVELOPMENT.md) - Creating new modules
- [Testing Guide](COMPREHENSIVE_TESTING_GUIDE.md) - Testing functions
- [API Reference](../../api/COMPLETE_API_REFERENCE.md) - Complete function catalog
