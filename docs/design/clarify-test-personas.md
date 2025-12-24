# Functional Requirements: Clarify Test Persona Roles

**Feature ID**: FRQ-2024-004  
**Version**: 1.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft  
**Priority**: Medium  
**Category**: Clarity / TokenEfficiency

## Executive Summary

Clarify the distinction between `test_strategy_prompt` and `step5_test_review_prompt`, which currently have overlapping responsibilities. Recommended approach: **Enhance roles** to make purposes distinct rather than merge, as both are actively used in different contexts.

## Problem Statement

### Current State

Two test-related personas exist with unclear distinction:

1. **test_strategy_prompt**:
   - Role: "QA engineer and test automation specialist"
   - Focus: Coverage analysis, test recommendations
   - Task: Simple, generic (390 chars, 56 words)
   - Usage: 11 files (higher usage)
   - Context: Generic test strategy

2. **step5_test_review_prompt**:
   - Role: "senior QA engineer and test automation specialist"
   - Focus: Comprehensive test review, coverage, quality, generation
   - Task: Detailed, workflow-integrated (2350 chars, 283 words)
   - Usage: 7 files
   - Context: Workflow Step 5 specific

**Issues**:
- **Unclear Distinction**: Both described as "test automation specialist"
- **Role Overlap**: Both analyze coverage and test quality
- **Redundancy**: Similar expertise claims
- **Confusion**: Developers unsure which to use when

### Current Usage Patterns

After analysis:
- `test_strategy_prompt`: Used in 11 files, simpler generic analysis
- `step5_test_review_prompt`: Used in 7 files, comprehensive workflow step

**Key Finding**: Both are actively used, suggesting they serve different purposes despite unclear documentation.

### Desired State

**Recommended Approach**: Clarify roles rather than merge

**Rationale**:
1. Both are actively used (11 vs 7 files)
2. `test_strategy_prompt` is simpler, suitable for quick analysis
3. `step5_test_review_prompt` is comprehensive, suitable for workflow steps
4. Different use cases warrant different prompts

**Clarified Roles**:
```yaml
test_strategy_prompt:
  role: "You are a test strategy architect specializing in coverage analysis and test planning. Focus on high-level strategy and identifying coverage gaps."

step5_test_review_prompt:
  role: "You are a hands-on test engineer focused on reviewing existing test code quality, writing new test cases, and implementing testing best practices."
```

## Functional Requirements

### FR-1: Clarify test_strategy_prompt Role
**Priority**: High  
**Requirement**: Update role to emphasize high-level strategy focus

**Acceptance Criteria**:
- Role clearly indicates "strategy architect" or "test strategist"
- Emphasis on "high-level", "planning", "coverage analysis"
- Distinct from hands-on test writing
- No overlap with step5_test_review_prompt responsibilities

**New Role**:
```yaml
test_strategy_prompt:
  role: "You are a test strategy architect specializing in coverage analysis and test planning. Your focus is on high-level strategy, identifying coverage gaps, and recommending test priorities rather than writing specific test cases."
```

### FR-2: Clarify step5_test_review_prompt Role
**Priority**: High  
**Requirement**: Update role to emphasize hands-on implementation focus

**Acceptance Criteria**:
- Role clearly indicates "hands-on engineer" or "implementer"
- Emphasis on "code review", "test writing", "quality assessment"
- Distinct from strategic planning
- Clear workflow integration context

**New Role**:
```yaml
step5_test_review_prompt:
  role: "You are a hands-on test engineer and code quality specialist focused on reviewing existing test implementations, writing new test cases, assessing test code quality, and ensuring testing best practices are followed."
```

### FR-3: Update Task Templates for Clarity
**Priority**: Medium  
**Requirement**: Ensure task templates reinforce the role distinctions

**Acceptance Criteria**:
- `test_strategy_prompt` tasks focus on analysis and recommendations
- `step5_test_review_prompt` tasks focus on review and implementation
- No conflicting instructions between the two

### FR-4: Document Usage Guidelines
**Priority**: Medium  
**Requirement**: Add inline comments explaining when to use each prompt

**Acceptance Criteria**:
- Comments before each prompt definition
- Clear use case descriptions
- Examples of appropriate usage

**Example**:
```yaml
# Test Strategy Prompt - High-level analysis and planning
# Use for: Coverage gap analysis, test prioritization, strategic recommendations
# NOT for: Reviewing specific test code, writing test cases
test_strategy_prompt:
  role: "..."

# Test Review Prompt - Hands-on implementation and quality
# Use for: Workflow Step 5, reviewing test code, writing tests, quality assessment
# NOT for: High-level strategy, coverage planning
step5_test_review_prompt:
  role: "..."
```

### FR-5: Validation
**Priority**: High  
**Requirement**: Verify changes don't break existing functionality

**Acceptance Criteria**:
- All functions using `build_test_strategy_prompt()` still work
- All functions using `build_step5_test_review_prompt()` still work
- YAML parses correctly
- No backward compatibility issues

## Non-Functional Requirements

### NFR-1: Backward Compatibility
- No breaking changes to function signatures
- No changes to parameter usage
- Existing tests continue to pass

### NFR-2: Clarity
- Roles are self-documenting
- Clear distinction eliminates confusion
- Inline comments provide guidance

### NFR-3: Maintainability
- Future contributors understand which to use
- Clear separation of concerns
- Easy to extend independently

## Alternative Approaches Considered

### Alternative 1: Merge Prompts
**Approach**: Consolidate into single `step5_test_review_prompt`

**Pros**:
- Eliminates redundancy
- Single source of truth
- Token savings (~200-300)

**Cons**:
- Breaks 11 existing usages of `test_strategy_prompt`
- Loses simple, generic option
- May be overkill for quick analysis

**Decision**: **Rejected** - Both prompts are actively used, indicating different valid use cases

### Alternative 2: Create New Generic Prompt
**Approach**: Keep both, add third generic one

**Pros**:
- Maximum flexibility
- No breaking changes

**Cons**:
- Adds complexity
- More maintenance burden
- Doesn't solve clarity problem

**Decision**: **Rejected** - Adds complexity without clear benefit

### Alternative 3: Clarify Roles (SELECTED)
**Approach**: Update roles to make purposes distinct

**Pros**:
- No breaking changes
- Maintains both use cases
- Improves clarity
- Minimal implementation effort

**Cons**:
- Still have two prompts to maintain
- Small amount of overlap remains

**Decision**: **ACCEPTED** - Best balance of clarity and backward compatibility

## Technical Design

### Changes to ai_helpers.yaml

**Before**:
```yaml
test_strategy_prompt:
  role: "You are a QA engineer and test automation specialist with expertise in test strategy, coverage analysis, and test-driven development (TDD)."

step5_test_review_prompt:
  role: "You are a senior QA engineer and test automation specialist with expertise in testing strategies, code coverage analysis, test-driven development (TDD), behavior-driven development (BDD), and continuous integration best practices."
```

**After**:
```yaml
# Test Strategy Prompt - High-level Coverage Analysis and Planning
# Use for: Coverage gap analysis, test prioritization, strategic recommendations
# Focus: What to test, where are gaps, what's the strategy
test_strategy_prompt:
  role: "You are a test strategy architect specializing in coverage analysis and test planning. Your focus is on high-level strategy, identifying coverage gaps, and recommending test priorities rather than writing specific test cases."

# Test Review Prompt - Hands-on Implementation and Quality Assessment
# Use for: Workflow Step 5, reviewing test code, writing tests, quality assessment
# Focus: How to test, test code quality, specific test implementations
step5_test_review_prompt:
  role: "You are a hands-on test engineer and code quality specialist focused on reviewing existing test implementations, writing new test cases, assessing test code quality, and ensuring testing best practices are followed."
```

### No Code Changes Required

- Prompt builder functions remain unchanged
- Function signatures unchanged
- Parameters unchanged
- Only YAML role strings modified

## Test Plan

### Test Case 1: YAML Validity
**Objective**: Verify YAML parses correctly

```bash
python3 -c "import yaml; yaml.safe_load(open('src/workflow/lib/ai_helpers.yaml'))" && echo "✅ YAML valid"
```

**Expected**: No parsing errors

### Test Case 2: Role Content Verification
**Objective**: Verify roles contain clarifying keywords

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

# Check test_strategy_prompt
ts_role = data['test_strategy_prompt']['role']
assert 'strategy' in ts_role.lower() or 'architect' in ts_role.lower()
assert 'high-level' in ts_role.lower() or 'planning' in ts_role.lower()

# Check step5_test_review_prompt
tr_role = data['step5_test_review_prompt']['role']
assert 'hands-on' in tr_role.lower() or 'implementation' in tr_role.lower()
assert 'review' in tr_role.lower() or 'quality' in tr_role.lower()

print("✅ Roles clarified")
```

**Expected**: Assertions pass

### Test Case 3: Function Extraction Still Works
**Objective**: Verify prompt builders can extract updated roles

```bash
source src/workflow/lib/ai_helpers.sh

# Test test_strategy_prompt extraction
prompt1=$(build_test_strategy_prompt "Coverage: 80%" "test/file1.test.js")
echo "$prompt1" | grep -q "test strategy" && echo "✅ test_strategy_prompt works"

# Test step5_test_review_prompt extraction  
prompt2=$(build_step5_test_review_prompt "jest" "node" 10 5 8 2 "yes" "issues" "files")
echo "$prompt2" | grep -q "hands-on\|test engineer" && echo "✅ step5_test_review_prompt works"
```

**Expected**: Both prompts extract successfully

### Test Case 4: Role Distinction Validation
**Objective**: Verify roles are clearly distinct

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

ts_role = data['test_strategy_prompt']['role'].lower()
tr_role = data['step5_test_review_prompt']['role'].lower()

# Check for distinguishing keywords
strategy_keywords = ['strategy', 'architect', 'planning', 'high-level']
handson_keywords = ['hands-on', 'implementation', 'writing', 'quality']

has_strategy = any(kw in ts_role for kw in strategy_keywords)
has_handson = any(kw in tr_role for kw in handson_keywords)

if has_strategy and has_handson:
    print("✅ Roles are distinct")
else:
    print("❌ Roles not sufficiently distinct")
```

**Expected**: Roles have distinct keywords

### Test Case 5: Comment Presence
**Objective**: Verify inline comments added

```bash
grep -B3 "^test_strategy_prompt:" src/workflow/lib/ai_helpers.yaml | grep -q "# Test Strategy" && echo "✅ test_strategy comment present"
grep -B3 "^step5_test_review_prompt:" src/workflow/lib/ai_helpers.yaml | grep -q "# Test Review" && echo "✅ step5 comment present"
```

**Expected**: Comments present before each prompt

## Success Criteria

1. ✅ Roles updated with clear distinctions
2. ✅ Inline comments added explaining usage
3. ✅ YAML parses correctly
4. ✅ No backward compatibility issues
5. ✅ All tests pass
6. ✅ Documentation updated

## Impact Analysis

### Benefits

1. **Clarity**: Clear distinction eliminates confusion
2. **Maintainability**: Easier to know which to update
3. **Developer Experience**: Self-documenting roles
4. **Backward Compatibility**: No breaking changes
5. **Flexibility**: Maintains both use cases

### Minimal Changes

- Only role strings modified
- No code changes required
- No function signature changes
- No parameter changes

### Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| AI behavior changes | Low | Low | Roles still describe same expertise |
| Confusion persists | Low | Very Low | Clear keywords added |
| Breaking changes | None | None | Only string updates |

## Implementation Timeline

1. **Analysis** (Complete) - 15 minutes
2. **Update Roles** - 10 minutes
3. **Add Comments** - 5 minutes
4. **Testing** - 15 minutes
5. **Documentation** - 5 minutes

**Total Estimated Time**: 50 minutes

## Acceptance Checklist

- [ ] FR-1: test_strategy_prompt role clarified
- [ ] FR-2: step5_test_review_prompt role clarified
- [ ] FR-3: Task templates reviewed (optional)
- [ ] FR-4: Inline comments added
- [ ] FR-5: Validation complete
- [ ] NFR-1: Backward compatible
- [ ] NFR-2: Clarity improved
- [ ] NFR-3: Maintainability improved
- [ ] All test cases pass (5/5)
- [ ] YAML valid
- [ ] Documentation complete

## Related Issues

- **Category**: Clarity, Maintainability
- **Severity**: Medium (doesn't break functionality, but causes confusion)
- **Related to**: FRQ-2024-001, FRQ-2024-002, FRQ-2024-003 (all prompt improvements)

## References

- **YAML File**: `src/workflow/lib/ai_helpers.yaml`
- **Prompt Builders**: `src/workflow/lib/ai_helpers.sh`
- **Usage**: 11 files use test_strategy_prompt, 7 use step5_test_review_prompt

## Appendix A: Current Usage Locations

**test_strategy_prompt used in**:
- `build_test_strategy_prompt()` function
- `build_language_aware_test_strategy_prompt()` enhancement
- Various test-related scripts

**step5_test_review_prompt used in**:
- `build_step5_test_review_prompt()` function
- Step 5 execution scripts
- Test workflow steps

## Appendix B: Role Keywords

**Strategy-focused keywords**:
- "strategy architect"
- "high-level"
- "planning"
- "coverage gaps"
- "prioritization"

**Implementation-focused keywords**:
- "hands-on"
- "implementation"
- "code quality"
- "writing test cases"
- "reviewing code"

---

**Document Status**: ✅ Ready for Implementation  
**Recommended Approach**: Clarify roles (not merge)  
**Next Steps**: Update role strings and add inline comments
