#!/bin/bash
set -euo pipefail

################################################################################
# Skip Predictor Module
# Version: 1.0.0 (Phase 1 - Foundation)
# Purpose: ML-powered step necessity prediction for intelligent orchestration
#
# Features:
#   - Predict step necessity based on historical data
#   - Feature similarity matching (cosine similarity)
#   - Confidence scoring (multi-factor)
#   - Safety mechanisms (critical steps, high-risk changes)
#   - Skip history tracking
#
# Performance Target: 95%+ accuracy, <5% false positive rate
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/jq_wrapper.sh" ]]; then
    source "${SCRIPT_DIR}/jq_wrapper.sh"
else
    jq_safe() { jq "$@"; }
fi

# ML data directories
ML_DATA_DIR="${ML_DATA_DIR:-${WORKFLOW_HOME}/.ml_data}"
ML_SKIP_HISTORY="${ML_SKIP_HISTORY:-${ML_DATA_DIR}/skip_history.jsonl}"
ML_TRAINING_DATA="${ML_TRAINING_DATA:-${ML_DATA_DIR}/training_data.jsonl}"

# Confidence thresholds
CONFIDENCE_AUTO_SKIP=0.85      # Auto-skip if confidence >= 0.85
CONFIDENCE_WARN_SKIP=0.70      # Skip with warning if >= 0.70
CONFIDENCE_PROMPT_USER=0.50    # Prompt user if >= 0.50
# Below 0.50: Always run (safety first)

# Critical steps that should NEVER be skipped
declare -a CRITICAL_STEPS=(0 15)

# Export for subshells
export ML_SKIP_HISTORY

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize skip prediction system
init_skip_predictor() {
    mkdir -p "$ML_DATA_DIR"
    
    if [[ ! -f "$ML_SKIP_HISTORY" ]]; then
        touch "$ML_SKIP_HISTORY"
    fi
    
    # Check if we have enough data
    local skip_sample_count=$(wc -l < "$ML_SKIP_HISTORY" 2>/dev/null || echo "0")
    local training_sample_count=$(wc -l < "$ML_TRAINING_DATA" 2>/dev/null || echo "0")
    
    if [[ $training_sample_count -lt 10 ]]; then
        export SKIP_PREDICTION_ENABLED=false
        return 1
    else
        export SKIP_PREDICTION_ENABLED=true
        return 0
    fi
}

# ==============================================================================
# FEATURE SIMILARITY
# ==============================================================================

# Calculate cosine similarity between feature vectors
# Args: $1 = features_json_1, $2 = features_json_2
# Returns: similarity score (0.0 - 1.0)
calculate_feature_similarity() {
    local features1="$1"
    local features2="$2"
    
    # Extract feature values
    local f1_total=$(echo "$features1" | jq -r '.total_files // 0')
    local f1_doc=$(echo "$features1" | jq -r '.doc_files // 0')
    local f1_code=$(echo "$features1" | jq -r '.code_files // 0')
    local f1_test=$(echo "$features1" | jq -r '.test_files // 0')
    local f1_lines=$(echo "$features1" | jq -r '.lines_changed // 0')
    
    local f2_total=$(echo "$features2" | jq -r '.total_files // 0')
    local f2_doc=$(echo "$features2" | jq -r '.doc_files // 0')
    local f2_code=$(echo "$features2" | jq -r '.code_files // 0')
    local f2_test=$(echo "$features2" | jq -r '.test_files // 0')
    local f2_lines=$(echo "$features2" | jq -r '.lines_changed // 0')
    
    # Change type similarity (categorical)
    local type1=$(echo "$features1" | jq -r '.change_type // "mixed"')
    local type2=$(echo "$features2" | jq -r '.change_type // "mixed"')
    local type_match=0
    [[ "$type1" == "$type2" ]] && type_match=1
    
    # Calculate similarity using awk (faster and more reliable than bc)
    local similarity=$(awk -v f1_total="$f1_total" -v f2_total="$f2_total" \
                              -v f1_doc="$f1_doc" -v f2_doc="$f2_doc" \
                              -v f1_code="$f1_code" -v f2_code="$f2_code" \
                              -v f1_test="$f1_test" -v f2_test="$f2_test" \
                              -v f1_lines="$f1_lines" -v f2_lines="$f2_lines" \
                              -v type_match="$type_match" '
        BEGIN {
            # Calculate normalized differences
            total_diff = sqrt((f1_total - f2_total)^2) / (f1_total + f2_total + 1)
            doc_diff = sqrt((f1_doc - f2_doc)^2) / (f1_doc + f2_doc + 1)
            code_diff = sqrt((f1_code - f2_code)^2) / (f1_code + f2_code + 1)
            test_diff = sqrt((f1_test - f2_test)^2) / (f1_test + f2_test + 1)
            lines_diff = sqrt((f1_lines - f2_lines)^2) / (f1_lines + f2_lines + 1)
            
            # Calculate similarity
            sim = 1 - ((total_diff + doc_diff + code_diff + test_diff + lines_diff) / 5)
            
            # Boost if types match
            if (type_match == 1) {
                sim = sim * 1.2
                if (sim > 1.0) sim = 1.0
            }
            
            printf "%.2f", sim
        }
    ')
    
    echo "$similarity"
}

# ==============================================================================
# SKIP HISTORY QUERIES
# ==============================================================================

# Query skip history for similar executions
# Args: $1 = step_number, $2 = features_json
# Returns: JSON with historical skip data
query_skip_history() {
    local step="$1"
    local features="$2"
    
    [[ ! -f "$ML_SKIP_HISTORY" ]] && echo '{"sample_count":0,"skip_rate":0,"confidence":0}' && return 0
    
    # Find similar executions (similarity > 0.7)
    local similar_runs=()
    local total_found=0
    local skipped_count=0
    local success_count=0
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        local hist_step=$(echo "$line" | jq -r '.step // 0')
        [[ "$hist_step" != "$step" ]] && continue
        
        local hist_features=$(echo "$line" | jq -r '.features // {}')
        local similarity=$(calculate_feature_similarity "$features" "$hist_features")
        
        # Only consider if similarity > 0.7
        if awk -v sim="$similarity" 'BEGIN {exit !(sim > 0.7)}'; then
            ((total_found++))
            
            local was_skipped=$(echo "$line" | jq -r '.skipped // false')
            local outcome=$(echo "$line" | jq -r '.outcome // "unknown"')
            
            if [[ "$was_skipped" == "true" ]]; then
                ((skipped_count++))
                [[ "$outcome" == "success" ]] && ((success_count++))
            fi
        fi
    done < "$ML_SKIP_HISTORY"
    
    # Calculate skip rate using awk
    local skip_rate=$(awk -v skipped="$skipped_count" -v total="$total_found" 'BEGIN {
        if (total > 0) printf "%.2f", skipped / total
        else print "0"
    }')
    
    # Calculate confidence based on sample size
    local confidence=0
    if [[ $total_found -ge 20 ]]; then
        confidence=0.95
    elif [[ $total_found -ge 10 ]]; then
        confidence=0.80
    elif [[ $total_found -ge 5 ]]; then
        confidence=0.60
    else
        confidence=0.30
    fi
    
    # Output result
    jq_safe -n \
        --argjson sample_count "$total_found" \
        --argjson skip_rate "$skip_rate" \
        --argjson confidence "$confidence" \
        --argjson success_count "$success_count" \
        '{
            sample_count: $sample_count,
            skip_rate: $skip_rate,
            confidence: $confidence,
            success_count: $success_count
        }'
}

# ==============================================================================
# CONFIDENCE SCORING
# ==============================================================================

# Calculate multi-factor confidence score
# Args: $1 = step, $2 = features, $3 = skip_history_json
# Returns: confidence score (0.0 - 1.0)
calculate_skip_confidence() {
    local step="$1"
    local features="$2"
    local skip_history="$3"
    
    # Factor 1: Sample Size (30% weight)
    local sample_count=$(echo "$skip_history" | jq -r '.sample_count // 0')
    local sample_score=0.3
    if [[ $sample_count -ge 20 ]]; then
        sample_score=0.95
    elif [[ $sample_count -ge 10 ]]; then
        sample_score=0.80
    elif [[ $sample_count -ge 5 ]]; then
        sample_score=0.60
    else
        sample_score=0.30
    fi
    
    # Factor 2: Historical Success Rate (25% weight)
    local skip_rate=$(echo "$skip_history" | jq -r '.skip_rate // 0')
    local success_count=$(echo "$skip_history" | jq -r '.success_count // 0')
    local success_rate=$(awk -v skip_rate="$skip_rate" -v success="$success_count" -v samples="$sample_count" 'BEGIN {
        if (samples > 0 && skip_rate > 0) {
            total_skips = int(samples * skip_rate)
            if (total_skips < 1) total_skips = 1
            printf "%.2f", success / total_skips
        } else {
            print "1.0"
        }
    }')
    
    # Factor 3: Feature Match Quality (30% weight)
    # Already incorporated in query_skip_history (similarity > 0.7)
    local feature_score=0.85
    
    # Factor 4: Recency (15% weight)
    # For now, use a fixed score (will implement time-based weighting later)
    local recency_score=0.90
    
    # Composite confidence using awk
    local confidence=$(awk -v ss="$sample_score" -v sr="$success_rate" -v fs="$feature_score" -v rs="$recency_score" 'BEGIN {
        printf "%.2f", (ss * 0.30) + (sr * 0.25) + (fs * 0.30) + (rs * 0.15)
    }')
    
    echo "$confidence"
}

# ==============================================================================
# SAFETY MECHANISMS
# ==============================================================================

# Check if step is safe to skip
# Args: $1 = step_number, $2 = confidence, $3 = features
# Returns: 0 if safe to skip, 1 if should run
is_safe_to_skip() {
    local step="$1"
    local confidence="$2"
    local features="$3"
    
    # Rule 1: Never skip critical steps
    for critical_step in "${CRITICAL_STEPS[@]}"; do
        [[ "$step" == "$critical_step" ]] && return 1
    done
    
    # Rule 2: Confidence threshold
    if ! awk -v conf="$confidence" -v thresh="$CONFIDENCE_AUTO_SKIP" 'BEGIN {exit !(conf >= thresh)}'; then
        return 1
    fi
    
    # Rule 3: Never skip if prior failure detected
    if [[ "${HAS_PRIOR_FAILURE:-false}" == "true" ]]; then
        return 1
    fi
    
    # Rule 4: Check for high-risk changes
    local change_type=$(echo "$features" | jq -r '.change_type // "mixed"')
    local code_files=$(echo "$features" | jq -r '.code_files // 0')
    local lines_changed=$(echo "$features" | jq -r '.lines_changed // 0')
    
    # High-risk: large code changes
    if [[ "$change_type" =~ "code" ]] && [[ $lines_changed -gt 500 ]]; then
        return 1
    fi
    
    # Rule 5: Step-specific safety rules
    case "$step" in
        5|7|9)  # Test Review, Test Execution, Code Quality - high-value steps
            # Only skip if very high confidence
            if ! awk -v conf="$confidence" 'BEGIN {exit !(conf >= 0.90)}'; then
                return 1
            fi
            ;;
    esac
    
    return 0
}

# ==============================================================================
# SKIP PREDICTION
# ==============================================================================

# Predict if step should be skipped
# Args: $1 = step_number, $2 = features_json
# Returns: JSON prediction with confidence and recommendation
predict_step_necessity() {
    local step="$1"
    local features="$2"
    
    # Initialize if not already done
    if [[ "${SKIP_PREDICTION_ENABLED:-}" != "true" ]]; then
        init_skip_predictor
    fi
    
    # If ML not enabled, return default (run step)
    if [[ "${SKIP_PREDICTION_ENABLED:-false}" != "true" ]]; then
        jq_safe -n \
            --argjson step "$step" \
            '{
                step: $step,
                should_skip: false,
                skip_probability: 0,
                confidence: 0,
                historical_samples: 0,
                risk_level: "unknown",
                reason: "insufficient_data"
            }'
        return 0
    fi
    
    # Query historical skip data
    local skip_history=$(query_skip_history "$step" "$features")
    local skip_rate=$(echo "$skip_history" | jq -r '.skip_rate // 0')
    local sample_count=$(echo "$skip_history" | jq -r '.sample_count // 0')
    
    # Calculate confidence
    local confidence=$(calculate_skip_confidence "$step" "$features" "$skip_history")
    
    # Determine risk level using awk
    local risk_level=$(awk -v sr="$skip_rate" 'BEGIN {
        if (sr > 0.8) print "low"
        else if (sr < 0.2) print "high"
        else print "medium"
    }')
    
    # Safety check
    local should_skip=false
    local reason="safety_check_failed"
    
    if is_safe_to_skip "$step" "$confidence" "$features"; then
        if awk -v sr="$skip_rate" 'BEGIN {exit !(sr > 0.8)}'; then
            should_skip=true
            reason="high_skip_rate"
        fi
    fi
    
    # Build prediction result
    jq_safe -n \
        --argjson step "$step" \
        --argjson should_skip "$([ "$should_skip" = true ] && echo true || echo false)" \
        --argjson skip_probability "$skip_rate" \
        --argjson confidence "$confidence" \
        --argjson historical_samples "$sample_count" \
        --arg risk_level "$risk_level" \
        --arg reason "$reason" \
        '{
            step: $step,
            should_skip: $should_skip,
            skip_probability: $skip_probability,
            confidence: $confidence,
            historical_samples: $historical_samples,
            risk_level: $risk_level,
            reason: $reason
        }'
}

# ==============================================================================
# SKIP DECISION RECORDING
# ==============================================================================

# Record skip decision for learning
# Args: $1 = run_id, $2 = step, $3 = skipped (true/false), $4 = features, $5 = confidence
record_skip_decision() {
    local run_id="$1"
    local step="$2"
    local skipped="$3"
    local features="$4"
    local confidence="$5"
    local reason="${6:-ml_prediction}"
    
    # Create record
    local record=$(jq_safe -n \
        --arg run_id "$run_id" \
        --argjson step "$step" \
        --argjson skipped "$skipped" \
        --arg reason "$reason" \
        --argjson features "$features" \
        --argjson confidence "$confidence" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            run_id: $run_id,
            step: $step,
            skipped: $skipped,
            reason: $reason,
            features: $features,
            confidence: $confidence,
            timestamp: $timestamp,
            outcome: "pending",
            subsequent_failure: false
        }')
    
    # Append to skip history
    echo "$record" >> "$ML_SKIP_HISTORY"
}

# Update skip decision outcome
# Args: $1 = run_id, $2 = step, $3 = outcome (success/should_have_run)
update_skip_outcome() {
    local run_id="$1"
    local step="$2"
    local outcome="$3"
    local subsequent_failure="${4:-false}"
    
    # Create temporary file
    local temp_file="${ML_SKIP_HISTORY}.tmp"
    
    # Update matching record
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        local line_run_id=$(echo "$line" | jq -r '.run_id // ""')
        local line_step=$(echo "$line" | jq -r '.step // 0')
        
        if [[ "$line_run_id" == "$run_id" ]] && [[ "$line_step" == "$step" ]]; then
            # Update outcome
            echo "$line" | jq \
                --arg outcome "$outcome" \
                --argjson subsequent_failure "$subsequent_failure" \
                '.outcome = $outcome | .subsequent_failure = $subsequent_failure'
        else
            echo "$line"
        fi
    done < "$ML_SKIP_HISTORY" > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$ML_SKIP_HISTORY"
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Generate skip prediction report
# Args: $1 = predictions_json_array
generate_skip_report() {
    local predictions="$1"
    
    echo "## Skip Prediction Report"
    echo ""
    echo "| Step | Should Skip | Probability | Confidence | Samples | Risk |"
    echo "|------|-------------|-------------|------------|---------|------|"
    
    echo "$predictions" | jq -r '.[] | 
        "| \(.step) | \(if .should_skip then "✅ Yes" else "❌ No" end) | \(.skip_probability * 100 | floor)% | \(.confidence * 100 | floor)% | \(.historical_samples) | \(.risk_level) |"'
    
    echo ""
    
    # Summary
    local total_steps=$(echo "$predictions" | jq 'length')
    local skipped_steps=$(echo "$predictions" | jq '[.[] | select(.should_skip == true)] | length')
    local time_saved_est=$((skipped_steps * 120))  # Estimate 2 min per step
    
    echo "**Summary:**"
    echo "- Total steps analyzed: $total_steps"
    echo "- Recommended to skip: $skipped_steps"
    echo "- Estimated time saved: ~$((time_saved_est / 60)) minutes"
    echo ""
}

# Export functions
export -f init_skip_predictor
export -f calculate_feature_similarity
export -f query_skip_history
export -f calculate_skip_confidence
export -f is_safe_to_skip
export -f predict_step_necessity
export -f record_skip_decision
export -f update_skip_outcome
export -f generate_skip_report
