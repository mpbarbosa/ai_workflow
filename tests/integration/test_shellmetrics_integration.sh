#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Shellmetrics Integration in Step 9
# Tests that shellmetrics is properly integrated into code quality validation
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_HOME="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source required modules
source "${WORKFLOW_HOME}/src/workflow/lib/colors.sh"

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Shellmetrics Integration Test${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"

# Test 1: Check if shellmetrics is available
echo -e "\n${CYAN}Test 1: Shellmetrics Availability${NC}"
SHELLMETRICS="/home/mpb/bin/shellmetrics"
if [[ -x "$SHELLMETRICS" ]]; then
    echo -e "${GREEN}✓${NC} shellmetrics is installed at $SHELLMETRICS"
    $SHELLMETRICS --version
elif command -v shellmetrics >/dev/null 2>&1; then
    SHELLMETRICS="shellmetrics"
    echo -e "${GREEN}✓${NC} shellmetrics is in PATH"
    shellmetrics --version
else
    echo -e "${RED}✗${NC} shellmetrics not found"
    echo -e "${YELLOW}Install from: https://github.com/ko1nksm/shellmetrics${NC}"
    exit 1
fi

# Test 2: Test shellmetrics on audio_notifications.sh
echo -e "\n${CYAN}Test 2: Analyze Audio Notifications Module${NC}"
AUDIO_MODULE="${WORKFLOW_HOME}/src/workflow/lib/audio_notifications.sh"

if [[ -f "$AUDIO_MODULE" ]]; then
    echo -e "${GREEN}✓${NC} Found audio_notifications.sh"
    
    # Run shellmetrics
    OUTPUT=$($SHELLMETRICS --no-color "$AUDIO_MODULE" 2>&1)
    
    if echo "$OUTPUT" | grep -q "function(s) analyzed"; then
        echo -e "${GREEN}✓${NC} Shellmetrics analysis successful"
        
        # Extract metrics
        FUNCTIONS=$(echo "$OUTPUT" | grep "function(s) analyzed" | grep -o '[0-9]\+ function' | awk '{print $1}')
        AVG_CCN=$(echo "$OUTPUT" | tail -5 | grep '[0-9]' | tail -1 | awk '{print $7}')
        AVG_LLOC=$(echo "$OUTPUT" | tail -5 | grep '[0-9]' | tail -1 | awk '{print $5}')
        
        echo -e "  Functions: ${FUNCTIONS:-unknown}"
        echo -e "  Average CCN: ${AVG_CCN:-unknown}"
        echo -e "  Average LLOC: ${AVG_LLOC:-unknown}"
        
        # Verify reasonable metrics
        if [[ -n "$FUNCTIONS" ]] && [[ ${FUNCTIONS} -gt 0 ]]; then
            echo -e "${GREEN}✓${NC} Function count is positive ($FUNCTIONS functions)"
        else
            echo -e "${RED}✗${NC} No functions detected"
            exit 1
        fi
        
        # Check for high complexity (should pass for our module)
        HIGH_COMPLEXITY=$(echo "$OUTPUT" | awk '/LLOC  CCN  Location/,/^-+$/ {if ($2 > 10 || $1 > 100) print}' | grep -v "^-" | grep -v "LLOC  CCN" || true)
        if [[ -z "$HIGH_COMPLEXITY" ]]; then
            echo -e "${GREEN}✓${NC} No high complexity functions (CCN>10 or LLOC>100)"
        else
            echo -e "${YELLOW}⚠${NC} High complexity functions found:"
            echo "$HIGH_COMPLEXITY"
        fi
    else
        echo -e "${RED}✗${NC} Shellmetrics analysis failed"
        echo "$OUTPUT"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Audio module not found"
    exit 1
fi

# Test 3: Test CSV output format
echo -e "\n${CYAN}Test 3: CSV Output Format${NC}"
CSV_OUTPUT=$($SHELLMETRICS --csv "$AUDIO_MODULE" 2>&1)

if echo "$CSV_OUTPUT" | head -1 | grep -q "file,func,lineno,lloc,ccn"; then
    echo -e "${GREEN}✓${NC} CSV header correct"
    
    # Count CSV lines (excluding header)
    CSV_LINES=$(echo "$CSV_OUTPUT" | tail -n +2 | wc -l)
    echo -e "  CSV rows: ${CSV_LINES}"
    
    if [[ $CSV_LINES -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} CSV data present"
    else
        echo -e "${RED}✗${NC} No CSV data"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} CSV format incorrect"
    exit 1
fi

# Test 4: Check Step 9 integration
echo -e "\n${CYAN}Test 4: Step 9 Code Quality Integration${NC}"
STEP9="${WORKFLOW_HOME}/src/workflow/steps/step_09_code_quality.sh"

if grep -q "shellmetrics" "$STEP9"; then
    echo -e "${GREEN}✓${NC} Shellmetrics referenced in step_09_code_quality.sh"
    
    # Check for key integration points
    if grep -q "command -v shellmetrics" "$STEP9"; then
        echo -e "${GREEN}✓${NC} Shellmetrics availability check present"
    else
        echo -e "${RED}✗${NC} No availability check found"
    fi
    
    if grep -q "Cyclomatic Complexity" "$STEP9"; then
        echo -e "${GREEN}✓${NC} CCN metric handling present"
    else
        echo -e "${YELLOW}⚠${NC} CCN metric handling not found"
    fi
    
    if grep -q "LLOC" "$STEP9"; then
        echo -e "${GREEN}✓${NC} LLOC metric handling present"
    else
        echo -e "${YELLOW}⚠${NC} LLOC metric handling not found"
    fi
else
    echo -e "${RED}✗${NC} Shellmetrics not integrated in step_09_code_quality.sh"
    exit 1
fi

# Test 5: Run shellmetrics on multiple files
echo -e "\n${CYAN}Test 5: Multiple File Analysis${NC}"
TEST_FILES=$(find "${WORKFLOW_HOME}/src/workflow/lib" -name "*.sh" -type f | head -5)
FILE_COUNT=$(echo "$TEST_FILES" | wc -l)

echo -e "  Analyzing ${FILE_COUNT} library modules..."

if echo "$TEST_FILES" | xargs $SHELLMETRICS --no-color > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Batch analysis successful"
else
    echo -e "${RED}✗${NC} Batch analysis failed"
    exit 1
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "\n${GREEN}✓ All tests passed!${NC}"
echo -e "\nShellmetrics integration is working correctly."
echo -e "\nUsage in workflow:"
echo -e "  cd /path/to/bash/project"
echo -e "  ./src/workflow/execute_tests_docs_workflow.sh --steps 9"
echo ""
