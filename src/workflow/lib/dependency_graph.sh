#!/bin/bash
set -euo pipefail

################################################################################
# Step Dependency Graph Module
# Purpose: Visualize execution flow and identify parallelization opportunities
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Created: December 18, 2025
################################################################################

# ==============================================================================
# DEPENDENCY DEFINITIONS
# ==============================================================================

# Define dependencies for each step (which steps must complete before this one)
declare -A STEP_DEPENDENCIES
STEP_DEPENDENCIES=(
    [0]=""                # Pre-Analysis has no dependencies
    [0a]="0"              # Version Update depends on Pre-Analysis (runs before docs)
    [0b]="0a"             # Bootstrap Documentation depends on Version Update (NEW v3.1.0)
    [1]="0b"              # Documentation depends on Bootstrap Documentation
    [2]="1"               # Consistency depends on Documentation
    [3]="0"               # Script Refs depends on Pre-Analysis
    [4]="0"               # Configuration Validation depends on Pre-Analysis (NEW v3.2.0)
    [5]="0"               # Directory Structure depends on Pre-Analysis
    [6]="0"               # Test Review depends on Pre-Analysis
    [7]="6"               # Test Generation depends on Test Review
    [8]="7"               # Test Execution depends on Test Generation
    [9]="0"               # Dependencies depends on Pre-Analysis
    [10]="8"              # Code Quality depends on Test Execution
    [11]="8,10"           # Deployment Readiness Gate depends on test execution and code quality (NEW v3.3.0, v4.1.0: removed circular dep on 16)
    [11.5]="1,2,3,4,5,8,9,10"  # Context Analysis depends on most steps (MOVED from Step 11)
    [11.7]="10"           # Front-End Development Analysis depends on Code Quality (NEW v4.0.1)
    [13]="2"              # Markdown Linting depends on Consistency
    [14]="0"              # Prompt Engineer Analysis depends on Pre-Analysis (can run early)
    [15]="11.7"           # UX Analysis depends on Front-End Development Analysis (can also run if no front-end code)
    [16]="11.5,13,14,15"  # AI-Powered Version Update depends on all analysis steps
    [12]="16"             # Git Finalization MUST BE LAST - depends on version update
)

# Define parallelizable step groups (steps that can run simultaneously)
# Updated v4.0.1: Step 11.7 (Front-End Development) added
declare -a PARALLEL_GROUPS
PARALLEL_GROUPS=(
    "0a"                  # Group 1: Version Update (runs after Step 0)
    "0b"                  # Group 2: Bootstrap Documentation (runs after 0a)
    "3,4,5,6,9,14"        # Group 3: Can run in parallel with Step 1
    "2,13"                # Group 4: Consistency checks
    "7"                   # Group 5: Test Generation
    "8,10"                # Group 6: Test Execution and Code Quality
    "11"                  # Group 7: Deployment Readiness Gate (NEW v3.3.0, conditional)
    "11.5"                # Group 8: Context Analysis (MOVED from Step 11)
    "11.7"                # Group 9: Front-End Development Analysis (NEW v4.0.1)
    "15"                  # Group 10: UX Analysis (updated dependency: after 11.7)
    "16"                  # Group 11: AI-Powered Version Update
    "12"                  # Group 12: Git Finalization (MUST BE LAST)
)

# 3-Track Parallel Execution Structure (v4.0.1 - with Front-End Development Analysis)
# Track 1 (Analysis):       0 → (3,4,5,14 parallel) → 11.5 ──────┐
# Track 2 (Validation):     6 → 7 → 8 → 10 → 11.7 → 11* (+ 9 parallel) ├─→ 16 → 12 (FINAL)
# Track 3 (Documentation):  0a → 0b → 1 → 2 → 13 → 15 ────────────┘
#
# Step 11 (Deployment Readiness Gate):
# - Conditional execution (only with --validate-release flag)
# - Runs after Step 8 (tests), Step 10 (code quality), Step 16 (version)
# - Blocks workflow on failure (strict mode)
# - Validates: tests passing, CHANGELOG updated, version bump, branch sync
#
# Step 11.5 (Context Analysis):
# - Moved from Step 11 to accommodate Deployment Gate
# - Runs in parallel with documentation track
# - Can execute alongside steps in Track 3
#
# Step 11.7 (Front-End Development Analysis): NEW v4.0.1
# - Runs after Step 10 (Code Quality)
# - Analyzes front-end code for technical implementation
# - Only executes for projects with front-end code
# - Must complete before Step 15 (UX Analysis)
#
# Step 15 (UX Analysis):
# - Updated dependency: now depends on Step 11.7 (Front-End Development)
# - Focuses on user experience and visual design
# - Complementary to Step 11.7 (technical vs UX focus)
#
# Synchronization Points:
# - All tracks wait for Step 0 completion
# - Step 11 waits for Steps 8, 10, 16 (deployment checks)
# - Step 11.5 waits for Track 2 & 3 critical steps
# - Step 11.7 waits for Step 10 (Code Quality)
# - Step 15 waits for Step 11.7 (or skips if no front-end code)
# - Step 16 waits for all analysis completion (Steps 11.5, 13, 14, 15)
# - Step 12 waits for version update (Step 16)
# - Estimated 60-70% time reduction vs sequential execution

# Step execution time estimates (in seconds, based on historical data)
declare -A STEP_TIME_ESTIMATES
STEP_TIME_ESTIMATES=(
    [0]=30    # Pre-Analysis
    [0a]=45   # Version Update (automated, pre-processing)
    [0b]=120  # Bootstrap Documentation (with AI) - NEW v3.1.0
    [1]=120   # Documentation (with AI)
    [2]=90    # Consistency
    [3]=60    # Script Refs
    [4]=90    # Configuration Validation (with AI) - NEW v3.2.0
    [5]=90    # Directory Structure
    [6]=120   # Test Review (with AI)
    [7]=180   # Test Generation (with AI)
    [8]=240   # Test Execution (longest step)
    [9]=60    # Dependencies
    [10]=150  # Code Quality (with AI)
    [11]=45   # Deployment Readiness Gate (NEW v3.3.0, conditional)
    [11.5]=120  # Context Analysis (with AI, MOVED from Step 11)
    [11.7]=180  # Front-End Development Analysis (with AI) - NEW v4.0.1
    [12]=90   # Git Finalization (with AI)
    [13]=45   # Markdown Linting
    [14]=150  # Prompt Engineer Analysis (with AI)
    [15]=180  # UX Analysis (with AI)
    [16]=60   # AI-Powered Version Update (with AI, final validation)
)

# ==============================================================================
# DEPENDENCY ANALYSIS
# ==============================================================================

# Check if step's dependencies are met
# Usage: check_dependencies <step_number> <completed_steps>
# Returns: 0 if dependencies met, 1 otherwise
check_dependencies() {
    local step_num="$1"
    local completed_steps="$2"  # Comma-separated list
    
    local dependencies="${STEP_DEPENDENCIES[${step_num}]}"
    
    # No dependencies means step can run
    if [[ -z "${dependencies}" ]]; then
        return 0
    fi
    
    # Check each dependency
    IFS=',' read -ra DEPS <<< "${dependencies}"
    for dep in "${DEPS[@]}"; do
        if ! echo ",${completed_steps}," | grep -q ",${dep},"; then
            return 1  # Dependency not met
        fi
    done
    
    return 0  # All dependencies met
}

# Get next runnable steps based on completed steps
# Usage: get_next_runnable_steps <completed_steps>
# Returns: Comma-separated list of step numbers that can run
get_next_runnable_steps() {
    local completed_steps="$1"
    local runnable_steps=""
    
    for i in {0..15}; do
        # Skip if already completed
        if echo ",${completed_steps}," | grep -q ",${i},"; then
            continue
        fi
        
        # Check if dependencies are met
        if check_dependencies "${i}" "${completed_steps}"; then
            if [[ -z "${runnable_steps}" ]]; then
                runnable_steps="${i}"
            else
                runnable_steps="${runnable_steps},${i}"
            fi
        fi
    done
    
    echo "${runnable_steps}"
}

# Get steps that can run in parallel
# Usage: get_parallel_steps <completed_steps>
# Returns: Comma-separated list of steps that can run simultaneously
get_parallel_steps() {
    local completed_steps="$1"
    local runnable=$(get_next_runnable_steps "${completed_steps}")
    
    # All runnable steps can potentially run in parallel
    echo "${runnable}"
}

# ==============================================================================
# VISUALIZATION
# ==============================================================================

# Generate Mermaid diagram of step dependencies
# Usage: generate_dependency_diagram [output_file]
generate_dependency_diagram() {
    local output_file="${1:-${BACKLOG_RUN_DIR}/STEP_DEPENDENCY_GRAPH.md}"
    
    mkdir -p "$(dirname "${output_file}")"
    
    cat > "${output_file}" << 'EOF'
# Step Dependency Graph

**Generated:** 
EOF
    echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "${output_file}"
    
    cat >> "${output_file}" << 'EOF'

## Workflow Step Dependencies

This graph shows the dependencies between workflow steps and identifies parallelization opportunities.

```mermaid
graph TD
    Step0[Step 0: Pre-Analysis<br/>~30s]
    Step1[Step 1: Documentation<br/>~120s]
    Step2[Step 2: Consistency<br/>~90s]
    Step3[Step 3: Script Refs<br/>~60s]
    Step4[Step 4: Directory<br/>~90s]
    Step5[Step 5: Test Review<br/>~120s]
    Step6[Step 6: Test Gen<br/>~180s]
    Step7[Step 7: Test Exec<br/>~240s]
    Step8[Step 8: Dependencies<br/>~60s]
    Step9[Step 9: Code Quality<br/>~150s]
    Step10[Step 10: Context<br/>~120s]
    Step11[Step 11: Git Final<br/>~90s]
    Step12[Step 12: Markdown<br/>~45s]
    
    Step0 --> Step1
    Step0 --> Step3
    Step0 --> Step4
    Step0 --> Step5
    Step0 --> Step8
    
    Step1 --> Step2
    Step2 --> Step12
    
    Step5 --> Step6
    Step6 --> Step7
    Step7 --> Step9
    
    Step1 --> Step10
    Step2 --> Step10
    Step3 --> Step10
    Step4 --> Step10
    Step7 --> Step10
    Step8 --> Step10
    Step9 --> Step10
    
    Step10 --> Step11
    
    style Step0 fill:#e1f5e1
    style Step7 fill:#ffe1e1
    style Step11 fill:#e1e5ff
```

## Parallelization Opportunities

### Group 1: Independent Validation (After Step 0)
Can run in parallel after Pre-Analysis completes:
- ✅ Step 1: Documentation Updates (~120s)
- ✅ Step 3: Script Reference Validation (~60s)
- ✅ Step 4: Directory Structure Validation (~90s)
- ✅ Step 5: Test Review (~120s)
- ✅ Step 8: Dependency Validation (~60s)

**Potential Time Saving:** ~270s (sequential: 450s → parallel: 180s)

### Group 2: Documentation Checks
Can run in parallel:
- ✅ Step 2: Consistency Analysis (~90s)
- ✅ Step 12: Markdown Linting (~45s)

**Potential Time Saving:** ~45s (sequential: 135s → parallel: 90s)

### Group 3: Quality Checks
Can run in parallel:
- ✅ Step 7: Test Execution (~240s)
- ✅ Step 9: Code Quality Validation (~150s)

**Potential Time Saving:** ~150s (sequential: 390s → parallel: 240s)

## Execution Time Analysis

### Current Sequential Execution
Total estimated time: **~1,395 seconds** (~23 minutes)

### With Parallelization
Estimated time: **~930 seconds** (~15.5 minutes)

**Time Savings: ~465 seconds** (~8 minutes, **33% faster**)

## Critical Path Analysis

The critical path (longest sequential chain) is:
1. Step 0: Pre-Analysis (30s)
2. Step 5: Test Review (120s)
3. Step 6: Test Generation (180s)
4. Step 7: Test Execution (240s) ⚠️ **Bottleneck**
5. Step 10: Context Analysis (120s)
6. Step 11: Git Finalization (90s)

**Critical Path Duration:** ~780 seconds (~13 minutes)

### Bottleneck Identification
- 🔴 **Step 7 (Test Execution)** is the primary bottleneck at 240s
- 🟡 **Step 6 (Test Generation)** is secondary at 180s
- 🟡 **Step 1 & 5 (AI steps)** at 120s each

## Optimization Recommendations

1. **Implement Parallel Execution** for Group 1 steps → Save ~8 minutes
2. **Optimize Test Execution** (Step 7) → Consider test sharding
3. **Cache AI Responses** → Reduce Steps 1, 5, 6, 9, 10, 11 duration
4. **Skip Redundant Steps** → Use change detection to skip unnecessary validation

---

*Generated by Step Dependency Graph Module v2.0.0*
EOF
    
    echo "${output_file}"
}

# Generate ASCII dependency tree
generate_dependency_tree() {
    cat << 'EOF'
Workflow Step Dependency Tree
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 0: Pre-Analysis (30s)
├─→ Step 1: Documentation (120s)
│   ├─→ Step 2: Consistency (90s)
│   │   ├─→ Step 12: Markdown Lint (45s)
│   │   └─→ Step 10: Context Analysis (120s)*
│   └─→ Step 10: Context Analysis (120s)*
├─→ Step 3: Script Refs (60s)
│   └─→ Step 10: Context Analysis (120s)*
├─→ Step 4: Directory Structure (90s)
│   └─→ Step 10: Context Analysis (120s)*
├─→ Step 5: Test Review (120s)
│   └─→ Step 6: Test Generation (180s)
│       └─→ Step 7: Test Execution (240s) ⚠️
│           ├─→ Step 9: Code Quality (150s)
│           │   └─→ Step 10: Context Analysis (120s)*
│           └─→ Step 10: Context Analysis (120s)*
└─→ Step 8: Dependencies (60s)
    └─→ Step 10: Context Analysis (120s)*

Step 10: Context Analysis (120s)*
└─→ Step 11: Git Finalization (90s)

* Step 10 has multiple dependencies (marked with asterisks)
⚠️ Step 7 is the primary bottleneck
EOF
}

# ==============================================================================
# EXECUTION PLANNING
# ==============================================================================

# Generate optimal execution plan with parallelization
# Usage: generate_execution_plan
generate_execution_plan() {
    local output_file="${BACKLOG_RUN_DIR}/EXECUTION_PLAN.md"
    
    mkdir -p "${BACKLOG_RUN_DIR}"
    
    cat > "${output_file}" << EOF
# Workflow Execution Plan

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Workflow Run:** ${WORKFLOW_RUN_ID}

---

## Execution Phases

### Phase 1: Pre-Analysis (30s)
- **Step 0:** Pre-Analysis
- **Parallel:** No (prerequisite for all steps)

### Phase 2: Independent Validation (180s) ⚡ Parallel
Run these steps simultaneously after Phase 1:
- **Step 1:** Documentation Updates (120s)
- **Step 3:** Script Reference Validation (60s)
- **Step 4:** Directory Structure Validation (90s)
- **Step 5:** Test Review (120s)
- **Step 8:** Dependency Validation (60s)

**Time:** Max duration = 180s (vs 450s sequential)

### Phase 3: Consistency Checks (90s) ⚡ Partial Parallel
- **Step 2:** Consistency Analysis (90s) - depends on Step 1
- **Step 12:** Markdown Linting (45s) - depends on Step 2

### Phase 4: Test Pipeline (600s)
- **Step 6:** Test Generation (180s) - depends on Step 5
- **Step 7:** Test Execution (240s) - depends on Step 6
- **Step 9:** Code Quality (150s) - can parallel with Step 7

**Optimization:** Steps 7 and 9 can run in parallel (saves 150s)

### Phase 5: Final Analysis (120s)
- **Step 10:** Context Analysis (120s)

### Phase 6: Finalization (90s)
- **Step 11:** Git Finalization (90s)

---

## Timeline Comparison

| Execution Mode | Total Time | Improvement |
|----------------|------------|-------------|
| Sequential     | ~1,395s (~23 min) | Baseline |
| Parallel       | ~930s (~15.5 min) | 33% faster |

## Implementation Strategy

1. **Phase 1 Implementation:** Parallelize Group 1 (Steps 1,3,4,5,8)
   - Use Bash background jobs with \`wait\` synchronization
   - Estimated development: 2-3 hours
   - Time savings: ~270 seconds per run

2. **Phase 2 Implementation:** Parallelize Steps 7 & 9
   - Ensure test execution doesn't interfere with quality checks
   - Estimated development: 1-2 hours
   - Time savings: ~150 seconds per run

3. **Phase 3 Implementation:** Smart step skipping
   - Use change detection module
   - Skip unnecessary validation steps
   - Additional time savings: Variable (up to 50% for simple changes)

---

*Generated by Step Dependency Graph Module v2.0.0*
EOF
    
    echo "${output_file}"
}

# Display execution phases in terminal
display_execution_phases() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             WORKFLOW EXECUTION PHASES                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Phase 1: Pre-Analysis (30s)"
    echo "  → Step 0"
    echo ""
    echo "Phase 2: Independent Validation ⚡ (180s parallel)"
    echo "  → Steps 1, 3, 4, 5, 8"
    echo ""
    echo "Phase 3: Test Pipeline (600s)"
    echo "  → Steps 6, 7, 9"
    echo ""
    echo "Phase 4: Final Analysis (120s)"
    echo "  → Step 10"
    echo ""
    echo "Phase 5: Finalization (90s)"
    echo "  → Step 11"
    echo ""
    echo "Total Estimated Time: ~930s (~15.5 minutes)"
    echo ""
}

# Calculate critical path duration
calculate_critical_path() {
    local total=0
    
    # Critical path: 0 → 5 → 6 → 7 → 10 → 11
    total=$((total + STEP_TIME_ESTIMATES[0]))  # Pre-Analysis
    total=$((total + STEP_TIME_ESTIMATES[5]))  # Test Review
    total=$((total + STEP_TIME_ESTIMATES[6]))  # Test Generation
    total=$((total + STEP_TIME_ESTIMATES[7]))  # Test Execution
    total=$((total + STEP_TIME_ESTIMATES[10])) # Context Analysis
    total=$((total + STEP_TIME_ESTIMATES[11])) # Git Finalization
    
    echo "${total}"
}

# Export functions for use in workflow
export -f check_dependencies get_next_runnable_steps get_parallel_steps
export -f generate_dependency_diagram generate_execution_plan
export -f display_execution_phases calculate_critical_path

# ==============================================================================
# JSON EXPORT (NEW v2.6.1)
# ==============================================================================

# Export step metadata and dependencies as JSON
# Usage: export_step_metadata_json [output_file]
export_step_metadata_json() {
    local output_file="${1:-/dev/stdout}"
    
    # Source step metadata if available
    if [[ -f "$(dirname "${BASH_SOURCE[0]}")/step_metadata.sh" ]]; then
        source "$(dirname "${BASH_SOURCE[0]}")/step_metadata.sh"
    fi
    
    cat > "$output_file" << 'JSONEOF'
{
  "version": "2.6.1",
  "generated": "$(date -Iseconds)",
  "workflow": {
    "total_steps": 16,
    "parallelizable": true,
    "supports_smart_execution": true
  },
  "steps": [
JSONEOF
    
    # Generate JSON for each step
    local first=true
    for step in {0..14}; do
        # Skip if step doesn't exist
        if [[ ! -v STEP_DEPENDENCIES[$step] ]]; then
            continue
        fi
        
        # Add comma separator
        if [[ "$first" == "false" ]]; then
            echo "    ," >> "$output_file"
        fi
        first=false
        
        # Get metadata
        local name="${STEP_NAMES[$step]:-Step $step}"
        local desc="${STEP_DESCRIPTIONS[$step]:-No description}"
        local category="${STEP_CATEGORIES[$step]:-unknown}"
        local can_skip="${STEP_CAN_SKIP[$step]:-false}"
        local can_parallel="${STEP_CAN_PARALLELIZE[$step]:-false}"
        local needs_ai="${STEP_REQUIRES_AI[$step]:-false}"
        local affects="${STEP_AFFECTS_FILES[$step]:-}"
        local deps="${STEP_DEPENDENCIES[$step]:-}"
        local time="${STEP_TIME_ESTIMATES[$step]:-60}"
        
        # Convert dependencies to JSON array
        local deps_json="[]"
        if [[ -n "$deps" ]]; then
            deps_json="[$(echo "$deps" | sed 's/,/,/g')]"
        fi
        
        cat >> "$output_file" << STEPJSON
    {
      "id": $step,
      "name": "$name",
      "description": "$desc",
      "category": "$category",
      "dependencies": $deps_json,
      "estimated_time_seconds": $time,
      "can_skip": $can_skip,
      "can_parallelize": $can_parallel,
      "requires_ai": $needs_ai,
      "affects_files": "$affects"
    }
STEPJSON
    done
    
    cat >> "$output_file" << 'JSONEOF'
  ],
  "categories": {
    "analysis": [0, 10],
    "documentation": [1],
    "validation": [2, 3, 4, 8],
    "testing": [5, 6, 7],
    "quality": [9, 12, 13, 14],
    "versioning": [15],
    "finalization": [11]
  },
  "parallelization": {
    "max_parallel_groups": 7,
    "groups": [
      {
        "id": 1,
        "steps": [1, 3, 4, 5, 8, 13, 14],
        "description": "Independent validation after Pre-Analysis"
      },
      {
        "id": 2,
        "steps": [2, 12],
        "description": "Documentation checks"
      },
      {
        "id": 3,
        "steps": [6],
        "description": "Test generation"
      },
      {
        "id": 4,
        "steps": [7, 9],
        "description": "Test execution and quality"
      },
      {
        "id": 5,
        "steps": [10],
        "description": "Context analysis"
      },
      {
        "id": 6,
        "steps": [15],
        "description": "Version update"
      },
      {
        "id": 7,
        "steps": [11],
        "description": "Final git operations"
      }
    ]
  },
  "critical_path": {
    "steps": [0, 5, 6, 7, 10, 15, 11],
    "total_time_seconds": 825,
    "description": "Longest sequential chain through workflow"
  },
  "optimization": {
    "sequential_time_seconds": 1440,
    "parallel_time_seconds": 975,
    "time_savings_seconds": 465,
    "time_savings_percent": 32
  }
}
JSONEOF
    
    if [[ "$output_file" != "/dev/stdout" ]]; then
        echo "Step metadata exported to: $output_file"
    fi
}

# Query step dependencies with metadata
# Usage: query_step_info <step_number>
query_step_info() {
    local step_num="$1"
    
    if [[ ! -v STEP_DEPENDENCIES[$step_num] ]]; then
        echo "Error: Invalid step number: $step_num" >&2
        return 1
    fi
    
    # Source metadata if available
    if [[ -f "$(dirname "${BASH_SOURCE[0]}")/step_metadata.sh" ]]; then
        source "$(dirname "${BASH_SOURCE[0]}")/step_metadata.sh"
    fi
    
    echo "=== Step $step_num Information ==="
    echo "Name: ${STEP_NAMES[$step_num]:-Unknown}"
    echo "Description: ${STEP_DESCRIPTIONS[$step_num]:-No description}"
    echo "Category: ${STEP_CATEGORIES[$step_num]:-unknown}"
    echo "Dependencies: ${STEP_DEPENDENCIES[$step_num]:-none}"
    echo "Estimated Time: ${STEP_TIME_ESTIMATES[$step_num]:-unknown}s"
    echo "Can Skip: ${STEP_CAN_SKIP[$step_num]:-unknown}"
    echo "Can Parallelize: ${STEP_CAN_PARALLELIZE[$step_num]:-unknown}"
    echo "Requires AI: ${STEP_REQUIRES_AI[$step_num]:-unknown}"
    echo "Affects Files: ${STEP_AFFECTS_FILES[$step_num]:-none}"
}

# Find steps that can run now based on completed steps
# Usage: get_ready_steps <completed_steps_csv>
get_ready_steps() {
    local completed="$1"
    local ready=()
    
    for step in {0..15}; do
        if [[ ! -v STEP_DEPENDENCIES[$step] ]]; then
            continue
        fi
        
        # Skip if already completed
        if echo ",$completed," | grep -q ",$step,"; then
            continue
        fi
        
        # Check if dependencies are met
        if check_dependencies "$step" "$completed"; then
            ready+=("$step")
        fi
    done
    
    echo "${ready[@]}" | tr ' ' ','
}

# Calculate critical path through workflow
# Returns: Space-separated list of steps in critical path
calculate_critical_path() {
    # Hardcoded based on dependency analysis
    # This is the longest sequential chain
    echo "0 5 6 7 10 15 11"
}

# Calculate total time for step list
# Usage: calculate_total_time <step_list_csv>
calculate_total_time() {
    local steps="$1"
    local total=0
    
    IFS=',' read -ra STEP_ARRAY <<< "$steps"
    for step in "${STEP_ARRAY[@]}"; do
        local time="${STEP_TIME_ESTIMATES[$step]:-60}"
        total=$((total + time))
    done
    
    echo "$total"
}

# Export additional functions
export -f export_step_metadata_json
export -f query_step_info
export -f get_ready_steps
export -f calculate_critical_path
export -f calculate_total_time

################################################################################
# Module enhanced with step metadata support (v2.6.1)
################################################################################
