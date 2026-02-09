# change_detection.sh - Change Type Detection API

**Version**: 2.0.0  
**Location**: `src/workflow/lib/change_detection.sh`  
**Purpose**: Auto-detect documentation-only, test-only, or full-stack changes to optimize workflow execution

## Overview

The Change Detection module analyzes Git changes to classify modifications and enable smart execution optimization. It filters workflow artifacts, categorizes changes by type, and provides intelligent analysis for workflow optimization decisions.

**Key Features**:
- Automatic detection of change types (docs-only, tests-only, full-stack)
- Workflow artifact filtering (excludes generated files)
- Git diff analysis and classification
- Integration with smart execution optimization
- Support for custom exclusion patterns

## Dependencies

**Required Modules**:
- None (standalone module)

**External Tools**:
- `git` - For diff and change analysis
- `grep`, `awk`, `sed` - For text processing

## Configuration

**Environment Variables**:
```bash
# Workflow artifact patterns (auto-configured)
WORKFLOW_ARTIFACTS=( ... )  # Array of patterns to exclude

# Change type classification
CHANGE_TYPES=(
    ["docs-only"]="Documentation changes only"
    ["tests-only"]="Test files only"
    ["code-only"]="Source code only"
    ["full-stack"]="Mixed changes"
)
```

## Functions

### Artifact Filtering

#### `filter_workflow_artifacts(file_list)`

Filter out ephemeral workflow artifacts from a file list.

**Parameters**:
- `file_list` (string): Newline-separated list of file paths

**Returns**:
- Filtered file list (stdout), one file per line
- Exit code: 0 (always succeeds)

**Example**:
```bash
# Get changed files and filter artifacts
changed_files=$(git diff --name-only HEAD)
filtered=$(filter_workflow_artifacts "$changed_files")
echo "$filtered"
```

**Excluded Patterns**:
- `.ai_workflow/backlog/*` - Execution history
- `.ai_workflow/logs/*` - Log files
- `.ai_workflow/summaries/*` - AI summaries
- `src/workflow/metrics/*` - Metrics data
- `src/workflow/.checkpoints/*` - Checkpoint data
- `src/workflow/.ai_cache/*` - AI response cache
- `*.tmp`, `*.bak`, `*.swp` - Temporary files
- `.DS_Store`, `Thumbs.db` - System files

#### `is_workflow_artifact(file_path)`

Check if a single file is a workflow artifact.

**Parameters**:
- `file_path` (string): Path to check

**Returns**:
- Exit code: 0 (true) if artifact, 1 (false) otherwise

**Example**:
```bash
if is_workflow_artifact ".ai_workflow/logs/run.log"; then
    echo "This is a workflow artifact"
fi
```

### Change Classification

#### `analyze_changes()`

Analyze Git changes and classify by type.

**Parameters**: None (uses Git working directory)

**Returns**:
- Exit code: 0 on success
- Sets global variables:
  - `CHANGE_TYPE`: "docs-only", "tests-only", "code-only", or "full-stack"
  - `DOCS_CHANGED`: true/false
  - `TESTS_CHANGED`: true/false
  - `CODE_CHANGED`: true/false

**Example**:
```bash
analyze_changes

case "$CHANGE_TYPE" in
    "docs-only")
        echo "Running documentation workflow only"
        ;;
    "tests-only")
        echo "Running test workflow only"
        ;;
    "full-stack")
        echo "Running full workflow"
        ;;
esac
```

#### `get_changed_files([base_ref])`

Get list of changed files, filtered for workflow artifacts.

**Parameters**:
- `base_ref` (optional): Git reference for comparison (default: HEAD)

**Returns**:
- Newline-separated list of changed files (stdout)
- Exit code: 0 on success, 1 on error

**Example**:
```bash
# Get changes from HEAD
changed_files=$(get_changed_files)

# Get changes from a specific commit
changed_files=$(get_changed_files "main")

# Process each file
while IFS= read -r file; do
    echo "Changed: $file"
done <<< "$changed_files"
```

#### `classify_file(file_path)`

Classify a single file by type.

**Parameters**:
- `file_path` (string): Path to classify

**Returns**:
- String (stdout): "docs", "tests", "code", or "other"
- Exit code: 0 on success

**Example**:
```bash
file_type=$(classify_file "README.md")
echo "File type: $file_type"  # Output: "docs"

file_type=$(classify_file "tests/test_api.sh")
echo "File type: $file_type"  # Output: "tests"
```

**Classification Rules**:
- **Documentation**: `*.md`, `*.rst`, `*.txt`, `docs/*`
- **Tests**: `tests/*`, `test/*`, `*_test.*`, `*_spec.*`, `*.test.*`
- **Code**: `*.sh`, `*.js`, `*.py`, `*.go`, `*.java`, etc.
- **Other**: Configuration files, build files, etc.

### Advanced Analysis

#### `detect_change_magnitude()`

Detect the scale of changes (minor, moderate, major).

**Parameters**: None

**Returns**:
- String (stdout): "minor", "moderate", or "major"
- Exit code: 0 on success

**Example**:
```bash
magnitude=$(detect_change_magnitude)

case "$magnitude" in
    "minor")
        echo "Small changes - quick validation"
        ;;
    "moderate")
        echo "Medium changes - standard validation"
        ;;
    "major")
        echo "Large changes - full validation"
        ;;
esac
```

**Thresholds**:
- **Minor**: 1-5 files changed, < 100 lines
- **Moderate**: 6-20 files changed, < 500 lines
- **Major**: > 20 files or > 500 lines

#### `get_change_summary()`

Get human-readable summary of changes.

**Parameters**: None

**Returns**:
- Summary text (stdout)
- Exit code: 0 on success

**Example**:
```bash
summary=$(get_change_summary)
echo "$summary"
# Output: "3 documentation files, 2 test files, 1 source file modified"
```

## Usage Patterns

### Basic Change Detection

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"

# Analyze changes
analyze_changes

# Use result for workflow optimization
if [[ "$CHANGE_TYPE" == "docs-only" ]]; then
    # Skip test execution for docs-only changes
    echo "Skipping tests for documentation-only changes"
    SKIP_TESTS=true
fi
```

### Custom Change Analysis

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"

# Get filtered changed files
changed_files=$(get_changed_files)

# Process each file
docs_count=0
test_count=0
code_count=0

while IFS= read -r file; do
    type=$(classify_file "$file")
    case "$type" in
        "docs") ((docs_count++)) ;;
        "tests") ((test_count++)) ;;
        "code") ((code_count++)) ;;
    esac
done <<< "$changed_files"

echo "Changes: $docs_count docs, $test_count tests, $code_count code files"
```

### Integration with Smart Execution

```bash
#!/bin/bash
source "$(dirname "$0")/lib/change_detection.sh"
source "$(dirname "$0")/lib/workflow_optimization.sh"

# Analyze changes
analyze_changes

# Get smart execution recommendations
if [[ "$CHANGE_TYPE" == "docs-only" ]]; then
    # Use docs-only optimization profile
    STEPS_TO_RUN=$(get_docs_only_steps)
elif [[ "$CHANGE_TYPE" == "tests-only" ]]; then
    # Use test-only optimization profile
    STEPS_TO_RUN=$(get_test_only_steps)
else
    # Full workflow
    STEPS_TO_RUN=$(get_all_steps)
fi
```

## Error Handling

**Error Codes**:
- `0` - Success
- `1` - Git operation failed
- `2` - No changes detected
- `3` - Invalid input

**Error Examples**:
```bash
# Handle no changes
if ! get_changed_files > /dev/null 2>&1; then
    echo "No changes detected"
    exit 0
fi

# Handle Git errors
if ! analyze_changes; then
    echo "ERROR: Failed to analyze changes"
    exit 1
fi
```

## Testing

```bash
# Run module tests
cd src/workflow/lib
./test_change_detection.sh

# Test with sample changes
git add README.md
analyze_changes
echo "Change type: $CHANGE_TYPE"  # Should be "docs-only"
git reset README.md
```

## Performance Considerations

- **Change analysis**: O(n) where n = number of changed files
- **Artifact filtering**: O(n×m) where m = number of patterns
- **Git operations**: Depend on repository size

**Optimization Tips**:
- Use `git diff --name-only` for file lists only
- Cache analysis results when possible
- Filter early to reduce processing

## Related Modules

- **workflow_optimization.sh** - Uses change detection for smart execution
- **metrics.sh** - Tracks change detection performance
- **step_execution.sh** - Adapts execution based on change type

## Version History

- **2.0.0** (2025-12-18): Initial modular implementation
  - Added artifact filtering
  - Added change classification
  - Added magnitude detection
  - Added summary generation

## See Also

- [Workflow Optimization Guide](../../guides/OPTIMIZATION.md)
- [Smart Execution](../../user-guide/feature-guide.md#smart-execution)
- [Change Detection Architecture](../../architecture/CHANGE_DETECTION.md)
