#!/usr/bin/env bash
# API Documentation Extractor
# Parses shell script modules to extract comprehensive API documentation

set -euo pipefail

LIB_DIR="/home/mpb/Documents/GitHub/ai_workflow/src/workflow/lib"
OUTPUT_FILE="/home/mpb/Documents/GitHub/ai_workflow/docs/api/COMPLETE_API_REFERENCE.md"

# Module categories for organization
declare -A MODULE_CATEGORIES=(
    ["ai_cache.sh"]="AI & Caching"
    ["ai_helpers.sh"]="AI & Caching"
    ["ai_personas.sh"]="AI & Caching"
    ["ai_prompt_builder.sh"]="AI & Caching"
    ["ai_validation.sh"]="AI & Caching"
    ["analysis_cache.sh"]="AI & Caching"
    ["change_detection.sh"]="Core Infrastructure"
    ["metrics.sh"]="Core Infrastructure"
    ["workflow_optimization.sh"]="Core Infrastructure"
    ["tech_stack.sh"]="Core Infrastructure"
    ["config.sh"]="Configuration"
    ["config_wizard.sh"]="Configuration"
    ["project_kind_config.sh"]="Configuration"
    ["project_kind_detection.sh"]="Configuration"
    ["git_automation.sh"]="Git Operations"
    ["git_cache.sh"]="Git Operations"
    ["git_submodule_helpers.sh"]="Git Operations"
    ["auto_commit.sh"]="Git Operations"
    ["batch_ai_commit.sh"]="Git Operations"
    ["file_operations.sh"]="File Operations"
    ["edit_operations.sh"]="File Operations"
    ["doc_section_extractor.sh"]="Documentation"
    ["doc_section_mapper.sh"]="Documentation"
    ["doc_template_validator.sh"]="Documentation"
    ["auto_documentation.sh"]="Documentation"
    ["changelog_generator.sh"]="Documentation"
    ["link_validator.sh"]="Documentation"
    ["validation.sh"]="Validation & Testing"
    ["enhanced_validations.sh"]="Validation & Testing"
    ["metrics_validation.sh"]="Validation & Testing"
    ["api_coverage.sh"]="Validation & Testing"
    ["code_example_tester.sh"]="Validation & Testing"
    ["deployment_validator.sh"]="Validation & Testing"
    ["step_execution.sh"]="Step Management"
    ["step_loader.sh"]="Step Management"
    ["step_metadata.sh"]="Step Management"
    ["step_registry.sh"]="Step Management"
    ["step_adaptation.sh"]="Step Management"
    ["step_validation_cache.sh"]="Step Management"
    ["step_validation_cache_integration.sh"]="Step Management"
    ["session_manager.sh"]="Session & State"
    ["backlog.sh"]="Session & State"
    ["summary.sh"]="Session & State"
    ["dependency_cache.sh"]="Optimization"
    ["dependency_graph.sh"]="Optimization"
    ["code_changes_optimization.sh"]="Optimization"
    ["docs_only_optimization.sh"]="Optimization"
    ["full_changes_optimization.sh"]="Optimization"
    ["conditional_execution.sh"]="Optimization"
    ["incremental_analysis.sh"]="Optimization"
    ["skip_predictor.sh"]="Optimization"
    ["ml_optimization.sh"]="Optimization"
    ["multi_stage_pipeline.sh"]="Optimization"
    ["workflow_profiles.sh"]="Optimization"
    ["performance.sh"]="Performance & Monitoring"
    ["performance_monitoring.sh"]="Performance & Monitoring"
    ["dashboard.sh"]="Performance & Monitoring"
    ["model_selector.sh"]="AI Model Selection"
    ["utils.sh"]="Utilities"
    ["colors.sh"]="Utilities"
    ["jq_wrapper.sh"]="Utilities"
    ["argument_parser.sh"]="Utilities"
    ["health_check.sh"]="Utilities"
    ["third_party_exclusion.sh"]="Utilities"
    ["version_bump.sh"]="Utilities"
    ["cleanup_handlers.sh"]="Cleanup"
    ["cleanup_template.sh"]="Cleanup"
    ["audio_notifications.sh"]="User Experience"
    ["precommit_hooks.sh"]="Hooks"
)

# Extract module purpose from header comments
extract_module_purpose() {
    local file="$1"
    local purpose=""
    local in_header=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^#[[:space:]]*$ ]]; then
            continue
        fi
        
        if [[ "$line" =~ ^#\!.*bash ]]; then
            continue
        fi
        
        if [[ "$line" =~ ^#[[:space:]]*(.+)$ ]]; then
            local comment="${BASH_REMATCH[1]}"
            if [[ ! "$comment" =~ ^-+$ ]] && [[ ! "$comment" =~ ^=+$ ]]; then
                if [[ -n "$comment" ]]; then
                    purpose="$comment"
                    break
                fi
            fi
        elif [[ ! "$line" =~ ^#.* ]] && [[ -n "$line" ]]; then
            break
        fi
    done < "$file"
    
    echo "$purpose"
}

# Extract function documentation
extract_function_docs() {
    local file="$1"
    local func_name="$2"
    local docs=""
    local found_func=false
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        if [[ "$line" =~ ^[[:space:]]*(function[[:space:]]+)?${func_name}[[:space:]]*\(\) ]]; then
            found_func=true
            break
        fi
    done < "$file"
    
    if [[ "$found_func" == true ]]; then
        local start_line=$((line_num - 1))
        local comment_lines=""
        
        while [[ $start_line -gt 0 ]]; do
            local prev_line=$(sed -n "${start_line}p" "$file")
            if [[ "$prev_line" =~ ^[[:space:]]*#(.*)$ ]]; then
                comment_lines="${BASH_REMATCH[1]}"$'\n'"$comment_lines"
                ((start_line--))
            else
                break
            fi
        done
        
        echo "$comment_lines"
    fi
}

# Extract function signature and parameters
extract_function_signature() {
    local file="$1"
    local func_name="$2"
    
    awk -v fname="$func_name" '
        /^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)/ {
            gsub(/^[[:space:]]+/, "")
            gsub(/function[[:space:]]+/, "")
            gsub(/\(\).*/, "")
            if ($0 == fname) {
                in_function = 1
                next
            }
        }
        in_function && /local[[:space:]]+[a-zA-Z_]/ {
            print $0
        }
        in_function && /^[[:space:]]*}[[:space:]]*$/ {
            exit
        }
    ' "$file"
}

# Get all functions in a file
get_functions() {
    local file="$1"
    grep -E "^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)" "$file" | \
        sed -E 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\).*/\2/' | \
        sort -u
}

# Main execution
main() {
    echo "Extracting API documentation from library modules..."
    
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    
    # Count totals
    local total_modules=0
    local total_functions=0
    
    cd "$LIB_DIR"
    for file in $(find . -maxdepth 1 -name "*.sh" ! -name "test_*.sh" | sort); do
        ((total_modules++))
        local funcs=$(get_functions "$file" | wc -l)
        ((total_functions += funcs))
    done
    
    # Start writing output
    cat > "$OUTPUT_FILE" << 'HEADER'
# Complete API Reference - AI Workflow Automation

> **Version**: 4.0.1  
> **Last Updated**: 2026-02-09  
> **Generated**: Auto-generated from source code  

HEADER

    echo "**Total Modules**: $total_modules  " >> "$OUTPUT_FILE"
    echo "**Total Functions**: $total_functions" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Generate TOC by category
    echo "## Table of Contents" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    declare -A categories
    for file in $(find . -maxdepth 1 -name "*.sh" ! -name "test_*.sh" | sort); do
        local basename=$(basename "$file")
        local category="${MODULE_CATEGORIES[$basename]:-Uncategorized}"
        categories["$category"]=1
    done
    
    for category in $(echo "${!categories[@]}" | tr ' ' '\n' | sort); do
        echo "### $category" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        for file in $(find . -maxdepth 1 -name "*.sh" ! -name "test_*.sh" | sort); do
            local basename=$(basename "$file")
            local file_category="${MODULE_CATEGORIES[$basename]:-Uncategorized}"
            
            if [[ "$file_category" == "$category" ]]; then
                local anchor=$(echo "$basename" | sed 's/\.sh$//' | tr '[:upper:]_' '[:lower:]-')
                echo "- [$basename](#module-$anchor)" >> "$OUTPUT_FILE"
            fi
        done
        echo "" >> "$OUTPUT_FILE"
    done
    
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Extract documentation for each module
    local module_count=0
    for file in $(find . -maxdepth 1 -name "*.sh" ! -name "test_*.sh" | sort); do
        ((module_count++))
        local basename=$(basename "$file")
        local module_name="${basename%.sh}"
        local category="${MODULE_CATEGORIES[$basename]:-Uncategorized}"
        
        echo "Processing [$module_count/$total_modules] $basename..."
        
        echo "## Module: $basename" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "**Location**: \`src/workflow/lib/$basename\`  " >> "$OUTPUT_FILE"
        echo "**Category**: $category" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        local purpose=$(extract_module_purpose "$file")
        if [[ -n "$purpose" ]]; then
            echo "**Purpose**: $purpose" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
        
        local functions=$(get_functions "$file")
        if [[ -n "$functions" ]]; then
            local func_count=$(echo "$functions" | wc -l)
            echo "**Functions**: $func_count" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            
            while IFS= read -r func_name; do
                [[ -z "$func_name" ]] && continue
                
                echo "### \`$func_name\`" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                
                local docs=$(extract_function_docs "$file" "$func_name")
                if [[ -n "$docs" ]]; then
                    echo "$docs" | while IFS= read -r doc_line; do
                        [[ -z "$doc_line" ]] && continue
                        echo "$doc_line" >> "$OUTPUT_FILE"
                    done
                    echo "" >> "$OUTPUT_FILE"
                fi
                
                echo "---" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            done <<< "$functions"
        else
            echo "*No public functions documented*" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
        
        echo "" >> "$OUTPUT_FILE"
    done
    
    echo "✓ API documentation generated: $OUTPUT_FILE"
    echo "  Total modules: $total_modules"
    echo "  Total functions: $total_functions"
}

main "$@"
