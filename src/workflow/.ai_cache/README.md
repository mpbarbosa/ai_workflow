# AI Response Cache

## Purpose

Cache AI responses to reduce token usage and improve performance. This caching system provides **60-80% token savings** by storing and reusing previous AI responses for identical prompts.

## Key Features

- **Automatic Caching**: All AI responses cached by default (SHA256-keyed)
- **Time-To-Live (TTL)**: 24-hour default expiration
- **Automatic Cleanup**: Daily cleanup of expired entries
- **Collision-Safe**: SHA256 hashing ensures unique keys
- **Hit Rate Tracking**: Metrics collection for cache effectiveness

## Structure

```
.ai_cache/
├── README.md           # This file
├── index.json         # Cache index with metadata
└── [hash].json        # Individual cached responses (SHA256-keyed)
```

## Cache Index Format

The `index.json` file maintains metadata for all cached entries:

```json
{
  "version": "1.0",
  "last_cleanup": "2025-12-18T12:00:00Z",
  "entries": {
    "abc123...": {
      "persona": "documentation_specialist",
      "prompt_hash": "abc123...",
      "created_at": "2025-12-18T10:30:00Z",
      "expires_at": "2025-12-19T10:30:00Z",
      "size_bytes": 4096,
      "hits": 5
    }
  }
}
```

## Individual Cache Entry Format

Each cached response is stored as a JSON file:

```json
{
  "persona": "documentation_specialist",
  "prompt": "Original prompt text...",
  "response": "AI-generated response...",
  "created_at": "2025-12-18T10:30:00Z",
  "expires_at": "2025-12-19T10:30:00Z",
  "metadata": {
    "model": "gpt-4",
    "tokens": 1500
  }
}
```

## Usage

### Enable Caching (Default)

Caching is enabled by default. No special flags needed:

```bash
./execute_tests_docs_workflow.sh
```

### Disable Caching

Use the `--no-ai-cache` flag to bypass cache:

```bash
./execute_tests_docs_workflow.sh --no-ai-cache
```

### Clear Cache

Manually clear all cached entries:

```bash
rm -rf .ai_cache/*.json
# Keep index.json structure or regenerate on next run
```

## Cache Management

### Automatic Cleanup

- **Frequency**: Every 24 hours
- **Trigger**: First cache access after cleanup interval
- **Action**: Removes entries past their TTL
- **Logging**: Cleanup operations logged to workflow logs

### Manual Cleanup

Force cleanup of expired entries:

```bash
# Using the cache module directly
source lib/ai_cache.sh
cleanup_expired_cache_entries
```

## Performance Metrics

Cache effectiveness is tracked in workflow metrics:

```json
{
  "ai_cache": {
    "total_calls": 100,
    "cache_hits": 75,
    "cache_misses": 25,
    "hit_rate": "75%",
    "tokens_saved": 112500
  }
}
```

## Configuration

Default settings are defined in `lib/ai_cache.sh`:

```bash
AI_CACHE_TTL=86400           # 24 hours in seconds
AI_CACHE_DIR=".ai_cache"     # Cache directory location
AI_CACHE_CLEANUP_INTERVAL=86400  # Daily cleanup
```

## Best Practices

1. **Keep Cache Enabled**: Provides significant performance benefits
2. **Monitor Hit Rates**: Check metrics to validate caching effectiveness
3. **Clear When Needed**: Clear cache after major prompt template changes
4. **TTL Awareness**: Understand 24-hour expiration for time-sensitive operations
5. **Disk Space**: Monitor cache directory size for large projects

## Troubleshooting

### Cache Not Working

1. Verify cache directory exists: `ls -la .ai_cache/`
2. Check write permissions: `touch .ai_cache/test && rm .ai_cache/test`
3. Review logs for cache errors: `grep "cache" logs/*/workflow_execution.log`

### Stale Responses

1. Clear cache for fresh responses: `rm -rf .ai_cache/*.json`
2. Use `--no-ai-cache` for one-time bypass
3. Check TTL settings if responses expire too slowly

### High Disk Usage

1. Review cache size: `du -sh .ai_cache/`
2. Reduce TTL in configuration
3. Run manual cleanup: `cleanup_expired_cache_entries`

## Technical Details

- **Hash Algorithm**: SHA256 (persona + prompt)
- **Storage Format**: JSON (human-readable)
- **Concurrency**: File-based locking for safety
- **Portability**: Works on all Unix-like systems

## Related Documentation

- `lib/ai_cache.sh` - Cache implementation
- `lib/ai_helpers.sh` - AI integration using cache
- `docs/workflow-automation/PHASE2_COMPLETION.md` - Feature documentation
- `MIGRATION_README.md` - Version 2.3.0 release notes

---

**Last Updated**: 2025-12-18  
**Module Version**: 2.3.1  
**Maintained By**: AI Workflow Automation Team
