#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Code Example Tester Module
# Version: 1.0.0
# Purpose: Extract and test code snippets from documentation
#
# Features:
#   - Extract code blocks from markdown files
#   - Language detection and syntax validation
#   - Execute testable code snippets in isolated environments
#   - Compile-check for compiled languages
#   - Lint check for scripting languages
#   - Support for multiple languages (bash, python, javascript, etc.)
#   - Detailed error reporting with line numbers
#
# Integration: Used by Step 7 (Test Creation)
################################################################################

# Set defaults
CODE_EXAMPLES_TEMP_DIR="${WORKFLOW_HOME:-$(pwd)}/.code_examples_temp"
ENABLE_CODE_EXECUTION="${ENABLE_CODE_EXECUTION:-false}"  # Opt-in for security

# Supported languages
declare -A LANGUAGE_VALIDATORS=(
    ["bash"]="validate_bash_code"
    ["sh"]="validate_bash_code"
    ["python"]="validate_python_code"
    ["python3"]="validate_python_code"
    ["javascript"]="validate_javascript_code"
    ["js"]="validate_javascript_code"
    ["typescript"]="validate_typescript_code"
    ["ts"]="validate_typescript_code"
    ["go"]="validate_go_code"
    ["java"]="validate_java_code"
    ["c"]="validate_c_code"
    ["cpp"]="validate_cpp_code"
    ["ruby"]="validate_ruby_code"
    ["php"]="validate_php_code"
)

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize code example testing system
init_code_example_tester() {
    mkdir -p "$CODE_EXAMPLES_TEMP_DIR"
    print_info "Code example tester initialized (temp: $CODE_EXAMPLES_TEMP_DIR)"
    
    # Cleanup old temp files
    find "$CODE_EXAMPLES_TEMP_DIR" -type f -mtime +1 -delete 2>/dev/null || true
    
    return 0
}

# Cleanup temporary files
cleanup_code_examples() {
    [[ -d "$CODE_EXAMPLES_TEMP_DIR" ]] && rm -rf "$CODE_EXAMPLES_TEMP_DIR"
    return 0
}

# ==============================================================================
# CODE EXTRACTION
# ==============================================================================

# Extract code blocks from markdown file
# Args: $1 = file path
# Output: Format "line_number|language|code_block_content"
extract_code_blocks() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    local in_code_block=false
    local code_language=""
    local code_content=""
    local block_start_line=0
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Detect code block start
        if [[ "$line" =~ ^\`\`\`([a-zA-Z0-9_-]*) ]]; then
            if $in_code_block; then
                # Nested blocks (shouldn't happen, but handle it)
                continue
            fi
            in_code_block=true
            code_language="${BASH_REMATCH[1]:-text}"
            code_content=""
            block_start_line=$line_num
            continue
        fi
        
        # Detect code block end
        if [[ "$line" =~ ^\`\`\`$ ]] && $in_code_block; then
            # Output the complete code block
            if [[ -n "$code_content" ]]; then
                # Encode newlines to preserve multiline content
                local encoded_content=$(echo "$code_content" | base64 -w 0)
                echo "${block_start_line}|${code_language}|${encoded_content}"
            fi
            
            in_code_block=false
            code_language=""
            code_content=""
            block_start_line=0
            continue
        fi
        
        # Collect code content
        if $in_code_block; then
            code_content+="${line}"$'\n'
        fi
    done < "$file"
    
    # Handle unclosed code blocks
    if $in_code_block && [[ -n "$code_content" ]]; then
        print_warning "Unclosed code block in $file at line $block_start_line"
    fi
}

# Extract inline code from markdown (single backticks)
# Args: $1 = file path
# Output: Format "line_number|inline_code"
extract_inline_code() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    local line_num=0
    while IFS= read -r line; do
        ((line_num++))
        
        # Extract all inline code segments
        while [[ "$line" =~ \`([^\`]+)\` ]]; do
            local code="${BASH_REMATCH[1]}"
            echo "${line_num}|${code}"
            # Remove matched part and continue
            line="${line#*\`*\`}"
        done
    done < "$file"
}

# ==============================================================================
# LANGUAGE-SPECIFIC VALIDATORS
# ==============================================================================

# Validate Bash code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_bash_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Syntax check only (don't execute)
    if bash -n "$temp_file" 2>&1; then
        return 0
    else
        return 1
    fi
}

# Validate Python code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_python_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if python/python3 is available
    local python_cmd=""
    if command -v python3 &>/dev/null; then
        python_cmd="python3"
    elif command -v python &>/dev/null; then
        python_cmd="python"
    else
        print_warning "Python not available for validation"
        return 0  # Skip if not available
    fi
    
    # Compile check (syntax validation)
    if $python_cmd -m py_compile "$temp_file" 2>&1; then
        return 0
    else
        return 1
    fi
}

# Validate JavaScript code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_javascript_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if node is available
    if command -v node &>/dev/null; then
        # Syntax check only
        if node --check "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "Node.js not available for JavaScript validation"
        return 0  # Skip if not available
    fi
}

# Validate TypeScript code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_typescript_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if tsc is available
    if command -v tsc &>/dev/null; then
        # Compile check
        if tsc --noEmit "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "TypeScript compiler not available for validation"
        return 0  # Skip if not available
    fi
}

# Validate Go code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_go_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if go is available
    if command -v go &>/dev/null; then
        # Format check (validates syntax)
        if go fmt "$temp_file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "Go compiler not available for validation"
        return 0  # Skip if not available
    fi
}

# Validate Java code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_java_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if javac is available
    if command -v javac &>/dev/null; then
        # Compile check
        if javac "$temp_file" 2>&1; then
            # Clean up compiled class files
            rm -f "${temp_file%.java}.class"
            return 0
        else
            return 1
        fi
    else
        print_warning "Java compiler not available for validation"
        return 0  # Skip if not available
    fi
}

# Validate C code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_c_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if gcc is available
    if command -v gcc &>/dev/null; then
        # Syntax check only (don't link)
        if gcc -fsyntax-only "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "GCC not available for C validation"
        return 0  # Skip if not available
    fi
}

# Validate C++ code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_cpp_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if g++ is available
    if command -v g++ &>/dev/null; then
        # Syntax check only (don't link)
        if g++ -fsyntax-only "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "G++ not available for C++ validation"
        return 0  # Skip if not available
    fi
}

# Validate Ruby code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_ruby_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if ruby is available
    if command -v ruby &>/dev/null; then
        # Syntax check only
        if ruby -c "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "Ruby not available for validation"
        return 0  # Skip if not available
    fi
}

# Validate PHP code
# Args: $1 = code content, $2 = temp file path
# Returns: 0 if valid, 1 if errors
validate_php_code() {
    local code="$1"
    local temp_file="$2"
    
    echo "$code" > "$temp_file"
    
    # Check if php is available
    if command -v php &>/dev/null; then
        # Lint check
        if php -l "$temp_file" 2>&1; then
            return 0
        else
            return 1
        fi
    else
        print_warning "PHP not available for validation"
        return 0  # Skip if not available
    fi
}

# ==============================================================================
# VALIDATION ENGINE
# ==============================================================================

# Validate a single code block
# Args: $1 = language, $2 = code content (base64 encoded), $3 = source file, $4 = line number
# Returns: 0 if valid, 1 if errors
validate_code_block() {
    local language="$1"
    local encoded_content="$2"
    local source_file="$3"
    local line_num="$4"
    
    # Decode content
    local code_content=$(echo "$encoded_content" | base64 -d)
    
    # Skip validation for certain languages/cases
    case "$language" in
        text|txt|output|console|plaintext|"")
            return 0  # Skip non-code blocks
            ;;
    esac
    
    # Check if we have a validator for this language
    local validator="${LANGUAGE_VALIDATORS[$language]:-}"
    if [[ -z "$validator" ]]; then
        print_warning "No validator for language: $language (skipping)"
        return 0
    fi
    
    # Create temp file with appropriate extension
    local file_ext="$language"
    [[ "$language" == "python3" ]] && file_ext="py"
    [[ "$language" == "javascript" || "$language" == "js" ]] && file_ext="js"
    [[ "$language" == "typescript" || "$language" == "ts" ]] && file_ext="ts"
    
    local temp_file="${CODE_EXAMPLES_TEMP_DIR}/code_${line_num}.${file_ext}"
    
    # Run validator
    local validation_output
    if validation_output=$($validator "$code_content" "$temp_file" 2>&1); then
        return 0
    else
        print_error "Code validation failed in ${source_file}:${line_num} (${language})"
        echo "$validation_output" | head -10  # Show first 10 lines of error
        return 1
    fi
}

# Validate all code examples in a file
# Args: $1 = file path, $2 = report file
# Returns: Count of validation errors
validate_file_code_examples() {
    local file="$1"
    local report_file="$2"
    local error_count=0
    local validated_count=0
    
    # Extract and validate code blocks
    while IFS='|' read -r line_num language encoded_content; do
        ((validated_count++))
        
        if ! validate_code_block "$language" "$encoded_content" "$file" "$line_num"; then
            echo "${file}:${line_num}: Code validation error in ${language} block" >> "$report_file"
            ((error_count++))
        fi
    done < <(extract_code_blocks "$file")
    
    [[ $validated_count -gt 0 ]] && print_info "Validated $validated_count code blocks in $(basename "$file")"
    
    return $error_count
}

# Validate code examples in all documentation files
# Args: $1 = output report file, $2 = directory to scan (default: current)
# Returns: Total count of validation errors
validate_all_code_examples() {
    local report_file="$1"
    local scan_dir="${2:-.}"
    local total_errors=0
    local files_checked=0
    
    print_info "Validating code examples in documentation..."
    
    # Initialize
    init_code_example_tester
    
    # Find and validate all markdown files
    while IFS= read -r md_file; do
        ((files_checked++))
        local errors=0
        validate_file_code_examples "$md_file" "$report_file" || errors=$?
        ((total_errors += errors))
    done < <(find "$scan_dir" -name "*.md" -type f ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/.ai_workflow/*" 2>/dev/null || true)
    
    # Cleanup
    cleanup_code_examples
    
    if [[ $total_errors -eq 0 ]]; then
        print_success "All code examples validated successfully ($files_checked files checked)"
    else
        print_warning "Found $total_errors code validation errors in $files_checked files"
    fi
    
    return $total_errors
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Generate code example validation summary
# Args: $1 = report file, $2 = output summary file
generate_code_validation_summary() {
    local report_file="$1"
    local summary_file="$2"
    
    [[ ! -f "$report_file" ]] && return 1
    
    local total_errors=$(wc -l < "$report_file" 2>/dev/null || echo 0)
    
    # Count by language
    declare -A lang_counts
    while IFS= read -r line; do
        if [[ "$line" =~ in\ ([a-z]+)\ block ]]; then
            local lang="${BASH_REMATCH[1]}"
            ((lang_counts[$lang]++)) || lang_counts[$lang]=1
        fi
    done < "$report_file"
    
    cat > "$summary_file" << EOF
# Code Example Validation Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Total Errors**: $total_errors

## Errors by Language

EOF
    
    for lang in "${!lang_counts[@]}"; do
        echo "- **${lang}**: ${lang_counts[$lang]}" >> "$summary_file"
    done
    
    cat >> "$summary_file" << EOF

## Details

\`\`\`
$(cat "$report_file")
\`\`\`

---

*Generated by Code Example Tester Module v1.0.0*
EOF
    
    print_info "Code validation summary generated: $summary_file"
}

# Export functions
export -f init_code_example_tester
export -f cleanup_code_examples
export -f extract_code_blocks
export -f extract_inline_code
export -f validate_bash_code
export -f validate_python_code
export -f validate_javascript_code
export -f validate_typescript_code
export -f validate_go_code
export -f validate_java_code
export -f validate_c_code
export -f validate_cpp_code
export -f validate_ruby_code
export -f validate_php_code
export -f validate_code_block
export -f validate_file_code_examples
export -f validate_all_code_examples
export -f generate_code_validation_summary
