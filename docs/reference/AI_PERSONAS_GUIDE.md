# AI Personas Reference Guide

**Version**: v4.1.0  
**Last Updated**: 2026-02-10  
**Audience**: Users and developers working with AI-powered workflow steps

## Table of Contents

1. [Overview](#overview)
2. [Persona Categories](#persona-categories)
3. [Core Documentation Personas](#core-documentation-personas)
4. [Testing Personas](#testing-personas)
5. [Code Quality Personas](#code-quality-personas)
6. [Integration Personas](#integration-personas)
7. [Using AI Personas](#using-ai-personas)
8. [Customizing Personas](#customizing-personas)
9. [Token Efficiency](#token-efficiency)
10. [Best Practices](#best-practices)

---

## Overview

The AI Workflow Automation system uses **17 specialized AI personas** to perform different validation and enhancement tasks across the 23-step pipeline. Each persona has:

- **Specific Expertise**: Focused domain knowledge
- **Clear Role**: Well-defined responsibilities
- **Behavioral Guidelines**: Consistent decision-making patterns
- **Output Standards**: Structured, actionable results

### Persona Architecture

```
AI Personas (17 total)
├── Documentation (5 personas)
│   ├── technical_writer           # Bootstrap docs from scratch (Step 0b)
│   ├── documentation_specialist   # Analyze and update docs (Step 2)
│   ├── consistency_checker        # Audit documentation quality (Step 3)
│   ├── script_ref_validator       # Validate code references (Step 4)
│   └── markdown_linter           # Check markdown formatting (Step 8)
│
├── Testing (3 personas)
│   ├── test_strategist           # Define test strategy (Step 1)
│   ├── test_engineer             # Review test implementation (Step 5)
│   └── test_executor             # Analyze test results (Step 7)
│
├── Code Quality (6 personas)
│   ├── code_reviewer             # Review code quality (Step 6, 9)
│   ├── quality_auditor           # Comprehensive quality check (Step 11)
│   ├── front_end_developer       # Front-end technical analysis (Step 11.7) ⭐ NEW v4.0.1
│   ├── ui_ux_designer            # UX/accessibility analysis (Step 15) ⭐ UPDATED v4.0.1
│   ├── devops_engineer           # CI/CD validation (Step 12)
│   └── context_analyst           # Context analysis (Step 11.5)
│
└── Integration (3 personas)
    ├── prompt_engineer           # Optimize AI prompts (Step 13)
    ├── git_specialist            # Generate commit messages (Step 14)
    └── version_manager           # Semantic versioning (Step 16)
```

### Configuration Files

| File | Purpose | Lines |
|------|---------|-------|
| `.workflow_core/config/ai_helpers.yaml` | Base persona definitions | 762 |
| `.workflow_core/config/ai_prompts_project_kinds.yaml` | Project-specific enhancements | 300+ |
| `.workflow_core/config/model_selection_rules.yaml` | Model selection logic | 100+ |

---

## Persona Categories

### 1. Core Documentation Personas

These personas handle documentation analysis, creation, and quality assurance.

#### technical_writer (NEW v3.1.0, UPDATED v4.0.1)

**Purpose**: Generate comprehensive documentation from scratch for undocumented or new projects with necessity-first evaluation.

**Expertise**:
- API documentation creation
- Architecture documentation
- User guides and tutorials
- Developer guides
- Code documentation standards
- Documentation needs assessment (NEW v4.0.1)

**Used In**: Step 0b (Bootstrap Documentation)

**Key Capabilities**:
- **Necessity Evaluation** (NEW v4.0.1): Evaluates whether documentation generation is truly needed before proceeding
- Analyzes codebase structure to understand components
- Creates comprehensive documentation hierarchy
- Generates API references with examples
- Documents architecture patterns and design decisions
- Creates getting started guides and tutorials
- Language-agnostic with dynamic language-specific standards

**Necessity-First Framework** (v4.0.1):

The technical_writer now evaluates documentation needs BEFORE generating content:

✅ **Generates Documentation When**:
- Critical Gap: No/minimal README (< 100 words)
- Public API Undocumented: Missing function/class docs
- Setup Impossible: No installation instructions
- Architecture Mystery: Complex system without overview
- Breaking Changes: Major version without migration guide
- Legal/Security Gap: Missing LICENSE/security policy
- Explicit Request: Task specifically asks for docs

❌ **Skips Generation When**:
- Complete Coverage: All public APIs documented
- Clear Getting Started: README has basics
- Recent Updates: Docs modified < 3 months ago
- No Code Changes: No new features since last update
- Adequate Examples: Working examples exist
- Architecture Documented: System design is clear

**Decision Framework**:
- **Phase 0 (Necessity Check)**: Evaluates all criteria before generation
- **Default Behavior**: Do nothing unless clear need demonstrated
- **Transparent Decisions**: Always outputs evaluation with evidence
- **Token Efficient**: Prevents unnecessary AI processing for well-documented projects

**Output Format**:
- **Necessity Report**: Clear PASS/FAIL decision with evidence
- **IF PASS**: Shows criteria met → generates documentation
- **IF FAIL**: Shows evaluation → exits with optional minor suggestions
- Complete documentation files (README, API docs, guides) - only if needed
- Organized documentation structure
- Code examples and usage patterns
- Architecture diagrams (when applicable)

**Example Use Case**:
```bash
# Bootstrap documentation for a new project
./execute_tests_docs_workflow.sh --steps 0b --target /path/to/undocumented-project

# Result: Evaluates necessity first, generates only if criteria met
```

**When to Use**:
- New projects without documentation
- Legacy projects needing documentation overhaul
- Open source projects requiring comprehensive docs
- After major refactoring requiring doc rewrite
- Periodic documentation audits (will skip if docs are current)

**Configuration** (`.workflow_core/config/ai_helpers.yaml`):
- Prompt template: `technical_writer_prompt` (v4.2.0)
- Submodule commit: `a165069` (2026-02-09)
- Enhancement: Necessity-first evaluation framework
- Lines: ~150 (evaluation criteria + task template + approach)

**Behavioral Changes (v4.0.1)**:
- **OLD**: Always proceeded with documentation generation
- **NEW**: Evaluates necessity → generates only if criteria met
- **Impact**: 60-80% reduction in unnecessary documentation generation for well-documented projects
- **Token Savings**: Significant reduction in AI processing costs

---

#### documentation_specialist

**Purpose**: Analyze existing documentation and identify needed updates based on code changes.

**Expertise**:
- Documentation accuracy assessment
- Gap identification
- Change impact analysis
- API documentation standards

**Used In**: Step 2 (Documentation Analysis)

**Key Capabilities**:
- Compares documentation against current code
- Identifies outdated or missing information
- Suggests specific documentation updates
- Validates API documentation completeness
- Considers language-specific documentation standards (JSDoc, docstrings, etc.)

**Behavioral Guidelines**:
- Provides concrete, actionable output
- Explicitly states when no updates needed
- Only updates truly outdated information
- Makes informed decisions based on context
- Defaults to "no changes" rather than unnecessary modifications

**Output Format**:
```markdown
# Documentation Analysis

## Required Updates
1. **File**: path/to/file.md
   - **Issue**: Outdated API signature
   - **Fix**: Update function parameters
   
## Optional Improvements
1. **File**: path/to/another.md
   - **Enhancement**: Add usage example

## No Changes Needed
- docs/guide.md - Current and accurate
```

**Example Prompt**:
```bash
Analyze the following documentation against the current codebase:
- Files changed: src/api/users.js, src/api/auth.js
- Documentation: docs/API.md
```

---

#### consistency_checker

**Purpose**: Audit documentation for consistency, accuracy, and completeness.

**Expertise**:
- Cross-reference validation
- Version consistency
- Link validation
- Terminology consistency

**Used In**: Step 3 (Consistency Check)

**Key Capabilities**:
- Validates cross-references between documents
- Checks version numbers consistency
- Identifies broken links
- Verifies code examples
- Ensures terminology consistency

**Behavioral Guidelines**:
- Provides structured, prioritized analysis
- Identifies specific files, line numbers, and issues
- Includes concrete recommended fixes
- Prioritizes by severity and impact
- Focuses on accuracy over style preferences

**Output Format**:
```markdown
# Consistency Issues

## Critical (Must Fix)
1. **File**: README.md:45
   - **Issue**: Version mismatch (states v1.0, actual v2.0)
   - **Fix**: Update version to v2.0.0

## Important (Should Fix)
1. **File**: docs/API.md:120
   - **Issue**: Broken link to internal documentation
   - **Fix**: Update link to docs/guides/authentication.md

## Minor (Consider Fixing)
1. **File**: docs/guide.md:33
   - **Issue**: Inconsistent terminology ("user" vs "account")
   - **Fix**: Standardize on "user"
```

---

#### script_ref_validator

**Purpose**: Validate that code references in documentation are accurate.

**Expertise**:
- Code reference validation
- API signature verification
- Example code testing
- Language-specific documentation formats

**Used In**: Step 4 (Script Reference Validation)

**Key Capabilities**:
- Validates function/method references
- Checks API signatures match code
- Verifies example code syntax
- Validates import/include statements
- Considers language-specific documentation patterns

**Output Format**:
```markdown
# Script Reference Validation

## Invalid References
1. **File**: docs/API.md:78
   - **Reference**: `getUserById(id, options)`
   - **Actual**: `getUserById(id)` (options parameter removed)
   - **Fix**: Remove options parameter from documentation

## Valid References
- docs/getting-started.md: All code examples valid
```

---

#### markdown_linter

**Purpose**: Check markdown formatting and style consistency.

**Expertise**:
- Markdown syntax validation
- Style guide compliance
- Formatting consistency
- Link structure

**Used In**: Step 8 (Markdown Linting)

**Key Capabilities**:
- Validates markdown syntax
- Checks heading hierarchy
- Validates list formatting
- Checks code block language tags
- Validates link formats

**Output Format**:
```markdown
# Markdown Linting Results

## Errors
- README.md:23: Invalid heading hierarchy (H1 → H3)
- docs/api.md:45: Missing language tag for code block

## Warnings
- docs/guide.md:67: Inconsistent list marker (use - throughout)

## Style Suggestions
- Consider using consistent heading case (Title Case vs sentence case)
```

---

### 2. Testing Personas

These personas handle test strategy, implementation review, and result analysis.

#### test_strategist

**Purpose**: Define comprehensive test strategy based on code changes.

**Expertise**:
- Test coverage analysis
- Test case design
- Testing frameworks
- Coverage gap identification

**Used In**: Step 1 (Test Strategy)

**Key Capabilities**:
- Identifies what needs testing (WHAT, not HOW)
- Suggests test scenarios and edge cases
- Identifies coverage gaps
- Recommends test types (unit, integration, e2e)
- Considers project-specific testing frameworks

**Output Format**:
```markdown
# Test Strategy

## New Tests Required
1. **Component**: UserAuthService
   - **Scenario**: Password reset with expired token
   - **Type**: Unit test
   - **Priority**: High

## Coverage Gaps
1. **Area**: Error handling in API endpoints
   - **Missing**: 400/500 error response tests
   - **Recommendation**: Add integration tests

## Test Types Recommended
- Unit: 15 new tests
- Integration: 5 new tests
- E2E: 2 new scenarios
```

---

#### test_engineer

**Purpose**: Review test implementation quality and effectiveness.

**Expertise**:
- Test code quality
- Test design patterns
- Assertion best practices
- Mock/stub strategies

**Used In**: Step 5 (Test Review)

**Key Capabilities**:
- Reviews test implementation (HOW, not WHAT)
- Validates test quality and maintainability
- Checks assertion clarity
- Reviews test isolation
- Validates mock usage
- Language-specific testing practices

**Behavioral Guidelines**:
- Separates strategic concerns (what to test) from tactical (how to test)
- Focuses on implementation quality
- Validates test maintainability
- Ensures tests follow framework best practices

**Output Format**:
```markdown
# Test Review

## Implementation Issues
1. **File**: tests/auth.test.js:45
   - **Issue**: Test lacks proper cleanup
   - **Fix**: Add afterEach hook to reset state

## Good Practices
- Proper use of mocks in user service tests
- Clear test descriptions

## Recommendations
- Consider parameterized tests for boundary cases
```

---

#### test_executor

**Purpose**: Analyze test execution results and identify issues.

**Expertise**:
- Test result interpretation
- Failure pattern analysis
- Flaky test identification
- Performance bottleneck detection

**Used In**: Step 7 (Test Execution)

**Key Capabilities**:
- Analyzes test output
- Categorizes failures
- Identifies flaky tests
- Suggests fixes for failures
- Detects performance issues

**Output Format**:
```markdown
# Test Execution Analysis

## Test Results Summary
- Total: 247 tests
- Passed: 245 (99.2%)
- Failed: 2 (0.8%)
- Duration: 45.3s

## Failures
1. **Test**: UserService should handle concurrent updates
   - **Error**: Race condition detected
   - **Fix**: Add proper locking mechanism

## Warnings
- 3 tests took > 5s (consider optimization)
```

---

### 3. Code Quality Personas

These personas handle code review, quality auditing, UX analysis, and CI/CD validation.

#### code_reviewer

**Purpose**: Review code quality, style, and best practices.

**Expertise**:
- Code quality assessment
- Design patterns
- Performance optimization
- Security considerations

**Used In**: Steps 6 (Code Review), 9 (Quality Check)

**Key Capabilities**:
- Reviews code for quality issues
- Identifies anti-patterns
- Suggests performance improvements
- Flags security concerns
- Validates coding standards
- Language-specific quality rules

**Output Format**:
```markdown
# Code Review

## Issues
1. **File**: src/api/users.js:123
   - **Issue**: Unhandled promise rejection
   - **Severity**: High
   - **Fix**: Add .catch() or try-catch

## Suggestions
1. **File**: src/utils/validation.js:45
   - **Enhancement**: Extract repeated validation logic
   - **Benefit**: Improved maintainability
```

---

#### quality_auditor

**Purpose**: Comprehensive code quality assessment across entire codebase.

**Expertise**:
- Holistic quality assessment
- Technical debt identification
- Architecture review
- Maintainability analysis

**Used In**: Step 11 (Quality Audit)

**Key Capabilities**:
- Comprehensive codebase analysis
- Architecture pattern validation
- Technical debt quantification
- Maintainability scoring
- Cross-cutting concerns identification

**Output Format**:
```markdown
# Quality Audit

## Overall Assessment
- Code Quality: B+ (87/100)
- Maintainability: Good
- Technical Debt: Moderate

## Key Findings
1. **Architecture**: Well-structured, clear separation of concerns
2. **Testing**: Excellent coverage (100%)
3. **Documentation**: Good, minor gaps

## Recommendations
1. Refactor UserService class (too many responsibilities)
2. Extract shared validation logic
3. Add performance monitoring
```

---

#### front_end_developer

**Purpose**: Analyze front-end code for technical implementation quality, performance, and architecture.

**Expertise**:
- Modern JavaScript frameworks (React, Vue, Angular, Svelte)
- Component architecture and design patterns
- Performance optimization (Core Web Vitals, code splitting, lazy loading)
- TypeScript and type safety
- State management patterns
- Accessibility implementation (WCAG 2.1+)
- Front-end testing (Jest, React Testing Library, Cypress, Playwright)
- Build tools and bundlers (Vite, Webpack, Rollup)

**Used In**: Step 11.7 (Front-End Development Analysis)

**Key Capabilities**:
- Reviews component architecture and composition
- Identifies performance bottlenecks (unnecessary re-renders, bundle size)
- Validates TypeScript usage and type safety
- Evaluates state management patterns
- Checks accessibility implementation (ARIA attributes, semantic HTML)
- Assesses testing coverage and quality
- Reviews build configuration and optimization
- Identifies cross-browser compatibility issues

**Behavioral Guidelines**:
- Focuses on technical implementation, NOT visual design or UX
- Provides concrete, production-ready code solutions
- Prioritizes performance and maintainability
- Considers framework-specific best practices
- Validates modern JavaScript/TypeScript patterns

**Output Format**:
```markdown
# Front-End Development Analysis

## Executive Summary
[Priority counts: X critical issues, Y improvements, Z optimizations]

## Critical Issues
1. **File**: src/components/UserList.tsx:45
   - **Issue**: Component causing unnecessary re-renders
   - **Impact**: Performance degradation
   - **Fix**: Wrap with React.memo and use useCallback for handlers

## Architecture & Design
- Component structure and patterns
- Props drilling and component coupling
- Shared component opportunities

## Performance Optimizations
1. **Bundle Size**: 450KB (target: <300KB)
   - Add code splitting for routes
   - Lazy load heavy components
   - Tree-shake unused lodash functions

## Code Quality Improvements
- TypeScript coverage: 85% (target: 95%)
- Test coverage: 72% (target: 80%)
- ESLint issues: 23 warnings

## Accessibility Implementation
✅ Good: Semantic HTML structure
⚠️ Needs Work: Missing ARIA labels on 5 interactive elements
❌ Critical: No focus indicators on buttons

## Recommendations
1. **High Priority**: Add focus indicators (accessibility)
2. **Medium Priority**: Implement code splitting for routes
3. **Low Priority**: Increase TypeScript coverage to 95%
```

**Example Use Case**:
```bash
# Analyze React/Vue/Angular project front-end code
./execute_tests_docs_workflow.sh --steps 11.7

# Or as part of full workflow (auto-runs for front-end projects)
./execute_tests_docs_workflow.sh
```

**When to Use**:
- React, Vue, Angular, Svelte projects
- Static websites with significant JavaScript
- SPAs (Single Page Applications)
- Any project with front-end components

**Relationship with ui_ux_designer**:
- **front_end_developer (Step 11.7)**: Technical implementation, code quality, performance
- **ui_ux_designer (Step 15)**: User experience, visual design, usability
- Run sequentially: technical analysis first, then UX review

---

#### ui_ux_designer

**Purpose**: Analyze user experience, visual design, and accessibility from a user perspective.

**Expertise**:
- User research and user journey mapping
- Information architecture and navigation design
- Visual design (typography, color theory, spacing, hierarchy)
- Interaction design and micro-interactions
- Usability testing and cognitive psychology
- WCAG 2.1 compliance from user perspective
- Design systems and component libraries
- Mobile-first and responsive design strategy

**Used In**: Step 15 (UX Analysis)

**Key Capabilities**:
- Evaluates usability and cognitive load
- Assesses visual hierarchy and design consistency
- Reviews navigation and information architecture
- Analyzes user flows and friction points
- Checks accessibility from user perspective (readability, contrast, clarity)
- Validates responsive design strategy
- Identifies interaction patterns and feedback issues
- Reviews design system adherence

**Behavioral Guidelines**:
- Focuses on user experience and visual design, NOT technical implementation
- Considers user needs and cognitive load
- Applies design principles (hierarchy, contrast, alignment, proximity)
- Prioritizes user experience over aesthetics alone
- Makes informed decisions based on UX best practices

**Output Format**:
```markdown
# UX Analysis Report

## Executive Summary
[Priority counts: X critical issues, Y improvements, Z recommendations]

## Critical Usability Issues
1. **Page**: Checkout flow
   - **Issue**: No progress indicator
   - **Impact**: Users feel lost in multi-step process
   - **Fix**: Add step indicator (Step 1 of 3)

## Visual Design
- Typography scale: Inconsistent heading hierarchy
- Color usage: 3 contrast violations (WCAG 2.1 AA)
- Spacing: Inconsistent padding in cards

## Interaction Design
✅ Good: Clear hover states on buttons
⚠️ Needs Work: No loading feedback on form submission
❌ Critical: No error recovery mechanism

## Information Architecture
- Navigation clarity: 7/10
- Content organization: Good use of categories
- Labeling: 2 ambiguous menu items

## Accessibility (User Perspective)
- Readability: Text too small on mobile (12px, should be 16px)
- Color contrast: 3 violations
- Cognitive load: Form has 15 fields (consider multi-step)

## Recommendations
1. **Critical**: Fix color contrast violations
2. **High**: Add progress indicator to checkout
3. **Medium**: Improve form UX (split into steps)
4. **Low**: Enhance micro-interactions
```

**Example Use Case**:
```bash
# Analyze UI/UX for web application
./execute_tests_docs_workflow.sh --steps 15

# Or as part of full workflow (auto-runs for UI projects)
./execute_tests_docs_workflow.sh
```

**When to Use**:
- Web applications with user interfaces
- Documentation sites (content presentation)
- Static websites (visual design)
- Any project with UI components

**Relationship with front_end_developer**:
- **front_end_developer (Step 11.7)**: Technical implementation (code architecture, performance)
- **ui_ux_designer (Step 15)**: User experience (usability, visual design)
- Complementary perspectives: technical quality + user experience quality

---

#### devops_engineer

**Purpose**: Validate CI/CD configuration and deployment processes.

**Expertise**:
- CI/CD pipelines
- Build configurations
- Deployment strategies
- Infrastructure as code

**Used In**: Step 12 (DevOps Validation)

**Key Capabilities**:
- Reviews CI/CD configuration
- Validates build scripts
- Checks deployment processes
- Analyzes infrastructure setup
- Identifies automation opportunities

**Output Format**:
```markdown
# DevOps Validation

## CI/CD Configuration
- Pipeline: GitHub Actions
- Status: ✅ Valid

## Issues
1. **File**: .github/workflows/test.yml:23
   - **Issue**: Missing caching for dependencies
   - **Impact**: Slower builds
   - **Fix**: Add caching step

## Recommendations
- Add automated deployment to staging
- Implement blue-green deployment
```

---

### 4. Integration Personas

These personas handle workflow integration, optimization, and finalization.

#### prompt_engineer

**Purpose**: Optimize AI prompts for better results and efficiency.

**Expertise**:
- Prompt engineering
- Token optimization
- Context management
- Response quality

**Used In**: Step 13 (Prompt Engineering)

**Key Capabilities**:
- Analyzes prompt effectiveness
- Suggests optimization strategies
- Reduces token usage
- Improves response quality
- Validates prompt clarity

**Output Format**:
```markdown
# Prompt Engineering Analysis

## Current Prompts
- Average tokens: 450
- Response quality: Good

## Optimizations
1. **Prompt**: Documentation analysis
   - **Current**: 520 tokens
   - **Optimized**: 380 tokens (27% reduction)
   - **Change**: Remove redundant context

## Recommendations
- Use YAML anchors for common guidelines
- Implement behavioral patterns
- Standardize output formats
```

---

#### git_specialist

**Purpose**: Generate meaningful commit messages from changes.

**Expertise**:
- Git conventions
- Commit message standards
- Change categorization
- Version control best practices

**Used In**: Step 14 (Git Commit)

**Key Capabilities**:
- Analyzes git diff
- Generates structured commit messages
- Categorizes changes (feat, fix, docs, etc.)
- Identifies breaking changes
- Follows conventional commits

**Behavioral Guidelines**:
- Output only raw commit message text (no code blocks)
- Follow conventional commits format
- Single commit message per invocation
- Clear, concise descriptions

**Output Format**:
```
feat(auth): add password reset functionality

- Implement password reset token generation
- Add email notification for reset requests
- Create reset password form
- Add tests for reset flow

BREAKING CHANGE: Reset tokens now expire after 1 hour
```

---

#### project_manager

**Purpose**: Finalize workflow execution and generate summary.

**Expertise**:
- Project coordination
- Progress tracking
- Summary generation
- Recommendation prioritization

**Used In**: Step 15 (Finalization)

**Key Capabilities**:
- Summarizes workflow execution
- Identifies key accomplishments
- Prioritizes next steps
- Generates executive summary
- Tracks metrics and improvements

**Output Format**:
```markdown
# Workflow Summary

## Execution Overview
- Duration: 12.5 minutes
- Steps completed: 15/15
- Issues found: 8
- Issues fixed: 6

## Key Accomplishments
1. Updated 12 documentation files
2. Added 15 new tests (coverage: 100%)
3. Fixed 3 critical code quality issues

## Next Steps (Priority)
1. Address remaining accessibility issues (2 items)
2. Optimize slow tests (3 tests > 5s)
3. Refactor UserService class

## Metrics
- Code quality: B+ → A-
- Test coverage: 97% → 100%
- Documentation completeness: 85% → 95%
```

---

## Using AI Personas

### In Step Scripts

```bash
#!/usr/bin/env bash

# Source AI helpers
source "${SCRIPT_DIR}/../lib/ai_helpers.sh"

# Call AI with specific persona
call_ai_persona "documentation_specialist" \
    "Analyze this documentation against current code" \
    "${output_file}" || return 1
```

### With Custom Context

```bash
# Build custom prompt with persona
local prompt
prompt=$(build_ai_prompt \
    "test_strategist" \
    "Identify test scenarios for UserAuthService changes" \
    "Focus on edge cases and security concerns")

# Call AI with prompt
echo "$prompt" | copilot --model claude-sonnet-4.5
```

### Checking Persona Availability

```bash
# Validate Copilot CLI is available
if ! validate_copilot_cli; then
    print_error "AI features require GitHub Copilot CLI"
    return 1
fi

# Check if specific persona is configured
if ! persona_exists "custom_persona"; then
    print_warning "Custom persona not found, using default"
fi
```

---

## Customizing Personas

### Adding Project-Specific Enhancements

Edit `.workflow_core/config/ai_prompts_project_kinds.yaml`:

```yaml
shell_script_automation:
  documentation_specialist:
    additional_context: |
      For shell scripts, also consider:
      - ShellCheck compliance
      - POSIX compatibility
      - Exit codes and error handling
    
    quality_standards:
      - "Use set -euo pipefail"
      - "Quote all variables"
      - "Document exit codes"

nodejs_api:
  code_reviewer:
    additional_context: |
      For Node.js APIs, focus on:
      - Async/await error handling
      - Security middleware
      - Rate limiting
      - Input validation
    
    quality_standards:
      - "Use async/await over callbacks"
      - "Validate all user inputs"
      - "Implement proper error middleware"
```

### Creating Custom Personas

Add to `.workflow_core/config/ai_helpers.yaml`:

```yaml
custom_persona:
  role_prefix: |
    You are a [specific role] with expertise in [specific domain].
  
  behavioral_guidelines: *behavioral_actionable
  
  capabilities:
    - Capability 1
    - Capability 2
    - Capability 3
  
  task_template: |
    ## Task
    {task_description}
    
    ## Context
    {context}
  
  standards:
    - Standard 1
    - Standard 2
  
  output_format: |
    ## Summary
    [Brief summary]
    
    ## Details
    [Detailed findings]
    
    ## Recommendations
    [Action items]
```

---

## Token Efficiency

The AI persona system is optimized for token efficiency through:

### 1. YAML Anchors

Common behavioral guidelines defined once and reused:

```yaml
_behavioral_actionable: &behavioral_actionable |
  **Critical Behavioral Guidelines**:
  - ALWAYS provide concrete, actionable output
  - If documentation is accurate, say "No updates needed"

# Reuse in multiple personas
documentation_specialist:
  behavioral_guidelines: *behavioral_actionable

consistency_checker:
  behavioral_guidelines: *behavioral_actionable
```

**Savings**: ~260-390 tokens per workflow

### 2. Output Format Simplification (v4.0.0)

Removed rigid templates from prompts:

**Before**:
```
Expected output format:
1. Section 1
   - Item A
   - Item B
2. Section 2
   ...
```

**After**:
```
Output: Structured analysis with specific issues and fixes
```

**Savings**: ~550 tokens per workflow

### 3. Language-Specific Injection

Dynamic language-specific standards instead of static examples:

**Before**:
```
For JavaScript:
- Use JSDoc format
- Example: /** @param {string} id */

For Python:
- Use docstrings
- Example: def foo(id: str) -> None:
```

**After**:
```
{language_specific_standards}  # Injected at runtime
```

**Savings**: ~340 tokens per workflow

### Total Token Efficiency

- **Total Savings**: ~1,400-1,500 tokens per workflow
- **Cost Impact**: ~$0.042-0.045 saved per workflow (GPT-4 @ $0.03/1K tokens)
- **Annual Savings**: ~$252-270/year at 500 workflows/month

---

## Best Practices

### Using Personas Effectively

1. **Choose the Right Persona**: Match persona expertise to task
2. **Provide Context**: Include relevant project information
3. **Be Specific**: Clear task descriptions yield better results
4. **Validate Output**: Review AI recommendations before applying
5. **Iterate**: Refine prompts based on results

### Prompt Construction

1. **Clear Objective**: State what you want accomplished
2. **Relevant Context**: Include necessary background
3. **Constraints**: Specify any limitations or requirements
4. **Output Format**: Describe expected structure
5. **Examples**: Provide examples when applicable

### Maintaining Personas

1. **Version Control**: Track persona changes in Git
2. **Documentation**: Document custom persona purposes
3. **Testing**: Validate personas with test scenarios
4. **Metrics**: Track persona effectiveness
5. **Iteration**: Refine based on results

### Token Optimization

1. **Remove Duplication**: Use YAML anchors for common content
2. **Simplify Output**: Avoid overly rigid templates
3. **Dynamic Context**: Inject context at runtime
4. **Concise Language**: Use clear, brief instructions
5. **Measure**: Track token usage and optimize

### Security Considerations

1. **No Secrets**: Never include sensitive data in prompts
2. **Code Review**: Review AI-generated code before committing
3. **Validation**: Always validate AI recommendations
4. **Rate Limiting**: Implement rate limits for API calls
5. **Audit Logs**: Track AI persona usage

---

## Troubleshooting

### Persona Not Working

**Problem**: AI persona not producing expected results.

**Solutions**:
1. Verify Copilot CLI authentication: `gh auth status`
2. Check persona exists: Review `.workflow_core/config/ai_helpers.yaml`
3. Enable verbose mode: `VERBOSE=1` to see full prompts
4. Clear AI cache: `rm -rf .ai_cache/`
5. Try different model: Set `COPILOT_MODEL=claude-opus-4`

### Inconsistent Results

**Problem**: Same prompt produces different results.

**Solutions**:
1. Add more specific constraints
2. Provide more context
3. Use examples in prompts
4. Specify output format explicitly
5. Increase temperature for creativity or decrease for consistency

### Token Limits Exceeded

**Problem**: Prompt too large for model.

**Solutions**:
1. Reduce context size
2. Split into multiple prompts
3. Use summarization
4. Switch to model with larger context window
5. Optimize prompt for token efficiency

### Poor Quality Output

**Problem**: AI output not meeting quality standards.

**Solutions**:
1. Refine persona definition
2. Add more specific standards
3. Provide better examples
4. Increase model capability (e.g., Opus vs Sonnet)
5. Review and iterate on prompts

---

## Related Documentation

- [Extending the Workflow](./EXTENDING_THE_WORKFLOW.md) - How to add custom personas
- [Configuration Reference](../reference/CONFIGURATION_REFERENCE.md) - Configuration options
- [API Reference](../api/COMPLETE_API_REFERENCE.md) - API documentation
- [Project Reference](../PROJECT_REFERENCE.md) - Complete feature list

---

## Quick Reference Table

| Persona | Purpose | Step | Key Focus |
|---------|---------|------|-----------|
| technical_writer | Bootstrap docs from scratch | 0b | Comprehensive documentation |
| documentation_specialist | Analyze and update docs | 2 | Change-driven updates |
| consistency_checker | Audit doc quality | 3 | Cross-reference validation |
| script_ref_validator | Validate code refs | 4 | Code reference accuracy |
| markdown_linter | Check markdown | 8 | Formatting consistency |
| test_strategist | Define test strategy | 1 | What to test |
| test_engineer | Review test code | 5 | How to test |
| test_executor | Analyze test results | 7 | Test execution |
| code_reviewer | Review code quality | 6, 9 | Code quality |
| quality_auditor | Comprehensive audit | 11 | Holistic assessment |
| context_analyst | Context analysis | 11.5 | Workflow summary |
| front_end_developer | Front-end technical analysis | 11.7 | Technical implementation ⭐ NEW |
| ui_ux_designer | UX/visual design | 15 | User experience ⭐ UPDATED |
| devops_engineer | CI/CD validation | 12 | DevOps practices |
| prompt_engineer | Optimize prompts | 13 | AI efficiency |
| git_specialist | Generate commits | 14 | Git best practices |
| version_manager | Semantic versioning | 16 | Version updates |

**Total**: 17 personas across 23 workflow steps (updated v4.0.1)
