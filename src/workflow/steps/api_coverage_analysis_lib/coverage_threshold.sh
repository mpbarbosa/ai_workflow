#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1.5 Coverage Threshold Module
# Version: 1.0.0
# Purpose: Threshold checking and enforcement logic
################################################################################

# Check if coverage meets threshold
# Args: $1 = current coverage %, $2 = threshold %
# Returns: 0 if meets threshold, 1 otherwise
check_coverage_threshold() {
    local coverage="$1"
    local threshold="$2"
    
    if [[ $coverage -ge $threshold ]]; then
        return 0
    else
        return 1
    fi
}

# Calculate required APIs to reach threshold
# Args: $1 = total APIs, $2 = documented APIs, $3 = threshold %
# Returns: Number of additional APIs needed
calculate_required_apis() {
    local total="$1"
    local documented="$2"
    local threshold="$3"
    
    local required=$((total * threshold / 100))
    local needed=$((required - documented))
    
    if [[ $needed -lt 0 ]]; then
        echo "0"
    else
        echo "$needed"
    fi
}

# Get coverage status label
# Args: $1 = coverage %
# Returns: Status label (Excellent, Good, Fair, Poor)
get_coverage_status() {
    local coverage="$1"
    
    if [[ $coverage -ge 90 ]]; then
        echo "Excellent"
    elif [[ $coverage -ge 80 ]]; then
        echo "Good"
    elif [[ $coverage -ge 60 ]]; then
        echo "Fair"
    else
        echo "Poor"
    fi
}

# Export functions
export -f check_coverage_threshold
export -f calculate_required_apis
export -f get_coverage_status
