# Quick Reference: --target Option

## Basic Usage

```bash
# Run workflow on target project
./shell_scripts/workflow/execute_tests_docs_workflow.sh --target /path/to/project

# Common examples
./execute_tests_docs_workflow.sh --target ~/Documents/GitHub/mpbarbosa_site
./execute_tests_docs_workflow.sh --target ~/Documents/GitHub/monitora_vagas --auto
./execute_tests_docs_workflow.sh --target ~/Documents/GitHub/busca_vagas --dry-run
```

## Combined Options

```bash
# Target + Auto mode
./execute_tests_docs_workflow.sh --target /path/to/project --auto

# Target + Specific steps
./execute_tests_docs_workflow.sh --target /path/to/project --steps 0,1,2,3,4

# Target + Dry run
./execute_tests_docs_workflow.sh --target /path/to/project --dry-run

# Target + Verbose
./execute_tests_docs_workflow.sh --target /path/to/project --verbose --auto
```

## How It Works

| Variable | Points To | Purpose |
|----------|-----------|---------|
| `WORKFLOW_HOME` | ai_workflow repository | Workflow scripts, backlog, logs |
| `PROJECT_ROOT` | Target project (or ai_workflow) | Where workflow runs |
| `TARGET_PROJECT_ROOT` | Target project path | Set by --target option |

## Benefits

✅ No file copying needed  
✅ Run on multiple projects  
✅ Centralized reporting  
✅ Easy workflow updates  
✅ 100% backward compatible  

## Error Handling

```bash
# Invalid path
$ ./execute_tests_docs_workflow.sh --target /nonexistent
❌ ERROR: Target directory does not exist: /nonexistent

# Missing argument
$ ./execute_tests_docs_workflow.sh --target
❌ ERROR: --target requires a directory path argument
```

## Where Reports Are Saved

All reports saved in ai_workflow regardless of target:

```
ai_workflow/
└── shell_scripts/workflow/
    ├── backlog/workflow_YYYYMMDD_HHMMSS/     # Execution reports
    ├── summaries/workflow_YYYYMMDD_HHMMSS/   # Step summaries
    └── logs/workflow_YYYYMMDD_HHMMSS/        # Workflow logs
```

## See Also

- **Full Documentation**: [docs/TARGET_PROJECT_FEATURE.md](TARGET_PROJECT_FEATURE.md)
- **Help**: `./execute_tests_docs_workflow.sh --help`
- **Version**: `./execute_tests_docs_workflow.sh --version`
