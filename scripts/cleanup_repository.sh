#!/usr/bin/env bash
# Repository Cleanup Script
# Date: 2026-02-08
# Purpose: Clean up root directory, remove duplicates, add READMEs

set -euo pipefail

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

echo "🧹 AI Workflow Repository Cleanup"
echo "=================================="
echo "📁 Repository: $REPO_ROOT"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track changes
CHANGES_MADE=0

# ============================================================================
# Action 1: Clean up top-level test scripts and temp files
# ============================================================================

echo "📦 Action 1: Cleaning up top-level files..."
echo ""

# Create scripts/deprecated directory if needed
mkdir -p scripts/deprecated

# Files to move to scripts/deprecated
TEST_SCRIPTS=(
    "test_step1_optimization.sh"
    "test_prompt_builder_fix.sh"
    "test_step1_log_fix.sh"
    "verify_step1_fix.sh"
    "test_step15_integration.sh"
)

echo "  Moving test scripts to scripts/deprecated/..."
for script in "${TEST_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "    ✓ Moving $script"
        git mv "$script" scripts/deprecated/ 2>/dev/null || mv "$script" scripts/deprecated/
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

# Temporary/output files to remove
TEMP_FILES=(
    "STEP_15_COMPLETE_SUMMARY.txt"
    "ai_documentation_analysis.txt"
    "documentation_analysis_parallel.md"
    "documentation_updates.md"
    "step0b_bootstrap_documentation.md"
    "stderr.txt"
    "stdout.txt"
    "cript (Step 7) is not changing to the correct directory before running tests."
    "t:coverage"
)

echo "  Removing temporary/output files..."
for file in "${TEMP_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "    ✓ Removing $file"
        rm -f "$file"
        CHANGES_MADE=$((CHANGES_MADE + 1))
    fi
done

echo -e "${GREEN}✅ Top-level cleanup complete${NC}"
echo ""

# ============================================================================
# Action 2: Remove duplicate src/workflow/src/ directory
# ============================================================================

echo "📦 Action 2: Removing duplicate src/workflow/src/ directory..."
echo ""

if [ -d "src/workflow/src" ]; then
    echo "  Found duplicate: src/workflow/src/"
    
    # Check what's inside
    file_count=$(find src/workflow/src -type f | wc -l)
    dir_size=$(du -sh src/workflow/src/ | cut -f1)
    
    echo "    Contents: $file_count files, $dir_size"
    
    # List files for review
    if [ "$file_count" -gt 0 ]; then
        echo "    Files found:"
        find src/workflow/src -type f | sed 's|^|      - |'
        
        # Check if any files are not in cache/metrics
        non_cache_files=$(find src/workflow/src -type f ! -path "*/\.ai_cache/*" ! -path "*/metrics/*" | wc -l)
        
        if [ "$non_cache_files" -gt 0 ]; then
            echo -e "    ${YELLOW}⚠️  WARNING: Found $non_cache_files non-cache files${NC}"
            echo "    These files might be important. Review before removal:"
            find src/workflow/src -type f ! -path "*/\.ai_cache/*" ! -path "*/metrics/*" | sed 's|^|      - |'
            echo ""
            read -p "    Continue with removal? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "    ${YELLOW}⊘ Skipped duplicate removal${NC}"
                echo ""
            else
                rm -rf src/workflow/src
                echo -e "    ${GREEN}✓ Removed duplicate directory${NC}"
                CHANGES_MADE=$((CHANGES_MADE + 1))
                echo ""
            fi
        else
            # Only cache/metrics - safe to remove
            echo "    ✓ Only cache/metrics files found - safe to remove"
            rm -rf src/workflow/src
            echo -e "    ${GREEN}✓ Removed duplicate directory${NC}"
            CHANGES_MADE=$((CHANGES_MADE + 1))
            echo ""
        fi
    else
        # Empty directory - safe to remove
        rm -rf src/workflow/src
        echo -e "    ${GREEN}✓ Removed empty duplicate directory${NC}"
        CHANGES_MADE=$((CHANGES_MADE + 1))
        echo ""
    fi
else
    echo "  ℹ️  No duplicate src/workflow/src/ directory found"
    echo ""
fi

echo -e "${GREEN}✅ Duplicate removal complete${NC}"
echo ""

# ============================================================================
# Action 3: Consolidate overlapping documentation
# ============================================================================

echo "📦 Action 3: Consolidating documentation directories..."
echo ""

# Check for overlapping documentation
echo "  Analyzing documentation structure..."

# Main docs directories
docs_dirs=(
    "docs"
    "documentation"
    "doc"
)

found_dirs=()
for dir in "${docs_dirs[@]}"; do
    if [ -d "$dir" ] && [ "$dir" != "docs" ]; then
        found_dirs+=("$dir")
    fi
done

if [ ${#found_dirs[@]} -gt 0 ]; then
    echo "  Found overlapping documentation directories:"
    for dir in "${found_dirs[@]}"; do
        file_count=$(find "$dir" -type f | wc -l)
        echo "    - $dir/ ($file_count files)"
    done
    echo ""
    echo "  📋 Recommendation: Manually review and consolidate to docs/"
    echo "     Use: git mv $dir/* docs/ (after review)"
    echo ""
else
    echo "  ✓ No overlapping documentation directories found"
    echo ""
fi

echo -e "${GREEN}✅ Documentation analysis complete${NC}"
echo ""

# ============================================================================
# Action 4: Add READMEs to runtime directories
# ============================================================================

echo "📦 Action 4: Adding READMEs to runtime directories..."
echo ""

# logs/README.md
if [ ! -f "logs/README.md" ]; then
    cat > logs/README.md << 'EOF'
# Workflow Execution Logs

This directory contains execution logs from workflow runs.

## Structure

```
logs/
├── workflow_YYYYMMDD_HHMMSS/
│   ├── workflow.log              # Main workflow log
│   ├── step_00_*.log             # Step-specific logs
│   ├── step_01_*.log
│   └── ...
└── README.md
```

## Log Rotation

Logs are automatically organized by execution timestamp. Old logs are not automatically deleted.

### Manual Cleanup

```bash
# Remove logs older than 30 days
find logs/ -type d -name "workflow_*" -mtime +30 -exec rm -rf {} \;

# Archive old logs
tar -czf logs_archive_$(date +%Y%m%d).tar.gz logs/workflow_2025*
```

## Log Levels

- **INFO**: Normal execution information
- **WARN**: Warning messages (non-fatal)
- **ERROR**: Error messages (may cause step failure)
- **DEBUG**: Detailed debug information (when --debug enabled)

## Viewing Logs

```bash
# View latest workflow log
tail -f logs/$(ls -t logs/ | head -1)/workflow.log

# Search for errors
grep -r "ERROR" logs/

# View specific step log
cat logs/workflow_YYYYMMDD_HHMMSS/step_05_test_execution.log
```

---

**Note**: This directory is excluded from git via `.gitignore`
EOF
    echo "  ✓ Created logs/README.md"
    CHANGES_MADE=$((CHANGES_MADE + 1))
fi

# backlog/README.md
if [ ! -f "backlog/README.md" ]; then
    cat > backlog/README.md << 'EOF'
# Workflow Execution Backlog

This directory contains execution reports and artifacts from workflow runs.

## Structure

```
backlog/
├── workflow_YYYYMMDD_HHMMSS/
│   ├── step_00_*.md              # Step execution reports
│   ├── step_01_documentation_updates.md
│   ├── step_02_consistency_check.md
│   ├── ...
│   ├── CHANGE_ANALYSIS.md        # Change detection results
│   ├── METRICS_SUMMARY.md        # Performance metrics
│   └── EXECUTION_SUMMARY.md      # Overall summary
└── README.md
```

## Purpose

Backlog entries provide:
- **Step Reports**: Detailed output from each workflow step
- **Change Analysis**: Git diff analysis and change categorization
- **Metrics**: Performance data and timing information
- **Summaries**: Executive summaries of workflow execution

## Retention

Backlog entries are kept indefinitely unless manually removed.

### Cleanup

```bash
# Remove entries older than 90 days
find backlog/ -type d -name "workflow_*" -mtime +90 -exec rm -rf {} \;

# Archive specific workflow run
tar -czf backlog_20250120.tar.gz backlog/workflow_20250120_*
```

## Using Backlog Data

```bash
# View latest execution summary
cat backlog/$(ls -t backlog/ | head -1)/EXECUTION_SUMMARY.md

# Review specific step output
cat backlog/workflow_YYYYMMDD_HHMMSS/step_01_documentation_updates.md

# Compare metrics across runs
grep "Total Duration" backlog/*/METRICS_SUMMARY.md
```

## AI-Generated Content

Many reports in backlog are generated by AI personas:
- Documentation analysis (documentation_specialist)
- Code reviews (code_reviewer)
- Test strategies (test_engineer)
- UX analysis (ux_designer)

---

**Note**: This directory is excluded from git via `.gitignore`
EOF
    echo "  ✓ Created backlog/README.md"
    CHANGES_MADE=$((CHANGES_MADE + 1))
fi

# test-results/README.md
if [ ! -f "test-results/README.md" ]; then
    cat > test-results/README.md << 'EOF'
# Test Execution Results

This directory contains test execution results and coverage reports.

## Structure

```
test-results/
├── unit/
│   ├── test_ai_cache_YYYYMMDD.xml
│   ├── test_metrics_YYYYMMDD.xml
│   └── ...
├── integration/
│   ├── test_workflow_step1_YYYYMMDD.xml
│   └── ...
├── coverage/
│   ├── coverage_YYYYMMDD.html
│   └── coverage_YYYYMMDD.json
└── README.md
```

## Test Types

### Unit Tests
- **Location**: `tests/unit/`
- **Results**: `test-results/unit/`
- **Purpose**: Test individual functions in isolation

### Integration Tests
- **Location**: `tests/integration/`
- **Results**: `test-results/integration/`
- **Purpose**: Test interaction between modules

### End-to-End Tests
- **Location**: `tests/e2e/`
- **Results**: `test-results/`
- **Purpose**: Test complete workflow execution

## Running Tests

```bash
# All tests
./tests/run_all_tests.sh

# Unit tests only
./tests/run_all_tests.sh --unit

# Integration tests only
./tests/run_all_tests.sh --integration

# Specific test
./tests/unit/test_ai_cache.sh
```

## Coverage Reports

Coverage reports show which code is tested:

```bash
# Generate coverage report
./tests/run_all_tests.sh --coverage

# View HTML report
open test-results/coverage/index.html

# View summary
cat test-results/coverage/coverage_summary.txt
```

## Test Result Formats

- **XML**: JUnit-compatible format for CI/CD
- **JSON**: Structured data for processing
- **HTML**: Human-readable reports
- **TXT**: Plain text summaries

## Cleanup

```bash
# Remove old test results
find test-results/ -type f -mtime +30 -delete

# Archive test results
tar -czf test-results_$(date +%Y%m%d).tar.gz test-results/
```

---

**Note**: This directory is excluded from git via `.gitignore`
EOF
    echo "  ✓ Created test-results/README.md"
    CHANGES_MADE=$((CHANGES_MADE + 1))
fi

echo -e "${GREEN}✅ README files created${NC}"
echo ""

# ============================================================================
# Summary
# ============================================================================

echo "=================================="
echo "📊 Cleanup Summary"
echo "=================================="
echo ""

if [ $CHANGES_MADE -eq 0 ]; then
    echo "ℹ️  No changes needed - repository is clean!"
else
    echo -e "${GREEN}✅ Made $CHANGES_MADE changes${NC}"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Review changes: git status"
    echo "  2. Check moved files: ls scripts/deprecated/"
    echo "  3. Review READMEs: cat logs/README.md"
    echo "  4. Commit changes:"
    echo "     git add ."
    echo "     git commit -m 'chore: repository cleanup and organization"
    echo ""
    echo "     - Move test scripts to scripts/deprecated/"
    echo "     - Remove temporary/output files"
    echo "     - Remove duplicate src/workflow/src/ directory"
    echo "     - Add READMEs to runtime directories (logs, backlog, test-results)"
    echo "     '"
fi

echo ""
echo "🎉 Cleanup complete!"
