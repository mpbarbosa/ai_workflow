# Tech Stack Adaptive Framework - Quick Reference

**Version**: 1.0.0  
**For**: Developers & Users  
**See Also**: [Full Requirements](../design/tech-stack-framework.md)

---

## Overview

The Tech Stack Adaptive Framework allows the workflow to automatically adapt to different programming languages and project structures. No more "package.json not found" errors on Python projects!

---

## Quick Start

### Option 1: Auto-Detection (Recommended)

Just run the workflow - it will detect your tech stack automatically:

```bash
cd /path/to/your/python/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --auto
```

**Supported**: JavaScript, Python, Go, Java, Ruby, Rust, C/C++, Bash

### Option 2: Configuration File (Better Results)

Create `.workflow-config.yaml` in your project root:

```yaml
# Minimal configuration (6 lines)
project:
  name: "my-project"
  kind: "python_api"              # Optional: auto-detected if not specified

tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"
```

### Option 3: Interactive Setup

Let the wizard create the config for you:

```bash
./execute_tests_docs_workflow.sh --init-config
```

---

## Configuration Examples

### Python Project (pip)

```yaml
project:
  name: "ml-pipeline"
  kind: "python_api"

tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"
  linter: "pylint"
  test_command: "pytest tests/"
  lint_command: "pylint src/"

structure:
  source_dirs: [src]
  test_dirs: [tests]
  exclude_dirs: [venv, __pycache__, .pytest_cache]

dependencies:
  package_file: "requirements.txt"
  install_command: "pip install -r requirements.txt"
```

### JavaScript Project (npm)

```yaml
project:
  name: "web-app"
  kind: "react_spa"

tech_stack:
  primary_language: "javascript"
  build_system: "npm"
  test_framework: "jest"
  linter: "eslint"
  test_command: "npm test"
  lint_command: "npm run lint"

structure:
  source_dirs: [src]
  test_dirs: [src/__tests__]
  exclude_dirs: [node_modules, dist, coverage]

dependencies:
  package_file: "package.json"
  lock_file: "package-lock.json"
  install_command: "npm install"
```

### Go Project

```yaml
project:
  name: "api-service"
  kind: "go_api"

tech_stack:
  primary_language: "go"
  build_system: "go mod"
  test_framework: "go test"
  test_command: "go test ./..."
  lint_command: "golangci-lint run"

structure:
  source_dirs: [cmd, internal, pkg]
  exclude_dirs: [vendor, bin]

dependencies:
  package_file: "go.mod"
  install_command: "go mod download"
```

### Java Project (Maven)

```yaml
project:
  name: "backend-service"
  kind: "java_api"

tech_stack:
  primary_language: "java"
  build_system: "maven"
  test_framework: "junit"
  test_command: "mvn test"
  lint_command: "mvn checkstyle:check"

structure:
  source_dirs: [src/main/java]
  test_dirs: [src/test/java]
  exclude_dirs: [target]

dependencies:
  package_file: "pom.xml"
  install_command: "mvn install"
```

---

## What Gets Adapted

### Step Execution

Different commands run based on language:

| Step | JavaScript | Python | Go | Java |
|------|-----------|--------|-----|------|
| **Dependencies** | npm audit | pip check | go mod verify | mvn verify |
| **Quality** | eslint | pylint | go vet | checkstyle |
| **Tests** | npm test | pytest | go test | mvn test |

### File Patterns

Different file extensions and test patterns:

```yaml
JavaScript: *.js, *.jsx, *.test.js, __tests__/
Python:     *.py, test_*.py, *_test.py, tests/
Go:         *.go, *_test.go
Java:       *.java, *Test.java, *Tests.java
```

### AI Prompts

Language-specific instructions for better AI results:

**JavaScript**:
- Focus on JSDoc comments
- Document async/await patterns
- Reference npm packages

**Python**:
- Follow PEP 257 docstrings
- Use type hints (PEP 484)
- Reference PyPI packages

**Go**:
- Follow godoc conventions
- Document exported functions
- Reference go modules

---

## Configuration Schema

### Required Fields

```yaml
project:
  name: "string"              # Project name

tech_stack:
  primary_language: "string"  # Main language
```

### Optional Fields (Recommended)

```yaml
project:
  kind: "string"              # Project type: shell_automation, nodejs_api, nodejs_cli,
                              # nodejs_library, static_website, react_spa, vue_spa,
                              # python_api, python_cli, python_library, documentation
                              # (auto-detected if not specified)

tech_stack:
  languages: [list]           # Additional languages
  build_system: "string"      # npm, pip, go mod, maven, etc.
  test_framework: "string"    # jest, pytest, go test, junit, etc.
  test_command: "string"      # Command to run tests
  linter: "string"            # eslint, pylint, golangci-lint, etc.
  lint_command: "string"      # Command to run linter

structure:
  source_dirs: [list]         # Source code directories
  test_dirs: [list]           # Test directories
  docs_dirs: [list]           # Documentation directories
  exclude_dirs: [list]        # Directories to skip

dependencies:
  package_file: "string"      # Main dependency file
  lock_file: "string"         # Lock file (optional)
  install_command: "string"   # Dependency install command

ai_prompts:
  language_context: "string"  # Custom context for AI
  custom_instructions: [list] # Custom AI instructions
```

---

## Supported Project Kinds

The `project.kind` field enables project-aware AI personas and optimized workflow execution:

| Kind | Description | Characteristics |
|------|-------------|-----------------|
| **shell_automation** | Shell script workflow/automation | executable_focus, script_heavy, no_build |
| **nodejs_api** | Node.js REST API / backend service | server_runtime, requires_build, dependency_heavy |
| **nodejs_cli** | Node.js command-line tool | executable_focus, requires_build, binary_output |
| **nodejs_library** | Node.js reusable library/module | library_focus, requires_build, npm_publish |
| **static_website** | Static HTML/CSS/JS website | no_runtime, no_build, browser_target |
| **react_spa** | React single-page application | client_runtime, requires_build, browser_target |
| **vue_spa** | Vue.js single-page application | client_runtime, requires_build, browser_target |
| **python_api** | Python API / web service | server_runtime, optional_build, dependency_heavy |
| **python_cli** | Python command-line tool | executable_focus, optional_build, binary_output |
| **python_library** | Python reusable library/package | library_focus, optional_build, pypi_publish |
| **documentation** | Documentation-only project | no_runtime, optional_build, content_focus |

**Note**: If not specified, project kind is auto-detected using the `detect_project_kind()` function.

---

## Supported Languages

| Language | Build System | Test Framework | Status |
|----------|-------------|----------------|--------|
| **JavaScript** | npm, yarn, pnpm | jest, mocha, vitest | ✅ v1.0 |
| **Python** | pip, poetry, pipenv | pytest, unittest | ✅ v1.0 |
| **Go** | go mod | go test | ✅ v1.0 |
| **Java** | maven, gradle | junit, testng | ✅ v1.0 |
| **Ruby** | bundler, gem | rspec, minitest | ✅ v1.0 |
| **Rust** | cargo | cargo test | ✅ v1.0 |
| **C/C++** | make, cmake | gtest, catch2 | ✅ v1.0 |
| **Bash** | N/A | bats, shunit2 | ✅ v1.0 |
| **PHP** | composer | phpunit | 🔜 v1.1 |
| **Swift** | swift pm | xctest | 🔜 v1.1 |
| **Kotlin** | gradle | junit | 🔜 v1.1 |

---

## Commands

### Setup Commands

```bash
# Interactive setup wizard
./execute_tests_docs_workflow.sh --init-config

# Use template
./execute_tests_docs_workflow.sh --init-config --template python-pip

# List available templates
./execute_tests_docs_workflow.sh --list-templates
```

### Validation Commands

```bash
# Validate current config
./execute_tests_docs_workflow.sh --validate-config

# Validate specific file
./execute_tests_docs_workflow.sh --validate-config path/to/config.yaml

# Show detected tech stack
./execute_tests_docs_workflow.sh --show-tech-stack
```

### Workflow Execution

```bash
# Auto-detect and run
./execute_tests_docs_workflow.sh --auto

# With specific config file
./execute_tests_docs_workflow.sh --config custom-config.yaml

# Dry-run to see what would happen
./execute_tests_docs_workflow.sh --dry-run
```

---

## Auto-Detection

### How It Works

1. **Scan for package files** (high confidence)
   - `package.json` → JavaScript
   - `requirements.txt`, `pyproject.toml` → Python
   - `go.mod` → Go
   - `pom.xml`, `build.gradle` → Java

2. **Count source files** (medium confidence)
   - Count `*.py`, `*.js`, `*.go`, etc.
   - Calculate language percentages

3. **Check directory structure** (low confidence)
   - `node_modules/` → JavaScript
   - `venv/`, `__pycache__/` → Python
   - `vendor/` → Go

4. **Combine signals** → Final decision
   - Confidence score: 0-100%
   - If < 80%, prompt user for confirmation

### Example Detection

```
🔍 Analyzing project...

Detected Signals:
  ✓ requirements.txt found (High confidence: +40%)
  ✓ pyproject.toml found (High confidence: +30%)
  ✓ 80 *.py files (Medium confidence: +20%)
  ✓ venv/ directory (Low confidence: +5%)

Result:
  Primary Language: Python (95% confidence)
  Build System: pip (detected from requirements.txt)
  Test Framework: pytest (detected from pyproject.toml)
  
✅ Auto-detection complete!
```

---

## Custom AI Context

Add project-specific context to improve AI suggestions:

```yaml
ai_prompts:
  language_context: |
    This is a machine learning pipeline using:
    - scikit-learn for model training
    - pandas for data processing
    - FastAPI for REST API
    
    Focus on data science best practices and ML documentation.
  
  custom_instructions:
    - "Use type hints for all functions"
    - "Follow PEP 8 style guide strictly"
    - "Document all data transformations"
    - "Include example usage in docstrings"
```

**Result**: AI generates ML-focused documentation with proper type hints and examples.

---

## Troubleshooting

### Config Not Loading

**Problem**: Configuration file not detected

**Solution**:
```bash
# Check file name (must be exact)
ls -la .workflow-config.yaml  # or .workflow-config.yml

# Validate syntax
./execute_tests_docs_workflow.sh --validate-config
```

### Wrong Language Detected

**Problem**: Auto-detection picks wrong language

**Solution**: Create config file to override:
```yaml
tech_stack:
  primary_language: "python"  # Force Python
```

### Tests Not Running

**Problem**: Test command not working

**Solution**: Specify explicit test command:
```yaml
tech_stack:
  test_command: "python -m pytest tests/ -v"
```

### Custom Build System

**Problem**: Using custom/unusual build system

**Solution**: Override all commands:
```yaml
tech_stack:
  build_system: "custom"
  install_command: "./scripts/install.sh"
  test_command: "./scripts/test.sh"
  lint_command: "./scripts/lint.sh"
```

---

## Migration from v2.4.0

### No Action Needed

If your project is JavaScript/Node.js, everything works as before:
```bash
# This still works exactly the same
./execute_tests_docs_workflow.sh
```

### For Non-JavaScript Projects

**Before** (v2.4.0): Errors and manual workarounds
```bash
❌ ERROR: package.json not found
❌ ERROR: npm command failed
```

**After** (v1.0.0): Automatic adaptation
```bash
✅ Auto-detected: Python project
✅ Using pip for dependencies
✅ Using pytest for tests
```

**Best Practice**: Create config file for optimal results
```bash
./execute_tests_docs_workflow.sh --init-config
```

---

## Performance

### Overhead

- Config loading: < 100ms
- Auto-detection: < 500ms
- Total impact: < 1 second

### Optimization

Config file is **faster** than auto-detection:
- With config: ~100ms
- Auto-detect: ~500ms
- **Recommendation**: Use config for production

---

## Best Practices

### 1. Always Create Config File

Even if auto-detection works, config provides:
- ✅ Faster startup (no detection)
- ✅ Better AI prompts (custom context)
- ✅ Explicit documentation
- ✅ Version control

### 2. Keep Config Minimal

Only specify what's needed:
```yaml
# Good: Minimal but complete
tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"

# Avoid: Over-specified
tech_stack:
  primary_language: "python"
  languages: [python]  # Redundant
  build_system: "pip"
  # ... 20 more fields ...
```

### 3. Use Templates

Start with a template:
```bash
./execute_tests_docs_workflow.sh --init-config --template python-pip
# Edit as needed
```

### 4. Validate Before Commit

Always validate before committing:
```bash
./execute_tests_docs_workflow.sh --validate-config
git add .workflow-config.yaml
```

### 5. Add Custom Context

For better AI results, add project-specific context:
```yaml
ai_prompts:
  language_context: |
    This is a REST API using FastAPI.
    Focus on API documentation and HTTP best practices.
```

---

## FAQ

**Q: Do I need a config file?**  
A: No, auto-detection works for most projects. But config provides better results.

**Q: Can I use multiple languages?**  
A: Yes! Specify in `tech_stack.languages: [python, javascript]`

**Q: What if my language isn't supported?**  
A: Use generic config. Full support coming in future releases.

**Q: How do I customize AI prompts?**  
A: Use `ai_prompts.language_context` and `custom_instructions`.

**Q: Can I use this with --target option?**  
A: Yes! Config is loaded from target project directory.

**Q: Is this backward compatible?**  
A: Yes! v2.4.0 behavior preserved when no config present.

---

## Examples Repository

Find complete examples at:
```
src/workflow/config/templates/
├── javascript-node.yaml
├── python-pip.yaml
├── python-poetry.yaml
├── go-module.yaml
├── java-maven.yaml
└── ...more...
```

---

## Support

- **Documentation**: [Tech Stack Adaptive Framework](../design/tech-stack-framework.md)
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Quick Reference Version**: 1.0.0  
**Last Updated**: 2025-12-18  
**Status**: Ready for Implementation
