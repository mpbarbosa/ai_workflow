# AI Model Selection Guide

**Feature Version**: v3.2.0  
**Status**: Stable  
**Last Updated**: 2026-02-06

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [How It Works](#how-it-works)
4. [Model Tier System](#model-tier-system)
5. [Complexity Calculation](#complexity-calculation)
6. [Configuration](#configuration)
7. [CLI Options](#cli-options)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Usage](#advanced-usage)

---

## Overview

The AI Model Selection feature automatically chooses the optimal GitHub Copilot AI model for each workflow step based on the complexity of your recent code changes. This ensures:

- **Cost Efficiency**: Simple tasks use faster, cheaper models
- **Quality**: Complex tasks get powerful reasoning models they need
- **Performance**: Optimal model selection reduces overall execution time
- **Transparency**: Clear reasoning for every model assignment

### Benefits

| Metric | Improvement |
|--------|-------------|
| Token Usage | 30-50% reduction |
| Execution Time | 15-25% faster |
| Response Quality | Matched to task complexity |
| Cost | Lower with tiered approach |

---

## Quick Start

### Automatic Mode (Recommended)

Model selection happens automatically when you run the workflow:

```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

During **Step 0**, you'll see:

```
=== AI Model Selection Analysis ===
✓ Change classification:
  • Code files: 8
  • Documentation: 5
  • Tests: 2

✓ Complexity analysis:
  • Code: 72 → HIGH
  • Documentation: 18 → LOW
  • Tests: 35 → MEDIUM

✓ Model definitions saved: .ai_workflow/model_definitions.json

Key model assignments:
  • Step 1 (Documentation): claude-haiku-4.5
  • Step 5 (Test Review): claude-sonnet-4.5
  • Step 9 (Code Quality): claude-opus-4.5
```

### Preview Mode

See model assignments without running the full workflow:

```bash
./execute_tests_docs_workflow.sh --show-model-plan
```

### Override Mode

Force a specific model for all steps:

```bash
./execute_tests_docs_workflow.sh --force-model claude-opus-4.6
```

---

## How It Works

### Workflow Integration

```
┌─────────────────────────────────────────────────────────────┐
│ Step 0: Pre-Analysis                                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Detect git changes (modified/staged/untracked)          │
│ 2. Classify files by nature (code/docs/tests)              │
│ 3. Calculate complexity for each category                   │
│ 4. Map complexity scores to model tiers                     │
│ 5. Generate model definitions JSON                          │
│ 6. Save to .ai_workflow/model_definitions.json             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Subsequent Steps (1-15)                                     │
├─────────────────────────────────────────────────────────────┤
│ • Load model definition for current step                    │
│ • Use selected model for AI calls                           │
│ • Log model used in step logs                               │
└─────────────────────────────────────────────────────────────┘
```

### File Classification

Files are classified with priority rules to handle ambiguous cases:

1. **Tests** (highest priority): `*test*.js`, `*.spec.js`, `__tests__/*`
2. **Documentation**: `*.md`, `docs/*`, `README*`, `CHANGELOG*`
3. **Code** (default): `*.js`, `*.py`, `*.go`, `*.ts`, etc.

**Example**:
- `test_documentation.md` → **Tests** (test pattern takes priority)
- `README.md` → **Documentation**
- `src/utils.js` → **Code**

---

## Model Tier System

Based on [GitHub Copilot Model Comparison](https://docs.github.com/en/copilot/reference/ai-models/model-comparison).

### Tier 1: Fast (Complexity 0-25)

**Primary**: `claude-haiku-4.5`  
**Alternatives**: `gpt-5-mini`, `gemini-3-flash`

**Best For**:
- Simple documentation updates
- Minor code edits
- Quick fixes
- Typo corrections

**Example Scenario**: Updated README.md with 50 words

### Tier 2: Balanced (Complexity 26-60)

**Primary**: `claude-sonnet-4.5`  
**Alternatives**: `gpt-5.1-codex`, `gpt-5-mini`

**Best For**:
- General-purpose coding
- New features (moderate complexity)
- Test updates
- Code reviews

**Example Scenario**: Added 3 new functions across 5 files

### Tier 3: Deep Reasoning (Complexity 61-90)

**Primary**: `claude-opus-4.5`  
**Alternatives**: `gpt-5.2`, `claude-sonnet-4.0`, `gemini-3-pro`

**Best For**:
- Complex refactoring
- Multi-file changes
- Architecture decisions
- Deep code analysis

**Example Scenario**: Refactored core module, 500+ lines changed

### Tier 4: Agentic (Complexity 91+)

**Primary**: `claude-opus-4.6`  
**Alternatives**: `gpt-5.2-codex`, `gpt-5.1-codex-max`

**Best For**:
- Architectural changes
- System-wide refactors
- Breaking changes
- Complex problem-solving

**Example Scenario**: Redesigned entire authentication system

---

## Complexity Calculation

### Code Complexity Formula

```
score = (cyclomatic_complexity × 2.0) + 
        (lines_changed / 10) + 
        (function_depth × 1.5) +
        semantic_factor
```

**Components**:
- **Cyclomatic Complexity**: Counts control flow paths (if, for, while, switch, &&, ||, ?:)
- **Lines Changed**: Total insertions + deletions from git diff
- **Function Depth**: Maximum nesting level of functions/blocks
- **Semantic Factor**: Detected from commit messages
  - `minor_change` = +5
  - `enhancement` = +15
  - `major_refactor` = +30
  - `architectural_change` = +50

### Documentation Complexity Formula

```
score = (words_changed / 100) + 
        (files_affected × 0.5) +
        (structural_changes × 2.0) +
        (primary_doc_modifier × 5.0)
```

**Components**:
- **Words Changed**: Estimated from lines (lines × 10)
- **Files Affected**: Number of documentation files modified
- **Structural Changes**: Heading/table/list modifications
- **Primary Doc Modifier**: +5 if README.md or main index changed

### Test Complexity Formula

```
score = (test_cases_affected × 1.5) +
        (lines_changed / 20) +
        (coverage_impact × 2.0)
```

**Components**:
- **Test Cases**: Count of test/it/describe blocks
- **Lines Changed**: Total modifications in test files
- **Coverage Impact**: Estimated from commit messages
  - `minor_update` = +5
  - `new_coverage` = +15
  - `major_expansion` = +30

---

## Configuration

### Configuration File

Create `.workflow_core/config/model_selection_rules.yaml` to customize:

```yaml
model_selection:
  enabled: true

thresholds:
  tier_1_max: 25    # Adjust tier boundaries
  tier_2_max: 60
  tier_3_max: 90

tier_preferences:
  tier_1_fast:
    primary: claude-haiku-4.5
    alternatives:
      - gpt-5-mini
  # ... customize models per tier

complexity_weights:
  code:
    cyclomatic_multiplier: 2.0  # Adjust weights
    lines_per_point: 10
    # ... other weights

step_overrides:
  step_06_test_gen:
    tier_adjustment: +1  # Always use one tier higher
```

### Project Configuration

In `.workflow-config.yaml`:

```yaml
model_selection:
  enabled: true
  # Future: project-specific overrides
```

---

## CLI Options

### --force-model <model>

Override automatic selection and use specific model for all steps.

```bash
# Use most powerful model everywhere
./execute_tests_docs_workflow.sh --force-model claude-opus-4.6

# Use fastest model everywhere (e.g., for testing)
./execute_tests_docs_workflow.sh --force-model claude-haiku-4.5
```

**Supported Models**:
- Claude: `claude-haiku-4.5`, `claude-sonnet-4.0`, `claude-sonnet-4.5`, `claude-opus-4.5`, `claude-opus-4.6`
- GPT: `gpt-4.1`, `gpt-5`, `gpt-5-mini`, `gpt-5.1`, `gpt-5.1-codex`, `gpt-5.2`, `gpt-5.2-codex`
- Gemini: `gemini-2.5-pro`, `gemini-3-flash`, `gemini-3-pro`
- Others: `grok-code-fast-1`, `qwen2.5`, `raptor-mini`

**Validation**: Invalid model names are rejected with suggestions:

```
ERROR: Invalid model name: claude-opus-10

Supported models:
  - claude-haiku-4.5
  - claude-opus-4.5
  ...

Did you mean one of these?
  - claude-opus-4.5
  - claude-opus-4.6
```

### --show-model-plan

Preview model assignments without executing workflow.

```bash
./execute_tests_docs_workflow.sh --show-model-plan
```

**Output**:
```
=== Model Selection Plan ===

Change Analysis:
  Code:          15 files (complexity: 72 → HIGH)
  Documentation:  3 files (complexity: 15 → LOW)
  Tests:          2 files (complexity: 38 → MEDIUM)

Model Assignments:
  Step 1 (Documentation):  claude-haiku-4.5 (fast)
  Step 5 (Test Review):    claude-sonnet-4.5 (balanced)
  Step 9 (Code Quality):   claude-opus-4.5 (deep reasoning)
  ... [all steps listed]

Estimated Token Usage: ~45K tokens
Estimated Cost Savings: 35% vs. using high-tier everywhere
```

---

## Troubleshooting

### Model Selection Not Running

**Symptom**: No model selection output in Step 0

**Solutions**:
1. Check if model_selector.sh is present: `ls src/workflow/lib/model_selector.sh`
2. Ensure feature is enabled (default: true)
3. Check Step 0 logs for errors

### Invalid JSON Error

**Symptom**: "ERROR: Invalid JSON generated"

**Solutions**:
1. Check if `jq` is installed: `which jq`
2. Verify git repository is valid: `git status`
3. Check Step 0 logs for generation errors

### Model Not Available

**Symptom**: Warning about unavailable model

**Solutions**:
1. System automatically falls back to alternatives
2. Use `--force-model` with a known-available model
3. Update GitHub Copilot CLI: `npm install -g @githubnext/github-copilot-cli`

### Complexity Seems Wrong

**Symptom**: Simple changes getting high-tier models (or vice versa)

**Solutions**:
1. Review `.ai_workflow/model_definitions.json` to see factors
2. Adjust thresholds in `model_selection_rules.yaml`
3. Use `--force-model` to override if needed
4. Check commit messages (they influence semantic analysis)

---

## Advanced Usage

### Custom Complexity Thresholds

For projects with different characteristics, adjust thresholds:

```yaml
# .workflow_core/config/model_selection_rules.yaml
thresholds:
  tier_1_max: 30    # Wider range for fast models
  tier_2_max: 70    # More tasks use balanced models
  tier_3_max: 95    # Reserve agentic for truly complex
```

### Step-Specific Overrides

Force certain steps to always use specific tiers:

```yaml
step_overrides:
  step_13_prompt_engineer:
    force_tier: tier_3_deep  # Always deep reasoning
  
  step_01_documentation:
    tier_adjustment: -1  # Use one tier lower (docs are simpler)
```

### Integration with CI/CD

```yaml
# .github/workflows/ai-workflow.yml
- name: Run AI Workflow
  run: |
    ./execute_tests_docs_workflow.sh \
      --auto \
      --smart-execution \
      --parallel \
      --force-model claude-sonnet-4.5  # Consistent for CI
```

### Metrics Tracking

Monitor model selection effectiveness:

```bash
# Check model_definitions.json from recent runs
jq '.model_definitions | to_entries[] | {step: .key, model: .value.model, reason: .value.reason}' \
  .ai_workflow/model_definitions.json
```

---

## FAQ

**Q: Does this increase costs?**  
A: No, it typically reduces costs by 30-50% by using faster models for simple tasks.

**Q: Can I disable this feature?**  
A: Yes, set `model_selection.enabled: false` in config. Workflow uses defaults.

**Q: What if I prefer a specific model?**  
A: Use `--force-model <model>` to override for a run, or configure in YAML for permanence.

**Q: How accurate is complexity calculation?**  
A: Generally good for typical projects. Adjust thresholds if needed for your specific codebase.

**Q: Does it work offline?**  
A: Model selection works offline (analyzes git locally). Model execution requires internet.

**Q: Can I see what models were used in past runs?**  
A: Yes, check `backlog/workflow_*/model_definitions.json` or workflow logs.

---

## Related Documentation

- [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) - Complete feature reference
- [GitHub Copilot Models](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) - Official model comparison
- [CHANGELOG.md](../CHANGELOG.md) - Version history

---

**Last Updated**: 2026-02-06  
**Feature Version**: v3.2.0
