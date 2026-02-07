#!/bin/bash
set -euo pipefail

################################################################################
# Skip Predictor Test Suite
# Tests the ML-powered skip prediction functionality
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define print functions first
print_success() { echo "✅ $*"; }
print_error() { echo "❌ $*"; }
print_info() { echo "ℹ️  $*"; }
print_warning() { echo "⚠️  $*"; }

source "${SCRIPT_DIR}/skip_predictor.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        print_success "PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        print_success "PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "FAIL: $test_name"
        echo "  Condition was false"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ "$condition" == "false" ]] || [[ "$condition" == "1" ]]; then
        print_success "PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "FAIL: $test_name"
        echo "  Condition was true"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    export ML_DATA_DIR="/tmp/skip_predictor_test_$$"
    export ML_SKIP_HISTORY="${ML_DATA_DIR}/skip_history.jsonl"
    export ML_TRAINING_DATA="${ML_DATA_DIR}/training_data.jsonl"
    
    mkdir -p "$ML_DATA_DIR"
    
    # Create sample training data
    cat > "$ML_TRAINING_DATA" <<'EOF'
{"step":1,"duration":45,"features":{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"test_files":0,"lines_changed":150}}
{"step":2,"duration":60,"features":{"change_type":"docs_only","total_files":3,"doc_files":3,"code_files":0,"test_files":0,"lines_changed":80}}
{"step":5,"duration":180,"features":{"change_type":"code_only","total_files":10,"doc_files":0,"code_files":8,"test_files":2,"lines_changed":500}}
{"step":5,"duration":190,"features":{"change_type":"code_only","total_files":12,"doc_files":0,"code_files":10,"test_files":2,"lines_changed":550}}
{"step":7,"duration":240,"features":{"change_type":"code_only","total_files":8,"doc_files":0,"code_files":6,"test_files":2,"lines_changed":400}}
{"step":7,"duration":250,"features":{"change_type":"mixed","total_files":15,"doc_files":3,"code_files":10,"test_files":2,"lines_changed":600}}
{"step":9,"duration":90,"features":{"change_type":"code_only","total_files":5,"doc_files":0,"code_files":5,"test_files":0,"lines_changed":200}}
{"step":1,"duration":50,"features":{"change_type":"docs_only","total_files":4,"doc_files":4,"code_files":0,"test_files":0,"lines_changed":120}}
{"step":2,"duration":65,"features":{"change_type":"docs_only","total_files":2,"doc_files":2,"code_files":0,"test_files":0,"lines_changed":60}}
{"step":1,"duration":55,"features":{"change_type":"docs_only","total_files":6,"doc_files":6,"code_files":0,"test_files":0,"lines_changed":180}}
{"step":5,"duration":170,"features":{"change_type":"code_only","total_files":9,"doc_files":0,"code_files":7,"test_files":2,"lines_changed":480}}
EOF
    
    # Create sample skip history
    cat > "$ML_SKIP_HISTORY" <<'EOF'
{"run_id":"test_001","step":5,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0},"confidence":0.90,"outcome":"success","subsequent_failure":false}
{"run_id":"test_002","step":5,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":4,"doc_files":4,"code_files":0},"confidence":0.88,"outcome":"success","subsequent_failure":false}
{"run_id":"test_003","step":5,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":6,"doc_files":6,"code_files":0},"confidence":0.92,"outcome":"success","subsequent_failure":false}
{"run_id":"test_004","step":6,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":3,"doc_files":3,"code_files":0},"confidence":0.85,"outcome":"success","subsequent_failure":false}
{"run_id":"test_005","step":6,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":4,"doc_files":4,"code_files":0},"confidence":0.87,"outcome":"success","subsequent_failure":false}
{"run_id":"test_006","step":7,"skipped":false,"reason":"code_changes","features":{"change_type":"code_only","total_files":10,"code_files":8},"confidence":0.0,"outcome":"success","subsequent_failure":false}
{"run_id":"test_007","step":7,"skipped":false,"reason":"code_changes","features":{"change_type":"code_only","total_files":12,"code_files":10},"confidence":0.0,"outcome":"success","subsequent_failure":false}
{"run_id":"test_008","step":5,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0},"confidence":0.91,"outcome":"success","subsequent_failure":false}
{"run_id":"test_009","step":5,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":3,"doc_files":3,"code_files":0},"confidence":0.89,"outcome":"success","subsequent_failure":false}
{"run_id":"test_010","step":6,"skipped":true,"reason":"ml_prediction","features":{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0},"confidence":0.86,"outcome":"success","subsequent_failure":false}
EOF
    
    export SKIP_PREDICTION_ENABLED=true
}

cleanup_test_env() {
    rm -rf "$ML_DATA_DIR"
}

# ==============================================================================
# TEST CASES
# ==============================================================================

test_init_skip_predictor() {
    print_info "Testing: init_skip_predictor"
    
    init_skip_predictor
    local result=$?
    
    assert_equals "0" "$result" "Initialization succeeds with sufficient data"
    assert_true "$([ -f "$ML_SKIP_HISTORY" ] && echo true || echo false)" "Skip history file exists"
}

test_feature_similarity() {
    print_info "Testing: calculate_feature_similarity"
    
    local features1='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"lines_changed":150}'
    local features2='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"lines_changed":150}'
    
    local similarity=$(calculate_feature_similarity "$features1" "$features2")
    
    # Exact match should have high similarity (>0.9)
    if awk -v sim="$similarity" 'BEGIN {exit !(sim > 0.9)}'; then
        assert_true "true" "Exact features have high similarity (got $similarity)"
    else
        assert_true "false" "Exact features have high similarity (got $similarity)"
    fi
}

test_feature_similarity_different() {
    print_info "Testing: Feature similarity with different features"
    
    local features1='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"lines_changed":150}'
    local features2='{"change_type":"code_only","total_files":20,"doc_files":0,"code_files":15,"lines_changed":800}'
    
    local similarity=$(calculate_feature_similarity "$features1" "$features2")
    
    # Very different features should have low similarity (<0.5)
    if awk -v sim="$similarity" 'BEGIN {exit !(sim < 0.5)}'; then
        assert_true "true" "Different features have low similarity (got $similarity)"
    else
        assert_true "false" "Different features have low similarity (got $similarity)"
    fi
}

test_query_skip_history() {
    print_info "Testing: query_skip_history"
    
    local features='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"lines_changed":150}'
    local result=$(query_skip_history "5" "$features")
    
    local sample_count=$(echo "$result" | jq -r '.sample_count')
    local skip_rate=$(echo "$result" | jq -r '.skip_rate')
    
    # Should find similar records for step 5 with docs-only changes
    if [[ $sample_count -gt 0 ]]; then
        assert_true "true" "Found historical samples (count: $sample_count)"
    else
        assert_true "false" "Found historical samples (count: $sample_count)"
    fi
    
    # Skip rate should be > 0 since we have skip records
    if awk -v sr="$skip_rate" 'BEGIN {exit !(sr > 0)}'; then
        assert_true "true" "Skip rate calculated (rate: $skip_rate)"
    else
        assert_true "false" "Skip rate calculated (rate: $skip_rate)"
    fi
}

test_confidence_scoring() {
    print_info "Testing: calculate_skip_confidence"
    
    local features='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0}'
    local skip_history='{"sample_count":10,"skip_rate":0.8,"confidence":0.80,"success_count":8}'
    
    local confidence=$(calculate_skip_confidence "5" "$features" "$skip_history")
    
    # With 10 samples and 80% skip rate, confidence should be moderate-high (>0.5)
    if awk -v conf="$confidence" 'BEGIN {exit !(conf > 0.5)}'; then
        assert_true "true" "Confidence calculated correctly (got $confidence)"
    else
        assert_true "false" "Confidence calculated correctly (got $confidence)"
    fi
}

test_safety_critical_steps() {
    print_info "Testing: Safety - Critical steps never skipped"
    
    local features='{"change_type":"docs_only","total_files":1,"doc_files":1,"code_files":0}'
    
    # Step 0 is critical - should never skip
    is_safe_to_skip "0" "0.95" "$features"
    local result=$?
    
    assert_equals "1" "$result" "Step 0 (critical) not safe to skip even with high confidence"
    
    # Step 15 is critical - should never skip
    is_safe_to_skip "15" "0.95" "$features"
    result=$?
    
    assert_equals "1" "$result" "Step 15 (critical) not safe to skip even with high confidence"
}

test_safety_low_confidence() {
    print_info "Testing: Safety - Low confidence prevents skip"
    
    local features='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0}'
    
    # Non-critical step but low confidence
    is_safe_to_skip "5" "0.60" "$features"
    local result=$?
    
    assert_equals "1" "$result" "Low confidence (0.60) prevents skip"
}

test_safety_high_confidence() {
    print_info "Testing: Safety - High confidence allows skip"
    
    local features='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0}'
    
    # Non-critical step with high confidence
    is_safe_to_skip "2" "0.90" "$features"
    local result=$?
    
    assert_equals "0" "$result" "High confidence (0.90) allows skip"
}

test_predict_step_necessity() {
    print_info "Testing: predict_step_necessity"
    
    local features='{"change_type":"docs_only","total_files":5,"doc_files":5,"code_files":0,"test_files":0,"lines_changed":150}'
    local prediction=$(predict_step_necessity "5" "$features")
    
    # Verify JSON structure
    local step=$(echo "$prediction" | jq -r '.step')
    local has_confidence=$(echo "$prediction" | jq -r '.confidence')
    local has_samples=$(echo "$prediction" | jq -r '.historical_samples')
    
    assert_equals "5" "$step" "Prediction for correct step"
    
    if [[ "$has_confidence" != "null" ]] && [[ "$has_confidence" != "" ]]; then
        assert_true "true" "Prediction includes confidence score"
    else
        assert_true "false" "Prediction includes confidence score"
    fi
    
    if [[ "$has_samples" != "null" ]] && [[ "$has_samples" != "" ]]; then
        assert_true "true" "Prediction includes historical sample count"
    else
        assert_true "false" "Prediction includes historical sample count"
    fi
}

test_record_skip_decision() {
    print_info "Testing: record_skip_decision"
    
    local features='{"change_type":"docs_only","total_files":3,"doc_files":3,"code_files":0}'
    
    record_skip_decision "test_run_001" "5" "true" "$features" "0.88" "ml_prediction"
    
    # Check if record was added
    local last_record=$(tail -n 1 "$ML_SKIP_HISTORY")
    local run_id=$(echo "$last_record" | jq -r '.run_id')
    local step=$(echo "$last_record" | jq -r '.step')
    
    assert_equals "test_run_001" "$run_id" "Skip decision recorded with correct run_id"
    assert_equals "5" "$step" "Skip decision recorded with correct step"
}

test_insufficient_data() {
    print_info "Testing: Insufficient data handling"
    
    # Clear training data
    echo "" > "$ML_TRAINING_DATA"
    
    init_skip_predictor
    local result=$?
    
    assert_equals "1" "$result" "Init fails with insufficient data"
    assert_equals "false" "${SKIP_PREDICTION_ENABLED:-false}" "Skip prediction disabled with insufficient data"
}

# ==============================================================================
# RUN TESTS
# ==============================================================================

echo "========================================"
echo "Skip Predictor Test Suite"
echo "========================================"
echo ""

setup_test_env

# Run all tests
test_init_skip_predictor
test_feature_similarity
test_feature_similarity_different
test_query_skip_history
test_confidence_scoring
test_safety_critical_steps
test_safety_low_confidence
test_safety_high_confidence
test_predict_step_necessity
test_record_skip_decision
test_insufficient_data

cleanup_test_env

# Print summary
echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    print_success "All tests passed! ✨"
    exit 0
else
    print_error "Some tests failed"
    exit 1
fi
