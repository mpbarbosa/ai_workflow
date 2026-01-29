# Step 15: Quick Start Guide

**Version**: v3.0.0  
**Purpose**: Automatically update semantic versions in modified files  
**Execution Time**: ~45 seconds

---

## Quick Overview

Step 15 automatically detects and updates version numbers in all modified files as part of the AI Workflow Automation pipeline. It runs after all analysis steps and before Git Finalization.

## What It Does

1. ✅ **Detects** version patterns in modified files
2. ✅ **Determines** appropriate version bump (major/minor/patch)
3. ✅ **Updates** versions automatically
4. ✅ **Validates** changes and provides rollback on failure
5. ✅ **Reports** all updates in backlog

## Supported Version Formats

### Semver (X.Y.Z)
```bash
version="2.1.0"
VERSION: 1.5.3
Version = 3.0.0
```

### Date-Based
```bash
version="2024-12-25"
VERSION: 2025-01-11
```

### Comment Headers
```bash
#!/bin/bash
# Version: 2.1.0
# version 1.5.3
```

## Usage

### 1. Standard Workflow (Includes Step 15)
```bash
# Run full workflow - Step 15 runs automatically
./execute_tests_docs_workflow.sh
```

### 2. Run Specific Steps
```bash
# Run only version update and git finalization
./execute_tests_docs_workflow.sh --steps 0,15,11

# Run all steps except version update
./execute_tests_docs_workflow.sh --steps 0-14,11
```

### 3. Preview Mode
```bash
# See what would be updated without making changes
./execute_tests_docs_workflow.sh --dry-run
```

### 4. With Optimizations
```bash
# Use smart execution and parallel processing
./execute_tests_docs_workflow.sh --smart-execution --parallel
```

## Example Workflow

### Scenario: Bug Fix Release

```bash
# 1. Make your changes
vim src/myapp.sh

# 2. Run workflow (includes version update)
./execute_tests_docs_workflow.sh

# Expected output:
# Step 15: Semantic Version Update
#   ℹ Detected change level: patch bump
#   ℹ Checking: src/myapp.sh
#     ↳ Current version: 1.2.3
#     ↳ New version: 1.2.4
#     ✓ Updated: 1.2.3 → 1.2.4
#   ✓ Version update completed: 1 file updated
```

### Scenario: New Feature

```bash
# 1. Add new feature with tests
vim src/feature.sh
vim tests/test_feature.sh

# 2. Run workflow
./execute_tests_docs_workflow.sh

# Expected output:
# Step 15: Semantic Version Update
#   ℹ Detected change level: minor bump
#   ℹ Checking: src/feature.sh
#     ↳ Current version: 1.2.4
#     ↳ New version: 1.3.0
#     ✓ Updated: 1.2.4 → 1.3.0
```

### Scenario: Breaking Change

```bash
# 1. Make breaking changes
vim src/api.sh

# 2. Document breaking change in commit
git commit -m "feat: redesign API

BREAKING CHANGE: API interface completely redesigned"

# 3. Run workflow
./execute_tests_docs_workflow.sh

# Expected output:
# Step 15: Semantic Version Update
#   ℹ Detected change level: major bump
#   ℹ Checking: src/api.sh
#     ↳ Current version: 1.3.0
#     ↳ New version: 2.0.0
#     ✓ Updated: 1.3.0 → 2.0.0
```

## Version Bump Rules

| Scenario | Bump Type | Example |
|----------|-----------|---------|
| Commit has "BREAKING CHANGE" | Major | 1.2.3 → 2.0.0 |
| Code + tests modified | Minor | 1.2.3 → 1.3.0 |
| Only code modified | Minor | 1.2.3 → 1.3.0 |
| Only docs modified | Patch | 1.2.3 → 1.2.4 |
| Bug fixes | Patch | 1.2.3 → 1.2.4 |
| Test-only changes | Patch | 1.2.3 → 1.2.4 |

## What Gets Updated

### ✅ Included
- Source files (*.sh, *.js, *.py, etc.)
- Documentation files with version tags
- Configuration files with versions
- Header comments with version info

### ❌ Excluded
- Workflow artifacts (backlog/, logs/, summaries/)
- Temporary files (*.tmp, *.bak, *.swp)
- Files without version patterns
- Lock files (package-lock.json, etc.)

## Output and Reports

### Console Output
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 15: Semantic Version Update
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Analyzing modified files for version updates...
ℹ Detected change level: patch bump

ℹ Checking: src/workflow/steps/step_15_version_update.sh
  ↳ Pattern detected: semver_comment
  ↳ Current version: 1.0.0
  ↳ New version: 1.0.1
  ✓ Updated: 1.0.0 → 1.0.1

✓ Version update completed: 1 file updated
```

### Backlog Report
Location: `src/workflow/backlog/workflow_YYYYMMDD_HHMMSS/step15_Version_Update.md`

```markdown
# Step 15: Semantic Version Update

**Status:** ✅ Complete

## Version Bump Type: patch

## Files Processed
- `src/file1.sh`: Updated 2.0.0 → 2.0.1 ✅
- `src/file2.sh`: Version already current (1.5.0) (skipped)
- `docs/README.md`: No version pattern (skipped)

## Summary
- Files updated: 1
- Files skipped: 2
- Files failed: 0
```

### Summary File
Location: `src/workflow/summaries/workflow_YYYYMMDD_HHMMSS/step15_Version_Update_summary.txt`

```
Updated 1 file
```

## Troubleshooting

### Issue: No versions detected
**Problem**: "No version pattern detected, skipping"  
**Solution**: Add version to file header:
```bash
#!/bin/bash
# Version: 1.0.0
```

### Issue: Wrong bump type
**Problem**: Minor bump when expecting patch  
**Solution**: Check git history - code+tests modified triggers minor bump

### Issue: Version not updated
**Problem**: File shows old version after step runs  
**Solution**: Check if file is in exclusion list or workflow artifacts

### Issue: Update failed
**Problem**: "Failed to update version"  
**Solution**: 
1. Check file permissions
2. Verify version pattern is regular (not in string literals)
3. Check backup file exists: `*.version_backup`

## Tips and Best Practices

### 1. Consistent Version Placement
Place versions in predictable locations:
```bash
#!/bin/bash
# Version: 1.0.0  ← Recommended: Top of file
# Author: Your Name

# or

VERSION="1.0.0"  ← Recommended: Near top
```

### 2. Use Standard Formats
Stick to recognized patterns:
- ✅ `# Version: 1.0.0`
- ✅ `version="1.0.0"`
- ✅ `VERSION: 1.0.0`
- ❌ `ver: 1.0.0` (not recognized)

### 3. Document Breaking Changes
Always mark breaking changes in commits:
```bash
git commit -m "refactor: change API signature

BREAKING CHANGE: Function parameters reordered"
```

### 4. Review Before Commit
Check version updates in Step 15 report before committing:
```bash
# After workflow completes
cat src/workflow/backlog/workflow_*/step15_Version_Update.md
```

### 5. Skip When Not Needed
For docs-only changes that shouldn't bump version:
```bash
./execute_tests_docs_workflow.sh --steps 0-14,11
```

## Integration with Other Steps

### Step 11 (Git Finalization)
- **Dependency**: Step 11 runs AFTER Step 15
- **Purpose**: Commit version updates with other changes
- **Benefit**: All changes committed atomically

### Step 10 (Context Analysis)
- **Dependency**: Step 15 runs AFTER Step 10
- **Purpose**: Uses analysis results to determine bump type
- **Benefit**: Intelligent versioning based on change context

### Smart Execution
- **Behavior**: Step 15 respects smart execution mode
- **Skip Logic**: May skip for documentation-only changes
- **Override**: Use `--steps` to force execution

## Performance

| Metric | Typical Value |
|--------|---------------|
| **Execution Time** | 45 seconds |
| **Files Processed** | 1-50 |
| **Memory Usage** | < 10 MB |
| **Overhead** | ~3% of total workflow |

## Next Steps

After Step 15 runs:
1. **Step 11**: Git Finalization commits version updates
2. **Review**: Check backlog for update report
3. **Verify**: Confirm versions in modified files
4. **Release**: Use updated versions for tagging

## Advanced Usage

### Custom Bump Type (Future)
```bash
# Override automatic detection (future feature)
BUMP_TYPE=major ./execute_tests_docs_workflow.sh
```

### Skip Specific Files (Future)
```bash
# Exclude files from version update (future feature)
SKIP_VERSION_UPDATE="*.lock,*.min.js" ./execute_tests_docs_workflow.sh
```

### Version Consistency Check (Future)
```bash
# Verify all files use same version (future feature)
./execute_tests_docs_workflow.sh --check-version-consistency
```

## FAQ

**Q: Will Step 15 update package.json versions?**  
A: Currently no. Step 15 focuses on file header versions. Package versions can be added in future versions.

**Q: Can I disable Step 15?**  
A: Yes, use `--steps 0-14,11` to skip Step 15.

**Q: What if multiple files have different versions?**  
A: Each file is updated independently based on its current version.

**Q: Does Step 15 create git tags?**  
A: Not yet. Git tagging is a future enhancement.

**Q: Can I customize version patterns?**  
A: Not yet configurable, but patterns cover most common formats.

---

**Quick Start**: Just run `./execute_tests_docs_workflow.sh` - Step 15 works automatically!  
**Documentation**: See `STEP_15_VERSION_UPDATE_IMPLEMENTATION.md` for technical details  
**Support**: Check backlog reports for troubleshooting information
