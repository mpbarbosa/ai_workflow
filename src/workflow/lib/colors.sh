#!/bin/bash
set -euo pipefail

################################################################################
# Color Codes Module
# Purpose: ANSI color definitions for consistent terminal output
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ANSI color codes - matching existing shell script conventions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Export all color codes for use in other modules
export RED GREEN YELLOW BLUE CYAN MAGENTA NC
