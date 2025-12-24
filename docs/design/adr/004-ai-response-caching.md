# ADR-004: Implement AI Response Caching

**Status**: Accepted  
**Date**: 2025-12-18  
**Deciders**: Project maintainers  
**Related**: ADR-005, ADR-006

## Context

AI queries via GitHub Copilot CLI were:
- Slow (2-5 seconds per query)
- Expensive (token usage)
- Redundant (same prompts repeated)
- Not persisted across runs

For documentation-only changes, 60-80% of AI queries were identical to previous runs.

## Decision

Implement persistent AI response caching with:

**Key Features**:
- SHA256-based cache keys from prompt+context
- 24-hour TTL for cached responses
- Automatic cleanup of expired entries
- File-based cache storage (`.ai_cache/`)
- Atomic write operations
- Cache hit rate tracking

**Implementation**: New module `ai_cache.sh` (11K lines)

### Cache Structure

```
.ai_cache/
├── index.json          # Cache metadata and TTL
└── [sha256_hash]       # Cached response files
```

### Cache Strategy

1. **Key Generation**: SHA256(prompt + persona + context)
2. **Lookup**: Check index for valid (non-expired) entry
3. **Hit**: Return cached response, update access time
4. **Miss**: Query AI, cache response with TTL
5. **Cleanup**: Automatic removal of expired entries (daily)

## Consequences

### Positive

✅ **Performance**
- 60-80% reduction in AI query time for repeated prompts
- Near-instant response for cache hits
- Significant workflow speedup for iterative development

✅ **Cost Savings**
- 60-80% reduction in token usage
- Lower API costs
- Reduced rate limiting issues

✅ **Reliability**
- Works offline for cached queries
- Consistent responses for same inputs
- Reduces API dependency

✅ **Developer Experience**
- Faster feedback loops
- Can rerun workflow without penalty
- Enables rapid iteration

### Negative

⚠️ **Storage**
- Cache directory grows over time
- Requires disk space (~10-50MB typical)
- Automatic cleanup mitigates growth

⚠️ **Stale Data**
- Cached responses may become outdated
- 24-hour TTL balances freshness and performance
- Can disable with `--no-ai-cache`

⚠️ **Cache Invalidation**
- Prompt changes don't invalidate old cache
- Cache key includes prompt content (mitigates this)
- Manual cleanup possible

### Neutral

ℹ️ **Configuration**
- Enabled by default
- Can disable with `--no-ai-cache` flag
- TTL configurable (default 24h)

## Implementation

### Caching Logic

```bash
# Pseudo-code
cache_key=$(sha256sum <<< "${prompt}${persona}${context}")

if cache_entry_valid "${cache_key}"; then
    return cached_response
else
    response=$(ai_query "${prompt}")
    cache_response "${cache_key}" "${response}"
    return response
fi
```

### Cleanup Strategy

- Daily automatic cleanup of expired entries
- Triggered on workflow start
- Removes entries older than TTL
- Updates index.json

## Alternatives Considered

### Alternative 1: In-Memory Cache
- **Pros**: Faster access
- **Cons**: Not persistent across runs, limited by RAM
- **Rejected**: Persistence needed for iterative workflows

### Alternative 2: Database (SQLite)
- **Pros**: Better query capabilities, ACID
- **Cons**: Additional dependency, complexity
- **Rejected**: File-based sufficient for use case

### Alternative 3: No Caching
- **Rejected**: Performance and cost benefits too significant

## Measurements

**Before Caching**:
- Documentation-only change: 23 minutes
- 40-50 AI queries per run
- ~$0.10-0.20 per run (token costs)

**After Caching**:
- Documentation-only change (cache hit): 3.5 minutes (85% faster)
- 8-12 unique AI queries (60-80% cache hit rate)
- ~$0.02-0.04 per run (80% cost reduction)

## Related Decisions

- **ADR-005**: Smart execution (combines with caching for maximum benefit)
- **ADR-006**: Parallel execution (independent optimization)

## References

- `src/workflow/lib/ai_cache.sh` (implementation)
- [`PERFORMANCE_BENCHMARKS.md`](../../reference/performance-benchmarks.md)

---

**Outcome**: Successfully implemented in v2.3.0. Achieved 60-80% token reduction and 85% speedup for documentation changes.
