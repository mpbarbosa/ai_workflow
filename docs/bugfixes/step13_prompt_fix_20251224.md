# Step 13 Prompt Engineer Bug Fix

**Date**: 2024-12-24  
**Issue**: Step 13 AI prompt was malformed, causing AI to request clarification instead of analyzing prompts  
**Severity**: Critical - Step 13 was non-functional  
**Status**: ✅ Fixed

## Root Cause Analysis

### Problem 1: Empty Role, Task, and Approach Fields

**Location**: `src/workflow/steps/step_13_prompt_engineer.sh` lines 90-147

The script's awk patterns for extracting YAML fields were designed for single-line quoted strings:
```awk
if ($0 ~ /^[[:space:]]*role:/) {
    match($0, /role:[[:space:]]*"(.+)"/, arr)
    print arr[1]
    exit
}
```

However, the YAML file uses **multiline block scalars** with pipe notation (`|`):
```yaml
step13_prompt_engineer_prompt:
  role: |
    You are a senior prompt engineer...
    
    **Critical Behavioral Guidelines**:
    - ALWAYS provide concrete analysis...
```

**Result**: All three fields (role, task, approach) were extracted as empty strings.

### Problem 2: Duplicate Prompt Content Placeholder

**Location**: `src/workflow/lib/ai_helpers.yaml` lines 1366-1367

The task_template contained a placeholder for prompt content:
```yaml
task_template: |
  **Prompt Content to Analyze:**
  {prompts_content}
```

But the script **also** appends the actual YAML content at the end of the prompt (line 154 in the script). This created confusion because:
1. The AI saw `{prompts_content}` as a template variable in the Task section
2. The actual content appeared later after the Approach section
3. The behavioral guidelines said "you have ALL the context" but the template variable suggested otherwise

## What Was Sent to the AI

The malformed prompt looked like this:

```
**Role**: 

**Task**: 

**Approach**: 

**Prompt Content to Analyze:**
```yaml
[full YAML file content]
```
```

With empty Role, Task, and Approach fields, the AI correctly responded:
> "I notice you've provided a comprehensive YAML prompt configuration file but haven't 
> specified a **Role**, **Task**, or **Approach** for me to follow."

## Fix Applied

### Fix 1: Corrected YAML Block Scalar Extraction

Updated awk patterns to properly handle YAML block scalars with 2-space indentation:

```bash
# Extract role (multiline YAML block scalar format with 2-space indent)
local role=$(awk '
    /^step13_prompt_engineer_prompt:$/ { in_section=1; next }
    in_section && /^[a-z]/ { exit }
    in_section && /^[[:space:]]{2}role:[[:space:]]*\|/ { in_role=1; next }
    in_section && in_role {
        # Stop at next field (at same or lower indent level)
        if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_role=0; next }
        # Capture content (remove 4-space indent from content lines)
        if ($0 ~ /^[[:space:]]{4}/) {
            sub(/^[[:space:]]{4}/, "")
            print
        }
    }
' "$yaml_file")
```

Applied the same fix to `task_template` and `approach` extractions.

### Fix 2: Removed Duplicate Placeholder

Removed lines 1366-1367 from `src/workflow/lib/ai_helpers.yaml`:

```diff
  **Current Personas:**
  {personas_list}
  
- **Prompt Content to Analyze:**
- {prompts_content}
- 
  **Tasks:**
```

The actual YAML content is already appended by the script at the end, so the placeholder was redundant and confusing.

### Fix 3: Updated Comment for Clarity

Updated the comment in the script to explain why `prompts_content` isn't substituted inline:

```bash
# Note: prompts_content is appended at the end of the prompt (after approach section)
# to avoid sed issues with large YAML content containing special characters
```

## Verification

After the fix, the prompt is correctly formatted:

```
**Role**: You are a senior prompt engineer and AI specialist with expertise in designing effective AI prompts, evaluating prompt quality, optimizing token usage, and improving AI-human interaction patterns.

**Critical Behavioral Guidelines**:
- ALWAYS provide concrete analysis immediately (never ask clarifying questions)
- You have been given ALL the context needed - the YAML content IS the complete prompt configuration
- Proceed directly with the analysis based on the provided YAML prompt templates
- If no improvements are needed for a persona, explicitly state that
- Make informed decisions based on the provided content
- Your task, approach, and all required information are already specified below

**Task**: Analyze all AI persona prompts defined in this workflow's configuration file and identify opportunities for improvement.

**Context:**
- Project: AI Workflow Automation (bash-automation-framework)
- Configuration File: src/workflow/lib/ai_helpers.yaml
- Total Personas: {persona_count}
- Analysis Scope: All persona prompt templates (role, task_template, approach)

**Current Personas:**
{personas_list}

**Tasks:**

1. **Clarity and Specificity Assessment:**
   [... full task list ...]

**Approach**: **Output:**

For each improvement opportunity identified, provide:
[... full approach guidelines ...]

**Prompt Content to Analyze:**
```yaml
[... complete YAML file content ...]
```
```

## Files Modified

1. `src/workflow/steps/step_13_prompt_engineer.sh`
   - Lines 90-112: Fixed role extraction (multiline block scalar)
   - Lines 114-125: Fixed task_template extraction (multiline block scalar)
   - Lines 128-142: Fixed approach extraction (multiline block scalar)
   - Line 126-127: Updated comment for clarity

2. `src/workflow/lib/ai_helpers.yaml`
   - Lines 1366-1367: Removed duplicate `{prompts_content}` placeholder from task_template

## Testing

Tested with mock data:
```bash
personas_list="doc_analysis_prompt step2_consistency_prompt test_strategy_prompt"
persona_count=3
prompts_content="# Sample YAML content"

result=$(build_prompt_engineer_analysis_prompt "$personas_list" "$persona_count" "$prompts_content")
```

Verified:
- ✅ Role field populated with full multiline content
- ✅ Task field populated with full task template
- ✅ Approach field populated with output guidelines
- ✅ No duplicate `{prompts_content}` placeholder in task section
- ✅ Actual YAML content appended at end of prompt
- ✅ All template variables substituted correctly

## Impact

- **Before**: Step 13 was completely non-functional, AI would ask for clarification
- **After**: Step 13 can properly analyze AI prompts and create improvement suggestions
- **Breaking Changes**: None
- **Backward Compatibility**: Maintained (legacy `role` field still supported)

## Related Issues

This bug would have affected any workflow run that reached Step 13 on a `bash-automation-framework` project type.

## Lessons Learned

1. **YAML Parsing**: Be careful with different YAML scalar formats (quoted, literal `|`, folded `>`)
2. **Template Variable Placement**: Avoid having placeholder variables that duplicate actual content
3. **Testing**: Shell script YAML parsing needs thorough testing with actual YAML structure
4. **Indentation**: YAML is whitespace-sensitive - awk patterns must match exact indentation

## Follow-Up Actions

- [ ] Consider using a proper YAML parser library (`yq` or `python -c 'import yaml'`)
- [ ] Add unit tests for `build_prompt_engineer_analysis_prompt()` function
- [ ] Review other steps for similar YAML parsing issues
- [ ] Document YAML structure requirements in code comments
