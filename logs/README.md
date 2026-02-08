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
