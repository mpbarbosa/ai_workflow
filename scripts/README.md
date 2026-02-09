# Utility Scripts Documentation

This directory contains utility scripts for repository maintenance, documentation validation, and workflow management.

**Version**: 1.0.0  
**Last Updated**: 2026-02-08

## Quick Reference

```bash
# Artifact cleanup
./scripts/cleanup_artifacts.sh --all --older-than 30
./scripts/cleanup_artifacts.sh --all --dry-run

# Documentation validation
python3 scripts/check_doc_links.py
python3 scripts/validate_api_docs.py
./scripts/validate_doc_examples.sh

# Repository maintenance
./scripts/bump_version.sh <new-version>
./scripts/standardize_dates.sh
./scripts/doc_diff_checker.sh
```

---

## Script Categories

### Artifact Cleanup

#### cleanup_artifacts.sh

Comprehensive artifact cleanup utility for workflow execution artifacts.

**Purpose**: Remove old workflow artifacts (logs, backlog, metrics, cache) to keep repository clean.

**Usage**:
```bash
# Clean all artifacts older than 30 days
./scripts/cleanup_artifacts.sh --all --older-than 30

# Dry-run (preview only)
./scripts/cleanup_artifacts.sh --all --dry-run

# Clean specific types
./scripts/cleanup_artifacts.sh --logs --older-than 7
./scripts/cleanup_artifacts.sh --backlog --older-than 60
./scripts/cleanup_artifacts.sh --metrics --older-than 90
./scripts/cleanup_artifacts.sh --cache
```

**Options**:
- `--all` - Clean all artifact types
- `--logs` - Clean workflow logs
- `--backlog` - Clean workflow backlog
- `--metrics` - Clean metrics data
- `--cache` - Clean AI cache
- `--older-than DAYS` - Only clean artifacts older than N days (default: 30)
- `--dry-run` - Show what would be deleted without deleting
- `--verbose` - Detailed output
- `--help` - Show help message

**Features**:
- Age-based filtering
- Dry-run mode for safety
- Colored output with statistics
- Confirmation prompts
- Detailed logging

**Exit Codes**:
- 0 = Success
- 1 = Error (invalid options, permission denied, etc.)

---

#### cleanup_repository.sh

Repository-wide cleanup including Git history optimization.

**Purpose**: Comprehensive repository cleanup including deprecated files and Git optimization.

**Usage**:
```bash
# Standard cleanup
./scripts/cleanup_repository.sh

# With Git garbage collection
./scripts/cleanup_repository.sh --aggressive
```

**Features**:
- Removes deprecated files
- Cleans up temporary files
- Git garbage collection
- Repository size optimization

---

### Documentation Validation

#### check_doc_links.py

Validates all links in documentation files.

**Purpose**: Check for broken internal and external links in documentation.

**Usage**:
```bash
# Check all documentation
python3 scripts/check_doc_links.py

# Check specific directory
python3 scripts/check_doc_links.py docs/guides/

# Verbose output
python3 scripts/check_doc_links.py --verbose
```

**Checks**:
- Internal links (relative paths)
- External URLs (HTTP/HTTPS)
- Anchor links
- Image references

**Exit Codes**:
- 0 = All links valid
- 1 = Broken links found

---

#### validate_api_docs.py

Validates API documentation completeness and accuracy.

**Purpose**: Ensure API documentation matches actual code exports and signatures.

**Usage**:
```bash
# Validate all API docs
python3 scripts/validate_api_docs.py

# Check specific modules
python3 scripts/validate_api_docs.py src/workflow/lib/
```

**Validations**:
- Function signatures match documentation
- All exported functions documented
- Parameter types documented
- Return values documented

---

#### validate_doc_examples.sh

Validates code examples in documentation.

**Purpose**: Ensure documentation examples are syntactically correct and runnable.

**Usage**:
```bash
# Validate all examples
./scripts/validate_doc_examples.sh

# Check specific files
./scripts/validate_doc_examples.sh docs/guides/CONDITIONAL_EXECUTION.md
```

**Features**:
- Bash syntax checking
- Python syntax checking
- YAML syntax checking
- Example output verification

---

#### validate_docs.sh

General documentation validation.

**Purpose**: Run comprehensive documentation validation checks.

**Usage**:
```bash
# Run all validation checks
./scripts/validate_docs.sh

# Quick validation (skip expensive checks)
./scripts/validate_docs.sh --quick
```

**Checks**:
- Link validation
- Example validation
- Structure validation
- Context block validation

---

#### validate_context_blocks.py

Validates documentation context blocks (from .workflow_core).

**Purpose**: Ensure context blocks in documentation are properly formatted and contain required information.

**Usage**:
```bash
# Validate all docs
python3 scripts/validate_context_blocks.py docs/

# Check specific file
python3 scripts/validate_context_blocks.py docs/guides/VALIDATION_SCRIPTS.md
```

**Note**: This is a copy from `.workflow_core/scripts/` for convenience.

---

### Repository Maintenance

#### bump_version.sh

Updates version numbers across all project files.

**Purpose**: Consistently update version numbers in documentation, badges, and version files.

**Usage**:
```bash
# Bump to new version
./scripts/bump_version.sh 4.1.0

# Dry-run (preview changes)
./scripts/bump_version.sh 4.1.0 --dry-run
```

**Updates**:
- README.md badges
- CHANGELOG.md
- Version files
- Documentation references
- Git tags (optional)

**Features**:
- Semantic version validation
- Dry-run mode
- Automatic Git tagging
- Changelog updates

---

#### standardize_dates.sh

Standardizes date formats across documentation.

**Purpose**: Ensure consistent date formatting (ISO 8601: YYYY-MM-DD) throughout documentation.

**Usage**:
```bash
# Standardize all dates
./scripts/standardize_dates.sh

# Preview changes
./scripts/standardize_dates.sh --dry-run

# Process specific directory
./scripts/standardize_dates.sh docs/guides/
```

**Features**:
- Converts various date formats to ISO 8601
- Preserves Git commit dates
- Safe backup creation
- Detailed change log

---

#### doc_diff_checker.sh

Checks for documentation inconsistencies and differences.

**Purpose**: Identify discrepancies between related documentation files.

**Usage**:
```bash
# Check all documentation
./scripts/doc_diff_checker.sh

# Check specific files
./scripts/doc_diff_checker.sh docs/guides/CONDITIONAL_EXECUTION.md docs/PROJECT_REFERENCE.md
```

**Features**:
- Cross-reference validation
- Duplicate content detection
- Version consistency checking
- Missing documentation detection

---

#### function_documentation.sh

Generates function documentation from source code.

**Purpose**: Extract and document shell functions from source code.

**Usage**:
```bash
# Generate docs for all modules
./scripts/function_documentation.sh src/workflow/lib/

# Generate for specific file
./scripts/function_documentation.sh src/workflow/lib/ai_helpers.sh
```

**Features**:
- Extracts function signatures
- Parses inline documentation
- Generates markdown documentation
- Cross-references dependencies

---

#### fix_documentation_issues.sh

Automatically fixes common documentation issues.

**Purpose**: Auto-fix formatting issues, broken links, and inconsistencies.

**Usage**:
```bash
# Fix all issues
./scripts/fix_documentation_issues.sh

# Preview fixes (dry-run)
./scripts/fix_documentation_issues.sh --dry-run

# Fix specific types
./scripts/fix_documentation_issues.sh --links-only
```

**Fixes**:
- Broken internal links
- Inconsistent formatting
- Missing headers
- Trailing whitespace

---

#### migrate_to_named_steps.sh

Migration utility for v4.0.0 configuration-driven steps.

**Purpose**: Convert legacy numeric step references to named step identifiers.

**Usage**:
```bash
# Migrate all files
./scripts/migrate_to_named_steps.sh

# Preview changes
./scripts/migrate_to_named_steps.sh --dry-run

# Migrate specific directory
./scripts/migrate_to_named_steps.sh docs/
```

**Changes**:
- Converts `--steps 0,2,3` to `--steps preprocessing,documentation_updates,test_execution`
- Updates documentation references
- Preserves backward compatibility notes

---

## Submodule Scripts

Additional validation scripts from `.workflow_core/scripts/`:

### validate_structure.py

Validates documentation structure and organization.

**Usage**:
```bash
python3 .workflow_core/scripts/validate_structure.py docs/
```

**Checks**:
- Required sections present
- Proper heading hierarchy
- Table of contents accuracy
- Cross-reference validity

---

### validate_context_blocks.py

Validates context block formatting and content.

**Usage**:
```bash
python3 .workflow_core/scripts/validate_context_blocks.py docs/
```

**Checks**:
- Context block syntax
- Required fields present
- Version information
- Author attribution

---

## Best Practices

### Before Committing

Run these validation checks:

```bash
# Quick validation
python3 scripts/check_doc_links.py
python3 .workflow_core/scripts/validate_structure.py docs/

# Comprehensive validation (slower)
./scripts/validate_docs.sh
./scripts/validate_doc_examples.sh
```

### Regular Maintenance

Schedule periodic cleanups:

```bash
# Weekly: Clean old logs
./scripts/cleanup_artifacts.sh --logs --older-than 7

# Monthly: Clean old backlog
./scripts/cleanup_artifacts.sh --backlog --older-than 30

# Quarterly: Clean old metrics
./scripts/cleanup_artifacts.sh --metrics --older-than 90
```

### Version Updates

When releasing new versions:

```bash
# 1. Bump version
./scripts/bump_version.sh <new-version>

# 2. Standardize dates
./scripts/standardize_dates.sh

# 3. Validate all docs
./scripts/validate_docs.sh

# 4. Check for inconsistencies
./scripts/doc_diff_checker.sh
```

---

## Prerequisites

### Python Scripts

- Python 3.8 or higher
- Standard library only (no external dependencies)

### Bash Scripts

- Bash 4.0 or higher
- Standard Unix utilities: `find`, `grep`, `sed`, `awk`
- Git (for repository operations)

### Platform Support

| Script Type | Linux | macOS | Windows |
|-------------|-------|-------|---------|
| Python scripts | ✅ | ✅ | ✅ |
| Bash scripts | ✅ | ✅ | ⚠️ WSL/Git Bash |

---

## Contributing

When adding new scripts:

1. Add appropriate shebang line (`#!/usr/bin/env bash` or `#!/usr/bin/env python3`)
2. Make executable: `chmod +x scripts/new-script.sh`
3. Add usage documentation to this README
4. Include `--help` option in the script
5. Document exit codes
6. Add example usage
7. Test on multiple platforms if possible

---

## Troubleshooting

### Permission Denied

```bash
# Fix executable permissions
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

### Python Not Found

```bash
# Use python3 explicitly
python3 scripts/check_doc_links.py

# Or create symlink
ln -s $(which python3) /usr/local/bin/python
```

### Bash Version Issues

```bash
# Check Bash version
bash --version

# Use newer Bash if available
/usr/local/bin/bash scripts/cleanup_artifacts.sh
```

---

## See Also

- [Contributing Guide](../CONTRIBUTING.md) - Contribution guidelines
- [Project Reference](../docs/PROJECT_REFERENCE.md) - Complete project documentation
- [Workflow Documentation](../docs/workflow-automation/) - Workflow system details
- [.workflow_core Scripts](../.workflow_core/scripts/README.md) - Submodule utilities

---

**Maintained by**: AI Workflow Automation Team  
**License**: MIT  
**Last Updated**: 2026-02-08
