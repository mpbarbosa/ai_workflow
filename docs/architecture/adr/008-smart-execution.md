# ADR-008: Change-Based Smart Execution

**Status**: Accepted  
**Date**: 2025-12-22  
**Author**: Marcelo Pereira Barbosa

## Context

The workflow automation pipeline consists of 20 steps that take approximately 23 minutes to complete. However, not all steps are necessary for every type of change:

- **Documentation-only changes**: Steps 5-7 (testing) are unnecessary
- **Code-only changes**: Step 1 (documentation) might be skipped
- **Configuration changes**: Only specific validation steps needed

Running the full pipeline for small changes resulted in:
1. **Wasted Developer Time**: 20+ minutes for a typo fix
2. **Wasted CI Resources**: Unnecessary compute costs
3. **Slower Feedback Loops**: Delayed PR reviews
4. **Developer Frustration**: Long waits for simple changes

The team needed an intelligent system that could automatically skip unnecessary steps based on change type while maintaining workflow integrity.

## Decision

Implement **Smart Execution** that analyzes Git changes and automatically skips unnecessary steps:

1. **Change Detection Module** (`change_detection.sh`):
   - Analyzes `git diff` to categorize changes
   - Classifies as: docs_only, code_only, tests_only, config_only, or full_changes
   - Detects file types, directories, and impact scope

2. **Skip Logic** (in `workflow_optimization.sh`):
   - Documentation-only: Skip steps 5-7 (testing pipeline)
   - Code-only: May skip step 1 (documentation updates)
   - Test-only: Skip documentation and code quality steps
   - Full changes: Run all steps

3. **CLI Integration**:
   ```bash
   ./execute_tests_docs_workflow.sh --smart-execution
   ```

4. **Override Capability**:
   - Manual override with `--no-smart-execution`
   - Force specific steps with `--steps`

## Rationale

**Performance data from testing:**

| Change Type | Baseline | Smart Execution | Time Saved |
|-------------|----------|-----------------|------------|
| Documentation Only | 23 min | 3.5 min | 85% faster |
| Code Changes | 23 min | 14 min | 40% faster |
| Test Changes | 23 min | 10 min | 57% faster |
| Full Changes | 23 min | 23 min | 0% (all steps needed) |

**Key benefits:**
1. **Dramatic Time Savings**: Up to 85% faster for common changes
2. **Maintains Safety**: Never skips critical validation
3. **Zero Configuration**: Works automatically
4. **Easy Override**: Manual control when needed
5. **CI/CD Optimization**: Reduces compute costs significantly

## Consequences

### Positive
- **Developer Productivity**: Faster feedback loops (3.5 min vs 23 min for docs)
- **CI Cost Reduction**: 40-85% reduction in compute time
- **Better UX**: Instant feedback for simple changes
- **Reduced Friction**: Encourages more frequent documentation updates
- **Energy Efficiency**: Lower carbon footprint from reduced compute

### Negative
- **Complexity**: Additional logic to maintain
- **Edge Cases**: Some changes might be misclassified
- **Testing Overhead**: Must test skip logic thoroughly
- **False Confidence**: Risk of skipping steps that should run

### Neutral
- **Change Detection Logic**: Requires ongoing refinement
- **Override Usage**: Developers must know when to override
- **Logging Requirements**: Must log skip decisions clearly
- **Metrics Collection**: Track skip effectiveness over time

## Alternatives Considered

### Alternative 1: Manual Step Selection
- **Description**: Require developers to specify which steps to run
- **Pros**: 
  - Complete control
  - No misclassification risk
  - Simple implementation
- **Cons**: 
  - Requires developer knowledge of workflow
  - Error-prone (forgetting critical steps)
  - Poor developer experience
  - No automation benefits
- **Why not chosen**: Defeats purpose of automation; prone to human error

### Alternative 2: Configuration Files
- **Description**: Create `.workflow-skip.yaml` files to specify skip logic
- **Pros**: 
  - Explicit and auditable
  - Per-project customization
  - No ambiguity
- **Cons**: 
  - Additional configuration overhead
  - Requires maintenance
  - Not automatic
  - Friction for new projects
- **Why not chosen**: Adds complexity without significant benefit

### Alternative 3: AI-Based Skip Prediction
- **Description**: Use AI to analyze changes and recommend skips
- **Pros**: 
  - Could handle complex cases
  - Learns over time
  - Very intelligent
- **Cons**: 
  - Overkill for deterministic problem
  - Slower (AI inference time)
  - Less predictable
  - Requires training data
- **Why not chosen**: Over-engineering; rule-based approach is sufficient

### Alternative 4: No Optimization
- **Description**: Always run all steps
- **Pros**: 
  - Simple
  - No skip logic bugs
  - Complete validation always
- **Cons**: 
  - Wastes time and resources
  - Poor developer experience
  - Higher CI costs
- **Why not chosen**: Unacceptable performance for simple changes

## Implementation Notes

### Change Detection Algorithm
```bash
analyze_changes() {
    local changed_files=$(git diff --name-only HEAD)
    
    # Classify by file patterns
    local has_code=false
    local has_docs=false
    local has_tests=false
    
    # Determine change type
    # Return: docs_only, code_only, tests_only, full_changes
}
```

### Skip Decision Matrix
| Change Type | Steps to Skip | Steps to Run |
|-------------|---------------|--------------|
| docs_only | 5, 6, 7 | 0-4, 8-15 |
| code_only | (conditional) | All except conditionally 1 |
| tests_only | 1, 2, 3, 9 | 0, 4, 5, 6, 7, 8, 10-15 |
| full_changes | none | All |

### Logging
```bash
print_info "Smart execution enabled"
print_info "Change type detected: docs_only"
print_info "Skipping steps: 5, 6, 7 (testing pipeline)"
```

### Metrics Tracking
- Track skip decisions
- Measure time savings
- Monitor false skips (steps that should have run)
- Analyze pattern effectiveness

### Testing Requirements
- Unit tests for change detection logic
- Integration tests for each change type
- Edge case testing (mixed changes)
- Override functionality testing

## References

- Related ADRs: 
  - [ADR-009: Fork-Join Parallel Execution](./009-parallel-execution.md)
  - [ADR-010: ML-Based Workflow Optimization](./010-ml-optimization.md)
  - [ADR-017: Comprehensive Metrics Collection](./017-metrics-collection.md)
- Documentation:
  - [change_detection.sh API](../../api/LIBRARY_MODULES_COMPLETE_API.md#change_detectionsh)
  - [workflow_optimization.sh API](../../api/LIBRARY_MODULES_COMPLETE_API.md#workflow_optimizationsh)
  - [Performance Guide](../../guides/PERFORMANCE_TUNING.md)
- Implementation:
  - `src/workflow/lib/change_detection.sh`
  - `src/workflow/lib/workflow_optimization.sh`
- Metrics Data: `.ml_data/metrics/history.jsonl`

## Review History

| Date | Reviewer | Decision | Notes |
|------|----------|----------|-------|
| 2025-12-22 | Core Team | Approved | After prototype showing 85% improvement |
| 2025-12-23 | QA Team | Approved | Testing strategy validated |
| 2026-01-15 | Core Team | Reaffirmed | No false skips detected in 4 weeks |
| 2026-02-08 | Documentation Review | Approved | Historical record created |
