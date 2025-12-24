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
    [1]="0"               # Documentation depends on Pre-Analysis
    [2]="1"               # Consistency depends on Documentation
    [3]="0"               # Script Refs depends on Pre-Analysis
    [4]="0"               # Directory Structure depends on Pre-Analysis
    [5]="0"               # Test Review depends on Pre-Analysis
    [6]="5"               # Test Generation depends on Test Review
    [7]="6"               # Test Execution depends on Test Generation
    [8]="0"               # Dependencies depends on Pre-Analysis
    [9]="7"               # Code Quality depends on Test Execution
    [10]="1,2,3,4,7,8,9"  # Context Analysis depends on most steps
    [12]="2"              # Markdown Linting depends on Consistency
    [13]="0"              # Prompt Engineer Analysis depends on Pre-Analysis (can run early)
    [14]="0,1"            # UX Analysis depends on Pre-Analysis and Documentation
    [11]="10,12,13,14"    # Git Finalization MUST BE LAST - depends on all analysis steps
)

# Define parallelizable step groups (steps that can run simultaneously)
# Updated v2.4.0: 3-Track Parallelization with Step 11 as FINAL step
declare -a PARALLEL_GROUPS
PARALLEL_GROUPS=(
    "1,3,4,5,8,13,14"     # Group 1: Can run after Pre-Analysis
    "2,12"                # Group 2: Consistency checks
    "6"                   # Group 3: Test Generation
    "7,9"                 # Group 4: Test Execution and Code Quality
    "10"                  # Group 5: Context Analysis
    "11"                  # Group 6: Git Finalization (MUST BE LAST - runs after all other steps)
)

# 3-Track Parallel Execution Structure (v2.4.0)
# Track 1 (Analysis):       0 → (3,4,13 parallel) → 10 ┐
# Track 2 (Validation):     5 → 6 → 7 → 9 (+ 8 parallel) ├─→ 11 (FINAL)
# Track 3 (Documentation):  1 → 2 → 12 → 14 ────────────┘
#
# Synchronization Points:
# - All tracks wait for Step 0 completion
# - Step 10 waits for Track 2 & 3 critical steps
# - Estimated 60-70% time reduction vs sequential execution

# Step execution time estimates (in seconds, based on historical data)
declare -A STEP_TIME_ESTIMATES
STEP_TIME_ESTIMATES=(
    [0]=30    # Pre-Analysis
    [1]=120   # Documentation (with AI)
    [2]=90    # Consistency
    [3]=60    # Script Refs
    [4]=90    # Directory Structure
    [5]=120   # Test Review (with AI)
    [6]=180   # Test Generation (with AI)
    [7]=240   # Test Execution (longest step)
    [8]=60    # Dependencies
    [9]=150   # Code Quality (with AI)
    [10]=120  # Context Analysis (with AI)
    [11]=90   # Git Finalization (with AI)
    [12]=45   # Markdown Linting
    [13]=150  # Prompt Engineer Analysis (with AI)
    [14]=180  # UX Analysis (with AI)
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
    
    for i in {0..14}; do
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
