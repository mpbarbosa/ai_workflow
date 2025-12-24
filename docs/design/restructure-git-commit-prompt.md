# Functional Requirements: Restructure Git Commit Prompt

**Feature ID**: FRQ-2024-006  
**Version**: 1.0.0  
**Date**: 2025-12-24  
**Author**: AI Workflow Automation Team  
**Status**: Draft  
**Priority**: Low  
**Category**: Clarity / Structure

## Executive Summary

Restructure the `step11_git_commit_prompt` to move conventional commit types from inline role description to a separate structured field. This improves readability, maintainability, and makes it easier to reference and update commit types.

## Problem Statement

### Current State

The `step11_git_commit_prompt` role embeds conventional commit types inline:

```yaml
step11_git_commit_prompt:
  role: "You are a senior git workflow specialist... Use these conventional commit types: feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (code restructuring), test (tests), chore (maintenance), perf (performance), ci (CI/CD)."
  task_template: |
    ...
```

**Issues**:
- **Verbosity**: 211 chars of role text devoted to listing types
- **Readability**: Long inline list is hard to scan
- **Maintainability**: Hard to update or add new commit types
- **Structure**: Mixed role description with reference data
- **Reusability**: Can't easily reference types elsewhere

**Current Role Length**: 420 chars (211 chars for types list)

### Desired State

Structured format with separate commit types field:

```yaml
step11_git_commit_prompt:
  role: "You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, and git best practices."
  
  commit_types: |
    - feat: New feature
    - fix: Bug fix
    - docs: Documentation only
    - style: Formatting, no code change
    - refactor: Code restructuring
    - test: Adding/updating tests
    - chore: Maintenance tasks
    - perf: Performance improvement
    - ci: CI/CD changes
  
  task_template: |
    Generate a professional conventional commit message using the commit types defined above.
    ...
```

**Benefits**:
- Cleaner role description
- Scannable commit types list
- Easier to update types
- Better structure
- Token savings (~10-15)

## Functional Requirements

### FR-1: Extract Commit Types to Separate Field
**Priority**: High  
**Requirement**: Create new `commit_types` field with structured list

**Acceptance Criteria**:
- New `commit_types` field added
- Markdown bullet list format for easy scanning
- Each type with clear, concise description
- All 9 conventional commit types included

**Commit Types to Include**:
```yaml
commit_types: |
  - feat: New feature or capability
  - fix: Bug fix
  - docs: Documentation only changes
  - style: Formatting, whitespace, no code change
  - refactor: Code restructuring without behavior change
  - test: Adding or updating tests
  - chore: Maintenance tasks, tooling, dependencies
  - perf: Performance improvement
  - ci: CI/CD pipeline changes
```

### FR-2: Simplify Role Description
**Priority**: High  
**Requirement**: Remove commit types list from role, keep expertise description

**Acceptance Criteria**:
- Commit types list removed from role
- Expertise areas preserved
- Clear, concise role description
- Reference to using "conventional commit types"

**New Role**:
```yaml
role: "You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, git best practices, and commit message optimization. Use the conventional commit types defined below to generate clear, informative commit messages."
```

### FR-3: Update Task Template Reference
**Priority**: Medium  
**Requirement**: Update task template to reference the new field

**Acceptance Criteria**:
- Task template references "commit types defined above"
- Clear instruction to use structured types
- No breaking changes to task flow

**Example Update**:
```yaml
task_template: |
  Generate a professional conventional commit message using the commit types defined above.
  
  **Available Commit Types:** Reference the commit_types field above
  ...
```

### FR-4: Update Prompt Builder Function
**Priority**: High  
**Requirement**: Ensure `build_step11_git_commit_prompt()` handles new structure

**Acceptance Criteria**:
- Function extracts `commit_types` field
- Includes commit types in generated prompt
- Backward compatible with existing usage
- No breaking changes

**Implementation**:
```bash
# In build_step11_git_commit_prompt()
commit_types=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
    /commit_types: \|/ {flag=1; next}
    /^[[:space:]]+task_template:/ {flag=0}
    flag && /^[[:space:]]{4}/ {
        sub(/^[[:space:]]{4}/, "");
        print
    }
')
```

### FR-5: Validation
**Priority**: High  
**Requirement**: Verify no breaking changes

**Acceptance Criteria**:
- YAML parses correctly
- All 9 commit types present
- Prompt builder extracts correctly
- Generated prompts include commit types
- Backward compatible

## Non-Functional Requirements

### NFR-1: Backward Compatibility
- No breaking changes to generated prompts
- Same commit message quality
- Existing workflows unaffected

### NFR-2: Clarity
- More scannable structure
- Easier to understand and update
- Self-documenting format

### NFR-3: Maintainability
- Easy to add new commit types
- Clear separation of concerns
- Structured reference data

## Technical Design

### YAML Structure Changes

**Before**:
```yaml
step11_git_commit_prompt:
  role: "You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, git best practices, technical writing, and commit message optimization. Use these conventional commit types: feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (code restructuring), test (tests), chore (maintenance), perf (performance), ci (CI/CD)."
  
  task_template: |
    Generate a professional conventional commit message...
```

**After**:
```yaml
step11_git_commit_prompt:
  role: "You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, git best practices, and commit message optimization. Use the conventional commit types defined below to generate clear, informative commit messages."
  
  commit_types: |
    - feat: New feature or capability
    - fix: Bug fix
    - docs: Documentation only changes
    - style: Formatting, whitespace, no code change
    - refactor: Code restructuring without behavior change
    - test: Adding or updating tests
    - chore: Maintenance tasks, tooling, dependencies
    - perf: Performance improvement
    - ci: CI/CD pipeline changes
  
  task_template: |
    Generate a professional conventional commit message using the commit types defined above.
    
    **Available Commit Types:**
    {commit_types}
    ...
```

### Prompt Builder Update

Update `build_step11_git_commit_prompt()` in `ai_helpers.sh`:

```bash
build_step11_git_commit_prompt() {
    # ... existing parameter extraction ...
    
    # Extract commit_types (new)
    commit_types=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
        /commit_types: \|/ {flag=1; next}
        /^[[:space:]]+task_template:/ {flag=0}
        flag && /^[[:space:]]{4}/ {
            sub(/^[[:space:]]{4}/, "");
            print
        }
    ')
    
    # Replace {commit_types} in task template
    task="${task//\{commit_types\}/$commit_types}"
    
    # ... rest of function ...
}
```

## Test Plan

### Test Case 1: YAML Validity
**Objective**: Verify YAML parses correctly

```bash
python3 -c "import yaml; yaml.safe_load(open('src/workflow/lib/ai_helpers.yaml'))" && echo "✅ YAML valid"
```

**Expected**: No parsing errors

### Test Case 2: Commit Types Field Present
**Objective**: Verify new field exists and contains all types

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

gcp = data['step11_git_commit_prompt']
assert 'commit_types' in gcp, "commit_types field missing"

commit_types = gcp['commit_types']
required_types = ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci']

for ctype in required_types:
    assert ctype in commit_types, f"Missing commit type: {ctype}"

print("✅ All 9 commit types present")
```

**Expected**: All assertions pass

### Test Case 3: Role Simplified
**Objective**: Verify role no longer contains inline types

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

role = data['step11_git_commit_prompt']['role']

# Should not contain the old inline list
assert 'feat (new feature)' not in role, "Role still contains inline types"
assert 'Use these conventional commit types:' not in role, "Role still has old pattern"

# Should be shorter
assert len(role) < 300, f"Role too long: {len(role)} chars"

print("✅ Role simplified")
```

**Expected**: Assertions pass, role is concise

### Test Case 4: Prompt Builder Extraction
**Objective**: Verify prompt builder can extract commit_types

```bash
source src/workflow/lib/ai_helpers.sh

# Test extraction (simplified)
yaml_file="src/workflow/lib/ai_helpers.yaml"
commit_types=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
    /commit_types: \|/ {flag=1; next}
    /^[[:space:]]+task_template:/ {flag=0}
    flag && /^[[:space:]]{4}/ {
        sub(/^[[:space:]]{4}/, "");
        print
    }
')

echo "$commit_types" | grep -q "feat:" && echo "✅ Can extract commit_types"
```

**Expected**: Extraction successful

### Test Case 5: Structure Validation
**Objective**: Verify all expected fields present

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

gcp = data['step11_git_commit_prompt']

required_fields = ['role', 'commit_types', 'task_template', 'approach']
for field in required_fields:
    assert field in gcp, f"Missing field: {field}"

print("✅ All required fields present")
```

**Expected**: All fields present

### Test Case 6: Format Validation
**Objective**: Verify commit types use bullet list format

```python
import yaml

with open('src/workflow/lib/ai_helpers.yaml') as f:
    data = yaml.safe_load(f)

commit_types = data['step11_git_commit_prompt']['commit_types']

# Check for bullet list format
lines = [l.strip() for l in commit_types.split('\n') if l.strip()]
bullet_lines = [l for l in lines if l.startswith('-')]

assert len(bullet_lines) == 9, f"Expected 9 bullet items, got {len(bullet_lines)}"
print("✅ Commit types use proper bullet format")
```

**Expected**: Proper bullet list format

## Success Criteria

1. ✅ `commit_types` field added with all 9 types
2. ✅ Role simplified (< 300 chars)
3. ✅ Task template references new field
4. ✅ YAML parses correctly
5. ✅ All tests pass (6/6)
6. ✅ Backward compatible

## Impact Analysis

### Benefits

1. **Clarity**: Scannable, structured commit types
2. **Maintainability**: Easy to add/update types
3. **Separation**: Role vs reference data separated
4. **Token Efficiency**: ~10-15 token savings
5. **Reusability**: Types can be referenced elsewhere

### Token Savings Analysis

**Before** (role):
```
Use these conventional commit types: feat (new feature), fix (bug fix), docs (documentation), style (formatting), refactor (code restructuring), test (tests), chore (maintenance), perf (performance), ci (CI/CD).
```
~211 chars, ~50 tokens

**After** (commit_types field):
```
- feat: New feature or capability
- fix: Bug fix
- docs: Documentation only changes
...
```
~350 chars but more structured

**Net Impact**: Slightly more chars but better structure. The reference format is clearer for AI interpretation.

### Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Prompt builder breaks | High | Low | Test extraction thoroughly |
| AI ignores new format | Medium | Very Low | Clear reference in task |
| Structure overhead | Low | None | More readable format |

## Implementation Timeline

1. **Analysis** (Complete) - 10 minutes
2. **Update YAML** - 15 minutes
3. **Update Prompt Builder** - 20 minutes
4. **Testing** - 15 minutes
5. **Documentation** - 10 minutes

**Total Estimated Time**: 70 minutes (~1.2 hours)

## Acceptance Checklist

- [ ] FR-1: commit_types field added
- [ ] FR-2: Role simplified
- [ ] FR-3: Task template updated
- [ ] FR-4: Prompt builder updated
- [ ] FR-5: Validation complete
- [ ] NFR-1: Backward compatible
- [ ] NFR-2: Clarity improved
- [ ] NFR-3: Maintainability enhanced
- [ ] All test cases pass (6/6)
- [ ] YAML valid
- [ ] Documentation complete

## Related Issues

- **Category**: Clarity, Structure
- **Severity**: Low (doesn't break functionality, improves quality)
- **Related to**: Other prompt improvements (FRQ-2024-001 through FRQ-2024-005)

## References

- **YAML File**: `src/workflow/lib/ai_helpers.yaml`
- **Prompt Builder**: `src/workflow/lib/ai_helpers.sh::build_step11_git_commit_prompt()`
- **Usage**: Step 11 (git commit message generation)

## Appendix A: Conventional Commit Types

**Standard Types** (from Conventional Commits specification):
- `feat`: New feature for the user
- `fix`: Bug fix for the user
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process or auxiliary tools
- `perf`: Code change that improves performance
- `ci`: Changes to CI configuration files and scripts

## Appendix B: Example Output

**Before**:
```
**Role**: You are a senior git workflow specialist... Use these conventional commit types: feat (new feature), fix (bug fix)...

**Task**: Generate a professional conventional commit message...
```

**After**:
```
**Role**: You are a senior git workflow specialist... Use the conventional commit types defined below...

**Commit Types:**
- feat: New feature or capability
- fix: Bug fix
- docs: Documentation only changes
...

**Task**: Generate a professional conventional commit message using the commit types defined above...
```

---

**Document Status**: ✅ Ready for Implementation  
**Approach**: Restructure with separate commit_types field  
**Next Steps**: Update YAML structure and prompt builder
