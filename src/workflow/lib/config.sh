#!/bin/bash
set -euo pipefail

################################################################################
# Workflow Configuration Module
# Purpose: Central configuration and constants for workflow automation
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Script metadata
SCRIPT_VERSION="2.3.0"
SCRIPT_NAME="Tests & Documentation Workflow Automation"

# Directory paths - computed relative to project root
# PROJECT_ROOT must be set by calling script before sourcing this module
if [[ -z "${PROJECT_ROOT:-}" ]]; then
    # Fallback: compute from this script's location (lib/ is in src/workflow/)
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi

SRC_DIR="${PROJECT_ROOT}/src"
BACKLOG_DIR="${PROJECT_ROOT}/src/workflow/backlog"
SUMMARIES_DIR="${PROJECT_ROOT}/src/workflow/summaries"
LOGS_DIR="${PROJECT_ROOT}/src/workflow/logs"
DOCS_DIR="${PROJECT_ROOT}/docs"
SHELL_SCRIPTS_DIR="${PROJECT_ROOT}/shell_scripts"

# Temporary files tracking for cleanup
# Used by AI-enhanced steps to store intermediate validation results
# Cleaned up automatically via trap handler on script exit
TEMP_FILES=()

# Backlog tracking - unique timestamped workflow run ID
WORKFLOW_RUN_ID="workflow_$(date +%Y%m%d_%H%M%S)"
BACKLOG_RUN_DIR="${BACKLOG_DIR}/${WORKFLOW_RUN_ID}"
SUMMARIES_RUN_DIR="${SUMMARIES_DIR}/${WORKFLOW_RUN_ID}"
LOGS_RUN_DIR="${LOGS_DIR}/${WORKFLOW_RUN_ID}"

# Workflow tracking
declare -A WORKFLOW_STATUS
TOTAL_STEPS=13
DRY_RUN=false
INTERACTIVE_MODE=true
AUTO_MODE=false
WORKFLOW_START_TIME=$(date +%s)

# Analysis variables (populated during execution)
ANALYSIS_COMMITS=""
ANALYSIS_MODIFIED=""
CHANGE_SCOPE=""

# Export all configuration variables for use in other modules
export SCRIPT_VERSION SCRIPT_NAME
export PROJECT_ROOT SRC_DIR BACKLOG_DIR SUMMARIES_DIR LOGS_DIR DOCS_DIR SHELL_SCRIPTS_DIR
export WORKFLOW_RUN_ID BACKLOG_RUN_DIR SUMMARIES_RUN_DIR LOGS_RUN_DIR
export TOTAL_STEPS DRY_RUN INTERACTIVE_MODE AUTO_MODE WORKFLOW_START_TIME
export ANALYSIS_COMMITS ANALYSIS_MODIFIED CHANGE_SCOPE
