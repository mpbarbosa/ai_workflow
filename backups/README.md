# Backups Directory

Temporary backups created during major refactoring or migration operations.

## Purpose

This directory stores pre-migration backups for safety during:
- Major refactoring (modularization, restructuring)
- File moves or renames
- Configuration changes
- Code migrations

## Retention Policy

**Temporary Storage Only** - Backups should be removed after successful validation:
- Keep for 7-30 days after migration
- Remove once changes are committed and tested
- Maximum retention: 90 days

## Cleanup

To clean up old backups:

```bash
# Remove backups older than 30 days
find backups/ -type d -name "pre-migration-*" -mtime +30 -exec rm -rf {} \;
```

## Current Backups

Check subdirectories for specific backup purposes. Each backup directory should be named:
- `pre-migration-YYYYMMDD_HHMMSS/` - Timestamped migration backups
- Purpose documented in parent commit or changelog

**Last Updated**: 2026-02-09
