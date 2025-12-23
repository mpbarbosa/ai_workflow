# Adaptive Pre-Flight Checks - Implementation Summary

## Problem Statement

The workflow automation system was encountering errors when run on non-Node.js projects:

```
⚠️  WARNING: node_modules not found. Installing dependencies...
npm error code ENOENT
npm error syscall open
npm error path /home/mpb/Documents/GitHub/ai_workflow/src/package.json
npm error errno -2
npm error enoent Could not read package.json: Error: ENOENT: no such file or directory
```

**Root Cause**: The workflow was hardcoded to assume all projects are Node.js-based with `package.json` files.

## Solution Overview

Implemented **adaptive pre-flight checks** that automatically detect the project's technology stack and adjust validation requirements accordingly.

### Key Principle
> Every project repository has its own properties and tech stack (programming language), therefore the automation workflow must do adaptive pre-flight checks according to the project characteristics.

## Implementation Details

### 1. Technology Stack Detection

Created `detect_project_tech_stack()` function that identifies projects by scanning for characteristic files:

```bash
detect_project_tech_stack() {
    local tech_stack=()
    
    # Check for Node.js
    if [[ -f "$SRC_DIR/package.json" ]] || [[ -f "$PROJECT_ROOT/package.json" ]]; then
        tech_stack+=("nodejs")
    fi
    
    # Check for Python
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]] || \
       [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        tech_stack+=("python")
    fi
    
    # Check for Ruby, Go, Rust, Java...
    # ...
    
    # Default to shell if no package files found
    if [[ ${#tech_stack[@]} -eq 0 ]]; then
        tech_stack+=("shell")
    fi
    
    echo "${tech_stack[@]}"
}
```

### 2. Adaptive Validation Logic

Modified validation functions to behave differently based on detected tech stack:

#### Node.js Projects (Strict Requirements)
```bash
if [[ " ${tech_stack[*]} " =~ " nodejs " ]]; then
    # REQUIRES package.json
    # REQUIRES Node.js and npm
    # Validates node_modules
    # Runs npm install if needed
    # Runs npm audit for security
fi
```

#### Shell/Bash Projects (Relaxed Requirements)
```bash
elif [[ " ${tech_stack[*]} " =~ " shell " ]]; then
    # Node.js/npm marked as OPTIONAL
    # Skips package.json requirement
    # Skips dependency installation
    # Validates git repository only
fi
```

#### Other Projects (Graceful Handling)
```bash
else
    # Node.js/npm marked as OPTIONAL
    # Skips npm-specific validations
    # Returns success/warning status
fi
```

### 3. Modified Components

#### File: `src/workflow/lib/validation.sh`
- ✅ Added `detect_project_tech_stack()`
- ✅ Updated `check_prerequisites()` to use tech detection
- ✅ Updated `validate_dependencies()` to be adaptive
- ✅ Exported new function

**Lines Modified**: ~60 lines added/changed

#### File: `src/workflow/execute_tests_docs_workflow.sh`
- ✅ Updated `check_prerequisites()` with inline tech detection
- ✅ Updated `validate_dependencies()` to be adaptive
- ✅ Added clear logging of detected tech stack

**Lines Modified**: ~90 lines added/changed

#### File: `src/workflow/steps/step_08_dependencies.sh`
- ✅ Added `detect_project_tech_stack_step8()`
- ✅ Updated `step8_validate_dependencies()` to handle multiple tech stacks
- ✅ Shell projects: Skip with ✅ success status
- ✅ Non-Node.js: Skip with ⚠️ warning status
- ✅ Exported new function

**Lines Modified**: ~70 lines added/changed

## Testing

### Test Script
Created `test_adaptive_checks.sh` to verify functionality:

```bash
./test_adaptive_checks.sh
```

**Results**: All tests pass ✅
- ✓ Tech stack detection works
- ✓ Shell projects don't require package.json
- ✓ Node.js/npm are optional for shell projects
- ✓ Git validation works
- ✓ Can detect multiple tech stacks

### Manual Verification

Before (Error):
```
⚠️  WARNING: node_modules not found. Installing dependencies...
npm error code ENOENT
npm error path /home/mpb/Documents/GitHub/ai_workflow/src/package.json
```

After (Success):
```
✅ Tech stack detected: shell
ℹ️  Node.js available: v25.2.1 (not required for this project)
ℹ️  npm available: 11.7.0 (not required for this project)
...
ℹ️  Shell/Bash project detected - no package dependencies to validate
✅ Shell project validation complete
```

## Benefits

1. **Universal Compatibility**: Works with any project type (Node.js, Python, Ruby, Go, Shell/Bash, etc.)
2. **Smart Detection**: Automatically adapts to project structure
3. **Clear Messaging**: Distinguishes between required vs. optional tools
4. **No False Errors**: Won't fail on missing dependencies for other tech stacks
5. **Extensible**: Easy to add support for more languages
6. **Backward Compatible**: Node.js projects work exactly as before

## Supported Tech Stacks

| Tech Stack | Detection | Validation Status |
|------------|-----------|-------------------|
| Node.js | `package.json` | ✅ Full support |
| Shell/Bash | Default (no package files) | ✅ Full support |
| Python | `requirements.txt`, `setup.py`, `pyproject.toml`, `Pipfile` | ⚠️ Planned |
| Ruby | `Gemfile` | ⚠️ Planned |
| Go | `go.mod` | ⚠️ Planned |
| Rust | `Cargo.toml` | 📝 Future |
| Java (Maven) | `pom.xml` | 📝 Future |
| Java (Gradle) | `build.gradle` | 📝 Future |

## Usage Examples

### Running on Shell/Bash Project (ai_workflow)
```bash
cd /home/mpb/Documents/GitHub/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --dry-run
# ✅ Works without errors - detects as shell project
```

### Running on Node.js Project (mpbarbosa_site)
```bash
cd /path/to/mpbarbosa_site
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
# ✅ Works as before - full npm validation
```

### Running on Python Project
```bash
cd /path/to/python-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
# ✅ Works gracefully - skips npm checks
```

## Future Enhancements

- [ ] Full Python dependency validation (pip, pipenv, poetry)
- [ ] Full Ruby dependency validation (bundler)
- [ ] Full Go dependency validation (go mod)
- [ ] Rust/Cargo support
- [ ] Multi-language project detection (polyglot repos)
- [ ] Custom tech stack overrides via CLI flags: `--tech-stack nodejs,python`
- [ ] Tech stack detection cache for performance

## Version History

- **v2.1.0** (2025-12-18): Initial implementation
  - Adaptive pre-flight checks
  - Tech stack detection function
  - Shell/Bash project support
  - Non-Node.js graceful handling

## Files Changed

```
modified:   src/workflow/lib/validation.sh
modified:   src/workflow/execute_tests_docs_workflow.sh
modified:   src/workflow/steps/step_08_dependencies.sh
new file:   docs/workflow-automation/adaptive-preflight-checks.md
new file:   test_adaptive_checks.sh
new file:   ADAPTIVE_CHECKS_IMPLEMENTATION.md
```

## Documentation

- [Adaptive Pre-Flight Checks Guide](../../workflow-automation/adaptive-preflight-checks.md)
- [Test Script](../../../tests/integration/test_adaptive_checks.sh)
- [Validation Module](../../../src/workflow/lib/validation.sh)

---

**Issue Resolved**: ✅  
**Implementation Date**: 2025-12-18  
**Version**: v2.1.0
