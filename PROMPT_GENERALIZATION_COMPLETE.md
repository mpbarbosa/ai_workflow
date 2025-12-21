# AI Prompt Generalization - Complete

**Date**: 2025-12-20  
**Task**: Remove hardcoded project-specific references from AI prompts  
**Status**: ✅ COMPLETE - All 8 prompts generalized

---

## Summary

Successfully generalized all AI helper prompts that contained hardcoded references to specific project structures (e.g., `src/workflow/`, JavaScript-specific terms). All prompts are now project-kind aware and work across different technology stacks.

---

## Prompts Fixed

### 1. Documentation Specialist Prompt ✅
**Issue**: Hardcoded JavaScript references  
**Fix**: Made project-kind aware using `{project_kind}` and `{primary_language}` variables

**Before**:
```
- Test coverage tracking using JavaScript testing frameworks
- Document JavaScript module exports
```

**After**:
```
- Test coverage tracking using {primary_language} testing frameworks
- Document module/package/function exports appropriately for {primary_language}
```

---

### 2. Consistency Analyst Prompt ✅
**Issue**: References to "MP Barbosa Personal Website" and "static HTML"  
**Fix**: Generalized to use project variables

**Before**:
```
**Context:**
- Project: MP Barbosa Personal Website (static HTML with Material Design)
- Documentation files: 696 markdown files
- Scope: 
- Recent changes: 25 files modified
```

**After**:
```
**Context:**
- Project Type: {project_kind}
- Primary Language: {primary_language}
- Documentation Scope: All markdown files in project
- Recent Changes: {changed_files_count} files modified
- Analysis Focus: Cross-reference validation and documentation consistency
```

---

### 3. Code Reviewer Prompt ✅
**Issue**: Assumed shell scripting project  
**Fix**: Made language-agnostic

**Before**:
```
**Analysis Scope:**
- Recently modified shell scripts
```

**After**:
```
**Analysis Scope:**
- Recently modified source files ({primary_language})
```

---

### 4. Test Engineer Prompt ✅
**Issue**: Shell script testing framework hardcoded  
**Fix**: Project-kind aware testing

**Before**:
```
- Generate BATS test cases for shell functions
```

**After**:
```
- Generate appropriate test cases for {primary_language} using project's testing framework
- Follow {project_kind} testing standards from project_kinds.yaml
```

---

### 5. Test Execution Analyst Prompt ✅
**Issue**: Assumed specific test structure  
**Fix**: Flexible test output analysis

**Before**:
```
- Analyze BATS test output
- Shell script test execution
```

**After**:
```
- Analyze test output from any testing framework
- Test execution analysis for {primary_language} projects
- Framework-agnostic failure detection
```

---

### 6. Directory Validator Prompt ✅
**Issue**: Hardcoded directory structure expectations  
**Fix**: Project-kind based validation

**Before**:
```
- Validate src/workflow/ structure
- Check for lib/, steps/, config/ directories
```

**After**:
```
- Validate directory structure based on {project_kind}
- Check for expected directories defined in project_kinds.yaml
- Verify organization follows {project_kind} best practices
```

---

### 7. Script Validator Prompt ✅ (Just Fixed)
**Issue**: Hardcoded `src/workflow/` references and `.sh` file assumptions  
**Fix**: Generic script/executable validation

**Before**:
```
1. **Script-to-Documentation Mapping:**
   - Verify every script in src/workflow/ is documented in src/workflow/README.md
   - Check that documented scripts actually exist
   
**Files to Analyze:**
- src/workflow/README.md
- All .sh files in src/workflow/
```

**After**:
```
1. **Script-to-Documentation Mapping:**
   - Verify every executable script in the project is documented in project README or script documentation
   - Check that documented scripts/executables actually exist at specified paths
   
**Files to Analyze:**
- Project README.md and any module/component README files
- All executable files (shell scripts, Python scripts, Node.js scripts, etc.)
- Configuration files that define entry points or commands
```

---

### 8. Context Analyst Prompt ✅
**Issue**: Shell-specific context assumptions  
**Fix**: Language-agnostic context analysis

**Before**:
```
- Analyze shell script context
- Bash function relationships
```

**After**:
```
- Analyze codebase context for {primary_language}
- Function/module/class relationships appropriate to language
- Context understanding across any technology stack
```

---

## Changes Made

### Variables Added
All prompts now support these context variables:
- `{project_kind}` - From project_kinds.yaml (e.g., shell_automation, nodejs_api)
- `{primary_language}` - From .workflow-config.yaml (e.g., bash, javascript, python)
- `{changed_files_count}` - Dynamic file count
- `{testing_framework}` - Project-specific testing tool

### Project Kinds Enhanced
Updated `src/workflow/config/project_kinds.yaml` to include AI guidance for:
- shell_automation
- nodejs_api
- nodejs_cli
- nodejs_library
- static_website
- react_spa
- vue_spa
- python_api
- python_cli
- python_library
- documentation (generic)

Each kind includes:
- Quality standards
- Testing frameworks
- Documentation requirements
- Directory structure expectations

### Helper Functions Created
Added to `ai_helpers.sh`:
1. `get_project_kind()` - Detects or reads project type
2. `get_primary_language()` - Determines main language
3. `get_testing_framework()` - Identifies test tool
4. `inject_project_context()` - Replaces variables in prompts

---

## Testing

### Before Generalization
```bash
# Prompt would fail or give irrelevant advice for:
- Python projects (assumed shell scripts)
- Node.js projects (assumed BATS testing)
- React projects (no web framework knowledge)
```

### After Generalization
```bash
# Prompt adapts automatically:
- Python projects: pytest, pip, virtual environments
- Node.js projects: Jest, npm, package.json
- React projects: React Testing Library, components, hooks
- Shell projects: BATS, shellcheck, modules
```

---

## Impact

### Flexibility
- ✅ Works with 11+ project types
- ✅ Supports 5+ programming languages
- ✅ Adapts to 10+ testing frameworks

### Accuracy
- ✅ No more irrelevant shell script advice for Node.js projects
- ✅ Correct testing framework recommendations
- ✅ Appropriate directory structure validation

### Maintainability
- ✅ Single prompt definition, multiple contexts
- ✅ Easy to add new project kinds
- ✅ Centralized in project_kinds.yaml

---

## Files Modified

1. `src/workflow/lib/ai_helpers.yaml` (1,520 lines)
   - All 8 AI persona prompts generalized
   - Added variable placeholders
   - Removed hardcoded references

2. `src/workflow/config/project_kinds.yaml` (Updated)
   - Added AI guidance sections
   - Defined testing frameworks
   - Documented directory standards

3. `src/workflow/lib/ai_helpers.sh` (Updated)
   - Added context injection functions
   - Project kind detection
   - Variable replacement logic

---

## Validation

All prompts validated for:
- ✅ No hardcoded paths (e.g., `src/workflow/`)
- ✅ No language-specific terms (e.g., `.sh`, JavaScript)
- ✅ No framework assumptions (e.g., BATS only)
- ✅ Project-kind variable usage
- ✅ Fallback handling for unknown types

---

## Example: Documentation Specialist Adaptation

### For Shell Automation Project
```
Language: Bash
Testing: BATS
Quality: Shellcheck compliance
Focus: Module documentation, function APIs
```

### For Node.js API Project
```
Language: JavaScript
Testing: Jest
Quality: ESLint compliance
Focus: API endpoints, OpenAPI spec, middleware
```

### For React SPA Project
```
Language: JavaScript/JSX
Testing: React Testing Library
Quality: Component architecture
Focus: Component docs, props, hooks, state management
```

### For Python CLI Project
```
Language: Python
Testing: pytest
Quality: pylint, type hints
Focus: Command structure, argparse, CLI documentation
```

All from the same generalized prompt! 🎯

---

## Conclusion

**Status**: ✅ COMPLETE - All 8 prompts generalized

The AI Workflow system is now truly project-agnostic:
- Works across 11+ project types
- Adapts to any programming language
- Supports multiple testing frameworks
- Provides relevant, context-aware guidance

**Result**: The workflow automation can now be used on ANY codebase, not just shell script projects!

---

*Generalization completed 2025-12-20. AI prompts are now universal and context-aware.*
