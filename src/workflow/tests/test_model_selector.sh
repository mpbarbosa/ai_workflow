#!/bin/bash
set -uo pipefail  # Removed -e to prevent early exit on test failures

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${SCRIPT_DIR}/.."
TEST_FAILURES=0
TEST_PASSES=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

source "${WORKFLOW_DIR}/lib/model_selector.sh"

main() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          MODEL SELECTOR MODULE - UNIT TEST SUITE               ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "TEST SUITE 1: Model Validation"
    
    if validate_model_name "claude-haiku-4.5"; then
        echo -e "${GREEN}✓${NC} Valid model: claude-haiku-4.5"
        ((TEST_PASSES++))
    else
        echo -e "${RED}✗${NC} Valid model: claude-haiku-4.5"
        ((TEST_FAILURES++))
    fi
    
    if validate_model_name "invalid-model"; then
        echo -e "${RED}✗${NC} Invalid model should fail"
        ((TEST_FAILURES++))
    else
        echo -e "${GREEN}✓${NC} Invalid model correctly rejected"
        ((TEST_PASSES++))
    fi
    
    local suggestions=$(suggest_similar_models "claude")
    if [[ -n "$suggestions" ]]; then
        echo -e "${GREEN}✓${NC} Model suggestions working"
        ((TEST_PASSES++))
    else
        echo -e "${RED}✗${NC} Model suggestions failed"
        ((TEST_FAILURES++))
    fi
    
    echo ""
    echo "TEST SUITE 2: Model Tier Mapping"
    
    local model=$(get_model_for_tier "low")
    [[ "$model" == "claude-haiku-4.5" ]] && echo -e "${GREEN}✓${NC} Tier 1: $model" && ((TEST_PASSES++)) || { echo -e "${RED}✗${NC} Tier 1 wrong"; ((TEST_FAILURES++)); }
    
    model=$(get_model_for_tier "medium")
    [[ "$model" == "claude-sonnet-4.5" ]] && echo -e "${GREEN}✓${NC} Tier 2: $model" && ((TEST_PASSES++)) || { echo -e "${RED}✗${NC} Tier 2 wrong"; ((TEST_FAILURES++)); }
    
    model=$(get_model_for_tier "high")
    [[ "$model" == "claude-opus-4.5" ]] && echo -e "${GREEN}✓${NC} Tier 3: $model" && ((TEST_PASSES++)) || { echo -e "${RED}✗${NC} Tier 3 wrong"; ((TEST_FAILURES++)); }
    
    echo ""
    echo "TEST SUITE 3: JSON Generation"
    
    export PROJECT_ROOT="${WORKFLOW_DIR}"
    export WORKFLOW_RUN_ID="test_$(date +%s)"
    
    local definitions=$(generate_model_definitions "test.js" "README.md" "test.spec.js")
    if echo "$definitions" | jq empty 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Model definitions JSON valid"
        ((TEST_PASSES++))
    else
        echo -e "${RED}✗${NC} Model definitions JSON invalid"
        ((TEST_FAILURES++))
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "SUMMARY: $TEST_PASSES passed, $TEST_FAILURES failed"
    echo "═══════════════════════════════════════════════════════════════"
    
    [[ $TEST_FAILURES -eq 0 ]] && echo -e "${GREEN}✓ ALL TESTS PASSED${NC}" && return 0
    echo -e "${RED}✗ SOME TESTS FAILED${NC}" && return 1
}

main "$@"
