# Quick Reference: Sprint Improvements

## 🚀 What Was Added

### 1. Error Handling Template
**Location**: `templates/error_handling.sh`

**Quick Start**:
```bash
source templates/error_handling.sh
require_command "git"
info "Starting process..."
```

**Key Functions**:
- `error "msg" [exit_code]` - Exit with error
- `warn "msg"` - Print warning
- `info "msg"` - Print info
- `debug "msg"` - Debug logging (requires DEBUG=1)
- `require_command "cmd"` - Verify command exists
- `require_file "path"` - Verify file exists
- `require_directory "path"` - Verify directory exists

### 2. Test Runner
**Location**: `tests/test_runner.sh`

**Quick Commands**:
```bash
# Run all tests
./tests/test_runner.sh

# Unit tests only
./tests/test_runner.sh --unit

# Integration tests only
./tests/test_runner.sh --integration

# Verbose mode
./tests/test_runner.sh --verbose

# Continue on failure
./tests/test_runner.sh --continue
```

**Test Organization**:
- Unit tests: `tests/unit/test_*.sh`
- Integration tests: `tests/integration/test_*.sh`
- Reports: `test-results/test_report_*.txt`

### 3. CLI Parser (Already Exists)
**Location**: `src/workflow/lib/argument_parser.sh`

Already implemented - no action needed!

## 📁 New Directory Structure

```
ai_workflow/
├── templates/              # NEW: Reusable code templates
│   ├── error_handling.sh  # Error handling patterns
│   └── README.md          # Template documentation
├── tests/
│   ├── test_runner.sh     # NEW: Automated test harness
│   ├── unit/              # Unit tests
│   └── integration/       # Integration tests
└── docs/
    ├── SPRINT_IMMEDIATE_ACTIONS_COMPLETE.md  # NEW
    └── QUICK_REFERENCE_SPRINT_IMPROVEMENTS.md # NEW
```

## 🎯 Common Use Cases

### Starting a New Script
```bash
#!/bin/bash
set -euo pipefail

# Import error handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../templates/error_handling.sh"

# Validate dependencies
require_command "git" "git"
require_command "jq" "jq"
require_file "config.yaml" "configuration file"

# Your script logic here
info "Script started successfully"
```

### Running Tests Before Commit
```bash
# Quick check
./tests/test_runner.sh --unit

# Full validation
./tests/test_runner.sh --all --continue

# Detailed debugging
./tests/test_runner.sh --verbose
```

### Using Standard Error Handling
```bash
# Check if command succeeded
if ! git status &>/dev/null; then
    error "Not a git repository" ${EXIT_GENERAL_ERROR}
fi

# Validate file exists
require_file "package.json" "npm configuration"

# Safe command execution
safe_exec npm install
```

## 🔗 Related Documentation

- **Sprint Summary**: `docs/SPRINT_IMMEDIATE_ACTIONS_COMPLETE.md`
- **Template Usage**: `templates/README.md`
- **Test Runner Help**: `./tests/test_runner.sh --help`
- **Argument Parser**: `src/workflow/lib/argument_parser.sh`

## 💡 Tips

1. **Always use `set -euo pipefail`** at the top of scripts
2. **Source error handling early** to catch issues fast
3. **Run tests before committing** to catch regressions
4. **Use debug logging** during development (`DEBUG=1`)
5. **Check test reports** in `test-results/` for details

## 🎓 Examples

### Error Handling
```bash
# Before (no standard handling)
if [ ! -f "config.yaml" ]; then
    echo "Error: config.yaml not found"
    exit 1
fi

# After (with template)
require_file "config.yaml" "configuration file"
```

### Test Execution
```bash
# Before (manual execution)
bash tests/unit/test_utils.sh
bash tests/unit/test_validation.sh
# ... repeat for all tests

# After (automated)
./tests/test_runner.sh
```

### Command Validation
```bash
# Before (manual check)
if ! command -v git &>/dev/null; then
    echo "Error: git not found"
    exit 1
fi

# After (with template)
require_command "git"
```

---

**Created**: 2025-12-18  
**Sprint**: Immediate Actions - Technical Debt Reduction Phase 1
