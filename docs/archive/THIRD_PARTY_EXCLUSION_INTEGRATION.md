# Third-Party Exclusion Integration Guide

> **📚 CONSOLIDATED GUIDE AVAILABLE**: This document is supplementary. For the complete,  
> authoritative guide with examples and usage, see [**docs/THIRD_PARTY_EXCLUSION_GUIDE.md**](../THIRD_PARTY_EXCLUSION_GUIDE.md).

**Purpose:** Step-by-step guide for integrating the `third_party_exclusion.sh` module into existing workflow steps.

**Target Audience:** Developers maintaining workflow steps

**Date:** 2025-12-23

---

## Quick Start

### 1. Source the Module

Add at the top of your step file (after other library imports):

```bash
# Source third-party exclusion module
THIRD_PARTY_EXCLUSION_LIB="${WORKFLOW_LIB_DIR}/third_party_exclusion.sh"
if [[ -f "$THIRD_PARTY_EXCLUSION_LIB" ]]; then
    source "$THIRD_PARTY_EXCLUSION_LIB"
else
    # Fallback if module not found
    print_warning "Third-party exclusion module not found, using basic exclusions"
fi
```

### 2. Replace Manual Exclusions

**Before:**
```bash
# Manual exclusion patterns
find . -name "*.js" \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/coverage/*"
```

**After:**
```bash
# Automatic exclusions
find_with_exclusions "." "*.js" 5
```

### 3. Add AI Context

**Before:**
```bash
ai_call "documentation_specialist" \
    "Review the following files..." \
    "$file_list"
```

**After:**
```bash
ai_context=$(get_ai_exclusion_context)
ai_call "documentation_specialist" \
    "Review the following files. $ai_context..." \
    "$file_list"
```

### 4. Add Logging

```bash
log_exclusions "$STEP_LOG_FILE"
excluded_count=$(count_excluded_dirs "$TARGET_DIR")
print_info "Excluding $excluded_count third-party directories"
```

---

## Step-by-Step Integration Examples

### Step 1: Documentation Updates

**Current Implementation** (`step_01_documentation.sh`):
```bash
# Find markdown files manually
docs=$(find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*")
```

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

# Source libraries
source "$(dirname "$0")/../lib/third_party_exclusion.sh"
source "$(dirname "$0")/../lib/ai_helpers.sh"

# Step validation
validate_step1() {
    print_info "Validating Step 1 prerequisites..."
    
    # Count excluded directories for logging
    local excluded_count
    excluded_count=$(count_excluded_dirs "$TARGET_DIR")
    print_info "Found $excluded_count third-party directories to exclude"
    
    return 0
}

# Step execution
execute_step1() {
    print_header "Step 1: Documentation Updates"
    
    # Log exclusions
    log_exclusions "$STEP_LOG_FILE"
    
    # Find documentation files with exclusions
    local docs
    docs=$(find_with_exclusions "$TARGET_DIR" "*.md" 5)
    
    if [[ -z "$docs" ]]; then
        print_warning "No documentation files found"
        return 0
    fi
    
    # Get AI context
    local ai_context
    ai_context=$(get_ai_exclusion_context)
    
    # Call AI with context
    ai_call "documentation_specialist" \
        "Review these documentation files. $ai_context" \
        "$docs"
}
```

### Step 2: Documentation Consistency

**Current Implementation** (`step_02_consistency.sh`):
```bash
# Manual file discovery
files=$(find . -type f \( -name "*.md" -o -name "*.sh" \) | grep -v node_modules | grep -v .git)
```

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step2() {
    print_header "Step 2: Documentation Consistency"
    
    # Get markdown files
    local md_files
    md_files=$(find_with_exclusions "." "*.md" 5)
    
    # Get shell files
    local sh_files
    sh_files=$(find_with_exclusions "." "*.sh" 5)
    
    # Combine and analyze
    local all_files="$md_files"$'\n'"$sh_files"
    
    # Filter out any excluded paths (belt and suspenders)
    all_files=$(echo "$all_files" | filter_excluded_files)
    
    # Log summary
    local total_files
    total_files=$(echo "$all_files" | wc -l)
    local excluded
    excluded=$(count_excluded_dirs ".")
    
    print_info "Analyzing $total_files files (excluded $excluded third-party directories)"
    
    # Continue with consistency checks...
}
```

### Step 3: Script Reference Validation

**Current Implementation** (line 203, 219):
```bash
non_executable=$(fast_find "src/workflow" "*.sh" 5 "node_modules" ".git" | ...)
all_scripts=$(fast_find "src/workflow" "*.sh" 5 "node_modules" ".git" | sort)
```

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step3() {
    print_header "Step 3: Script Reference Validation"
    
    # Check 1: Executable permission validation
    print_info "Checking executable permissions..."
    local non_executable
    non_executable=$(find_with_exclusions "src/workflow" "*.sh" 5 | \
        while read -r f; do [[ ! -x "$f" ]] && echo "$f"; done)
    
    # Check 2: Script inventory
    print_info "Gathering script inventory..."
    local all_scripts
    all_scripts=$(find_with_exclusions "src/workflow" "*.sh" 5 | sort)
    local script_count
    script_count=$(echo "$all_scripts" | wc -l)
    
    # Log exclusion info
    local excluded
    excluded=$(count_excluded_dirs "src/workflow")
    print_info "Found $script_count scripts (excluded $excluded directories)"
    
    # Continue with validation...
}
```

### Step 4: Directory Structure Validation

**New Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step4() {
    print_header "Step 4: Directory Structure Validation"
    
    # Get expected directories from config
    local expected_dirs="src tests docs examples"
    
    # Find all directories, excluding third-party
    local actual_dirs
    actual_dirs=$(find . -type d -maxdepth 2 | filter_excluded_files)
    
    # Log what we're excluding
    log_exclusions "$STEP_LOG_FILE"
    
    # Validate structure...
}
```

### Step 5: Test Review

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step5() {
    print_header "Step 5: Test Coverage Review"
    
    # Get language-specific exclusions
    local primary_lang
    primary_lang=$(get_primary_language)
    local lang_excludes
    lang_excludes=$(get_language_exclusions "$primary_lang")
    
    print_info "Language: $primary_lang, Exclusions: $lang_excludes"
    
    # Find test files based on language
    local test_files
    case "$primary_lang" in
        javascript|typescript)
            test_files=$(find_with_exclusions "." "*.test.js" 5)
            test_files+=$'\n'$(find_with_exclusions "." "*.spec.js" 5)
            ;;
        python)
            test_files=$(find_with_exclusions "." "test_*.py" 5)
            ;;
        *)
            test_files=$(find_with_exclusions "." "*test*" 5)
            ;;
    esac
    
    # Get source files
    local source_files
    source_files=$(find_with_exclusions "src" "*" 5)
    
    # Add AI context
    local ai_context
    ai_context=$(get_ai_exclusion_context)
    
    # Analyze coverage with AI
    ai_call "test_engineer" \
        "Review test coverage. $ai_context
        Source files: $source_files
        Test files: $test_files" \
        "coverage_report.md"
}
```

### Step 9: Code Quality

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step9() {
    print_header "Step 9: Code Quality Analysis"
    
    # Get language and its exclusions
    local lang
    lang=$(get_primary_language)
    local excludes
    excludes=$(get_language_exclusions "$lang")
    
    print_info "Running quality checks for $lang (excluding: $excludes)"
    
    # Find source files
    local source_pattern
    case "$lang" in
        javascript) source_pattern="*.js" ;;
        typescript) source_pattern="*.ts" ;;
        python) source_pattern="*.py" ;;
        *) source_pattern="*" ;;
    esac
    
    local source_files
    source_files=$(find_with_exclusions "src" "$source_pattern" 5)
    
    # Run quality checks only on project files
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Verify not excluded (double-check)
        if ! is_excluded_path "$file"; then
            run_quality_check "$file"
        fi
    done <<< "$source_files"
    
    # Add exclusion context to AI analysis
    local ai_context
    ai_context=$(get_ai_exclusion_context)
    
    ai_call "code_reviewer" \
        "Analyze code quality. $ai_context
        Files analyzed: $source_files" \
        "quality_report.md"
}
```

### Step 12: Markdown Linting

**Integrated Implementation:**
```bash
#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/third_party_exclusion.sh"

execute_step12() {
    print_header "Step 12: Markdown Linting"
    
    # Find markdown files
    local md_files
    md_files=$(find_with_exclusions "." "*.md" 5)
    
    if [[ -z "$md_files" ]]; then
        print_warning "No markdown files found"
        return 0
    fi
    
    # Count for logging
    local file_count
    file_count=$(echo "$md_files" | wc -l)
    local excluded
    excluded=$(count_excluded_dirs ".")
    
    print_info "Linting $file_count markdown files (excluded $excluded directories)"
    log_exclusions "$STEP_LOG_FILE"
    
    # Run markdownlint
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        markdownlint "$file" || true
    done <<< "$md_files"
}
```

---

## Common Patterns

### Pattern 1: Basic File Discovery

```bash
# Old way
files=$(find . -name "*.ext" ! -path "*/node_modules/*" ! -path "*/.git/*")

# New way
files=$(find_with_exclusions "." "*.ext" 5)
```

### Pattern 2: Grep/Search Operations

```bash
# Old way
grep -r "pattern" . --exclude-dir=node_modules --exclude-dir=.git

# New way
grep_with_exclusions "pattern" "." "*"
```

### Pattern 3: File Filtering

```bash
# Old way
cat all_files.txt | grep -v node_modules | grep -v venv

# New way
cat all_files.txt | filter_excluded_files
```

### Pattern 4: Path Validation

```bash
# Old way
if [[ "$path" =~ node_modules ]]; then skip; fi

# New way
if is_excluded_path "$path"; then skip; fi
```

### Pattern 5: Language-Specific

```bash
# Old way
if [[ "$lang" == "javascript" ]]; then
    excludes="node_modules dist build"
elif [[ "$lang" == "python" ]]; then
    excludes="venv __pycache__"
fi

# New way
excludes=$(get_language_exclusions "$lang")
```

---

## Testing Integration

After integrating, verify:

1. **Module loads correctly:**
   ```bash
   source lib/third_party_exclusion.sh
   echo "Loaded: $(declare -F | grep -c 'get_.*exclusion')"
   # Should output: Loaded: 5 (or more)
   ```

2. **Exclusions work:**
   ```bash
   mkdir -p test_proj/{src,node_modules}
   touch test_proj/src/app.js
   touch test_proj/node_modules/lib.js
   
   files=$(find_with_exclusions "test_proj" "*.js" 3)
   echo "$files" | grep -q "app.js" && echo "✓ Found project file"
   echo "$files" | grep -q "lib.js" && echo "✗ Found excluded file" || echo "✓ Excluded correctly"
   
   rm -rf test_proj
   ```

3. **Run step tests:**
   ```bash
   # If step has tests
   cd src/workflow/steps
   bash test_step_XX.sh
   ```

---

## Migration Checklist

For each step being migrated:

- [ ] Source `third_party_exclusion.sh` module
- [ ] Replace manual `find` with `find_with_exclusions()`
- [ ] Replace manual `grep` with `grep_with_exclusions()`
- [ ] Add `log_exclusions()` call at step start
- [ ] Add `get_ai_exclusion_context()` to AI calls
- [ ] Remove hardcoded exclusion patterns
- [ ] Test step still functions correctly
- [ ] Verify excluded directories are actually excluded
- [ ] Update step documentation
- [ ] Add performance metrics (before/after)

---

## Backward Compatibility

The module maintains backward compatibility with existing `fast_find()` usage through `fast_find_safe()`:

```bash
# Old code continues to work
fast_find "." "*.sh" 5 "node_modules" ".git"

# But this is now preferred (standard exclusions automatic)
fast_find_safe "." "*.sh" 5

# Or even better (clear intent)
find_with_exclusions "." "*.sh" 5
```

---

## Performance Monitoring

Track performance improvements after integration:

```bash
# Before integration
time ./step_XX.sh > before.log 2>&1

# After integration
time ./step_XX.sh > after.log 2>&1

# Compare
echo "Files scanned before: $(grep -c "Processing" before.log)"
echo "Files scanned after: $(grep -c "Processing" after.log)"
```

---

## Troubleshooting

### Module Not Found

**Error:** `third_party_exclusion.sh: No such file or directory`

**Solution:**
```bash
# Verify module exists
ls -la src/workflow/lib/third_party_exclusion.sh

# Check WORKFLOW_LIB_DIR is set
echo "$WORKFLOW_LIB_DIR"

# Use absolute path if needed
source "$(dirname "$0")/../lib/third_party_exclusion.sh"
```

### Functions Not Available

**Error:** `get_exclusion_array: command not found`

**Solution:**
```bash
# Check if module was sourced
declare -F | grep exclusion

# Re-source the module
source lib/third_party_exclusion.sh

# Verify functions exported
export -f get_exclusion_array
```

### Exclusions Not Working

**Issue:** Third-party files still being processed

**Debug:**
```bash
# Test exclusion detection
is_excluded_path "/path/to/node_modules/file.js"
echo $?  # Should be 0 (excluded)

# Verify patterns
get_standard_exclusion_patterns | grep node_modules

# Check actual files found
find_with_exclusions "." "*.js" 5 | grep -i node_modules
# Should have no output
```

---

## Support

- **Module Documentation:** `docs/workflow-automation/THIRD_PARTY_EXCLUSION_MODULE.md`
- **Test Suite:** `tests/unit/lib/test_third_party_exclusion.sh`
- **Functional Requirements:** `CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md` § Third-Party File Exclusion

---

**Last Updated:** 2025-12-23  
**Version:** 1.0.0
