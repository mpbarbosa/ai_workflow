# Functional Requirements: Clarify or Deprecate Quality Prompt

**Feature ID**: FRQ-2024-005  
**Version**: 1.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft  
**Priority**: Medium  
**Category**: TokenEfficiency / Clarity

## Executive Summary

Analyze the relationship between `quality_prompt` and `step9_code_quality_prompt` to determine if the simpler version should be deprecated or clarified. Recommended approach: **Clarify roles** similar to test prompts, as both are actively used with different scopes.

## Problem Statement

### Current State

Two code quality personas exist with potential overlap:

1. **quality_prompt**:
   - Role: "software quality engineer and code review specialist"
   - Size: Small, focused (825 chars total)
   - Usage: 13 locations (higher usage via `build_quality_prompt()`)
   - Purpose: Quick, generic code quality reviews
   - Parameters: Simple (`{files_to_review}`)

2. **step9_code_quality_prompt**:
   - Role: "senior software quality engineer and code review specialist"
   - Size: Comprehensive (2903 chars total - 3.5x larger)
   - Usage: 8 locations (workflow Step 9)
   - Purpose: Comprehensive workflow-integrated analysis
   - Parameters: Rich context (project, language, tech stack, etc.)

**Similarity to Test Prompts Issue**:
This is the same pattern as test personas (FRQ-2024-004):
- Simple generic version for quick analysis
- Comprehensive version for workflow steps
- Both actively used
- Unclear distinction in role descriptions

### Current Usage Patterns

**quality_prompt**:
- Used by `build_quality_prompt()` function
- Enhanced by `build_language_aware_quality_prompt()`
- 13 total usages in codebase
- Generic code review scenarios

**step9_code_quality_prompt**:
- Used by `build_step9_code_quality_prompt()` function
- 8 total usages in codebase
- Workflow Step 9 specific

### Analysis: Deprecate or Clarify?

**Evidence FOR Deprecation**:
- Significant size difference (3.5x)
- Similar role descriptions
- step9 version is more comprehensive
- Could consolidate maintenance

**Evidence AGAINST Deprecation**:
- quality_prompt used MORE frequently (13 vs 8)
- Different complexity levels serve different needs
- Simple version useful for quick reviews
- Breaking 13 existing usages is high cost

**Recommendation**: **Clarify roles** (not deprecate)

**Rationale**:
1. Higher usage (13 locations) indicates active use case
2. Simpler version has value for quick reviews
3. Similar to test_strategy_prompt vs step5_test_review_prompt pattern
4. Deprecation would break more code than test prompts
5. Clear role distinction is low-cost, high-value solution

## Functional Requirements

### FR-1: Clarify quality_prompt Role
**Priority**: High  
**Requirement**: Update role to emphasize quick, focused code review

**Acceptance Criteria**:
- Role indicates "focused code reviewer" or "code review specialist"
- Emphasis on "quick", "targeted", "file-level review"
- Distinct from comprehensive analysis
- Clear use case guidance

**New Role**:
```yaml
quality_prompt:
  role: "You are a focused code review specialist conducting targeted file-level quality assessments. Your reviews are quick, practical, and focused on immediate code quality issues rather than comprehensive architectural analysis."
```

### FR-2: Clarify step9_code_quality_prompt Role
**Priority**: High  
**Requirement**: Update role to emphasize comprehensive analysis

**Acceptance Criteria**:
- Role indicates "comprehensive quality engineer" or "technical debt specialist"
- Emphasis on "comprehensive", "architectural", "maintainability"
- Distinct from quick reviews
- Clear workflow integration

**New Role**:
```yaml
step9_code_quality_prompt:
  role: "You are a comprehensive software quality engineer specializing in architectural analysis, technical debt assessment, and long-term maintainability. You perform in-depth code quality reviews considering design patterns, scalability, and system-wide implications."
```

### FR-3: Add Inline Documentation
**Priority**: Medium  
**Requirement**: Add comments explaining when to use each prompt

**Acceptance Criteria**:
- Comments before each prompt definition
- Clear use case descriptions
- Examples of appropriate usage
- Guidance on choosing between them

**Example**:
```yaml
# Quality Prompt - Quick File-Level Code Review
# Use for: Focused code reviews, specific file analysis, quick quality checks
# Focus: Immediate code quality issues, file-level problems
# NOT for: Architectural analysis, comprehensive system review
quality_prompt:
  role: "..."

# Step 9 Code Quality Prompt - Comprehensive Quality Analysis
# Use for: Workflow Step 9, architectural reviews, technical debt assessment
# Focus: System-wide quality, maintainability, design patterns
# NOT for: Quick file reviews, simple syntax checks
step9_code_quality_prompt:
  role: "..."
```

### FR-4: Update Task Templates (Optional)
**Priority**: Low  
**Requirement**: Ensure task templates reinforce role distinctions

**Acceptance Criteria**:
- `quality_prompt` emphasizes file-level analysis
- `step9_code_quality_prompt` emphasizes comprehensive review
- No conflicting instructions

### FR-5: Validation
**Priority**: High  
**Requirement**: Verify no breaking changes

**Acceptance Criteria**:
- All 13 usages of `build_quality_prompt()` still work
- All 8 usages of `build_step9_code_quality_prompt()` still work
- YAML parses correctly
- No backward compatibility issues

## Non-Functional Requirements

### NFR-1: Backward Compatibility
- No breaking changes to function signatures
- No changes to parameter usage
- Existing code continues to work

### NFR-2: Clarity
- Clear distinction between quick and comprehensive reviews
- Self-documenting roles
- Inline comments provide guidance

### NFR-3: Maintainability
- Clear when to update which prompt
- Easy to extend independently
- Future contributors understand distinction

## Alternative Approaches Considered

### Alternative 1: Deprecate quality_prompt (REJECTED)
**Approach**: Remove quality_prompt, use only step9_code_quality_prompt

**Pros**:
- Single source of truth
- Token savings (~825 chars)
- Less maintenance

**Cons**:
- Breaks 13 existing usages (more than test prompts)
- Loses simple option for quick reviews
- step9 version may be overkill for simple cases
- Higher implementation cost

**Decision**: **Rejected** - Too disruptive, loses valid use case

### Alternative 2: Create Unified Prompt
**Approach**: Single prompt that adapts based on parameters

**Pros**:
- Flexible
- No duplication

**Cons**:
- Complex implementation
- Harder to optimize for each use case
- May become bloated

**Decision**: **Rejected** - Over-engineered

### Alternative 3: Clarify Roles (SELECTED)
**Approach**: Update role descriptions to make purposes distinct

**Pros**:
- No breaking changes
- Maintains both use cases
- Low implementation cost
- Improves clarity

**Cons**:
- Still have two prompts to maintain
- Small overlap remains

**Decision**: **ACCEPTED** - Best balance, consistent with test prompts solution

## Technical Design

### Changes to ai_helpers.yaml

**Before**:
```yaml
quality_prompt:
  role: "You are a software quality engineer and code review specialist with expertise in code quality standards, best practices, and maintainability."

step9_code_quality_prompt:
  role: "You are a senior software quality engineer and code review specialist with expertise in code quality standards, static analysis, linting best practices, design patterns, maintainability assessment, and technical debt identification."
```

**After**:
```yaml
# Quality Prompt - Quick File-Level Code Review
# Use for: Targeted code reviews, specific file analysis, quick quality checks
# Focus: File-level issues, immediate problems, practical improvements
# NOT for: Architectural analysis, comprehensive system review
quality_prompt:
  role: "You are a focused code review specialist conducting targeted file-level quality assessments. Your reviews are quick, practical, and focused on immediate code quality issues rather than comprehensive architectural analysis."

# Step 9 Code Quality Prompt - Comprehensive Quality and Architecture Analysis
# Use for: Workflow Step 9, architectural reviews, technical debt assessment, system-wide analysis
# Focus: Comprehensive quality, maintainability, design patterns, architectural concerns
# NOT for: Quick file reviews, simple syntax checks
step9_code_quality_prompt:
  role: "You are a comprehensive software quality engineer specializing in architectural analysis, technical debt assessment, and long-term maintainability. You perform in-depth code quality reviews considering design patterns, scalability, and system-wide implications."
```

### No Code Changes Required

- Prompt builder functions remain unchanged
- Function signatures unchanged  
- Parameters unchanged
- Only YAML role strings and comments modified

## Test Plan

### Test Case 1: YAML Validity
**Objective**: Verify YAML parses correctly

```bash
python3 -c "import yaml; yaml.safe_load(open('src/workflow/lib/ai_helpers.yaml'))" && echo "✅ YAML valid"
```

**Expected**: No parsing errors

### Test Case 2: Role Keywords Verification
**Objective**: Verify roles contain clarifying keywords

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

# Check quality_prompt
qp_role = data['quality_prompt']['role'].lower()
assert any(kw in qp_role for kw in ['focused', 'quick', 'targeted', 'file-level'])

# Check step9_code_quality_prompt
cq_role = data['step9_code_quality_prompt']['role'].lower()
assert any(kw in cq_role for kw in ['comprehensive', 'architectural', 'system-wide', 'in-depth'])

print("✅ Roles clarified with distinct keywords")
```

**Expected**: Assertions pass

### Test Case 3: Function Extraction Still Works
**Objective**: Verify prompt builders can extract updated roles

```bash
source src/workflow/lib/ai_helpers.sh

# Test quality_prompt extraction
prompt1=$(build_quality_prompt "file1.js file2.js")
echo "$prompt1" | grep -qi "focused\|targeted" && echo "✅ quality_prompt works"

# Test step9_code_quality_prompt extraction
prompt2=$(build_step9_code_quality_prompt "params...")
echo "$prompt2" | grep -qi "comprehensive\|architectural" && echo "✅ step9_code_quality_prompt works"
```

**Expected**: Both prompts extract successfully

### Test Case 4: Role Distinction Validation
**Objective**: Verify roles are clearly distinct

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

qp_role = data['quality_prompt']['role'].lower()
cq_role = data['step9_code_quality_prompt']['role'].lower()

# Check for distinguishing keywords
quick_keywords = ['focused', 'quick', 'targeted', 'file-level', 'immediate']
comprehensive_keywords = ['comprehensive', 'architectural', 'system-wide', 'in-depth', 'long-term']

has_quick = any(kw in qp_role for kw in quick_keywords)
has_comprehensive = any(kw in cq_role for kw in comprehensive_keywords)

assert has_quick and has_comprehensive, "Roles not distinct"
print("✅ Roles have clear distinction")
```

**Expected**: Roles have distinct focus areas

### Test Case 5: Comment Presence
**Objective**: Verify inline comments added

```bash
grep -B3 "^quality_prompt:" src/workflow/lib/ai_helpers.yaml | grep -q "# Quality Prompt" && echo "✅ quality_prompt comment present"
grep -B3 "^step9_code_quality_prompt:" src/workflow/lib/ai_helpers.yaml | grep -q "# Step 9" && echo "✅ step9 comment present"
```

**Expected**: Comments present before each prompt

### Test Case 6: Structure Preservation
**Objective**: Verify all fields still present

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

# quality_prompt
qp = data['quality_prompt']
assert 'role' in qp and len(qp['role']) > 100
assert 'task_template' in qp
assert 'approach' in qp
print("✅ quality_prompt structure preserved")

# step9_code_quality_prompt
cq = data['step9_code_quality_prompt']
assert 'role' in cq and len(cq['role']) > 100
assert 'task_template' in cq
assert 'approach' in cq
print("✅ step9_code_quality_prompt structure preserved")
```

**Expected**: All fields present and valid

## Success Criteria

1. ✅ Roles updated with clear distinctions
2. ✅ Inline comments added explaining usage
3. ✅ YAML parses correctly
4. ✅ No backward compatibility issues
5. ✅ All tests pass (6/6)
6. ✅ Documentation updated

## Impact Analysis

### Benefits

1. **Clarity**: Clear distinction between quick and comprehensive reviews
2. **Maintainability**: Know which to update for different scenarios
3. **Developer Experience**: Self-documenting, easier to choose
4. **Backward Compatibility**: No breaking changes
5. **Consistency**: Matches test prompts pattern (FRQ-2024-004)

### Comparison with Test Prompts

| Aspect | Test Prompts | Quality Prompts |
|--------|--------------|-----------------|
| Simple version usage | 11 files | 13 files |
| Complex version usage | 7 files | 8 files |
| Size ratio | Strategy simpler | quality_prompt simpler |
| Decision | Clarify roles | Clarify roles |
| Rationale | Both active use | Both active use |

### Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| AI behavior changes | Low | Low | Roles still describe same domain |
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

- [ ] FR-1: quality_prompt role clarified
- [ ] FR-2: step9_code_quality_prompt role clarified
- [ ] FR-3: Inline comments added
- [ ] FR-4: Task templates reviewed (optional)
- [ ] FR-5: Validation complete
- [ ] NFR-1: Backward compatible
- [ ] NFR-2: Clarity improved
- [ ] NFR-3: Maintainability improved
- [ ] All test cases pass (6/6)
- [ ] YAML valid
- [ ] Documentation complete

## Related Issues

- **Similar to**: FRQ-2024-004 (Test Persona Clarification)
- **Pattern**: Simple vs Comprehensive persona pairs
- **Category**: Clarity, TokenEfficiency
- **Severity**: Medium

## References

- **YAML File**: `src/workflow/lib/ai_helpers.yaml`
- **Prompt Builders**: `src/workflow/lib/ai_helpers.sh`
  - `build_quality_prompt()` - 13 usages
  - `build_step9_code_quality_prompt()` - 8 usages
  - `build_language_aware_quality_prompt()` - Uses quality_prompt

## Appendix A: Usage Locations

**quality_prompt used in**:
- `build_quality_prompt()` function
- `build_language_aware_quality_prompt()` enhancement
- Exported functions
- Generic code review scenarios

**step9_code_quality_prompt used in**:
- `build_step9_code_quality_prompt()` function
- Step 9 execution scripts
- Workflow integration

## Appendix B: Role Keywords

**Quick/Focused keywords**:
- "focused"
- "quick"
- "targeted"
- "file-level"
- "immediate"
- "practical"

**Comprehensive keywords**:
- "comprehensive"
- "architectural"
- "system-wide"
- "in-depth"
- "long-term"
- "technical debt"

## Appendix C: Pattern Consistency

This is the **third pair** following the same pattern:

1. **Test Prompts** (FRQ-2024-004):
   - test_strategy_prompt (strategy architect)
   - step5_test_review_prompt (hands-on engineer)

2. **Quality Prompts** (FRQ-2024-005):
   - quality_prompt (focused reviewer)
   - step9_code_quality_prompt (comprehensive analyst)

**Pattern**: Simple/generic vs comprehensive/workflow-integrated

**Solution**: Clarify roles, don't merge (both have value)

---

**Document Status**: ✅ Ready for Implementation  
**Recommended Approach**: Clarify roles (not deprecate)  
**Consistency**: Matches test prompts solution pattern  
**Next Steps**: Update role strings and add inline comments
