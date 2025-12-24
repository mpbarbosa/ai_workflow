# ADR-001: Adopt Modular Architecture

**Status**: Accepted  
**Date**: 2025-12-14  
**Deciders**: Project maintainers  
**Related**: ADR-002, ADR-003

## Context

The original workflow system (v1.x) was a monolithic script of ~2,500 lines with:
- All functionality in a single file
- Difficult to maintain and test
- Hard to understand and contribute to
- No code reusability
- Testing required running the entire workflow

The system was becoming increasingly complex with:
- 14+ workflow steps (now 15)
- AI integration with multiple personas
- Performance optimization features
- Configuration management
- Metrics collection

## Decision

We decided to adopt a **modular architecture** with the following structure:

### Module Organization

```
src/workflow/
├── execute_tests_docs_workflow.sh  # Main orchestrator (2,009 lines)
├── lib/                            # 28 library modules (12,671 lines)
│   ├── ai_helpers.sh               # AI integration
│   ├── change_detection.sh         # Change analysis
│   ├── workflow_optimization.sh    # Optimization features
│   └── ... (25 more modules)
├── steps/                          # 15 step modules (3,786 lines)
│   ├── step_00_analyze.sh
│   ├── step_01_documentation.sh
│   └── ... (13 more steps)
└── config/                         # YAML configuration
    ├── paths.yaml
    ├── project_kinds.yaml
    └── ...
```

### Design Principles

1. **Single Responsibility**: Each module has one clear purpose
2. **Functional Core**: Pure functions in library modules
3. **Separation of Concerns**: Steps, libraries, config separated
4. **Testability**: Individual modules can be tested in isolation
5. **Composability**: Modules can be combined and reused

### Module Categories

- **Library Modules** (28): Reusable functions (ai_helpers.sh, utils.sh, etc.)
- **Step Modules** (15): Workflow step implementations
- **Configuration** (6 YAML files): Externalized configuration
- **Orchestrator** (1): Main coordination script

## Consequences

### Positive

✅ **Maintainability**
- Each module is ~200-500 lines (manageable size)
- Clear responsibility boundaries
- Easy to locate specific functionality

✅ **Testability**
- 37 test files covering 100% of modules
- Can test individual functions
- Faster test execution

✅ **Reusability**
- Functions can be sourced by other scripts
- Common utilities shared across steps
- Library modules used by multiple steps

✅ **Collaboration**
- Multiple contributors can work simultaneously
- Clear ownership boundaries
- Easier code review

✅ **Documentation**
- Each module documented independently
- API documentation for library functions
- Clear module inventory

### Negative

⚠️ **Complexity**
- More files to manage (49 total)
- Requires understanding module relationships
- Module loading order matters

⚠️ **Initial Learning Curve**
- New contributors need to understand architecture
- Module organization must be learned
- Dependency relationships not immediately obvious

⚠️ **Performance Overhead**
- Slight overhead from sourcing multiple files
- Mitigated by caching and lazy loading
- Negligible in practice (<100ms total)

### Neutral

ℹ️ **Migration Required**
- Existing v1.x users need to understand new structure
- Migration guide provided
- Backward compatibility maintained where possible

## Implementation

### Phase 1: Core Modularization (v2.0.0)
- Extract utility functions to `utils.sh`
- Create separate step modules
- Maintain basic library structure

### Phase 2: Library Expansion (v2.1.0)
- Expand to 20+ library modules
- Implement dependency management
- Add configuration modules

### Phase 3: Optimization Modules (v2.3.0)
- Add optimization-specific modules
- Implement caching and change detection
- Complete modularization to 28 modules

## Alternatives Considered

### Alternative 1: Keep Monolithic Structure
- **Pros**: Simple, no migration needed
- **Cons**: Unmaintainable at current scale (would be 10,000+ lines)
- **Rejected**: Not sustainable for project growth

### Alternative 2: Microservices Architecture
- **Pros**: Maximum isolation, language flexibility
- **Cons**: Over-engineering, complex deployment, performance overhead
- **Rejected**: Too complex for shell script workflow

### Alternative 3: Plugin Architecture
- **Pros**: Maximum extensibility
- **Cons**: Complex plugin API, version compatibility issues
- **Deferred**: May be considered in v3.0

## Related Decisions

- **ADR-002**: Externalize configuration to YAML (complements modularization)
- **ADR-003**: Split orchestrator into sub-modules (further refinement)

## References

- [`WORKFLOW_MODULARIZATION_PHASE1.md`](../../archive/WORKFLOW_MODULARIZATION_COMPLETE.md)
- [`WORKFLOW_MODULE_INVENTORY.md`](../../archive/WORKFLOW_MODULARIZATION_COMPLETE.md)
- [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle)

---

**Outcome**: Successfully implemented in v2.0.0. System now has 28 library modules with 100% test coverage and significantly improved maintainability.
