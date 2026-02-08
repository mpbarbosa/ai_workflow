# Library API Reference

**Version**: 3.1.0  
**Last Updated**: 2026-02-08  
**Status**: Comprehensive Reference

---

## Table of Contents

1. [Core Modules](#core-modules)
   - [ai_helpers.sh](#ai_helperssh)
   - [workflow_optimization.sh](#workflow_optimizationsh)
   - [change_detection.sh](#change_detectionsh)
2. [Session & Execution](#session--execution)
   - [session_manager.sh](#session_managersh)
   - [ai_cache.sh](#ai_cachesh)
3. [Git & Operations](#git--operations)
   - [git_automation.sh](#git_automationsh)
   - [edit_operations.sh](#edit_operationssh)
4. [Monitoring & Analysis](#monitoring--analysis)
   - [metrics.sh](#metricssh)
   - [tech_stack.sh](#tech_stacksh)
5. [Quick Reference](#quick-reference)

---

## Core Modules

### ai_helpers.sh

**Purpose**: Core AI prompt building, GitHub Copilot integration, and language-aware prompt generation

**Size**: 113.4 KB  
**Functions**: 22+ exported functions  
**Dependencies**: `colors.sh`, `ai_personas.sh`, `project_kind_detection.sh`, `tech_stack.sh`

#### Key Functions

##### `is_copilot_available()`
Check if GitHub Copilot CLI is available in the environment.

**Parameters**: None  
**Returns**: 
- `0` - Copilot CLI is available
- `1` - Copilot CLI not found

**Example**:
```bash
if is_copilot_available; then
    echo "✓ Copilot CLI is available"
else
    echo "✗ Copilot CLI not found"
    exit 1
fi
```

---

##### `build_ai_prompt()`
Construct base AI prompt from project context and metadata.

**Parameters**: None (uses global context variables)  
**Returns**: String containing the constructed prompt

**Example**:
```bash
source src/workflow/lib/ai_helpers.sh
prompt=$(build_ai_prompt)
echo "$prompt" > prompt.txt
```

---

##### `execute_copilot_prompt(prompt, [options])`
Execute an AI prompt via GitHub Copilot CLI with optional caching.

**Parameters**:
- `prompt` (string, required): The prompt text to send to Copilot
- `options` (string, optional): Additional CLI flags (e.g., `--model`, `--temperature`)

**Returns**: JSON response from Copilot CLI

**Example**:
```bash
response=$(execute_copilot_prompt "Analyze this code for issues" "--model claude-sonnet-4")
echo "$response" | jq -r '.content'
```

---

##### `get_language_documentation_conventions(language)`
Retrieve language-specific documentation conventions (Javadoc, JSDoc, etc.).

**Parameters**:
- `language` (string, required): Programming language name (e.g., "javascript", "python")

**Returns**: String with documentation conventions

**Supported Languages**: JavaScript, Python, Go, Java, Ruby, Rust, C++, Bash

**Example**:
```bash
conventions=$(get_language_documentation_conventions "javascript")
# Returns: "Use JSDoc format with @param, @returns, and @example tags..."
```

---

##### `trigger_ai_step(step_num)`
Execute AI analysis for a specific workflow step with caching and error handling.

**Parameters**:
- `step_num` (integer, required): Step number (0-15)

**Returns**: 
- `0` - Success
- `1` - Failure

**Example**:
```bash
if trigger_ai_step 5; then
    echo "Step 5 AI analysis completed"
else
    echo "Step 5 AI analysis failed"
    exit 1
fi
```

---

### workflow_optimization.sh

**Purpose**: Smart workflow execution with change-based skip logic, parallel tracks, and checkpointing

**Size**: 34.8 KB  
**Functions**: 8 exported functions  
**Dependencies**: `change_detection.sh`, `metrics.sh`

#### Key Functions

##### `should_skip_step_by_impact(step_num, change_type)`
Determine if a workflow step should be skipped based on change analysis.

**Parameters**:
- `step_num` (integer, required): Step number to evaluate
- `change_type` (string, required): Detected change type (e.g., "docs-only", "code-only")

**Returns**: 
- `0` - Skip the step
- `1` - Execute the step

**Example**:
```bash
change_type=$(detect_change_type)
if should_skip_step_by_impact 7 "$change_type"; then
    echo "⊘ Skipping Step 7 (not applicable to $change_type)"
else
    execute_step 7
fi
```

---

##### `execute_parallel_tracks(track_config)`
Run independent workflow steps concurrently for faster execution.

**Parameters**:
- `track_config` (string, required): JSON configuration specifying parallel tracks

**Returns**: JSON with execution results for each track

**Example**:
```bash
config='{"track1": "2,3", "track2": "5,6"}'
results=$(execute_parallel_tracks "$config")
echo "$results" | jq -r '.track1.status'
```

---

##### `save_checkpoint(step_num, data)`
Save workflow state for recovery after failures.

**Parameters**:
- `step_num` (integer, required): Step number being checkpointed
- `data` (string, required): Serialized state data

**Returns**: 
- `0` - Checkpoint saved successfully
- `1` - Save failed

**Checkpoint Location**: `.ai_workflow/.checkpoints/step_${step_num}.json`

**Example**:
```bash
checkpoint_data=$(cat <<EOF
{
  "step": 5,
  "status": "completed",
  "timestamp": "$(date -Iseconds)",
  "artifacts": ["docs/api/README.md"]
}
EOF
)
save_checkpoint 5 "$checkpoint_data"
```

---

### change_detection.sh

**Purpose**: Auto-detect change types and recommend workflow steps based on file changes

**Size**: 526 lines  
**Functions**: 11 exported functions  
**Dependencies**: None (standalone)

#### Key Functions

##### `detect_change_type()`
Classify repository changes into categories for smart execution.

**Parameters**: None (analyzes Git working directory)  
**Returns**: One of:
- `docs-only` - Only documentation files changed
- `tests-only` - Only test files changed
- `config-only` - Only configuration files changed
- `scripts-only` - Only script files changed
- `code-only` - Only source code changed
- `full-stack` - Multiple categories changed
- `mixed` - Changes don't fit standard categories
- `unknown` - Unable to determine

**Example**:
```bash
change_type=$(detect_change_type)
echo "Detected change type: $change_type"

if [[ "$change_type" == "docs-only" ]]; then
    echo "Running documentation-only workflow (steps 0,2,3,11)"
fi
```

---

##### `filter_workflow_artifacts(file_list)`
Remove ephemeral workflow files from change analysis.

**Parameters**:
- `file_list` (array or newline-separated string): Files to filter

**Returns**: Filtered file list (newline-separated)

**Filtered Patterns**:
- `src/workflow/logs/**/*`
- `src/workflow/backlog/**/*`
- `src/workflow/.ai_cache/**/*`
- `src/workflow/metrics/**/*`
- `test-results/**/*`
- `*.log`, `*.tmp`

**Example**:
```bash
all_files=$(git diff --name-only HEAD)
filtered=$(filter_workflow_artifacts "$all_files")
echo "Analyzing ${filtered[@]}"
```

---

##### `get_recommended_steps()`
Return comma-separated list of recommended workflow steps based on changes.

**Parameters**: None  
**Returns**: String like "0,2,3,5,11" or "all"

**Example**:
```bash
steps=$(get_recommended_steps)
./execute_tests_docs_workflow.sh --steps "$steps"
```

---

## Session & Execution

### session_manager.sh

**Purpose**: Manage unique bash sessions, timeouts, and cleanup for workflow operations

**Size**: 377 lines  
**Functions**: 12 exported functions  
**Dependencies**: `colors.sh`

#### Key Functions

##### `generate_session_id(step_num, operation)`
Create unique timestamped session identifier.

**Parameters**:
- `step_num` (integer, required): Step number
- `operation` (string, required): Operation name (e.g., "npm_test", "git_commit")

**Returns**: String like "step05_npm_test_20260208_004930"

**Example**:
```bash
session_id=$(generate_session_id 5 "npm_test")
echo "Created session: $session_id"
```

---

##### `execute_with_session(step, operation, command, [timeout], [mode])`
Run a command with automatic session tracking and cleanup.

**Parameters**:
- `step` (integer, required): Step number
- `operation` (string, required): Operation identifier
- `command` (string, required): Shell command to execute
- `timeout` (integer, optional): Timeout in seconds (default: 300)
- `mode` (string, optional): Execution mode - "sync", "async", or "detached" (default: "sync")

**Returns**: Exit code of executed command

**Modes**:
- `sync`: Wait for completion with timeout
- `async`: Run in background, return immediately
- `detached`: Run independently, survives session cleanup

**Example**:
```bash
# Synchronous execution with 60s timeout
execute_with_session 5 "npm_test" "npm test" 60 "sync"

# Asynchronous execution
session_id=$(execute_with_session 5 "build" "npm run build" 0 "async")
# ... do other work ...
wait_for_session "$session_id" 120
```

---

##### `cleanup_all_sessions()`
Kill all active sessions registered for cleanup.

**Parameters**: None  
**Returns**: None

**Usage**: Automatically called on `EXIT` trap or manually for cleanup

**Example**:
```bash
trap cleanup_all_sessions EXIT ERR

# ... workflow execution ...
```

---

### ai_cache.sh

**Purpose**: Cache AI responses to reduce token usage and improve performance

**Size**: 394 lines  
**Functions**: 14 exported functions  
**Dependencies**: None (optional `jq` for JSON)

#### Key Functions

##### `init_ai_cache()`
Initialize AI cache directory and index file.

**Parameters**: None  
**Returns**: 
- `0` - Initialization successful
- `1` - Failed to create cache

**Cache Location**: `${WORKFLOW_HOME}/src/workflow/.ai_cache/`  
**Index File**: `index.json`

**Example**:
```bash
if init_ai_cache; then
    echo "✓ AI cache initialized"
fi
```

---

##### `generate_cache_key(prompt, [context])`
Create SHA256 hash key for caching.

**Parameters**:
- `prompt` (string, required): AI prompt text
- `context` (string, optional): Additional context (step, files, etc.)

**Returns**: 64-character hex string

**Example**:
```bash
key=$(generate_cache_key "Analyze code quality" "step=5,files=src/**/*.js")
echo "Cache key: $key"
```

---

##### `call_ai_with_cache(prompt, context, command)`
Execute AI call with automatic caching.

**Parameters**:
- `prompt` (string, required): AI prompt
- `context` (string, required): Context information
- `command` (string, required): Copilot CLI command to execute

**Returns**: AI response (from cache or fresh)

**TTL**: 24 hours (86400 seconds)

**Example**:
```bash
response=$(call_ai_with_cache \
    "Analyze this codebase" \
    "step=1,language=javascript" \
    "gh copilot suggest 'analyze codebase'")
echo "$response"
```

---

##### `get_cache_stats()`
Display cache statistics (size, entries, hit rate).

**Parameters**: None  
**Returns**: Human-readable statistics to stdout

**Example**:
```bash
get_cache_stats
# Output:
# AI Cache Statistics:
# Total entries: 47
# Cache size: 12.3 MB
# Hit rate: 68.2%
# Tokens saved: ~156,000
```

---

## Git & Operations

### git_automation.sh

**Purpose**: Intelligent post-workflow Git automation and artifact staging

**Size**: 435 lines  
**Functions**: 11 exported functions  
**Dependencies**: `colors.sh`

#### Key Functions

##### `detect_workflow_artifacts()`
Find all workflow-generated artifacts for staging.

**Parameters**: None  
**Returns**: Newline-separated list of file paths

**Detected Artifacts**:
- Documentation: `docs/**/*.md`
- Test results: `test-results/**/*`, `coverage/**/*`
- Logs: `src/workflow/logs/**/*.log`
- Reports: `src/workflow/backlog/**/*.md`
- Config: `.workflow-config.yaml`

**Example**:
```bash
artifacts=$(detect_workflow_artifacts)
echo "Found artifacts:"
echo "$artifacts"
```

---

##### `categorize_artifacts(files...)`
Classify artifact files by type.

**Parameters**:
- `files` (array): File paths to categorize

**Returns**: JSON object with categories

**Categories**: `docs`, `tests`, `logs`, `config`, `source`

**Example**:
```bash
categories=$(categorize_artifacts docs/api/README.md test-results/junit.xml)
echo "$categories" | jq -r '.docs[]'
```

---

##### `generate_artifact_commit_message([status])`
Create contextual commit message for workflow artifacts.

**Parameters**:
- `status` (string, optional): Workflow status ("success" or "failure", default: "success")

**Returns**: Multi-line commit message string

**Example**:
```bash
commit_msg=$(generate_artifact_commit_message "success")
git commit -m "$commit_msg"
# Output:
# docs: Update workflow artifacts (automated)
# 
# - Documentation updates from workflow execution
# - Test results and coverage reports
# - Workflow logs and metrics
# 
# Generated by: AI Workflow Automation v3.1.0
```

---

##### `stage_workflow_artifacts(status)`
Auto-stage workflow artifacts based on success/failure.

**Parameters**:
- `status` (string, required): "success" or "failure"

**Returns**: 
- `0` - Artifacts staged successfully
- `1` - Staging failed or disabled

**Behavior**:
- On success: Stage docs, tests, config (exclude logs unless `GIT_AUTO_STAGE_LOGS=true`)
- On failure: Stage logs and reports only

**Example**:
```bash
if stage_workflow_artifacts "success"; then
    echo "✓ Artifacts staged for commit"
    git status --short
fi
```

---

### edit_operations.sh

**Purpose**: Advanced file editing with fuzzy matching, validation, and safe retry logic

**Size**: 428 lines  
**Functions**: 8 exported functions  
**Dependencies**: `colors.sh`

#### Key Functions

##### `string_similarity(str1, str2)`
Compute similarity percentage between two strings using Levenshtein distance.

**Parameters**:
- `str1` (string, required): First string
- `str2` (string, required): Second string

**Returns**: Integer 0-100 (percentage similarity)

**Example**:
```bash
similarity=$(string_similarity "const oldVariable" "const oldVariabl")
echo "Similarity: ${similarity}%"  # Output: 94%
```

---

##### `find_fuzzy_match(file, search_string, [min_similarity])`
Find best fuzzy match in file when exact match fails.

**Parameters**:
- `file` (string, required): File path to search
- `search_string` (string, required): Text to find
- `min_similarity` (integer, optional): Minimum similarity threshold (default: 80)

**Returns**: 
- `0` - Match found (sets `FUZZY_MATCH_LINE` and `FUZZY_MATCH_SIMILARITY`)
- `1` - No suitable match

**Example**:
```bash
if find_fuzzy_match "src/utils.js" "function processData(" 75; then
    echo "Found match at line $FUZZY_MATCH_LINE (${FUZZY_MATCH_SIMILARITY}% similar)"
else
    echo "No match found"
fi
```

---

##### `safe_edit_file(file, old_string, new_string, [preview], [max_retries])`
Edit file with validation, backup, and retry logic.

**Parameters**:
- `file` (string, required): File path to edit
- `old_string` (string, required): Text to replace
- `new_string` (string, required): Replacement text
- `preview` (boolean, optional): Show diff before editing (default: false)
- `max_retries` (integer, optional): Retry attempts on failure (default: 3)

**Returns**: 
- `0` - Edit successful
- `1` - Edit failed after retries

**Features**:
- Automatic backup creation (`.backup.TIMESTAMP`)
- Fuzzy matching fallback (80% threshold)
- Exponential backoff retry (1s, 2s, 4s)
- Diff preview support

**Example**:
```bash
if safe_edit_file "src/app.js" \
    "const oldVar = 123;" \
    "const newVar = 456;" \
    true \
    3; then
    echo "✓ File edited successfully"
else
    echo "✗ Edit failed after 3 retries"
    exit 1
fi
```

---

##### `batch_edit_file(file, edits_file)`
Apply multiple edits to a file atomically.

**Parameters**:
- `file` (string, required): Target file path
- `edits_file` (string, required): JSON file with edit operations

**Edits File Format**:
```json
[
  {"old": "const foo = 1;", "new": "const bar = 1;"},
  {"old": "function old()", "new": "function newFunc()"}
]
```

**Returns**: 
- `0` - All edits applied successfully
- `1` - One or more edits failed

**Example**:
```bash
cat > edits.json <<EOF
[
  {"old": "let x = 1;", "new": "let x = 2;"},
  {"old": "let y = 3;", "new": "let y = 4;"}
]
EOF

batch_edit_file "src/vars.js" "edits.json"
```

---

## Monitoring & Analysis

### metrics.sh

**Purpose**: Track workflow duration, success rate, and step-level timing data

**Size**: 612 lines  
**Functions**: 17 exported functions  
**Dependencies**: `ml_optimization.sh` (optional), `colors.sh`

#### Key Functions

##### `init_metrics()`
Initialize metrics collection system.

**Parameters**: None  
**Returns**: 
- `0` - Initialization successful
- `1` - Failed to initialize

**Creates**:
- `${METRICS_DIR}/current_run.json`
- `${METRICS_DIR}/history.jsonl` (if not exists)

**Example**:
```bash
if init_metrics; then
    echo "✓ Metrics collection initialized"
fi
```

---

##### `start_step_timer(step_num, step_name)`
Begin timing a workflow step.

**Parameters**:
- `step_num` (integer, required): Step number
- `step_name` (string, required): Human-readable step name

**Returns**: None (records timestamp internally)

**Example**:
```bash
start_step_timer 5 "Code Quality Analysis"
# ... execute step 5 ...
stop_step_timer 5 "success"
```

---

##### `stop_step_timer(step_num, status, [error_message])`
End step timing and record result.

**Parameters**:
- `step_num` (integer, required): Step number
- `status` (string, required): "success", "failed", or "skipped"
- `error_message` (string, optional): Error details if failed

**Returns**: None (updates metrics internally)

**Example**:
```bash
start_step_timer 7 "Integration Tests"
if npm test; then
    stop_step_timer 7 "success"
else
    stop_step_timer 7 "failed" "Test suite returned non-zero exit code"
fi
```

---

##### `finalize_metrics([overall_status])`
Compute final statistics and save to history.

**Parameters**:
- `overall_status` (string, optional): "success" or "failed" (default: auto-detect)

**Returns**: None (writes to history file)

**Actions**:
- Calculates total duration
- Computes success rate
- Appends to `history.jsonl`
- Generates `summary.md`
- Triggers ML data collection (if enabled)

**Example**:
```bash
trap 'finalize_metrics "failed"' ERR
trap 'finalize_metrics "success"' EXIT

# ... workflow execution ...
```

---

##### `get_success_rate([count])`
Calculate success rate from historical data.

**Parameters**:
- `count` (integer, optional): Number of recent runs to analyze (default: 10)

**Returns**: Percentage string (e.g., "85.0%")

**Example**:
```bash
success_rate=$(get_success_rate 20)
echo "Success rate (last 20 runs): $success_rate"
```

---

##### `generate_metrics_summary()`
Create human-readable metrics report.

**Parameters**: None  
**Returns**: Markdown report written to `${METRICS_DIR}/summary.md`

**Report Sections**:
1. Overall Statistics
2. Step Timing Breakdown
3. Success/Failure Analysis
4. Performance Trends
5. Recommendations

**Example**:
```bash
finalize_metrics
generate_metrics_summary
cat "${METRICS_DIR}/summary.md"
```

---

### tech_stack.sh

**Purpose**: Detect project tech stack and provide language-specific commands

**Size**: 46.6 KB  
**Functions**: 25+ exported functions  
**Dependencies**: `colors.sh`

#### Key Functions

##### `detect_tech_stack()`
Comprehensive detection of project technology stack.

**Parameters**: None  
**Returns**: JSON object with detected technologies

**Detection Methods**:
- Package managers: `package.json`, `requirements.txt`, `Gemfile`, etc.
- Config files: `.eslintrc`, `pytest.ini`, `Cargo.toml`
- Source file patterns: `**/*.js`, `**/*.py`, `**/*.go`

**JSON Schema**:
```json
{
  "primary_language": "javascript",
  "framework": "react",
  "test_framework": "jest",
  "build_tool": "webpack",
  "package_manager": "npm",
  "confidence": 0.95
}
```

**Example**:
```bash
tech_stack=$(detect_tech_stack)
echo "$tech_stack" | jq -r '.primary_language'  # Output: javascript
```

---

##### `get_test_command([language])`
Retrieve standard test command for detected language.

**Parameters**:
- `language` (string, optional): Override detected language

**Returns**: String command (e.g., "npm test", "pytest", "go test ./...")

**Supported Languages**: JavaScript, Python, Go, Java, Ruby, Rust, C++, Bash

**Example**:
```bash
test_cmd=$(get_test_command)
echo "Running tests: $test_cmd"
eval "$test_cmd"
```

---

##### `execute_language_command(command_type, [args])`
Execute language-specific command with appropriate context.

**Parameters**:
- `command_type` (string, required): "test", "lint", "format", "build", or "clean"
- `args` (string, optional): Additional command arguments

**Returns**: Exit code from executed command

**Example**:
```bash
# Run tests with coverage
execute_language_command "test" "--coverage"

# Lint with auto-fix
execute_language_command "lint" "--fix"
```

---

##### `print_tech_stack_summary()`
Display detected tech stack in human-readable format.

**Parameters**: None  
**Returns**: None (prints to stdout)

**Example**:
```bash
print_tech_stack_summary
# Output:
# Technology Stack Summary:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Primary Language: JavaScript (Node.js 25.2.1)
# Framework: React 18.2
# Test Framework: Jest
# Build Tool: Webpack 5
# Package Manager: npm
# Confidence: 95%
```

---

## Quick Reference

### Most Common Operations

#### 1. Check if AI is available
```bash
source src/workflow/lib/ai_helpers.sh
if is_copilot_available && is_copilot_authenticated; then
    echo "AI ready"
fi
```

#### 2. Detect change type and optimize execution
```bash
source src/workflow/lib/change_detection.sh
change_type=$(detect_change_type)
steps=$(get_recommended_steps)
echo "Recommended steps for $change_type: $steps"
```

#### 3. Execute with session management
```bash
source src/workflow/lib/session_manager.sh
execute_with_session 5 "npm_test" "npm test" 120 "sync"
```

#### 4. Use AI with caching
```bash
source src/workflow/lib/ai_cache.sh
init_ai_cache
response=$(call_ai_with_cache "Analyze code" "step=5" "gh copilot suggest '...'")
```

#### 5. Track metrics
```bash
source src/workflow/lib/metrics.sh
init_metrics
start_step_timer 5 "Quality Check"
# ... do work ...
stop_step_timer 5 "success"
finalize_metrics
```

#### 6. Detect tech stack
```bash
source src/workflow/lib/tech_stack.sh
detect_tech_stack
test_cmd=$(get_test_command)
eval "$test_cmd"
```

#### 7. Stage artifacts automatically
```bash
source src/workflow/lib/git_automation.sh
stage_workflow_artifacts "success"
msg=$(generate_artifact_commit_message)
git commit -m "$msg"
```

#### 8. Safe file editing with retries
```bash
source src/workflow/lib/edit_operations.sh
safe_edit_file "src/app.js" \
    "const old = 1;" \
    "const new = 2;" \
    true \
    3
```

---

## Environment Variables

### Global Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `WORKFLOW_HOME` | Auto-detected | Workflow installation directory |
| `VERBOSE` | `false` | Enable verbose logging |
| `DRY_RUN` | `false` | Preview actions without execution |
| `DEBUG` | `false` | Enable debug mode |

### AI Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `USE_AI_CACHE` | `true` | Enable AI response caching |
| `AI_CACHE_DIR` | `.ai_workflow/.ai_cache` | Cache storage location |
| `AI_CACHE_TTL` | `86400` | Cache TTL in seconds (24h) |
| `AI_CACHE_MAX_SIZE_MB` | `100` | Maximum cache size |
| `COPILOT_MODEL` | `claude-sonnet-4` | Default AI model |

### Git Automation

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_AUTOMATION_ENABLED` | `true` | Enable git automation |
| `AUTO_STAGE_ARTIFACTS` | `true` | Auto-stage workflow artifacts |
| `GIT_AUTO_STAGE_LOGS` | `false` | Include logs in staging |

### Metrics & Performance

| Variable | Default | Description |
|----------|---------|-------------|
| `METRICS_DIR` | Target project metrics | Metrics storage location |
| `ML_OPTIMIZE` | `false` | Enable ML optimization training |
| `TRACK_PERFORMANCE` | `true` | Enable performance tracking |

---

## Error Codes

### Common Exit Codes

| Code | Meaning | Resolution |
|------|---------|------------|
| `0` | Success | Operation completed successfully |
| `1` | General error | Check error message and logs |
| `2` | Invalid arguments | Review function parameters |
| `3` | File not found | Verify file paths |
| `4` | Permission denied | Check file/directory permissions |
| `5` | Timeout | Increase timeout or check system resources |
| `6` | Cache error | Clear cache with `clear_ai_cache()` |
| `7` | Git error | Check git repository status |
| `8` | AI unavailable | Verify Copilot CLI installation |

---

## Performance Tips

1. **Enable AI Caching**: Reduces token usage by 60-80%
   ```bash
   export USE_AI_CACHE=true
   ```

2. **Use Smart Execution**: Skip unnecessary steps
   ```bash
   change_type=$(detect_change_type)
   # Only run relevant steps
   ```

3. **Parallel Execution**: Run independent steps concurrently
   ```bash
   execute_parallel_tracks '{"track1":"2,3","track2":"5,6"}'
   ```

4. **Session Management**: Prevent resource leaks
   ```bash
   trap cleanup_all_sessions EXIT
   ```

5. **Checkpoint Recovery**: Resume from failures
   ```bash
   if load_checkpoint 5; then
       echo "Resuming from step 5"
   fi
   ```

---

## Additional Resources

- **[Module Index](./MODULE_INDEX.md)** - Alphabetical module listing
- **[Function Reference](./FUNCTION_REFERENCE.md)** - All functions A-Z
- **[Architecture Guide](../architecture/SYSTEM_ARCHITECTURE.md)** - System design
- **[Developer Guide](../guides/DEVELOPER_GUIDE.md)** - Contributing guide
- **[FAQ](../FAQ.md)** - Common questions

---

**Documentation Version**: 3.1.0  
**Generated**: 2026-02-08  
**Maintained by**: AI Workflow Automation Team
