#!/bin/bash
set -euo pipefail

################################################################################
# Machine Learning Optimization Module
# Version: 3.0.0
# Purpose: Predictive optimization using historical workflow data
#
# Features:
#   - Step duration prediction based on file patterns
#   - Auto-adjust parallelization based on performance
#   - Smart skip recommendations using ML classification
#   - Continuous learning from execution history
#   - Anomaly detection
#
# Performance Target: 15-30% additional improvement over static optimization
################################################################################

# Set defaults with safe fallbacks for test environments
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
ML_DATA_DIR="${ML_DATA_DIR:-${WORKFLOW_HOME}/.ml_data}"
ML_TRAINING_DATA="${ML_TRAINING_DATA:-${ML_DATA_DIR}/training_data.jsonl}"
ML_MODEL_DIR="${ML_MODEL_DIR:-${ML_DATA_DIR}/models}"
ML_PREDICTIONS="${ML_PREDICTIONS:-${ML_DATA_DIR}/predictions.json}"

# Export for subshells and test environments
export ML_TRAINING_DATA ML_MODEL_DIR ML_PREDICTIONS

# Training thresholds
MIN_TRAINING_SAMPLES=10  # Minimum samples before ML kicks in
RETRAINING_INTERVAL=86400  # Retrain every 24 hours

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize ML data structures
init_ml_system() {
    mkdir -p "$ML_DATA_DIR"
    mkdir -p "$ML_MODEL_DIR"
    
    if [[ ! -f "$ML_TRAINING_DATA" ]]; then
        touch "$ML_TRAINING_DATA"
        print_info "Initialized ML training data store"
    fi
    
    # Check if we have enough data for ML
    local sample_count=$(wc -l < "$ML_TRAINING_DATA" 2>/dev/null || echo "0")
    
    if [[ $sample_count -lt $MIN_TRAINING_SAMPLES ]]; then
        print_warning "ML: Only $sample_count samples (need $MIN_TRAINING_SAMPLES for predictions)"
        export ML_ENABLED=false
        return 1
    else
        print_success "ML: Ready with $sample_count training samples"
        export ML_ENABLED=true
        return 0
    fi
}

# ==============================================================================
# FEATURE EXTRACTION
# ==============================================================================

# Extract features from current changes
# Returns: JSON object with features
extract_change_features() {
    local features="{}"
    
    # File count features
    local total_files=$(get_modified_files | wc -l | tr -d '[:space:]')
    total_files=${total_files:-0}
    [[ ! "$total_files" =~ ^[0-9]+$ ]] && total_files=0
    
    local doc_files=$(get_modified_files | grep -c '\.md$\|^docs/' 2>/dev/null || echo 0)
    doc_files=$(echo "$doc_files" | tr -d '[:space:]')
    doc_files=${doc_files:-0}
    [[ ! "$doc_files" =~ ^[0-9]+$ ]] && doc_files=0
    
    local code_files=$(get_modified_files | grep -c '\.sh$\|\.js$\|\.ts$\|\.py$' 2>/dev/null || echo 0)
    code_files=$(echo "$code_files" | tr -d '[:space:]')
    code_files=${code_files:-0}
    [[ ! "$code_files" =~ ^[0-9]+$ ]] && code_files=0
    
    local test_files=$(get_modified_files | grep -c 'test\|spec' 2>/dev/null || echo 0)
    test_files=$(echo "$test_files" | tr -d '[:space:]')
    test_files=${test_files:-0}
    [[ ! "$test_files" =~ ^[0-9]+$ ]] && test_files=0
    
    local config_files=$(get_modified_files | grep -c 'config\|\.yaml$\|\.json$' 2>/dev/null || echo 0)
    config_files=$(echo "$config_files" | tr -d '[:space:]')
    config_files=${config_files:-0}
    [[ ! "$config_files" =~ ^[0-9]+$ ]] && config_files=0
    
    # Line change features
    local total_lines_added=$(git diff --cached --numstat 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    total_lines_added=$(echo "$total_lines_added" | tr -d '[:space:]')
    total_lines_added=${total_lines_added:-0}
    [[ ! "$total_lines_added" =~ ^[0-9]+$ ]] && total_lines_added=0
    
    local total_lines_deleted=$(git diff --cached --numstat 2>/dev/null | awk '{sum+=$2} END {print sum+0}')
    total_lines_deleted=$(echo "$total_lines_deleted" | tr -d '[:space:]')
    total_lines_deleted=${total_lines_deleted:-0}
    [[ ! "$total_lines_deleted" =~ ^[0-9]+$ ]] && total_lines_deleted=0
    
    local total_lines_changed=$((total_lines_added + total_lines_deleted))
    
    # Change type classification
    local change_type="mixed"
    if [[ $doc_files -gt 0 ]] && [[ $code_files -eq 0 ]]; then
        change_type="docs_only"
    elif [[ $code_files -gt 0 ]] && [[ $doc_files -eq 0 ]]; then
        change_type="code_only"
    elif [[ $test_files -gt 0 ]] && [[ $code_files -eq 0 ]]; then
        change_type="test_only"
    elif [[ $config_files -gt 0 ]]; then
        change_type="config_change"
    fi
    
    # Directory depth (complexity indicator) - strip leading zeros for JSON, handle empty string
    local max_depth=$(get_modified_files | awk -F/ '{print NF}' | sort -rn | head -1 | tr -d '[:space:]' | sed 's/^0*\(.\)/\1/' | sed 's/^$/0/')
    max_depth=${max_depth:-0}
    [[ ! "$max_depth" =~ ^[0-9]+$ ]] && max_depth=0
    
    # Time-based features (strip leading zeros for JSON, handle empty string)
    local hour_of_day=$(date +%H | tr -d '[:space:]' | sed 's/^0*\(.\)/\1/' | sed 's/^$/0/')
    hour_of_day=${hour_of_day:-0}
    [[ ! "$hour_of_day" =~ ^[0-9]+$ ]] && hour_of_day=0
    
    local day_of_week=$(date +%u | tr -d '[:space:]' | sed 's/^0*\(.\)/\1/' | sed 's/^$/1/')
    day_of_week=${day_of_week:-1}
    [[ ! "$day_of_week" =~ ^[0-9]+$ ]] && day_of_week=1
    
    # Build feature vector
    # Log jq arguments for debugging
    if [[ "${DEBUG:-false}" == "true" ]] || [[ "${WORKFLOW_LOG_FILE:-}" != "" ]]; then
        {
            echo "[DEBUG] extract_change_features jq arguments:"
            echo "  change_type=${change_type}"
            echo "  total_files=${total_files}, doc_files=${doc_files}, code_files=${code_files}"
            echo "  test_files=${test_files}, config_files=${config_files}"
            echo "  lines_added=${total_lines_added}, lines_deleted=${total_lines_deleted}, lines_changed=${total_lines_changed}"
            echo "  max_depth=${max_depth}, hour=${hour_of_day}, day=${day_of_week}"
        } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
    fi
    
    features=$(jq -n \
        --arg change_type "$change_type" \
        --argjson total_files "$total_files" \
        --argjson doc_files "$doc_files" \
        --argjson code_files "$code_files" \
        --argjson test_files "$test_files" \
        --argjson config_files "$config_files" \
        --argjson lines_added "$total_lines_added" \
        --argjson lines_deleted "$total_lines_deleted" \
        --argjson lines_changed "$total_lines_changed" \
        --argjson max_depth "$max_depth" \
        --argjson hour "$hour_of_day" \
        --argjson day "$day_of_week" \
        '{
            change_type: $change_type,
            total_files: $total_files,
            doc_files: $doc_files,
            code_files: $code_files,
            test_files: $test_files,
            config_files: $config_files,
            lines_added: $lines_added,
            lines_deleted: $lines_deleted,
            lines_changed: $lines_changed,
            max_depth: $max_depth,
            hour_of_day: $hour,
            day_of_week: $day
        }')
    
    echo "$features"
}

# ==============================================================================
# DURATION PREDICTION
# ==============================================================================

# Predict step duration based on features
# Args: $1 = step_number, $2 = features_json
# Returns: predicted duration in seconds
predict_step_duration() {
    local step="$1"
    local features="$2"
    
    [[ "${ML_ENABLED:-false}" != "true" ]] && echo "0" && return 1
    
    # Extract relevant features
    local change_type=$(echo "$features" | jq -r '.change_type // "mixed"')
    local total_files=$(echo "$features" | jq -r '.total_files // 0')
    local lines_changed=$(echo "$features" | jq -r '.lines_changed // 0')
    
    # Ensure numeric values are valid
    total_files=${total_files//[^0-9]/}
    total_files=${total_files:-0}
    lines_changed=${lines_changed//[^0-9]/}
    lines_changed=${lines_changed:-0}
    
    # Check if training data exists
    if [[ ! -f "$ML_TRAINING_DATA" ]]; then
        echo "0"
        return 0
    fi
    
    # Query historical data for similar patterns
    # Log jq arguments for debugging
    if [[ "${DEBUG:-false}" == "true" ]] || [[ "${WORKFLOW_LOG_FILE:-}" != "" ]]; then
        {
            echo "[DEBUG] predict_step_duration jq arguments:"
            echo "  step=${step}, change_type=${change_type}"
            echo "  total_files=${total_files}, lines_changed=${lines_changed}"
        } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
    fi
    
    local similar_runs=$(jq -s --arg step "$step" \
        --arg change_type "$change_type" \
        --argjson total_files "$total_files" \
        --argjson lines_changed "$lines_changed" \
        '[.[] | select(
            .step == ($step | tonumber) and
            .features.change_type == $change_type and
            ((.features.total_files - $total_files) | fabs) <= 5 and
            ((.features.lines_changed - $lines_changed) | fabs) <= 500
        )]' "$ML_TRAINING_DATA" 2>/dev/null)
    
    # Validate similar_runs is valid JSON
    if ! echo "$similar_runs" | jq -e . >/dev/null 2>&1; then
        echo "0"
        return 0
    fi
    
    local sample_count=$(echo "$similar_runs" | jq 'length' 2>/dev/null)
    sample_count=${sample_count//[^0-9]/}
    sample_count=${sample_count:-0}
    
    if [[ $sample_count -lt 3 ]]; then
        # Not enough similar samples - fall back to overall average
        local avg_duration=$(jq -s --arg step "$step" \
            '[.[] | select(.step == ($step | tonumber)) | .duration] | 
            if length > 0 then (add / length | floor) else 0 end' \
            "$ML_TRAINING_DATA" 2>/dev/null)
        
        # Ensure it's a valid integer
        avg_duration=${avg_duration//[^0-9]/}
        echo "${avg_duration:-0}"
        return 0
    fi
    
    # Calculate weighted average (more recent = higher weight)
    local predicted=$(echo "$similar_runs" | jq -r '
        [to_entries[] | {
            duration: .value.duration,
            weight: (1.0 / (($now - .value.timestamp) / 86400 + 1))
        }] | 
        if length > 0 then
            ((map(.duration * .weight) | add) / (map(.weight) | add) | floor)
        else
            0
        end
    ' --argjson now "$(date +%s)")
    
    # Ensure it's a valid integer
    predicted=${predicted//[^0-9]/}
    echo "${predicted:-0}"
}

# Predict total workflow duration
# Args: $1 = features_json, $2 = steps_array
# Returns: predicted total duration
predict_workflow_duration() {
    local features="$1"
    shift
    local steps=("$@")
    
    [[ "${ML_ENABLED:-false}" != "true" ]] && echo "0" && return 1
    
    local total_predicted=0
    
    for step in "${steps[@]}"; do
        local step_prediction=$(predict_step_duration "$step" "$features")
        total_predicted=$((total_predicted + step_prediction))
    done
    
    # Add parallelization factor if applicable
    if [[ "${PARALLEL_EXECUTION:-false}" == "true" ]]; then
        # Estimate 33% reduction for parallel execution
        total_predicted=$((total_predicted * 67 / 100))
    fi
    
    echo "$total_predicted"
}

# ==============================================================================
# PARALLELIZATION AUTO-ADJUSTMENT
# ==============================================================================

# Recommend optimal parallelization strategy
# Args: $1 = features_json
# Returns: parallelization recommendation JSON
recommend_parallelization() {
    local features="$1"
    
    [[ "${ML_ENABLED:-false}" != "true" ]] && echo "{}" && return 1
    
    local change_type=$(echo "$features" | jq -r '.change_type')
    local total_files=$(echo "$features" | jq -r '.total_files')
    local code_files=$(echo "$features" | jq -r '.code_files')
    local test_files=$(echo "$features" | jq -r '.test_files')
    
    # Check if training data exists
    if [[ ! -f "$ML_TRAINING_DATA" ]]; then
        # Return safe defaults when no training data
        jq -n '{
            recommend_parallel: false,
            strategy: "sequential",
            confidence: "low",
            expected_benefit_pct: "0"
        }'
        return 0
    fi
    
    # Analyze historical performance with/without parallelization
    local parallel_avg=$(jq -s --arg change_type "$change_type" \
        '[.[] | select(.features.change_type == $change_type and .parallel == true) | .total_duration] | 
        if length > 0 then (add / length) else 0 end' \
        "$ML_TRAINING_DATA" 2>/dev/null)
    parallel_avg=${parallel_avg//[^0-9.]/}
    parallel_avg=${parallel_avg:-0}
    
    local serial_avg=$(jq -s --arg change_type "$change_type" \
        '[.[] | select(.features.change_type == $change_type and .parallel == false) | .total_duration] | 
        if length > 0 then (add / length) else 0 end' \
        "$ML_TRAINING_DATA" 2>/dev/null)
    serial_avg=${serial_avg//[^0-9.]/}
    serial_avg=${serial_avg:-0}
    
    local parallel_benefit=0
    if [[ "$serial_avg" != "0" ]] && [[ "$parallel_avg" != "0" ]]; then
        parallel_benefit=$(echo "scale=2; ($serial_avg - $parallel_avg) * 100 / $serial_avg" | bc)
    fi
    
    # Decision logic
    local recommend_parallel=false
    local strategy="sequential"
    local confidence="low"
    
    if (( $(echo "$parallel_benefit > 20" | bc -l) )); then
        recommend_parallel=true
        strategy="parallel"
        confidence="high"
    elif (( $(echo "$parallel_benefit > 10" | bc -l) )); then
        recommend_parallel=true
        strategy="parallel"
        confidence="medium"
    fi
    
    # Adjust based on file types
    if [[ "$change_type" == "docs_only" ]]; then
        recommend_parallel=true
        strategy="3-way-parallel"
        confidence="high"
    elif [[ $test_files -gt 5 ]]; then
        recommend_parallel=true
        strategy="test-sharding"
        confidence="high"
    elif [[ $code_files -gt 10 ]]; then
        recommend_parallel=true
        strategy="4-track-parallel"
        confidence="medium"
    fi
    
    # Build recommendation
    # Log jq arguments for debugging
    if [[ "${DEBUG:-false}" == "true" ]] || [[ "${WORKFLOW_LOG_FILE:-}" != "" ]]; then
        {
            echo "[DEBUG] recommend_parallelization jq arguments:"
            echo "  recommend=${recommend_parallel}, strategy=${strategy}"
            echo "  confidence=${confidence}, benefit=${parallel_benefit}"
        } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
    fi
    
    jq -n \
        --argjson recommend "$recommend_parallel" \
        --arg strategy "$strategy" \
        --arg confidence "$confidence" \
        --arg benefit "$parallel_benefit" \
        '{
            recommend_parallel: $recommend,
            strategy: $strategy,
            confidence: $confidence,
            expected_benefit_pct: $benefit
        }'
}

# ==============================================================================
# SKIP CONDITION RECOMMENDATIONS
# ==============================================================================

# Recommend which steps to skip based on ML classification
# Args: $1 = features_json
# Returns: array of steps to skip
recommend_skip_steps() {
    local features="$1"
    
    [[ "${ML_ENABLED:-false}" != "true" ]] && echo "[]" && return 1
    
    local change_type=$(echo "$features" | jq -r '.change_type')
    local doc_files=$(echo "$features" | jq -r '.doc_files')
    local code_files=$(echo "$features" | jq -r '.code_files')
    local test_files=$(echo "$features" | jq -r '.test_files')
    
    local skip_steps=()
    
    # Learn from historical patterns - which steps had no impact?
    # For each step, check if it ever found issues for similar change patterns
    for step in {0..14}; do
        local issues_found=$(jq -s --arg step "$step" \
            --arg change_type "$change_type" \
            '[.[] | select(
                .step == ($step | tonumber) and 
                .features.change_type == $change_type and 
                .issues_found > 0
            )] | length' "$ML_TRAINING_DATA" 2>/dev/null || echo "0")
        
        local total_runs=$(jq -s --arg step "$step" \
            --arg change_type "$change_type" \
            '[.[] | select(
                .step == ($step | tonumber) and 
                .features.change_type == $change_type
            )] | length' "$ML_TRAINING_DATA" 2>/dev/null || echo "0")
        
        # If step never found issues in similar contexts, recommend skip
        if [[ $total_runs -gt 5 ]] && [[ $issues_found -eq 0 ]]; then
            skip_steps+=($step)
        fi
    done
    
    # Rule-based augmentation
    case "$change_type" in
        "docs_only")
            # Skip code quality, tests, security for docs-only
            skip_steps+=(5 6 7 8 9)
            ;;
        "test_only")
            # Skip docs steps for test-only changes
            skip_steps+=(1 2)
            ;;
        "config_change")
            # Configuration changes need full validation
            skip_steps=()
            ;;
    esac
    
    # Remove duplicates and sort
    local unique_steps=($(printf '%s\n' "${skip_steps[@]}" | sort -nu))
    
    # Convert to JSON array - handle empty case
    if [[ ${#unique_steps[@]} -eq 0 ]]; then
        echo "[]"
    else
        printf '%s\n' "${unique_steps[@]}" | jq -R 'tonumber' | jq -s .
    fi
}

# ==============================================================================
# ANOMALY DETECTION
# ==============================================================================

# Detect if current execution is anomalous
# Args: $1 = step_number, $2 = actual_duration, $3 = predicted_duration
# Returns: 0 if normal, 1 if anomaly
detect_anomaly() {
    local step="$1"
    local actual="$2"
    local predicted="$3"
    
    [[ "${ML_ENABLED:-false}" != "true" ]] && return 0
    [[ $predicted -eq 0 ]] && return 0
    
    # Calculate deviation percentage
    local deviation=$(echo "scale=2; abs($actual - $predicted) * 100 / $predicted" | bc)
    
    # Anomaly if deviation > 100% (2x expected)
    if (( $(echo "$deviation > 100" | bc -l) )); then
        print_warning "🚨 ANOMALY DETECTED: Step $step took ${actual}s (expected ${predicted}s)"
        print_warning "   Deviation: ${deviation}%"
        
        # Log anomaly for investigation
        log_anomaly "$step" "$actual" "$predicted" "$deviation"
        
        return 1
    fi
    
    return 0
}

# Log anomaly for investigation
# Args: $1 = step, $2 = actual, $3 = predicted, $4 = deviation_pct
log_anomaly() {
    local step="$1"
    local actual="$2"
    local predicted="$3"
    local deviation="$4"
    
    # Validate numeric inputs
    [[ ! "$step" =~ ^[0-9]+$ ]] && step=0
    [[ ! "$actual" =~ ^[0-9]+$ ]] && actual=0
    [[ ! "$predicted" =~ ^[0-9]+$ ]] && predicted=0
    
    local anomaly_log="${ML_DATA_DIR}/anomalies.jsonl"
    
    # Log jq arguments for debugging
    if [[ "${DEBUG:-false}" == "true" ]] || [[ "${WORKFLOW_LOG_FILE:-}" != "" ]]; then
        {
            echo "[DEBUG] log_anomaly jq arguments:"
            echo "  step=${step}, actual=${actual}, predicted=${predicted}"
            echo "  deviation=${deviation}, timestamp=$(date +%s)"
        } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
    fi
    
    jq -n \
        --argjson step "$step" \
        --argjson actual "$actual" \
        --argjson predicted "$predicted" \
        --arg deviation "$deviation" \
        --argjson timestamp "$(date +%s)" \
        '{
            timestamp: $timestamp,
            step: $step,
            actual_duration: $actual,
            predicted_duration: $predicted,
            deviation_pct: $deviation,
            date: (now | strftime("%Y-%m-%d %H:%M:%S"))
        }' >> "$anomaly_log"
}

# ==============================================================================
# TRAINING DATA COLLECTION
# ==============================================================================

# Record workflow execution for training
# Args: $1 = execution_data_json
record_execution() {
    local execution_data="$1"
    
    # Append to training data
    echo "$execution_data" >> "$ML_TRAINING_DATA"
    
    # Check if retraining is needed
    check_retraining_needed
}

# Record step execution for training
# Args: $1 = step_number, $2 = duration, $3 = features_json, $4 = issues_found
record_step_execution() {
    local step="$1"
    local duration="$2"
    local features="$3"
    local issues_found="${4:-0}"
    
    # Guard: Skip if ML_TRAINING_DATA not initialized (test environment)
    if [[ -z "${ML_TRAINING_DATA:-}" ]]; then
        return 0
    fi
    
    # Validate numeric inputs to prevent jq errors
    step=${step:-0}
    duration=${duration:-0}
    issues_found=${issues_found:-0}
    [[ ! "$step" =~ ^[0-9]+$ ]] && step=0
    [[ ! "$duration" =~ ^[0-9]+$ ]] && duration=0
    [[ ! "$issues_found" =~ ^[0-9]+$ ]] && issues_found=0
    [[ -z "$features" || "$features" == '""' || "$features" == "null" ]] && features="{}"
    
    # Compact features JSON to single line for jq --argjson (multiline breaks parsing)
    local features_compact
    features_compact=$(echo "$features" | jq -c '.' 2>/dev/null || echo "{}")
    
    local record=$(jq -nc \
        --argjson step "$step" \
        --argjson duration "$duration" \
        --argjson features "$features_compact" \
        --argjson issues "$issues_found" \
        --argjson timestamp "$(date +%s)" \
        --argjson parallel "${PARALLEL_EXECUTION:-false}" \
        '{
            step: $step,
            duration: $duration,
            features: $features,
            issues_found: $issues,
            timestamp: $timestamp,
            parallel: $parallel,
            date: (now | strftime("%Y-%m-%d %H:%M:%S"))
        }')
    
    echo "$record" >> "$ML_TRAINING_DATA"
}

# ==============================================================================
# MODEL RETRAINING
# ==============================================================================

# Check if retraining is needed
check_retraining_needed() {
    local last_training_file="${ML_MODEL_DIR}/last_training.txt"
    
    if [[ ! -f "$last_training_file" ]]; then
        # Never trained before
        retrain_models
        return 0
    fi
    
    local last_training=$(cat "$last_training_file")
    local current_time=$(date +%s)
    local time_since_training=$((current_time - last_training))
    
    if [[ $time_since_training -gt $RETRAINING_INTERVAL ]]; then
        print_info "ML: Retraining models (last trained $(($time_since_training / 3600))h ago)"
        retrain_models
    fi
}

# Retrain ML models
retrain_models() {
    print_info "ML: Retraining models with latest data..."
    
    # For now, this is a placeholder for actual ML model training
    # In production, you would:
    # 1. Load training data
    # 2. Train predictive models (e.g., using Python/scikit-learn)
    # 3. Save models to ML_MODEL_DIR
    # 4. Validate model performance
    
    # For this shell implementation, we use statistical methods
    # and historical averages (which we're already doing)
    
    # Mark training timestamp
    date +%s > "${ML_MODEL_DIR}/last_training.txt"
    
    # Calculate and cache statistics for faster lookups
    calculate_model_statistics
    
    print_success "ML: Models retrained successfully"
}

# Calculate and cache model statistics
calculate_model_statistics() {
    local stats_file="${ML_MODEL_DIR}/statistics.json"
    
    # Calculate statistics per change_type and step
    jq -s 'group_by(.features.change_type) | 
        map({
            change_type: .[0].features.change_type,
            steps: (group_by(.step) | 
                map({
                    step: .[0].step,
                    avg_duration: (map(.duration) | add / length),
                    min_duration: (map(.duration) | min),
                    max_duration: (map(.duration) | max),
                    std_dev: (map(.duration) | 
                        (add / length) as $mean | 
                        map(pow(. - $mean; 2)) | add / length | sqrt),
                    sample_count: length
                })
            )
        })' "$ML_TRAINING_DATA" > "$stats_file" 2>/dev/null || echo "[]" > "$stats_file"
}

# ==============================================================================
# ML-DRIVEN OPTIMIZATION APPLICATION
# ==============================================================================

# Apply ML recommendations to workflow
# Returns: JSON with recommendations
apply_ml_optimization() {
    if ! init_ml_system; then
        print_info "ML system not ready - using rule-based optimization"
        echo '{"ml_enabled": false}'
        return 1
    fi
    
    print_header "ML-Driven Optimization"
    
    # Extract features from current changes
    local features=$(extract_change_features)
    
    # Validate features is valid JSON
    if ! echo "$features" | jq -e . >/dev/null 2>&1; then
        print_error "Failed to extract valid features JSON"
        echo '{"ml_enabled": false, "error": "invalid_features"}'
        return 1
    fi
    
    echo "Features detected:" >&2
    echo "$features" | jq . >&2
    echo "" >&2
    
    # Get parallelization recommendation
    local parallel_rec=$(recommend_parallelization "$features")
    
    echo "Parallelization recommendation:" >&2
    echo "$parallel_rec" | jq . >&2
    echo "" >&2
    
    # Get skip recommendations
    local skip_rec=$(recommend_skip_steps "$features")
    
    echo "Skip recommendations:" >&2
    echo "$skip_rec" | jq . >&2
    echo "" >&2
    
    # Predict workflow duration
    local predicted_duration=$(predict_workflow_duration "$features" 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14)
    # Ensure it's a valid integer
    predicted_duration=${predicted_duration//[^0-9]/}
    predicted_duration=${predicted_duration:-0}
    local predicted_min=$((predicted_duration / 60))
    
    echo "Predicted workflow duration: ${predicted_min}m (${predicted_duration}s)" >&2
    echo "" >&2
    
    # Build complete recommendation
    local recommendations=$(jq -n \
        --argjson features "$features" \
        --argjson parallel "$parallel_rec" \
        --argjson skip "$skip_rec" \
        --argjson duration "$predicted_duration" \
        '{
            ml_enabled: true,
            features: $features,
            parallelization: $parallel,
            skip_steps: $skip,
            predicted_duration: $duration,
            confidence: "high"
        }')
    
    # Save predictions for validation
    echo "$recommendations" > "$ML_PREDICTIONS"
    
    echo "$recommendations"
}

# Validate ML predictions after execution
# Args: $1 = actual_duration
validate_ml_predictions() {
    local actual_duration="$1"
    
    [[ ! -f "$ML_PREDICTIONS" ]] && return 0
    
    local predicted_duration=$(jq -r '.predicted_duration' "$ML_PREDICTIONS")
    
    [[ "$predicted_duration" == "null" ]] || [[ -z "$predicted_duration" ]] && return 0
    
    local error=$(echo "scale=2; abs($actual_duration - $predicted_duration) * 100 / $predicted_duration" | bc)
    
    print_header "ML Prediction Validation"
    echo "Predicted duration: ${predicted_duration}s"
    echo "Actual duration:    ${actual_duration}s"
    echo "Prediction error:   ${error}%"
    
    if (( $(echo "$error < 20" | bc -l) )); then
        print_success "✅ Excellent prediction accuracy!"
    elif (( $(echo "$error < 50" | bc -l) )); then
        print_info "⚠️  Moderate prediction accuracy"
    else
        print_warning "❌ Poor prediction accuracy - model needs more training data"
    fi
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Display ML system status
display_ml_status() {
    print_header "ML System Status"
    
    local sample_count=$(wc -l < "$ML_TRAINING_DATA" 2>/dev/null || echo "0")
    local anomaly_count=$(wc -l < "${ML_DATA_DIR}/anomalies.jsonl" 2>/dev/null || echo "0")
    local last_training=$(cat "${ML_MODEL_DIR}/last_training.txt" 2>/dev/null || echo "0")
    
    echo "Training samples:   $sample_count"
    echo "Anomalies detected: $anomaly_count"
    
    if [[ $last_training -gt 0 ]]; then
        local current_time=$(date +%s)
        local hours_since=$((( current_time - last_training) / 3600))
        echo "Last training:      ${hours_since}h ago"
    else
        echo "Last training:      Never"
    fi
    
    if [[ $sample_count -ge $MIN_TRAINING_SAMPLES ]]; then
        print_success "Status: ACTIVE"
    else
        print_warning "Status: COLLECTING DATA (need $((MIN_TRAINING_SAMPLES - sample_count)) more samples)"
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f init_ml_system
export -f extract_change_features
export -f predict_step_duration
export -f predict_workflow_duration
export -f recommend_parallelization
export -f recommend_skip_steps
export -f detect_anomaly
export -f record_execution
export -f record_step_execution
export -f retrain_models
export -f apply_ml_optimization
export -f validate_ml_predictions
export -f display_ml_status

################################################################################
# End of Machine Learning Optimization Module
################################################################################
