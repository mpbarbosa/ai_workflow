# Step 13: Prompt Engineer Analysis

**Version**: 1.0.0 (Added in v2.3.1)  
**Module**: `src/workflow/steps/step_13_prompt_engineer.sh`  
**Persona**: `prompt_engineer` (defined in `src/workflow/lib/ai_helpers.yaml`)  
**Scope**: Only runs on `bash-automation-framework` projects (ai_workflow repository)

## Overview

Step 13 is a specialized workflow step that analyzes all AI persona prompts defined in the workflow configuration and identifies opportunities for improvement. It uses AI-powered analysis to evaluate prompt quality across multiple dimensions and automatically creates GitHub issues for each improvement opportunity.

## Purpose

This step serves several critical functions:

1. **Quality Assurance**: Continuously monitor and improve AI prompt quality
2. **Token Optimization**: Identify opportunities to reduce token usage while maintaining effectiveness
3. **Consistency**: Ensure all personas follow similar patterns and best practices
4. **User Experience**: Improve the clarity and helpfulness of AI responses
5. **Documentation**: Generate actionable improvement recommendations with examples

## When It Runs

### Project Type Filtering

Step 13 **only runs** on projects with the following configuration in `.workflow-config.yaml`:

```yaml
project:
  type: "bash-automation-framework"
```

This ensures the step only analyzes prompts when running on the ai_workflow repository itself, not on projects that use the workflow as a tool.

### Execution Dependencies

- **Depends on**: Step 0 (Pre-Analysis)
- **Can run in parallel with**: Steps 1, 3, 4, 5, 8 (Group 1 validation steps)
- **Estimated duration**: 150 seconds (with AI analysis)

## Workflow

### Phase 1: Extract Persona Information

1. Load `src/workflow/lib/ai_helpers.yaml`
2. Count total personas (e.g., 15 personas in v2.3.1)
3. Extract persona names (e.g., `doc_analysis_prompt`, `step2_consistency_prompt`)
4. Read complete prompt content for analysis

### Phase 2: AI-Powered Analysis

If GitHub Copilot CLI is available:

1. Build comprehensive AI prompt with:
   - Role definition (Prompt Engineer + AI Specialist)
   - Complete persona content for analysis
   - Analysis framework (6 categories)
   - Expected output format
   
2. Execute AI analysis via GitHub Copilot CLI

3. Receive structured recommendations with:
   - Persona name
   - Issue category
   - Severity level (Low/Medium/High/Critical)
   - Current problem description
   - Improvement recommendation
   - Expected impact
   - Implementation notes

### Phase 3: Parse Improvement Opportunities

1. Parse AI output to extract individual opportunities
2. Each opportunity structured as:
   ```markdown
   ## Improvement Opportunity #N
   
   **Persona**: {name}
   **Category**: {category}
   **Severity**: {severity}
   
   ### Current Problem
   {description}
   
   ### Recommendation
   {suggestion}
   
   ### Expected Impact
   {benefit}
   ```

### Phase 4: Create GitHub Issues

For each improvement opportunity:

1. Extract key information (persona, category, severity)
2. Build issue title: `[Prompt Engineering] Improve {persona} - {category}`
3. Build issue body with:
   - Full improvement details
   - Implementation checklist
   - Suggested labels
4. Create GitHub issue using `gh issue create`
5. Track created issue URLs in backlog

### Phase 5: Generate Summary

1. Save step summary with counts
2. Save detailed backlog report with:
   - Personas analyzed
   - Opportunities found
   - Issues created
   - Issue URLs
3. Update workflow status

## Analysis Categories

The AI analysis evaluates prompts across six dimensions:

### 1. Clarity and Specificity

- Role definitions are clear and authoritative
- Task templates provide sufficient context
- Approach sections give actionable guidance
- No vague or ambiguous instructions
- Prompts are complete for intended tasks

### 2. Token Efficiency

- No redundant or repetitive content
- Opportunities to consolidate instructions
- Verbose phrasing simplified
- Balance of conciseness and comprehensiveness
- Estimated token usage per persona

### 3. Output Quality Optimization

- Expected output formats well-defined
- Prompts guide toward structured responses
- Examples improve understanding where needed
- Encourage actionable recommendations
- Clear success criteria

### 4. Consistency and Standardization

- Consistent formatting across personas
- Similar tasks use similar prompt patterns
- Consistent terminology and style
- All personas follow best practices
- Template reuse opportunities

### 5. Domain Expertise Alignment

- Role matches task complexity
- Technical domain accurately represented
- Appropriate authority level
- Domain-specific guidance present
- Leverages relevant best practices

### 6. User Experience Considerations

- Developer-friendly prompts
- Clear error handling guidance
- Helpful, not just correct responses
- Context-aware recommendations
- Adaptable to different scenarios

## Severity Levels

Issues are prioritized by severity:

- **Critical**: Impacts correctness or causes confusion
- **High**: Significantly improves output quality or saves tokens
- **Medium**: Enhances consistency or user experience
- **Low**: Minor refinements or stylistic improvements

## GitHub Issue Format

Each created issue follows this structure:

```markdown
## Prompt Engineering Improvement Opportunity

**Generated by**: Workflow Step 13 - Prompt Engineer Analysis
**Analysis Date**: YYYY-MM-DD
**Configuration File**: `src/workflow/lib/ai_helpers.yaml`

---

[Full improvement opportunity content]

---

## Implementation Checklist

- [ ] Review the recommendation
- [ ] Update `src/workflow/lib/ai_helpers.yaml`
- [ ] Test the improved prompt with relevant workflow step
- [ ] Validate output quality improvement
- [ ] Update documentation if needed

## Labels

`prompt-engineering` `ai-optimization` `severity:{level}` `{category}`
```

## Configuration

### AI Persona Definition

Located in `src/workflow/lib/ai_helpers.yaml`:

```yaml
step13_prompt_engineer_prompt:
  role: "You are a senior prompt engineer and AI specialist..."
  
  task_template: |
    Analyze all AI persona prompts...
    
    **Context:**
    - Project: AI Workflow Automation
    - Configuration File: src/workflow/lib/ai_helpers.yaml
    - Total Personas: {persona_count}
    
    [Full analysis framework]
  
  approach: |
    **Expected Output Format:**
    [Structured format definition]
    
    **Best Practices to Apply:**
    - Use imperative voice
    - Be specific about expected outputs
    - Include examples where helpful
    [Additional best practices]
```

### Dependencies

The step requires:

1. **GitHub Copilot CLI**: For AI analysis
   - Install: `npm install -g @githubnext/github-copilot-cli`
   - Authenticate: `gh auth login`

2. **GitHub CLI (`gh`)**: For issue creation
   - Install: https://cli.github.com/
   - Authenticate: `gh auth login`

## Usage Examples

### Basic Execution

```bash
# Run full workflow (step 13 included automatically)
cd /path/to/ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --auto

# Run only step 13
./src/workflow/execute_tests_docs_workflow.sh --steps 13

# Run with smart execution (step 13 included in validation group)
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel
```

### Dry Run Mode

```bash
# Preview what issues would be created without actually creating them
./src/workflow/execute_tests_docs_workflow.sh --steps 13 --dry-run
```

### Interactive Mode

```bash
# Review AI analysis interactively before issue creation
./src/workflow/execute_tests_docs_workflow.sh --steps 13
# Copilot CLI will open for review
```

## Output Files

### Execution Log

```
src/workflow/logs/workflow_TIMESTAMP/step13_prompt_analysis_TIMESTAMP.log
```

Contains full AI analysis output and execution details.

### Step Report

```
src/workflow/backlog/workflow_TIMESTAMP/step_13_Prompt_Engineer_Analysis.md
```

Contains:
- Personas analyzed
- Opportunities found
- Issues created/failed
- Issue URLs

### Created Issues List

```
src/workflow/backlog/workflow_TIMESTAMP/created_issues.txt
```

List of GitHub issue URLs created during this run.

### Failed Issues (if any)

```
src/workflow/backlog/workflow_TIMESTAMP/issue_N_failed.md
```

Issue content that failed to be created (e.g., `gh` CLI not available).

## Error Handling

### Missing GitHub Copilot CLI

- **Behavior**: Step skips AI analysis
- **Status**: ⚠️ SKIP
- **Output**: Warning message with installation instructions

### Missing GitHub CLI

- **Behavior**: Issues are not created but content is saved to files
- **Status**: ⚠️ WARNINGS
- **Output**: Issue content files in backlog directory

### GitHub CLI Not Authenticated

- **Behavior**: Same as missing GitHub CLI
- **Output**: Authentication instructions provided

### Wrong Project Type

- **Behavior**: Step skips entirely
- **Status**: ⏭️ SKIP
- **Output**: Info message explaining scope limitation

## Performance Characteristics

- **Estimated Duration**: 150 seconds (with AI)
- **Token Usage**: ~2,000-4,000 tokens (analyzing 15 personas)
- **Caching**: AI responses cached for 24 hours
- **Parallel Execution**: Can run with Steps 1, 3, 4, 5, 8

## Best Practices

### When to Run

- After adding new AI personas
- After modifying existing prompts
- Periodically (e.g., monthly) for continuous improvement
- Before major releases

### Acting on Issues

1. **Review Issues Promptly**: Triage created issues within 1 week
2. **Prioritize by Severity**: Address Critical and High severity first
3. **Test Changes**: Always test prompt improvements before committing
4. **Measure Impact**: Track token usage and output quality improvements
5. **Close Loop**: Close issues after implementing and validating changes

### Continuous Improvement

- Track trends in issue categories over time
- Monitor token usage reduction from improvements
- Collect feedback on AI output quality
- Update analysis criteria based on learnings

## Troubleshooting

### No Improvement Opportunities Found

**Possible Causes**:
- All prompts are already well-designed ✅
- AI analysis didn't run (check Copilot CLI availability)
- Output parsing failed

**Solutions**:
- Review execution logs
- Check Copilot CLI authentication
- Verify YAML syntax in ai_helpers.yaml

### Issues Not Created

**Possible Causes**:
- GitHub CLI not installed or authenticated
- Repository permissions insufficient
- Network connectivity issues

**Solutions**:
- Install GitHub CLI: https://cli.github.com/
- Authenticate: `gh auth login`
- Check repository access permissions
- Review failed issue files in backlog directory

### Step Skipped Unexpectedly

**Possible Causes**:
- Project type is not `bash-automation-framework`
- Running on wrong repository

**Solutions**:
- Verify `.workflow-config.yaml` project type
- Step is designed to only run on ai_workflow itself
- This is expected behavior when running on other projects

## Integration with Other Steps

- **Step 0**: Provides project analysis and tech stack detection
- **Step 1**: Benefits from improved documentation prompts
- **Step 2**: Benefits from improved consistency analysis prompts
- **Steps 5-7**: Benefits from improved testing prompts
- **Step 11**: Benefits from improved git commit prompts

## Metrics and Monitoring

Track these metrics over time:

1. **Personas Analyzed**: Should match total persona count
2. **Opportunities Found**: Trend should decrease as prompts improve
3. **Issues Created**: Success rate of issue creation
4. **Token Usage**: Track reduction from efficiency improvements
5. **Severity Distribution**: Monitor high-severity issue trends

## Future Enhancements

Potential improvements for future versions:

1. **Automated Testing**: Test prompt improvements automatically
2. **A/B Testing**: Compare old vs. new prompts
3. **Metrics Integration**: Track token usage before/after changes
4. **Prompt Templates**: Generate standardized prompts
5. **Cross-Project Analysis**: Compare prompts across multiple projects
6. **Historical Tracking**: Track improvement trends over time

## References

- **Main Orchestrator**: `src/workflow/execute_tests_docs_workflow.sh`
- **Dependency Graph**: `src/workflow/lib/dependency_graph.sh`
- **AI Configuration**: `src/workflow/lib/ai_helpers.yaml`
- **Step Module**: `src/workflow/steps/step_13_prompt_engineer.sh`

## Version History

### v1.0.0 (2025-12-20)

- Initial implementation
- 6-category analysis framework
- GitHub issue integration
- Project type filtering
- Parallel execution support
