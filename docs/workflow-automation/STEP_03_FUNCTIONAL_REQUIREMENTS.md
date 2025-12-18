# Functional Requirements Document: Step 3 - Script Reference Validation

**Document Version:** 1.0.0
**Module Version:** 2.0.0
**Date:** December 15, 2025
**Status:** Active
**Author:** Automated Workflow System

---

## 1. Executive Summary

### 1.1 Purpose

This document defines the functional requirements for Step 3 of the Tests & Documentation Workflow Automation system. Step 3 is responsible for AI-powered script reference validation that ensures shell scripts are properly documented, executable, and correctly referenced in documentation.

### 1.2 Scope

The module provides automated and semi-automated script reference validation, leveraging GitHub Copilot CLI for intelligent analysis while maintaining comprehensive fallback mechanisms for automated detection.

### 1.3 Module Information

- **Module File:** `src/workflow/steps/step_03_script_refs.sh`
- **Module Version:** 2.0.0 (Major: 2, Minor: 0, Patch: 0)
- **Parent System:** Tests & Documentation Workflow Automation
- **Dependencies:** AI Helpers Library, File Operations Library, Step Execution Framework

---

## 2. System Overview

### 2.1 Architecture Context

Step 3 operates as a modular component within the workflow automation framework, integrating with:

- **AI Helpers Library** (`lib/ai_helpers.sh`) - Copilot CLI integration
- **File Operations Library** (`lib/file_operations.sh`) - Fast file discovery
- **Backlog System** - Issue tracking and reporting
- **Logging System** - Execution audit trail
- **Summary System** - Step completion reporting

### 2.2 Execution Flow

```text
Input: Shell Scripts → Reference Detection → Permission Check → Documentation Check → AI Analysis → Outputs
```

**Output Kinds:**

1. **Validation Report** - Script reference validation with detected issues
2. **Permission Issues** - Scripts missing executable permissions
3. **Documentation Gaps** - Undocumented scripts requiring documentation
4. **Backlog Issues** - Detected problems tracked for resolution

---

## 3. Functional Requirements

### FR-1: Version Management

#### FR-1.1 Version Information Storage

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL maintain version information in standardized module constants.

**Acceptance Criteria:**

- Define `STEP3_VERSION` constant with semantic version format
- Define `STEP3_VERSION_MAJOR` constant for major version
- Define `STEP3_VERSION_MINOR` constant for minor version
- Define `STEP3_VERSION_PATCH` constant for patch version
- Use `readonly` declarations for immutability

**Version Format:**

| Constant | Type | Example |
|----------|------|---------|
| `STEP3_VERSION` | String | `"2.0.0"` |
| `STEP3_VERSION_MAJOR` | Integer | `2` |
| `STEP3_VERSION_MINOR` | Integer | `0` |
| `STEP3_VERSION_PATCH` | Integer | `0` |

---

### FR-2: Script Reference Validation

#### FR-2.1 Documented Script Existence Check

**Priority:** Critical
**Status:** Implemented

**Requirement:**
The system SHALL validate that all scripts referenced in documentation actually exist in the repository.

**Acceptance Criteria:**

- Parse `shell_scripts/README.md` for script references
- Extract script paths using regex: `` `./shell_scripts/[^`]+\.sh` ``
- Verify file existence for each referenced script
- Report missing scripts with file paths
- Count total missing script references
- Save issues to temporary tracking file

**Reference Detection Pattern:**

```text
Input:  See `./shell_scripts/deploy_to_webserver.sh` for details
Extract: shell_scripts/deploy_to_webserver.sh
Validate: [[ -f "shell_scripts/deploy_to_webserver.sh" ]]
```

#### FR-2.2 Executable Permission Validation

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL verify that all shell scripts have executable permissions.

**Acceptance Criteria:**

- Discover all `.sh` files in `shell_scripts/` directory
- Use `fast_find()` with depth limit of 5
- Exclude `node_modules/` and `.git/` directories
- Check executable permission with `[[ -x "$file" ]]` test
- Report non-executable scripts with file paths
- Count total permission issues

**Permission Check Logic:**

```bash
# For each .sh file:
if [[ ! -x "$script" ]]; then
    # Report as non-executable
fi
```

#### FR-2.3 Script Inventory Generation

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL generate a comprehensive inventory of all shell scripts in the project.

**Acceptance Criteria:**

- Discover all `.sh` files recursively
- Sort script list alphabetically
- Count total scripts found
- Include in AI prompt context
- Use for undocumented script detection

#### FR-2.4 Undocumented Script Detection

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL identify scripts that exist in the repository but are not documented.

**Acceptance Criteria:**

- Compare script inventory against `shell_scripts/README.md` content
- Check if script basename appears anywhere in documentation
- Report undocumented scripts with full paths
- Count total undocumented scripts
- Save to issues tracking file

**Detection Algorithm:**

```bash
for script in all_scripts; do
    script_name=$(basename "$script")
    if ! grep -q "$script_name" "shell_scripts/README.md"; then
        # Report as undocumented
    fi
done
```

---

### FR-3: AI-Powered Analysis

#### FR-3.1 GitHub Copilot CLI Integration

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL generate and execute AI prompts for script reference validation using GitHub Copilot CLI.

**Acceptance Criteria:**

- Build validation prompt via `build_step3_script_refs_prompt()`
- Include script count in prompt context
- Include change scope from workflow
- Include detected issues summary
- Include complete script inventory
- Display prompt to user before execution
- Execute with logging to unique timestamped file

#### FR-3.2 AI Prompt Context Construction

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL construct comprehensive AI prompts with full repository and script context.

**Prompt Components:**

| Component | Source | Purpose |
|-----------|--------|---------|
| Script Count | `fast_find()` count | Scope quantification |
| Change Scope | `${CHANGE_SCOPE}` | Context from workflow |
| Issues Found | Automated checks | Detected problems |
| Issues Content | Issues file | Detailed problem list |
| Script Inventory | `fast_find()` sorted | Complete script list |

#### FR-3.3 AI Execution Logging

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL log all AI script validation sessions.

**Acceptance Criteria:**

- Generate log filename: `step3_copilot_script_validation_YYYYMMDD_HHMMSS_NNNNN.log`
- Store in workflow-specific directory: `${LOGS_RUN_DIR}/`
- Use 21-character precision timestamp
- Capture complete session output
- Extract and save issues from log file
- Display log file path to user

---

### FR-4: Issue Reporting and Tracking

#### FR-4.1 Automated Issue Detection

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL automatically detect and report script reference issues.

**Issue Categories:**

| Category | Detection Method | Severity |
|----------|------------------|----------|
| Missing References | File existence check | Critical |
| Non-Executable | Permission test | High |
| Undocumented | Documentation search | Medium |

**Acceptance Criteria:**

- Track issues in temporary file
- Count total issues detected
- Include in step results
- Pass to AI analysis for recommendations

#### FR-4.2 Issue Aggregation

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL aggregate all detected issues into a single tracking file.

**Acceptance Criteria:**

- Use temporary file via `mktemp`
- Register in `TEMP_FILES` array for cleanup
- Write one issue per line with category prefix
- Format: `Category: filepath`
- Examples:
  - `Missing script reference: shell_scripts/deleted.sh`
  - `Non-executable: shell_scripts/script.sh`
  - `Undocumented: shell_scripts/new_script.sh`

#### FR-4.3 Script Issue Reporting

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL create backlog reports for detected script reference issues and automatically save AI-generated analysis without user interaction.

**Acceptance Criteria:**

- Generate markdown report with timestamp
- List total script count
- List all missing script references with file paths
- List permission issues with affected scripts
- List undocumented scripts requiring documentation
- Provide recommended corrective actions
- Save to backlog directory with `Script_Reference_Validation` identifier
- **Automatically save AI-generated analysis to proper folder without user interaction**
- **Determine target folder based on issue type and severity**
- Display warning to user when issues found
- Display success when no issues found

**Report Structure:**

```markdown
## Script Reference Validation Issues
**Timestamp**: YYYY-MM-DD HH:MM:SS
**Total Scripts Checked**: N

### Missing Script References
⚠️  **BROKEN REFERENCE**: Documentation references non-existent script
   - Reference: shell_scripts/deleted_script.sh
   - Source: shell_scripts/README.md
   - Action: Remove reference or restore missing script

### Permission Issues
⚠️  **NON-EXECUTABLE**: Script lacks executable permission
   - Script: shell_scripts/script_name.sh
   - Action: Run `chmod +x shell_scripts/script_name.sh`

### Undocumented Scripts
⚠️  **MISSING DOCUMENTATION**: Script not documented in README
   - Script: shell_scripts/new_script.sh
   - Action: Add documentation to shell_scripts/README.md

### Recommended Actions
1. Remove or update broken script references in documentation
2. Fix executable permissions: `chmod +x [script_path]`
3. Document all scripts in shell_scripts/README.md
4. Re-run validation to verify all issues resolved
```

#### FR-4.4 Backlog Integration

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL integrate detected issues with workflow backlog system.

**Acceptance Criteria:**

- Extract issues from AI log via `extract_and_save_issues_from_log()`
- Use step identifier: `"Script_Reference_Validation"`
- Save to backlog directory with timestamp
- Include in workflow reporting

---

### FR-5: Execution Modes

#### FR-5.1 Interactive Mode

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL support interactive mode with user confirmations.

**Acceptance Criteria:**

- Prompt before running Copilot CLI: "Run GitHub Copilot CLI to validate script references?"
- Default to "Yes" for script validation (primary feature)
- Use `confirm_action()` with appropriate defaults
- Log user decisions to workflow log

#### FR-5.2 Automatic Mode

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL support automatic mode without user interaction.

**Acceptance Criteria:**

- Skip Copilot CLI prompts when `$AUTO_MODE == true`
- Use default behaviors for all decisions
- Execute automated checks unconditionally
- Log automatic mode execution
- Provide fallback analysis without AI

#### FR-5.3 Dry-Run Mode

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL support dry-run mode for operation preview.

**Acceptance Criteria:**

- Display intended actions without execution
- Skip Copilot CLI invocation
- Skip file modifications
- Display prompt that would be used
- Log dry-run actions with `[DRY RUN]` prefix
- Execute read-only validations (file checks, permission checks)

---

### FR-6: Output and Reporting

#### FR-6.1 Step Results Persistence

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL persist step results using standardized reporting functions.

**Acceptance Criteria:**

- Save via `save_step_results()` function with parameters:
  - Step number: `"3"`
  - Step name: `"Script_Reference_Validation"`
  - Issue count: Total detected issues
  - Success message: "All script references valid..."
  - Warning message: "Found N script reference issues..."
  - Data file: Script issues file
  - Context value: Total script count

#### FR-6.2 Workflow Status Update

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL update workflow status tracking upon completion.

**Acceptance Criteria:**

- Update via `update_workflow_status("step3", "✅")`
- Integrate with workflow-level status tracking
- Provide status for progress reporting
- Indicate successful completion

#### FR-6.3 User Feedback Messages

**Priority:** Medium
**Status:** Implemented

**Requirement:**
The system SHALL provide clear user feedback for each validation phase.

**Acceptance Criteria:**

- Display phase headers: "Phase 1: Automated script reference validation..."
- Display progress messages: "Checking executable permissions..."
- Display issue counts: "Found N undocumented scripts"
- Display success indicators: ✅ for passed checks
- Display warning indicators: ⚠️ for detected issues

---

### FR-7: Integration Requirements

#### FR-7.1 Library Dependencies

**Priority:** Critical
**Status:** Implemented

**Dependencies:**

| Library | Purpose | Required |
|---------|---------|----------|
| `lib/ai_helpers.sh` | Copilot CLI integration, prompt building | ✅ Yes |
| `lib/file_operations.sh` | Fast file discovery | ✅ Yes |
| `lib/backlog.sh` | Issue tracking and reporting | ✅ Yes |
| `lib/summary.sh` | Step summary generation | ✅ Yes |
| `lib/colors.sh` | Terminal output formatting | ✅ Yes |
| `lib/utils.sh` | Confirmation prompts, file operations | ✅ Yes |
| `lib/validation.sh` | Workflow status tracking | ✅ Yes |

#### FR-7.2 Function Exports

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL export functions for use by parent workflow and testing.

**Exported Functions:**

- `step3_validate_script_references` - Main step execution

---

### FR-8: Data Management

#### FR-8.1 Temporary File Management

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL manage temporary files with automatic cleanup.

**Temporary Files:**

| File | Purpose | Cleanup |
|------|---------|---------|
| `script_issues_file` | Issue tracking list | Via `TEMP_FILES` array |
| `temp_prompt_file` | AI prompt storage | Via `TEMP_FILES` array |

**Acceptance Criteria:**

- Create temporary files via `mktemp`
- Register in `TEMP_FILES` array immediately
- Cleanup handled by parent workflow
- Support multiple temporary files per step

#### FR-8.2 Script Issues Reporting

**Priority:** High
**Status:** Implemented

**Requirement:**
The system SHALL generate comprehensive script issue reports.

**Report Format:**

```text
Missing script reference: shell_scripts/deleted.sh
Non-executable: shell_scripts/script_without_exec.sh
Undocumented: shell_scripts/new_feature.sh
Undocumented: shell_scripts/utility.sh
```

**Acceptance Criteria:**

- One line per issue
- Format: `Category: filepath`
- Include in step results data file
- Display to user during execution
- Include in AI prompt context

---

## 4. Non-Functional Requirements

### NFR-1: Performance

**Requirement:** Step 3 SHALL complete automated checks within 30 seconds for typical repositories (excluding AI analysis time).

**Targets:**

- Script inventory generation: < 5 seconds
- Reference validation: < 5 seconds
- Permission checks: < 5 seconds
- Documentation checks: < 10 seconds

### NFR-2: Usability

**Requirement:** Output SHALL use color-coded messages with clear severity indicators.

**Color Scheme:**

- Success: Green (`✅`)
- Warning: Yellow (`⚠️`)
- Info: Cyan (`ℹ️`)
- Error: Red (`❌`)

### NFR-3: Maintainability

**Requirement:** Code SHALL follow modular architecture with single responsibility principle.

**Design Patterns:**

- Separated concerns: detection vs. reporting
- Reusable validation components
- Clear function naming conventions
- Comprehensive inline documentation

### NFR-4: Reliability

**Requirement:** System SHALL never fail workflow due to validation issues (graceful degradation).

**Behaviors:**

- Continue on missing references (report only)
- Continue on permission issues (report only)
- Continue on documentation gaps (report only)
- Return success with warnings

### NFR-5: Auditability

**Requirement:** All validation actions SHALL be logged with detailed context.

**Logged Information:**

- Script reference validation attempts and results
- Permission check details
- Documentation gap detection
- AI prompt execution and results

---

## 5. Data Requirements

### DR-1: Input Data

**Source:** File system and workflow context

**Data Elements:**

- All `.sh` files in `shell_scripts/` directory
- `shell_scripts/README.md` content
- Workflow change scope
- Script file permissions

### DR-2: Configuration Data

**Source:** Workflow automation configuration

**Data Elements:**

- `$PROJECT_ROOT` - Repository root directory
- `$LOGS_RUN_DIR` - Log file directory path
- `$INTERACTIVE_MODE` - User interaction flag
- `$AUTO_MODE` - Automatic execution flag
- `$DRY_RUN` - Dry-run mode flag
- `${CHANGE_SCOPE}` - Workflow change scope

### DR-3: Output Data

**Destinations:**

- Backlog directory: `${BACKLOG_RUN_DIR}/step3_*.md`
- Summaries directory: `${SUMMARIES_RUN_DIR}/step3_*.md`
- Logs directory: `${LOGS_RUN_DIR}/step3_*.log`

**Data Elements:**

- Script reference validation reports
- Permission issue lists
- Documentation gap reports
- AI session logs
- Issue extraction reports
- Step completion summaries

---

## 6. User Interaction Requirements

### UIR-1: Command-Line Output

**Requirement:** System SHALL provide clear, structured terminal output.

**Output Elements:**

- Step header: `Step 3: Validate Script References`
- Phase indicators: `Phase 1: Automated script reference validation...`
- Progress messages: `Checking executable permissions...`
- Results: Count of issues, successes, warnings
- AI prompt display in highlighted format

### UIR-2: User Confirmations

**Requirement:** System SHALL request user confirmation for AI analysis in interactive mode.

**Confirmation Point:**

- "Run GitHub Copilot CLI to validate script references?"
- Default: Yes (primary feature)
- Skippable in automatic mode

### UIR-3: Result Summaries

**Requirement:** System SHALL display concise result summaries after each validation phase.

**Summary Format:**

```text
✅ All referenced scripts exist
⚠️ Found 2 scripts without executable permissions
⚠️ Found 3 undocumented scripts
```

---

## 7. Integration Points

### IP-1: AI Helpers Library

**Functions Used:**

- `build_step3_script_refs_prompt()` - Generate script validation prompts
- `execute_copilot_prompt()` - Execute AI analysis
- `extract_and_save_issues_from_log()` - Parse AI output

### IP-2: File Operations Library

**Functions Used:**

- `fast_find()` - Efficient file discovery with exclusions

**Integration Pattern:**

```bash
fast_find "shell_scripts" "*.sh" 5 "node_modules" ".git"
```

### IP-3: Step Execution Framework

**Functions Used:**

- `print_step()` - Step header formatting
- `print_info()` - Informational messages
- `print_success()` - Success messages
- `print_warning()` - Warning messages
- `confirm_action()` - User confirmations
- `save_step_results()` - Result persistence
- `update_workflow_status()` - Status tracking

---

## 8. Testing Requirements

### TR-1: Unit Testing

**Requirements:**

- Test script reference extraction from documentation
- Test file existence validation
- Test permission checking logic
- Test undocumented script detection
- Test issue aggregation

**Test Cases:**

| Function | Test Case | Expected Result |
|----------|-----------|-----------------|
| Reference extraction | Parse README.md | Extract all script paths |
| Existence check | Missing script | Report as missing |
| Permission check | Non-executable | Report permission issue |
| Documentation check | Unlisted script | Report as undocumented |

### TR-2: Integration Testing

**Requirements:**

- Test with real shell_scripts directory
- Test with missing referenced scripts
- Test with non-executable scripts
- Test with undocumented scripts
- Test in all execution modes (interactive/auto/dry-run)

### TR-3: Edge Cases

**Requirements:**

- Empty shell_scripts directory
- No README.md documentation
- All scripts properly documented
- Scripts with special characters in names
- Symbolic links to scripts
- Scripts in nested subdirectories

---

## 9. Acceptance Criteria Summary

### Must Have (Priority: Critical/High)

✅ Script reference existence validation
✅ Executable permission checking
✅ Undocumented script detection
✅ Script inventory generation
✅ AI-powered validation analysis
✅ Comprehensive error handling
✅ Graceful degradation for optional features
✅ Issue tracking and reporting
✅ Workflow status integration

### Should Have (Priority: Medium)

✅ Dry-run mode support
✅ Script count statistics
✅ Detailed logging with timestamps
✅ Issue extraction from AI logs
✅ Temporary file management

### Could Have (Priority: Low)

✅ Repository statistics reporting
✅ Script categorization by function

---

## 10. Change History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-12-15 | Initial functional requirements document | Workflow System |

---

## 11. References

### Related Documentation

- `/src/workflow/README.md` - Workflow system overview
- `/docs/TESTS_DOCS_WORKFLOW_AUTOMATION_PLAN.md` - Workflow architecture
- `.github/copilot-instructions.md` - Project development guidelines
- `/docs/workflow-automation/STEP_01_FUNCTIONAL_REQUIREMENTS.md` - Step 1 requirements
- `/docs/workflow-automation/STEP_02_FUNCTIONAL_REQUIREMENTS.md` - Step 2 requirements

### Related Modules

- `step_01_documentation.sh` - Documentation updates
- `step_02_consistency.sh` - Documentation consistency analysis
- `step_04_directory.sh` - Directory structure validation
- `lib/file_operations.sh` - Fast file discovery library

---

## 12. Appendix

### A. Script Reference Detection Examples

**Documentation Pattern:**

```markdown
Use `./shell_scripts/deploy_to_webserver.sh` for production deployment.
Run `./shell_scripts/pull_all_submodules.sh` to update submodules.
```

**Extracted References:**

```text
shell_scripts/deploy_to_webserver.sh
shell_scripts/pull_all_submodules.sh
```

### B. Permission Check Examples

**Executable Script:**

```bash
-rwxr-xr-x  1 user group 1234 Dec 15 00:00 script.sh
# Result: ✅ Pass
```

**Non-Executable Script:**

```bash
-rw-r--r--  1 user group 1234 Dec 15 00:00 script.sh
# Result: ⚠️ Non-executable
```

### C. Sample AI Prompt Structure

```text
You are a Shell Script Documentation Specialist analyzing script
references and documentation accuracy.

TASK:
Review the following shell script inventory for documentation gaps,
broken references, and permission issues.

SCRIPT STATISTICS:
- Total Scripts: 23
- Change Scope: shell_scripts modifications
- Issues Found: 5

DETECTED ISSUES:
Missing script reference: shell_scripts/deleted.sh
Non-executable: shell_scripts/new_script.sh
Undocumented: shell_scripts/utility.sh

SCRIPT INVENTORY:
./shell_scripts/deploy_to_webserver.sh
./shell_scripts/pull_all_submodules.sh
./shell_scripts/sync_to_public.sh
...

VALIDATION TASKS:
1. Review missing script references and suggest documentation updates
2. Identify permission issues requiring fixing
3. Recommend documentation for undocumented scripts
4. Validate script organization and naming conventions
```

### D. Sample Step Results Report

**Script Issues File Content:**

```text
Missing script reference: shell_scripts/old_deploy.sh
Non-executable: shell_scripts/new_feature.sh
Undocumented: shell_scripts/utility_helper.sh
Undocumented: shell_scripts/backup_script.sh
```

**Step Summary:**

```markdown
### Script Reference Validation Summary

**Scripts Checked:** 23
**Reference Issues:** 1
**Permission Issues:** 1
**Documentation Gaps:** 2
**Status:** ⚠️ Issues Detected

Automated checks identified 4 total issues requiring attention.
Review missing references, fix permissions, and document new scripts.
```

---

**Document Status:** ✅ Complete
**Last Review:** December 15, 2025
**Next Review:** Upon module version update or architectural changes
