# Documentation Templates

This directory contains standardized templates for creating consistent, high-quality documentation across the AI Workflow Automation project.

## Available Templates

### 1. Configuration Reference Template
**File**: `config_reference.md`  
**Purpose**: Document configuration keys in YAML files  
**Use When**: Adding new configuration options to `.workflow-config.yaml` or `.workflow_core/config/*.yaml`

**Example**:
```yaml
# Documenting this configuration:
project:
  name: "My Project"
  kind: "nodejs_api"
```

→ Use `config_reference.md` to create documentation for `project.name` and `project.kind`

---

### 2. Placeholder/Variable Reference Template
**File**: `placeholder_reference.md`  
**Purpose**: Document template placeholders and substitution variables  
**Use When**: Creating new placeholders in prompts, templates, or configuration files

**Example**:
```
Template: "Processing {PROJECT_NAME} files..."
```

→ Use `placeholder_reference.md` to document the `{PROJECT_NAME}` placeholder

---

### 3. API Documentation Template
**File**: `api_documentation.md`  
**Purpose**: Document shell modules and functions  
**Use When**: Creating new library modules or adding functions to existing modules

**Example**:
```bash
# Documenting this module:
src/workflow/lib/new_feature.sh
```

→ Use `api_documentation.md` to create `docs/api/core/new_feature.md`

---

## How to Use Templates

### Step 1: Copy the Template

```bash
# For configuration documentation
cp templates/docs/config_reference.md docs/reference/config/[key_name].md

# For placeholder documentation
cp templates/docs/placeholder_reference.md docs/reference/placeholders/[placeholder_name].md

# For API documentation
cp templates/docs/api_documentation.md docs/api/core/[module_name].md
```

### Step 2: Replace Placeholders

All templates use `[bracketed]` placeholders. Replace these with actual content:

```markdown
## Configuration Key: `[key.path.here]`
↓
## Configuration Key: `project.kind`
```

### Step 3: Remove Unused Sections

If a section doesn't apply to your documentation, remove it:

```markdown
## Advanced Usage
[If no advanced usage, delete this entire section]
```

### Step 4: Add Custom Sections

Templates are starting points. Add sections as needed:

```markdown
## Custom Section for My Feature
[Additional content specific to your needs]
```

---

## Template Structure

### Common Elements in All Templates

1. **Version Header**: Track template version
2. **Overview**: High-level description
3. **Examples**: Real-world usage
4. **References**: Links to related content
5. **Usage Notes**: Instructions for using the template

### Placeholder Conventions

- `[bracketed]` = Must replace with actual content
- `{BRACED}` = Template variable/placeholder (keep as-is when documenting)
- `` `code` `` = Literal code/values

---

## Documentation Standards

### Writing Guidelines

1. **Be Concise**: Short paragraphs, clear language
2. **Show Examples**: Include at least 2 examples per concept
3. **Link Related Content**: Cross-reference related documentation
4. **Keep Updated**: Update version history when changing

### Code Block Guidelines

Always specify language for syntax highlighting:

```bash
# ✅ Good - language specified
echo "Hello"
```

```
# ❌ Bad - no language
echo "Hello"
```

### Link Guidelines

Use relative links for internal documentation:

```markdown
✅ See [API Reference](../api/README.md)
❌ See [API Reference](https://github.com/.../docs/api/README.md)
```

---

## Validation

Before committing documentation, run validators:

```bash
# Validate API documentation
python3 scripts/validate_api_docs.py docs/api/

# Check for broken links
python3 scripts/check_doc_links.py docs/
```

---

## Examples of Good Documentation

### Example 1: Configuration Key

See `docs/reference/config/project_kind.md` for a well-documented configuration key following the template.

### Example 2: Placeholder

See `docs/reference/placeholders/project_name.md` for a well-documented placeholder following the template.

### Example 3: API Function

See `docs/api/core/metrics.md` for well-documented API functions following the template.

---

## Template Maintenance

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-07 | Initial templates created |

### Template Updates

When updating templates:

1. Increment version number
2. Update version history
3. Notify documentation maintainers
4. Update existing docs if breaking changes

---

## Quick Reference

### Template Selection Guide

| You're Documenting... | Use This Template |
|----------------------|------------------|
| YAML configuration key | `config_reference.md` |
| Template variable/placeholder | `placeholder_reference.md` |
| Shell script module/function | `api_documentation.md` |
| New feature or guide | Create custom from scratch |

### Common Mistakes to Avoid

❌ **Don't**:
- Leave `[bracketed]` placeholders in final docs
- Skip examples section
- Forget to update version history
- Use absolute URLs for internal links

✅ **Do**:
- Replace all placeholders
- Provide real examples
- Link to source code
- Use relative paths

---

## Getting Help

- **Documentation Issues**: File issue with `docs:` label
- **Template Problems**: Contact documentation team
- **Examples Needed**: Check `docs/` for similar documentation
- **Style Questions**: See `docs/reference/documentation-style-guide.md`

---

## Contributing

To improve these templates:

1. Fork and create branch
2. Update template file(s)
3. Update this README
4. Test with real documentation
5. Submit pull request

---

**Last Updated**: 2026-02-07  
**Maintainer**: Documentation Team  
**Questions**: See `docs/MAINTAINERS.md`
