# Workflow Profiles Guide

**Version:** 3.1.0 (Bash Workflow Automation)  
**Status:** ✅ Implemented  
**Module:** `src/workflow/lib/workflow_profiles.sh`

## Overview

Workflow profiles customize step execution based on change type, saving significant time by skipping unnecessary validation steps and focusing on relevant checks.

## Available Profiles

| Profile | Description | Skip Steps | Focus Steps | Time Savings |
|---------|-------------|------------|-------------|--------------|
| **docs_only** | Documentation changes only | 7,8 (tests, deps) | 2,4,10 (docs, structure, analysis) | 60% (~10 min saved) |
| **code_changes** | Source code modifications | 2 (docs) | 7,8,9,13 (tests, deps, quality, prompt) | 20% (~5 min saved) |
| **test_changes** | Test modifications only | 2,4 (docs, structure) | 7,9 (tests, quality) | 35% (~8 min saved) |
| **infrastructure** | CI/CD, dependencies, config | 2,4 (docs, structure) | 8,9,14 (deps, quality, summary) | 0% (needs full check) |
| **full_validation** | Complete workflow | none | all | 0% (baseline 23-28 min) |

## Usage

### Automatic Detection

```bash
# Profile is auto-detected based on git changes
./src/workflow/execute_tests_docs_workflow.sh

# Workflow detects:
# - Only .md files changed → docs_only profile
# - src/**/*.sh changed → code_changes profile
# - test files changed → test_changes profile
# - .yml/.yaml changed → infrastructure profile
```

### Manual Override

```bash
# Force specific profile
export WORKFLOW_PROFILE="docs_only"
./src/workflow/execute_tests_docs_workflow.sh

# Disable profile detection (use full validation)
export SKIP_PROFILE_DETECTION="true"
./src/workflow/execute_tests_docs_workflow.sh
```

### List Available Profiles

```bash
source src/workflow/lib/workflow_profiles.sh
list_profiles
```

Output:
```
Available Workflow Profiles:

  code_changes         Source code modifications (est. 20-25 minutes)
  docs_only            Documentation changes only (est. 8-12 minutes)
  test_changes         Test modifications only (est. 15-18 minutes)
  infrastructure       CI/CD and dependencies (est. 25-30 minutes)
  full_validation      Complete workflow validation (est. 23-28 minutes)
```

### Display Profile Info

```bash
source src/workflow/lib/workflow_profiles.sh
display_profile_info "docs_only"
```

Output:
```
╔════════════════════════════════════════════════════════════╗
║              WORKFLOW PROFILE: docs_only
╚════════════════════════════════════════════════════════════╝

Description: Documentation changes only
Estimated Time: 8-12 minutes

Steps to Skip: 7,8
Focus Steps: 2,4,10
```

## Change Detection Patterns

### Documentation Changes
Triggers `docs_only` profile when ONLY these files change:
- `*.md` - Markdown files
- `docs/` - Documentation directory
- `README*` - README files
- `CHANGELOG*` - Changelog files
- `*.txt` - Text files

### Code Changes
Triggers `code_changes` profile:
- `src/**/*.sh` - Source shell scripts
- `*.sh` - Root-level scripts
- `lib/*.sh` - Library modules

### Test Changes
Triggers `test_changes` profile:
- `test*.sh` - Test scripts
- `*_test.sh` - Unit test files
- `tests/` - Test directory

### Infrastructure Changes
Triggers `infrastructure` profile (forces thorough validation):
- `*.yml`, `*.yaml` - YAML configuration
- `.github/` - GitHub Actions
- `Makefile` - Build configuration
- `*.json` - JSON configuration

## Step Reference

| Step # | Name | Description |
|--------|------|-------------|
| 0 | analyze | Change analysis |
| 1 | tech_stack | Technology stack detection |
| 2 | documentation | Documentation validation |
| 3 | script_refs | Script reference checking |
| 4 | structure | Project structure validation |
| 5 | code_analysis | Code quality analysis |
| 6 | ai_validation | AI-powered validation |
| 7 | tests | Test execution |
| 8 | dependencies | Dependency validation |
| 9 | quality | Code quality checks |
| 10 | analysis | Comprehensive analysis |
| 11 | optimization | Optimization suggestions |
| 13 | prompt | Prompt engineering |
| 14 | summary | Summary generation |
| 15 | version | Version management |

## API Functions

### `detect_workflow_profile()`
Auto-detect profile based on git changes.

**Environment:**
- Sets: `WORKFLOW_PROFILE`
- Respects: `SKIP_PROFILE_DETECTION`

**Example:**
```bash
source src/workflow/lib/workflow_profiles.sh
detect_workflow_profile
echo "Selected profile: $WORKFLOW_PROFILE"
```

### `should_skip_step(step_number)`
Check if step should be skipped based on current profile.

**Returns:** 0 if should skip, 1 if should run

**Example:**
```bash
if should_skip_step "7"; then
    echo "Skipping test execution (step 7)"
else
    echo "Running tests..."
fi
```

### `get_skip_steps([profile])`
Get comma-separated list of steps to skip.

**Example:**
```bash
skip_steps=$(get_skip_steps "docs_only")
echo "Steps to skip: $skip_steps"  # Output: 7,8
```

### `get_focus_steps([profile])`
Get comma-separated list of steps to focus on.

**Example:**
```bash
focus_steps=$(get_focus_steps "code_changes")
echo "Focus on: $focus_steps"  # Output: 7,8,9,13
```

### `get_estimated_time([profile])`
Get estimated execution time for profile.

**Example:**
```bash
time=$(get_estimated_time "docs_only")
echo "Estimated: $time"  # Output: 8-12 minutes
```

### `calculate_savings(profile)`
Calculate time savings percentage vs full validation.

**Example:**
```bash
savings=$(calculate_savings "docs_only")
echo "Savings: $savings"  # Output: 60%
```

## Integration Example

```bash
#!/usr/bin/env bash
# Example workflow script using profiles

source src/workflow/lib/workflow_profiles.sh

# Auto-detect profile
detect_workflow_profile

# Display selected profile
display_profile_info

# Check if we should skip tests
if should_skip_step "7"; then
    echo "Skipping tests based on profile: $WORKFLOW_PROFILE"
else
    echo "Running tests..."
    ./run_tests.sh
fi

# Check if we should skip dependencies
if should_skip_step "8"; then
    echo "Skipping dependency validation"
else
    echo "Validating dependencies..."
    ./check_dependencies.sh
fi

echo "Workflow complete!"
```

## Performance Impact

### Before Profiles (Baseline)
- Every run: 23-28 minutes full workflow
- Daily (10 runs): 230-280 minutes

### After Profiles (Optimized)
**Daily breakdown (10 runs):**
- 4 docs_only × 10 min = 40 minutes
- 3 code_changes × 20 min = 60 minutes
- 2 test_changes × 16 min = 32 minutes
- 1 infrastructure × 27 min = 27 minutes
- **Total: ~159 minutes**
- **Savings: 71-121 minutes (30-43%)**

## Best Practices

### 1. Trust Auto-Detection
Let the system detect the profile based on your changes:
```bash
# Good: Let system detect
./src/workflow/execute_tests_docs_workflow.sh

# Only override when necessary
export WORKFLOW_PROFILE="full_validation"
./src/workflow/execute_tests_docs_workflow.sh
```

### 2. Use Full Validation for Critical Changes
Force full validation for:
- Release branches
- Main/master branch merges
- Security-sensitive changes

### 3. Monitor Profile Distribution
Track which profiles are used most often:
```bash
# Add to workflow execution
echo "$WORKFLOW_PROFILE" >> .workflow_profile_history
```

### 4. Adjust Patterns as Needed
Edit `PROFILE_PATTERNS` in `workflow_profiles.sh` to match your project structure.

## Troubleshooting

### Profile Not Auto-Detected
**Symptom:** Always uses `full_validation`

**Cause:** Git changes not detectable or no git repository

**Solution:**
```bash
# Check git status
git status

# Manually set profile
export WORKFLOW_PROFILE="docs_only"
```

### Wrong Profile Selected
**Symptom:** `code_changes` when you only edited docs

**Cause:** Mixed changes (both code and docs)

**Solution:** Commit separately:
```bash
# Commit docs first
git add docs/ README.md
git commit -m "docs: update documentation"
# → triggers docs_only profile

# Then commit code
git add src/
git commit -m "feat: add new feature"
# → triggers code_changes profile
```

### Steps Still Running When They Should Skip
**Symptom:** Tests run in `docs_only` profile

**Cause:** Profile not integrated into main workflow script

**Solution:** Ensure main workflow checks `should_skip_step()` before each step.

## Future Enhancements

### Phase 2: Machine Learning Profile Selection
Learn from history to predict optimal profile:
- Track which profiles worked best
- Analyze false positives/negatives
- Auto-adjust patterns

### Phase 3: Custom Profiles
Allow project-specific profiles:
```yaml
# .workflow-profiles.yaml
custom_profile:
  description: "Frontend changes"
  skip_steps: [8, 9]
  focus_steps: [7, 13]
  patterns:
    - "src/frontend/**/*.js"
    - "public/**/*"
```

### Phase 4: Profile Recommendations
Suggest profiles based on commit message:
```bash
git commit -m "docs: update README"
# → System suggests: "docs_only profile recommended"
```

## Related Features

- **Smart Execution** (Node.js): Conditional test execution
- **Test Splitting** (Node.js): Fast/slow test tiers
- **Change Detection**: Git diff analysis
- **Metrics Collection**: Track profile usage and time savings

## Changelog

### [3.1.0] - 2026-02-07
- ✨ Initial implementation of workflow profiles
- ✨ 5 predefined profiles (docs_only, code_changes, test_changes, infrastructure, full_validation)
- ✨ Auto-detection based on git changes
- ✨ Manual override support
- ✨ Time estimation and savings calculation
- ✨ Profile display and listing functions
- 📚 Comprehensive documentation

---

**Maintained by:** AI Workflow Team  
**Last Updated:** 2026-02-07  
**Module Location:** `src/workflow/lib/workflow_profiles.sh`
