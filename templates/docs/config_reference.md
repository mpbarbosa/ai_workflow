# Configuration Reference Template

> **Template Version**: 1.0.0  
> **Purpose**: Standard template for documenting configuration keys  
> **Usage**: Copy this template when documenting new configuration entries

---

## Configuration Key: `[key.path.here]`

### Overview

**Location**: `.workflow-config.yaml` or `.workflow_core/config/[filename].yaml`  
**Section**: `[section_name]`  
**Type**: `[string|number|boolean|object|array]`  
**Required**: `[Yes|No]`  
**Default**: `[default_value]` or `None`

**Purpose**: Brief description of what this configuration controls.

---

## Specification

### Syntax

```yaml
[section]:
  [key_name]: [value]
```

### Valid Values

| Value | Type | Description |
|-------|------|-------------|
| `value1` | [type] | Description of value1 |
| `value2` | [type] | Description of value2 |

**Constraints**:
- [Constraint 1]
- [Constraint 2]

---

## Examples

### Basic Usage

```yaml
[section]:
  [key_name]: [value]
```

### Advanced Usage

```yaml
[section]:
  [key_name]:
    [nested]: [value]
```

---

## Related Configuration

- `[related.key.1]` - Relationship description
- `[related.key.2]` - Relationship description

---

## References

- **Source Code**: `[path/to/file.sh]`
- **Related Docs**: [Link to docs]
