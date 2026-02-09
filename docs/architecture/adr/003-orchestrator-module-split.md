# ADR-003: Split Orchestrator into Sub-modules

**Status**: Accepted  
**Date**: 2025-12-20  
**Deciders**: Project maintainers  
**Related**: ADR-001

## Context

The main orchestrator (`execute_tests_docs_workflow.sh`) grew to 2,009 lines with:
- Pre-flight checks
- Argument parsing
- Step execution coordination
- Quality checks
- Finalization logic
- All in a single file

This violated the Single Responsibility Principle and made testing difficult.

## Decision

Split orchestrator into focused sub-modules:

```
src/workflow/orchestrators/
├── pre_flight.sh       # Pre-flight checks (140 lines)
├── validation.sh       # Input validation (180 lines)
├── quality.sh          # Quality checks (160 lines)
└── finalization.sh     # Cleanup and finalization (150 lines)
```

**Total**: 630 lines extracted from main orchestrator

### Module Responsibilities

**pre_flight.sh**: System checks, prerequisites, environment setup  
**validation.sh**: Argument validation, configuration checks  
**quality.sh**: Post-execution quality checks, metrics validation  
**finalization.sh**: Cleanup, summary generation, exit handling

## Consequences

### Positive

✅ **Improved Testability**
- Each orchestrator module testable independently
- Clearer test boundaries
- Easier to mock dependencies

✅ **Better Organization**
- Main orchestrator focuses on coordination
- Supporting logic in dedicated modules
- Easier to locate specific functionality

✅ **Maintainability**
- Main orchestrator reduced from 2,009 to ~1,400 lines
- Each sub-module focused and manageable
- Clear separation of concerns

### Negative

⚠️ **More Files**
- 4 additional files to manage
- Module loading order matters
- Slight complexity increase

### Neutral

ℹ️ **Refactoring Required**
- Move functions to appropriate modules
- Update function calls
- Maintain backward compatibility

## Implementation

Extracted orchestration logic into 4 focused modules while keeping main orchestrator as coordinator.

## Alternatives Considered

### Alternative 1: Keep Single File
- **Rejected**: Would continue growing, already at 2,009 lines

### Alternative 2: More Granular Split
- **Considered**: Could split further (10+ modules)
- **Deferred**: Current split sufficient, can refine later

## Related Decisions

- **ADR-001**: Modular architecture (continues this pattern)

## References

- [`ORCHESTRATOR_ARCHITECTURE.md`](../../developer-guide/architecture.md)

---

**Outcome**: Successfully implemented in v2.4.0. Orchestrator reduced by 630 lines with improved organization.
