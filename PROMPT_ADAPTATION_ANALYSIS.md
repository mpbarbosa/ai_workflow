# Prompt Adaptation Analysis & Recommendation

**Date**: 2025-12-20
**Issue**: JavaScript-specific prompts with hardcoded project references
**Files Affected**: `src/workflow/lib/ai_helpers.yaml`

---

## Problem Statement

Several AI prompts in `ai_helpers.yaml` contain hardcoded references to a specific project:
- "MP Barbosa Personal Website"
- JavaScript/Node.js/npm specific details
- Jest testing framework assumptions
- ES Modules specific mentions

### Affected Prompts

| Prompt | Line | Hardcoded References |
|--------|------|---------------------|
| `step5_test_review_prompt` | 351 | "MP Barbosa Personal Website", Jest, npm, ES Modules |
| `step6_test_gen_prompt` | 440-441 | "MP Barbosa Personal Website", Jest, npm test |
| `step8_dependencies_prompt` | 515-516 | "MP Barbosa Personal Website", npm specific |
| `step9_code_quality_prompt` | 597-598 | "MP Barbosa Personal Website", JavaScript, Jest |
| `step10_context_prompt` | 678 | "MP Barbosa Personal Website" |

---

## Analysis: Option 1 vs Option 2

### Option 1: Rewrite to Be More General

**Approach**: Replace hardcoded references with placeholders/variables

**Pros:**
✅ Single source of truth - easier to maintain
✅ Works for all project types automatically  
✅ Consistent with existing project kind system
✅ Reduces duplication
✅ Already have variables like `{test_framework}`, `{node_version}`

**Cons:**
⚠️ May lose specificity for JavaScript projects
⚠️ Requires careful placeholder design
⚠️ Some language-specific best practices may be lost

### Option 2: Keep Original + Add Project-Kind Variants

**Approach**: Create separate prompts for each project kind

**Pros:**
✅ Maximum specificity for each language
✅ Can preserve detailed JavaScript guidance
✅ Easier to add language-specific best practices
✅ More tailored recommendations

**Cons:**
❌ High maintenance burden (multiply prompts by project kinds)
❌ Duplication of common content
❌ Risk of inconsistency across variants
❌ Current system has 7+ project kinds = lots of duplication
❌ Goes against DRY principle

---

## Recommendation: **Option 1 (Generalize)**

### Rationale

1. **System Already Designed for This**
   - The codebase already uses project kind detection
   - Variables like `{test_framework}`, `{primary_language}` exist
   - The `project_kinds.yaml` already defines language-specific details

2. **Scalability**
   - 7+ project kinds × 5 affected prompts = 35+ prompt variants
   - Unsustainable maintenance burden
   - Hard to keep consistent

3. **Existing Pattern**
   - Other prompts already use placeholders successfully
   - The `documentation_specialist` persona is already project-aware

4. **Preservation of Specificity**
   - Can inject language-specific guidance via variables
   - Can reference language-specific style guides dynamically
   - Better separation of concerns

---

## Implementation Strategy

### Phase 1: Replace Hardcoded Project Name

**Before:**
```yaml
**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
```

**After:**
```yaml
**Context:**
- Project: {project_name} ({project_description})
- Primary Language: {primary_language}
- Technology Stack: {tech_stack_summary}
```

### Phase 2: Generalize Test Framework References

**Before:**
```yaml
- Test Framework: Jest with ES Modules (experimental-vm-modules)
- Test Command: npm test (with experimental VM modules for ES6)
```

**After:**
```yaml
- Test Framework: {test_framework}
- Test Command: {test_command}
- Test Environment: {test_environment}
```

### Phase 3: Generalize Package Manager References

**Before:**
```yaml
- Package Manager: npm
- npm Version: {npm_version}
```

**After:**
```yaml
- Package Manager: {package_manager}
- Package Manager Version: {package_manager_version}
```

### Phase 4: Add Language-Specific Sections (Dynamic)

**Before:**
```yaml
**Testing Standards to Apply:**
- Jest best practices for ES Modules
- AAA pattern (Arrange-Act-Assert)
```

**After:**
```yaml
**Testing Standards to Apply:**
{language_specific_testing_standards}
- AAA pattern (Arrange-Act-Assert)
- Clear test descriptions (behavior-focused)
```

Where `{language_specific_testing_standards}` is populated from `project_kinds.yaml`:

```yaml
# In project_kinds.yaml
testing_standards:
  javascript: "Jest/Vitest best practices for ES Modules"
  python: "Pytest best practices with fixtures"
  shell_automation: "BATS testing conventions"
  rust: "Cargo test best practices"
```

---

## Implementation Plan

### Step 1: Create Variable Mapping

Add to existing functions that build AI prompts:

```bash
# In ai_helpers.sh or project_kind_config.sh
get_project_context_variables() {
    local project_kind="$1"
    
    # Read from .workflow-config.yaml and project_kinds.yaml
    local project_name=$(get_project_name)
    local project_desc=$(get_project_description)
    local primary_lang=$(get_primary_language)
    local tech_stack=$(get_tech_stack_summary)
    local test_framework=$(get_test_framework)
    local test_command=$(get_test_command)
    local package_manager=$(get_package_manager)
    local language_standards=$(get_language_specific_standards "$project_kind")
    
    # Return as key=value pairs for substitution
    echo "project_name=$project_name"
    echo "project_description=$project_desc"
    echo "primary_language=$primary_lang"
    # ... etc
}
```

### Step 2: Update Prompt Templates

For each affected prompt in `ai_helpers.yaml`:

1. Replace hardcoded "MP Barbosa Personal Website" with `{project_name}`
2. Replace "static HTML + JavaScript with ES Modules" with `{project_description}`
3. Replace "Jest" with `{test_framework}`
4. Replace "npm" with `{package_manager}`
5. Add new variable `{language_specific_standards}`

### Step 3: Extend Project Kinds Configuration

Add language-specific guidance to `project_kinds.yaml`:

```yaml
nodejs_api:
  testing_standards:
    - "Jest/Vitest best practices"
    - "Express middleware testing patterns"
    - "Supertest for API testing"
  
  style_guides:
    - "Airbnb JavaScript Style Guide"
    - "Node.js Best Practices"
  
  best_practices:
    - "Use async/await for async operations"
    - "Handle errors with proper HTTP status codes"

shell_automation:
  testing_standards:
    - "BATS testing conventions"
    - "Test with set -euo pipefail"
  
  style_guides:
    - "Google Shell Style Guide"
    - "ShellCheck recommendations"
  
  best_practices:
    - "Quote all variable expansions"
    - "Use [[ ]] for conditionals"
```

### Step 4: Update Prompt Building Functions

Modify functions like `build_test_review_prompt()`:

```bash
build_test_review_prompt() {
    local project_kind=$(get_project_kind)
    
    # Get all context variables
    local context_vars=$(get_project_context_variables "$project_kind")
    
    # Load base template from YAML
    local template=$(get_yaml_section "step5_test_review_prompt" "task_template")
    
    # Substitute all variables
    local final_prompt=$(substitute_template_variables "$template" "$context_vars")
    
    echo "$final_prompt"
}
```

---

## Example Transformation

### Before (Hardcoded)

```yaml
step5_test_review_prompt:
  task_template: |
    **Context:**
    - Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
    - Test Framework: Jest with ES Modules (experimental-vm-modules)
    - Test Command: npm test (with experimental VM modules for ES6)
    - Coverage: Available via npm run test:coverage
    
    **Testing Standards to Apply:**
    - Jest best practices for ES Modules
    - AAA pattern (Arrange-Act-Assert)
```

### After (Generalized)

```yaml
step5_test_review_prompt:
  task_template: |
    **Context:**
    - Project: {project_name} ({project_description})
    - Primary Language: {primary_language}
    - Test Framework: {test_framework}
    - Test Command: {test_command}
    - Coverage Command: {coverage_command}
    
    **Testing Standards to Apply:**
    {language_specific_testing_standards}
    - AAA pattern (Arrange-Act-Assert)
    - Clear test descriptions (behavior-focused)
    - Proper async handling (language-specific)
```

### Runtime Values (JavaScript Project)

```
project_name: "MP Barbosa Personal Website"
project_description: "static HTML + JavaScript with ES Modules"
primary_language: "javascript"
test_framework: "Jest"
test_command: "npm test"
coverage_command: "npm run test:coverage"
language_specific_testing_standards:
  - Jest best practices for ES Modules
  - Proper mock usage with jest.mock()
  - Async/await patterns for async tests
```

### Runtime Values (Shell Project)

```
project_name: "AI Workflow Automation"
project_description: "Shell script automation with modular architecture"
primary_language: "bash"
test_framework: "BATS"
test_command: "./test_modules.sh"
coverage_command: "N/A"
language_specific_testing_standards:
  - BATS testing conventions
  - Test with set -euo pipefail
  - Mock external commands
```

---

## Benefits of This Approach

### 1. Maintainability
- ✅ Single prompt template per persona
- ✅ Language-specific details in one place (`project_kinds.yaml`)
- ✅ Easy to add new project kinds

### 2. Consistency
- ✅ Same prompt structure for all languages
- ✅ No risk of drift between variants
- ✅ Centralized best practices

### 3. Flexibility
- ✅ Can still add language-specific guidance
- ✅ Variables can be as detailed as needed
- ✅ Easy to override per-project

### 4. Scalability
- ✅ Adding new project kind = update config file only
- ✅ No need to duplicate prompts
- ✅ Works with existing detection system

---

## Migration Checklist

- [ ] Create `get_project_context_variables()` function
- [ ] Add language-specific sections to `project_kinds.yaml`
- [ ] Update `step5_test_review_prompt` in `ai_helpers.yaml`
- [ ] Update `step6_test_gen_prompt` in `ai_helpers.yaml`
- [ ] Update `step8_dependencies_prompt` in `ai_helpers.yaml`
- [ ] Update `step9_code_quality_prompt` in `ai_helpers.yaml`
- [ ] Update `step10_context_prompt` in `ai_helpers.yaml`
- [ ] Update prompt building functions
- [ ] Test with JavaScript project
- [ ] Test with Shell project
- [ ] Test with Python project
- [ ] Update documentation

---

## Conclusion

**Recommendation: Implement Option 1 (Generalize)**

This approach:
- Aligns with existing system design
- Reduces maintenance burden
- Maintains language-specific guidance through variables
- Scales well for new project types
- Follows DRY principles

The key is thoughtful variable design and comprehensive `project_kinds.yaml` configuration.

---

**Status**: Analysis Complete
**Next Step**: Implement generalized prompts with project-kind-specific variables
**Estimated Effort**: 2-3 hours for full implementation
