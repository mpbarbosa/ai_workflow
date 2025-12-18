# Adaptive Pre-Flight Checks

## Overview

The workflow automation system now includes **adaptive pre-flight checks** that automatically detect the project's technology stack and adjust validation requirements accordingly.

## Problem Solved

Previously, the workflow was hardcoded to expect Node.js projects with `package.json` files. When run on non-Node.js projects (Python, Ruby, Go, Shell/Bash, etc.), it would:
- Display errors about missing `package.json`
- Attempt to run `npm install` unnecessarily
- Fail validation for projects that don't use npm

## Solution

### Technology Stack Detection

The workflow now automatically detects project types by scanning for characteristic files:

| Tech Stack | Detection Files |
|------------|----------------|
| **Node.js** | `package.json` |
| **Python** | `requirements.txt`, `setup.py`, `pyproject.toml`, `Pipfile` |
| **Ruby** | `Gemfile` |
| **Go** | `go.mod` |
| **Rust** | `Cargo.toml` |
| **Java (Maven)** | `pom.xml` |
| **Java (Gradle)** | `build.gradle`, `build.gradle.kts` |
| **Shell/Bash** | Default if no package files found |

### Adaptive Validation

Based on detected tech stack:

#### Node.js Projects
- ✅ **Requires** `package.json`
- ✅ **Requires** Node.js and npm installed
- ✅ Validates `node_modules` directory
- ✅ Runs `npm install` if needed
- ✅ Validates Jest if present in dependencies
- ✅ Runs `npm audit` for security checks

#### Shell/Bash Projects
- ✅ **Skips** package.json requirement
- ℹ️ Node.js/npm marked as optional
- ✅ **Skips** dependency installation
- ✅ Validates git repository health
- ✅ Step 8 (Dependency Validation) skipped with success status

#### Python/Ruby/Go Projects
- ⚠️ Validation not yet fully implemented
- ℹ️ Node.js/npm marked as optional
- ⚠️ Step 8 skipped with warning status
- 📝 Manual dependency review recommended

## Modified Components

### 1. `lib/validation.sh`
```bash
# New function to detect project tech stack
detect_project_tech_stack()

# Updated pre-flight checks
check_prerequisites()  # Now tech-aware

# Updated dependency validation
validate_dependencies()  # Adaptive based on tech stack
```

### 2. `execute_tests_docs_workflow.sh`
```bash
# Inline tech stack detection in:
check_prerequisites()
validate_dependencies()
```

### 3. `steps/step_08_dependencies.sh`
```bash
# New detection function
detect_project_tech_stack_step8()

# Updated main function
step8_validate_dependencies()  # Handles multiple tech stacks
```

## Usage Examples

### Running on Shell/Bash Project (ai_workflow repo)
```bash
cd /home/mpb/Documents/GitHub/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --dry-run
```

**Output:**
```
Detecting project technology stack...
✅ Tech stack detected: shell
ℹ️  Node.js available: v25.2.1 (not required for this project)
ℹ️  npm available: 10.9.2 (not required for this project)

...

Step 8: Validate Dependencies & Environment
ℹ️  Shell/Bash project detected - no package dependencies to validate
✅ Shell project - no dependencies to validate
```

### Running on Node.js Project
```bash
cd /path/to/nodejs-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

**Output:**
```
Detecting project technology stack...
✅ Tech stack detected: nodejs
✅ package.json found
✅ Node.js: v25.2.1
✅ npm: 10.9.2

...

Step 8: Validate Dependencies & Environment
ℹ️  Phase 1: Automated dependency analysis (Node.js)...
✅ package.json is valid JSON
✅ node_modules directory exists
```

### Running on Python Project
```bash
cd /path/to/python-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

**Output:**
```
Detecting project technology stack...
✅ Tech stack detected: python
ℹ️  Node.js available: v25.2.1 (not required for this project)

...

Step 8: Validate Dependencies & Environment
⚠️  Non-Node.js project detected - dependency validation not yet implemented
⚠️  python project - validation not implemented
```

## Benefits

1. **Universal Compatibility**: Works with any project type
2. **Smart Detection**: Automatically adapts to project structure
3. **Clear Messaging**: Distinguishes between required vs. optional tools
4. **No False Errors**: Won't fail on missing dependencies for other tech stacks
5. **Extensible**: Easy to add support for more languages

## Future Enhancements

- [ ] Full Python dependency validation (pip, pipenv, poetry)
- [ ] Full Ruby dependency validation (bundler, gem)
- [ ] Full Go dependency validation (go mod)
- [ ] Rust/Cargo support
- [ ] Multi-language project detection (polyglot repos)
- [ ] Custom tech stack overrides via CLI flags

## Version History

- **v2.1.0** (2025-12-18): Initial implementation of adaptive pre-flight checks
  - Added `detect_project_tech_stack()` function
  - Updated all validation functions to be tech-aware
  - Shell/Bash project support
  - Non-Node.js project graceful handling

---

**Related Documentation:**
- [Validation Module](../src/workflow/lib/validation.sh)
- [Step 8: Dependency Validation](../src/workflow/steps/step_08_dependencies.sh)
- [Main Workflow](../src/workflow/execute_tests_docs_workflow.sh)
