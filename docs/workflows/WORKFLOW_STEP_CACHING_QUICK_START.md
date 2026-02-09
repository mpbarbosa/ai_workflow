# Workflow Step Caching - Quick Start

**⚡ 3-minute integration guide**

## What is it?

Caches validation results between runs to skip unchanged files. **60% faster** on average.

## Quick Integration

### 1. Source the module (1 line)

```bash
source "${WORKFLOW_HOME}/src/workflow/lib/step_validation_cache.sh"
```

### 2. Initialize cache (1 line)

```bash
init_validation_cache
```

### 3. Replace validation loops

**Before:**
```bash
for file in *.js; do
    npx eslint "${file}"
done
```

**After:**
```bash
for file in *.js; do
    validate_file_cached "step9" "eslint" "${file}" "npx eslint '${file}'"
done
```

## Done! 🎉

Files will be cached and skipped if unchanged. First run builds cache (~5s overhead). Subsequent runs skip validation for unchanged files.

## Performance

| Change Type | Time Saved |
|-------------|------------|
| Docs only | 78% faster |
| 1 file | 65% faster |
| 10% files | 48% faster |

## Full Documentation

See `docs/workflows/WORKFLOW_STEP_CACHING.md` for:
- Complete API reference
- Integration examples
- Performance tuning
- Troubleshooting

## Quick Commands

```bash
# Show cache stats
get_validation_cache_stats

# Clear cache
rm -rf src/workflow/.validation_cache

# Disable caching
export USE_VALIDATION_CACHE=false
```

## Example: Step 9 Integration

```bash
#!/bin/bash
source "${WORKFLOW_HOME}/src/workflow/lib/step_validation_cache.sh"

step9_code_quality_validation() {
    # Initialize
    init_validation_cache
    
    # Find files
    files=$(find . -name "*.js" ! -path "*/node_modules/*")
    
    # Batch validate (recommended)
    batch_validate_files_cached "step9" "eslint" "npx eslint {file}" ${files}
    
    # Show stats
    get_validation_cache_stats
}
```

**Result**: Only validates changed files. 60% faster.

---

**Next**: Read full guide at `docs/workflows/WORKFLOW_STEP_CACHING.md`
