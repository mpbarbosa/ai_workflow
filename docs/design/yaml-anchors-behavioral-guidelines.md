# Functional Requirements: YAML Anchors for Behavioral Guidelines

**Feature ID**: FRQ-2024-001  
**Version**: 1.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft

## Executive Summary

Implement YAML anchors and aliases to deduplicate common behavioral guidelines across AI personas, reducing token usage by 120-180 tokens per workflow execution while improving maintainability and consistency.

## Problem Statement

### Current State

The AI prompt configuration in `src/workflow/lib/ai_helpers.yaml` contains duplicated behavioral guidelines across multiple personas:

1. **doc_analysis_prompt** (lines 8-18): 9 lines of guidelines
2. **consistency_prompt** (lines 76-84): 8 lines of guidelines  
3. **test_strategy_prompt**: Similar patterns

**Issues**:
- **Token Inefficiency**: 40-60 tokens repeated per persona (120-180 tokens total)
- **Maintenance Burden**: Changes require updates in multiple locations
- **Inconsistency Risk**: Guidelines can drift out of sync
- **Violation of DRY Principle**: Same content repeated verbatim

### Desired State

Single source of truth for common behavioral guidelines using YAML anchors, reducing duplication while maintaining readability and allowing persona-specific customizations.

## Functional Requirements

### FR-1: YAML Anchor Definition
**Priority**: High  
**Requirement**: Define reusable YAML anchors for common behavioral guidelines at the top of `ai_helpers.yaml`

**Acceptance Criteria**:
- Anchor defined before first persona definition
- Named with descriptive prefix (e.g., `_behavioral_guidelines_*`)
- Contains core guidelines common to all documentation-focused personas
- Uses consistent formatting and terminology

**Example**:
```yaml
# Reusable behavioral guidelines anchors
_behavioral_guidelines_actionable: &actionable_guidelines |
  **Critical Behavioral Guidelines**:
  - ALWAYS provide concrete, actionable output (never ask clarifying questions)
  - Make informed decisions based on available context
  - If no changes needed, explicitly state "No updates needed - documentation is current"
  - Default to "no changes" rather than making unnecessary modifications

_behavioral_guidelines_structured: &structured_guidelines |
  - Provide structured, prioritized analysis (never general observations)
  - Identify specific files, line numbers, and exact issues
  - Include concrete recommended fixes for each problem
  - Prioritize issues by severity and impact on user experience
```

### FR-2: Persona Integration
**Priority**: High  
**Requirement**: Update existing personas to reference YAML anchors while preserving functionality

**Acceptance Criteria**:
- `doc_analysis_prompt` references appropriate anchor
- `consistency_prompt` references appropriate anchor
- Persona-specific guidelines remain in-line
- No functional changes to prompt generation
- Original behavior maintained

**Example**:
```yaml
doc_analysis_prompt:
  role: |
    You are a senior technical documentation specialist with expertise in software 
    architecture documentation, API documentation, and developer experience (DX) optimization.
    
    <<: *actionable_guidelines
    
    **Additional Guidelines**:
    - Only update what is truly outdated or incorrect
    - Focus on accuracy over completeness
```

### FR-3: YAML Parser Compatibility
**Priority**: Critical  
**Requirement**: Ensure YAML anchor implementation works with existing parser

**Acceptance Criteria**:
- `yq` tool successfully parses YAML with anchors
- `parse_yaml()` function in workflow extracts correct values
- No parsing errors or warnings
- Anchor resolution happens transparently

**Testing Commands**:
```bash
# Test YAML validity
yq eval '.doc_analysis_prompt.role' src/workflow/lib/ai_helpers.yaml

# Test anchor resolution
yq eval '._behavioral_guidelines_actionable' src/workflow/lib/ai_helpers.yaml
```

### FR-4: Backward Compatibility
**Priority**: Critical  
**Requirement**: Maintain 100% backward compatibility with existing prompt generation

**Acceptance Criteria**:
- All existing personas generate identical prompts
- No changes to `ai_helpers.sh` functions required
- Step 1, 2, 5, 6 continue to function normally
- Tests pass without modification

**Validation**:
- Run workflow steps and compare prompts before/after
- Token count remains same or decreases
- Prompt content is semantically identical

### FR-5: Documentation Updates
**Priority**: Medium  
**Requirement**: Document the YAML anchor pattern for future contributors

**Acceptance Criteria**:
- Comment at top of `ai_helpers.yaml` explains anchor usage
- Architecture Decision Record (ADR) created
- README updated if applicable
- Code comments reference anchor pattern

## Non-Functional Requirements

### NFR-1: Performance
- No measurable impact on YAML parsing time (<10ms difference)
- Token reduction: 40-60 tokens per persona using anchors
- Overall token savings: 120-180 tokens per workflow execution

### NFR-2: Maintainability
- Single point of update for shared guidelines
- Clear naming convention for anchors (`_behavioral_guidelines_*`)
- Anchors defined at top of file for visibility

### NFR-3: Extensibility
- Pattern supports additional anchors for other common blocks
- Easy to add new personas referencing existing anchors
- Supports both full replacement and partial merging

## Technical Design

### YAML Anchor Syntax

```yaml
# Define anchor
_anchor_name: &anchor_alias |
  Content here
  Multiple lines supported

# Reference anchor (full replacement)
some_key: *anchor_alias

# Reference anchor (merge with additional content)
some_key: |
  <<: *anchor_alias
  Additional content specific to this key
```

### Implementation Approach

1. **Phase 1: Anchor Definition**
   - Identify common guideline blocks
   - Create anchors at top of `ai_helpers.yaml`
   - Validate YAML syntax

2. **Phase 2: Persona Migration**
   - Update `doc_analysis_prompt`
   - Update `consistency_prompt`
   - Validate prompt generation

3. **Phase 3: Testing**
   - Unit tests for YAML parsing
   - Integration tests for prompt generation
   - Comparison tests (before/after)

4. **Phase 4: Documentation**
   - Add inline comments
   - Create ADR
   - Update architecture docs

### Files to Modify

1. **`src/workflow/lib/ai_helpers.yaml`** (Primary)
   - Add anchor definitions (top of file)
   - Update persona definitions to reference anchors
   - Add explanatory comments

2. **`docs/design/adr/007-yaml-anchors-behavioral-guidelines.md`** (New)
   - Document decision to use YAML anchors
   - Explain rationale and alternatives
   - Provide usage guidelines

3. **`tests/unit/lib/test_ai_helpers.sh`** (If exists, or create)
   - Test YAML parsing with anchors
   - Validate prompt generation
   - Compare token counts

## Test Plan

### Test Case 1: YAML Parsing
**Objective**: Verify YAML anchors parse correctly

```bash
# Test anchor definition
yq eval '._behavioral_guidelines_actionable' src/workflow/lib/ai_helpers.yaml | grep -q "Critical Behavioral Guidelines"

# Test anchor resolution in persona
yq eval '.doc_analysis_prompt.role' src/workflow/lib/ai_helpers.yaml | grep -q "Critical Behavioral Guidelines"
```

**Expected Result**: Both commands succeed, content matches

### Test Case 2: Prompt Generation
**Objective**: Verify prompt generation unchanged

```bash
# Before implementation - capture baseline
source src/workflow/lib/ai_helpers.sh
get_ai_role "documentation_specialist" > /tmp/prompt_before.txt

# After implementation - capture new output
get_ai_role "documentation_specialist" > /tmp/prompt_after.txt

# Compare
diff /tmp/prompt_before.txt /tmp/prompt_after.txt
```

**Expected Result**: No differences (exit code 0)

### Test Case 3: Token Count
**Objective**: Verify token reduction in YAML file

```bash
# Count tokens in original file
wc -w src/workflow/lib/ai_helpers.yaml.backup

# Count tokens in anchored file
wc -w src/workflow/lib/ai_helpers.yaml

# Verify reduction
```

**Expected Result**: Word count reduced by ~60-100 words

### Test Case 4: Integration Test
**Objective**: Verify workflow steps execute correctly

```bash
# Run Step 1 (documentation update)
cd src/workflow
./steps/step_01_documentation.sh

# Run Step 2 (consistency check)
./steps/step_02_consistency.sh

# Verify prompt logs contain expected content
grep "Critical Behavioral Guidelines" .ai_workflow/prompts/*/step*.md
```

**Expected Result**: All steps succeed, prompts contain guidelines

### Test Case 5: Multiple Anchor References
**Objective**: Verify multiple personas can reference same anchor

```bash
# Test doc_analysis_prompt
yq eval '.doc_analysis_prompt.role' src/workflow/lib/ai_helpers.yaml | grep -q "actionable output"

# Test consistency_prompt  
yq eval '.consistency_prompt.role' src/workflow/lib/ai_helpers.yaml | grep -q "actionable output"
```

**Expected Result**: Both contain anchor content

## Success Criteria

1. ✅ YAML file valid with anchors
2. ✅ All personas generate identical prompts
3. ✅ Token count reduced by 120-180 tokens
4. ✅ No functional regressions
5. ✅ All tests pass
6. ✅ Documentation complete

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| YAML parser incompatibility | High | Low | Test with `yq` before implementation |
| Prompt generation breaks | High | Low | Comprehensive comparison testing |
| Merge syntax issues | Medium | Medium | Use simple anchor references first |
| Maintenance confusion | Low | Medium | Clear documentation and examples |

## Implementation Timeline

1. **Requirements & Design** (Current) - 30 minutes
2. **Implementation** - 45 minutes
   - Create anchors
   - Update personas
   - Validate YAML
3. **Testing** - 30 minutes
   - Parse validation
   - Prompt comparison
   - Integration tests
4. **Documentation** - 15 minutes
   - ADR creation
   - Inline comments

**Total Estimated Time**: 2 hours

## Acceptance Checklist

- [ ] Functional requirements met (FR-1 through FR-5)
- [ ] Non-functional requirements met (NFR-1 through NFR-3)
- [ ] All test cases pass
- [ ] YAML validates with yq
- [ ] Prompts unchanged functionally
- [ ] Token count reduced
- [ ] Documentation complete
- [ ] ADR created
- [ ] Code reviewed
- [ ] Backward compatible

## References

- **YAML Anchors Spec**: https://yaml.org/spec/1.2.2/#3222-anchors-and-aliases
- **Project Context**: `src/workflow/lib/ai_helpers.yaml`
- **Related Features**: AI Prompt System (Phase 4), Language-Aware Prompts
- **Version**: AI Workflow Automation v2.4.0

## Appendix A: Current Duplication Analysis

### doc_analysis_prompt (lines 8-18)
```yaml
**Critical Behavioral Guidelines**:
- ALWAYS provide concrete, actionable output (never ask clarifying questions)
- If documentation is accurate, explicitly say "No updates needed - documentation is current"
- Only update what is truly outdated or incorrect
- Make informed decisions based on available context
- Default to "no changes" rather than making unnecessary modifications
```
**Token count**: ~45 tokens

### consistency_prompt (lines 76-84)
```yaml
**Critical Behavioral Guidelines**:
- ALWAYS provide structured, prioritized analysis (never general observations)
- Identify specific files, line numbers, and exact issues
- Include concrete recommended fixes for each problem
- Prioritize issues by severity and impact on user experience
- Focus on accuracy and consistency over style preferences
- Default to "no issues found" only when documentation is truly consistent
```
**Token count**: ~48 tokens

### Commonalities
- "Critical Behavioral Guidelines" header
- Emphasis on concrete/specific output
- "Make informed decisions"
- "Default to no changes/no issues"

**Total Duplication**: ~100 tokens across 2 personas

## Appendix B: Alternative Approaches Considered

### Alternative 1: External Include File
**Pros**: Maximum reusability, separate concerns  
**Cons**: Adds file I/O, complicates parsing, not native YAML  
**Decision**: Rejected - YAML anchors are native and simpler

### Alternative 2: Runtime Template Substitution
**Pros**: Maximum flexibility, supports complex logic  
**Cons**: Requires code changes, reduces declarative nature  
**Decision**: Rejected - Over-engineered for this use case

### Alternative 3: Status Quo
**Pros**: No changes, no risk  
**Cons**: Continued duplication, maintenance burden  
**Decision**: Rejected - Benefits outweigh minimal implementation risk

---

**Document Status**: ✅ Ready for Implementation  
**Next Steps**: Proceed to implementation phase with approval
