# Error Codes Reference

Common error codes and their meanings in the AI Workflow Automation system.

## Exit Codes

### General

- **0**: Success
- **1**: General error
- **2**: Usage error (invalid arguments)
- **126**: Command cannot execute
- **127**: Command not found
- **130**: Script terminated by Ctrl+C

### Workflow-Specific

- **10**: Prerequisites not met
- **11**: Configuration error
- **12**: Project detection failed
- **20**: Step validation failed
- **21**: Step execution failed
- **30**: AI service unavailable
- **31**: AI cache error
- **40**: File operation error
- **41**: Git operation error

## Common Error Messages

### "Prerequisites not met"
**Cause**: Required tools not installed or wrong version  
**Solution**: Run health check: `./src/workflow/lib/health_check.sh`

### "Copilot CLI not available"
**Cause**: GitHub Copilot CLI not installed  
**Solution**: Install with `npm install -g @githubnext/github-copilot-cli`

### "Project kind detection failed"
**Cause**: Unable to detect project type  
**Solution**: Set explicitly in `.workflow-config.yaml`

### "Step dependencies not met"
**Cause**: Previous step did not complete successfully  
**Solution**: Check logs and re-run from checkpoint

### "AI cache index corrupted"
**Cause**: Cache index file damaged  
**Solution**: Delete `.ai_cache/index.json` and retry

## Debugging

Enable debug mode for detailed error information:

```bash
export DEBUG=1
./execute_tests_docs_workflow.sh
```

Check logs for detailed error traces:
```bash
cat src/workflow/logs/workflow_*/error.log
```

## Getting Help

- See [Troubleshooting Guide](../user-guide/troubleshooting.md)
- Check [FAQ](../user-guide/faq.md)
- Open an issue on GitHub with error logs
