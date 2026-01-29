# ADR 007: YAML Anchors for Behavioral Guidelines Deduplication

**Status**: Accepted  
**Date**: 2025-12-24  
**Authors**: AI Workflow Automation Team  
**Related**: [FRQ-2024-001](../yaml-anchors-behavioral-guidelines.md)

## Context

The AI prompt configuration in `.workflow_core/config/ai_helpers.yaml` contains duplicated behavioral guidelines across multiple personas. The same "Critical Behavioral Guidelines" block (~50-60 words) was repeated verbatim in:

1. `doc_analysis_prompt` - 54 words
2. `consistency_prompt` - 60 words  
3. Other potential personas - ~50 words each

**Problems**:
- **Maintenance**: Changes require updates in multiple locations
- **Consistency**: Guidelines can drift out of sync
- **Violation of DRY Principle**: Same content repeated
- **File Bloat**: Unnecessary duplication increases file size

**Token Impact**:
- Direct duplication: ~100+ words in YAML file
- Indirect maintenance burden: Risk of inconsistency

## Decision

We will use **YAML anchors and aliases** to define common behavioral guidelines once and reference them multiple times across personas.

### Implementation Approach

1. **Define Anchors** at top of `ai_helpers.yaml`:
   ```yaml
   _behavioral_actionable: &behavioral_actionable |
     **Critical Behavioral Guidelines**:
     - ALWAYS provide concrete, actionable output
     - Make informed decisions based on available context
     - Default to "no changes" rather than unnecessary modifications
   ```

2. **Split Persona Roles** into composable parts:
   ```yaml
   doc_analysis_prompt:
     role_prefix: |
       You are a senior technical documentation specialist...
     behavioral_guidelines: *behavioral_actionable
     role: |  # Legacy field for backward compatibility
       ...full role text...
   ```

3. **Add Composition Function** (`compose_role_from_yaml`):
   - Python-based YAML parser with anchor resolution
   - Composes `role_prefix + behavioral_guidelines`
   - Falls back to legacy `role` field if new fields absent
   - Maintains 100% backward compatibility

4. **Update Prompt Builders** to use new function:
   - `build_doc_analysis_prompt()` calls `compose_role_from_yaml()`
   - Falls back to legacy extraction if composition fails
   - Zero impact on existing functionality

## Alternatives Considered

### Alternative 1: External Include File
**Approach**: Store guidelines in separate `.yaml` file, include at runtime

**Pros**:
- Maximum reusability
- Clean separation of concerns

**Cons**:
- Adds file I/O complexity
- Non-standard YAML pattern
- Requires custom include mechanism

**Decision**: Rejected - YAML anchors are native and simpler

### Alternative 2: Runtime Template Substitution
**Approach**: Use placeholder syntax (`{{guidelines}}`) replaced at runtime

**Pros**:
- Maximum flexibility
- Supports complex logic

**Cons**:
- Requires significant code changes
- Reduces declarative nature of YAML
- Over-engineered for this use case

**Decision**: Rejected - Too complex for marginal benefit

### Alternative 3: Accept Duplication
**Approach**: Keep current duplication, document guidelines separately

**Pros**:
- No changes required
- No risk

**Cons**:
- Continued maintenance burden
- Risk of inconsistency
- Misses opportunity for improvement

**Decision**: Rejected - Benefits of anchors outweigh minimal implementation cost

### Alternative 4: Change Code to Send Separate Guidelines
**Approach**: Modify prompt builders to send `role` + `guidelines` as separate parameters

**Pros**:
- Clean separation in code
- Easy to modify guidelines independently

**Cons**:
- Breaking change to existing code
- Requires updates to all prompt callers
- More invasive than YAML-only solution

**Decision**: Rejected - YAML anchors provide same benefit without code changes

## Consequences

### Positive

1. **Single Source of Truth**: Guidelines defined once, referenced multiple times
2. **Easier Maintenance**: Update one anchor, applies to all personas
3. **Consistency Guaranteed**: Anchors ensure identical wording
4. **Backward Compatible**: Legacy `role` field preserved during transition
5. **File Size Reduction**: Potential ~200 char savings (once legacy fields removed)
6. **Extensibility**: Pattern supports additional anchors for other common blocks

### Negative

1. **Slight Complexity Increase**: Added `compose_role_from_yaml()` function (~70 lines)
2. **Python Dependency**: Composition function requires Python 3 (already a project dependency)
3. **Two-Phase Approach**: Keeping legacy fields temporarily increases file size initially
4. **Learning Curve**: Contributors need to understand YAML anchor syntax

### Neutral

1. **No Token Savings in Prompts**: AI receives same role text (by design - backward compatible)
2. **File Size Initially Larger**: Legacy fields add overhead during transition
3. **Testing Required**: Need to verify anchor resolution works correctly

## Implementation

### Files Modified

1. **`.workflow_core/config/ai_helpers.yaml`**:
   - Added anchor definitions (`_behavioral_actionable`, `_behavioral_structured`)
   - Split personas into `role_prefix` + `behavioral_guidelines` + `role` (legacy)
   - Updated version to 3.1.0

2. **`src/workflow/lib/ai_helpers.sh`**:
   - Added `compose_role_from_yaml()` function
   - Updated `build_doc_analysis_prompt()` to use composition
   - Exported new function
   - Maintained backward compatibility with fallbacks

### Testing

- ✅ YAML validity: Parses correctly with Python `yaml.safe_load()`
- ✅ Anchor resolution: Aliases resolve to correct content
- ✅ Role composition: `compose_role_from_yaml()` produces expected output
- ✅ Backward compatibility: Legacy extraction still works
- ✅ Integration: Prompt building functions work unchanged
- ✅ Functional equivalence: New method produces same prompts as old method

### Migration Path

**Phase 1** (Current): Dual format support
- New: `role_prefix` + `behavioral_guidelines` (anchored)
- Legacy: `role` field (full text)
- Both present for backward compatibility

**Phase 2** (Future): Deprecate legacy format
- Monitor usage for one release cycle
- Verify no fallbacks to legacy extraction
- Remove `role` fields, keep only anchored format
- Realize full file size savings (~200 chars)

### Deprecation Plan

After one stable release (v2.4.1 or v2.5.0):
1. Verify `compose_role_from_yaml()` is always used
2. Remove legacy `role` fields from personas
3. Remove fallback extraction in prompt builders
4. Update documentation to use only new format

## Lessons Learned

1. **YAML Anchors Limitation**: Cannot embed anchors mid-string, only replace entire values
2. **Python is Better for YAML**: Shell-based YAML parsing doesn't handle anchors well
3. **Backward Compatibility is Critical**: Dual format approach prevented breaking changes
4. **File Size != Token Savings**: Implementation focused on maintainability over raw token count
5. **Test Early**: Python test script caught anchor resolution issues before integration

## Related Documents

- **Functional Requirements**: [docs/design/yaml-anchors-behavioral-guidelines.md](../yaml-anchors-behavioral-guidelines.md)
- **YAML Spec**: [YAML 1.2 Anchors and Aliases](https://yaml.org/spec/1.2.2/#3222-anchors-and-aliases)
- **Implementation PR**: (Link to PR when created)

## Acceptance Criteria

- [x] YAML file valid with anchors
- [x] All personas generate identical prompts
- [x] No functional regressions
- [x] All tests pass
- [x] Documentation complete
- [x] Backward compatible
- [x] Function exported and tested
- [x] Integration test passed

## References

- **YAML 1.2 Specification**: https://yaml.org/spec/1.2.2/
- **Python yaml Module**: https://pyyaml.org/wiki/PyYAMLDocumentation
- **AI Helpers Module**: `src/workflow/lib/ai_helpers.sh`
- **Prompt Configuration**: `.workflow_core/config/ai_helpers.yaml`

---

**Status**: ✅ Implemented and Tested  
**Next Review**: After v2.4.1 release (remove legacy `role` fields)
