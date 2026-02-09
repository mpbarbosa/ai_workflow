# Deprecation Notices

**Version**: 4.0.1  
**Last Updated**: 2026-02-09

> ⚠️ **Purpose**: Track deprecated features, legacy APIs, and migration timelines

## Table of Contents

- [Current Deprecations](#current-deprecations)
- [Migration Guide](#migration-guide)
- [Removal Timeline](#removal-timeline)
- [Legacy Features](#legacy-features)

---

## Current Deprecations

### 1. Legacy Step Numbering (v4.0.0)

**Status**: ⚠️ Deprecated  
**Removal**: v5.0.0 (estimated 2026-Q2)

**What's Deprecated**:
- Numeric step file names (e.g., `step_01_documentation.sh`, `step_02_test_planning.sh`)
- Numeric step references in `--steps` option (though still supported for backward compatibility)

**Replacement**:
- Descriptive step names (e.g., `documentation_updates.sh`, `test_planning.sh`)
- Descriptive references: `--steps documentation_updates,test_execution`

**Migration**:
```bash
# Old (deprecated but still works)
./execute_tests_docs_workflow.sh --steps 0,1,2,5

# New (recommended)
./execute_tests_docs_workflow.sh --steps analyze,documentation_updates,test_planning,test_execution
```

**Timeline**:
- v4.0.0 (2026-02-08): Deprecation announced, both styles work
- v4.5.0 (2026-03): Deprecation warnings added
- v5.0.0 (2026-Q2): Legacy numeric names removed

**See**: [Migration Guide v4.0](../MIGRATION_GUIDE_v4.0.md)

---

### 2. AI Helpers `role` Field (Planned v2.5.0)

**Status**: ⚠️ Deprecated  
**Removal**: v5.0.0 (estimated 2026-Q2)

**What's Deprecated**:
- `role:` field in AI persona configurations (`.workflow_core/config/ai_helpers.yaml`)
- 15 persona definitions contain legacy `role` fields for backward compatibility

**Replacement**:
- Personas use `persona:` field instead
- Modern AI model configuration uses direct persona references

**Example**:
```yaml
# Old (deprecated)
documentation_specialist:
  role: "documentation expert"  # Legacy field
  persona: "documentation_specialist"

# New (current)
documentation_specialist:
  persona: "documentation_specialist"
  expertise: "Technical documentation, API docs, user guides"
```

**Migration**: No action required - backward compatible. Fields will be removed in v5.0.0.

**Timeline**:
- v2.4.1: Deprecation notice in config comments
- v4.0.0: Still present for compatibility
- v5.0.0 (2026-Q2): Complete removal

---

### 3. Old Configuration File Names

**Status**: ✅ Migrated (v3.0.0)  
**Removal**: Completed

**What Was Deprecated**:
- `.workflow_config` (no extension)
- `workflow_config.yml` (wrong extension)

**Replacement**:
- `.workflow-config.yaml` (standardized)

**Migration**: Automatic migration script provided in v2.8.0

---

### 4. Legacy Pre-Commit Hook Location

**Status**: ✅ Migrated (v3.0.0)  
**Removal**: Completed

**What Was Deprecated**:
- Pre-commit hooks in `scripts/hooks/`
- Manual hook installation

**Replacement**:
- Standard Git hooks: `.git/hooks/pre-commit`
- `--install-hooks` command for automatic installation

**Migration**:
```bash
# Install modern hooks
./execute_tests_docs_workflow.sh --install-hooks
```

---

## Migration Guide

### From v3.x to v4.0

**Major Changes**:
1. Configuration-driven step execution
2. Descriptive step names
3. Updated module count (20 → 23 steps)

**Action Required**:
```bash
# Update step references in scripts/CI
# Old
--steps 0,1,2,5,7

# New
--steps analyze,documentation_updates,test_planning,test_execution,code_review
```

**See**: [Complete Migration Guide](../MIGRATION_GUIDE_v4.0.md)

---

### From v2.x to v3.0

**Major Changes**:
1. Pre-commit hooks system
2. Configuration file standardization
3. Audio notifications

**Action Required**:
```bash
# Rename config file (if exists)
mv .workflow_config .workflow-config.yaml

# Install new pre-commit hooks
./execute_tests_docs_workflow.sh --install-hooks
```

---

## Removal Timeline

### v5.0.0 (Planned 2026-Q2)

**Breaking Changes**:
- Remove legacy numeric step names
- Remove `role:` field from AI configs
- Remove backward compatibility shims
- Require `.workflow-config.yaml` (no fallbacks)

**Preparation**:
1. Migrate to descriptive step names now
2. Update CI/CD pipelines
3. Review deprecation warnings in logs

---

### v4.5.0 (Planned 2026-03)

**Deprecation Warnings**:
- Add warnings when using numeric step references
- Log messages when legacy config detected
- Suggest modern alternatives in output

---

## Legacy Features

### Still Supported (But Discouraged)

#### 1. Numeric Step References

```bash
# Still works but discouraged
./execute_tests_docs_workflow.sh --steps 0,5,7

# Modern equivalent
./execute_tests_docs_workflow.sh --steps analyze,test_execution,code_review
```

**Why Discouraged**: 
- Less readable
- Harder to maintain
- Breaks when step order changes

#### 2. Mixed Syntax

```bash
# Mixing old and new (works but confusing)
./execute_tests_docs_workflow.sh --steps 0,documentation_updates,5,code_review
```

**Recommendation**: Use consistent style (preferably all descriptive names)

---

### Removed Features

#### 1. Step Numbers in File Names (v5.0.0+)

**Removed**: Files like `step_01_*.sh` will not exist

**Impact**: Direct file references will break:
```bash
# Will fail in v5.0.0+
source src/workflow/steps/step_01_documentation.sh

# Use this instead
source src/workflow/steps/documentation_updates.sh
```

#### 2. Old Config Format (v3.0.0)

**Removed**: Non-YAML config files

**Impact**: Projects using `.workflow_config` must migrate to `.workflow-config.yaml`

---

## How to Check for Deprecations

### Automated Check

```bash
# Run deprecation check
./scripts/check_deprecations.sh

# Output shows:
# ⚠️  Using legacy step references in CI config
# ⚠️  Old config file format detected
# ✓  No deprecated AI persona fields found
```

### Manual Review

```bash
# Check for numeric step references
grep -r "steps.*[0-9]" .github/ scripts/

# Check for old config files
ls -la .workflow_config* workflow_config.*

# Check AI config for role fields
grep "role:" .workflow_core/config/ai_helpers.yaml
```

---

## Getting Help

### Questions About Deprecations

- **Documentation**: [Migration Guides](../guides/)
- **Issues**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mpbarbosa/ai_workflow/discussions)

### Reporting Issues

If a deprecation causes problems:

1. **Check this document** for migration path
2. **Review migration guide** for your version
3. **Search existing issues** on GitHub
4. **Create new issue** if not found, include:
   - Current version
   - Deprecated feature used
   - Error message/behavior
   - Steps to reproduce

---

## Deprecation Policy

### Our Commitment

1. **Notice Period**: Minimum 2 major versions (4-6 months)
2. **Migration Path**: Always provide clear alternative
3. **Backward Compatibility**: Maintain during deprecation period
4. **Documentation**: Clear notices in all relevant docs
5. **Warnings**: Log warnings in affected workflows

### Example Timeline

```
v4.0.0: Feature deprecated, still works, documented
  ↓
v4.5.0: Warnings added to logs, migration guide published
  ↓
v5.0.0: Feature removed, fallback removed
```

### Exceptions

Immediate removal (no deprecation period) only for:
- Security vulnerabilities
- Data corruption risks
- Critical bugs with no safe alternative

---

**Last Updated**: 2026-02-09  
**Version**: 4.0.1  
**Next Review**: 2026-03-01
