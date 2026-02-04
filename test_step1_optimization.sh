#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 Optimization Test Script
# Purpose: Test incremental + parallel optimizations with timing
################################################################################

echo "================================================"
echo "Step 1 Optimization Test"
echo "Testing: Incremental Processing + Parallelization"
echo "================================================"
echo ""

# Navigate to project root
cd "$(dirname "$0")" || exit 1
PROJECT_ROOT=$(pwd)
export PROJECT_ROOT

# Set up environment
export WORKFLOW_HOME="${PROJECT_ROOT}/src/workflow"
export AI_CACHE_DIR="${WORKFLOW_HOME}/.ai_cache"
export USE_AI_CACHE=true
export ENABLE_DOC_INCREMENTAL=true
export ENABLE_DOC_PARALLEL=true
export DOC_PARALLEL_THRESHOLD=4
export DOC_MAX_PARALLEL_JOBS=4

# Set up required workflow variables
export BACKLOG_DIR="${WORKFLOW_HOME}/backlog"
export LOGS_DIR="${WORKFLOW_HOME}/logs"
export WORKFLOW_RUN_ID="test_$(date +%Y%m%d_%H%M%S)"
export BACKLOG_STEP_DIR="${BACKLOG_DIR}/workflow_${WORKFLOW_RUN_ID}"
export LOGS_RUN_DIR="${LOGS_DIR}/workflow_${WORKFLOW_RUN_ID}"

mkdir -p "$BACKLOG_STEP_DIR" "$LOGS_RUN_DIR"

# Source library modules
LIB_DIR="${WORKFLOW_HOME}/lib"
for lib_file in "${LIB_DIR}"/*.sh; do
    if [[ -f "$lib_file" ]] && [[ ! "$(basename "$lib_file")" =~ ^test_ ]]; then
        source "$lib_file" 2>/dev/null || true
    fi
done

# Source Step 1 module
source "${WORKFLOW_HOME}/steps/step_01_documentation.sh"

echo "Environment Setup:"
echo "  - Project Root: $PROJECT_ROOT"
echo "  - AI Cache: $AI_CACHE_DIR"
echo "  - Incremental: $ENABLE_DOC_INCREMENTAL"
echo "  - Parallel: $ENABLE_DOC_PARALLEL (threshold: $DOC_PARALLEL_THRESHOLD)"
echo ""

# Check cache state
if [[ -f "$AI_CACHE_DIR/doc_hashes.json" ]]; then
    echo "Incremental Cache Status:"
    if command -v jq &>/dev/null; then
        cached_count=$(jq '.files | length' "$AI_CACHE_DIR/doc_hashes.json" 2>/dev/null || echo "0")
        last_updated=$(jq -r '.last_updated' "$AI_CACHE_DIR/doc_hashes.json" 2>/dev/null || echo "unknown")
        echo "  - Cached files: $cached_count"
        echo "  - Last updated: $last_updated"
    else
        echo "  - Cache exists (jq not available for details)"
    fi
else
    echo "Incremental Cache Status: Not initialized (first run)"
fi
echo ""

# Check git changes
echo "Git Status:"
changed_count=$(git status --short 2>/dev/null | wc -l)
echo "  - Modified/Untracked files: $changed_count"

doc_changes=$(git status --short 2>/dev/null | grep '\.md$' | wc -l || echo 0)
echo "  - Documentation files changed: $doc_changes"
echo ""

# Test Run 1: With current changes
echo "================================================"
echo "TEST RUN 1: Processing Current Changes"
echo "================================================"
echo ""

start_time=$(date +%s)
start_ns=$(date +%s%N)

if step1_update_documentation; then
    echo ""
    echo "✅ Step 1 completed successfully"
else
    echo ""
    echo "❌ Step 1 failed"
fi

end_time=$(date +%s)
end_ns=$(date +%s%N)
duration=$((end_time - start_time))
duration_ms=$(( (end_ns - start_ns) / 1000000 ))

echo ""
echo "================================================"
echo "TEST RUN 1 RESULTS"
echo "================================================"
echo "Duration: ${duration}s (${duration_ms}ms)"
echo "Cache file: $AI_CACHE_DIR/doc_hashes.json"

if [[ -f "$AI_CACHE_DIR/doc_hashes.json" ]] && command -v jq &>/dev/null; then
    cached_count=$(jq '.files | length' "$AI_CACHE_DIR/doc_hashes.json" 2>/dev/null || echo "0")
    echo "Cached documentation files: $cached_count"
fi

echo ""
echo "Output files:"
ls -lh "$BACKLOG_STEP_DIR"/*.md 2>/dev/null || echo "  No output files generated"

# Test Run 2: Immediate re-run (should use cache)
echo ""
echo "================================================"
echo "TEST RUN 2: Immediate Re-run (Cache Test)"
echo "================================================"
echo "This should skip AI analysis if docs haven't changed"
echo ""

export BACKLOG_STEP_DIR="${BACKLOG_DIR}/workflow_${WORKFLOW_RUN_ID}_run2"
export LOGS_RUN_DIR="${LOGS_DIR}/workflow_${WORKFLOW_RUN_ID}_run2"
mkdir -p "$BACKLOG_STEP_DIR" "$LOGS_RUN_DIR"

start_time2=$(date +%s)
start_ns2=$(date +%s%N)

if step1_update_documentation; then
    echo ""
    echo "✅ Step 1 (run 2) completed successfully"
else
    echo ""
    echo "❌ Step 1 (run 2) failed"
fi

end_time2=$(date +%s)
end_ns2=$(date +%s%N)
duration2=$((end_time2 - start_time2))
duration_ms2=$(( (end_ns2 - start_ns2) / 1000000 ))

echo ""
echo "================================================"
echo "TEST RUN 2 RESULTS"
echo "================================================"
echo "Duration: ${duration2}s (${duration_ms2}ms)"
echo "Speedup vs Run 1: $((duration - duration2))s saved"

if [[ $duration2 -lt 5 ]]; then
    echo "✅ Cache working! Run 2 was significantly faster (<5s)"
else
    echo "⚠️  Run 2 took longer than expected. Cache may not be working."
fi

echo ""
echo "================================================"
echo "OPTIMIZATION SUMMARY"
echo "================================================"
echo "Run 1 (with changes): ${duration}s"
echo "Run 2 (cache hit):    ${duration2}s"
echo "Improvement:          $((duration - duration2))s ($((100 - (duration2 * 100 / duration)))% faster)"
echo ""
echo "Test complete. Check outputs in:"
echo "  - Backlog: ${BACKLOG_DIR}/workflow_${WORKFLOW_RUN_ID}*/"
echo "  - Logs: ${LOGS_DIR}/workflow_${WORKFLOW_RUN_ID}*/"
echo "  - Cache: $AI_CACHE_DIR/doc_hashes.json"
