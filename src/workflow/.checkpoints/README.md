# Workflow Checkpoints

## Purpose

Store workflow execution checkpoints for resume capability and crash recovery. This directory enables the workflow to recover from interruptions and continue from the last successful step.

## Key Features

- **Automatic Checkpointing**: Each step completion creates a checkpoint
- **Resume Capability**: Restart from last successful step after crashes
- **State Persistence**: Preserves execution context and variables
- **Idempotent Recovery**: Safe to re-run without side effects
- **Progress Tracking**: Monitor workflow execution progress

## Structure

```
.checkpoints/
├── README.md                    # This file
└── workflow_YYYYMMDD_HHMMSS/   # Checkpoint directory per run
    ├── checkpoint.json          # Master checkpoint state
    ├── step_00.complete         # Step completion markers
    ├── step_01.complete
    ├── step_02.complete
    └── state/                   # Step-specific state data
        ├── step_00_state.json
        ├── step_01_state.json
        └── ...
```

## Checkpoint State Format

The `checkpoint.json` file maintains the overall workflow state:

```json
{
  "version": "2.3.0",
  "workflow_id": "workflow_20251218_121530",
  "project_path": "/home/user/project",
  "started_at": "2025-12-18T12:15:30Z",
  "last_checkpoint": "2025-12-18T12:20:45Z",
  "completed_steps": [0, 1, 2, 5],
  "current_step": 6,
  "total_steps": 13,
  "execution_mode": {
    "auto": true,
    "smart_execution": true,
    "parallel": false,
    "dry_run": false
  },
  "environment": {
    "shell": "bash",
    "bash_version": "5.1.16",
    "git_available": true,
    "copilot_available": true
  },
  "metadata": {
    "user": "developer",
    "hostname": "workstation",
    "pid": 12345
  }
}
```

## Step Completion Markers

Each `step_XX.complete` file marks a successfully completed step:

```bash
# step_01.complete
STEP=1
COMPLETED_AT=2025-12-18T12:16:42Z
DURATION_SECONDS=72
EXIT_CODE=0
```

## Step State Files

Individual step state saved in JSON format:

```json
{
  "step": 1,
  "name": "documentation",
  "status": "completed",
  "started_at": "2025-12-18T12:15:30Z",
  "completed_at": "2025-12-18T12:16:42Z",
  "duration_seconds": 72,
  "exit_code": 0,
  "outputs": {
    "files_modified": ["README.md", "docs/API.md"],
    "ai_calls": 3,
    "tokens_used": 2500
  },
  "errors": [],
  "warnings": []
}
```

## Usage

### Automatic Checkpointing

Checkpoints are created automatically during workflow execution:

```bash
# Normal execution - checkpoints created automatically
./execute_tests_docs_workflow.sh
```

### Resume from Checkpoint

Resume a failed workflow from the last successful step:

```bash
# Resume most recent workflow
./execute_tests_docs_workflow.sh --resume

# Resume specific workflow run
./execute_tests_docs_workflow.sh --resume workflow_20251218_121530
```

### View Checkpoint Status

Check the current checkpoint state:

```bash
# Show checkpoint information
./execute_tests_docs_workflow.sh --checkpoint-status

# List all checkpoints
ls -la .checkpoints/
```

### Clear Checkpoints

Remove old checkpoints to free disk space:

```bash
# Clear all checkpoints
rm -rf .checkpoints/workflow_*

# Clear checkpoints older than 7 days
find .checkpoints/ -name "workflow_*" -mtime +7 -exec rm -rf {} \;
```

## Checkpoint Lifecycle

1. **Workflow Start**: Create checkpoint directory
2. **Step Execution**: Update checkpoint before/after each step
3. **Step Completion**: Create completion marker and state file
4. **Workflow End**: Finalize checkpoint with summary
5. **Retention**: Keep for 7 days (configurable)

## Resume Behavior

When resuming from a checkpoint:

1. **Validation**: Verify checkpoint integrity and compatibility
2. **State Restore**: Load execution context and environment
3. **Skip Completed**: Bypass steps marked as complete
4. **Continue**: Execute remaining steps in sequence
5. **Cleanup**: Update checkpoint on completion

## Configuration

Checkpoint settings are defined in the main workflow script:

```bash
CHECKPOINT_DIR=".checkpoints"
CHECKPOINT_RETENTION_DAYS=7
CHECKPOINT_ENABLED=true
```

## Best Practices

1. **Don't Delete During Execution**: Can cause recovery issues
2. **Regular Cleanup**: Remove old checkpoints to save space
3. **Use Resume**: Always prefer resume over restart for failed runs
4. **Monitor Size**: Large projects may generate substantial checkpoint data
5. **Backup Critical**: Include checkpoints in disaster recovery plans

## Troubleshooting

### Cannot Resume Workflow

1. Verify checkpoint exists: `ls .checkpoints/workflow_*/`
2. Check checkpoint integrity: `cat .checkpoints/workflow_*/checkpoint.json`
3. Ensure correct workflow ID provided
4. Review logs for checkpoint errors

### Checkpoint Corruption

1. Remove corrupted checkpoint: `rm -rf .checkpoints/workflow_YYYYMMDD_HHMMSS`
2. Restart workflow from beginning
3. Check disk space and permissions
4. Review system logs for I/O errors

### High Disk Usage

1. Check checkpoint size: `du -sh .checkpoints/`
2. Clean old checkpoints: `find .checkpoints/ -mtime +7 -delete`
3. Adjust retention policy in configuration
4. Exclude large state data if not needed

## Advanced Features

### Parallel Execution Checkpoints

When using `--parallel`, checkpoints track independent execution paths:

```json
{
  "parallel_execution": {
    "enabled": true,
    "groups": [
      {"steps": [1, 2, 3], "status": "completed"},
      {"steps": [5, 6], "status": "running"},
      {"steps": [9, 10], "status": "pending"}
    ]
  }
}
```

### Smart Execution Integration

Checkpoints integrate with smart execution to skip unchanged steps:

```json
{
  "smart_execution": {
    "enabled": true,
    "skipped_steps": [4, 8, 11],
    "skip_reason": "no_relevant_changes"
  }
}
```

## Technical Details

- **Storage Format**: JSON for state, plain text for markers
- **Atomicity**: Write-then-rename for atomic updates
- **Locking**: File-based locks prevent concurrent access
- **Permissions**: 0755 for directories, 0644 for files
- **Portability**: POSIX-compliant, works on all Unix-like systems

## Related Documentation

- `lib/step_execution.sh` - Checkpoint implementation
- `lib/workflow_optimization.sh` - Resume logic
- `docs/workflow-automation/WORKFLOW_RESILIENCE_SUMMARY.md` - Resilience features
- `MIGRATION_README.md` - Workflow architecture

## Security Considerations

- Checkpoints may contain sensitive project data
- Restrict permissions on checkpoint directory
- Exclude from version control (add to .gitignore)
- Clean up checkpoints on shared systems
- Review checkpoint data before sharing logs

---

**Last Updated**: 2025-12-18  
**Module Version**: 2.3.0  
**Maintained By**: AI Workflow Automation Team
