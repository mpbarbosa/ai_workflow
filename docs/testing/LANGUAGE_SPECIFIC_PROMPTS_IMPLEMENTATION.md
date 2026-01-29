# Language-Specific Prompt Substitution Implementation

**Version**: 2.7.0  
**Date**: 2026-01-01  
**Status**: ✅ Implemented and Tested

## Overview

Implemented dynamic language-specific content substitution in AI prompts. The system now properly replaces template placeholders like `{language_specific_documentation}` with actual language-specific guidelines based on the project's `PRIMARY_LANGUAGE` setting.

## Problem Fixed

### Before
Prompts contained unresolved placeholders:
```
**Language-Specific Standards:** {language_specific_documentation}
```

This resulted in AI receiving incomplete guidance without language-specific best practices.

### After
Prompts contain actual language-specific content:
```
**Language-Specific Standards:** 
• Use JSDoc format with @param, @returns, @throws tags
• Document async/await patterns and promise chains
• Include TypeScript types when applicable
• Reference npm packages with correct versions
• Follow MDN Web Docs style for web APIs

**Documentation Format:** JSDoc 3

**Example:**
/**
 * Fetches user data from the API
 * @param {string} userId - User identifier
 * @returns {Promise<User>} User object
 * @throws {Error} If user not found
 */
async function getUser(userId) { ... }
```

## Implementation

### New Functions

#### 1. get_language_specific_content()

**Location**: `src/workflow/lib/ai_prompt_builder.sh` (lines 13-66)

**Purpose**: Extract and format language-specific content from YAML

**Signature**:
```bash
get_language_specific_content <yaml_file> <section_name> <language>
```

**Example**:
```bash
content=$(get_language_specific_content \
    "ai_helpers.yaml" \
    "language_specific_documentation" \
    "javascript")
```

**Returns**:
- Key points (bullet list)
- Documentation format (if available)
- Example code snippet (if available)
- Fallback generic guidance if language not found

#### 2. substitute_language_placeholders()

**Location**: `src/workflow/lib/ai_prompt_builder.sh` (lines 68-127)

**Purpose**: Replace all language-specific placeholders in prompt text

**Signature**:
```bash
substitute_language_placeholders <prompt_text> <yaml_file>
```

**Handles**:
- `{language_specific_documentation}` - Documentation standards
- `{language_specific_testing_standards}` - Testing practices  
- `{language_specific_quality}` - Code quality rules
- `{language_specific_directory_standards}` - Directory organization

**Behavior**:
1. Reads `PRIMARY_LANGUAGE` from environment or `.workflow-config.yaml`
2. If no language set, removes placeholder lines
3. If language set, extracts and substitutes content
4. Preserves formatting and newlines

### Integration Points

Updated 5 prompt building functions:
1. `build_doc_analysis_prompt()` - Step 1 (Documentation)
2. `build_consistency_prompt()` - Step 2 (Consistency)
3. `build_test_strategy_prompt()` - Step 5 (Test Review)
4. `build_quality_prompt()` - Step 9 (Code Quality)
5. `build_issue_extraction_prompt()` - Issue extraction

All now call `substitute_language_placeholders()` before returning the prompt.

## Supported Languages

Content is defined in `ai_helpers.yaml` for:

### 1. JavaScript
```yaml
language_specific_documentation:
  javascript:
    key_points: |
      • Use JSDoc format with @param, @returns, @throws tags
      • Document async/await patterns and promise chains
      • Include TypeScript types when applicable
      • Reference npm packages with correct versions
      • Follow MDN Web Docs style for web APIs
    doc_format: "JSDoc 3"
    example_snippet: |
      /**
       * Fetches user data from the API
       * @param {string} userId - User identifier
       * @returns {Promise<User>} User object
       * @throws {Error} If user not found
       */
      async function getUser(userId) { ... }
```

### 2. Python
```yaml
  python:
    key_points: |
      • Follow PEP 257 docstring conventions
      • Use type hints (PEP 484) consistently
      • Document exceptions with raises sections
      • Use Google/NumPy format for complex functions
      • Include examples in public API docstrings
    doc_format: "PEP 257 (Google/NumPy style)"
```

### 3. Go
```yaml
  go:
    key_points: |
      • Use godoc format, start with function/type name
      • Document all exported functions and types
      • Include examples in doc comments
      • Document error return values explicitly
      • Follow Go proverbs for design patterns
    doc_format: "godoc"
```

### 4. Java, Ruby, Rust, Shell, TypeScript
Similar structures defined for each language with appropriate standards.

## Configuration

### Setting PRIMARY_LANGUAGE

**Method 1**: `.workflow-config.yaml` (recommended)
```yaml
tech_stack:
  primary_language: "javascript"
```

**Method 2**: Environment variable
```bash
export PRIMARY_LANGUAGE="python"
./execute_tests_docs_workflow.sh
```

**Method 3**: Command-line (if implemented)
```bash
./execute_tests_docs_workflow.sh --language javascript
```

## Usage Examples

### Automatic Substitution

The substitution happens automatically when prompts are built:

```bash
# In Step 1 (Documentation Updates)
prompt=$(build_doc_analysis_prompt "$changed_files" "$doc_files")
# Prompt now contains JavaScript-specific documentation standards
```

### Manual Testing

```bash
# Source the module
source src/workflow/lib/ai_prompt_builder.sh

# Set language
export PRIMARY_LANGUAGE="javascript"

# Build prompt
prompt=$(build_doc_analysis_prompt "src/index.js" "README.md")

# Check content
echo "$prompt" | grep -A10 "Language-Specific"
```

## Benefits

### 1. Improved AI Guidance
- AI receives language-specific best practices
- More accurate documentation suggestions
- Better alignment with language conventions

### 2. Consistency
- Same standards applied across all projects using the same language
- Centralized management of language guidelines
- Easy to update standards globally

### 3. Scalability
- Easy to add new languages
- Existing projects benefit automatically
- No code changes needed to support new languages

### 4. Flexibility
- Works with or without language specification
- Graceful fallback to generic guidance
- Doesn't break existing workflows

## Testing

### Test Results

Tested on **ibira.js** (JavaScript project):

```
✅ Content extraction: SUCCESS
✅ Prompt substitution: SUCCESS
✅ Formatting preservation: SUCCESS
✅ JavaScript-specific content: FOUND

Output preview:
• Use JSDoc format with @param, @returns, @throws tags
• Document async/await patterns and promise chains
• Include TypeScript types when applicable
...
**Documentation Format:** JSDoc 3
```

### Test Scenarios

| Scenario | Result |
|----------|--------|
| PRIMARY_LANGUAGE=javascript | ✅ JSDoc standards applied |
| PRIMARY_LANGUAGE=python | ✅ PEP 257 standards applied |
| PRIMARY_LANGUAGE not set | ✅ Generic guidance (fallback) |
| Unsupported language | ✅ Generic guidance (fallback) |
| Multiple placeholders | ✅ All replaced correctly |

## Files Modified

1. **src/workflow/lib/ai_prompt_builder.sh** (+141 lines)
   - Added `get_language_specific_content()` function
   - Added `substitute_language_placeholders()` function
   - Integrated substitution into 5 prompt builders

**Total**: 141 lines added, 5 functions updated

## YAML Data Structure

The language-specific data in `ai_helpers.yaml` follows this structure:

```yaml
language_specific_documentation:
  <language>:
    key_points: |
      • Bullet point 1
      • Bullet point 2
    doc_format: "Format name"
    example_snippet: |
      code example
```

Similar structures exist for:
- `language_specific_testing`
- `language_specific_quality`
- `language_specific_directory`

## Fallback Behavior

When language is not specified or not found:

1. **Placeholder Removal**: Lines containing `{language_specific_*}` are removed
2. **Generic Guidance**: Falls back to general best practices
3. **No Errors**: Graceful degradation, workflow continues
4. **Logging**: Logs "PRIMARY_LANGUAGE not set" for debugging

## Performance Impact

- **Minimal overhead**: YAML parsing happens once per prompt
- **No network calls**: All data local
- **Cached**: yq results can be cached if needed
- **Estimated time**: <100ms per prompt

## Future Enhancements

Potential improvements:

1. **Caching**: Cache extracted content per language per session
2. **Language Detection**: Auto-detect from file extensions if not set
3. **Multi-Language**: Support projects with multiple primary languages
4. **Custom Standards**: Allow project-specific overrides via config
5. **Validation**: Warn if language set but no standards defined

## Migration Guide

### For Existing Projects

**No migration needed!** The feature is:
- ✅ Backward compatible
- ✅ Opt-in (works without configuration)
- ✅ Non-breaking (fallback to generic guidance)

### To Enable

Add to your `.workflow-config.yaml`:

```yaml
tech_stack:
  primary_language: "your_language_here"  # javascript, python, go, etc.
```

Run workflow as usual:
```bash
./execute_tests_docs_workflow.sh --auto
```

## Troubleshooting

### Issue: Placeholder Not Replaced

**Symptom**: Prompt contains `{language_specific_documentation}`

**Causes**:
1. PRIMARY_LANGUAGE not set
2. Language not supported in YAML
3. yq not installed or wrong version

**Solution**:
```bash
# Check PRIMARY_LANGUAGE
echo $PRIMARY_LANGUAGE

# Check .workflow-config.yaml
yq '.tech_stack.primary_language' .workflow-config.yaml

# Check yq availability
yq --version
```

### Issue: Wrong Language Standards Applied

**Symptom**: Getting Python standards for JavaScript project

**Cause**: PRIMARY_LANGUAGE set incorrectly

**Solution**:
```bash
# Verify setting
grep primary_language .workflow-config.yaml

# Update if needed
yq -i '.tech_stack.primary_language = "javascript"' .workflow-config.yaml
```

## Related Documentation

- **Main Config**: `docs/TECH_STACK_ADAPTIVE_FRAMEWORK.md`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`
- **AI Prompts**: `src/workflow/lib/ai_helpers.yaml`

## Conclusion

The language-specific prompt substitution feature successfully:
- ✅ Fixes the unresolved placeholder issue
- ✅ Provides language-appropriate AI guidance
- ✅ Works automatically with existing workflows
- ✅ Supports 8+ languages out of the box
- ✅ Gracefully handles edge cases
- ✅ Maintains backward compatibility

The implementation is production-ready and has been tested on a real project (ibira.js) with successful results.

---

**Version**: 2.7.0  
**Implementation Date**: 2026-01-01  
**Status**: Complete and Production-Ready
