# Documentation Style Guide - AI Workflow Automation

**Version**: 1.0.0  
**Purpose**: Establish consistent formatting and style conventions  
**Status**: ✅ Authoritative Reference  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Purpose](#purpose)
- [File Paths](#file-paths)
- [Code Elements](#code-elements)
- [Commands](#commands)
- [Configuration Values](#configuration-values)
- [Emphasis and Highlighting](#emphasis-and-highlighting)
- [Lists and Tables](#lists-and-tables)
- [Headers and Titles](#headers-and-titles)
- [Links and References](#links-and-references)
- [Status Indicators](#status-indicators)
- [Examples and Code Blocks](#examples-and-code-blocks)
- [Numbers and Metrics](#numbers-and-metrics)
- [Anti-Patterns](#anti-patterns)

---

## Purpose

This guide defines **formatting conventions** for all AI Workflow Automation documentation. Consistent formatting improves readability, maintainability, and professionalism.

### Scope

- All markdown files (`.md`)
- README files
- Documentation guides
- Code comments (where applicable)
- Release notes

### Goals

- **Consistency**: Same elements formatted identically
- **Readability**: Easy to scan and understand
- **Professionalism**: High-quality presentation
- **Maintainability**: Clear patterns to follow

---

## File Paths

### Rule: Always Use Inline Code

**Format**: `` `path/to/file.ext` ``

**Applies To**:
- Absolute paths
- Relative paths
- File names
- Directory paths
- Configuration files

### Examples

✅ **Correct**:
```markdown
The `src/workflow/lib/ai_helpers.sh` module provides AI integration.
Configuration lives in `.workflow_core/config/paths.yaml`.
Edit `.workflow-config.yaml` to set project kind.
Logs stored in `src/workflow/logs/`.
```

❌ **Incorrect**:
```markdown
The src/workflow/lib/ai_helpers.sh module provides AI integration.
Configuration lives in **.workflow_core/config/paths.yaml**.
Edit .workflow-config.yaml to set project kind.
Logs stored in src/workflow/logs/.
```

### Special Cases

**Full Paths with Line Numbers**:
```markdown
See `src/workflow/lib/metrics.sh:142` for implementation.
Error at `execute_tests_docs_workflow.sh:1205`
```

**Paths in Code Blocks**:
```markdown
\`\`\`bash
# Inline code not needed in code blocks
source src/workflow/lib/ai_helpers.sh
cd src/workflow/steps
\`\`\`
```

**Multiple Paths in Series**:
```markdown
The modules `ai_helpers.sh`, `metrics.sh`, and `change_detection.sh` work together.
```

**Paths with Wildcards**:
```markdown
All `*.sh` files in `src/workflow/lib/`
Test files: `tests/**/*.test.js`
```

---

## Code Elements

### Variables

**Format**: `` `VARIABLE_NAME` ``

✅ **Correct**:
```markdown
Set `TARGET_DIR` to your project root.
The `WORKFLOW_ROOT` variable points to installation.
Check `${PROJECT_KIND}` for project type.
```

❌ **Incorrect**:
```markdown
Set TARGET_DIR to your project root.
The **WORKFLOW_ROOT** variable points to installation.
Check PROJECT_KIND for project type.
```

### Functions

**Format**: `` `function_name()` `` (include parentheses)

✅ **Correct**:
```markdown
Call `execute_step()` to run a step.
The `detect_change_type()` function analyzes git changes.
Override `validate_step()` for custom validation.
```

❌ **Incorrect**:
```markdown
Call execute_step to run a step.
The detect_change_type function analyzes changes.
Override **validate_step** for validation.
```

### Modules and Steps

**Format**: `` `module_name.sh` `` or `` `step_XX_name.sh` ``

✅ **Correct**:
```markdown
The `ai_helpers.sh` module provides 14 personas.
`step_07_test_exec.sh` executes tests.
Source the `metrics.sh` module.
```

❌ **Incorrect**:
```markdown
The ai_helpers.sh module provides 14 personas.
step_07_test_exec.sh executes tests.
Source the **metrics** module.
```

---

## Commands

### Shell Commands

**Format**: `` `command` `` (inline) or code block (multi-line)

**Inline Commands**:
```markdown
Run `./execute_tests_docs_workflow.sh --smart-execution` to enable optimization.
Use `git status` to check changes.
Install with `npm install`.
```

**Multi-line Commands**:
````markdown
```bash
./execute_tests_docs_workflow.sh \
  --smart-execution \
  --parallel \
  --auto
```
````

### Command Flags

**Format**: `` `--flag-name` ``

✅ **Correct**:
```markdown
Enable with `--smart-execution` flag.
Use `--parallel` for simultaneous execution.
Combine `--smart-execution` and `--parallel`.
```

❌ **Incorrect**:
```markdown
Enable with --smart-execution flag.
Use **--parallel** for simultaneous execution.
Combine --smart-execution and --parallel.
```

### Command Options with Values

**Format**: `` `--option VALUE` `` or `` `--option=VALUE` ``

✅ **Correct**:
```markdown
Specify steps with `--steps 0,5,7,11`.
Set config with `--config-file .my-config.yaml`.
Target directory: `--target /path/to/project`.
```

---

## Configuration Values

### YAML Keys

**Format**: `` `key_name` ``

✅ **Correct**:
```markdown
Set `project.kind` to `nodejs_api`.
Configure `tech_stack.primary_language`.
The `step_relevance` key defines applicability.
```

### YAML Values

**Format**: `` `value` ``

✅ **Correct**:
```markdown
Valid values: `required`, `recommended`, `optional`, `skip`.
Set to `true` or `false`.
Use `nodejs_api` for Node.js APIs.
```

### Environment Variables

**Format**: `` `VARIABLE_NAME` ``

✅ **Correct**:
```markdown
Set `WORKFLOW_ROOT` environment variable.
Check `$HOME` for user directory.
Export `TARGET_DIR=/path/to/project`.
```

---

## Emphasis and Highlighting

### Bold

**Use For**:
- Important concepts (first introduction)
- Warnings and cautions
- Section emphasis
- Status labels

**Format**: `**text**`

✅ **Correct**:
```markdown
**Smart execution** analyzes changes to skip steps.
**Warning**: This operation cannot be undone.
**Status**: ✅ Production Ready
**Important**: Always commit before running.
```

### Italic

**Use For**:
- Technical terms (first use)
- Emphasis within sentences
- Notes and asides

**Format**: `*text*` or `_text_`

✅ **Correct**:
```markdown
The workflow uses *change detection* to classify modifications.
See the *metrics guide* for details.
*Note*: This feature requires v2.3.0+.
```

### Bold + Italic

**Use For**:
- Critical warnings
- Breaking changes

**Format**: `***text***`

✅ **Correct**:
```markdown
***Breaking Change***: Configuration format updated in v2.4.0.
***Critical***: Backup data before proceeding.
```

### Don't Use For

❌ **Never use bold/italic for**:
- File paths (use inline code)
- Commands (use inline code)
- Variables (use inline code)
- Function names (use inline code)

---

## Lists and Tables

### Bullet Lists

**Format**:
```markdown
- First item
- Second item
  - Nested item
  - Another nested item
- Third item
```

**Use `-` (hyphen), not `*` (asterisk)**

### Numbered Lists

**Format**:
```markdown
1. First step
2. Second step
3. Third step
```

**Always start with `1.`**, markdown handles numbering.

### Checklist

**Format**:
```markdown
- [ ] Incomplete task
- [x] Completed task
- [ ] Another task
```

### Tables

**Format**: Always align columns

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value A  | Value B  | Value C  |
```

**Alignment**:
```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| Text | Text   | Text  |
```

---

## Headers and Titles

### Level 1 Header (Title)

**Format**: `# Title`

**Use**: Document title only (one per file)

```markdown
# Smart Execution Guide
```

### Level 2 Header (Major Section)

**Format**: `## Section Name`

**Use**: Major sections

```markdown
## Quick Start
## Configuration
## Performance Impact
```

### Level 3 Header (Subsection)

**Format**: `### Subsection Name`

**Use**: Subsections within major sections

```markdown
### Enable Smart Execution
### Change Detection Logic
```

### Level 4 Header (Detail)

**Format**: `#### Detail Name`

**Use**: Detailed breakdowns (use sparingly)

```markdown
#### Scenario 1: Documentation Update
#### Step-by-Step Process
```

### Capitalization

**Title Case** for headers:
```markdown
✅ ## Quick Start Guide
✅ ### Change Detection Logic
✅ #### Performance Optimization

❌ ## Quick start guide
❌ ### Change detection logic
❌ #### performance optimization
```

---

## Links and References

### Internal Links (Same File)

**Format**: `[Link Text](#section-anchor)`

```markdown
See [Quick Start](#quick-start) for usage.
Refer to [Performance Impact](#performance-impact).
```

**Anchor**: Lowercase, hyphens, no special chars

### Internal Links (Other File)

**Format**: `[Link Text](#example-section)`

```markdown
See [Metrics Guide](metrics-interpretation.md) for details.
Refer to [Configuration](configuration.md).
```

### External Links

**Format**: `[Link Text](https://url.com)`

```markdown
Visit [GitHub Copilot](https://github.com/features/copilot) for more.
See [Node.js Documentation](https://nodejs.org/docs).
```

### References with Inline Code

**Combine** code formatting with links:

```markdown
See [`ai_helpers.sh`](../../src/workflow/lib/ai_helpers.sh) implementation.
The [`step_relevance.yaml`](../../src/workflow/config/step_relevance.yaml) defines relevance.
```

---

## Status Indicators

### Emoji Status

**Format**: Use standard emoji consistently

```markdown
✅ Complete / Success / Correct
❌ Incomplete / Error / Incorrect
⚠️ Warning / Caution
🟢 Resolved / Fixed
🟠 In Progress / Needs Attention
🔴 Critical / Broken
🟡 Medium Priority
⏩ Skipped
📊 Information / Data
🎉 Celebration / Major Achievement
```

### Status Labels

**Format**: `**Status**: ✅ Label`

```markdown
**Status**: ✅ Production Ready
**Status**: 🟢 Resolved
**Status**: 🟠 In Progress
**Priority**: 🔴 Critical
```

### Version Tags

**Format**: `` `vX.Y.Z` ``

```markdown
Added in `v2.3.0`
Breaking change in `v2.4.0`
Deprecated since `v2.2.0`
```

---

## Examples and Code Blocks

### Inline Code Examples

**Format**: `` `code` ``

```markdown
Set `PROJECT_KIND="nodejs_api"` in configuration.
The function returns `0` on success.
Use `--dry-run` for testing.
```

### Code Blocks

**Format**: Use language specifier

````markdown
```bash
#!/usr/bin/env bash
./execute_tests_docs_workflow.sh --smart-execution
```

```javascript
const result = await execute();
```

```yaml
project:
  kind: nodejs_api
```

```json
{
  "version": "2.4.0"
}
```
````

### Example Output

**Format**: Use `text` or no language for output

````markdown
```text
✅ Step 0: Pre-Analysis (15s)
✅ Step 1: Documentation (140s)
⏩ Skipping Step 3 (not relevant)
Total: 350s (5.8 minutes)
```
````

### Multi-Example Pattern

````markdown
**Example 1**: Documentation changes
```bash
./workflow.sh --smart-execution
```

**Example 2**: Code changes
```bash
./workflow.sh --smart-execution --parallel
```
````

---

## Date and Time Formatting

### Standard Format

**Format**: ISO 8601

ISO 8601 is the international standard for date and time representation. Use it consistently across all documentation.

#### Dates Only

**Format**: `YYYY-MM-DD`

✅ **Correct**:
```markdown
**Last Updated**: 2025-12-23
**Release Date**: 2025-12-23
**Version**: v2.4.0 (2025-12-23)
```

❌ **Incorrect**:
```markdown
**Last Updated**: December 23, 2025
**Release Date**: 2025/12/23
**Version**: v2.4.0 (Dec 23, 2025)
```

#### Dates with Time

**Format**: `YYYY-MM-DDTHH:MM:SSZ` (with T separator)

✅ **Correct**:
```markdown
**Timestamp**: 2025-12-23T19:05:29Z
**Migration Date**: 2025-12-18T02:25:21Z
**Created**: 2025-12-20T14:00:00-03:00
```

❌ **Incorrect**:
```markdown
**Timestamp**: 2025-12-23 19:05:29
**Migration Date**: 2025-12-18 02:25:21
**Created**: 2025-12-20 14:00:00
```

### Rationale

**Why ISO 8601?**

1. **International Standard**: Recognized globally
2. **Unambiguous**: No MM/DD vs DD/MM confusion
3. **Sortable**: Lexicographic sort works correctly
4. **Machine-Parseable**: Easy for scripts and tools
5. **Timezone-Aware**: Supports timezone indicators
6. **No Localization**: No language-dependent month names

### Version Dates

**Format**: `[vX.Y.Z] - YYYY-MM-DD`

✅ **Correct**:
```markdown
## [v2.4.0] - 2025-12-23
## [v2.3.1] - 2025-12-18
## [v2.3.0] - 2025-12-18
```

### Changelog Dates

**Format**: `#### YYYY-MM-DD - Title`

✅ **Correct**:
```markdown
#### 2025-12-23 - Step 14 Documentation
**Category**: Added
**Impact**: HIGH
```

### Prose Dates (Exception)

When writing narrative prose where month names read naturally, prose format is acceptable **in body text only**. Always use ISO in metadata.

✅ **Acceptable in prose**:
```markdown
In December 2025, we released version 2.4.0 with significant improvements.
```

✅ **Always use ISO in metadata**:
```markdown
**Release Date**: 2025-12-23
In December 2025, we released version 2.4.0 with significant improvements.
```

### Validation

**Automated Checking**:
```bash
# Check for date format issues
./scripts/standardize_dates.sh --check

# Fix automatically
./scripts/standardize_dates.sh --fix
```

**Manual Review**:
- Verify ISO format: `YYYY-MM-DD`
- Check T separator for times
- Ensure timezone indicator (Z or ±HH:MM)
- Validate month (01-12) and day (01-31)

---

## Numbers and Metrics

### Percentages

**Format**: `XX%` (no space)

```markdown
✅ 85% faster
✅ Improved by 40%
✅ 60-80% token reduction

❌ 85 % faster
❌ Improved by 40 %
```

### Time Durations

**Format**: `X minutes` or `X min` or `XXs`

```markdown
✅ 23 minutes
✅ 5.8 min
✅ 140s
✅ 2 hours 15 minutes

❌ 23min (no space)
❌ 5.8 minutes (inconsistent)
```

### File Sizes

**Format**: `XXK` or `XX.XKB` or `XXMB`

```markdown
✅ 18KB
✅ 2.3MB
✅ 19K
✅ 135KB+

❌ 18kb (lowercase)
❌ 18 KB (space)
```

### Version Numbers

**Format**: `vX.Y.Z` (with 'v' prefix)

```markdown
✅ v2.4.0
✅ v2.3.1
✅ Version 2.4.0

❌ 2.4.0 (no 'v')
❌ V2.4.0 (capital V)
```

### Ranges

**Format**: `X-Y` (hyphen, no spaces)

```markdown
✅ 60-80% reduction
✅ 2-3 minutes
✅ Steps 0-14

❌ 60 - 80% reduction (spaces)
❌ 2 to 3 minutes (words)
```

---

## Anti-Patterns

### Common Mistakes

#### File Paths

```markdown
❌ src/workflow/lib/ai_helpers.sh (plain text)
❌ **src/workflow/lib/ai_helpers.sh** (bold)
✅ `src/workflow/lib/ai_helpers.sh` (inline code)
```

#### Commands

```markdown
❌ Run ./execute_tests_docs_workflow.sh to start
❌ Run **./execute_tests_docs_workflow.sh** to start
✅ Run `./execute_tests_docs_workflow.sh` to start
```

#### Variables

```markdown
❌ Set TARGET_DIR to your project
❌ Set **TARGET_DIR** to your project
✅ Set `TARGET_DIR` to your project
```

#### Functions

```markdown
❌ Call execute_step to run
❌ Call **execute_step()** to run
✅ Call `execute_step()` to run
```

#### Configuration Keys

```markdown
❌ Set project.kind to nodejs_api
❌ Set **project.kind** to **nodejs_api**
✅ Set `project.kind` to `nodejs_api`
```

#### Mixing Formats

```markdown
❌ The src/workflow/lib/ai_helpers.sh module uses `AI_CACHE_DIR`
✅ The `src/workflow/lib/ai_helpers.sh` module uses `AI_CACHE_DIR`

❌ Run ./workflow.sh with --smart-execution flag
✅ Run `./workflow.sh` with `--smart-execution` flag
```

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────┐
│  Documentation Formatting Quick Reference            │
├──────────────────────────────────────────────────────┤
│  File Paths:      `path/to/file.sh`                 │
│  Commands:        `command --flag`                  │
│  Variables:       `VARIABLE_NAME`                   │
│  Functions:       `function_name()`                 │
│  Config Keys:     `key.name`                        │
│  Config Values:   `value`                           │
│                                                      │
│  Bold:            **Important Text**                │
│  Italic:          *Emphasis*                        │
│  Bold+Italic:     ***Critical***                    │
│                                                      │
│  Lists:           - Item (use hyphens)              │
│  Numbered:        1. First                          │
│  Checklist:       - [ ] Todo                        │
│                                                      │
│  Headers:         ## Title Case                     │
│  Links:           [Text](#anchor)                   │
│  Status:          ✅ Complete                       │
│  Version:         v2.4.0                            │
│                                                      │
│  Dates:           2025-12-23                        │
│  Timestamps:      2025-12-23T19:05:29Z              │
│                                                      │
│  Code Blocks:     ```bash                           │
│                   code here                         │
│                   ```                               │
│                                                      │
│  Numbers:         85% (no space)                    │
│  Time:            23 minutes                        │
│  Size:            18KB                              │
│  Range:           60-80% (no spaces)                │
└──────────────────────────────────────────────────────┘
```

---

## Verification Checklist

When writing or reviewing documentation:

- [ ] File paths in inline code (`` `path/file.sh` ``)
- [ ] Commands in inline code (`` `command` ``)
- [ ] Variables in inline code (`` `VARIABLE` ``)
- [ ] Functions with parentheses (`` `function()` ``)
- [ ] Config keys/values in inline code
- [ ] Bold only for emphasis, not code elements
- [ ] Consistent status emoji (✅, ❌, ⚠️)
- [ ] Version format: `vX.Y.Z`
- [ ] Percentages: `XX%` (no space)
- [ ] Time format: `X minutes` or `Xs`
- [ ] Headers in Title Case
- [ ] Lists use hyphens (`-`), not asterisks
- [ ] Code blocks have language specifier
- [ ] Tables properly aligned
- [ ] Links use descriptive text

---

## Implementation Guidelines

### For New Documents

1. Use this guide as template
2. Apply formatting consistently
3. Review with checklist
4. Cross-reference similar docs for consistency

### For Existing Documents

1. Update during routine edits
2. Bulk updates for major inconsistencies
3. Focus on user-visible documentation first
4. Internal docs lower priority

### For Code Comments

Apply where relevant:
```bash
# ✅ Source the `ai_helpers.sh` module
source "${WORKFLOW_ROOT}/lib/ai_helpers.sh"

# ✅ Set `PROJECT_KIND` environment variable
export PROJECT_KIND="nodejs_api"
```

---

## Document Metadata

**Include at top of guides**:

```markdown
# Document Title

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-12-23

---
```

---

## Updating This Guide

**Process**:
1. Propose formatting change
2. Discuss with team/maintainers
3. Update this guide first
4. Apply to documentation gradually
5. Use in new documents immediately

**Version History**:
- v1.0.0 (2025-12-23): Initial style guide

---

**Version**: 1.0.0  
**Status**: ✅ Authoritative Reference  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

**This is the authoritative style guide. All documentation should follow these formatting conventions.**
