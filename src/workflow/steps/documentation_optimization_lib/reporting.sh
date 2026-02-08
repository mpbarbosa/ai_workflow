#!/usr/bin/env bash
#
# Reporting Engine
# Generates optimization reports and metrics
#

set -euo pipefail

################################################################################
# Generate optimization report
################################################################################
generate_optimization_report() {
    local report_file="$PROJECT_ROOT/docs/.archive/optimization_report.md"
    
    print_info "Generating optimization report..."
    
    # Calculate metrics
    local files_removed=$((${#EXACT_DUPLICATES[@]} + ${#OUTDATED_FILES[@]}))
    local size_saved=0
    
    for file in "${EXACT_DUPLICATES[@]}" "${OUTDATED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            local size
            size=$(wc -c < "$file" 2>/dev/null || echo "0")
            size_saved=$((size_saved + size))
        fi
    done
    
    # Convert to KB
    local size_saved_kb=$((size_saved / 1024))
    
    # Estimate token savings (rough: 1 token ≈ 4 characters)
    local tokens_saved=$((size_saved / 4))
    
    # Generate report
    cat > "$report_file" << EOF
# Documentation Optimization Report

**Generated:** $(date +"%Y-%m-%d %H:%M:%S")  
**Project:** $(basename "$PROJECT_ROOT")

## Summary

- **Total files analyzed:** $TOTAL_FILES
- **Exact duplicates found:** ${#EXACT_DUPLICATES[@]}
- **Redundant pairs found:** ${#REDUNDANT_PAIRS[@]}
- **Outdated files found:** ${#OUTDATED_FILES[@]}
- **Files removed/archived:** $files_removed
- **Size reduction:** ${size_saved_kb}KB
- **Estimated token savings:** ~${tokens_saved} tokens

## Actions Taken

### Exact Duplicates Consolidated

EOF
    
    if [[ ${#EXACT_DUPLICATES[@]} -gt 0 ]]; then
        for file in "${EXACT_DUPLICATES[@]}"; do
            echo "- \`$file\`" >> "$report_file"
        done
    else
        echo "None" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### Outdated Files Archived

EOF
    
    if [[ ${#OUTDATED_FILES[@]} -gt 0 ]]; then
        for file in "${OUTDATED_FILES[@]}"; do
            echo "- \`$file\`" >> "$report_file"
        done
    else
        echo "None" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### Redundant Pairs (Manual Review Recommended)

EOF
    
    if [[ ${#REDUNDANT_PAIRS[@]} -gt 0 ]]; then
        for pair in "${REDUNDANT_PAIRS[@]}"; do
            IFS='|' read -r file1 file2 similarity <<< "$pair"
            echo "- \`$file1\` ↔ \`$file2\` (similarity: $similarity)" >> "$report_file"
        done
    else
        echo "None" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Recommendations

- Review redundant pairs above 80% similarity for potential consolidation
- Update version references in remaining documentation
- Consider running this optimization quarterly to maintain documentation quality

## Archive Location

All modified files have been archived to:
\`$ARCHIVE_DIR\`

To restore files, copy them back from the archive directory.

EOF
    
    print_success "Report generated: $report_file"
    
    # Display summary
    echo ""
    echo "📊 Optimization Complete!"
    echo "═══════════════════════"
    echo "  Files analyzed: $TOTAL_FILES"
    echo "  Files optimized: $files_removed"
    echo "  Size saved: ${size_saved_kb}KB"
    echo "  Token savings: ~${tokens_saved}"
    echo ""
    echo "Full report: $report_file"
    
    return 0
}

# Export functions
export -f generate_optimization_report
