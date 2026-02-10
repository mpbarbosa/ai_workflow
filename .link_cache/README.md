# Link Cache Directory

**Purpose**: Caches link validation results to speed up documentation checks.

## Overview

This directory stores cached results from link validation operations performed during documentation analysis (Step 6). By caching link validation results, subsequent workflow runs avoid re-checking unchanged links, significantly improving performance.

## Structure

```
.link_cache/
├── <hash>.cache    # Individual link validation results
├── index.json      # Cache index with metadata
└── README.md       # This file
```

## How It Works

1. **Link Validation** (Step 6) checks all URLs in documentation
2. **Cache Key**: SHA256 hash of the URL
3. **Cache Entry**: Contains validation result (valid/broken/timeout) and timestamp
4. **TTL**: 7 days (configurable)

## Cache Management

### Automatic Management

- **Auto-created**: First run of link validation creates this directory
- **Auto-cleaned**: Entries older than 7 days are removed automatically
- **Max size**: 100MB (oldest entries removed when exceeded)

### Manual Management

```bash
# Clear all cache
rm -rf .link_cache/*

# Clear cache older than N days
find .link_cache/ -name "*.cache" -mtime +7 -delete

# View cache statistics
ls -lh .link_cache/ | wc -l  # Number of cached links
du -sh .link_cache/          # Total cache size
```

## Configuration

Configured in `.workflow-config.yaml`:

```yaml
link_validation:
  cache_enabled: true
  cache_ttl: 604800      # 7 days in seconds
  cache_max_size: 104857600  # 100MB
```

## Performance Impact

- **Without cache**: ~30-60 seconds for 100+ links
- **With cache (90% hit rate)**: ~5-10 seconds
- **Improvement**: 80-85% faster

## Gitignore

This directory is in `.gitignore` as cache contents are:
- Environment-specific (network conditions)
- Regenerable (computed from documentation)
- Temporary (TTL-based expiration)

## Notes

- Empty directory is normal for first-time setup
- Cache is shared across all workflow runs
- Link validation respects rate limits (10 requests/second)
- Broken link results are cached to avoid repeated checks

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-10  
**Feature introduced**: v2.9.0
