#!/bin/bash
set -euo pipefail

################################################################################
# Model Selector Module
# Purpose: Intelligent AI model selection based on change complexity
# Part of: Tests & Documentation Workflow Automation v3.2.0
# Created: 2026-02-06
################################################################################

# ==============================================================================
# CONFIGURATION LOADING
# ==============================================================================

# Load configuration from YAML file
load_model_selection_config() {
    local config_file="${AI_WORKFLOW_ROOT:-.}/.workflow_core/config/model_selection_rules.yaml"
    
    # If config file exists, load settings
    if [[ -f "$config_file" ]]; then
        # Future: Parse YAML and override defaults
        # For now, we use hardcoded defaults
        return 0
    fi
    
    return 0
}

# ==============================================================================
# MODEL VALIDATION
# ==============================================================================

# List of supported GitHub Copilot models
declare -a SUPPORTED_MODELS
SUPPORTED_MODELS=(
    # Claude models
    "claude-haiku-4.5"
    "claude-sonnet-4.0"
    "claude-sonnet-4.5"
    "claude-opus-4.1"
    "claude-opus-4.5"
    "claude-opus-4.6"
    # GPT models
    "gpt-4.1"
    "gpt-5"
    "gpt-5-mini"
    "gpt-5.1"
    "gpt-5.1-codex"
    "gpt-5.1-codex-mini"
    "gpt-5.1-codex-max"
    "gpt-5.2"
    "gpt-5.2-codex"
    # Gemini models
    "gemini-2.5-pro"
    "gemini-3-flash"
    "gemini-3-pro"
    # Grok models
    "grok-code-fast-1"
    # Qwen models
    "qwen2.5"
    # Raptor models
    "raptor-mini"
)

# Validate model name
# Usage: validate_model_name <model_name>
# Returns: 0 if valid, 1 if invalid
validate_model_name() {
    local model="$1"
    
    # Check if model is in supported list
    for supported_model in "${SUPPORTED_MODELS[@]}"; do
        if [[ "$model" == "$supported_model" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Get list of supported models
# Usage: list_supported_models
# Returns: Space-separated list of models
list_supported_models() {
    echo "${SUPPORTED_MODELS[@]}"
}

# Suggest similar models if invalid
# Usage: suggest_similar_models <invalid_model>
# Returns: List of similar model names
suggest_similar_models() {
    local invalid_model="$1"
    local suggestions=""
    
    # Simple string matching - suggest models that contain similar parts
    for model in "${SUPPORTED_MODELS[@]}"; do
        # Check if models share common prefix or contain similar text
        if [[ "$model" == *"${invalid_model:0:5}"* ]] || [[ "$invalid_model" == *"${model:0:5}"* ]]; then
            suggestions="${suggestions}${model} "
        fi
    done
    
    # If no suggestions, return popular defaults
    if [[ -z "$suggestions" ]]; then
        suggestions="claude-sonnet-4.5 gpt-5.1-codex claude-opus-4.5"
    fi
    
    echo "$suggestions" | xargs
}

# ==============================================================================
# CONFIGURATION AND CONSTANTS
# ==============================================================================

# Model tier definitions based on GitHub Copilot model comparison
# https://docs.github.com/en/copilot/reference/ai-models/model-comparison
declare -A MODEL_TIERS
MODEL_TIERS=(
    # Tier 1: Fast (Low Complexity 0-25)
    ["tier_1_primary"]="claude-haiku-4.5"
    ["tier_1_alt1"]="gpt-5-mini"
    ["tier_1_alt2"]="gemini-3-flash"
    
    # Tier 2: Balanced (Medium Complexity 26-60)
    ["tier_2_primary"]="claude-sonnet-4.5"
    ["tier_2_alt1"]="gpt-5.1-codex"
    ["tier_2_alt2"]="gpt-5-mini"
    
    # Tier 3: Deep Reasoning (High Complexity 61-90)
    ["tier_3_primary"]="claude-opus-4.5"
    ["tier_3_alt1"]="gpt-5.2"
    ["tier_3_alt2"]="claude-sonnet-4.0"
    ["tier_3_alt3"]="gemini-3-pro"
    
    # Tier 4: Agentic (Very High Complexity 91+)
    ["tier_4_primary"]="claude-opus-4.6"
    ["tier_4_alt1"]="gpt-5.2-codex"
    ["tier_4_alt2"]="gpt-5.1-codex-max"
)

# Complexity thresholds
COMPLEXITY_TIER_1_MAX=25
COMPLEXITY_TIER_2_MAX=60
COMPLEXITY_TIER_3_MAX=90

# Complexity calculation weights
CODE_CYCLOMATIC_WEIGHT=2.0
CODE_LINES_DIVISOR=10
CODE_DEPTH_WEIGHT=1.5

DOCS_WORDS_DIVISOR=100
DOCS_FILES_WEIGHT=0.5
DOCS_STRUCTURAL_WEIGHT=2.0

TESTS_CASES_WEIGHT=1.5
TESTS_LINES_DIVISOR=20
TESTS_COVERAGE_WEIGHT=2.0

# Semantic complexity factors
declare -A SEMANTIC_FACTORS
SEMANTIC_FACTORS=(
    ["minor_change"]=5
    ["enhancement"]=15
    ["major_refactor"]=30
    ["architectural_change"]=50
)

# ==============================================================================
# CYCLOMATIC COMPLEXITY ANALYSIS
# ==============================================================================

# Calculate cyclomatic complexity for a code file
# Usage: calculate_cyclomatic_complexity <file_path>
# Returns: Complexity score (integer)
calculate_cyclomatic_complexity() {
    local file="$1"
    
    [[ ! -f "$file" ]] && echo "0" && return 0
    
    local complexity=1  # Base complexity
    
    # Count control flow structures
    # if/else, for, while, case, catch, &&, ||, ?:
    local if_count=$(grep -c -E '\b(if|else if)\b' "$file" 2>/dev/null || echo "0")
    if_count=${if_count//[^0-9]/}  # Remove non-numeric characters
    if_count=${if_count:-0}         # Default to 0 if empty
    
    local for_count=$(grep -c -E '\b(for|foreach)\b' "$file" 2>/dev/null || echo "0")
    for_count=${for_count//[^0-9]/}
    for_count=${for_count:-0}
    
    local while_count=$(grep -c -E '\bwhile\b' "$file" 2>/dev/null || echo "0")
    while_count=${while_count//[^0-9]/}
    while_count=${while_count:-0}
    
    local case_count=$(grep -c -E '\b(case|when)\b' "$file" 2>/dev/null || echo "0")
    case_count=${case_count//[^0-9]/}
    case_count=${case_count:-0}
    
    local catch_count=$(grep -c -E '\b(catch|except)\b' "$file" 2>/dev/null || echo "0")
    catch_count=${catch_count//[^0-9]/}
    catch_count=${catch_count:-0}
    
    local and_or_count=$(grep -c -E '(\&\&|\|\|)' "$file" 2>/dev/null || echo "0")
    and_or_count=${and_or_count//[^0-9]/}
    and_or_count=${and_or_count:-0}
    
    local ternary_count=$(grep -c -E '\?' "$file" 2>/dev/null || echo "0")
    ternary_count=${ternary_count//[^0-9]/}
    ternary_count=${ternary_count:-0}
    
    complexity=$((complexity + if_count + for_count + while_count + case_count + catch_count + and_or_count + ternary_count))
    
    echo "$complexity"
}

# Calculate maximum function nesting depth for a file
# Usage: calculate_function_depth <file_path>
# Returns: Maximum depth (integer)
calculate_function_depth() {
    local file="$1"
    
    [[ ! -f "$file" ]] && echo "0" && return 0
    
    local max_depth=0
    local current_depth=0
    
    # Count brace nesting (approximate for most languages)
    while IFS= read -r line; do
        local open_braces=$(echo "$line" | grep -o '{' | wc -l)
        local close_braces=$(echo "$line" | grep -o '}' | wc -l)
        
        current_depth=$((current_depth + open_braces - close_braces))
        
        if [[ $current_depth -gt $max_depth ]]; then
            max_depth=$current_depth
        fi
    done < "$file"
    
    echo "$max_depth"
}

# ==============================================================================
# SEMANTIC ANALYSIS
# ==============================================================================

# Detect semantic complexity factor from git commit messages and diff patterns
# Usage: detect_semantic_factor <file_list>
# Returns: One of: minor_change, enhancement, major_refactor, architectural_change
detect_semantic_factor() {
    local files="$1"
    
    # Check recent commit messages for keywords
    local recent_commits=$(git log -5 --pretty=format:"%s" 2>/dev/null || echo "")
    
    # Architectural change indicators
    if echo "$recent_commits" | grep -qi -E '(architect|redesign|breaking|migration|major refactor)'; then
        echo "architectural_change"
        return 0
    fi
    
    # Major refactor indicators
    if echo "$recent_commits" | grep -qi -E '(refactor|restructure|rewrite)'; then
        echo "major_refactor"
        return 0
    fi
    
    # Enhancement indicators
    if echo "$recent_commits" | grep -qi -E '(feature|feat|enhance|improve|add)'; then
        echo "enhancement"
        return 0
    fi
    
    # Check file count - many files suggest larger changes
    local file_count=$(echo "$files" | wc -w)
    if [[ $file_count -gt 10 ]]; then
        echo "major_refactor"
        return 0
    fi
    
    # Default to minor change
    echo "minor_change"
}

# ==============================================================================
# COMPLEXITY CALCULATION BY FILE TYPE
# ==============================================================================

# Calculate complexity for code files
# Usage: calculate_code_complexity <file_list>
# Returns: JSON object with score and factors
calculate_code_complexity() {
    local files="$1"
    
    [[ -z "$files" ]] && echo '{"score":0,"tier":"low","factors":{"cyclomatic":0,"lines_changed":0,"function_depth":0,"semantic":"none"}}' && return 0
    
    local total_cyclomatic=0
    local total_lines=0
    local max_depth=0
    local file_count=0
    
    # Analyze each code file
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        local cyclomatic=$(calculate_cyclomatic_complexity "$file")
        cyclomatic=${cyclomatic//[^0-9]/}
        cyclomatic=${cyclomatic:-0}
        
        local depth=$(calculate_function_depth "$file")
        depth=${depth//[^0-9]/}
        depth=${depth:-0}
        
        local lines=$(git diff --numstat HEAD -- "$file" 2>/dev/null | awk '{print $1+$2}' || echo "0")
        lines=${lines//[^0-9]/}
        lines=${lines:-0}
        
        total_cyclomatic=$((total_cyclomatic + cyclomatic))
        total_lines=$((total_lines + lines))
        
        if [[ $depth -gt $max_depth ]]; then
            max_depth=$depth
        fi
        
        ((file_count++))
    done <<< "$files"
    
    # Get semantic factor
    local semantic=$(detect_semantic_factor "$files")
    local semantic_value=${SEMANTIC_FACTORS[$semantic]}
    
    # Calculate combined score
    local cyclomatic_component=$(echo "$total_cyclomatic * $CODE_CYCLOMATIC_WEIGHT" | bc 2>/dev/null || echo "$total_cyclomatic")
    local lines_component=$(echo "$total_lines / $CODE_LINES_DIVISOR" | bc 2>/dev/null || echo "0")
    local depth_component=$(echo "$max_depth * $CODE_DEPTH_WEIGHT" | bc 2>/dev/null || echo "0")
    
    local score=$(echo "$cyclomatic_component + $lines_component + $depth_component + $semantic_value" | bc 2>/dev/null || echo "0")
    score=${score%.*}  # Convert to integer
    
    # Determine tier
    local tier="low"
    if [[ $score -gt $COMPLEXITY_TIER_3_MAX ]]; then
        tier="very_high"
    elif [[ $score -gt $COMPLEXITY_TIER_2_MAX ]]; then
        tier="high"
    elif [[ $score -gt $COMPLEXITY_TIER_1_MAX ]]; then
        tier="medium"
    fi
    
    # Return JSON
    cat <<EOF
{
  "score": $score,
  "tier": "$tier",
  "factors": {
    "cyclomatic": $total_cyclomatic,
    "lines_changed": $total_lines,
    "function_depth": $max_depth,
    "semantic": "$semantic"
  }
}
EOF
}

# Calculate complexity for documentation files
# Usage: calculate_docs_complexity <file_list>
# Returns: JSON object with score and factors
calculate_docs_complexity() {
    local files="$1"
    
    [[ -z "$files" ]] && echo '{"score":0,"tier":"low","factors":{"words_changed":0,"files_affected":0,"structural_changes":0,"primary_doc":false}}' && return 0
    
    local total_words=0
    local file_count=0
    local structural_changes=0
    local primary_doc_modified=false
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        # Count words changed (approximate: lines * 10)
        local lines=$(git diff --numstat HEAD -- "$file" 2>/dev/null | awk '{print $1+$2}' || echo "0")
        lines=${lines//[^0-9]/}
        lines=${lines:-0}
        local words=$((lines * 10))
        total_words=$((total_words + words))
        
        # Detect structural changes (headings, tables, lists)
        local heading_changes=$(git diff HEAD -- "$file" 2>/dev/null | grep -c -E '^\+#{1,6}\s|^\-#{1,6}\s' || echo "0")
        heading_changes=${heading_changes//[^0-9]/}
        heading_changes=${heading_changes:-0}
        
        local table_changes=$(git diff HEAD -- "$file" 2>/dev/null | grep -c -E '^\+\||\^\-\|' || echo "0")
        table_changes=${table_changes//[^0-9]/}
        table_changes=${table_changes:-0}
        
        structural_changes=$((structural_changes + heading_changes + table_changes))
        
        # Check if primary doc
        if [[ "$file" =~ README\.md$ ]] || [[ "$file" =~ ^docs/index\.md$ ]]; then
            primary_doc_modified=true
        fi
        
        ((file_count++))
    done <<< "$files"
    
    # Calculate score
    local words_component=$(echo "$total_words / $DOCS_WORDS_DIVISOR" | bc 2>/dev/null || echo "0")
    local files_component=$(echo "$file_count * $DOCS_FILES_WEIGHT" | bc 2>/dev/null || echo "0")
    local structural_component=$(echo "$structural_changes * $DOCS_STRUCTURAL_WEIGHT" | bc 2>/dev/null || echo "0")
    local primary_modifier=0
    [[ "$primary_doc_modified" == true ]] && primary_modifier=5
    
    local score=$(echo "$words_component + $files_component + $structural_component + $primary_modifier" | bc 2>/dev/null || echo "0")
    score=${score%.*}
    
    # Determine tier
    local tier="low"
    if [[ $score -gt $COMPLEXITY_TIER_2_MAX ]]; then
        tier="high"
    elif [[ $score -gt $COMPLEXITY_TIER_1_MAX ]]; then
        tier="medium"
    fi
    
    # Return JSON
    cat <<EOF
{
  "score": $score,
  "tier": "$tier",
  "factors": {
    "words_changed": $total_words,
    "files_affected": $file_count,
    "structural_changes": $structural_changes,
    "primary_doc": $primary_doc_modified
  }
}
EOF
}

# Calculate complexity for test files
# Usage: calculate_tests_complexity <file_list>
# Returns: JSON object with score and factors
calculate_tests_complexity() {
    local files="$1"
    
    [[ -z "$files" ]] && echo '{"score":0,"tier":"low","factors":{"test_cases":0,"lines_changed":0,"coverage_impact":"none"}}' && return 0
    
    local total_test_cases=0
    local total_lines=0
    local coverage_impact="minor_update"
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        # Count test cases (test/it/describe patterns)
        local test_cases=$(grep -c -E '\b(test|it|describe)\s*\(' "$file" 2>/dev/null || echo "0")
        test_cases=${test_cases//[^0-9]/}
        test_cases=${test_cases:-0}
        total_test_cases=$((total_test_cases + test_cases))
        
        # Count lines changed
        local lines=$(git diff --numstat HEAD -- "$file" 2>/dev/null | awk '{print $1+$2}' || echo "0")
        lines=${lines//[^0-9]/}
        lines=${lines:-0}
        total_lines=$((total_lines + lines))
    done <<< "$files"
    
    # Detect coverage impact from commit messages
    local recent_commits=$(git log -3 --pretty=format:"%s" 2>/dev/null || echo "")
    if echo "$recent_commits" | grep -qi -E '(coverage|new test|test expansion)'; then
        coverage_impact="new_coverage"
    fi
    if [[ $total_test_cases -gt 20 ]]; then
        coverage_impact="major_expansion"
    fi
    
    # Calculate score
    local cases_component=$(echo "$total_test_cases * $TESTS_CASES_WEIGHT" | bc 2>/dev/null || echo "0")
    local lines_component=$(echo "$total_lines / $TESTS_LINES_DIVISOR" | bc 2>/dev/null || echo "0")
    
    local coverage_value=5
    [[ "$coverage_impact" == "new_coverage" ]] && coverage_value=15
    [[ "$coverage_impact" == "major_expansion" ]] && coverage_value=30
    
    local coverage_component=$(echo "$coverage_value * $TESTS_COVERAGE_WEIGHT" | bc 2>/dev/null || echo "0")
    
    local score=$(echo "$cases_component + $lines_component + $coverage_component" | bc 2>/dev/null || echo "0")
    score=${score%.*}
    
    # Determine tier
    local tier="low"
    if [[ $score -gt $COMPLEXITY_TIER_2_MAX ]]; then
        tier="high"
    elif [[ $score -gt $COMPLEXITY_TIER_1_MAX ]]; then
        tier="medium"
    fi
    
    # Return JSON
    cat <<EOF
{
  "score": $score,
  "tier": "$tier",
  "factors": {
    "test_cases": $total_test_cases,
    "lines_changed": $total_lines,
    "coverage_impact": "$coverage_impact"
  }
}
EOF
}

# ==============================================================================
# MODEL SELECTION
# ==============================================================================

# Map complexity tier to model
# Usage: get_model_for_tier <tier> <step_id>
# Returns: Model name
get_model_for_tier() {
    local tier="$1"
    local step_id="${2:-}"
    
    # Apply step-specific adjustments
    case "$step_id" in
        step_06_test_gen)
            # Test generation needs one tier higher
            case "$tier" in
                low) tier="medium" ;;
                medium) tier="high" ;;
                high) tier="very_high" ;;
            esac
            ;;
        step_14_ux_analysis)
            # UX analysis always uses deep reasoning
            tier="high"
            ;;
    esac
    
    # Select model based on tier
    case "$tier" in
        low|tier_1)
            echo "${MODEL_TIERS[tier_1_primary]}"
            ;;
        medium|tier_2)
            echo "${MODEL_TIERS[tier_2_primary]}"
            ;;
        high|tier_3)
            echo "${MODEL_TIERS[tier_3_primary]}"
            ;;
        very_high|tier_4)
            echo "${MODEL_TIERS[tier_4_primary]}"
            ;;
        *)
            echo "${MODEL_TIERS[tier_2_primary]}"  # Default to balanced
            ;;
    esac
}

# Get alternative models for a tier
# Usage: get_alternative_models <tier>
# Returns: Space-separated list of alternative models
get_alternative_models() {
    local tier="$1"
    
    case "$tier" in
        low|tier_1)
            echo "${MODEL_TIERS[tier_1_alt1]} ${MODEL_TIERS[tier_1_alt2]}"
            ;;
        medium|tier_2)
            echo "${MODEL_TIERS[tier_2_alt1]} ${MODEL_TIERS[tier_2_alt2]}"
            ;;
        high|tier_3)
            echo "${MODEL_TIERS[tier_3_alt1]} ${MODEL_TIERS[tier_3_alt2]} ${MODEL_TIERS[tier_3_alt3]}"
            ;;
        very_high|tier_4)
            echo "${MODEL_TIERS[tier_4_alt1]} ${MODEL_TIERS[tier_4_alt2]}"
            ;;
        *)
            echo "${MODEL_TIERS[tier_2_alt1]}"
            ;;
    esac
}

# Get reason for model selection
# Usage: get_model_reason <tier> <category>
# Returns: Human-readable reason
get_model_reason() {
    local tier="$1"
    local category="$2"
    
    case "$tier" in
        low)
            echo "Low complexity ${category} changes - fast model sufficient"
            ;;
        medium)
            echo "Medium complexity ${category} changes - balanced model recommended"
            ;;
        high)
            echo "High complexity ${category} changes - deep reasoning required"
            ;;
        very_high)
            echo "Very high complexity ${category} changes - agentic model for complex reasoning"
            ;;
        *)
            echo "Default model selection for ${category}"
            ;;
    esac
}

# ==============================================================================
# MODEL DEFINITIONS GENERATION
# ==============================================================================

# Generate model definitions for all workflow steps
# Usage: generate_model_definitions <code_files> <doc_files> <test_files>
# Returns: JSON object with model definitions
generate_model_definitions() {
    local code_files="$1"
    local doc_files="$2"
    local test_files="$3"
    
    # Calculate complexities
    local code_complexity=$(calculate_code_complexity "$code_files")
    local docs_complexity=$(calculate_docs_complexity "$doc_files")
    local tests_complexity=$(calculate_tests_complexity "$test_files")
    
    # Extract scores and tiers
    local code_score=$(echo "$code_complexity" | jq -r '.score')
    local code_tier=$(echo "$code_complexity" | jq -r '.tier')
    local docs_score=$(echo "$docs_complexity" | jq -r '.score')
    local docs_tier=$(echo "$docs_complexity" | jq -r '.tier')
    local tests_score=$(echo "$tests_complexity" | jq -r '.score')
    local tests_tier=$(echo "$tests_complexity" | jq -r '.tier')
    
    # Generate step-by-step model assignments
    local workflow_run_id="${WORKFLOW_RUN_ID:-workflow_$(date +%Y%m%d_%H%M%S)}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    
    # Count files
    local code_count=$(echo "$code_files" | wc -w)
    local docs_count=$(echo "$doc_files" | wc -w)
    local tests_count=$(echo "$test_files" | wc -w)
    local total_files=$((code_count + docs_count + tests_count))
    
    # Build JSON
    cat <<EOF
{
  "workflow_run_id": "$workflow_run_id",
  "generated_at": "$timestamp",
  "git_info": {
    "commit": "$git_commit",
    "branch": "$git_branch"
  },
  "change_summary": {
    "total_files": $total_files,
    "by_category": {
      "code": $code_count,
      "documentation": $docs_count,
      "tests": $tests_count
    }
  },
  "complexity_analysis": {
    "code": $code_complexity,
    "documentation": $docs_complexity,
    "tests": $tests_complexity
  },
  "model_definitions": {
    "step_0a_version_update": {
      "model": "$(get_model_for_tier "$code_tier" "step_0a_version_update")",
      "reason": "$(get_model_reason "$code_tier" "version analysis")",
      "tier": "$code_tier",
      "alternatives": [$(get_alternative_models "$code_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_0b_bootstrap_docs": {
      "model": "$(get_model_for_tier "medium" "step_0b_bootstrap_docs")",
      "reason": "Documentation generation from scratch requires reasoning",
      "tier": "medium",
      "alternatives": [$(get_alternative_models "medium" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_01_documentation": {
      "model": "$(get_model_for_tier "$docs_tier" "step_01_documentation")",
      "reason": "$(get_model_reason "$docs_tier" "documentation")",
      "tier": "$docs_tier",
      "alternatives": [$(get_alternative_models "$docs_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_02_consistency": {
      "model": "$(get_model_for_tier "$docs_tier" "step_02_consistency")",
      "reason": "$(get_model_reason "$docs_tier" "documentation validation")",
      "tier": "$docs_tier",
      "alternatives": [$(get_alternative_models "$docs_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_03_script_refs": {
      "model": "$(get_model_for_tier "$code_tier" "step_03_script_refs")",
      "reason": "$(get_model_reason "$code_tier" "script analysis")",
      "tier": "$code_tier",
      "alternatives": [$(get_alternative_models "$code_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_05_test_review": {
      "model": "$(get_model_for_tier "$tests_tier" "step_05_test_review")",
      "reason": "$(get_model_reason "$tests_tier" "test analysis")",
      "tier": "$tests_tier",
      "alternatives": [$(get_alternative_models "$tests_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_06_test_gen": {
      "model": "$(get_model_for_tier "$tests_tier" "step_06_test_gen")",
      "reason": "Test generation (tier adjusted: $tests_tier → higher)",
      "tier": "$tests_tier",
      "alternatives": [$(get_alternative_models "$tests_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_09_code_quality": {
      "model": "$(get_model_for_tier "$code_tier" "step_09_code_quality")",
      "reason": "$(get_model_reason "$code_tier" "code analysis")",
      "tier": "$code_tier",
      "alternatives": [$(get_alternative_models "$code_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_13_prompt_engineer": {
      "model": "$(get_model_for_tier "high" "step_13_prompt_engineer")",
      "reason": "Prompt engineering requires deep reasoning",
      "tier": "high",
      "alternatives": [$(get_alternative_models "high" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_14_ux_analysis": {
      "model": "$(get_model_for_tier "$code_tier" "step_14_ux_analysis")",
      "reason": "UX analysis (forced tier: high for UI reasoning)",
      "tier": "high",
      "alternatives": [$(get_alternative_models "high" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    },
    "step_15_version_update": {
      "model": "$(get_model_for_tier "$code_tier" "step_15_version_update")",
      "reason": "$(get_model_reason "$code_tier" "version finalization")",
      "tier": "$code_tier",
      "alternatives": [$(get_alternative_models "$code_tier" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ' ')]
    }
  },
  "override": null
}
EOF
}

# ==============================================================================
# PERSISTENCE
# ==============================================================================

# Save model definitions to JSON file
# Usage: save_model_definitions <json_content>
# Returns: 0 on success, 1 on failure
save_model_definitions() {
    local json_content="$1"
    local definitions_dir="${PROJECT_ROOT:-.}/.ai_workflow"
    local definitions_file="${definitions_dir}/model_definitions.json"
    local temp_file="${definitions_file}.tmp"
    
    # Create directory if needed
    mkdir -p "$definitions_dir"
    
    # Validate JSON
    if ! echo "$json_content" | jq empty 2>/dev/null; then
        echo "ERROR: Invalid JSON generated" >&2
        return 1
    fi
    
    # Write to temp file
    echo "$json_content" > "$temp_file"
    
    # Atomic move
    mv "$temp_file" "$definitions_file"
    chmod 644 "$definitions_file"
    
    return 0
}

# Load model definitions from JSON file
# Usage: load_model_definitions
# Returns: JSON content or empty object
load_model_definitions() {
    local definitions_file="${PROJECT_ROOT:-.}/.ai_workflow/model_definitions.json"
    
    if [[ -f "$definitions_file" ]]; then
        cat "$definitions_file"
    else
        echo "{}"
    fi
}

# Export functions
export -f load_model_selection_config
export -f validate_model_name
export -f list_supported_models
export -f suggest_similar_models
export -f calculate_cyclomatic_complexity
export -f calculate_function_depth
export -f detect_semantic_factor
export -f calculate_code_complexity
export -f calculate_docs_complexity
export -f calculate_tests_complexity
export -f get_model_for_tier
export -f get_alternative_models
export -f get_model_reason
export -f generate_model_definitions
export -f save_model_definitions
export -f load_model_definitions
