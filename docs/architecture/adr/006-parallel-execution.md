# ADR-006: Parallel Step Execution

**Status**: Accepted  
**Date**: 2025-12-18  
**Deciders**: Project maintainers  
**Related**: ADR-004, ADR-005

## Context

The workflow executed all steps sequentially:
- Step N+1 waits for Step N to complete
- Many steps are independent (no shared state)
- CPU cores underutilized
- Total execution time = sum of all step times

Example sequential execution:
```
Step 1 (5min) → Step 3 (3min) → Step 4 (2min) = 10 minutes total
```

But Steps 1, 3, and 4 don't depend on each other.

## Decision

Implement parallel execution for independent steps:

**Key Features**:
- Dependency graph analysis
- Parallel execution groups
- Background process management
- Synchronized completion
- Error handling across processes

### Dependency Groups

Analyzed step dependencies and created parallel groups:

**Group 1** (Independent, run in parallel):
- Step 1: Documentation
- Step 3: Script refs
- Step 4: Directory
- Step 5: Test review
- Step 8: Dependencies
- Step 13: Prompt engineering
- Step 14: UX analysis

**Group 2** (Depends on Group 1):
- Step 6: Test generation
- Step 7: Test execution

**Group 3** (Depends on all previous):
- Step 9: Code quality
- Step 10: Context
- Step 11: Git operations
- Step 12: Markdown lint

### Execution Strategy

```bash
# Pseudo-code
# Group 1: Parallel
step_1 & pid1=$!
step_3 & pid3=$!
step_4 & pid4=$!
wait $pid1 $pid3 $pid4

# Group 2: Parallel (after Group 1)
step_6 & pid6=$!
step_7 & pid7=$!
wait $pid6 $pid7

# Group 3: Sequential
step_9
step_10
```

## Consequences

### Positive

✅ **Performance**
- 33% faster execution on average
- Group 1: 7 steps in ~5 minutes (instead of 15+ minutes)
- CPU utilization increased from ~25% to ~80%

✅ **Scalability**
- More CPU cores = better performance
- Naturally leverages modern hardware
- Graceful degradation on single-core systems

✅ **Combines with Optimizations**
- Smart execution + parallel: 57% faster
- Caching + parallel: 65% faster
- All three: 90% faster

### Negative

⚠️ **Complexity**
- Process management required
- Error handling across processes
- Debugging more difficult

⚠️ **Resource Usage**
- Higher memory usage (multiple processes)
- More disk I/O (concurrent operations)
- Potential rate limiting (parallel AI calls)

⚠️ **Output Interleaving**
- Console output from multiple steps mixed
- Log files help but real-time monitoring harder
- Mitigated with per-step log files

### Neutral

ℹ️ **Configuration**
- Opt-in with `--parallel` flag
- Dependency graph documented
- Can combine with `--smart-execution`

## Implementation

### Dependency Graph

Created `dependency_graph.sh` module:
- Analyzes step dependencies
- Generates execution groups
- Validates graph correctness
- Visualizes with Mermaid diagrams

### Process Management

Used bash background processes:
```bash
# Start parallel steps
step_1 & pid1=$!
step_3 & pid3=$!

# Wait for completion
wait $pid1 || exit_code1=$?
wait $pid3 || exit_code3=$?

# Check for failures
if [[ ${exit_code1} -ne 0 || ${exit_code3} -ne 0 ]]; then
    echo "Parallel execution failed"
    exit 1
fi
```

### Safety Measures

- File locking for shared resources
- Atomic operations for critical paths
- Error propagation from background processes
- Graceful degradation if parallelization fails

## Alternatives Considered

### Alternative 1: GNU Parallel
- **Pros**: Battle-tested, robust
- **Cons**: External dependency, less control
- **Rejected**: Wanted no external dependencies

### Alternative 2: Make-style Parallelism
- **Pros**: Proven pattern
- **Cons**: Makefile complexity, less shell-native
- **Rejected**: Bash background processes sufficient

### Alternative 3: Always Parallel
- **Pros**: Maximum performance
- **Cons**: Risks if dependencies wrong
- **Rejected**: Opt-in safer, allows sequential debugging

## Measurements

**Sequential Execution**:
- All 15 steps: 23 minutes

**Parallel Execution**:
- Group 1 (7 steps): ~5 minutes (was 15 minutes sequentially)
- Total workflow: ~15.5 minutes (33% faster)

**Combined Optimizations**:
- Smart + Parallel: ~10 minutes (57% faster for code changes)
- Smart + Parallel + Caching: ~2.3 minutes (90% faster for docs)

## Dependencies

Steps must complete in order if:
1. **Data Dependency**: Step N uses output from Step M
2. **State Dependency**: Step N modifies shared state used by Step M
3. **Resource Dependency**: Both need exclusive access to resource

Example dependencies:
- Step 6 (test generation) depends on Step 5 (test review)
- Step 7 (test execution) depends on Step 6 (test generation)
- Step 11 (git operations) depends on all previous steps

## Related Decisions

- **ADR-004**: AI caching (independent optimization)
- **ADR-005**: Smart execution (combines effectively)

## References

- `src/workflow/lib/dependency_graph.sh` (implementation)
- `src/workflow/lib/workflow_optimization.sh`
- [`PERFORMANCE_BENCHMARKS.md`](../../reference/performance-benchmarks.md)

---

**Outcome**: Successfully implemented in v2.3.0. Achieved 33% average speedup, combines with smart execution for 90% total improvement.
