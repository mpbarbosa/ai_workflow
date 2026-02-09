# Functional Requirements: AI Batch Mode Commit Message Generation

**Feature ID**: WF-2025-001  
**Version**: 1.0.0  
**Status**: Draft  
**Created**: 2025-12-31  
**Author**: AI Workflow Automation Team  
**Target Release**: v2.7.0

---

## Executive Summary

Enhance Step 11 (Git Finalization) to generate AI-powered commit messages in `--ai-batch` mode instead of using default conventional commit messages. This will provide high-quality, context-aware commit messages even in automated/non-interactive workflows.

### Current Behavior (v2.6.1)
- **Interactive Mode**: Prompts user to paste AI-generated commit message ✅
- **Auto Mode (`--auto`)**: Uses generic default commit message ⚠️
- **AI Batch Mode (`--ai-batch`)**: Uses generic default commit message ⚠️

### Target Behavior (v2.7.0)
- **Interactive Mode**: Prompts user to paste AI-generated commit message ✅ (no change)
- **Auto Mode (`--auto`)**: Uses generic default commit message ✅ (no change)
- **AI Batch Mode (`--ai-batch`)**: **Generates AI commit message automatically** ⭐ NEW

---

## Problem Statement

### Current Limitation
When running workflows with `--ai-batch` flag (intended for CI/CD, automated runs, or unattended execution), Step 11 falls back to a generic default commit message:

```
docs(documentation): update tests and documentation

Workflow automation completed comprehensive validation and updates.

Changes:
- Modified files: 5
- Documentation: 5 files
- Tests: 0 files  
- Scripts: 0 files
- Code: 0 files

Scope: General updates
Total changes: 5 files

[workflow-automation v2.6.1]
```

**Issues with this approach**:
1. ❌ **Generic and non-descriptive** - doesn't explain what was actually changed
2. ❌ **Poor commit history** - makes git log difficult to navigate
3. ❌ **Defeats AI-powered workflow purpose** - the workflow uses AI for everything except the final commit
4. ❌ **CI/CD unfriendly** - automated commits should be informative, not generic

### Business Impact
- **Developer Experience**: Poor commit messages reduce team productivity
- **Code Review**: Reviewers can't understand changes from commit messages alone
- **Compliance**: Some organizations require detailed commit messages for audit trails
- **Project Health**: Git history becomes cluttered with uninformative messages

---

## Proposed Solution

### High-Level Approach

Enable AI-powered commit message generation in `--ai-batch` mode using **non-interactive AI invocation** via GitHub Copilot CLI's batch capabilities.

**Key Principle**: Use Copilot CLI's ability to generate output without user interaction by:
1. Providing comprehensive git context as input
2. Requesting structured commit message as output
3. Capturing the AI response programmatically
4. Using the generated message for commit

---

## Functional Requirements

### FR-001: AI Batch Mode Detection
**Priority**: Must Have  
**Description**: Step 11 must detect when `AI_BATCH_MODE=true` and route to batch AI generation.

**Acceptance Criteria**:
- [ ] Check `${AI_BATCH_MODE:-false}` flag in Step 11
- [ ] When true, invoke batch AI commit message generation
- [ ] When false, maintain current behavior (interactive or default)

---

### FR-002: Non-Interactive AI Invocation
**Priority**: Must Have  
**Description**: Generate AI commit message without requiring user interaction.

**Acceptance Criteria**:
- [ ] Use Copilot CLI in non-interactive mode (if available)
- [ ] Provide comprehensive git context as input
- [ ] Capture AI-generated commit message programmatically
- [ ] Handle AI generation failures gracefully

**Technical Approach Options**:

#### Option A: Copilot CLI with Piped Input (Recommended)
```bash
# Use echo to pipe prompt to copilot
echo "$prompt" | copilot -p "$persona" > "$output_file" 2>&1
```

#### Option B: Copilot CLI with Heredoc
```bash
copilot -p "$persona" << EOF > "$output_file"
$prompt
EOF
```

#### Option C: Temporary Prompt File
```bash
echo "$prompt" > "$temp_prompt"
copilot -p "$persona" < "$temp_prompt" > "$output_file"
```

**Recommended**: Option A (simplest, most reliable)

---

### FR-003: Git Context Assembly
**Priority**: Must Have  
**Description**: Build comprehensive git context for AI to generate meaningful commit messages.

**Required Context Elements**:
- [ ] **Repository State**: branch, commits ahead/behind
- [ ] **Change Statistics**: modified, added, deleted, renamed files
- [ ] **File Categorization**: docs, tests, code, scripts, config
- [ ] **Diff Summary**: insertions, deletions, changed lines
- [ ] **Diff Sample**: First 200 lines of unified diff
- [ ] **Commit Type Inference**: feat, fix, docs, chore, test, refactor
- [ ] **Commit Scope**: component/module affected
- [ ] **Changed Files List**: Top 50 files with status

**Context Format**:
```
Generate a conventional commit message for these changes:

Repository: <project-name>
Branch: <branch-name>
Changes: <total> files (<modified> modified, <added> added, <deleted> deleted)
Type: <inferred-type> (<inferred-scope>)

Changed Files:
<file-list>

Diff Summary: <insertions>+, <deletions>-

Sample Changes:
<diff-sample>

Requirements:
- Follow Conventional Commits specification
- Include descriptive subject line (max 72 chars)
- Add detailed body explaining what and why
- List key changes as bullet points
- Reference related files/modules
```

---

### FR-004: AI Prompt Engineering
**Priority**: Must Have  
**Description**: Craft effective prompts for consistent, high-quality commit messages.

**Prompt Requirements**:
- [ ] Request conventional commit format explicitly
- [ ] Specify max subject line length (72 chars)
- [ ] Request body with bullet points for key changes
- [ ] Request focus on "what changed" and "why"
- [ ] Exclude implementation details unless critical
- [ ] Request professional, clear language

**Persona**: `git_workflow_specialist` (already exists in ai_helpers.yaml)

---

### FR-005: AI Response Parsing
**Priority**: Must Have  
**Description**: Extract clean commit message from AI response.

**Acceptance Criteria**:
- [ ] Remove AI conversational wrapper (e.g., "Here's a commit message:")
- [ ] Extract only the commit message content
- [ ] Preserve multi-line formatting
- [ ] Handle code blocks (```text ... ```)
- [ ] Trim leading/trailing whitespace
- [ ] Validate conventional commit format

**Parsing Strategy**:
```bash
# Remove common AI response wrappers
ai_response=$(cat "$ai_output_file")
commit_msg=$(echo "$ai_response" | \
    sed '/^Here/d; /^I.*generated/d; /^```/d' | \
    sed '/^$/d' | \
    awk '/^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)/{flag=1} flag')
```

---

### FR-006: Fallback Mechanisms
**Priority**: Must Have  
**Description**: Handle AI generation failures gracefully.

**Fallback Sequence**:
1. **Primary**: AI-generated commit message
2. **Fallback 1**: Enhanced default message with full context
3. **Fallback 2**: Current generic default message

**Failure Scenarios**:
- [ ] Copilot CLI not available → Log warning, use Fallback 1
- [ ] AI generation times out (30s) → Use Fallback 1
- [ ] AI response empty or unparseable → Use Fallback 1
- [ ] AI response doesn't follow format → Use Fallback 1

**Enhanced Fallback Message** (new):
```
<type>(<scope>): <inferred-summary>

Automated workflow execution completed with <change-count> changes.

Key Changes:
- <top-changed-file-1>
- <top-changed-file-2>
- <top-changed-file-3>

Categories:
- Documentation: <doc-count> files
- Tests: <test-count> files
- Code: <code-count> files

Diff: +<insertions> -<deletions>

[workflow-automation v<version> - batch mode]
```

---

### FR-007: Performance Requirements
**Priority**: Should Have  
**Description**: AI generation must not significantly slow down workflow execution.

**Performance Targets**:
- [ ] AI generation completes within 30 seconds (95th percentile)
- [ ] Timeout after 45 seconds, use fallback
- [ ] Cache AI prompt construction (reuse across runs if possible)
- [ ] Log generation time for monitoring

---

### FR-008: Logging and Observability
**Priority**: Should Have  
**Description**: Comprehensive logging for debugging and monitoring.

**Logging Requirements**:
- [ ] Log when AI batch mode is activated
- [ ] Log AI prompt sent to Copilot CLI
- [ ] Log raw AI response
- [ ] Log parsed commit message
- [ ] Log generation duration
- [ ] Log fallback usage
- [ ] Save full session to `${PROMPTS_RUN_DIR}/step11_batch_commit_<timestamp>.log`

**Log Format**:
```
[2025-12-31 10:30:15] [INFO] AI Batch Mode: Generating commit message
[2025-12-31 10:30:15] [DEBUG] Prompt length: 1250 chars
[2025-12-31 10:30:15] [DEBUG] Using persona: git_workflow_specialist
[2025-12-31 10:30:28] [INFO] AI response received (13s)
[2025-12-31 10:30:28] [DEBUG] Response length: 450 chars
[2025-12-31 10:30:28] [INFO] Commit message parsed successfully
[2025-12-31 10:30:28] [SUCCESS] Using AI-generated commit message
```

---

### FR-009: Configuration and Control
**Priority**: Should Have  
**Description**: Allow users to control batch AI generation behavior.

**Configuration Options** (via `.workflow-config.yaml`):
```yaml
git_finalization:
  batch_mode:
    ai_generation: true          # Enable/disable AI in batch mode
    generation_timeout: 30       # Timeout in seconds
    fallback_strategy: enhanced  # 'enhanced' or 'simple'
    save_prompt: true            # Save prompt to logs
    save_response: true          # Save full response to logs
```

**Command-Line Override**:
```bash
# Disable AI generation in batch mode
./execute_tests_docs_workflow.sh --ai-batch --no-batch-ai-commit

# Use simple fallback instead of enhanced
./execute_tests_docs_workflow.sh --ai-batch --simple-commit-fallback
```

---

### FR-010: Backward Compatibility
**Priority**: Must Have  
**Description**: Ensure existing workflows continue to function.

**Compatibility Requirements**:
- [ ] Interactive mode behavior unchanged
- [ ] Auto mode behavior unchanged (uses default message)
- [ ] Existing `--ai-batch` workflows continue to work
- [ ] New feature is opt-in via configuration (default: enabled)
- [ ] Fallback to current behavior if AI generation fails

---

## Non-Functional Requirements

### NFR-001: Security
- **Requirement**: AI prompts must not expose sensitive information
- **Implementation**: 
  - Filter diff content for secrets (API keys, tokens, passwords)
  - Limit diff sample to prevent large secrets exposure
  - Use git's built-in secret detection if available

### NFR-002: Reliability
- **Requirement**: 99% success rate for commit message generation
- **Implementation**:
  - Robust error handling
  - Multiple fallback levels
  - Timeout protection
  - Graceful degradation

### NFR-003: Usability
- **Requirement**: Users should understand what's happening
- **Implementation**:
  - Clear log messages about AI generation
  - Display generated commit message before committing
  - Confirmation prompt in interactive mode (even with --ai-batch if INTERACTIVE_MODE=true)

### NFR-004: Maintainability
- **Requirement**: Code should be easy to understand and modify
- **Implementation**:
  - Modular functions for each step
  - Clear variable names
  - Comprehensive comments
  - Unit tests for parsing logic

---

## Implementation Plan

### Phase 1: Core Implementation (v2.7.0-alpha)
**Duration**: 2-3 days

**Tasks**:
1. [ ] Create `generate_batch_ai_commit_message()` function
2. [ ] Implement non-interactive Copilot CLI invocation
3. [ ] Build git context assembly function
4. [ ] Implement AI response parsing
5. [ ] Add basic error handling and fallback
6. [ ] Update Step 11 to use new function when `AI_BATCH_MODE=true`

### Phase 2: Enhancement & Testing (v2.7.0-beta)
**Duration**: 2-3 days

**Tasks**:
1. [ ] Implement enhanced fallback message
2. [ ] Add configuration options
3. [ ] Improve prompt engineering based on testing
4. [ ] Add comprehensive logging
5. [ ] Create unit tests
6. [ ] Test with various project types (docs-only, code, mixed)

### Phase 3: Production Readiness (v2.7.0)
**Duration**: 1-2 days

**Tasks**:
1. [ ] Performance testing and optimization
2. [ ] Security review of prompt content
3. [ ] Documentation updates
4. [ ] Create migration guide
5. [ ] Final QA testing
6. [ ] Release

---

## Testing Strategy

### Unit Tests
```bash
# Test AI response parsing
test_parse_ai_commit_response()
test_extract_commit_from_markdown_block()
test_remove_ai_conversational_wrappers()

# Test fallback logic
test_fallback_when_ai_unavailable()
test_fallback_when_parsing_fails()
test_enhanced_fallback_message_format()

# Test git context assembly
test_git_context_with_docs_only()
test_git_context_with_code_changes()
test_git_context_with_mixed_changes()
```

### Integration Tests
```bash
# Test with real Copilot CLI
test_batch_commit_with_ai_generation()
test_batch_commit_fallback_without_copilot()
test_batch_commit_timeout_handling()

# Test different change types
test_docs_only_commit_message()
test_feature_commit_message()
test_bugfix_commit_message()
```

### Manual Test Scenarios
1. **Scenario 1**: Run workflow with `--ai-batch` on docs-only changes
   - Expected: AI generates descriptive commit about documentation updates
   
2. **Scenario 2**: Run workflow with `--ai-batch` on feature branch
   - Expected: AI generates feature commit with proper scope

3. **Scenario 3**: Run workflow with `--ai-batch` with Copilot unavailable
   - Expected: Falls back to enhanced default message

4. **Scenario 4**: Run workflow with `--ai-batch --auto` (both flags)
   - Expected: AI generates commit, no user prompts

---

## Success Metrics

### Quantitative Metrics
- [ ] **AI Generation Success Rate**: >95% of batch runs use AI-generated messages
- [ ] **Generation Time**: <30 seconds (95th percentile)
- [ ] **Fallback Rate**: <5% of runs use fallback
- [ ] **Commit Message Quality**: >80% pass conventional commit validation

### Qualitative Metrics
- [ ] **User Satisfaction**: Positive feedback from 90% of users
- [ ] **Commit History Quality**: Reviewers find commits easier to understand
- [ ] **CI/CD Integration**: Successful adoption in automated pipelines

---

## Risks and Mitigations

### Risk 1: AI Generation Unreliable
**Probability**: Medium  
**Impact**: High  
**Mitigation**: 
- Implement robust fallback mechanism
- Use timeout protection
- Allow disabling via configuration

### Risk 2: AI Generates Poor Quality Messages
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Invest in prompt engineering
- Test with various change types
- Allow human review in interactive mode
- Provide easy way to override

### Risk 3: Performance Impact
**Probability**: Low  
**Impact**: Medium  
**Mitigation**:
- Set aggressive timeout (30s)
- Make feature opt-out
- Cache prompt construction

### Risk 4: Copilot CLI Changes Break Integration
**Probability**: Medium  
**Impact**: High  
**Mitigation**:
- Version pin Copilot CLI recommendations
- Test with multiple CLI versions
- Fallback always available
- Monitor Copilot CLI changelog

---

## Dependencies

### External Dependencies
- **GitHub Copilot CLI**: Required for AI generation
  - Minimum version: TBD (test with current version)
  - Installation: `gh extension install github/gh-copilot`
  
### Internal Dependencies
- `execute_copilot_prompt()` function (lib/ai_helpers.sh)
- `git_workflow_specialist` persona (lib/ai_helpers.yaml)
- Git cache functions (lib/git_cache.sh)
- Step 11 module (steps/step_11_git.sh)

---

## Documentation Requirements

### User Documentation
- [ ] Update `docs/TARGET_PROJECT_FEATURE.md` with `--ai-batch` commit message behavior
- [ ] Update `docs/AI_BATCH_MODE.md` with Step 11 enhancements
- [ ] Add configuration examples to `docs/reference/configuration.md`
- [ ] Update `README.md` feature matrix

### Developer Documentation
- [ ] Update `src/workflow/steps/step_11_git.sh` header comments
- [ ] Document `generate_batch_ai_commit_message()` function
- [ ] Add troubleshooting guide for AI generation failures
- [ ] Update `CHANGELOG.md`

---

## Open Questions

1. **Q**: Should we allow users to provide custom commit message templates for AI?
   **A**: TBD - Consider for v2.8.0

2. **Q**: Should we implement AI caching for commit messages (reuse if changes identical)?
   **A**: TBD - Requires careful consideration of cache invalidation

3. **Q**: Should we support other AI providers (OpenAI API, Anthropic, local models)?
   **A**: TBD - Consider for v3.0.0

4. **Q**: Should we allow post-generation editing even in batch mode?
   **A**: TBD - Conflicts with batch/non-interactive goal

---

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/github-copilot-in-the-cli)
- [Git Commit Best Practices](https://chris.beams.io/posts/git-commit/)
- Current Implementation: `src/workflow/steps/step_11_git.sh`
- Related: `STEP_11_AI_BATCH_FIX.md` (current behavior)

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Owner | TBD | - | Pending |
| Tech Lead | TBD | - | Pending |
| QA Lead | TBD | - | Pending |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-12-31 | AI Workflow Team | Initial draft |

---

**Next Steps**: Review and approval → Implementation in v2.7.0-alpha
