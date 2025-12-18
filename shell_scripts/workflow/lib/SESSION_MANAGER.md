# Bash Session Management Module

**Module**: `lib/session_manager.sh`
**Version**: 2.0.0
**Purpose**: Comprehensive bash session management with unique session IDs, timeout handling, and cleanup

## Overview

The Session Manager module provides enterprise-grade bash command execution with proper resource management, preventing session conflicts and ensuring clean teardown of long-running operations.

## Key Features

✅ **Unique Session ID Generation** - Timestamp and random suffix for conflict-free sessions
✅ **Multiple Execution Modes** - Sync, async, and detached command execution
✅ **Timeout Management** - Configurable timeouts with recommended defaults
✅ **Automatic Cleanup** - Session tracking and cleanup on exit/interrupt
✅ **Process Management** - PID tracking for async operations
✅ **Helper Functions** - Convenience wrappers for npm and git commands

## Architecture

### Session ID Format
```
step{NN}_{operation}_{YYYYMMDD_HHMMSS}_{random6}
Example: step07_test_exec_20251113_193721_abc123
```

### Execution Modes

1. **Sync Mode** (default)
   - Waits for command completion
   - Enforces timeout
   - Immediate cleanup after completion
   - Use for: Short commands, validation, file operations

2. **Async Mode**
   - Runs in background with PID tracking
   - Allows checking status with `wait_for_session`
   - Manual cleanup required
   - Use for: Long-running builds, monitoring

3. **Detached Mode**
   - Completely independent process
   - No PID tracking
   - Logs to /tmp
   - Use for: Servers, daemons, persistent processes

## API Reference

### Session ID Management

#### `generate_session_id <step_num> <operation>`
Generates unique session identifier.

**Parameters:**
- `step_num`: Workflow step number (e.g., "07")
- `operation`: Operation name (e.g., "test_exec")

**Returns:** Session ID string

**Example:**
```bash
session_id=$(generate_session_id "07" "test_execution")
# Returns: step07_test_execution_20251113_193721_a1b2c3
```

#### `register_session <session_id> <description>`
Registers session for tracking and cleanup.

**Example:**
```bash
register_session "$session_id" "Running Jest test suite"
```

#### `unregister_session <session_id>`
Removes session from tracking.

### Command Execution

#### `execute_with_session <step_num> <operation> <command> [timeout] [mode]`
Executes command with full session management.

**Parameters:**
- `step_num`: Workflow step number
- `operation`: Operation name
- `command`: Shell command to execute
- `timeout`: Timeout in seconds (default: 30)
- `mode`: Execution mode: sync|async|detached (default: sync)

**Returns:** Command exit code

**Examples:**
```bash
# Sync execution with custom timeout
execute_with_session "07" "test_suite" "npm test" 300 "sync"

# Async execution for monitoring
execute_with_session "08" "build_watch" "npm run build:watch" 600 "async"

# Detached server
execute_with_session "09" "dev_server" "npm start" 0 "detached"
```

### Async Process Management

#### `wait_for_session <session_id> [timeout]`
Waits for async session to complete.

**Parameters:**
- `session_id`: Session identifier
- `timeout`: Maximum wait time in seconds (default: 60)

**Returns:** 0 on success, 1 on timeout or error

**Example:**
```bash
session_id=$(generate_session_id "08" "long_build")
execute_with_session "08" "long_build" "npm run build" 300 "async"

# Do other work...

wait_for_session "$session_id" 300
if [[ $? -eq 0 ]]; then
    echo "Build completed successfully"
fi
```

#### `kill_session <session_id>`
Forcefully terminates async session.

**Example:**
```bash
kill_session "$session_id"
```

### Cleanup

#### `cleanup_all_sessions`
Terminates all active sessions (automatic on exit/interrupt).

**Example:**
```bash
trap cleanup_all_sessions EXIT INT TERM
```

#### `list_active_sessions`
Displays all currently active sessions.

### Timeout Configuration

#### `get_recommended_timeout <operation_type>`
Returns recommended timeout for common operations.

**Operation Types:**
- `npm_test` → 300s (5 minutes)
- `npm_install` → 120s (2 minutes)
- `npm_build` → 180s (3 minutes)
- `git_operation` → 30s
- `file_operation` → 10s
- `validation` → 60s
- `ai_analysis` → 300s (5 minutes)
- `*` (default) → 30s

**Example:**
```bash
timeout=$(get_recommended_timeout "npm_test")
execute_with_session "07" "test" "npm test" "$timeout" "sync"
```

### Helper Functions

#### `execute_npm_command <step_num> <npm_command> [args...]`
Convenience wrapper for npm commands with auto-timeout.

**Example:**
```bash
execute_npm_command "07" "test" "--coverage"
# Automatically uses 300s timeout for npm_test
```

#### `execute_git_command <step_num> <git_args...>`
Convenience wrapper for git commands.

**Example:**
```bash
execute_git_command "11" "status --short"
execute_git_command "11" "add ."
```

## Usage Patterns

### Basic Workflow Step
```bash
#!/bin/bash
source "lib/session_manager.sh"

step7_run_tests() {
    print_step "7" "Execute Test Suite"

    # Use recommended timeout
    local timeout
    timeout=$(get_recommended_timeout "npm_test")

    # Execute with session management
    if execute_with_session "07" "test_suite" "npm test" "$timeout" "sync"; then
        print_success "Tests passed"
        return 0
    else
        print_error "Tests failed"
        return 1
    fi
}
```

### Long-Running Build
```bash
step8_build_project() {
    print_step "8" "Build Project"

    # Start async build
    local session_id
    session_id=$(generate_session_id "08" "build")
    register_session "$session_id" "Building project"

    execute_with_session "08" "build" "npm run build" 300 "async"

    # Do validation while building
    validate_configuration

    # Wait for build to complete
    if wait_for_session "$session_id" 300; then
        print_success "Build completed"
        return 0
    else
        print_error "Build failed or timed out"
        return 1
    fi
}
```

### Cleanup Integration
```bash
#!/bin/bash
source "lib/session_manager.sh"

# Register cleanup handler
trap cleanup_all_sessions EXIT INT TERM

main() {
    step1_validation
    step2_tests
    step3_deployment
}

main "$@"
```

## Testing

Comprehensive test suite: `test_session_manager.sh`

**Test Coverage:**
- ✅ Session ID generation and uniqueness
- ✅ Session registration and cleanup
- ✅ Sync/async/detached execution modes
- ✅ Timeout enforcement
- ✅ Process management
- ✅ Cleanup on exit
- ✅ Helper functions

**Run Tests:**
```bash
cd shell_scripts/workflow
bash test_session_manager.sh
```

**Test Results:**
- Total: 22 tests
- Pass Rate: 100%

## Integration with Workflow Automation

### Step Module Pattern
```bash
#!/bin/bash
# Step module using session manager

source "$(dirname "${BASH_SOURCE[0]}")/../lib/session_manager.sh"

step_execute() {
    local step_num="$1"

    # Use session manager for all commands
    execute_npm_command "$step_num" "install"
    execute_npm_command "$step_num" "test"
    execute_git_command "$step_num" "status"
}

export -f step_execute
```

### Enhanced Workflow Cleanup
```bash
# In main workflow script
source "lib/session_manager.sh"

# Register enhanced cleanup
trap enhanced_workflow_cleanup EXIT INT TERM

# All session cleanup happens automatically
```

## Best Practices

### ✅ Do's

1. **Always use unique sessions per operation**
   ```bash
   # Good
   execute_with_session "07" "unit_tests" "npm test" 300 "sync"
   execute_with_session "07" "lint_check" "npm run lint" 60 "sync"
   ```

2. **Use recommended timeouts**
   ```bash
   timeout=$(get_recommended_timeout "npm_test")
   execute_with_session "07" "test" "npm test" "$timeout" "sync"
   ```

3. **Register cleanup handlers**
   ```bash
   trap cleanup_all_sessions EXIT INT TERM
   ```

4. **Use helper functions for common operations**
   ```bash
   execute_npm_command "07" "test" "--coverage"
   execute_git_command "11" "add ."
   ```

### ❌ Don'ts

1. **Don't reuse session IDs**
   ```bash
   # Bad
   execute_with_session "07" "test1" "npm test" 300 "sync"
   execute_with_session "07" "test1" "npm test" 300 "sync"  # Same ID!
   ```

2. **Don't forget cleanup for async sessions**
   ```bash
   # Bad
   execute_with_session "08" "build" "npm run build" 300 "async"
   # ... no wait_for_session or cleanup
   ```

3. **Don't use arbitrary timeouts**
   ```bash
   # Bad
   execute_with_session "07" "test" "npm test" 999999 "sync"

   # Good
   timeout=$(get_recommended_timeout "npm_test")
   execute_with_session "07" "test" "npm test" "$timeout" "sync"
   ```

## Troubleshooting

### Session Conflicts
**Symptom:** "Session already exists" warnings
**Solution:** Use `generate_session_id` for automatic unique IDs

### Timeout Issues
**Symptom:** Commands timing out prematurely
**Solution:** Use `get_recommended_timeout` or increase timeout for specific operations

### Cleanup Not Running
**Symptom:** Active sessions left after script exit
**Solution:** Register trap handler:
```bash
trap cleanup_all_sessions EXIT INT TERM
```

### Async Session Lost
**Symptom:** Can't find async session
**Solution:** Save session ID and use `wait_for_session`:
```bash
session_id=$(generate_session_id "08" "build")
execute_with_session "08" "build" "npm run build" 300 "async"
wait_for_session "$session_id" 300
```

## Version History

**v2.0.0** (2025-11-13)
- Initial implementation
- Unique session ID generation
- Sync/async/detached execution modes
- Timeout management with recommendations
- Automatic cleanup and resource management
- Helper functions for npm and git
- Comprehensive test suite (22 tests, 100% pass rate)

## See Also

- [Workflow Automation README](../README.md)
- [Configuration Module](config.sh)
- [Utilities Module](utils.sh)
- [Test Suite](test_session_manager.sh)
