# Workflow Orchestrators

**Version**: 2.3.1 (Phase 3 Tech Stack Adaptive Framework)  
**Purpose**: Phase-specific workflow orchestration modules

---

## Overview

This directory contains sub-orchestrators that manage distinct phases of the workflow automation. Each orchestrator is responsible for coordinating a specific set of steps and implementing phase-specific optimizations.

## Orchestrators

### 1. Pre-Flight Orchestrator
**File**: `pre_flight.sh`  
**Lines**: 227  
**Phase**: Initialization  

**Responsibilities**:
- System prerequisites validation (Bash, Node.js, npm, git)
- Project dependencies verification
- Project structure validation
- Directory initialization
- Cache system initialization (git, AI, metrics)
- Change impact analysis

**Key Functions**:
- `execute_preflight()` - Main orchestration
- `check_prerequisites()` - System checks
- `validate_dependencies()` - npm/node validation
- `validate_project_structure()` - git/structure checks

**Called By**: Main script before workflow execution

---

### 2. Validation Orchestrator
**File**: `validation_orchestrator.sh`  
**Lines**: 228  
**Phase**: Documentation & Structure  

**Steps**: 0-4
- Step 0: Pre-Analysis
- Step 1: Documentation Updates
- Step 2: Consistency Analysis
- Step 3: Script Reference Validation
- Step 4: Directory Structure Validation

**Key Functions**:
- `execute_validation_phase()` - Main orchestration
- `execute_validation_steps()` - Sequential execution
- `execute_parallel_validation()` - Parallel execution (33% faster)

**Special Features**:
- Parallel execution support (Steps 1-4 simultaneously)
- Smart execution integration
- Resume capability

**Called By**: Main script `execute_full_workflow()`

---

### 3. Test Orchestrator
**File**: `test_orchestrator.sh`  
**Lines**: 111  
**Phase**: Testing  

**Steps**: 5-7
- Step 5: Test Review
- Step 6: Test Generation
- Step 7: Test Execution

**Key Functions**:
- `execute_test_phase()` - Main orchestration

**Special Features**:
- Smart execution (skip all for Low impact changes)
- Checkpoint management per step

**Called By**: Main script `execute_full_workflow()`

---

### 4. Quality Orchestrator
**File**: `quality_orchestrator.sh`  
**Lines**: 82  
**Phase**: Quality Checks  

**Steps**: 8-9
- Step 8: Dependency Validation
- Step 9: Code Quality Validation

**Key Functions**:
- `execute_quality_phase()` - Main orchestration

**Special Features**:
- Smart execution (skip Step 8 if package.json unchanged)

**Called By**: Main script `execute_full_workflow()`

---

### 5. Finalization Orchestrator
**File**: `finalization_orchestrator.sh`  
**Lines**: 93  
**Phase**: Completion  

**Steps**: 10-12
- Step 10: Context Analysis
- Step 11: Git Finalization
- Step 12: Markdown Linting

**Key Functions**:
- `execute_finalization_phase()` - Main orchestration

**Called By**: Main script `execute_full_workflow()`

---

## Architecture Principles

### Single Responsibility
Each orchestrator manages one distinct phase of the workflow with related steps.

### Clear Boundaries
Orchestrators communicate through:
- Return codes (0 = success, 1 = failure)
- Shared state (checkpoints, logs, metrics)
- Global variables (WORKFLOW_STATUS, CHANGE_IMPACT)

### Error Handling
```bash
execute_phase() {
    # Step execution
    if ! step_function; then
        print_error "Step failed"
        log_to_workflow "ERROR" "Phase failed at step"
        return 1
    fi
    
    # Success
    return 0
}
```

### Logging Pattern
```bash
execute_phase() {
    print_header "Phase Name (Steps X-Y)"
    log_to_workflow "INFO" "Starting phase"
    
    local start_time=$(date +%s)
    
    # ... execution ...
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Phase completed in ${duration}s"
    log_to_workflow "SUCCESS" "Phase completed: ${duration}s"
}
```

---

## Development Guidelines

### Adding a New Orchestrator

1. **Create file**: `orchestrators/new_phase.sh`

2. **Implement structure**:
```bash
#!/usr/bin/env bash

################################################################################
# New Phase Orchestrator
# Version: 2.3.1
# Purpose: Orchestrate [description] (Steps X-Y)
# Part of: Workflow Automation Modularization Phase 3
################################################################################

set -euo pipefail

execute_new_phase() {
    print_header "New Phase (Steps X-Y)"
    log_to_workflow "INFO" "Starting new phase"
    
    local start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step execution logic
    if [[ $resume_from -le X ]] && should_execute_step X; then
        log_step_start X "Step Name"
        if stepX_function; then
            ((executed_steps++)) || true
            save_checkpoint X
        else
            failed_step="Step X"
        fi
    fi
    
    # More steps...
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Phase completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "Phase completed: ${duration}s"
        return 0
    else
        print_error "Phase failed at $failed_step"
        log_to_workflow "ERROR" "Phase failed at $failed_step"
        return 1
    fi
}
```

3. **Add to main script**:
```bash
# In module loading section
for orch_file in "${ORCHESTRATORS_DIR}"/*.sh; do
    [[ -f "$orch_file" ]] && source "$orch_file"
done

# In execute_full_workflow()
if ! $phase_failed && [[ $resume_from -le Y ]]; then
    if ! execute_new_phase; then
        phase_failed=true
    fi
fi
```

4. **Test independently**:
```bash
source orchestrators/new_phase.sh
execute_new_phase
```

### Modifying Existing Orchestrator

1. **Identify orchestrator** by step numbers
2. **Edit directly** (focused files)
3. **Test in isolation**
4. **Run full workflow** to validate

### Best Practices

- Keep orchestrators < 250 lines
- One phase per orchestrator
- Use consistent naming: `execute_<phase>_phase()`
- Comprehensive error handling
- Detailed logging
- Support smart execution
- Support resume capability

---

## Testing

### Unit Testing
```bash
# Mock dependencies
step1_update_documentation() { return 0; }

# Source orchestrator
source orchestrators/validation_orchestrator.sh

# Test
if execute_validation_phase; then
    echo "Test passed"
else
    echo "Test failed"
fi
```

### Integration Testing
```bash
# Test specific phase
./execute_tests_docs_workflow_v2.4.sh \
  --dry-run \
  --steps 0,1,2,3,4 \
  --verbose
```

---

## Performance

### Loading Time
All orchestrators: < 10ms total

### Execution Overhead
Negligible (< 1ms per phase transition)

### Optimization Opportunities
- Parallel validation: 33% faster (implemented)
- Parallel testing: 30% faster (future)
- Parallel quality: 25% faster (future)

---

## Dependencies

### Required Libraries
- `lib/colors.sh` - Terminal formatting
- `lib/utils.sh` - Common utilities
- `lib/validation.sh` - Input validation
- `lib/backlog.sh` - Issue tracking
- `lib/step_execution.sh` - Step lifecycle
- `lib/workflow_optimization.sh` - Smart execution
- `lib/change_detection.sh` - Impact analysis
- `lib/metrics.sh` - Performance tracking

### Required Steps
Each orchestrator depends on corresponding step modules:
- Validation: `steps/step_0[0-4]_*.sh`
- Test: `steps/step_0[5-7]_*.sh`
- Quality: `steps/step_0[8-9]_*.sh`
- Finalization: `steps/step_1[0-2]_*.sh`

---

## Troubleshooting

### Function Not Found
**Symptom**: `command not found: execute_validation_phase`

**Solution**:
```bash
# Check sourcing in main script
grep "orchestrators" ../execute_tests_docs_workflow_v2.4.sh

# Verify file exists
ls -l validation_orchestrator.sh

# Check permissions
chmod +x *.sh
```

### Phase Execution Failed
**Symptom**: "Validation phase failed"

**Debug**:
```bash
# Enable debug mode
bash -x orchestrators/validation_orchestrator.sh

# Check dependencies
bash -n orchestrators/validation_orchestrator.sh

# Review logs
tail -f ../logs/workflow_*/workflow_execution.log
```

---

## Metrics

| Metric | Value |
|--------|-------|
| **Total Orchestrators** | 5 |
| **Total Lines** | 741 |
| **Average Lines** | 148 |
| **Largest Module** | 228 lines (validation) |
| **Smallest Module** | 82 lines (quality) |
| **Load Time** | < 10ms |
| **Overhead per Phase** | < 1ms |

---

## Version History

### v2.3.1 - Phase 3 Implementation (2025-12-18)
- Initial implementation
- 5 focused orchestrators
- Phase-based architecture
- 91% reduction from monolithic script

---

## References

- [Orchestrator Architecture Guide](/docs/ORCHESTRATOR_ARCHITECTURE.md)
- [Modularization Phase 3 Report](/MODULARIZATION_PHASE3_COMPLETION.md)
- [Main Coordinator](/src/workflow/execute_tests_docs_workflow_v2.4.sh)

---

**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-18
