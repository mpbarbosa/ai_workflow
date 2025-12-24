#!/usr/bin/env bash
# Date Format Standardizer
# Standardizes all dates in documentation to ISO 8601 format
#
# Usage: ./scripts/standardize_dates.sh [--check|--fix] [--verbose]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
FILES_WITH_ISSUES=0
TOTAL_ISSUES=0
FIXED_ISSUES=0

# Options
MODE="check"  # check or fix
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            MODE="check"
            shift
            ;;
        --fix)
            MODE="fix"
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            cat << 'EOF'
Usage: ./scripts/standardize_dates.sh [OPTIONS]

Standardize date formats across documentation to ISO 8601.

OPTIONS:
  --check       Check for date format issues (default)
  --fix         Fix date format issues automatically
  --verbose     Show detailed output
  --help        Show this help message

DATE FORMAT STANDARDS:
  ✓ ISO 8601: YYYY-MM-DD
  ✓ ISO 8601 with time: YYYY-MM-DDTHH:MM:SSZ
  ✗ Prose format: Month DD, YYYY
  ✗ Inconsistent separators: YYYY/MM/DD

EXAMPLES:
  # Check for issues
  ./scripts/standardize_dates.sh --check

  # Fix issues automatically
  ./scripts/standardize_dates.sh --fix

  # Fix with detailed output
  ./scripts/standardize_dates.sh --fix --verbose
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*"
}

# Convert month name to number
month_to_number() {
    local month="$1"
    case "$month" in
        January) echo "01" ;;
        February) echo "02" ;;
        March) echo "03" ;;
        April) echo "04" ;;
        May) echo "05" ;;
        June) echo "06" ;;
        July) echo "07" ;;
        August) echo "08" ;;
        September) echo "09" ;;
        October) echo "10" ;;
        November) echo "11" ;;
        December) echo "12" ;;
        *) echo "" ;;
    esac
}

# Detect prose dates like "December 23, 2025"
detect_prose_dates() {
    local file="$1"
    local issues=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ (January|February|March|April|May|June|July|August|September|October|November|December)[[:space:]]+([0-9]{1,2}),[[:space:]]*([0-9]{4}) ]]; then
            local month="${BASH_REMATCH[1]}"
            local day="${BASH_REMATCH[2]}"
            local year="${BASH_REMATCH[3]}"
            local month_num
            month_num=$(month_to_number "$month")
            
            if [[ -n "$month_num" ]]; then
                local iso_date
                iso_date=$(printf "%s-%s-%02d" "$year" "$month_num" "$day")
                
                issues=$((issues + 1))
                TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
                
                if [[ "$MODE" == "fix" ]]; then
                    # Escape special characters for sed
                    local escaped_month="${month// /[[:space:]]+}"
                    sed -i "s/${escaped_month}[[:space:]]\+${day},[[:space:]]*${year}/${iso_date}/g" "$file"
                    [[ "$VERBOSE" == "true" ]] && log_success "Fixed: $month $day, $year → $iso_date in $(basename "$file")"
                    FIXED_ISSUES=$((FIXED_ISSUES + 1))
                else
                    [[ "$VERBOSE" == "true" ]] && log_warning "Found: $month $day, $year (should be $iso_date) in $(basename "$file")"
                fi
            fi
        fi
    done < "$file"
    
    return $issues
}

# Detect inconsistent date separators (YYYY/MM/DD, YYYY.MM.DD)
detect_inconsistent_separators() {
    local file="$1"
    local issues=0
    
    while IFS= read -r line; do
        # Check for YYYY/MM/DD
        if [[ "$line" =~ ([0-9]{4})/([0-9]{2})/([0-9]{2}) ]]; then
            local year="${BASH_REMATCH[1]}"
            local month="${BASH_REMATCH[2]}"
            local day="${BASH_REMATCH[3]}"
            local iso_date="${year}-${month}-${day}"
            
            issues=$((issues + 1))
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            
            if [[ "$MODE" == "fix" ]]; then
                sed -i "s|${year}/${month}/${day}|${iso_date}|g" "$file"
                [[ "$VERBOSE" == "true" ]] && log_success "Fixed: ${year}/${month}/${day} → $iso_date in $(basename "$file")"
                FIXED_ISSUES=$((FIXED_ISSUES + 1))
            else
                [[ "$VERBOSE" == "true" ]] && log_warning "Found: ${year}/${month}/${day} (should be $iso_date) in $(basename "$file")"
            fi
        fi
        
        # Check for YYYY.MM.DD
        if [[ "$line" =~ ([0-9]{4})\.([0-9]{2})\.([0-9]{2}) ]]; then
            local year="${BASH_REMATCH[1]}"
            local month="${BASH_REMATCH[2]}"
            local day="${BASH_REMATCH[3]}"
            local iso_date="${year}-${month}-${day}"
            
            issues=$((issues + 1))
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            
            if [[ "$MODE" == "fix" ]]; then
                sed -i "s|${year}\.${month}\.${day}|${iso_date}|g" "$file"
                [[ "$VERBOSE" == "true" ]] && log_success "Fixed: ${year}.${month}.${day} → $iso_date in $(basename "$file")"
                FIXED_ISSUES=$((FIXED_ISSUES + 1))
            else
                [[ "$VERBOSE" == "true" ]] && log_warning "Found: ${year}.${month}.${day} (should be $iso_date) in $(basename "$file")"
            fi
        fi
    done < "$file"
    
    return $issues
}

# Detect dates with inconsistent time formats
detect_inconsistent_time_formats() {
    local file="$1"
    local issues=0
    
    while IFS= read -r line; do
        # Check for ISO date with space before time (should use T)
        if [[ "$line" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            local date="${BASH_REMATCH[1]}"
            local time="${BASH_REMATCH[2]}"
            local iso_datetime="${date}T${time}"
            
            # Skip if it's already valid ISO format
            [[ "$line" =~ ${date}T${time} ]] && continue
            
            issues=$((issues + 1))
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            
            if [[ "$MODE" == "fix" ]]; then
                sed -i "s|${date}[[:space:]]${time}|${iso_datetime}|g" "$file"
                [[ "$VERBOSE" == "true" ]] && log_success "Fixed: $date $time → $iso_datetime in $(basename "$file")"
                FIXED_ISSUES=$((FIXED_ISSUES + 1))
            else
                [[ "$VERBOSE" == "true" ]] && log_warning "Found: $date $time (should be $iso_datetime) in $(basename "$file")"
            fi
        fi
    done < "$file"
    
    return $issues
}

# Validate ISO 8601 format
validate_iso_format() {
    local file="$1"
    local valid=true
    
    while IFS= read -r line; do
        # Check for valid ISO dates
        if [[ "$line" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
            local date="${BASH_REMATCH[1]}"
            local year="${date:0:4}"
            local month="${date:5:2}"
            local day="${date:8:2}"
            
            # Basic validation (strip leading zeros to avoid octal interpretation)
            if [[ ${month#0} -lt 1 || ${month#0} -gt 12 ]]; then
                log_error "Invalid month in $date (file: $(basename "$file"))"
                valid=false
            fi
            
            if [[ ${day#0} -lt 1 || ${day#0} -gt 31 ]]; then
                log_error "Invalid day in $date (file: $(basename "$file"))"
                valid=false
            fi
        fi
    done < "$file"
    
    $valid && return 0 || return 1
}

# Process a single file
process_file() {
    local file="$1"
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    local file_issues=0
    
    # Detect prose dates
    if detect_prose_dates "$file"; then
        file_issues=$((file_issues + $?))
    fi
    
    # Detect inconsistent separators
    if detect_inconsistent_separators "$file"; then
        file_issues=$((file_issues + $?))
    fi
    
    # Detect inconsistent time formats
    if detect_inconsistent_time_formats "$file"; then
        file_issues=$((file_issues + $?))
    fi
    
    # Validate ISO format
    validate_iso_format "$file"
    
    if [[ $file_issues -gt 0 ]]; then
        FILES_WITH_ISSUES=$((FILES_WITH_ISSUES + 1))
    fi
    
    return 0
}

# Generate report
generate_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}DATE FORMAT STANDARDIZATION REPORT${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Mode:                 $MODE"
    echo "Files Scanned:        $TOTAL_FILES"
    echo "Files with Issues:    $FILES_WITH_ISSUES"
    echo "Total Issues Found:   $TOTAL_ISSUES"
    
    if [[ "$MODE" == "fix" ]]; then
        echo "Issues Fixed:         $FIXED_ISSUES"
    fi
    
    echo ""
    
    if [[ $TOTAL_ISSUES -eq 0 ]]; then
        echo -e "${GREEN}✅ All dates are properly formatted!${NC}"
        return 0
    else
        if [[ "$MODE" == "check" ]]; then
            echo -e "${YELLOW}⚠️  Found $TOTAL_ISSUES date format issues${NC}"
            echo ""
            echo "Run with --fix to automatically correct these issues:"
            echo "  ./scripts/standardize_dates.sh --fix"
        else
            echo -e "${GREEN}✅ Fixed $FIXED_ISSUES date format issues${NC}"
        fi
        return 1
    fi
}

# Main execution
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Date Format Standardizer"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [[ "$MODE" == "fix" ]]; then
        log_warning "Running in FIX mode - files will be modified"
    else
        log_info "Running in CHECK mode - no files will be modified"
    fi
    
    echo ""
    log_info "Scanning documentation files..."
    echo ""
    
    cd "${PROJECT_ROOT}"
    
    # Process all markdown files
    while IFS= read -r file; do
        process_file "$file"
    done < <(find docs README.md .github/copilot-instructions.md -name "*.md" -type f 2>/dev/null)
    
    # Generate report
    generate_report
}

main "$@"
