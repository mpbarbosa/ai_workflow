# Placeholder/Variable Reference Template

> **Template Version**: 1.0.0  
> **Purpose**: Standard template for documenting placeholders  
> **Usage**: Copy when documenting new placeholder patterns

---

## Placeholder: `{PLACEHOLDER_NAME}`

### Overview

**Pattern**: `{PLACEHOLDER_NAME}`  
**Type**: `[string|number|path]`  
**Source**: [user input|config|auto-detected]

**Purpose**: Brief description of placeholder.

---

## Substitution Examples

### Example 1

**Template**: `Text with {PLACEHOLDER_NAME}`  
**Value**: `example`  
**Result**: `Text with example`

---

## Where Used

- **File**: `path/to/template.md` (line X)
- **File**: `path/to/config.yaml` (line Y)

---

## Validation

```bash
# Validation logic
if [[ ! condition ]]; then
    error "Message"
fi
```

---

## References

- **Source**: `path/to/implementation.sh`
- **Templates**: `path/to/templates/`
