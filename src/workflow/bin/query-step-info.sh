#!/bin/bash
set -euo pipefail

################################################################################
# Query Step Information Tool  
# Purpose: Command-line tool to query workflow step metadata
# Usage: query-step-info.sh [command] [args...]
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_HOME="$(cd "${SCRIPT_DIR}/../.." && pwd)"
export WORKFLOW_HOME

# Source required modules
source "${SCRIPT_DIR}/../lib/colors.sh" 2>/dev/null || { RED=""; GREEN=""; CYAN=""; NC=""; }
source "${SCRIPT_DIR}/../lib/step_metadata.sh"
source "${SCRIPT_DIR}/../lib/dependency_graph.sh"

# Show usage
show_usage() {
    cat << 'USAGE'
Usage: query-step-info.sh [command] [args...]

Commands:
  info <step>              Show detailed information about a step
  list                     List all steps with basic info
  dependencies <step>      Show dependencies for a step
  ready <completed>        Show steps ready to run
  skippable                List all skippable steps
  critical-path            Show the critical path
  export-json [file]       Export metadata as JSON

Examples:
  query-step-info.sh info 7
  query-step-info.sh ready "0,1,2"
  query-step-info.sh export-json metadata.json
USAGE
}

# Main command dispatcher
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        info) query_step_info "$1" ;;
        list) 
            for step in {0..14}; do
                [[ -v STEP_NAMES[$step] ]] && printf "Step %2d: %s\n" "$step" "${STEP_NAMES[$step]}"
            done
            ;;
        dependencies) echo "Step $1 dependencies: ${STEP_DEPENDENCIES[$1]:-none}" ;;
        ready) get_ready_steps "$1" ;;
        skippable) get_skippable_steps ;;
        critical-path) calculate_critical_path ;;
        export-json) export_step_metadata_json "${1:-workflow-metadata.json}" ;;
        *) show_usage; exit 1 ;;
    esac
}

main "$@"
