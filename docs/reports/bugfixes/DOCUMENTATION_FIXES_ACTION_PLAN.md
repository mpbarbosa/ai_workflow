# Documentation Fixes - Action Plan

**Date**: 2025-12-24  
**Based On**: DOCUMENTATION_CONSISTENCY_ANALYSIS_COMPREHENSIVE_20251224.md  
**Priority**: HIGH  
**Estimated Time**: 15 minutes

---

## Summary

Two minor documentation updates needed to achieve 9.5/10 documentation quality score:

1. ✅ Update library module count (28 → 32) in PROJECT_REFERENCE.md
2. ✅ Add AI persona architecture clarification

---

## Action 1: Update Module Count in PROJECT_REFERENCE.md

**File**: `docs/PROJECT_REFERENCE.md`  
**Location**: Line ~60-100 (Module Inventory section)  
**Current**: References "28 library modules"  
**Correction**: Update to "32 library modules"

**Current Text** (approximate):
```markdown
### Library Modules (28 total in src/workflow/lib/)
```

**Updated Text**:
```markdown
### Library Modules (32 total in src/workflow/lib/)

> **Note**: Count updated 2025-12-24. Previous documentation referenced 28 modules 
> before recent module additions (ai_prompt_builder.sh, ai_personas.sh, 
> ai_validation.sh, cleanup_handlers.sh).
```

**Verification Command**:
```bash
find src/workflow/lib -name "*.sh" -type f | wc -l
# Should output: 32
```

**Additional Updates in Same Section**:
- Update the module list to include all 32 shell scripts
- Verify line counts are current
- Check that new modules added in v2.3.0-v2.4.0 are listed

---

## Action 2: Clarify AI Persona Architecture

**File**: `docs/PROJECT_REFERENCE.md` (or README.md)  
**Location**: AI Personas section (after listing personas)  
**Purpose**: Explain the flexible persona system

**Add This Note**:

```markdown
## AI Personas Architecture

The AI Workflow uses a **flexible persona system** rather than a fixed count:

### System Design
- **9 Base Prompt Templates** (in `.workflow_core/config/ai_helpers.yaml`)
  - doc_analysis_prompt
  - consistency_prompt  
  - test_strategy_prompt
  - quality_prompt
  - issue_extraction_prompt
  - markdown_lint_prompt
  - language_specific_documentation
  - language_specific_quality
  - language_specific_testing

- **4 Specialized Persona Types** (in `.workflow_core/config/ai_prompts_project_kinds.yaml`)
  - documentation_specialist (adapts per project kind)
  - code_reviewer (adapts per project kind)
  - test_engineer (adapts per project kind)
  - ux_designer (NEW v2.4.0, adapts per project kind)

### How It Works
1. Base prompts provide general guidance
2. Specialized persona types customize behavior for project kind
3. System dynamically constructs prompts based on context
4. Language-specific enhancements applied when PRIMARY_LANGUAGE set

**Total Functional Personas**: The "14 AI Personas" reference counts unique 
persona applications across workflow steps. The actual architecture is more 
sophisticated: each step may use multiple base prompts + specialized persona 
adaptations.

### Example
Step 2 (Documentation Consistency) uses:
- Base: consistency_prompt
- Specialized: documentation_specialist (shell_automation variant)
- Enhancement: language_specific_documentation (if PRIMARY_LANGUAGE=bash)

This flexible design allows the same workflow to adapt intelligently to different 
project types (Node.js API, React SPA, Python CLI, etc.) without code changes.
```

**Placement**: Add after the AI Personas list in PROJECT_REFERENCE.md, or in a new 
section in docs/reference/personas.md

---

## Action 3: Optional - Add Note to Archived Reports

**Priority**: LOW (can defer)  
**Files**: 29 files in `docs/archive/reports/` referencing `/shell_scripts/`

**Option A**: Add disclaimer at top of each archived report
```markdown
> **Historical Note (2025-12-24)**: This archived report references the 
> `/shell_scripts/` directory structure from before the 2025-12-18 migration 
> to the `ai_workflow` repository. Current scripts are located in `src/workflow/`.
```

**Option B**: Create a single README in docs/archive/reports/ explaining context
```markdown
# Archived Reports - Directory Structure Note

These reports were created before the 2025-12-18 repository migration.

**Directory Mapping**:
- `/shell_scripts/` → `src/workflow/` (current location)
- `/shell_scripts/README.md` → `src/workflow/README.md`
- `/shell_scripts/CHANGELOG.md` → Not applicable (see Git history)

All functionality has been preserved; only the directory structure changed.
```

---

## Verification Checklist

After making changes, verify:

- [ ] Module count in PROJECT_REFERENCE.md matches actual: `find src/workflow/lib -name "*.sh" | wc -l`
- [ ] All 32 library modules are listed in inventory section
- [ ] AI persona architecture explanation is clear and accurate
- [ ] No new broken links introduced
- [ ] Documentation still passes markdown linting
- [ ] Version numbers remain consistent (v2.4.0)

---

## Commands to Verify Changes

```bash
# Change to project root
cd /home/mpb/Documents/GitHub/ai_workflow

# Verify module counts
echo "Library modules (.sh):"
find src/workflow/lib -name "*.sh" -type f | wc -l
# Expected: 32

echo "Step modules (.sh):"
find src/workflow/steps -name "*.sh" -type f | wc -l
# Expected: 15

echo "Orchestrator modules (.sh):"
find src/workflow/orchestrators -name "*.sh" -type f | wc -l
# Expected: 4

# Check documentation references
echo "Checking module count references:"
grep -n "Library Modules" docs/PROJECT_REFERENCE.md

echo "Checking AI persona references:"
grep -n "AI Personas\|ai_personas" docs/PROJECT_REFERENCE.md

# Verify no broken links in main docs
echo "Checking for broken internal links (main docs):"
find docs/{user-guide,developer-guide,reference,design} -name "*.md" -exec grep -l "\[.*\](\/[^h]" {} \; 2>/dev/null | wc -l
# Expected: 0 or very few

# Run markdown linting (if available)
# npx markdownlint docs/PROJECT_REFERENCE.md
```

---

## Risk Assessment

**Risk Level**: **LOW** ✅

**Rationale**:
- Only 2 documentation files being updated
- Changes are clarifications/corrections, not rewrites
- No code changes required
- No breaking changes to APIs or functionality
- Updates improve accuracy without changing meaning

**Rollback Plan**: 
- Git revert if any issues
- Previous documentation remains in Git history

---

## Expected Outcome

**Before**: 8.5/10 documentation quality  
**After**: 9.5/10 documentation quality

**Improvements**:
- ✅ Accurate module count in single source of truth
- ✅ Clear explanation of AI persona architecture
- ✅ Better developer understanding of system design
- ✅ No misleading or outdated information

---

## Time Estimate

- Action 1 (Module count update): 5 minutes
- Action 2 (AI persona clarification): 10 minutes
- Verification: 5 minutes
- **Total**: 20 minutes

---

## Next Steps

1. Review this action plan
2. Execute Action 1 (update module count)
3. Execute Action 2 (add persona architecture note)
4. Run verification commands
5. Commit changes with message: `docs: update module count and clarify AI persona architecture`
6. Optional: Address archived reports (Action 3) in future maintenance session

---

**Prepared By**: Documentation Consistency Analysis System  
**Approved By**: Awaiting review  
**Status**: READY TO EXECUTE

---

**END OF ACTION PLAN**
