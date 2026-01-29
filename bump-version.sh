#!/usr/bin/env bash
################################################################################
# Convenience wrapper for bump_project_version.sh
# Usage: ./bump-version.sh [options]
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/src/workflow/bump_project_version.sh" "$@"
