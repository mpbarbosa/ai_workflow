#!/bin/bash
set -euo pipefail

################################################################################
# Function Documentation Generator
# Purpose: Generate documentation templates for undocumented functions
# Part of: Tests & Documentation Workflow Automation v2.4.0
################################################################################

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Extract function signature and generate documentation template
# Usage: generate_function_doc <file> <function_name>
generate_function_doc() {
    local file="$1"
    local func_name="$2"
    
    # Extract function body to analyze parameters
    local func_body
    func_body=$(awk "/^${func_name}\(\) \{/,/^}/" "$file")
    
    # Extract parameters (look for $1, $2, local var="$1", etc.)
    local params
    params=$(echo "$func_body" | grep -oP '(local \w+="?\$\{?\d+\}?|"\$\{\d+[:-][^}]*\}"|"\$\d+")' | \
        sed 's/local \(\w\+\)="\?\${\?\([0-9]\+\).*/\2:\1/' | \
        sort -u || echo "")
    
    # Generate documentation template
    cat << EOF

# Function: ${func_name}
# Description: [TODO: Add description]
# Usage: ${func_name} $(echo "$params" | awk -F: '{print "<"$2">"}' | tr '\n' ' ')
# Parameters:
EOF
    
    if [[ -n "$params" ]]; then
        echo "$params" | while IFS=: read -r num name; do
            echo "#   \$${num} - ${name} - [TODO: Add description]"
        done
    else
        echo "#   None"
    fi
    
    cat << EOF
# Returns:
#   0 - Success
#   1 - [TODO: Add failure conditions]
# Example:
#   ${func_name} [TODO: Add example]
EOF
}

# Find undocumented functions in a file
# Usage: find_undocumented_functions <file>
find_undocumented_functions() {
    local file="$1"
    local undocumented=()
    
    # Extract all function names
    local functions
    functions=$(grep -oP '^[a-z_]+(?=\(\) \{)' "$file" || echo "")
    
    if [[ -z "$functions" ]]; then
        return 0
    fi
    
    # Check each function for documentation
    while IFS= read -r func; do
        # Look for comment block before function (within 5 lines)
        local line_num
        line_num=$(grep -n "^${func}() {" "$file" | cut -d: -f1)
        
        if [[ -z "$line_num" ]]; then
            continue
        fi
        
        local start_line=$((line_num - 5))
        if [[ $start_line -lt 1 ]]; then
            start_line=1
        fi
        
        # Check if there's a documentation comment
        local has_doc
        has_doc=$(sed -n "${start_line},${line_num}p" "$file" | \
            grep -c "^# \(Function:\|Description:\|Usage:\|Parameters:\|Returns:\)" || echo "0")
        
        if [[ "$has_doc" -eq 0 ]]; then
            undocumented+=("$func")
        fi
    done <<< "$functions"
    
    # Report undocumented functions
    if [[ ${#undocumented[@]} -gt 0 ]]; then
        print_warning "File: $file - ${#undocumented[@]} undocumented functions"
        for func in "${undocumented[@]}"; do
            echo "  - $func"
        done
        return 1
    fi
    
    return 0
}

# Generate documentation for all undocumented functions in a file
# Usage: document_file <file> [--dry-run]
document_file() {
    local file="$1"
    local dry_run="${2:-false}"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Extract all function names
    local functions
    functions=$(grep -oP '^[a-z_]+(?=\(\) \{)' "$file" || echo "")
    
    if [[ -z "$functions" ]]; then
        print_info "No functions found in $file"
        return 0
    fi
    
    local doc_file="${file}.docs.tmp"
    > "$doc_file"
    
    # Process each function
    while IFS= read -r func; do
        # Check if already documented
        local line_num
        line_num=$(grep -n "^${func}() {" "$file" | cut -d: -f1)
        
        local start_line=$((line_num - 5))
        if [[ $start_line -lt 1 ]]; then
            start_line=1
        fi
        
        local has_doc
        has_doc=$(sed -n "${start_line},${line_num}p" "$file" | \
            grep -c "^# \(Function:\|Description:\|Usage:\)" || echo "0")
        
        if [[ "$has_doc" -eq 0 ]]; then
            print_info "Generating documentation for: $func"
            generate_function_doc "$file" "$func" >> "$doc_file"
        fi
    done <<< "$functions"
    
    if [[ -s "$doc_file" ]]; then
        if [[ "$dry_run" == "true" || "$dry_run" == "--dry-run" ]]; then
            print_info "Generated documentation (dry-run):"
            cat "$doc_file"
        else
            print_info "Documentation templates saved to: $doc_file"
            print_info "Review and integrate into $file"
        fi
    else
        print_success "All functions in $file are documented!"
        rm -f "$doc_file"
    fi
}

# Scan all shell scripts in directory for undocumented functions
# Usage: scan_directory <directory>
scan_directory() {
    local directory="$1"
    local total=0
    local undocumented=0
    
    print_info "Scanning directory: $directory"
    
    while IFS= read -r file; do
        ((total++))
        if ! find_undocumented_functions "$file"; then
            ((undocumented++))
        fi
    done < <(find "$directory" -name "*.sh" -type f)
    
    echo ""
    print_info "Scan complete:"
    print_info "  Total files: $total"
    print_info "  Files with undocumented functions: $undocumented"
    print_info "  Documentation coverage: $(( (total - undocumented) * 100 / total ))%"
}

# Main execution
main() {
    local command="${1:-scan}"
    local target="${2:-.}"
    
    case "$command" in
        scan)
            if [[ -f "$target" ]]; then
                find_undocumented_functions "$target"
            elif [[ -d "$target" ]]; then
                scan_directory "$target"
            else
                print_error "Invalid target: $target"
                return 1
            fi
            ;;
        generate)
            if [[ ! -f "$target" ]]; then
                print_error "File not found: $target"
                return 1
            fi
            local dry_run="${3:-false}"
            document_file "$target" "$dry_run"
            ;;
        *)
            cat << 'EOF'
Usage: function_documentation.sh <command> <target> [options]

Commands:
  scan <file|directory>       - Scan for undocumented functions
  generate <file> [--dry-run] - Generate documentation templates

Examples:
  # Scan a directory
  ./function_documentation.sh scan src/workflow/lib

  # Scan a single file
  ./function_documentation.sh scan src/workflow/lib/utils.sh

  # Generate documentation (dry-run)
  ./function_documentation.sh generate src/workflow/lib/utils.sh --dry-run

  # Generate documentation
  ./function_documentation.sh generate src/workflow/lib/utils.sh
EOF
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
