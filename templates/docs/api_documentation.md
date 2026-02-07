# API Documentation Template

> **Template Version**: 1.0.0  
> **Purpose**: Comprehensive API documentation template  
> **Usage**: Copy this template when documenting shell modules/functions

---

## Module: [module_name.sh]

### Overview

**Purpose**: Brief description of module purpose  
**Version**: [version]  
**Location**: `src/workflow/lib/[module_name.sh]`  
**Dependencies**: List required modules

**Description**: Detailed explanation of what this module does and when to use it.

---

## Functions

### `function_name()`

**Purpose**: What this function does

**Signature**:
```bash
function_name <arg1> <arg2> [optional_arg]
```

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `arg1` | string | Yes | Description of arg1 |
| `arg2` | number | Yes | Description of arg2 |
| `optional_arg` | boolean | No | Description (default: false) |

**Returns**:
- **Success (0)**: When operation succeeds
- **Failure (1)**: When operation fails

**Output**: What is written to stdout/stderr

**Example**:
```bash
# Basic usage
result=$(function_name "value1" "value2")

# With optional argument
function_name "value1" "value2" true
```

**Error Handling**:
- Returns 1 if arg1 is empty
- Exits with error if dependency missing

---

## Global Variables

### `VARIABLE_NAME`

**Type**: `[string|number|array|associative_array]`  
**Scope**: `[global|local]`  
**Default**: `[default_value]`

**Purpose**: What this variable stores

**Usage**:
```bash
VARIABLE_NAME="value"
echo "${VARIABLE_NAME}"
```

---

## Usage Examples

### Example 1: Basic Usage

```bash
#!/bin/bash
source "src/workflow/lib/[module_name.sh]"

# Use the module
function_name "arg1" "arg2"
```

### Example 2: Advanced Usage

```bash
#!/bin/bash
source "src/workflow/lib/[module_name.sh]"

# Complex workflow
if function_name "test" "123"; then
    echo "Success"
else
    echo "Failed"
fi
```

---

## Integration

### Required Setup

```bash
# Source dependencies first
source "src/workflow/lib/dependency.sh"

# Then source this module
source "src/workflow/lib/[module_name.sh]"
```

### Workflow Integration

**Used by**:
- `step_01_example.sh` - Description of usage
- `step_05_example.sh` - Description of usage

**Depends on**:
- `dependency_module.sh` - Why needed
- `another_module.sh` - Why needed

---

## Testing

### Unit Tests

**Location**: `tests/unit/test_[module_name].sh`

```bash
# Run tests
./tests/unit/test_[module_name].sh
```

### Integration Tests

**Location**: `tests/integration/test_[module_name]_integration.sh`

---

## Error Handling

| Error Code | Condition | Message |
|------------|-----------|---------|
| 1 | Invalid argument | "Error: argument cannot be empty" |
| 2 | File not found | "Error: file does not exist" |

---

## Performance

**Complexity**: O([complexity])  
**Typical Duration**: [X seconds]  
**Resource Usage**: [memory/disk implications]

---

## References

- **Source Code**: `src/workflow/lib/[module_name.sh]`
- **Tests**: `tests/unit/test_[module_name].sh`
- **Related Docs**: [Links to related documentation]
