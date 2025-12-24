# AI Response Caching - Configuration & Troubleshooting Guide

**Version**: 1.0.0  
**Module**: `src/workflow/lib/ai_cache.sh` (11K)  
**Feature**: Introduced in v2.3.0  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-12-23

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration Options](#configuration-options)
- [TTL Configuration](#ttl-configuration)
- [Cache Invalidation](#cache-invalidation)
- [Cache Management](#cache-management)
- [Usage Patterns](#usage-patterns)
- [Performance Impact](#performance-impact)
- [Troubleshooting](#troubleshooting)
- [API Reference](#api-reference)

---

## Overview

### What is AI Response Caching?

AI response caching stores GitHub Copilot CLI responses to avoid redundant API calls. When the same prompt is used again within the TTL period, the cached response is returned instead of calling the API.

### Benefits

- **60-80% Token Reduction**: Reuse responses for identical prompts
- **Faster Execution**: Cached responses returned instantly
- **Cost Savings**: Fewer API calls to GitHub Copilot
- **Reliability**: Works even if API is slow or unavailable

> 📊 **Performance Evidence**: See [Performance Benchmarks](performance-benchmarks.md) for complete methodology, raw data, and validation of caching effectiveness (Section 5).

### How It Works

1. **Request**: Workflow generates AI prompt
2. **Cache Check**: System checks if identical prompt exists in cache
3. **Hit**: If found and not expired, return cached response
4. **Miss**: If not found or expired, call AI and cache response
5. **Cleanup**: Expired entries automatically removed every 24 hours

---

## Quick Start

### Default Configuration

AI caching is **enabled by default** with these settings:

```bash
USE_AI_CACHE=true              # Caching enabled
AI_CACHE_TTL=86400            # 24 hours (in seconds)
AI_CACHE_MAX_SIZE_MB=100      # 100 MB maximum cache size
AI_CACHE_DIR=".ai_workflow/src/workflow/.ai_cache"
```

### Disable Caching

```bash
# Command-line flag (temporary)
./execute_tests_docs_workflow.sh --no-ai-cache

# Environment variable (session)
export USE_AI_CACHE=false
./execute_tests_docs_workflow.sh

# Permanent (edit script)
# In execute_tests_docs_workflow.sh, change:
USE_AI_CACHE=false
```

### Check Cache Status

```bash
# View cache statistics
./execute_tests_docs_workflow.sh
# At end of execution, see:
# "AI Cache: 12/15 hits (80% hit rate)"

# Manual check
ls -lah .ai_workflow/src/workflow/.ai_cache/
cat .ai_workflow/src/workflow/.ai_cache/index.json | jq
```

---

## Configuration Options

### Environment Variables

| Variable | Default | Description | Valid Values |
|----------|---------|-------------|--------------|
| `USE_AI_CACHE` | `true` | Enable/disable caching | `true`, `false` |
| `AI_CACHE_TTL` | `86400` | Time-to-live (seconds) | Any positive integer |
| `AI_CACHE_MAX_SIZE_MB` | `100` | Maximum cache size (MB) | Any positive integer |
| `AI_CACHE_DIR` | `.ai_workflow/src/workflow/.ai_cache` | Cache directory path | Any valid path |

### Configuration File

Create `.workflow-config.yaml` in project root:

```yaml
# AI Cache Configuration
ai_cache:
  enabled: true
  ttl_seconds: 86400  # 24 hours
  max_size_mb: 100
  directory: ".ai_workflow/src/workflow/.ai_cache"
```

**Note**: Currently configured via environment variables. YAML config support planned for future release.

---

## TTL Configuration

### Understanding TTL

**TTL (Time-To-Live)**: How long cached responses remain valid before expiring.

**Default**: 86400 seconds (24 hours)

### When to Adjust TTL

#### Increase TTL (Longer Cache)

**Use Case**: Stable projects with infrequent changes

```bash
# 7 days (604800 seconds)
export AI_CACHE_TTL=604800

# 30 days (2592000 seconds)
export AI_CACHE_TTL=2592000
```

**Benefits**:
- Maximum token savings
- Faster execution
- Good for documentation-heavy projects

**Risks**:
- May return stale responses after major changes
- Larger cache size

#### Decrease TTL (Shorter Cache)

**Use Case**: Rapidly changing projects, active development

```bash
# 6 hours (21600 seconds)
export AI_CACHE_TTL=21600

# 1 hour (3600 seconds)
export AI_CACHE_TTL=3600
```

**Benefits**:
- Fresher AI responses
- Adapts quickly to changes
- Smaller cache size

**Risks**:
- More API calls
- Higher token usage
- Slower execution

### Recommended TTL by Project Type

| Project Type | Recommended TTL | Reason |
|--------------|-----------------|---------|
| Production | 24 hours (default) | Balance freshness and efficiency |
| Documentation Site | 7 days | Content changes infrequently |
| Active Development | 6-12 hours | Code changes frequently |
| CI/CD Pipeline | 1 hour | Each run should be fresh |
| Testing/Experimentation | Disabled | Need fresh responses |

### Setting TTL

#### Temporary (Single Run)

```bash
export AI_CACHE_TTL=3600
./execute_tests_docs_workflow.sh
```

#### Permanent (Edit Script)

```bash
# Edit src/workflow/lib/ai_cache.sh
# Line 19: Change from:
AI_CACHE_TTL=86400

# To your desired value:
AI_CACHE_TTL=21600  # 6 hours
```

#### Per-Project (Recommended)

```bash
# Create project-specific script
cat > run_workflow.sh << 'EOF'
#!/bin/bash
export AI_CACHE_TTL=43200  # 12 hours
./path/to/execute_tests_docs_workflow.sh "$@"
EOF
chmod +x run_workflow.sh
```

---

## Cache Invalidation

### Automatic Invalidation

**Cache entries automatically expire** after TTL period. Cleanup runs:
- On workflow initialization
- After any workflow execution
- When cache size exceeds limit

### Manual Invalidation

#### Clear Entire Cache

```bash
# Remove all cached responses
rm -rf .ai_workflow/src/workflow/.ai_cache/
# Cache will be recreated on next run
```

#### Clear Expired Entries Only

```bash
# Let workflow clean up expired entries
./execute_tests_docs_workflow.sh --steps 0
# Runs pre-analysis which triggers cleanup
```

#### Clear Specific Entry

```bash
# Find cache key
ls .ai_workflow/src/workflow/.ai_cache/*.txt

# Remove specific entry
rm .ai_workflow/src/workflow/.ai_cache/<cache_key>.txt
rm .ai_workflow/src/workflow/.ai_cache/<cache_key>.meta
```

### When to Invalidate

**Clear cache when**:
- ✅ Major project refactoring
- ✅ Switching project types
- ✅ AI prompts significantly changed
- ✅ Testing cache behavior
- ✅ Debugging AI response issues

**Don't clear cache when**:
- ❌ Minor code changes
- ❌ Documentation updates
- ❌ Regular workflow execution
- ❌ Just to "clean up" (cache manages itself)

---

## Cache Management

### Cache Directory Structure

```
.ai_workflow/src/workflow/.ai_cache/
├── index.json              # Cache index with metadata
├── <hash1>.txt            # Cached AI response
├── <hash1>.meta           # Response metadata (timestamp, etc.)
├── <hash2>.txt
├── <hash2>.meta
└── ...
```

### Cache Index Format

**File**: `index.json`

```json
{
  "version": "1.0.0",
  "created": "2025-12-23T10:00:00-03:00",
  "last_cleanup": "2025-12-23T18:30:00-03:00",
  "entries": [
    {
      "cache_key": "a1b2c3d4e5f6...",
      "persona": "documentation_specialist",
      "timestamp": "2025-12-23T10:15:30-03:00",
      "timestamp_epoch": 1766527530,
      "expires_at": "2025-12-24T10:15:30-03:00",
      "size_bytes": 2048
    }
  ]
}
```

### Cache Entry Metadata

**File**: `<hash>.meta`

```json
{
  "cache_key": "a1b2c3d4e5f6...",
  "persona": "documentation_specialist",
  "prompt_hash": "sha256:abc123...",
  "timestamp": "2025-12-23T10:15:30-03:00",
  "timestamp_epoch": 1766527530,
  "ttl_seconds": 86400,
  "expires_at": "2025-12-24T10:15:30-03:00",
  "size_bytes": 2048,
  "version": "1.0.0"
}
```

### Cache Size Management

#### Check Cache Size

```bash
# Human-readable size
du -sh .ai_workflow/src/workflow/.ai_cache/

# Detailed breakdown
du -ah .ai_workflow/src/workflow/.ai_cache/ | sort -hr | head -20
```

#### Size Limits

- **Default Maximum**: 100 MB
- **Automatic Cleanup**: Triggered when limit exceeded
- **Cleanup Strategy**: Delete oldest expired entries first

#### Adjust Size Limit

```bash
# Edit src/workflow/lib/ai_cache.sh
# Line 20: Change from:
AI_CACHE_MAX_SIZE_MB=100

# To larger value:
AI_CACHE_MAX_SIZE_MB=500  # 500 MB
```

---

## Usage Patterns

### Pattern 1: Development Workflow

**Scenario**: Active development with frequent changes

```bash
# Use shorter TTL for fresher responses
export AI_CACHE_TTL=21600  # 6 hours

# Run workflow
./execute_tests_docs_workflow.sh --smart-execution
```

**Expected**: Lower cache hit rate (40-50%), but responses adapt quickly to changes.

---

### Pattern 2: Documentation Maintenance

**Scenario**: Documentation site with stable content

```bash
# Use longer TTL for maximum efficiency
export AI_CACHE_TTL=604800  # 7 days

# Run workflow
./execute_tests_docs_workflow.sh --smart-execution
```

**Expected**: High cache hit rate (70-90%), significant token savings.

---

### Pattern 3: CI/CD Pipeline

**Scenario**: Automated checks on every commit

```bash
# Disable cache for fresh analysis each time
./execute_tests_docs_workflow.sh --no-ai-cache --auto
```

**Expected**: No caching, every run is fresh analysis.

---

### Pattern 4: Local Development

**Scenario**: Developer iterating on same files

```bash
# Default caching with smart execution
./execute_tests_docs_workflow.sh --smart-execution

# Cache will help with repeated analysis of same files
```

**Expected**: High cache hit rate (60-80%) for repeated work.

---

### Pattern 5: Testing Changes

**Scenario**: Testing prompt or workflow changes

```bash
# Clear cache before test
rm -rf .ai_workflow/src/workflow/.ai_cache/

# Run with fresh cache
./execute_tests_docs_workflow.sh
```

**Expected**: 0% cache hit rate (intentional), test uses fresh responses.

---

## Performance Impact

### Token Usage Reduction

**Without Caching**:
```
Step 1: 15,000 tokens
Step 2: 8,000 tokens
Step 5: 12,000 tokens
Step 6: 18,000 tokens
Step 10: 10,000 tokens
Total: 63,000 tokens
```

**With Caching** (60% hit rate):
```
Step 1: 6,000 tokens (9,000 cached)
Step 2: 3,200 tokens (4,800 cached)
Step 5: 4,800 tokens (7,200 cached)
Step 6: 7,200 tokens (10,800 cached)
Step 10: 4,000 tokens (6,000 cached)
Total: 25,200 tokens (60% reduction)
```

### Execution Time Impact

**Cache Hit**: Instant (< 0.1 seconds)  
**Cache Miss**: 5-30 seconds (AI API call)

**Example Workflow**:
- **Without Cache**: 23 minutes (all API calls)
- **With Cache** (80% hit rate): 15 minutes (12 hits, 3 misses)
- **Savings**: 8 minutes (35% faster)

### Cache Hit Rate Targets

| Hit Rate | Assessment | Action |
|----------|------------|--------|
| 80-100% | ✅ Excellent | Cache working perfectly |
| 60-80% | ✅ Good | Normal for mixed workload |
| 40-60% | ⚠️ Moderate | Consider longer TTL |
| 20-40% | 🔴 Low | Check cache configuration |
| 0-20% | 🔴 Very Low | Investigate cache issues |

---

## Troubleshooting

### Issue 1: Cache Not Working (0% Hit Rate)

**Symptoms**:
- Cache hit rate always 0%
- AI calls happen every time
- No `.ai_cache` directory

**Diagnosis**:
```bash
# Check if cache enabled
echo $USE_AI_CACHE

# Check cache directory exists
ls -la .ai_workflow/src/workflow/.ai_cache/

# Check cache module loaded
grep "init_ai_cache" src/workflow/execute_tests_docs_workflow.sh
```

**Solutions**:
1. Verify `USE_AI_CACHE=true` (default)
2. Check cache directory permissions:
   ```bash
   chmod 755 .ai_workflow/src/workflow/.ai_cache/
   ```
3. Ensure cache module sourced in workflow script

---

### Issue 2: Cache Hit Rate Lower Than Expected

**Symptoms**:
- Hit rate consistently below 50%
- Expecting more cache reuse

**Diagnosis**:
```bash
# Check TTL setting
grep "AI_CACHE_TTL" src/workflow/lib/ai_cache.sh

# Check cache entry ages
find .ai_workflow/src/workflow/.ai_cache/ -name "*.meta" -exec cat {} \; | jq '.timestamp'

# Check if prompts are stable
# Compare recent cache keys
ls -lt .ai_workflow/src/workflow/.ai_cache/*.txt | head -10
```

**Solutions**:
1. **Increase TTL** if entries expiring too quickly
2. **Stabilize prompts** if they change frequently
3. **Check for dynamic content** in prompts (timestamps, random data)

---

### Issue 3: Cache Growing Too Large

**Symptoms**:
- `.ai_cache` directory using too much disk space
- Hundreds of cache files

**Diagnosis**:
```bash
# Check cache size
du -sh .ai_workflow/src/workflow/.ai_cache/

# Count entries
ls -1 .ai_workflow/src/workflow/.ai_cache/*.txt | wc -l

# Check index
jq '.entries | length' .ai_workflow/src/workflow/.ai_cache/index.json
```

**Solutions**:
1. **Decrease TTL** to expire entries faster
2. **Run manual cleanup**:
   ```bash
   ./execute_tests_docs_workflow.sh --steps 0
   ```
3. **Adjust size limit**:
   ```bash
   # Edit ai_cache.sh
   AI_CACHE_MAX_SIZE_MB=50  # Reduce from 100
   ```

---

### Issue 4: Stale Cached Responses

**Symptoms**:
- AI responses don't reflect recent changes
- Analysis seems outdated

**Diagnosis**:
```bash
# Check cache entry timestamps
find .ai_workflow/src/workflow/.ai_cache/ -name "*.meta" -exec jq '.timestamp, .expires_at' {} \;

# Check TTL setting
echo $AI_CACHE_TTL
```

**Solutions**:
1. **Clear cache**:
   ```bash
   rm -rf .ai_workflow/src/workflow/.ai_cache/
   ```
2. **Decrease TTL** for fresher responses
3. **Disable cache temporarily**:
   ```bash
   ./execute_tests_docs_workflow.sh --no-ai-cache
   ```

---

### Issue 5: Cache Index Corrupted

**Symptoms**:
- Error messages about cache index
- Cache operations failing
- JSON parse errors

**Diagnosis**:
```bash
# Validate JSON
jq . .ai_workflow/src/workflow/.ai_cache/index.json

# Check file exists and is readable
ls -l .ai_workflow/src/workflow/.ai_cache/index.json
```

**Solutions**:
1. **Recreate index**:
   ```bash
   rm .ai_workflow/src/workflow/.ai_cache/index.json
   ./execute_tests_docs_workflow.sh --steps 0
   ```
2. **Full cache reset**:
   ```bash
   rm -rf .ai_workflow/src/workflow/.ai_cache/
   ```

---

## API Reference

### Cache Initialization

#### `init_ai_cache()`
Initialize cache directory and index.

**Usage**:
```bash
init_ai_cache
```

**Called**: Automatically at workflow start

---

### Cache Operations

#### `get_cached_response(cache_key)`
Retrieve cached AI response if available and not expired.

**Returns**:
- `0` with response on stdout if cache hit
- `1` if cache miss

**Usage**:
```bash
if response=$(get_cached_response "$cache_key"); then
    echo "Cache hit: $response"
else
    echo "Cache miss, calling AI..."
fi
```

---

#### `cache_response(cache_key, response, persona)`
Store AI response in cache.

**Parameters**:
- `cache_key`: Unique cache identifier
- `response`: AI response text
- `persona`: AI persona name

**Usage**:
```bash
cache_response "$cache_key" "$ai_response" "documentation_specialist"
```

---

### Cache Management

#### `cleanup_ai_cache_old_entries()`
Remove expired cache entries.

**Usage**:
```bash
cleanup_ai_cache_old_entries
```

**Called**: Automatically on workflow start and completion

---

#### `get_cache_stats()`
Get cache statistics (size, entries, hit rate).

**Usage**:
```bash
get_cache_stats
```

**Output**:
```
Cache Statistics:
  Total Entries: 42
  Cache Size: 8.2M
  Created: 2025-12-20T10:00:00-03:00
  Last Cleanup: 2025-12-23T18:00:00-03:00
```

---

#### `clear_ai_cache()`
Clear entire AI cache.

**Usage**:
```bash
clear_ai_cache
```

**Warning**: Removes all cached responses. Use with caution.

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────┐
│  AI Cache - Quick Reference                              │
├──────────────────────────────────────────────────────────┤
│  Enable/Disable:                                         │
│  ./workflow.sh --no-ai-cache  # Disable                 │
│  export USE_AI_CACHE=false    # Disable via env        │
│                                                          │
│  TTL Configuration:                                      │
│  export AI_CACHE_TTL=86400    # 24 hours (default)     │
│  export AI_CACHE_TTL=21600    # 6 hours                │
│  export AI_CACHE_TTL=604800   # 7 days                 │
│                                                          │
│  Clear Cache:                                            │
│  rm -rf .ai_workflow/src/workflow/.ai_cache/           │
│                                                          │
│  Check Stats:                                            │
│  du -sh .ai_workflow/src/workflow/.ai_cache/           │
│  cat .ai_workflow/.ai_cache/index.json | jq           │
│                                                          │
│  Default Settings:                                       │
│  • TTL: 24 hours                                        │
│  • Max Size: 100 MB                                     │
│  • Auto cleanup: Yes                                    │
│  • Token savings: 60-80%                                │
└──────────────────────────────────────────────────────────┘
```

---

## Best Practices

### Do's ✅

1. **Use default TTL** (24 hours) for most projects
2. **Monitor hit rate** - aim for 60%+
3. **Let cache auto-manage** - cleanup happens automatically
4. **Clear cache** after major refactoring
5. **Increase TTL** for documentation-heavy projects
6. **Decrease TTL** during active development

### Don'ts ❌

1. **Don't disable** unless testing or CI/CD
2. **Don't manually edit** cache files
3. **Don't set TTL** too short (< 1 hour) - wastes tokens
4. **Don't set TTL** too long (> 30 days) - stale responses
5. **Don't clear cache** unnecessarily - rebuilds are expensive
6. **Don't ignore** low hit rates - investigate cause

---

**Version**: 1.0.0  
**Status**: ✅ Complete  
**Module**: `src/workflow/lib/ai_cache.sh` (11K)  
**Feature**: v2.3.0+  
**Maintained By**: AI Workflow Automation Team  
**Last Updated**: 2025-12-23

**This is the authoritative guide for AI response caching configuration and troubleshooting.**
