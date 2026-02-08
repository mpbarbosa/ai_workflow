# Developer Onboarding Guide

**Version**: v4.0.0  
**Last Updated**: 2026-02-08

Welcome to the AI Workflow Automation project! This guide will help you get started as a contributor or developer.

## Table of Contents

- [Quick Start](#quick-start)
- [Development Environment Setup](#development-environment-setup)
- [Understanding the Codebase](#understanding-the-codebase)
- [Development Workflow](#development-workflow)
- [Contributing Guidelines](#contributing-guidelines)
- [Testing Your Changes](#testing-your-changes)
- [Code Style and Standards](#code-style-and-standards)
- [Common Development Tasks](#common-development-tasks)

---

## Quick Start

### 30-Second Start

```bash
# Clone repository with submodules
git clone --recursive git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Run tests to verify setup
./tests/run_all_tests.sh

# Run workflow on itself (best way to understand it)
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel
```

### 5-Minute Deep Dive

```bash
# 1. Explore the codebase structure
tree -L 2 src/workflow/

# 2. Read the project reference
cat docs/PROJECT_REFERENCE.md

# 3. Review a simple library module
cat src/workflow/lib/colors.sh

# 4. Look at a step module
cat src/workflow/steps/documentation_updates.sh

# 5. Check configuration
cat .workflow_core/config/workflow_steps.yaml
```

---

## Development Environment Setup

### Prerequisites

**Required Tools**:
- Bash 4.0+ (5.0+ recommended)
- Git 2.30+
- GitHub CLI (`gh`) with Copilot extension
- Node.js 25.2.1+ (for GitHub Copilot CLI)
- `jq` (JSON processor)
- `yq` (YAML processor)

**Optional Tools**:
- ShellCheck (linting)
- Bats (testing)
- `yamllint` (YAML validation)

### Installation

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install bash git jq shellcheck

# GitHub CLI
sudo apt install gh

# yq
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# GitHub Copilot CLI
gh extension install github/gh-copilot

# Authenticate
gh auth login
```

#### macOS
```bash
# Using Homebrew
brew install bash git jq yq shellcheck gh

# GitHub Copilot CLI
gh extension install github/gh-copilot

# Authenticate
gh auth login
```

### Repository Setup

```bash
# Fork the repository (on GitHub)

# Clone your fork
git clone --recursive git@github.com:YOUR_USERNAME/ai_workflow.git
cd ai_workflow

# Add upstream remote
git remote add upstream git@github.com:mpbarbosa/ai_workflow.git

# Initialize submodules (if not using --recursive)
git submodule init
git submodule update

# Set up git hooks (optional)
./src/workflow/execute_tests_docs_workflow.sh --install-hooks
```

### Verify Setup

```bash
# Run health check
./src/workflow/lib/health_check.sh

# Expected output:
# ✓ Bash version: 5.1.16 (Required: 4.0+)
# ✓ Git available: 2.39.0
# ✓ Node.js available: 25.2.1
# ✓ GitHub Copilot CLI available
# ✓ Copilot authenticated
# ✓ Configuration file found
# ✓ All required directories exist

# Run basic tests
./tests/unit/test_colors.sh
./tests/unit/test_logging.sh

# Run workflow
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1 --dry-run
```

---

## Understanding the Codebase

### Architecture Overview

```
ai_workflow/
├── src/workflow/                      # Main workflow code
│   ├── execute_tests_docs_workflow.sh # Entry point (2,009 lines)
│   ├── lib/                           # 81 library modules
│   │   ├── ai_helpers.sh             # AI integration (102K)
│   │   ├── tech_stack.sh             # Tech detection (47K)
│   │   └── ...
│   ├── steps/                         # 20 step modules
│   │   ├── documentation_updates.sh
│   │   ├── test_execution.sh
│   │   └── ...
│   └── orchestrators/                 # 4 orchestrators (630 lines)
│       ├── pre_flight.sh
│       ├── validation.sh
│       ├── quality.sh
│       └── finalization.sh
├── .workflow_core/                    # Configuration submodule
│   └── config/
│       ├── ai_helpers.yaml           # AI prompts (762 lines)
│       ├── project_kinds.yaml        # Project types
│       └── workflow_steps.yaml       # Step definitions
├── tests/                             # Test suite (100% coverage)
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   └── run_all_tests.sh
├── docs/                             # Comprehensive documentation
│   ├── PROJECT_REFERENCE.md          # Single source of truth
│   ├── user-guide/
│   ├── developer-guide/
│   ├── reference/
│   └── architecture/
└── templates/                         # Workflow templates
    └── workflows/
        ├── docs-only.sh
        ├── test-only.sh
        └── feature.sh
```

### Key Concepts

#### 1. Modular Architecture
- **Library Modules**: Pure functions, no side effects
- **Step Modules**: Execute workflow stages
- **Orchestrators**: Coordinate step execution
- **Configuration**: YAML-based, declarative

#### 2. Functional Core / Imperative Shell
```
┌─────────────────────────┐
│  Imperative Shell       │  ← Steps (side effects)
│  ┌─────────────────┐   │
│  │ Functional Core │   │  ← Library (pure functions)
│  └─────────────────┘   │
└─────────────────────────┘
```

#### 3. Configuration-Driven (v4.0.0)
Steps are defined in YAML, not hardcoded:
```yaml
steps:
  - id: documentation_updates
    name: "Documentation Updates"
    file: documentation_updates.sh
    dependencies: []
```

#### 4. AI Integration
15 specialized personas for different tasks:
- documentation_specialist
- code_reviewer
- test_engineer
- ux_designer
- technical_writer
- and 10 more...

### Module Patterns

#### Library Module Structure
```bash
#!/usr/bin/env bash
# Module: module_name.sh
# Purpose: Brief description
# Dependencies: list of dependencies

set -euo pipefail

# Constants
readonly MODULE_VERSION="1.0.0"

# Public functions
public_function() {
    local param="${1}"
    # Implementation
    return 0
}

# Private helpers (prefixed with _)
_private_helper() {
    # Helper implementation
}

# Export public API
export -f public_function
```

#### Step Module Structure
```bash
#!/usr/bin/env bash
set -euo pipefail

# Validation function
validate_step_name() {
    # Check prerequisites
    return 0
}

# Execution function
execute_step_name() {
    # Main step logic
    return 0
}

# Main entry point
main() {
    validate_step_name || exit 1
    execute_step_name
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## Development Workflow

### 1. Planning

Before coding, understand:
- **What**: What problem are you solving?
- **Why**: Why is this change needed?
- **How**: How will you implement it?

```bash
# Review existing implementation
cat src/workflow/lib/existing_module.sh

# Check for similar patterns
grep -r "similar_pattern" src/workflow/lib/

# Read related documentation
cat docs/developer-guide/MODULE_DEVELOPMENT.md
```

### 2. Create Feature Branch

```bash
# Update main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 3. Make Changes

```bash
# Create new module
vim src/workflow/lib/new_module.sh

# Follow coding standards (see below)

# Test frequently
./tests/unit/test_new_module.sh
```

### 4. Write Tests

```bash
# Create test file
vim tests/unit/test_new_module.sh

# Test structure
#!/usr/bin/env bash
source "$(dirname "$0")/../../src/workflow/lib/new_module.sh"

test_function_name() {
    local result
    result=$(function_name "input")
    
    if [[ "$result" == "expected" ]]; then
        echo "✓ Test passed"
        return 0
    else
        echo "✗ Test failed: expected 'expected', got '$result'"
        return 1
    fi
}

# Run test
test_function_name
```

### 5. Run Tests

```bash
# Run your new tests
./tests/unit/test_new_module.sh

# Run all unit tests
./tests/run_all_tests.sh --unit

# Run all tests
./tests/run_all_tests.sh

# Run integration tests
./tests/run_all_tests.sh --integration
```

### 6. Update Documentation

```bash
# Update API documentation
vim docs/reference/MODULE_API_REFERENCE.md

# Update changelog
vim CHANGELOG.md

# Add examples if applicable
vim docs/user-guide/examples.md
```

### 7. Lint Your Code

```bash
# Lint shell scripts
shellcheck src/workflow/lib/new_module.sh

# Lint all changed files
git diff --name-only | grep '\.sh$' | xargs shellcheck
```

### 8. Commit Changes

```bash
# Stage changes
git add src/workflow/lib/new_module.sh
git add tests/unit/test_new_module.sh
git add docs/reference/MODULE_API_REFERENCE.md

# Commit with descriptive message
git commit -m "feat: Add new_module for feature X

- Implement function_name()
- Add comprehensive tests
- Update API documentation

Closes #123"
```

### 9. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
gh pr create --title "Add new_module for feature X" \
  --body "Description of changes"
```

---

## Contributing Guidelines

### Code Style

1. **Shell Script Standards**
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail  # Always include
   
   # Use snake_case for functions and variables
   my_function() {
       local my_variable="value"
   }
   
   # Quote variables
   echo "${my_variable}"
   
   # Use [[ ]] for conditionals
   if [[ -f "${file}" ]]; then
       echo "File exists"
   fi
   ```

2. **Function Documentation**
   ```bash
   # Function: calculate_sum
   # Purpose: Calculate sum of two numbers
   # Parameters:
   #   $1 - First number
   #   $2 - Second number
   # Returns: Sum of the two numbers
   # Exit Code: 0 on success, 1 on error
   calculate_sum() {
       local num1="${1}"
       local num2="${2}"
       echo $((num1 + num2))
   }
   ```

3. **Error Handling**
   ```bash
   function_name() {
       # Validate input
       if [[ $# -lt 1 ]]; then
           log_error "Missing required parameter"
           return 1
       fi
       
       # Check operation success
       if ! operation_command; then
           log_error "Operation failed"
           return 1
       fi
       
       return 0
   }
   ```

4. **Naming Conventions**
   - Functions: `verb_noun()` (e.g., `calculate_sum`, `validate_input`)
   - Variables: `descriptive_name` (e.g., `file_path`, `user_input`)
   - Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`, `DEFAULT_TIMEOUT`)
   - Private functions: `_underscore_prefix()` (e.g., `_internal_helper()`)

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Test additions or fixes
- `chore`: Build/tooling changes

**Example**:
```
feat: Add ML optimization for step duration prediction

- Implement predict_step_duration() function
- Add historical data collection
- Create ML model training pipeline
- Update documentation with ML optimization guide

Implements #145
```

### Pull Request Guidelines

1. **Title**: Clear, concise description
2. **Description**: 
   - What changes were made
   - Why they were needed
   - How they work
   - Testing performed
3. **Tests**: All tests must pass
4. **Documentation**: Updated if needed
5. **Size**: Keep PRs focused and reasonably sized

---

## Testing Your Changes

### Unit Tests

Test individual functions in isolation:

```bash
# Create test file
vim tests/unit/test_my_module.sh

# Test template
#!/usr/bin/env bash
source "$(dirname "$0")/../../src/workflow/lib/my_module.sh"

# Test successful case
test_success_case() {
    local result
    result=$(my_function "valid input")
    
    if [[ "$result" == "expected output" ]]; then
        echo "✓ Success case passed"
        return 0
    else
        echo "✗ Success case failed"
        return 1
    fi
}

# Test error case
test_error_case() {
    local result
    result=$(my_function "invalid input" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "✓ Error case passed"
        return 0
    else
        echo "✗ Error case failed (should have returned non-zero)"
        return 1
    fi
}

# Run tests
test_success_case || exit 1
test_error_case || exit 1
```

### Integration Tests

Test interaction between modules:

```bash
# Test workflow with new feature
./src/workflow/execute_tests_docs_workflow.sh \
  --steps your_new_step \
  --dry-run

# Verify output
cat backlog/workflow_*/step_your_new_step.md
```

### Manual Testing

```bash
# Test on sample project
cd /tmp/test-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Test specific scenarios
./execute_tests_docs_workflow.sh --smart-execution
./execute_tests_docs_workflow.sh --parallel
./execute_tests_docs_workflow.sh --steps your_new_step
```

---

## Common Development Tasks

### Adding a New Library Module

```bash
# 1. Create module file
cat > src/workflow/lib/my_new_module.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

my_public_function() {
    local input="${1}"
    echo "processed: ${input}"
}

export -f my_public_function
EOF

# 2. Create test file
cat > tests/unit/test_my_new_module.sh << 'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/../../src/workflow/lib/my_new_module.sh"

test_my_public_function() {
    local result
    result=$(my_public_function "test")
    [[ "$result" == "processed: test" ]]
}

test_my_public_function && echo "✓ Tests passed"
EOF

# 3. Make executable
chmod +x src/workflow/lib/my_new_module.sh
chmod +x tests/unit/test_my_new_module.sh

# 4. Test
./tests/unit/test_my_new_module.sh

# 5. Document
# Add to docs/reference/MODULE_API_REFERENCE.md
```

### Adding a New Step

```bash
# 1. Create step file
cat > src/workflow/steps/my_new_step.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

validate_my_new_step() {
    # Prerequisites check
    return 0
}

execute_my_new_step() {
    echo "Executing my new step..."
    # Step logic here
    return 0
}

main() {
    validate_my_new_step || exit 1
    execute_my_new_step
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

# 2. Add to workflow_steps.yaml
cat >> .workflow_core/config/workflow_steps.yaml << 'EOF'
  - id: my_new_step
    name: "My New Step"
    file: my_new_step.sh
    category: validation
    dependencies: []
    stage: 1
    can_run_parallel: true
EOF

# 3. Test
./src/workflow/execute_tests_docs_workflow.sh --steps my_new_step --dry-run
```

### Debugging

```bash
# Enable debug mode
export DEBUG=true
./src/workflow/execute_tests_docs_workflow.sh

# Trace execution
bash -x src/workflow/execute_tests_docs_workflow.sh

# Debug specific module
bash -x src/workflow/lib/my_module.sh

# Add debug statements
vim src/workflow/lib/my_module.sh
# Add: [[ "$DEBUG" == "true" ]] && echo "DEBUG: message" >&2
```

---

## Next Steps

1. **Read the architecture guide**: [docs/architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md](../architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md)
2. **Review module development guide**: [docs/developer-guide/MODULE_DEVELOPMENT.md](MODULE_DEVELOPMENT.md)
3. **Check open issues**: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
4. **Join discussions**: [github.com/mpbarbosa/ai_workflow/discussions](https://github.com/mpbarbosa/ai_workflow/discussions)

## Resources

- **Project Reference**: [docs/PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md)
- **API Reference**: [docs/api/LIBRARY_MODULES_COMPLETE_API.md](../api/LIBRARY_MODULES_COMPLETE_API.md)
- **Configuration Reference**: [docs/reference/COMPLETE_CONFIGURATION_REFERENCE.md](../reference/COMPLETE_CONFIGURATION_REFERENCE.md)
- **Troubleshooting**: [docs/guides/COMPREHENSIVE_TROUBLESHOOTING_GUIDE.md](../guides/COMPREHENSIVE_TROUBLESHOOTING_GUIDE.md)

---

**Welcome to the team! Happy coding! 🚀**

---

**Maintained by**: AI Workflow Automation Team  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
