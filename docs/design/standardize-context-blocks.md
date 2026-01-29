# Functional Requirements: Standardize Context Block Structure

**Feature ID**: FRQ-2024-003  
**Version**: 2.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft  
**Priority**: High  
**Category**: Consistency / Maintainability

## Executive Summary

Standardize context block structure and parameter naming across all workflow step prompts to improve maintainability, reduce cognitive load, and ensure consistent AI behavior across the 15-step workflow.

## Problem Statement

### Current State

The AI prompt templates in `.workflow_core/config/ai_helpers.yaml` use inconsistent context formatting:

**Inconsistencies Identified**:
1. **Parameter Name Variations**: 
   - `{project_name}` vs `{project_description}` vs `Project: XYZ`
   - `{primary_language}` vs `{language}` vs `Language: Bash`
   - `{change_scope}` vs `{scope}` vs `Scope: comprehensive`

2. **Ordering Differences**:
   - Some start with project info, others with file counts
   - No consistent sequence for common variables
   - Step-specific context mixed with common context

3. **Capitalization Inconsistencies**:
   - Some use `{Change Scope}` (title case)
   - Others use `{change_scope}` (snake_case)
   - Inconsistent use of markdown formatting

4. **Format Variations**:
   - Some use bullet lists (`-`)
   - Others use plain text paragraphs
   - Inconsistent use of markdown bold (`**`)

**Issues**:
- **Maintenance Burden**: Changes require understanding different formats
- **Cognitive Load**: Developers must remember multiple patterns
- **Inconsistent AI Behavior**: Different formats may affect AI interpretation
- **Testing Complexity**: Harder to validate prompt structure programmatically
- **Scalability**: Adding new steps requires guessing format conventions

### Desired State

Unified, predictable context block structure:

```yaml
**Context:**
- Project: {project_name} ({project_description})
- Primary Language: {primary_language}
- Scope: {change_scope}
- Modified Files: {modified_count}
[Step-specific context follows with same formatting pattern]
```

## Functional Requirements

### FR-1: Standard Context Block Structure
**Priority**: Critical  
**Requirement**: Define and implement a standard context block format for all step prompts

**Acceptance Criteria**:
- Consistent section header: `**Context:**`
- Bullet list format (using `-`)
- Standard parameter order (project → language → scope → files)
- Markdown bold for field labels
- Parameter names in snake_case: `{parameter_name}`

**Standard Template**:
```yaml
**Context:**
- Project: {project_name} ({project_description})
- Primary Language: {primary_language}
- Scope: {change_scope}
- Modified Files: {modified_count}
```

### FR-2: Parameter Name Standardization
**Priority**: Critical  
**Requirement**: Use consistent parameter names across all prompts

**Acceptance Criteria**:
- `{project_name}` - Project name only
- `{project_description}` - Project description
- `{primary_language}` - Primary programming language
- `{change_scope}` - Scope of changes (documentation/code/comprehensive)
- `{modified_count}` - Number of modified files
- All parameters use snake_case, no title case

**Prohibited Variations**:
- ❌ `{Project Name}` (title case)
- ❌ `{projectName}` (camelCase)
- ❌ `{project-name}` (kebab-case)
- ✅ `{project_name}` (snake_case)

### FR-3: Apply to All Step Prompts
**Priority**: High  
**Requirement**: Update all workflow step prompts with standardized context

**Affected Prompts** (7 total):
1. `step2_consistency_prompt` (consistency_prompt)
2. `step3_script_refs_prompt`
3. `step4_directory_prompt`
4. `step5_test_review_prompt`
5. `step7_test_execution_prompt`
6. `step8_dependencies_prompt`
7. `step9_code_quality_prompt`

**Not Affected**:
- `doc_analysis_prompt` (Step 1) - uses different format intentionally
- `step6_test_gen_prompt` - may have custom context needs
- Other non-step prompts (git, issue_extraction, etc.)

### FR-4: Step-Specific Context Follows Standard
**Priority**: Medium  
**Requirement**: Step-specific context fields follow same formatting pattern

**Acceptance Criteria**:
- Added after standard context block
- Use same bullet list format (`-`)
- Same markdown bold pattern for labels
- Clear separation from standard context

**Example**:
```yaml
**Context:**
- Project: {project_name} ({project_description})
- Primary Language: {primary_language}
- Scope: {change_scope}
- Modified Files: {modified_count}
- Test Files: {test_count}  # Step-specific
- Test Framework: {test_framework}  # Step-specific
```

### FR-5: Validation and Testing
**Priority**: High  
**Requirement**: Validate consistency across all updated prompts

**Acceptance Criteria**:
- Script to extract and compare context blocks
- Verification that all use standard parameter names
- Check for consistent ordering
- Validate bullet list format
- No title case or other variations

**Validation Script**:
```bash
# Extract context blocks and verify consistency
python3 check_prompt_consistency.py .workflow_core/config/ai_helpers.yaml
```

## Non-Functional Requirements

### NFR-1: Backward Compatibility
- Prompt builders must continue to work with new format
- No breaking changes to step execution
- All existing tests must pass

### NFR-2: Maintainability
- Single source of truth for context structure
- Easy to add new standard parameters
- Clear documentation of conventions

### NFR-3: Developer Experience
- Obvious pattern for new contributors
- Self-documenting through consistency
- Reduced cognitive load when editing prompts

## Technical Design

### Standard Context Block Pattern

```yaml
prompt_name:
  task_template: |
    [Task description here]
    
    **Context:**
    - Project: {project_name} ({project_description})
    - Primary Language: {primary_language}
    - Scope: {change_scope}
    - Modified Files: {modified_count}
    [Step-specific fields follow same pattern]
    
    **Your Task:**
    [Specific instructions]
```

### Parameter Substitution

Currently handled by prompt builder functions:
- `build_step2_consistency_prompt()`
- `build_step3_script_refs_prompt()`
- etc.

These functions will substitute `{parameter_name}` with actual values.

### Implementation Strategy

**Phase 1: Audit** (15 minutes)
1. Extract all current context blocks
2. Document variations and inconsistencies
3. Identify affected prompts

**Phase 2: Standardize** (30 minutes)
1. Update consistency_prompt (Step 2)
2. Update remaining step prompts
3. Ensure consistent parameter names

**Phase 3: Validate** (20 minutes)
1. YAML parsing test
2. Context block extraction test
3. Parameter name consistency check
4. Integration test with real workflow

**Phase 4: Document** (10 minutes)
1. Update inline comments
2. Create validation script
3. Document conventions

## Test Plan

### Test Case 1: Context Block Extraction
**Objective**: Extract context blocks from all step prompts

```python
import yaml
import re

with open('.workflow_core/config/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

# Extract context blocks
step_prompts = [
    'consistency_prompt',
    'step3_script_refs_prompt',
    'step4_directory_prompt',
    'step5_test_review_prompt',
    'step7_test_execution_prompt',
    'step8_dependencies_prompt',
    'step9_code_quality_prompt',
]

for prompt_name in step_prompts:
    if prompt_name in data:
        task = data[prompt_name].get('task_template', '')
        # Extract context block
        match = re.search(r'\*\*Context:\*\*(.*?)(?:\*\*|$)', task, re.DOTALL)
        if match:
            print(f"{prompt_name}: ✅ Has context block")
        else:
            print(f"{prompt_name}: ❌ Missing context block")
```

**Expected**: All 7 prompts have `**Context:**` section

### Test Case 2: Parameter Name Consistency
**Objective**: Verify all prompts use standard parameter names

```python
standard_params = [
    'project_name',
    'project_description',
    'primary_language',
    'change_scope',
    'modified_count',
]

for prompt_name in step_prompts:
    task = data[prompt_name].get('task_template', '')
    
    # Find all parameters
    params = re.findall(r'\{(\w+)\}', task)
    
    # Check for standard params using correct names
    for param in params:
        if param in ['project', 'language', 'scope', 'files']:
            print(f"{prompt_name}: ⚠️  Uses deprecated parameter: {param}")
```

**Expected**: No deprecated parameter names

### Test Case 3: Format Consistency
**Objective**: Verify bullet list format

```python
for prompt_name in step_prompts:
    task = data[prompt_name].get('task_template', '')
    context_match = re.search(r'\*\*Context:\*\*(.*?)(?:\*\*|$)', task, re.DOTALL)
    
    if context_match:
        context = context_match.group(1)
        lines = [l.strip() for l in context.split('\n') if l.strip()]
        
        # Check all lines start with '-'
        all_bullets = all(l.startswith('-') for l in lines if l)
        if all_bullets:
            print(f"{prompt_name}: ✅ Consistent bullet format")
        else:
            print(f"{prompt_name}: ❌ Inconsistent format")
```

**Expected**: All context items use bullet list format

### Test Case 4: Ordering Consistency
**Objective**: Verify standard parameters appear in consistent order

```python
expected_order = [
    'project_name',
    'project_description',
    'primary_language',
    'change_scope',
    'modified_count',
]

for prompt_name in step_prompts:
    task = data[prompt_name].get('task_template', '')
    
    # Extract parameters in order
    params = re.findall(r'\{(\w+)\}', task)
    standard_params_found = [p for p in params if p in expected_order]
    
    # Check if they appear in expected order
    if standard_params_found == sorted(standard_params_found, key=expected_order.index):
        print(f"{prompt_name}: ✅ Correct order")
    else:
        print(f"{prompt_name}: ⚠️  Non-standard order")
```

**Expected**: Standard parameters in consistent order

### Test Case 5: Integration Test
**Objective**: Run workflow step with new prompts

```bash
# Test Step 2 with standardized prompt
cd src/workflow
source lib/ai_helpers.sh

# Build prompt
prompt=$(python3 << 'EOF'
import yaml
with open('lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)
print(data['consistency_prompt']['task_template'])
EOF
)

# Verify context block present
echo "$prompt" | grep -q "**Context:**" && echo "✅ Context block present"
echo "$prompt" | grep -q "{project_name}" && echo "✅ project_name parameter"
echo "$prompt" | grep -q "{primary_language}" && echo "✅ primary_language parameter"
```

**Expected**: All standard parameters present and formatted correctly

### Test Case 6: YAML Validity
**Objective**: Ensure YAML remains valid

```bash
python3 -c "import yaml; yaml.safe_load(open('.workflow_core/config/ai_helpers.yaml'))" && echo "✅ YAML valid"
```

**Expected**: No parsing errors

## Success Criteria

1. ✅ All 7 step prompts use standardized context block
2. ✅ All use snake_case parameter names
3. ✅ Consistent bullet list format (`-`)
4. ✅ Standard parameters in consistent order
5. ✅ YAML parses correctly
6. ✅ All tests pass
7. ✅ Validation script created

## Impact Analysis

### Benefits

1. **Reduced Maintenance**: Single pattern to remember
2. **Easier Onboarding**: Clear, consistent conventions
3. **Better Testing**: Programmatic validation possible
4. **Predictable AI Behavior**: Consistent format improves AI comprehension
5. **Scalability**: Easy to add new steps following pattern

### Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking prompt builders | High | Low | Test all steps after changes |
| AI output quality changes | Medium | Low | Compare outputs before/after |
| Parameter name mismatches | High | Medium | Comprehensive testing |
| Missing step-specific context | Medium | Low | Careful review of each prompt |

## Implementation Timeline

1. **Audit Current State** - 15 minutes
   - Extract all context blocks
   - Document inconsistencies
   
2. **Standardize Prompts** - 30 minutes
   - Update 7 step prompts
   - Ensure consistent format
   
3. **Validation** - 20 minutes
   - Run all test cases
   - Verify consistency
   - Integration test
   
4. **Documentation** - 10 minutes
   - Inline comments
   - Validation script
   - Convention documentation

**Total Estimated Time**: 75 minutes (~1.25 hours)

## Acceptance Checklist

- [ ] FR-1: Standard context block structure implemented
- [ ] FR-2: Parameter names standardized
- [ ] FR-3: All 7 step prompts updated
- [ ] FR-4: Step-specific context follows pattern
- [ ] FR-5: Validation script created
- [ ] NFR-1: Backward compatibility maintained
- [ ] NFR-2: Maintainability improved
- [ ] NFR-3: Developer experience enhanced
- [ ] All test cases pass (6/6)
- [ ] YAML valid
- [ ] Integration tested
- [ ] Documentation updated

## Related Issues

- **Related to**: FRQ-2024-001 (YAML Anchors), FRQ-2024-002 (Nested Blocks)
- **Category**: Consistency, Maintainability
- **Severity**: High (affects multiple workflow steps)

## References

- **YAML Prompts**: `.workflow_core/config/ai_helpers.yaml`
- **Prompt Builders**: `src/workflow/lib/ai_helpers.sh`
- **Step Scripts**: `src/workflow/steps/step_*.sh`

## Appendix A: Current Inconsistencies

**To be filled during audit phase**:

Example inconsistencies found:
- Step 2: Uses `**Project Context:**` instead of `**Context:**`
- Step 3: Uses `Project: {project}` instead of `{project_name}`
- Step 4: Missing `{primary_language}`
- Step 5: Uses title case `{Test Count}` instead of `{test_count}`

## Appendix B: Standard Context Template

```yaml
# Standard context block for all step prompts
# Version: 2.0.0
# Required fields (always include):
**Context:**
- Project: {project_name} ({project_description})
- Primary Language: {primary_language}
- Scope: {change_scope}
- Modified Files: {modified_count}

# Optional step-specific fields (add as needed):
- [Step-Specific Field]: {step_specific_value}
```

## Appendix C: Parameter Naming Convention

**Standard Parameters**:
- `{project_name}` - Short project name
- `{project_description}` - One-line description
- `{primary_language}` - Main programming language (e.g., "bash", "javascript")
- `{change_scope}` - Scope descriptor ("documentation", "code", "comprehensive")
- `{modified_count}` - Number of modified files (integer)

**Parameter Format**:
- Always lowercase
- Use underscores for multi-word names
- Descriptive but concise
- No abbreviations unless obvious

---

**Document Status**: ✅ Ready for Implementation  
**Next Steps**: Proceed with audit phase to identify all inconsistencies
