# Troubleshooting Guide

## Common Issues

### Prerequisites Not Met

**Symptoms**: Health check fails or commands not found

**Solution**:
```bash
# Run health check to identify issues
./src/workflow/lib/health_check.sh

# Verify versions
bash --version  # Should be 4.0+
git --version   # Should be 2.0+
node --version  # Should be 25.2.1+
```

### Workflow Execution Failures

**Symptoms**: Workflow stops unexpectedly

**Solution**:
1. Check logs in `src/workflow/logs/workflow_*/`
2. Review execution reports in `src/workflow/backlog/workflow_*/`
3. Use `--dry-run` to preview execution
4. Check for checkpoint files and use `--no-resume` to force fresh start

### AI Features Not Working

**Symptoms**: AI steps skipped or fail

**Solution**:
```bash
# Verify Copilot CLI is installed
gh copilot --version

# Check AI cache
ls -la src/workflow/.ai_cache/

# Disable caching for testing
./execute_tests_docs_workflow.sh --no-ai-cache
```

### Performance Issues

**Symptoms**: Execution takes too long

**Solution**:
```bash
# Use optimization flags
./execute_tests_docs_workflow.sh --smart-execution --parallel

# Check metrics
cat src/workflow/metrics/current_run.json
```

## Getting Help

- Check [FAQ](faq.md) for common questions
- Review [Error Codes](../reference/error-codes.md)
- Open an issue on GitHub with logs and execution reports
- See [MAINTAINERS.md](../MAINTAINERS.md) for contact information
