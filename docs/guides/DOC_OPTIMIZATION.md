# Documentation Optimization Guide

**Step:** 2.5  
**Version:** 1.0.0  
**Purpose:** Reduce documentation size and AI context costs

## Overview

Step 2.5 analyzes your documentation base to identify and consolidate redundant or outdated files, reducing AI prompt context size and GitHub Copilot costs.

## Features

✅ **Exact Duplicate Detection** - SHA256-based file comparison  
✅ **Similarity Analysis** - Multi-factor scoring (title, content, size)  
✅ **Git History Analysis** - Identifies abandoned and outdated files  
✅ **Version Analysis** - Detects outdated version references  
✅ **Safe Archiving** - All changes preserved in `docs/.archive/`  
✅ **Comprehensive Reporting** - Detailed metrics and recommendations

## Usage

### Automatic Execution

The step runs automatically between Step 2 (Consistency Check) and Step 3 (Script References):

```bash
./src/workflow/execute_tests_docs_workflow.sh
```

### Dry-Run Mode

Preview changes without modifying files:

```bash
cd src/workflow/steps
PROJECT_ROOT=/path/to/project ./step_02_5_doc_optimize.sh --dry-run
```

### Non-Interactive Mode

Skip user prompts (auto-decline deletions):

```bash
PROJECT_ROOT=/path/to/project ./step_02_5_doc_optimize.sh --no-interactive
```

## Configuration

Add to `.workflow-config.yaml`:

```yaml
documentation_optimization:
  enabled: true
  outdated_threshold_months: 12
  similarity_threshold: 0.80
  confidence_threshold_auto: 0.90
  exclude_patterns:
    - "CHANGELOG.md"
    - "LICENSE*"
    - "CONTRIBUTING.md"
  archive_directory: "docs/.archive"
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | true | Enable/disable optimization step |
| `outdated_threshold_months` | 12 | Files older than this are considered outdated |
| `similarity_threshold` | 0.80 | Minimum similarity to flag as redundant |
| `confidence_threshold_auto` | 0.90 | Auto-consolidate above this confidence |
| `exclude_patterns` | See config | File patterns to exclude from analysis |
| `archive_directory` | docs/.archive | Where to store archived files |

## What Gets Optimized

### Exact Duplicates (100% confidence)
- Files with identical SHA256 hashes
- **Action:** Automatically consolidated
- **Safety:** Duplicate archived, only one copy kept

### High Similarity (80-89% confidence)
- Similar titles and content overlap
- **Action:** Flagged for manual review
- **Safety:** No automatic changes

### Outdated Files
Detected by:
- Last git modification > 12 months ago
- Version references 2+ major versions behind
- No recent commits or cross-references

**Action:** User prompted for archival  
**Safety:** All archived files preserved

## Output

### During Execution

```
╔════════════════════════════════════════════════════════════════╗
║  STEP 2.5: Documentation Optimization
╚════════════════════════════════════════════════════════════════╝

Phase 1: Heuristics Analysis
  ✓ Found 3 exact duplicates
  ✓ Found 5 redundant document pairs

Phase 2: Git History Analysis
  ✓ Identified 2 outdated files
  ✓ Found 1 abandoned file

Phase 3: Version Reference Analysis
  ✓ Scanned version references in 197 files
  ✓ Found 2 files with outdated version references

Phase 5: Optimization Summary
  📊 Analysis Results:
  Total files analyzed: 197
  Exact duplicates: 3
  Redundant pairs: 5
  Outdated files: 5

Phase 6: Applying Optimizations
  ✓ Created archive: docs/.archive/20260207_153000
  ✓ Consolidated 3 exact duplicates

Archive these 5 outdated files? [y/N] y
  ✓ Archived 5 outdated files

Phase 7: Generating Report
  ✓ Report generated: docs/.archive/optimization_report.md

📊 Optimization Complete!
═══════════════════════
  Files analyzed: 197
  Files optimized: 8
  Size saved: 127KB
  Token savings: ~31,750

Full report: docs/.archive/optimization_report.md
```

### Generated Report

A markdown report is generated at `docs/.archive/optimization_report.md` containing:
- Summary statistics
- List of consolidated files
- List of archived files
- Redundant pairs for manual review
- Recommendations
- Archive location

## Archive Structure

```
docs/.archive/
└── 20260207_153000/
    ├── original/              # Original files before modification
    │   ├── duplicate1.md
    │   └── outdated1.md
    ├── consolidated/          # Merged content (if applicable)
    └── optimization_report.md # Summary report
```

## Restoring Files

To restore an archived file:

```bash
# Copy from archive back to docs/
cp docs/.archive/20260207_153000/original/filename.md docs/path/filename.md

# Or restore entire archive
cp -r docs/.archive/20260207_153000/original/* docs/
```

## Performance

For a typical project with 200 documentation files:
- **Analysis time:** 2-3 minutes
- **Expected findings:** 5-10% redundancy, 3-5% outdated
- **Size reduction:** 10-15% (varies by project)
- **Token savings:** ~5,000-10,000 tokens

## Limitations

### Current Version (1.0.0)

- **AI analysis not yet implemented** - Edge cases (50-89% similarity) require manual review
- **Manual consolidation needed** - For redundant pairs, only exact duplicates are auto-consolidated
- **No automatic link updating** - Cross-references may need manual updates after consolidation

### Future Enhancements

- **Full AI integration** for edge case analysis
- **Automatic link resolution** and updating
- **Smart content merging** for redundant pairs
- **ML-based similarity scoring** (reduce AI costs)

## Safety Features

✅ **No data loss** - All modifications archived  
✅ **Git-friendly** - Works with version control  
✅ **Dry-run mode** - Preview before applying  
✅ **User confirmation** - For deletions and risky operations  
✅ **Excluded patterns** - Critical files never touched  
✅ **Rollback ready** - Easy restoration from archive

## Troubleshooting

### Step Skipped

**Cause:** No `docs/` directory or < 5 markdown files

**Solution:** Ensure documentation exists:
```bash
ls -la docs/*.md | wc -l  # Should be >= 5
```

### No Duplicates Found

**Cause:** Documentation is already well-maintained

**Result:** No optimization needed - this is good!

### Git Analysis Failed

**Cause:** Not in a git repository

**Impact:** Only git-based outdated detection skipped, heuristics still run

**Solution:** Initialize git or ignore warning

### Version Analysis Failed

**Cause:** Could not determine current project version

**Impact:** Only version-based outdated detection skipped

**Solution:** Add version to `package.json`, `pyproject.toml`, or `CHANGELOG.md`

## Integration with Other Steps

### Before Step 2.5
- **Step 0:** Detects project changes
- **Step 1:** Updates documentation content
- **Step 2:** Validates consistency

### After Step 2.5
- **Step 3:** Script reference validation
- **Step 4:** Directory structure check

**Recommendation:** Run Step 2.5 after major documentation updates to maintain efficiency.

## FAQ

**Q: Will this delete my documentation?**  
A: No files are permanently deleted. All changes are archived and can be restored.

**Q: How often should I run this?**  
A: Quarterly or after major documentation rewrites.

**Q: Can I disable this step?**  
A: Yes, set `documentation_optimization.enabled: false` in `.workflow-config.yaml`

**Q: What if I disagree with the analysis?**  
A: Use `--dry-run` to preview, and restore files from archive if needed.

**Q: Does this work with non-Markdown docs?**  
A: Currently only `.md` files are analyzed. Other formats are ignored.

## Related Documentation

- [Module Development Guide](../developer-guide/MODULE_DEVELOPMENT.md)
- [Workflow Overview](../README.md)
- [Project Reference](../PROJECT_REFERENCE.md)

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-07  
**Maintainer:** AI Workflow Team
