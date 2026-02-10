#!/usr/bin/env python3
"""
Enhance the API reference with introduction and usage guide
"""

from pathlib import Path

API_FILE = Path("/home/mpb/Documents/GitHub/ai_workflow/docs/api/COMPLETE_API_REFERENCE.md")

INTRODUCTION = """
## Introduction

This document provides a complete API reference for all library modules in the AI Workflow Automation system. The system consists of **69 library modules** with **848 functions** organized into **12 categories**.

### Purpose

This reference serves as:
- **Developer Guide**: Understand available functions and their usage
- **Integration Reference**: Learn how to use workflow modules in custom scripts
- **Maintenance Guide**: Track function signatures and documentation
- **Code Navigation**: Quickly find relevant functions by category

### Module Organization

Modules are organized into the following categories:

1. **AI & Caching** (6 modules) - AI prompt management, response caching, persona handling
2. **Core Infrastructure** (4 modules) - Change detection, metrics, tech stack, optimization
3. **Configuration** (4 modules) - Project configuration, wizard, kind detection
4. **Git Operations** (5 modules) - Git automation, caching, submodule management, auto-commit
5. **File Operations** (2 modules) - File editing and manipulation utilities
6. **Documentation** (6 modules) - Auto-documentation, changelog, templates, validation
7. **Step Management** (7 modules) - Step execution, loading, registry, validation cache
8. **Session & State** (3 modules) - Session management, backlog, summaries
9. **Optimization** (11 modules) - Smart execution, ML optimization, multi-stage pipeline
10. **Performance & Monitoring** (3 modules) - Performance tracking, dashboard
11. **Validation & Testing** (6 modules) - Enhanced validations, API coverage, test execution
12. **Utilities** (7 modules) - Colors, argument parsing, health checks, version bumping

### Key Modules

#### Core Infrastructure
- **change_detection.sh** (18 functions) - Detect code, documentation, and test changes
- **metrics.sh** (20 functions) - Performance metrics collection and reporting
- **workflow_optimization.sh** - Smart execution and performance optimization
- **tech_stack.sh** - Tech stack detection and configuration

#### AI & Caching
- **ai_helpers.sh** (44 functions) - Core AI integration with GitHub Copilot CLI
- **ai_cache.sh** (16 functions) - AI response caching with 60-80% token reduction
- **ai_personas.sh** - 17 specialized AI personas for different tasks
- **ai_prompt_builder.sh** - Dynamic prompt construction with context awareness

#### Git Operations
- **git_automation.sh** (11 functions) - Automated git operations and artifact staging
- **auto_commit.sh** - Intelligent commit message generation
- **git_cache.sh** - Git operation caching for performance

#### Step Management
- **step_execution.sh** - Execute workflow steps with dependency management
- **step_loader.sh** - Dynamic step loading with configuration support
- **step_registry.sh** - Step registration and metadata management
- **step_validation_cache.sh** - Cache validation results across runs

#### Optimization
- **ml_optimization.sh** - Machine learning-based step prediction
- **multi_stage_pipeline.sh** - Progressive 3-stage validation
- **conditional_execution.sh** - Smart step skipping based on changes
- **dependency_graph.sh** - Step dependency analysis and optimization

### Usage Patterns

#### Sourcing Modules

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/ai_helpers.sh"
source "${SCRIPT_DIR}/lib/change_detection.sh"
source "${SCRIPT_DIR}/lib/metrics.sh"

# Use module functions
init_metrics
analyze_changes
# ... your code
finalize_metrics
```

#### Using AI Helpers

```bash
# Initialize AI cache
init_ai_cache

# Call AI with specific persona
ai_call "documentation_specialist" "Analyze this file" "output.md"

# Build dynamic prompt
build_ai_prompt "code_reviewer" "additional context" > prompt.txt
```

#### Change Detection

```bash
# Analyze what changed
analyze_changes

# Check specific change types
if has_code_changes; then
    echo "Code changes detected"
fi

if has_doc_changes; then
    echo "Documentation changes detected"
fi

# Get filtered file lists
get_changed_code_files
get_changed_doc_files
```

#### Metrics Collection

```bash
# Initialize metrics
init_metrics

# Track step execution
start_step_timer "01" "Documentation Analysis"
# ... execute step
stop_step_timer "01" "success"

# Finalize and report
finalize_metrics
generate_metrics_report
```

#### Step Execution

```bash
# Load step configuration
load_step_config "documentation_updates"

# Execute step with dependencies
execute_step_with_dependencies "documentation_updates"

# Check step status
if step_completed "documentation_updates"; then
    echo "Step completed successfully"
fi
```

### Function Naming Conventions

Functions follow consistent naming patterns:

- **Verb_Noun**: `init_metrics`, `analyze_changes`, `validate_config`
- **Get_Something**: `get_changed_files`, `get_step_name`, `get_execution_mode`
- **Has/Is_Something**: `has_code_changes`, `is_workflow_artifact`, `is_copilot_available`
- **Check_Something**: `check_prerequisites`, `check_git_status`
- **Build/Generate_Something**: `build_prompt`, `generate_report`

### Return Values and Exit Codes

Most functions follow these conventions:

- **0** - Success
- **1** - General error
- **2** - Invalid arguments
- **3** - Missing dependencies
- **4** - Configuration error

### Error Handling

All modules follow consistent error handling:

```bash
function example_function() {
    local param="${1:-}"
    
    # Validate parameters
    if [[ -z "$param" ]]; then
        echo "ERROR: Parameter required" >&2
        return 1
    fi
    
    # Execute with error handling
    if ! some_command; then
        echo "ERROR: Command failed" >&2
        return 1
    fi
    
    return 0
}
```

### Testing

Each module has corresponding test files in `src/workflow/lib/test_*.sh`. Run tests with:

```bash
cd src/workflow/lib
./test_enhancements.sh        # Run all tests
./test_batch_operations.sh    # Test specific module
```

### Documentation Standards

All functions should include:
- **Description**: What the function does
- **Parameters**: List of parameters with types and descriptions
- **Returns**: Return value and exit codes
- **Examples**: Usage examples when complex
- **Notes**: Important implementation details

---

"""

def main():
    # Read existing content
    content = API_FILE.read_text()
    
    # Find insertion point (after the header, before TOC)
    lines = content.split('\n')
    
    # Find the "## Table of Contents" line
    toc_index = None
    for i, line in enumerate(lines):
        if line.strip() == "## Table of Contents":
            toc_index = i
            break
    
    if toc_index is None:
        print("Error: Could not find TOC")
        return
    
    # Insert introduction before TOC
    intro_lines = INTRODUCTION.split('\n')
    new_lines = lines[:toc_index] + intro_lines + lines[toc_index:]
    
    # Write back
    API_FILE.write_text('\n'.join(new_lines))
    
    print(f"✓ Enhanced API reference with introduction and usage guide")
    print(f"  Total lines: {len(new_lines)}")

if __name__ == "__main__":
    main()
