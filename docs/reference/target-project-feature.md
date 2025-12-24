# Target Project Feature - Dynamic Workflow Execution

**Date**: 2025-12-18  
**Feature Version**: 2.3.0  
**Status**: ✅ Implemented

## Overview

The workflow automation script supports flexible project targeting: it runs on the **current directory by default**, or you can specify a different project using the `--target` option. This allows the workflow to be executed on any project without requiring file copying or configuration updates.

## Feature Details

### Command-Line Option

```bash
--target PATH       Target project root directory (default: current directory)
```

### Default Behavior

**By default, the workflow runs on the current directory** where you execute the script:

```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

This makes it convenient to integrate the workflow into any project without needing to specify paths.

### Usage Examples

```bash
# Default: Run on current directory
cd /home/mpb/Documents/GitHub/mpbarbosa_site
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

# Explicit: Use --target to specify a different project
./src/workflow/execute_tests_docs_workflow.sh \
  --target /home/mpb/Documents/GitHub/mpbarbosa_site

# Run on monitora_vagas in auto mode
./src/workflow/execute_tests_docs_workflow.sh \
  --target /home/mpb/Documents/GitHub/monitora_vagas \
  --auto

# Run specific steps on busca_vagas
./src/workflow/execute_tests_docs_workflow.sh \
  --target /home/mpb/Documents/GitHub/busca_vagas \
  --steps 0,5,6,7

# Dry-run on target project
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/project \
  --dry-run
```

## Implementation Details

### Key Variables

1. **WORKFLOW_HOME**: Always points to ai_workflow repository
   - Contains workflow scripts, libraries, and modules
   - Stores backlog, summaries, and logs
   - Never changes, regardless of target

2. **PROJECT_ROOT**: Points to the project being validated
   - **Default**: Current working directory (`pwd`)
   - **With --target**: The specified target directory
   - Defaults to WORKFLOW_HOME (self-validation)
   - Overridden by --target option
   - Where workflow operations are performed

3. **TARGET_PROJECT_ROOT**: Set by --target option
   - Empty string when running on current directory (default)
   - Contains absolute path when targeting a different project via --target

### Path Resolution

```bash
# Default behavior (running from project directory, no --target)
cd /home/mpb/Documents/GitHub/mpbarbosa_site
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh

WORKFLOW_HOME=/home/mpb/Documents/GitHub/ai_workflow       # Workflow location
PROJECT_ROOT=/home/mpb/Documents/GitHub/mpbarbosa_site    # Current directory
TARGET_PROJECT_ROOT=""                                     # Not specified

# With --target option (running from anywhere)
cd /home/mpb/Documents/GitHub/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/project

WORKFLOW_HOME=/home/mpb/Documents/GitHub/ai_workflow       # Workflow location
PROJECT_ROOT=/path/to/project                              # From --target
TARGET_PROJECT_ROOT=/path/to/project                       # Specified via flag
```

### Directory Structure

```
When using --target:

Workflow Files (WORKFLOW_HOME):
  /home/mpb/Documents/GitHub/ai_workflow/
  ├── src/workflow/
  │   ├── lib/                    # Library modules
  │   ├── steps/                  # Step modules
  │   ├── backlog/                # Execution reports
  │   ├── summaries/              # Step summaries
  │   └── logs/                   # Workflow logs

Target Project (PROJECT_ROOT):
  /home/mpb/Documents/GitHub/mpbarbosa_site/
  ├── src/                        # Project source code
  ├── docs/                       # Project documentation
  ├── package.json                # Project dependencies
  └── ...                         # Other project files
```

## Benefits

### 1. No File Duplication
- Workflow scripts remain in ai_workflow repository
- No need to copy files to each target project
- Single source of truth for workflow logic

### 2. Easy Updates
- Update workflow in one place (ai_workflow)
- All target projects benefit immediately
- No synchronization issues

### 3. Centralized Reporting
- All backlog reports in ai_workflow/backlog
- All summaries in ai_workflow/summaries
- All logs in ai_workflow/logs
- Easy to track workflow executions across projects

### 4. Flexible Deployment
- Can still copy workflow to projects if needed
- Can run from ai_workflow repository
- Supports both standalone and integrated modes

## Validation

### Path Validation
The --target option includes validation:
- Checks if directory exists
- Converts to absolute path
- Displays error if path is invalid
- Exits with code 1 on validation failure

```bash
# Example error handling
$ ./execute_tests_docs_workflow.sh --target /nonexistent/path
❌ ERROR: Target directory does not exist: /nonexistent/path
```

### Pre-flight Checks
When using --target, pre-flight checks validate:
- Target directory exists and is accessible
- Git repository is present (warning only)
- src directory exists (warning only for workflow-only repos)
- package.json exists (warning only for workflow-only repos)
- Node.js/npm available (warning only)

## Logging and Reporting

### Workflow Log Header
```
================================================================================
WORKFLOW EXECUTION LOG
================================================================================
Workflow ID: workflow_20251218_053900
Script Version: 2.2.0
Started: 2025-12-18 05:39:00
Mode: AUTO
Steps: all
Workflow Home: /home/mpb/Documents/GitHub/ai_workflow
Project Root: /home/mpb/Documents/GitHub/mpbarbosa_site (target project)

================================================================================
EXECUTION LOG
================================================================================
```

### Console Output
```bash
═══════════════════════════════════════════════════════════════
  Tests & Documentation Workflow Automation v2.2.0
═══════════════════════════════════════════════════════════════

ℹ️  Target project: /home/mpb/Documents/GitHub/mpbarbosa_site
ℹ️  Workflow home: /home/mpb/Documents/GitHub/ai_workflow
```

## Compatibility

### Backward Compatibility
✅ **100% Backward Compatible**
- Default behavior unchanged (runs on ai_workflow)
- All existing scripts and configurations work
- No breaking changes to existing workflows

### Forward Compatibility
- Option designed for extensibility
- Can be enhanced with additional features:
  - Project type auto-detection
  - Configuration templates
  - Multi-project batch execution

## Testing

### Test Cases

#### 1. Self-Validation (Default)
```bash
cd ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --dry-run
# Expected: Runs on ai_workflow repository
```

#### 2. Target Project Validation
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --target /home/mpb/Documents/GitHub/mpbarbosa_site \
  --dry-run
# Expected: Runs on mpbarbosa_site, reports stored in ai_workflow
```

#### 3. Invalid Target
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --target /nonexistent/path
# Expected: Error message and exit code 1
```

#### 4. Combined Options
```bash
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/project \
  --auto \
  --steps 0,1,2,3,4
# Expected: Auto mode, documentation steps only, on target project
```

## Configuration

### No Configuration Required
The --target option works without any configuration changes:
- No paths.yaml updates needed
- No environment variables required
- No project-specific setup needed

### Optional Configuration
If desired, target projects can be pre-configured in paths.yaml:
```yaml
directories:
  targets:
    mpbarbosa_site: /home/mpb/Documents/GitHub/mpbarbosa_site
    monitora_vagas: /home/mpb/Documents/GitHub/monitora_vagas
```

This is informational only; --target accepts any valid path.

## Future Enhancements

### Planned Features
- [ ] `--target-alias` option to use paths.yaml shortcuts
- [ ] Auto-detection of project type (Node.js, Python, Go, etc.)
- [ ] Project-specific configuration templates
- [ ] Multi-project batch execution with `--targets`
- [ ] Remote project support via SSH
- [ ] Docker container support

### Example Future Usage
```bash
# Using alias (planned)
./execute_tests_docs_workflow.sh --target-alias mpbarbosa_site

# Batch execution (planned)
./execute_tests_docs_workflow.sh --targets "project1,project2,project3"

# Remote execution (planned)
./execute_tests_docs_workflow.sh --target ssh://user@host:/path/to/project
```

## Documentation Updates

### Files Updated
1. **README.md**: Added --target usage examples
2. **execute_tests_docs_workflow.sh**: Implemented --target option
3. **TARGET_PROJECT_FEATURE.md**: This documentation

### Help Text
Run `--help` to see the complete usage information:
```bash
./src/workflow/execute_tests_docs_workflow.sh --help
```

## Migration Guide

### From Copied Workflow
If you previously copied the workflow to target projects:

**Before:**
```bash
cd /path/to/target/project
./src/workflow/execute_tests_docs_workflow.sh
```

**After:**
```bash
cd /path/to/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh \
  --target /path/to/target/project
```

**Benefits:**
- No duplicate workflow files
- Easy to update workflow logic
- Centralized reporting

### Keeping Copied Workflow
The copied workflow still works! Both approaches are valid:
- **Copy approach**: Good for projects that need workflow modifications
- **Target approach**: Good for standard workflow execution

## Summary

The `--target` option transforms ai_workflow from a single-project tool into a multi-project workflow automation system. It provides:

✅ **Flexibility**: Run on any project without copying files  
✅ **Maintainability**: Update once, use everywhere  
✅ **Centralization**: All reports in one place  
✅ **Compatibility**: 100% backward compatible  
✅ **Simplicity**: No configuration required

---

**Implementation Date**: 2025-12-18  
**Feature Status**: ✅ Complete and Ready  
**Breaking Changes**: None  
**Version**: 2.2.1
