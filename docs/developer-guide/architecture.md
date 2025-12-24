# Orchestrator Architecture Guide

**Version**: 2.4.0  
**Last Updated**: 2025-12-18  
**Target Audience**: Developers contributing to AI Workflow Automation

---

## Overview

The v2.4.0 refactoring introduced a **phase-based orchestrator architecture** that breaks the monolithic 5,294-line main script into focused, maintainable components. This guide explains the architecture and how to work with it.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  execute_tests_docs_workflow_v2.4.sh (479 lines)                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Main Coordinator                                        │   │
│  │  - Configuration & Constants                             │   │
│  │  - Module Loading                                        │   │
│  │  - Argument Parsing                                      │   │
│  │  - High-Level Flow Control                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  Phase Orchestrators          │
              └───────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Pre-Flight    │   │ Validation    │   │ Test          │
│ (227 lines)   │   │ (228 lines)   │   │ (111 lines)   │
│               │   │               │   │               │
│ - System      │   │ - Step 0      │   │ - Step 5      │
│   checks      │   │ - Step 1      │   │ - Step 6      │
│ - Git cache   │   │ - Step 2      │   │ - Step 7      │
│ - AI cache    │   │ - Step 3      │   │               │
│ - Metrics     │   │ - Step 4      │   │               │
└───────────────┘   └───────────────┘   └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐
│ Quality       │   │ Finalization  │
│ (82 lines)    │   │ (93 lines)    │
│               │   │               │
│ - Step 8      │   │ - Step 10     │
│ - Step 9      │   │ - Step 11     │
│               │   │ - Step 12     │
└───────────────┘   └───────────────┘
        │                     │
        └──────────┬──────────┘
                   ▼
        ┌──────────────────────┐
        │  Step Modules         │
        │  (15 step_*.sh files) │
        └──────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  Library Modules      │
        │  (28 lib/*.sh files)  │
        └──────────────────────┘
```

---

## Component Responsibilities

### Main Coordinator
**File**: `execute_tests_docs_workflow_v2.4.sh`  
**Size**: 479 lines  
**Role**: High-level coordination and configuration

**Key Responsibilities**:
- Parse command-line arguments
- Load all modules (libraries, steps, orchestrators)
- Execute pre-flight checks
- Delegate execution to phase orchestrators
- Handle checkpoints and resume logic
- Display final workflow summary
- Manage cleanup and logging

**Key Functions**:
```bash
main()                      # Entry point
parse_arguments()           # CLI argument parsing
execute_full_workflow()     # Delegates to orchestrators
show_workflow_summary()     # Final reporting
```

**When to Modify**:
- Adding new command-line options
- Changing overall workflow flow
- Adding new orchestrators
- Modifying summary display

---

### Pre-Flight Orchestrator
**File**: `orchestrators/pre_flight.sh`  
**Size**: 227 lines  
**Phase**: Initialization  
**Role**: System validation and setup

**Key Responsibilities**:
- Validate system prerequisites (Bash 4.0+, Node.js, npm, git)
- Check project dependencies (package.json, node_modules)
- Validate project structure (git repo, README, src directories)
- Initialize workflow directories
- Initialize git state cache
- Initialize AI response cache
- Initialize metrics collection
- Analyze change impact

**Key Functions**:
```bash
execute_preflight()         # Main orchestration
check_prerequisites()       # System validation
validate_dependencies()     # npm/node checks
validate_project_structure()# git/directory validation
init_directories()          # Create workflow dirs
init_workflow_log()         # Setup logging
```

**When to Modify**:
- Adding new prerequisite checks
- Changing initialization sequence
- Adding new cache systems
- Modifying project structure requirements

**Example Addition**:
```bash
# Add Docker prerequisite check
check_docker_available() {
    if ! command -v docker &> /dev/null; then
        print_warning "Docker not found - some features may be unavailable"
        return 0
    fi
    print_success "Docker available"
    return 0
}

# Call in execute_preflight()
execute_preflight() {
    # ... existing checks ...
    check_docker_available
    # ... rest of function ...
}
```

---

### Validation Orchestrator
**File**: `orchestrators/validation_orchestrator.sh`  
**Size**: 228 lines  
**Phase**: Documentation & Structure (Steps 0-4)  
**Role**: Document and structure validation

**Key Responsibilities**:
- Execute Step 0 (Pre-Analysis)
- Execute Steps 1-4 (sequentially or in parallel)
- Coordinate parallel validation when `--parallel` enabled
- Handle smart execution skipping
- Manage checkpoints per step

**Key Functions**:
```bash
execute_validation_phase()    # Main orchestration
execute_validation_steps()    # Sequential execution
execute_parallel_validation() # Parallel execution (33% faster)
```

**Parallel Execution Logic**:
```bash
# Steps 1-4 run simultaneously when possible
execute_parallel_validation() {
    # Launch steps in background
    (step1_update_documentation) &
    (step2_check_consistency) &
    (step3_validate_script_references) &
    (step4_validate_directory_structure) &
    
    # Wait for all to complete
    wait
    
    # Check exit codes
    # Return 0 if all succeeded
}
```

**When to Modify**:
- Adding new validation steps
- Changing parallel execution logic
- Modifying step dependencies
- Adding phase-specific optimizations

---

### Test Orchestrator
**File**: `orchestrators/test_orchestrator.sh`  
**Size**: 111 lines  
**Phase**: Testing (Steps 5-7)  
**Role**: Test review, generation, and execution

**Key Responsibilities**:
- Execute Step 5 (Test Review)
- Execute Step 6 (Test Generation)
- Execute Step 7 (Test Execution)
- Apply smart execution (skip all for Low impact)

**Key Functions**:
```bash
execute_test_phase()  # Main orchestration
```

**Smart Execution**:
```bash
# Skip test steps for documentation-only changes
if [[ "${SMART_EXECUTION}" == "true" ]] && 
   should_skip_step_by_impact 5 "${CHANGE_IMPACT}"; then
    print_info "⚡ Step 5 skipped (smart execution - ${CHANGE_IMPACT} impact)"
    ((skipped_steps++))
fi
```

**When to Modify**:
- Adding new test-related steps
- Changing test execution order
- Modifying smart execution logic
- Adding test-specific optimizations

---

### Quality Orchestrator
**File**: `orchestrators/quality_orchestrator.sh`  
**Size**: 82 lines  
**Phase**: Quality Checks (Steps 8-9)  
**Role**: Dependency and code quality validation

**Key Responsibilities**:
- Execute Step 8 (Dependency Validation)
- Execute Step 9 (Code Quality Validation)
- Apply smart execution (skip Step 8 if package.json unchanged)

**Key Functions**:
```bash
execute_quality_phase()  # Main orchestration
```

**When to Modify**:
- Adding new quality checks
- Modifying dependency validation logic
- Adding new linting/quality tools
- Changing smart execution rules

---

### Finalization Orchestrator
**File**: `orchestrators/finalization_orchestrator.sh`  
**Size**: 93 lines  
**Phase**: Completion (Steps 10-12)  
**Role**: Context analysis, git operations, and cleanup

**Key Responsibilities**:
- Execute Step 10 (Context Analysis)
- Execute Step 11 (Git Finalization)
- Execute Step 12 (Markdown Linting)

**Key Functions**:
```bash
execute_finalization_phase()  # Main orchestration
```

**When to Modify**:
- Adding final validation steps
- Modifying git finalization logic
- Adding cleanup procedures
- Changing commit message generation

---

## Development Workflow

### Adding a New Step

1. **Create step module** in `steps/step_XX_name.sh`
2. **Add to appropriate orchestrator**:
   ```bash
   # Example: Adding Step 13 to finalization phase
   # Edit: orchestrators/finalization_orchestrator.sh
   
   if [[ $resume_from -le 13 ]] && should_execute_step 13; then
       log_step_start 13 "New Step Name"
       if step13_new_functionality; then
           ((executed_steps++))
           save_checkpoint 13
       else
           failed_step="Step 13"
       fi
   fi
   ```
3. **Update step count** in main coordinator
4. **Update documentation**

### Adding a New Phase

1. **Create new orchestrator** in `orchestrators/new_phase.sh`
2. **Implement phase function**:
   ```bash
   execute_new_phase() {
       print_header "New Phase (Steps X-Y)"
       log_to_workflow "INFO" "Starting new phase"
       
       # Step execution logic
       
       return 0  # or 1 on failure
   }
   ```
3. **Add to main coordinator**:
   ```bash
   # In execute_full_workflow()
   if ! $phase_failed && [[ $resume_from -le Y ]]; then
       if ! execute_new_phase; then
           phase_failed=true
       fi
   fi
   ```
4. **Update module loading** in main script
5. **Update documentation**

### Modifying Existing Phase Logic

1. **Identify correct orchestrator** based on step numbers
2. **Edit orchestrator** directly (small, focused files)
3. **Test phase in isolation**:
   ```bash
   # Source required modules
   source lib/*.sh
   source steps/step_*.sh
   source orchestrators/validation_orchestrator.sh
   
   # Test function directly
   execute_validation_phase
   ```
4. **Run full workflow** to validate integration

---

## Testing Strategy

### Unit Testing Orchestrators

```bash
#!/bin/bash
# test_orchestrators.sh

# Source test framework
source lib/colors.sh
source lib/utils.sh

# Mock step functions
step0_analyze_changes() { return 0; }
step1_update_documentation() { return 0; }
# ... etc

# Load orchestrator
source orchestrators/validation_orchestrator.sh

# Test
test_validation_phase_success() {
    if execute_validation_phase; then
        print_success "Validation phase test passed"
        return 0
    else
        print_error "Validation phase test failed"
        return 1
    fi
}

# Run tests
test_validation_phase_success
```

### Integration Testing

```bash
# Test full workflow with specific phase
./execute_tests_docs_workflow_v2.4.sh \
  --dry-run \
  --steps 0,1,2,3,4 \
  --verbose
```

---

## Performance Considerations

### Module Loading

All orchestrators are loaded at startup (negligible overhead):
```bash
# < 10ms total loading time
for orch_file in "${ORCHESTRATORS_DIR}"/*.sh; do
    source "$orch_file"
done
```

### Execution Flow

No performance degradation from refactoring:
- Same execution path
- Same function call depth
- Same memory usage
- Measured: <1ms difference in total runtime

### Optimization Opportunities

**Current**:
- Parallel validation: 33% faster (Steps 1-4)
- Smart execution: 40-85% faster (depending on changes)

**Future**:
- Parallel testing (Steps 5-7)
- Parallel quality checks (Steps 8-9)
- Estimated additional 20-30% improvement

---

## Migration from v2.3.0

### For Script Users

**No changes required** ✅
- Rename `execute_tests_docs_workflow_v2.4.sh` to `execute_tests_docs_workflow.sh`
- Or update aliases/scripts to use new filename
- All options work identically

### For Developers

**Old way** (v2.3.0):
```bash
# Edit 5,294-line file
vim execute_tests_docs_workflow.sh
# Find validation logic (line 1,267-1,887)
# Make changes
# Risk: break unrelated functionality
```

**New way** (v2.4.0):
```bash
# Edit focused orchestrator
vim orchestrators/validation_orchestrator.sh
# All validation logic in 228 lines
# Make changes
# Lower risk: isolated module
```

---

## Troubleshooting

### Orchestrator Not Found

**Symptom**: `command not found: execute_validation_phase`

**Solution**:
```bash
# Ensure orchestrators directory exists
ls orchestrators/

# Check sourcing in main script
grep "source.*orchestrators" execute_tests_docs_workflow_v2.4.sh

# Verify orchestrator is executable
chmod +x orchestrators/*.sh
```

### Phase Execution Failed

**Symptom**: "Validation phase failed"

**Debug**:
```bash
# Run with verbose mode
./execute_tests_docs_workflow_v2.4.sh --verbose --steps 0,1,2,3,4

# Check orchestrator directly
bash -x orchestrators/validation_orchestrator.sh

# Review workflow log
cat logs/workflow_*/workflow_execution.log
```

### Function Not Found

**Symptom**: `command not found: step1_update_documentation`

**Solution**:
```bash
# Ensure step modules are sourced
ls steps/step_01_documentation.sh

# Check sourcing order in main script
# Libraries must be sourced before orchestrators
```

---

## Best Practices

### Orchestrator Development

1. **Keep orchestrators focused** (< 250 lines)
2. **One phase per orchestrator**
3. **Clear function naming**: `execute_<phase>_phase()`
4. **Consistent error handling**:
   ```bash
   if ! step_function; then
       print_error "Step failed"
       return 1
   fi
   ```
5. **Comprehensive logging**:
   ```bash
   log_to_workflow "INFO" "Starting phase X"
   ```

### Integration

1. **Test orchestrator independently** before integration
2. **Verify all dependencies** (libraries, steps)
3. **Update documentation** with new orchestrators
4. **Maintain backward compatibility** when possible

### Performance

1. **Avoid redundant work** in orchestrators
2. **Leverage existing optimizations** (smart execution, parallel)
3. **Profile execution time** before/after changes
4. **Document performance impact**

---

## Reference

### Files Overview

| File | Lines | Purpose |
|------|-------|---------|
| `execute_tests_docs_workflow_v2.4.sh` | 479 | Main coordinator |
| `orchestrators/pre_flight.sh` | 227 | Initialization |
| `orchestrators/validation_orchestrator.sh` | 228 | Steps 0-4 |
| `orchestrators/test_orchestrator.sh` | 111 | Steps 5-7 |
| `orchestrators/quality_orchestrator.sh` | 82 | Steps 8-9 |
| `orchestrators/finalization_orchestrator.sh` | 93 | Steps 10-12 |

### Function Index

```
Main Coordinator:
├── main()
├── parse_arguments()
├── execute_full_workflow()
└── show_workflow_summary()

Pre-Flight:
├── execute_preflight()
├── check_prerequisites()
├── validate_dependencies()
└── validate_project_structure()

Validation:
├── execute_validation_phase()
├── execute_validation_steps()
└── execute_parallel_validation()

Test:
└── execute_test_phase()

Quality:
└── execute_quality_phase()

Finalization:
└── execute_finalization_phase()
```

---

## Next Steps

After familiarizing yourself with the orchestrator architecture:

1. **Review existing orchestrators** to understand patterns
2. **Run workflow with `--verbose`** to see execution flow
3. **Try modifying a simple orchestrator** (e.g., add logging)
4. **Test your changes** in isolation and integration
5. **Contribute improvements** following best practices

For questions or contributions, see `/docs/CONTRIBUTING.md`.

---

**Document Version**: 1.0  
**Architecture Version**: 2.4.0  
**Last Updated**: 2025-12-18
