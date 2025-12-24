# Release Process - AI Workflow Automation

**Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Status**: ✅ Official Process

---

## 📋 Table of Contents

- [Overview](#overview)
- [Semantic Versioning](#semantic-versioning)
- [Release Types](#release-types)
- [Pre-Release Checklist](#pre-release-checklist)
- [Release Workflow](#release-workflow)
- [Version Bumping](#version-bumping)
- [Release Notes](#release-notes)
- [Breaking Changes](#breaking-changes)
- [Hotfix Process](#hotfix-process)
- [Release Schedule](#release-schedule)

---

## Overview

### Release Philosophy

The AI Workflow Automation project follows a **structured release process** with:

1. **Semantic Versioning**: Clear version numbering (MAJOR.MINOR.PATCH)
2. **Predictable Schedule**: Regular releases with clear timelines
3. **Comprehensive Testing**: 100% test coverage before release
4. **Detailed Release Notes**: Complete documentation of changes
5. **Backward Compatibility**: Minimize breaking changes

### Current Version

**Version**: v2.4.0  
**Released**: 2025-12-23  
**Next Release**: v2.5.0 (Target: 2026-01-23)

---

## Semantic Versioning

We follow [Semantic Versioning 2.0.0](https://semver.org/):

### Version Format: MAJOR.MINOR.PATCH

```
v2.4.0
│ │ │
│ │ └─ PATCH: Bug fixes, minor improvements (backward compatible)
│ └─── MINOR: New features, enhancements (backward compatible)
└───── MAJOR: Breaking changes, architectural changes
```

### Version Number Rules

#### MAJOR Version (X.0.0)

**When to Bump**:
- Breaking API changes
- Removal of deprecated features
- Major architectural changes
- Incompatible configuration changes
- Changes that require user action to migrate

**Examples**:
- Remove support for old configuration format
- Change command-line argument syntax
- Require different Node.js version
- Remove backward compatibility layer

**Current**: v2.x.x (v2.0.0 released 2025-12-14)

---

#### MINOR Version (x.Y.0)

**When to Bump**:
- New features (backward compatible)
- New workflow steps
- New AI personas
- New optimization features
- New command-line options
- Deprecate features (but still support them)

**Examples**:
- Add Step 14 (UX Analysis) ✅ v2.4.0
- Add AI response caching ✅ v2.3.0
- Add parallel execution ✅ v2.3.0
- Add smart execution ✅ v2.3.0
- Add configuration wizard ✅ v2.3.1

**Current**: v2.4.x (v2.4.0 released 2025-12-23)

---

#### PATCH Version (x.x.Z)

**When to Bump**:
- Bug fixes (no new features)
- Performance improvements
- Documentation updates
- Test improvements
- Dependency updates (non-breaking)
- Security patches

**Examples**:
- Fix checkpoint file syntax errors ✅ v2.3.1
- Fix metrics calculation errors ✅ v2.3.1
- Fix Step 7 directory navigation ✅ v2.3.1
- Update documentation typos
- Improve error messages

**Current**: v2.4.0 (no patches yet)

---

## Release Types

### 1. Major Release (X.0.0)

**Frequency**: Every 6-12 months  
**Scope**: Breaking changes, major new features  
**Testing**: Full regression testing, beta period  
**Notice**: 30-day advance notice

**Process**:
1. Announce breaking changes 30 days before release
2. Create migration guide
3. Beta release for testing (X.0.0-beta.1)
4. Release candidate (X.0.0-rc.1)
5. Final release

**Example**: v3.0.0 (planned for 2026-06-01)
- Remove deprecated v1.x configuration support
- New plugin system architecture
- Require Node.js 26+

---

### 2. Minor Release (x.Y.0)

**Frequency**: Every 2-4 weeks  
**Scope**: New features, enhancements (backward compatible)  
**Testing**: Full test suite, integration testing  
**Notice**: 7-day advance notice (optional)

**Process**:
1. Feature development complete
2. All tests pass (100% coverage)
3. Documentation updated
4. Release notes prepared
5. Tag and release

**Recent Examples**:
- **v2.4.0** (2025-12-23): Step 14 - UX Analysis
- **v2.3.1** (2025-12-18): Critical fixes & checkpoint control
- **v2.3.0** (2025-12-18): Smart execution, parallel execution, AI caching

---

### 3. Patch Release (x.x.Z)

**Frequency**: As needed (typically 1-2 weeks)  
**Scope**: Bug fixes only  
**Testing**: Affected functionality tested  
**Notice**: None required

**Process**:
1. Fix identified bug
2. Write regression test
3. All tests pass
4. Tag and release immediately

**Example**: v2.4.1 (if needed)
- Fix UI detection false positive
- Fix cache cleanup edge case

---

### 4. Hotfix Release (x.x.Z)

**Frequency**: Emergency only  
**Scope**: Critical security or data loss bugs  
**Testing**: Minimal, focused testing  
**Notice**: Immediate release

**Process**:
1. Identify critical issue
2. Create hotfix branch from latest release tag
3. Implement minimal fix
4. Test affected functionality
5. Release immediately
6. Backport to main branch

**Example**: v2.4.1 (hypothetical)
- Fix data corruption in AI cache
- Fix security vulnerability in file operations

---

## Pre-Release Checklist

Before creating any release, complete this checklist:

### Code Quality

- [ ] All tests pass (`./tests/run_all_tests.sh`)
- [ ] Test coverage remains at 100%
- [ ] No compiler warnings or linting errors
- [ ] Code review completed (if applicable)
- [ ] No console.log or debug statements

### Documentation

- [ ] README.md updated with new version
- [ ] CHANGELOG.md / Release notes created
- [ ] Migration guide created (if breaking changes)
- [ ] API documentation updated
- [ ] Configuration schema updated (if changed)
- [ ] Feature documentation complete

### Version Updates

- [ ] Version bumped in `execute_tests_docs_workflow.sh`
- [ ] Version bumped in `README.md`
- [ ] Version bumped in `.github/copilot-instructions.md`
- [ ] Version bumped in all relevant docs

### Testing

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Self-test passes (`./execute_tests_docs_workflow.sh --smart-execution --parallel`)
- [ ] Test on sample projects (if applicable)
- [ ] Performance benchmarks run (if changed)

### Git

- [ ] All changes committed
- [ ] Commit messages follow convention
- [ ] Branch up to date with main
- [ ] No merge conflicts

---

## Release Workflow

### Step-by-Step Process

#### 1. Prepare Release Branch

```bash
# Create release branch from main
git checkout main
git pull origin main
git checkout -b release/v2.5.0

# Bump version numbers
./scripts/bump_version.sh 2.5.0
```

#### 2. Update Version Numbers

**Files to Update**:
```bash
# Main script
src/workflow/execute_tests_docs_workflow.sh
  # Line 8: # Version: 2.5.0

# README
README.md
  # Line 7: **Version**: v2.5.0

# Copilot Instructions
.github/copilot-instructions.md
  # Update version references
```

**Automated Script** (recommended):
```bash
#!/bin/bash
# scripts/bump_version.sh

NEW_VERSION="$1"

if [[ -z "${NEW_VERSION}" ]]; then
    echo "Usage: $0 <version>"
    exit 1
fi

# Update main script
sed -i "s/# Version: .*/# Version: ${NEW_VERSION}/" \
    src/workflow/execute_tests_docs_workflow.sh

# Update README
sed -i "s/\*\*Version\*\*: v.*/\*\*Version\*\*: v${NEW_VERSION}/" \
    README.md

# Update copilot instructions
sed -i "s/\*\*Version\*\*: .*/\*\*Version\*\*: ${NEW_VERSION}/" \
    .github/copilot-instructions.md

echo "✅ Version bumped to ${NEW_VERSION}"
```

#### 3. Create Release Notes

**Template**: `docs/RELEASE_NOTES_vX.Y.Z.md`

```markdown
# Release Notes: Version X.Y.Z

**Release Date**: YYYY-MM-DD  
**Status**: ✅ Complete

---

## 🎉 Major Features

[List major new features]

## ✨ What's New

### Feature 1: [Name]

[Description]

### Feature 2: [Name]

[Description]

## 🐛 Bug Fixes

- Fixed [issue description]
- Fixed [issue description]

## 📋 Implementation Details

### New Files

1. **`file1.sh`** (XXX lines)
   - [Description]

### Modified Files

1. **`file1.sh`**
   - [Changes]

## 🔧 Configuration Updates

[Any configuration changes]

## ⚡ Performance Improvements

[Any performance improvements with benchmarks]

## 🔄 Migration Guide

[If breaking changes, provide migration steps]

## 📚 Documentation Updates

- [Documentation changes]

## 🙏 Contributors

- [Contributors if applicable]

---

**Full Changelog**: https://github.com/mpbarbosa/ai_workflow/compare/v2.X.Y...v2.X.Z
```

#### 4. Run Full Test Suite

```bash
# Run all tests
./tests/run_all_tests.sh

# Run self-test
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel

# Run performance benchmarks (if changed)
./scripts/run_benchmarks.sh
```

#### 5. Commit Release Changes

```bash
git add -A
git commit -m "chore: Release v2.5.0

- Bump version to 2.5.0
- Update release notes
- Update documentation
"
```

#### 6. Create Git Tag

```bash
# Create annotated tag
git tag -a v2.5.0 -m "Release v2.5.0: [Brief description]

Major changes:
- [Feature 1]
- [Feature 2]
- [Bug fix 1]
"

# Verify tag
git tag -l -n9 v2.5.0
```

#### 7. Push Release

```bash
# Push branch
git push origin release/v2.5.0

# Push tag
git push origin v2.5.0
```

#### 8. Create GitHub Release

1. Go to https://github.com/mpbarbosa/ai_workflow/releases/new
2. Select tag: `v2.5.0`
3. Release title: `v2.5.0: [Brief description]`
4. Copy release notes into description
5. Check "Set as the latest release"
6. Click "Publish release"

#### 9. Merge to Main

```bash
# Create pull request
gh pr create \
  --base main \
  --head release/v2.5.0 \
  --title "Release v2.5.0" \
  --body "See release notes: docs/RELEASE_NOTES_v2.5.0.md"

# After approval, merge
gh pr merge --squash
```

#### 10. Announce Release

- Update project README with latest version
- Post in project discussions/announcements
- Notify users of breaking changes (if any)

---

## Version Bumping

### Quick Reference

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking change | MAJOR | v2.4.0 → v3.0.0 |
| New feature | MINOR | v2.4.0 → v2.5.0 |
| Bug fix | PATCH | v2.4.0 → v2.4.1 |
| Security fix | PATCH | v2.4.0 → v2.4.1 |
| Documentation | PATCH | v2.4.0 → v2.4.1 |

### Decision Tree

```
Does it break backward compatibility?
├─ YES → MAJOR version bump (X.0.0)
└─ NO
   ├─ Does it add new functionality?
   │  ├─ YES → MINOR version bump (x.Y.0)
   │  └─ NO → PATCH version bump (x.x.Z)
   └─ Is it a bug fix?
      └─ YES → PATCH version bump (x.x.Z)
```

### Examples

#### MAJOR (Breaking Changes)

```bash
# v2.4.0 → v3.0.0

# Breaking: Remove deprecated --old-flag option
- ./execute_tests_docs_workflow.sh --old-flag  # ❌ Removed
+ ./execute_tests_docs_workflow.sh --new-flag  # ✅ Use this instead

# Breaking: Change configuration format
- config.yaml: { version: "1" }  # ❌ Old format
+ config.yaml: { schema_version: 2 }  # ✅ New format
```

#### MINOR (New Features)

```bash
# v2.4.0 → v2.5.0

# Add new command-line option
./execute_tests_docs_workflow.sh --new-feature  # ✅ New option

# Add new workflow step
step_15_security_scan.sh  # ✅ New step

# Add new AI persona
security_analyst  # ✅ New persona
```

#### PATCH (Bug Fixes)

```bash
# v2.4.0 → v2.4.1

# Fix incorrect behavior
- cache_cleanup()  # ❌ Bug: Deletes wrong files
+ cache_cleanup()  # ✅ Fix: Deletes correct files

# Fix documentation typo
- "40-90% faster"  # ❌ Typo
+ "40-85% faster"  # ✅ Correct
```

---

## Release Notes

### Template Structure

Every release must have a release notes document:

**Filename**: `docs/RELEASE_NOTES_vX.Y.Z.md`

**Required Sections**:
1. **Title**: Release Notes: Version X.Y.Z
2. **Metadata**: Date, status, branch
3. **Major Features**: Headline features
4. **What's New**: Detailed new features
5. **Bug Fixes**: Fixed issues
6. **Implementation Details**: New/modified files
7. **Configuration Updates**: Config changes
8. **Performance Improvements**: With data
9. **Migration Guide**: If breaking changes
10. **Documentation Updates**: Doc changes

### Writing Good Release Notes

#### ✅ Good Examples

```markdown
## 🎉 Major Features

### Step 14: UX Analysis

A new workflow step that intelligently analyzes UI code:

- **Smart Detection**: Automatically detects UI projects (React, Vue, Static)
- **AI-Powered**: 14th specialized AI persona with UX expertise
- **Accessibility Focus**: WCAG 2.1 compliance checking
- **Performance**: 3-minute execution, parallel-ready

### Performance Improvements

Smart execution is now 40-85% faster for documentation-only changes:

| Change Type | Baseline | Optimized | Improvement |
|-------------|----------|-----------|-------------|
| Docs-only   | 23 min   | 3.5 min   | 85% faster  |
| Code changes| 23 min   | 14 min    | 40% faster  |

See [Performance Benchmarks](performance-benchmarks.md) for details.
```

#### ❌ Bad Examples

```markdown
## What's New

- Added stuff
- Fixed things
- Made it better
```

### Changelog vs Release Notes

**Release Notes**: User-facing, marketing-friendly, detailed
- Focus on **why** and **what** users care about
- Include examples and use cases
- Show before/after comparisons
- Link to detailed documentation

**CHANGELOG.md**: Developer-facing, technical, concise
- Focus on **what** changed technically
- List commits or PRs
- Reference issue numbers
- Follow [Keep a Changelog](https://keepachangelog.com/) format

---

## Breaking Changes

### Definition

A **breaking change** is any modification that requires users to:
1. Change their code or scripts
2. Update configuration files
3. Modify command-line arguments
4. Perform manual migration steps
5. Change their workflow

### Examples

#### Breaking Changes (MAJOR bump required)

```bash
# ❌ Remove command-line option
- --old-option  # Users' scripts will break

# ❌ Change configuration format
- config: { old: "format" }
+ config: { new: "format" }  # Users must update configs

# ❌ Rename exported function
- source lib.sh; old_function
+ source lib.sh; new_function  # Users' code breaks

# ❌ Change default behavior
- Default: auto-commit changes
+ Default: dry-run mode  # Users expecting auto-commit affected
```

#### Non-Breaking Changes (MINOR/PATCH)

```bash
# ✅ Add new command-line option
+ --new-option  # Existing scripts unaffected

# ✅ Add new configuration field
+ config: { new_field: "optional" }  # Old configs still work

# ✅ Add new exported function
+ source lib.sh; new_function  # Existing code unaffected

# ✅ Fix bug (restores documented behavior)
- Bug: Function returns wrong value
+ Fix: Function returns correct value  # Restores expected behavior
```

### Handling Breaking Changes

#### 1. Deprecation Period

Before removing features, deprecate them for at least one MINOR release:

```bash
# v2.5.0: Deprecate old function
old_function() {
    echo "⚠️  WARNING: old_function is deprecated. Use new_function instead."
    echo "⚠️  old_function will be removed in v3.0.0"
    # Still works, but warns
    new_function "$@"
}

# v3.0.0: Remove old function
# old_function removed entirely
```

#### 2. Migration Guide

Always provide a migration guide for breaking changes:

```markdown
## Migration Guide: v2.x → v3.0

### Breaking Change 1: Configuration Format

**Old Format** (v2.x):
\`\`\`yaml
config:
  version: "1"
  options:
    - opt1
    - opt2
\`\`\`

**New Format** (v3.0):
\`\`\`yaml
config:
  schema_version: 2
  options:
    opt1: true
    opt2: true
\`\`\`

**Migration Steps**:
1. Backup your config: `cp config.yaml config.yaml.backup`
2. Run migration script: `./scripts/migrate_config.sh`
3. Verify: `./execute_tests_docs_workflow.sh --dry-run`
```

#### 3. Backward Compatibility Layer

When possible, maintain backward compatibility temporarily:

```bash
# v2.5.0: Add new function, keep old
new_function() {
    # New implementation
}

old_function() {
    echo "⚠️  Deprecated: Use new_function"
    new_function "$@"
}

# v3.0.0: Remove old function
# Only new_function remains
```

---

## Hotfix Process

### When to Create a Hotfix

Hotfixes are for **critical issues** only:
- Security vulnerabilities
- Data loss bugs
- Complete workflow failure
- Critical performance regression

### Hotfix Workflow

```bash
# 1. Create hotfix branch from latest release tag
git checkout v2.4.0
git checkout -b hotfix/v2.4.1

# 2. Implement minimal fix
vim src/workflow/lib/affected_module.sh

# 3. Write regression test
vim tests/unit/test_affected_module.sh

# 4. Test fix
./tests/run_all_tests.sh

# 5. Bump PATCH version
./scripts/bump_version.sh 2.4.1

# 6. Commit
git add -A
git commit -m "fix: [Critical bug description]

Fixes #123
"

# 7. Tag hotfix
git tag -a v2.4.1 -m "Hotfix v2.4.1: [Brief description]"

# 8. Push hotfix
git push origin hotfix/v2.4.1
git push origin v2.4.1

# 9. Create GitHub release (mark as pre-release if needed)

# 10. Merge to main
git checkout main
git merge hotfix/v2.4.1
git push origin main

# 11. Delete hotfix branch
git branch -d hotfix/v2.4.1
```

---

## Release Schedule

### Planned Releases

| Version | Type | Target Date | Features |
|---------|------|-------------|----------|
| v2.4.1 | PATCH | As needed | Bug fixes |
| v2.5.0 | MINOR | 2026-01-23 | Step 15: Security Scan, Metrics Dashboard |
| v2.6.0 | MINOR | 2026-02-23 | Plugin system, Custom steps |
| v3.0.0 | MAJOR | 2026-06-01 | New architecture, Breaking changes |

### Release Cadence

- **MINOR releases**: Every 4-6 weeks
- **PATCH releases**: As needed (typically 1-2 weeks after MINOR)
- **MAJOR releases**: Every 6-12 months

### Release Freeze Periods

No new features during:
- 1 week before MAJOR release
- 3 days before MINOR release
- Bug fixes only during freeze

---

## Summary

### Quick Checklist

**Before Release**:
- [ ] All tests pass (100% coverage)
- [ ] Version bumped in all files
- [ ] Release notes created
- [ ] Documentation updated
- [ ] Migration guide (if breaking changes)

**During Release**:
- [ ] Create release branch
- [ ] Commit version changes
- [ ] Create and push tag
- [ ] Create GitHub release
- [ ] Merge to main

**After Release**:
- [ ] Announce release
- [ ] Monitor for issues
- [ ] Update project board
- [ ] Plan next release

### Key Principles

1. **Semantic Versioning**: Follow SemVer 2.0.0 strictly
2. **Backward Compatibility**: Minimize breaking changes
3. **Clear Communication**: Detailed release notes
4. **Comprehensive Testing**: 100% coverage before release
5. **User-Focused**: Prioritize user experience in changes

---

## Additional Resources

- **Semantic Versioning**: https://semver.org/
- **Keep a Changelog**: https://keepachangelog.com/
- **Release Notes Examples**: `docs/RELEASE_NOTES_v2.*.md`
- **Version Bump Script**: `scripts/bump_version.sh`

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Current Release**: v2.4.0  
**Status**: ✅ Official Release Process
