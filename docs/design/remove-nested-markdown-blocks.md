# Functional Requirements: Remove Nested Markdown Blocks from YAML Prompts

**Feature ID**: FRQ-2024-002  
**Version**: 1.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft  
**Priority**: Critical  
**Category**: OutputQuality / TokenEfficiency

## Executive Summary

Remove nested markdown code blocks from YAML prompt templates to eliminate parsing complexity, reduce token usage by 15-20 tokens per invocation, and improve AI comprehension of output structure requirements.

## Problem Statement

### Current State

The `consistency_prompt` in `src/workflow/lib/ai_helpers.yaml` contains nested markdown code blocks within the YAML structure:

```yaml
**Output Format Requirements**:

```markdown
## Executive Summary
[2-3 sentence overview of findings]

## Critical Issues (Must Fix Immediately)
### Issue 1: [Title]
- **File**: path/to/file.md:line_number
```
```
```

**Issues**:
1. **Parsing Complexity**: Markdown code blocks nested in YAML create triple-backtick confusion
2. **Token Waste**: Opening/closing code blocks add 15-20 unnecessary tokens
3. **AI Confusion**: Nested blocks may confuse AI about whether to include backticks in output
4. **Maintenance Risk**: Triple-backtick syntax fragile in YAML multi-line strings
5. **Readability**: Harder for humans to read and maintain

### Desired State

Clean, direct format specification without nested markdown blocks:

```yaml
**Output Format Requirements**:

## Executive Summary
[2-3 sentence overview of findings]

## Critical Issues (Must Fix Immediately)
### Issue 1: [Title]
- **File**: path/to/file.md:line_number
- **Problem**: [Clear description]
- **Fix**: [Specific action needed]
- **Impact**: [Why this matters]
```

## Functional Requirements

### FR-1: Remove Nested Markdown Blocks
**Priority**: Critical  
**Requirement**: Remove all nested markdown code blocks (` ```markdown `) from YAML prompt templates

**Acceptance Criteria**:
- No triple-backtick markdown blocks within YAML strings
- Format specifications use plain text with markdown formatting
- Output structure remains identical
- AI receives cleaner instructions

**Affected Prompts**:
- `consistency_prompt` (primary)
- Check other prompts for similar patterns

### FR-2: Maintain Output Structure
**Priority**: Critical  
**Requirement**: Preserve exact output structure and formatting requirements

**Acceptance Criteria**:
- AI still produces structured markdown output
- Section headers identical (##, ###)
- List formatting preserved (-, **, etc.)
- No degradation in output quality

**Validation**:
- Compare AI outputs before/after
- Verify section structure matches
- Check completeness of responses

### FR-3: Token Reduction
**Priority**: High  
**Requirement**: Reduce token count by removing unnecessary code block markers

**Acceptance Criteria**:
- Minimum 15 token reduction per affected prompt
- Measured in prompt sent to AI, not YAML file size
- No increase in tokens elsewhere (trade-off check)

**Measurement**:
```bash
# Count tokens in prompt
echo "$prompt" | wc -w  # Approximate token count
```

### FR-4: YAML Validity
**Priority**: Critical  
**Requirement**: Ensure YAML remains valid after removing nested blocks

**Acceptance Criteria**:
- YAML parses correctly with Python yaml.safe_load()
- No parsing errors or warnings
- Multi-line string format (|) preserved
- Indentation correct

**Testing**:
```python
import yaml
with open('ai_helpers.yaml') as f:
    data = yaml.safe_load(f)  # Must succeed
```

### FR-5: Comprehensive Scan
**Priority**: Medium  
**Requirement**: Identify and fix all instances of nested markdown blocks

**Acceptance Criteria**:
- Scan entire `ai_helpers.yaml` for ` ```markdown `
- Scan `ai_prompts_project_kinds.yaml` for similar patterns
- Document all changes made
- Create reusable pattern for future prompts

**Scanning**:
```bash
grep -n '```markdown' src/workflow/lib/ai_helpers.yaml
grep -n '```' src/workflow/config/ai_prompts_project_kinds.yaml
```

## Non-Functional Requirements

### NFR-1: Performance
- No measurable impact on YAML parsing time
- Token reduction: 15-20 tokens per affected prompt
- Overall workflow speedup: minimal but measurable

### NFR-2: Maintainability
- Easier to read and edit prompt templates
- Simpler for contributors to understand
- Reduced risk of YAML syntax errors

### NFR-3: Backward Compatibility
- AI output structure unchanged
- No breaking changes to workflow steps
- Existing tests continue to pass

## Technical Design

### Current Pattern Analysis

**Problematic Pattern**:
```yaml
approach: |
  **Output Format**:
  
  ```markdown
  ## Section
  Content here
  ```
```

**Issues with Pattern**:
1. Triple backticks inside YAML multi-line string (|)
2. AI might include backticks in actual output
3. Adds ~8 tokens for opening block, ~8 for closing
4. Potential YAML parser confusion

### Solution Pattern

**Clean Pattern**:
```yaml
approach: |
  **Output Format**:
  
  ## Section
  Content here
  
  **Note**: Provide output in markdown format using the structure above.
```

**Benefits**:
1. No nested code blocks
2. Clear structure specification
3. Explicit instruction to use markdown
4. ~15-20 tokens saved

### Implementation Steps

1. **Scan for Patterns**: Identify all instances
2. **Remove Code Blocks**: Delete ` ```markdown ` and closing ` ``` `
3. **Add Clarity Note**: Optional explicit markdown instruction
4. **Validate YAML**: Ensure parsing still works
5. **Test Prompt**: Verify AI output quality

### Token Calculation

**Before** (with code blocks):
```
```markdown (3 tokens) + ## Executive Summary (3 tokens) + ... + ``` (1 token)
= ~15-20 tokens for formatting
```

**After** (without code blocks):
```
## Executive Summary (3 tokens) + ...
= ~0 formatting tokens (just content)
```

**Savings**: 15-20 tokens per prompt invocation

## Test Plan

### Test Case 1: YAML Validity
**Objective**: Verify YAML parses correctly after changes

```bash
python3 << 'EOF'
import yaml
with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)
print("✅ YAML valid")
EOF
```

**Expected**: No parsing errors

### Test Case 2: Pattern Identification
**Objective**: Find all nested markdown blocks

```bash
# Find triple backticks in YAML
grep -n '```' src/workflow/lib/ai_helpers.yaml
grep -n '```' src/workflow/config/ai_prompts_project_kinds.yaml

# Check for markdown keyword
grep -n 'markdown' src/workflow/lib/ai_helpers.yaml
```

**Expected**: List of line numbers with nested blocks

### Test Case 3: Token Count Comparison
**Objective**: Measure token reduction

```bash
# Before
source src/workflow/lib/ai_helpers.sh
prompt_before=$(build_consistency_prompt_args)
tokens_before=$(echo "$prompt_before" | wc -w)

# After modifications
prompt_after=$(build_consistency_prompt_args)
tokens_after=$(echo "$prompt_after" | wc -w)

# Calculate savings
echo "Tokens saved: $((tokens_before - tokens_after))"
```

**Expected**: 15-20 token reduction

### Test Case 4: AI Output Quality
**Objective**: Verify AI still produces correct structure

```bash
# Run Step 2 with updated prompt
cd src/workflow
./steps/step_02_consistency.sh

# Check output structure
cat .ai_workflow/prompts/*/step02*.md | grep -E "^##|^###"
```

**Expected**: 
- Contains "## Executive Summary"
- Contains "## Critical Issues"
- Contains "### Issue"
- Proper markdown hierarchy

### Test Case 5: Prompt Extraction
**Objective**: Verify prompt builder extracts correctly

```bash
source src/workflow/lib/ai_helpers.sh

# Extract consistency prompt approach section
approach=$(awk '/^consistency_prompt:/,/^[a-z_]+:/ {
    if (/approach: \|/) { flag=1; next }
    if (flag && /^[a-z_]+:/) { exit }
    if (flag) print
}' src/workflow/lib/ai_helpers.yaml)

echo "$approach"

# Verify no triple backticks
if echo "$approach" | grep -q '```'; then
    echo "❌ Still contains code blocks"
    exit 1
else
    echo "✅ No nested code blocks"
fi
```

**Expected**: No triple backticks in extracted text

### Test Case 6: Compare Outputs
**Objective**: Ensure AI output structure unchanged

```bash
# Create test inputs
test_doc_count=226
test_broken_refs="test.md: /missing/file"
test_doc_files="README.md\ndocs/test.md"

# Generate prompts
source src/workflow/lib/ai_helpers.sh
prompt=$(build_consistency_prompt "$test_doc_count" "test" "10" "$test_broken_refs" "$test_doc_files")

# Check structure requirements present
echo "$prompt" | grep -q "## Executive Summary" && echo "✅ Executive Summary"
echo "$prompt" | grep -q "## Critical Issues" && echo "✅ Critical Issues"
echo "$prompt" | grep -q "**File**:" && echo "✅ File format"
echo "$prompt" | grep -q "**Problem**:" && echo "✅ Problem format"
```

**Expected**: All format requirements present in prompt

## Success Criteria

1. ✅ All nested markdown blocks removed
2. ✅ YAML parses correctly
3. ✅ Token count reduced by 15-20 tokens
4. ✅ AI output structure unchanged
5. ✅ All tests pass
6. ✅ Documentation updated

## Impact Analysis

### Positive Impacts

1. **Token Efficiency**: 15-20 tokens saved per consistency_prompt invocation
2. **Clarity**: Simpler format specification, easier for AI to parse
3. **Maintainability**: Easier for humans to read and edit
4. **Robustness**: Eliminates potential markdown parsing conflicts
5. **Extensibility**: Better pattern for future prompt development

### Potential Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| AI output format changes | High | Low | Test with real workflow execution |
| YAML parsing breaks | High | Very Low | Validate with yaml.safe_load() |
| Token count doesn't decrease | Low | Very Low | Measure before/after |
| Output quality degrades | Medium | Low | Compare outputs before/after |

### Risk Mitigation

1. **Test Thoroughly**: Run Step 2 with real data before committing
2. **Backup First**: Keep copy of original ai_helpers.yaml
3. **Validate**: Check YAML parsing in multiple contexts
4. **Monitor**: Review AI outputs after deployment

## Implementation Timeline

1. **Analysis & Scanning** - 15 minutes
   - Identify all nested markdown blocks
   - Document locations and patterns
   
2. **Implementation** - 20 minutes
   - Remove code blocks from consistency_prompt
   - Add clarifying notes if needed
   - Validate YAML syntax
   
3. **Testing** - 30 minutes
   - YAML validity test
   - Token count measurement
   - Integration test (Step 2)
   - Output quality verification
   
4. **Documentation** - 10 minutes
   - Update inline comments
   - Note changes in commit message

**Total Estimated Time**: 75 minutes (~1.25 hours)

## Acceptance Checklist

- [ ] Functional requirements met (FR-1 through FR-5)
- [ ] Non-functional requirements met (NFR-1 through NFR-3)
- [ ] All test cases pass (6/6)
- [ ] YAML validates correctly
- [ ] Token reduction achieved (15-20 tokens)
- [ ] AI output quality maintained
- [ ] No nested markdown blocks remain
- [ ] Documentation updated
- [ ] Changes reviewed

## Related Issues

- **Related to**: FRQ-2024-001 (YAML Anchors) - both improve YAML prompts
- **Category**: OutputQuality, TokenEfficiency
- **Severity**: Critical (affects AI output parsing)

## References

- **YAML Multi-line Strings**: https://yaml-multiline.info/
- **Markdown Specification**: https://spec.commonmark.org/
- **Token Counting**: Approximate with word count (1 word ≈ 1.3 tokens)
- **AI Helpers Module**: `src/workflow/lib/ai_helpers.yaml`

## Appendix A: Scanning Results

### Current Nested Block Locations

**To be filled during implementation**:
```bash
# Find all instances
grep -n '```markdown' src/workflow/lib/ai_helpers.yaml
grep -n '```' src/workflow/lib/ai_helpers.yaml | grep -v '^#'
```

Expected locations:
- consistency_prompt.approach (lines TBD)
- Possibly in task_template or approach sections
- Check project_kinds.yaml as well

## Appendix B: Token Analysis

### Detailed Token Breakdown

**Nested Block Overhead**:
- ` ```markdown ` = ~8 tokens (3 backticks + markdown keyword)
- ` ``` ` (closing) = ~4 tokens (3 backticks)
- Total overhead: ~12 tokens per block

**Consistency Prompt Blocks**:
- Likely 1-2 blocks in approach section
- Total savings: 12-24 tokens

**Additional Considerations**:
- Line breaks and formatting: ~3-5 tokens
- Total expected savings: 15-20 tokens (conservative estimate)

## Appendix C: Alternative Approaches Considered

### Alternative 1: Keep Blocks, Add Escape Characters
**Approach**: Escape backticks to prevent parsing issues

**Pros**: Preserves intended structure  
**Cons**: Still wastes tokens, adds complexity

**Decision**: Rejected - doesn't solve token efficiency

### Alternative 2: Use Different Block Syntax
**Approach**: Use `~~~` instead of ` ``` `

**Pros**: Might be less confusing  
**Cons**: Still nested, still wastes tokens

**Decision**: Rejected - doesn't address root cause

### Alternative 3: External Example Files
**Approach**: Store example outputs in separate files

**Pros**: Very clean YAML  
**Cons**: Adds file I/O, harder to maintain

**Decision**: Rejected - over-engineered

### Alternative 4: Remove All Structure Specification
**Approach**: Let AI decide output format

**Pros**: Minimal tokens  
**Cons**: Unpredictable output structure

**Decision**: Rejected - output quality critical

---

**Document Status**: ✅ Ready for Implementation  
**Next Steps**: Proceed with pattern scanning and implementation
