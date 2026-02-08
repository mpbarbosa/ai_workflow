# IDE Setup Guide - VS Code

**Version**: v4.0.0  
**Last Updated**: 2026-02-08  
**IDE**: Visual Studio Code  
**Related Documentation**: [Developer Onboarding](../developer-guide/DEVELOPER_ONBOARDING_GUIDE.md), [Development Setup](../developer-guide/development-setup.md)

## Overview

This guide provides step-by-step instructions for setting up Visual Studio Code (VS Code) for developing with the AI Workflow Automation project. It includes task configuration, debugging setup, recommended extensions, and productivity tips.

## Table of Contents

1. [Quick Setup](#quick-setup)
2. [VS Code Tasks](#vs-code-tasks)
3. [Debugging Configuration](#debugging-configuration)
4. [Recommended Extensions](#recommended-extensions)
5. [Workspace Settings](#workspace-settings)
6. [Keyboard Shortcuts](#keyboard-shortcuts)
7. [Productivity Tips](#productivity-tips)

---

## Quick Setup

### Prerequisites

```bash
# 1. Install VS Code
# Download from: https://code.visualstudio.com/

# 2. Verify prerequisites
./src/workflow/lib/health_check.sh

# 3. Open project in VS Code
code /path/to/ai_workflow
```

### Automatic Configuration

The project includes pre-configured VS Code tasks in `.vscode/tasks.json`:

```bash
# Tasks are automatically available when you open the workspace
# Access via: Terminal > Run Task... (or Ctrl+Shift+B)
```

**Available Tasks** (v2.6.0):
- ✅ AI Workflow: Full Run (with optimizations)
- ✅ AI Workflow: Documentation Only (~3-4 min)
- ✅ AI Workflow: Test Only (~8-10 min)
- ✅ AI Workflow: Feature Development (~15-20 min)
- ✅ AI Workflow: Auto-commit
- ✅ AI Workflow: Metrics Dashboard

---

## VS Code Tasks

### Using Built-in Tasks

#### Method 1: Command Palette
```
1. Press Ctrl+Shift+P (Windows/Linux) or Cmd+Shift+P (macOS)
2. Type "Tasks: Run Task"
3. Select from available tasks
```

#### Method 2: Keyboard Shortcut
```
1. Press Ctrl+Shift+B (default build task)
   - Runs "AI Workflow: Full Run" with optimizations
```

#### Method 3: Terminal Menu
```
1. Click Terminal > Run Task...
2. Select task from list
```

### Task Details

#### 1. AI Workflow: Full Run (Default)
```json
{
  "label": "AI Workflow: Full Run",
  "command": "./src/workflow/execute_tests_docs_workflow.sh",
  "args": ["--smart-execution", "--parallel"]
}
```

**When to use**: Complete validation with optimization (recommended for most cases)

**Duration**: 10-15 minutes (varies with changes)

**Keyboard**: `Ctrl+Shift+B`

---

#### 2. AI Workflow: Documentation Only
```json
{
  "label": "AI Workflow: Documentation Only",
  "command": "./templates/workflows/docs-only.sh"
}
```

**When to use**: Documentation-only changes (fastest workflow)

**Duration**: 3-4 minutes

**Steps executed**: 0, 2, 12 (analyze, documentation_updates, git_finalization)

---

#### 3. AI Workflow: Test Only
```json
{
  "label": "AI Workflow: Test Only",
  "command": "./templates/workflows/test-only.sh"
}
```

**When to use**: Test development and validation

**Duration**: 8-10 minutes

**Steps executed**: 0, 6, 7, 12 (analyze, test_review, test_execution, git_finalization)

---

#### 4. AI Workflow: Feature Development
```json
{
  "label": "AI Workflow: Feature Development",
  "command": "./templates/workflows/feature.sh"
}
```

**When to use**: Full feature development with comprehensive validation

**Duration**: 15-20 minutes

**Steps executed**: All 18 steps (0-15 + 0a, 0b)

---

#### 5. AI Workflow: Auto-commit
```json
{
  "label": "AI Workflow: Auto-commit",
  "command": "./src/workflow/execute_tests_docs_workflow.sh",
  "args": ["--smart-execution", "--parallel", "--auto-commit"]
}
```

**When to use**: Automatic commit of workflow artifacts after execution

**Duration**: 10-15 minutes + commit time

**Note**: Generates commit messages automatically

---

#### 6. AI Workflow: Metrics Dashboard
```json
{
  "label": "AI Workflow: Metrics Dashboard",
  "command": "./tools/metrics_dashboard.sh"
}
```

**When to use**: View workflow performance metrics and historical data

**Duration**: < 1 second

---

### Creating Custom Tasks

Edit `.vscode/tasks.json` to add custom tasks:

```json
{
  "label": "AI Workflow: Custom - Steps 2,5,7",
  "type": "shell",
  "command": "${workspaceFolder}/src/workflow/execute_tests_docs_workflow.sh",
  "args": [
    "--steps",
    "documentation_updates,code_review,test_execution"
  ],
  "group": "build",
  "presentation": {
    "reveal": "always",
    "panel": "dedicated"
  },
  "detail": "Run specific workflow steps (v4.0.0 name-based syntax)"
}
```

**Task Configuration Options**:

| Option | Values | Description |
|--------|--------|-------------|
| `reveal` | `always`, `silent`, `never` | When to show terminal |
| `panel` | `shared`, `dedicated`, `new` | Terminal panel behavior |
| `group` | `build`, `test`, `none` | Task category |
| `isDefault` | `true`, `false` | Default build task (Ctrl+Shift+B) |

---

## Debugging Configuration

### Launch Configuration

Create `.vscode/launch.json` for debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Workflow Step",
      "type": "bashdb",
      "request": "launch",
      "program": "${workspaceFolder}/src/workflow/execute_tests_docs_workflow.sh",
      "args": [
        "--steps",
        "analyze",
        "--verbose"
      ],
      "cwd": "${workspaceFolder}",
      "internalConsoleOptions": "openOnSessionStart"
    },
    {
      "name": "Debug Step Module",
      "type": "bashdb",
      "request": "launch",
      "program": "${workspaceFolder}/src/workflow/steps/documentation_updates.sh",
      "cwd": "${workspaceFolder}",
      "env": {
        "WORKFLOW_DEBUG": "1"
      }
    }
  ]
}
```

**Prerequisite**: Install Bash Debug extension (see [Recommended Extensions](#recommended-extensions))

### Debugging Steps

1. **Set Breakpoints**
   - Open a `.sh` file in VS Code
   - Click in the gutter (left of line numbers)
   - Red dot appears indicating breakpoint

2. **Start Debugging**
   - Press `F5` or click Run > Start Debugging
   - Select debug configuration

3. **Debug Controls**
   - `F5`: Continue
   - `F10`: Step Over
   - `F11`: Step Into
   - `Shift+F11`: Step Out
   - `Shift+F5`: Stop

4. **Inspect Variables**
   - View in Debug sidebar (Variables section)
   - Hover over variables in code
   - Use Debug Console for evaluations

### Debug Console Commands

```bash
# Print variable value
echo $WORKFLOW_DIR

# Execute command
ls -la logs/

# Check function definition
declare -f analyze_changes
```

---

## Recommended Extensions

### Essential Extensions

#### 1. **Bash Debug** (rogalmic.bash-debug)
```
Purpose: Debug Bash scripts with breakpoints
Install: Ctrl+Shift+X, search "Bash Debug"
```

#### 2. **ShellCheck** (timonwong.shellcheck)
```
Purpose: Linting for shell scripts
Install: Ctrl+Shift+X, search "ShellCheck"
Config: Automatically detects issues in .sh files
```

#### 3. **Bash IDE** (mads-hartmann.bash-ide-vscode)
```
Purpose: IntelliSense, formatting, code navigation
Install: Ctrl+Shift+X, search "Bash IDE"
Features:
  - Function definitions
  - Variable completion
  - Command descriptions
```

#### 4. **YAML** (redhat.vscode-yaml)
```
Purpose: YAML syntax highlighting and validation
Install: Ctrl+Shift+X, search "YAML"
Config: Validates .workflow_core/config/*.yaml
```

### Optional Extensions

#### 5. **Markdown All in One** (yzhang.markdown-all-in-one)
```
Purpose: Enhanced markdown editing
Features: TOC generation, preview, shortcuts
```

#### 6. **GitLens** (eamodio.gitlens)
```
Purpose: Advanced Git integration
Features: Blame, history, diff, commit graph
```

#### 7. **Code Spell Checker** (streetsidesoftware.code-spell-checker)
```
Purpose: Spell checking for code and comments
Config: Add project-specific words to dictionary
```

#### 8. **Todo Tree** (gruntfuggly.todo-tree)
```
Purpose: Highlight TODO, FIXME, NOTE in code
Config: Custom tags for workflow steps
```

### Extension Installation

```bash
# Install via command line
code --install-extension rogalmic.bash-debug
code --install-extension timonwong.shellcheck
code --install-extension mads-hartmann.bash-ide-vscode
code --install-extension redhat.vscode-yaml
```

---

## Workspace Settings

Create `.vscode/settings.json` for project-specific settings:

```json
{
  // Shell Script Settings
  "shellcheck.enable": true,
  "shellcheck.executablePath": "/usr/bin/shellcheck",
  "shellcheck.run": "onType",
  "shellcheck.exclude": [],
  
  // Bash IDE Settings
  "bashIde.globPattern": "**/*.{sh,bash}",
  "bashIde.backgroundAnalysisMaxFiles": 500,
  
  // Editor Settings
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.trimAutoWhitespace": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  
  // File Associations
  "files.associations": {
    "*.sh": "shellscript",
    ".workflow-config.yaml": "yaml",
    "*.yaml": "yaml"
  },
  
  // Search Exclusions (for better performance)
  "search.exclude": {
    "**/node_modules": true,
    "**/logs": true,
    "**/backlog": true,
    "**/.ai_cache": true,
    "**/test-results": true
  },
  
  // File Watcher Exclusions
  "files.watcherExclude": {
    "**/logs/**": true,
    "**/backlog/**": true,
    "**/.ai_cache/**": true,
    "**/metrics/**": true
  },
  
  // Terminal Settings
  "terminal.integrated.cwd": "${workspaceFolder}",
  "terminal.integrated.scrollback": 10000,
  
  // Git Settings
  "git.ignoreLimitWarning": true,
  "git.autofetch": true,
  
  // Markdown Settings
  "markdown.preview.fontSize": 14,
  "markdown.preview.lineHeight": 1.6,
  
  // TODO Highlighting (if Todo Tree extension installed)
  "todo-tree.general.tags": [
    "TODO",
    "FIXME",
    "NOTE",
    "HACK",
    "STEP"
  ],
  "todo-tree.highlights.defaultHighlight": {
    "foreground": "yellow"
  }
}
```

### ShellCheck Configuration

Create `.shellcheckrc` in project root:

```bash
# Disable warnings for specific codes
# SC1090: Can't follow non-constant source
disable=SC1090

# SC2034: Variable appears unused
disable=SC2034

# SC2155: Declare and assign separately
disable=SC2155

# Enable optional checks
enable=all
```

---

## Keyboard Shortcuts

### Custom Shortcuts for AI Workflow

Add to `keybindings.json` (Ctrl+K Ctrl+S, then click "Open Keyboard Shortcuts (JSON)"):

```json
[
  {
    "key": "ctrl+alt+w",
    "command": "workbench.action.tasks.runTask",
    "args": "AI Workflow: Full Run"
  },
  {
    "key": "ctrl+alt+d",
    "command": "workbench.action.tasks.runTask",
    "args": "AI Workflow: Documentation Only"
  },
  {
    "key": "ctrl+alt+t",
    "command": "workbench.action.tasks.runTask",
    "args": "AI Workflow: Test Only"
  },
  {
    "key": "ctrl+alt+m",
    "command": "workbench.action.tasks.runTask",
    "args": "AI Workflow: Metrics Dashboard"
  }
]
```

### Essential VS Code Shortcuts

| Shortcut | Action | Use Case |
|----------|--------|----------|
| `Ctrl+Shift+B` | Run Build Task | Run default workflow (Full Run) |
| `Ctrl+Shift+P` | Command Palette | Access all commands |
| `Ctrl+P` | Quick Open | Open files by name |
| `Ctrl+Shift+F` | Find in Files | Search across project |
| `Ctrl+G` | Go to Line | Jump to specific line |
| `F12` | Go to Definition | Navigate to function definition |
| `Ctrl+F12` | Go to Implementation | Navigate to implementation |
| `Shift+F12` | Find References | Find all usages |
| `F2` | Rename Symbol | Rename variable/function |
| `Ctrl+/` | Toggle Comment | Comment/uncomment lines |
| `` Ctrl+` `` | Toggle Terminal | Show/hide integrated terminal |
| `Ctrl+K Ctrl+S` | Keyboard Shortcuts | View/edit shortcuts |

---

## Productivity Tips

### 1. Multi-root Workspace

If working with multiple projects:

```json
// ai_workflow.code-workspace
{
  "folders": [
    {"path": "ai_workflow"},
    {"path": "../target_project"}
  ],
  "settings": {
    "terminal.integrated.cwd": "${workspaceFolder:ai_workflow}"
  }
}
```

Open workspace: `File > Open Workspace from File...`

---

### 2. Task Input Variables

Use VS Code variables in task arguments:

```json
{
  "label": "AI Workflow: Current File Step",
  "command": "./src/workflow/execute_tests_docs_workflow.sh",
  "args": [
    "--steps",
    "${input:stepName}"
  ],
  "inputs": [
    {
      "id": "stepName",
      "type": "promptString",
      "description": "Enter step name (e.g., documentation_updates)"
    }
  ]
}
```

---

### 3. Terminal Profiles

Configure shell profiles in `settings.json`:

```json
{
  "terminal.integrated.profiles.linux": {
    "Workflow Bash": {
      "path": "/bin/bash",
      "args": ["-l"],
      "env": {
        "WORKFLOW_DIR": "${workspaceFolder}/src/workflow",
        "WORKFLOW_DEBUG": "0"
      }
    }
  },
  "terminal.integrated.defaultProfile.linux": "Workflow Bash"
}
```

---

### 4. Code Snippets

Create `.vscode/bash.code-snippets` for reusable code:

```json
{
  "AI Workflow Function": {
    "prefix": "wf-func",
    "body": [
      "# ${1:Function description}",
      "# Arguments:",
      "#   $$1: ${2:param1_description}",
      "# Returns:",
      "#   0 on success, 1 on failure",
      "function ${3:function_name}() {",
      "  local ${2:param1}=\"\\$1\"",
      "  ",
      "  ${0:# Implementation}",
      "  ",
      "  return 0",
      "}"
    ],
    "description": "Create workflow function with documentation"
  },
  "Source Library": {
    "prefix": "wf-source",
    "body": [
      "# Source library module",
      "source \"\\$(dirname \"\\$0\")/lib/${1:module_name}.sh\""
    ]
  }
}
```

**Usage**: Type `wf-func` and press Tab

---

### 5. Workspace-Specific Search

Configure search patterns for workflow artifacts:

```json
// settings.json
{
  "search.quickOpen.includeSymbols": true,
  "search.quickOpen.includeHistory": true,
  
  // Custom search patterns
  "search.exclude": {
    "**/logs/**": true,
    "**/backlog/**": true,
    "**/.ai_cache/**": true
  },
  
  // Search only workflow steps
  "search.useGlobalIgnoreFiles": false
}
```

**Quick searches**:
- `Ctrl+T`: Search symbols (functions)
- `Ctrl+P` then `#`: Search symbols in current file
- `Ctrl+Shift+F`: Search with pattern (e.g., `function.*analyze`)

---

### 6. Git Integration Tips

```json
// settings.json
{
  "git.enableCommitSigning": true,
  "git.confirmSync": false,
  "git.autofetch": true,
  "git.pruneOnFetch": true,
  
  // Show git changes inline
  "diffEditor.renderSideBySide": true,
  "diffEditor.ignoreTrimWhitespace": false,
  
  // Source control sidebar
  "scm.defaultViewMode": "tree",
  "scm.alwaysShowProviders": true
}
```

**Useful Git commands in VS Code**:
- `Ctrl+Shift+G`: Open Source Control
- `Ctrl+Enter`: Commit with message
- Right-click file > Open Changes: View diff

---

### 7. Task Output Parsing

Configure problem matchers to highlight errors:

```json
{
  "label": "AI Workflow: Full Run",
  "command": "./src/workflow/execute_tests_docs_workflow.sh",
  "problemMatcher": {
    "owner": "workflow",
    "pattern": {
      "regexp": "^\\[ERROR\\]\\s+(.*):(\\d+):\\s+(.*)$",
      "file": 1,
      "line": 2,
      "message": 3
    }
  }
}
```

Errors appear in Problems panel (`Ctrl+Shift+M`)

---

### 8. Integrated Terminal Tips

```bash
# Open terminal in specific directory
Ctrl+` (then cd to src/workflow/)

# Split terminal
Ctrl+Shift+5

# Clear terminal
Ctrl+K (or type 'clear')

# Search terminal history
Ctrl+F (in terminal)

# Copy terminal output
Select text, then Ctrl+C
```

---

### 9. File Navigation

```bash
# Quick file navigation
Ctrl+P: Type filename (fuzzy search)

# Navigate to symbol
Ctrl+Shift+O: Show functions in current file

# Navigate to workspace symbol
Ctrl+T: Search all functions in workspace

# Go to definition
F12: Jump to function definition

# Peek definition
Alt+F12: View definition inline
```

---

### 10. Markdown Preview

```bash
# Preview markdown files
Ctrl+Shift+V: Open preview
Ctrl+K V: Open preview side-by-side

# Scroll sync
Preview follows editor cursor automatically
```

---

## Troubleshooting VS Code Setup

### Issue: Tasks Not Showing Up

**Solution**:
```bash
# 1. Reload VS Code window
Ctrl+Shift+P > "Developer: Reload Window"

# 2. Verify tasks.json exists
ls -la .vscode/tasks.json

# 3. Check tasks.json syntax
jq '.' .vscode/tasks.json
```

---

### Issue: ShellCheck Not Working

**Solution**:
```bash
# 1. Install ShellCheck
sudo apt install shellcheck  # Linux
brew install shellcheck      # macOS

# 2. Configure extension
# Open Settings (Ctrl+,)
# Search "shellcheck"
# Set executable path: /usr/bin/shellcheck

# 3. Verify installation
shellcheck --version
```

---

### Issue: Bash Debug Not Working

**Solution**:
```bash
# 1. Install bashdb
sudo apt install bashdb  # Linux
brew install bashdb      # macOS

# 2. Configure launch.json
# Verify "type": "bashdb"

# 3. Test manually
bashdb --version
```

---

### Issue: Terminal Not Opening in Project Root

**Solution**:
```json
// settings.json
{
  "terminal.integrated.cwd": "${workspaceFolder}"
}
```

---

## Advanced Configuration

### Custom Task for Dry-Run

```json
{
  "label": "AI Workflow: Dry-Run (No Changes)",
  "command": "${workspaceFolder}/src/workflow/execute_tests_docs_workflow.sh",
  "args": ["--dry-run"],
  "presentation": {
    "reveal": "always",
    "echo": true,
    "focus": false,
    "panel": "shared"
  },
  "problemMatcher": []
}
```

---

### Task Dependencies

Run multiple tasks in sequence:

```json
{
  "label": "AI Workflow: Test + Commit",
  "dependsOn": [
    "AI Workflow: Test Only",
    "Git: Commit and Push"
  ],
  "dependsOrder": "sequence"
}
```

---

### Environment Variables in Tasks

```json
{
  "label": "AI Workflow: Debug Mode",
  "command": "${workspaceFolder}/src/workflow/execute_tests_docs_workflow.sh",
  "options": {
    "env": {
      "WORKFLOW_DEBUG": "1",
      "AI_DEBUG": "1"
    }
  }
}
```

---

## Related Documentation

- **[Developer Onboarding Guide](../developer-guide/DEVELOPER_ONBOARDING_GUIDE.md)** - Getting started
- **[Development Setup](../developer-guide/development-setup.md)** - Prerequisites
- **[Debugging Workflows](DEBUGGING_WORKFLOWS.md)** - Debugging techniques
- **[Command Line Reference](../user-guide/COMMAND_LINE_REFERENCE.md)** - CLI options
- **[Workflow Templates](../../templates/workflows/)** - Pre-configured workflows

---

## Additional Resources

- **VS Code Docs**: https://code.visualstudio.com/docs
- **VS Code Tasks**: https://code.visualstudio.com/docs/editor/tasks
- **Bash IDE**: https://marketplace.visualstudio.com/items?itemName=mads-hartmann.bash-ide-vscode
- **ShellCheck**: https://www.shellcheck.net/

---

**Version History**:
- v4.0.0 (2026-02-08): Initial IDE setup guide
