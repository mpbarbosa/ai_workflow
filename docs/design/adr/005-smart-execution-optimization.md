# ADR-005: Smart Execution with Change Detection

**Status**: Accepted  
**Date**: 2025-12-18  
**Deciders**: Project maintainers  
**Related**: ADR-004, ADR-006

## Context

The workflow executed all 15 steps regardless of what changed:
- Documentation-only changes ran code quality checks
- Code-only changes ran documentation analysis
- 23 minutes for any change size
- Wasteful resource usage

## Decision

Implement smart execution that skips unnecessary steps based on git diff analysis:

**Key Features**:
- Git diff analysis (`change_detection.sh`)
- Change classification (docs, code, tests, config)
- Step relevance determination
- Automatic step skipping
- Impact assessment

### Change Detection Logic

```bash
# Analyze git diff
changed_files=$(git diff --name-only HEAD~1)

# Classify changes
docs_changed=$(filter_docs_files "${changed_files}")
code_changed=$(filter_code_files "${changed_files}")
tests_changed=$(filter_test_files "${changed_files}")

# Determine step relevance
if [[ -z "${code_changed}" ]]; then
    skip_step "code_quality"  # No code changes
fi
```

### Skip Strategy

| Change Type | Steps Run | Steps Skipped | Time Savings |
|-------------|-----------|---------------|--------------|
| Docs only   | 3-5       | 10-12         | 85%          |
| Code only   | 10-12     | 3-5           | 40%          |
| Full        | All 15    | 0             | 0%           |

## Consequences

### Positive

✅ **Performance**
- Documentation-only: 85% faster (23min → 3.5min)
- Code-only: 40% faster (23min → 14min)
- Combined with caching: up to 90% faster

✅ **Resource Efficiency**
- Only run necessary steps
- Reduced CPU usage
- Lower token consumption

✅ **Developer Experience**
- Faster feedback for small changes
- Encourages frequent commits
- Better CI/CD performance

✅ **Intelligent**
- Understands change impact
- Conservative when uncertain
- Configurable thresholds

### Negative

⚠️ **Complexity**
- Change detection logic required
- Edge cases to handle
- Classification rules needed

⚠️ **False Skips Risk**
- Miscategorization could skip needed steps
- Conservative approach mitigates this
- Can disable with `--no-smart-execution`

⚠️ **Git Dependency**
- Requires git repository
- Needs clean working directory
- Must have commits to compare

### Neutral

ℹ️ **Configuration**
- Opt-in with `--smart-execution` flag
- Impact thresholds configurable
- Can force full execution

## Implementation

### Change Classification

**Documentation** (`.md`, `.txt`, `.rst`):
- Documentation writing/editing
- README updates
- Guide updates

**Code** (`.sh`, `.js`, `.py`, etc.):
- Source code changes
- Library modifications
- Step implementations

**Tests** (`test_*.sh`, `*.test.js`):
- Test additions/modifications
- Test infrastructure changes

**Configuration** (`.yaml`, `.json`, `.config`):
- Configuration updates
- Settings changes

### Step Relevance Rules

Defined in `step_relevance.yaml`:
```yaml
step_09_code_quality:
  triggers:
    - code_files_changed
  skips_on:
    - only_docs_changed
    - only_config_changed
```

## Alternatives Considered

### Alternative 1: Always Run All Steps
- **Rejected**: Too slow for iterative development

### Alternative 2: Manual Step Selection
- **Pros**: User control
- **Cons**: Requires understanding of dependencies
- **Partial**: Implemented as `--steps` option

### Alternative 3: File-Based Markers
- **Pros**: No git dependency
- **Cons**: Manual management, error-prone
- **Rejected**: Git is better source of truth

## Measurements

**Before Smart Execution**:
- All changes: 23 minutes (15 steps)

**After Smart Execution**:
- Docs-only: 3.5 minutes (3-5 steps, 85% faster)
- Code-only: 14 minutes (10-12 steps, 40% faster)
- Combined with caching: 2.3 minutes (90% faster)

## Related Decisions

- **ADR-004**: AI caching (complementary optimization)
- **ADR-006**: Parallel execution (independent optimization)

## References

- `src/workflow/lib/change_detection.sh` (implementation)
- `src/workflow/lib/workflow_optimization.sh`
- [`PERFORMANCE_BENCHMARKS.md`](../../reference/performance-benchmarks.md)

---

**Outcome**: Successfully implemented in v2.3.0. Achieved 40-85% execution time reduction based on change type.
