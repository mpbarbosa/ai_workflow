# Language-Specific Integration Guide

**Version**: 4.0.1  
**Last Updated**: 2026-02-10  
**Purpose**: Configure AI Workflow for Python, Go, Rust, Java, and other language projects

## Overview

This guide shows how to integrate AI Workflow Automation with projects in different programming languages. While the workflow is language-agnostic, each language has specific conventions for tests, documentation, and project structure that should be configured properly.

## Table of Contents

- [Python Projects](#python-projects)
- [Go Projects](#go-projects)
- [Rust Projects](#rust-projects)
- [Java Projects](#java-projects)
- [Ruby Projects](#ruby-projects)
- [PHP Projects](#php-projects)
- [Monorepo Projects](#monorepo-projects)
- [Multi-Language Projects](#multi-language-projects)

---

## Python Projects

### Project Types Supported

- **Python API** (`python_api`) - Flask, FastAPI, Django REST
- **Python CLI** (`python_cli`) - Click, argparse, typer
- **Python Library** (`python_library`) - Reusable packages

### Configuration

#### Basic Setup

```bash
cd /path/to/python-project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

#### Example `.workflow-config.yaml`

```yaml
project:
  name: "my-python-api"
  kind: python_api
  description: "REST API built with FastAPI"

tech_stack:
  primary_language: python
  frameworks:
    - fastapi
    - pydantic
    - sqlalchemy
  testing_framework: pytest
  build_tool: pip
  package_manager: pip

paths:
  source:
    - "src/"
    - "app/"
  tests:
    - "tests/"
    - "test/"
  docs:
    - "docs/"
    - "README.md"
    - "API.md"
  exclude:
    - "**/__pycache__/"
    - "**/*.pyc"
    - ".venv/"
    - "venv/"
    - "*.egg-info/"

testing:
  command: "pytest --cov=src tests/"
  coverage_threshold: 80
  test_pattern: "test_*.py"
  
  # Alternative test commands
  unit_tests: "pytest tests/unit -v"
  integration_tests: "pytest tests/integration -v"
  e2e_tests: "pytest tests/e2e -v"

linting:
  enabled: true
  commands:
    - "black --check ."
    - "flake8 src/ tests/"
    - "mypy src/"
    - "pylint src/"

documentation:
  api_docs_pattern: "**/*.py"
  auto_generate: true
  style: "google"  # or "numpy", "sphinx"
```

### Project Structure Example

```
my-python-api/
├── .workflow-config.yaml
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
├── README.md
├── docs/
│   ├── API.md
│   ├── installation.md
│   └── usage.md
├── src/
│   └── myapi/
│       ├── __init__.py
│       ├── main.py
│       ├── models.py
│       └── routes/
│           ├── __init__.py
│           └── users.py
└── tests/
    ├── conftest.py
    ├── unit/
    │   └── test_models.py
    └── integration/
        └── test_api.py
```

### Running Workflow

```bash
# Full workflow
./execute_tests_docs_workflow.sh --smart-execution --parallel

# Documentation only
./templates/workflows/docs-only.sh

# Test development
./templates/workflows/test-only.sh

# With virtual environment
source venv/bin/activate
./execute_tests_docs_workflow.sh --steps documentation_updates,test_execution
```

### Step Behavior for Python

| Step | Python-Specific Behavior |
|------|--------------------------|
| **Step 1: Documentation** | Analyzes docstrings (Google/NumPy/Sphinx style) |
| **Step 2: Doc Updates** | Validates docstring coverage, suggests missing docs |
| **Step 5: Validation** | Checks `requirements.txt`, `pyproject.toml` sync |
| **Step 6: Automated Tests** | Suggests pytest fixtures, parametrized tests |
| **Step 7: Test Execution** | Runs pytest with coverage, generates reports |
| **Step 8: Test Validation** | Validates coverage thresholds, slow tests |
| **Step 9: Code Review** | Checks PEP 8, type hints, security (bandit) |

### Python-Specific Enhancements

#### Docstring Analysis

The workflow automatically detects and validates Python docstrings:

```python
# Before (detected as incomplete)
def calculate_score(user_id):
    return user_id * 42

# After (workflow suggests)
def calculate_score(user_id: int) -> int:
    """Calculate user score based on user ID.
    
    Args:
        user_id: Unique identifier for the user
        
    Returns:
        Calculated score as integer
        
    Raises:
        ValueError: If user_id is negative
        
    Example:
        >>> calculate_score(10)
        420
    """
    if user_id < 0:
        raise ValueError("user_id must be non-negative")
    return user_id * 42
```

#### Type Hint Validation

```python
# Workflow suggests adding type hints
def process_data(data, config):  # ❌ No types
    ...

def process_data(data: dict[str, Any], config: Config) -> ProcessedData:  # ✅ With types
    ...
```

---

## Go Projects

### Project Types Supported

- **Go API** (`go_api`) - Gin, Echo, Chi
- **Go CLI** (`go_cli`) - Cobra, urfave/cli
- **Go Library** (`go_library`) - Reusable packages

### Configuration

#### Example `.workflow-config.yaml`

```yaml
project:
  name: "my-go-api"
  kind: go_api
  description: "REST API built with Gin"

tech_stack:
  primary_language: go
  frameworks:
    - gin
    - gorm
  testing_framework: go_test
  build_tool: go
  package_manager: go_modules

paths:
  source:
    - "cmd/"
    - "internal/"
    - "pkg/"
  tests:
    - "**/*_test.go"
  docs:
    - "docs/"
    - "README.md"
  exclude:
    - "vendor/"
    - "bin/"

testing:
  command: "go test ./... -v -cover"
  coverage_threshold: 80
  test_pattern: "*_test.go"
  
  # Additional test commands
  unit_tests: "go test ./internal/... -v"
  integration_tests: "go test ./tests/integration/... -v"
  benchmark: "go test -bench=. -benchmem"

linting:
  enabled: true
  commands:
    - "gofmt -l ."
    - "go vet ./..."
    - "golangci-lint run"
    - "staticcheck ./..."

documentation:
  api_docs_pattern: "**/*.go"
  auto_generate: true
  style: "godoc"
```

### Project Structure Example

```
my-go-api/
├── .workflow-config.yaml
├── go.mod
├── go.sum
├── README.md
├── Makefile
├── docs/
│   ├── API.md
│   └── architecture.md
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── handlers/
│   │   ├── user.go
│   │   └── user_test.go
│   └── models/
│       ├── user.go
│       └── user_test.go
└── pkg/
    └── utils/
        ├── helpers.go
        └── helpers_test.go
```

### Go-Specific Features

#### Godoc Comment Analysis

```go
// Before (incomplete)
func CalculateScore(userID int) int {
    return userID * 42
}

// After (workflow suggests)
// CalculateScore computes a user's score based on their ID.
// It multiplies the user ID by 42.
//
// Parameters:
//   - userID: The unique identifier for the user (must be non-negative)
//
// Returns:
//   - int: The calculated score
//
// Example:
//
//  score := CalculateScore(10)
//  fmt.Println(score) // Output: 420
func CalculateScore(userID int) int {
    if userID < 0 {
        panic("userID must be non-negative")
    }
    return userID * 42
}
```

#### Table Test Detection

The workflow recognizes and validates Go table tests:

```go
func TestCalculateScore(t *testing.T) {
    tests := []struct {
        name     string
        userID   int
        expected int
    }{
        {"positive ID", 10, 420},
        {"zero ID", 0, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := CalculateScore(tt.userID)
            if result != tt.expected {
                t.Errorf("got %d, want %d", result, tt.expected)
            }
        })
    }
}
```

---

## Rust Projects

### Project Types Supported

- **Rust API** (`rust_api`) - Actix, Rocket, Axum
- **Rust CLI** (`rust_cli`) - Clap, structopt
- **Rust Library** (`rust_library`) - Reusable crates

### Configuration

#### Example `.workflow-config.yaml`

```yaml
project:
  name: "my-rust-api"
  kind: rust_api
  description: "REST API built with Actix"

tech_stack:
  primary_language: rust
  frameworks:
    - actix-web
    - tokio
    - serde
  testing_framework: cargo_test
  build_tool: cargo
  package_manager: cargo

paths:
  source:
    - "src/"
  tests:
    - "tests/"
    - "src/**/*_test.rs"
  docs:
    - "docs/"
    - "README.md"
  exclude:
    - "target/"
    - "Cargo.lock"

testing:
  command: "cargo test --all-features"
  coverage_threshold: 80
  test_pattern: "**/*_test.rs"
  
  unit_tests: "cargo test --lib"
  integration_tests: "cargo test --test '*'"
  doc_tests: "cargo test --doc"

linting:
  enabled: true
  commands:
    - "cargo fmt -- --check"
    - "cargo clippy -- -D warnings"
    - "cargo check --all-features"

documentation:
  api_docs_pattern: "**/*.rs"
  auto_generate: true
  style: "rustdoc"
```

### Rust-Specific Features

#### Rustdoc Comment Analysis

```rust
// Before
pub fn calculate_score(user_id: i32) -> i32 {
    user_id * 42
}

// After (workflow suggests)
/// Calculates a user's score based on their ID.
///
/// # Arguments
///
/// * `user_id` - The unique identifier for the user (must be non-negative)
///
/// # Returns
///
/// The calculated score as an i32
///
/// # Panics
///
/// Panics if `user_id` is negative
///
/// # Examples
///
/// ```
/// let score = calculate_score(10);
/// assert_eq!(score, 420);
/// ```
pub fn calculate_score(user_id: i32) -> i32 {
    assert!(user_id >= 0, "user_id must be non-negative");
    user_id * 42
}
```

---

## Java Projects

### Configuration

```yaml
project:
  name: "my-java-api"
  kind: java_api

tech_stack:
  primary_language: java
  frameworks:
    - spring-boot
    - hibernate
  testing_framework: junit5
  build_tool: maven  # or gradle

paths:
  source:
    - "src/main/java/"
  tests:
    - "src/test/java/"
  docs:
    - "docs/"
    - "README.md"
  exclude:
    - "target/"
    - "build/"

testing:
  command: "mvn test"
  # Or for Gradle: "gradle test"
  coverage_threshold: 80

linting:
  enabled: true
  commands:
    - "mvn checkstyle:check"
    - "mvn spotbugs:check"
```

---

## Monorepo Projects

### Workspace/Monorepo Structure

```yaml
project:
  name: "my-monorepo"
  kind: monorepo
  workspaces:
    - "packages/*"
    - "apps/*"

tech_stack:
  primary_language: typescript
  monorepo_tool: turborepo  # or nx, lerna

paths:
  source:
    - "packages/*/src/"
    - "apps/*/src/"
  tests:
    - "packages/*/tests/"
    - "apps/*/tests/"

testing:
  command: "turbo run test"
  per_package: true
```

### Running Workflow on Monorepo

```bash
# Run on entire monorepo
./execute_tests_docs_workflow.sh

# Run on specific package
./execute_tests_docs_workflow.sh --target packages/core

# Run on all packages in parallel
for pkg in packages/*; do
  ./execute_tests_docs_workflow.sh --target "$pkg" &
done
wait
```

---

## Multi-Language Projects

For projects with multiple languages (e.g., Python backend + JavaScript frontend):

```yaml
project:
  name: "full-stack-app"
  kind: multi_language

tech_stack:
  languages:
    - python
    - typescript
  primary_language: python

paths:
  source:
    - "backend/src/"
    - "frontend/src/"
  tests:
    - "backend/tests/"
    - "frontend/tests/"

testing:
  commands:
    backend: "cd backend && pytest"
    frontend: "cd frontend && npm test"
```

## CI/CD Integration

### GitHub Actions - Python

```yaml
name: AI Workflow
on: [push, pull_request]

jobs:
  workflow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run Workflow
        run: |
          /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto
```

### GitHub Actions - Go

```yaml
- name: Set up Go
  uses: actions/setup-go@v4
  with:
    go-version: '1.21'

- name: Get dependencies
  run: go mod download

- name: Run Workflow
  run: |
    /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
      --smart-execution --parallel --auto
```

## Troubleshooting

### Python: ModuleNotFoundError

```bash
# Ensure virtual environment is activated
source venv/bin/activate
pip install -e .
```

### Go: Package Not Found

```bash
# Ensure go.mod is up to date
go mod tidy
go mod download
```

### Rust: Compilation Errors

```bash
# Check for outdated dependencies
cargo update
cargo build
```

## See Also

- [Configuration Reference](../CONFIGURATION_REFERENCE.md)
- [Integration Guide](../guides/INTEGRATION_GUIDE.md)
- [CI/CD Integration](../guides/user/CI_CD_INTEGRATION.md)
- [Project Kinds Reference](../../.workflow_core/config/project_kinds.yaml)
