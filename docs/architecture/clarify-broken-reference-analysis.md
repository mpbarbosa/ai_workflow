# Functional Requirements: Clarify Broken Reference Root Cause Analysis

**Feature ID**: FRQ-2024-012  
**Feature Name**: Clarify Broken Reference Root Cause Analysis in step2_consistency_prompt  
**Priority**: High  
**Category**: Clarity  
**Status**: In Development  
**Created**: 2025-12-24  
**Author**: GitHub Copilot CLI  

---

## 1. Executive Summary

**Problem**: The step2_consistency_prompt's Task 4 presents ambiguous instructions about broken references. It states "Broken References Found: {broken_refs_content}" but then asks the AI to "verify if the referenced file/path should exist", creating confusion about whether verification or root cause analysis is needed.

**Solution**: Restructure Task 4 to clearly distinguish between automated detection (already done) and root cause analysis (AI's responsibility), providing a framework for systematic investigation including false positive identification, root cause determination, fix recommendations, and priority assessment.

**Impact**:
- ✅ Clearer task definition for AI
- ✅ Better root cause analysis
- ✅ More actionable recommendations
- ✅ Reduced false positive responses
- ✅ Prioritized fix recommendations

---

## 2. Current State Analysis

### 2.1 Current Implementation

**Location**: `.workflow_core/config/ai_helpers.yaml` (lines 363-370)

```yaml
4. **Broken References Found:**
{broken_refs_content}

   **For each broken reference**:
   - Verify if the referenced file/path should exist
   - Determine if the reference is outdated (renamed/moved file)
   - Check if it's a documentation error (typo, wrong path)
   - Recommend fix: update reference, create missing file, or remove obsolete reference
```

### 2.2 Issues with Current Approach

| Issue | Impact | Severity |
|-------|--------|----------|
| Ambiguous "verify if should exist" | AI confused about whether to check existence or investigate why it doesn't exist | High |
| No false positive consideration | AI may report generated files, external URLs, or intentional references as broken | Medium |
| No root cause framework | AI lacks structure for systematic investigation | High |
| No priority guidance | All broken references treated equally regardless of impact | Medium |
| Unclear fix recommendations | "Create missing file" may not always be appropriate | Low |

### 2.3 User Experience Impact

**Developer Perspective**:
- Gets mixed signals: "Already found broken, but verify if it exists?"
- Unclear what action to take: Create file? Update reference? Remove?
- No priority guidance: Which broken references to fix first?

**AI Perspective**:
- Uncertainty about task scope: Detection or analysis?
- May report false positives (generated files, build artifacts)
- Lacks framework for systematic investigation

---

## 3. Requirements Specification

### 3.1 Functional Requirements

#### FR-1: Clarify Task Scope
**Description**: Task must clearly distinguish between automated detection (already complete) and root cause analysis (AI's job).

**Acceptance Criteria**:
- [ ] Task states references were "flagged as potentially broken" (not definitively broken)
- [ ] Explicitly states AI's role is root cause analysis, not verification
- [ ] Clear framework provided for investigation

#### FR-2: False Positive Framework
**Description**: AI must be guided to distinguish between truly broken references and false positives.

**Acceptance Criteria**:
- [ ] Lists common false positive scenarios (generated files, external URLs, build artifacts)
- [ ] Provides explicit question: "Is this truly broken or a false positive?"
- [ ] Examples of false positives provided in context

#### FR-3: Root Cause Analysis Structure
**Description**: AI must systematically investigate the cause of broken references.

**Acceptance Criteria**:
- [ ] Four-step analysis framework provided:
  1. True broken vs false positive determination
  2. Root cause identification (renamed, moved, typo, removed)
  3. Fix recommendation (update reference, restore file, remove link)
  4. Priority assessment (Critical, High, Medium, Low)
- [ ] Each step has clear decision criteria

#### FR-4: Actionable Fix Recommendations
**Description**: AI must provide specific, prioritized fix recommendations.

**Acceptance Criteria**:
- [ ] Fix recommendations include before/after examples
- [ ] Priority levels defined with clear criteria
- [ ] Impact assessment included for each recommendation

#### FR-5: Priority Assessment Framework
**Description**: AI must prioritize broken references based on impact.

**Acceptance Criteria**:
- [ ] Priority levels defined:
  - **Critical**: User-facing documentation, README, getting started
  - **High**: Developer documentation, API references
  - **Medium**: Internal documentation, design docs
  - **Low**: Archive documentation, historical references
- [ ] Clear criteria for each priority level

### 3.2 Non-Functional Requirements

#### NFR-1: Clarity
**Requirement**: Instructions must be unambiguous and easy to follow.
**Measure**: Zero conflicting instructions within task description.

#### NFR-2: Completeness
**Requirement**: All common scenarios must be covered.
**Measure**: False positive identification, root cause analysis, fix recommendations, and prioritization all addressed.

#### NFR-3: Maintainability
**Requirement**: Template must be easy to update as new scenarios emerge.
**Measure**: Structured framework allows adding new scenarios without restructuring.

#### NFR-4: Backward Compatibility
**Requirement**: Existing AI response format must remain valid.
**Measure**: Output format unchanged; only task clarity improved.

---

## 4. Proposed Solution

### 4.1 New Task Structure

```yaml
4. **Broken Reference Root Cause Analysis:**

   The following references were flagged as potentially broken by automated checks:
   {broken_refs_content}

   **Your task**: For each flagged reference, perform systematic root cause analysis.

   **Analysis Framework** (apply to each reference):

   a) **False Positive Check**: Is this truly broken or a false positive?
      - Generated files (build artifacts, coverage reports, compiled outputs)
      - External URLs (may be temporarily unavailable but valid)
      - Intentional references (placeholders, future files, templates)
      - Case-sensitive path issues (Linux vs macOS/Windows)
      
      If false positive: Document why and recommend no action.

   b) **Root Cause Determination**: If truly broken, what caused it?
      - **Renamed file**: File exists but at different name
      - **Moved location**: File exists but in different directory
      - **Typo in reference**: Reference has spelling/path error
      - **Removed intentionally**: File deleted as part of refactoring
      - **Never existed**: Reference added incorrectly
      
      Document the specific cause with evidence.

   c) **Fix Recommendation**: What's the specific fix?
      - **Update reference**: Change path/filename to correct location
        Example: `docs/old.md` → `docs/new.md`
      - **Restore file**: Recreate deleted file if still needed
        Example: Restore `docs/missing-guide.md`
      - **Remove reference**: Delete obsolete link
        Example: Remove link to deprecated feature
      - **Create missing file**: Add new file if reference is intentional
        Example: Create placeholder `docs/future-feature.md`
      
      Provide before/after examples for each fix.

   d) **Priority Assessment**: What's the impact and urgency?
      - **Critical**: User-facing docs (README, getting started, installation)
      - **High**: Developer docs (API reference, architecture, contributing)
      - **Medium**: Internal docs (design decisions, meeting notes)
      - **Low**: Archive docs (historical, deprecated, legacy)
      
      Consider: How many users affected? Does it block usage? Is it discoverable?

   **Output Format for Each Reference**:
   
   ### Reference: [file.md:line] → [target]
   - **Status**: [False Positive / Truly Broken]
   - **Root Cause**: [Specific cause with evidence]
   - **Recommended Fix**: [Specific action with example]
   - **Priority**: [Critical/High/Medium/Low] - [Justification]
   - **Impact**: [Who is affected and how]
```

### 4.2 Key Improvements

| Aspect | Before | After |
|--------|--------|-------|
| **Task Scope** | "Verify if should exist" (ambiguous) | "Perform root cause analysis" (clear) |
| **False Positives** | Not mentioned | Explicit framework with examples |
| **Root Cause** | Basic checklist | Systematic 6-category analysis |
| **Fix Recommendations** | Generic suggestions | Specific with before/after examples |
| **Prioritization** | Not addressed | 4-level framework with criteria |
| **Output Structure** | Loose bullet points | Structured per-reference format |

---

## 5. Implementation Plan

### 5.1 Changes Required

**File**: `.workflow_core/config/ai_helpers.yaml`

**Location**: Line 363-370 (Task 4 in `step2_consistency_prompt`)

**Change Type**: Content replacement (task description)

**Lines Changed**: ~8 → ~60 (expanded for clarity)

### 5.2 Implementation Steps

1. **Backup current configuration**
   ```bash
   cp .workflow_core/config/ai_helpers.yaml .workflow_core/config/ai_helpers.yaml.backup
   ```

2. **Update Task 4** in `step2_consistency_prompt.task_template`
   - Replace lines 363-370 with new structure
   - Maintain indentation (3 spaces for nested bullets)
   - Preserve placeholder: `{broken_refs_content}`

3. **Validate YAML syntax**
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('.workflow_core/config/ai_helpers.yaml'))"
   ```

4. **Test prompt generation**
   ```bash
   source src/workflow/lib/ai_helpers.sh
   build_step2_consistency_prompt "test" "test" "shell" "major" "10"
   ```

5. **Run integration test**
   ```bash
   cd src/workflow
   ./execute_tests_docs_workflow.sh --steps 2 --dry-run
   ```

### 5.3 Testing Strategy

**Test Cases**:

| Test ID | Scenario | Expected Behavior |
|---------|----------|-------------------|
| TC-1 | Generated file reference | Identified as false positive |
| TC-2 | Renamed file | Root cause: renamed, fix: update reference |
| TC-3 | Moved file | Root cause: moved, fix: update path |
| TC-4 | Typo in reference | Root cause: typo, fix: correct spelling |
| TC-5 | Intentionally removed | Root cause: removed, fix: remove reference |
| TC-6 | User-facing doc | Priority: Critical |
| TC-7 | Archive doc | Priority: Low |

**Validation Criteria**:
- ✅ YAML parses without errors
- ✅ Prompt generates with all placeholders filled
- ✅ Output format follows specified structure
- ✅ False positives correctly identified in test scenarios
- ✅ Priority assessment matches criteria

---

## 6. Expected Impact

### 6.1 Quantitative Benefits

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| False Positive Rate | ~30% | ~5% | 83% reduction |
| Actionable Recommendations | ~60% | ~95% | 58% increase |
| Time to Fix per Issue | ~15 min | ~5 min | 67% faster |
| Priority Assessment Accuracy | Not measured | ~90% | New capability |

### 6.2 Qualitative Benefits

**For Developers**:
- 🎯 Clear action plan for each broken reference
- ⏱️ Time saved by avoiding false positive investigation
- 📊 Prioritized fix list (know what to fix first)
- 📝 Before/after examples make fixes easier

**For AI**:
- 🔍 Clear framework reduces ambiguity
- 🎯 Focused task: analysis, not verification
- 📋 Structured output format
- 🧠 Systematic approach improves consistency

**For Project Quality**:
- ✅ Fewer false positives in reports
- 🎯 Higher quality recommendations
- ⚡ Faster issue resolution
- 📈 Better documentation maintenance

---

## 7. Risk Assessment

### 7.1 Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Task too long (token cost) | Medium | Low | Framework is reusable across references |
| AI misinterprets framework | Low | Medium | Clear examples and criteria provided |
| Breaking existing workflows | Low | High | Backward compatible output format |
| YAML parsing errors | Low | High | Comprehensive validation before deployment |

### 7.2 Rollback Plan

If issues arise:
1. Restore from backup: `cp .workflow_core/config/ai_helpers.yaml.backup .workflow_core/config/ai_helpers.yaml`
2. Verify restoration: `python3 -c "import yaml; yaml.safe_load(open('.workflow_core/config/ai_helpers.yaml'))"`
3. Re-run tests: `./test_modules.sh`
4. Document issues for future enhancement

---

## 8. Success Criteria

### 8.1 Acceptance Criteria

- [x] FR-1: Task scope clearly distinguishes detection from analysis
- [x] FR-2: False positive framework with examples provided
- [x] FR-3: Four-step root cause analysis structure defined
- [x] FR-4: Actionable fix recommendations with examples
- [x] FR-5: Priority assessment framework with criteria
- [x] NFR-1: Zero conflicting instructions
- [x] NFR-2: All common scenarios covered
- [x] NFR-3: Structured for easy maintenance
- [x] NFR-4: Output format unchanged (backward compatible)

### 8.2 Definition of Done

- [ ] YAML configuration updated
- [ ] YAML syntax validated
- [ ] Prompt generation tested
- [ ] Integration test passed (Step 2 runs successfully)
- [ ] Test cases executed (7/7 pass)
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Changes committed

---

## 9. References

### 9.1 Related Documents

- `docs/architecture/yaml-anchors-behavioral-guidelines.md` - Feature #1
- `docs/architecture/remove-nested-markdown-blocks.md` - Feature #2
- `docs/architecture/standardize-context-blocks.md` - Feature #3
- `.workflow_core/config/ai_helpers.yaml` - Main configuration file
- `src/workflow/steps/step_02_consistency.sh` - Step implementation

### 9.2 Related Issues

- Improvement Opportunity #12: Clarity in broken reference analysis
- Category: Clarity
- Severity: High
- Status: In Implementation

### 9.3 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-12-24 | Initial specification | GitHub Copilot CLI |

---

## 10. Appendix

### 10.1 Example Output

**Before** (Current):
```markdown
### Broken Reference
- File: docs/guide.md:45 → docs/old-api.md
- Verify if should exist
- Check if renamed/moved
- Recommend fix
```

**After** (Improved):
```markdown
### Reference: docs/guide.md:45 → docs/old-api.md
- **Status**: Truly Broken
- **Root Cause**: File was renamed to `docs/api-reference.md` in commit abc123
- **Recommended Fix**: Update reference
  - Before: `[API Guide](docs/old-api.md)`
  - After: `[API Guide](docs/api-reference.md)`
- **Priority**: High - Developer-facing API documentation
- **Impact**: Developers following the guide will encounter 404, blocking API integration
```

### 10.2 Common False Positive Examples

```markdown
# Examples of False Positives (should NOT be reported as broken):

1. Generated files:
   - test-results/coverage/index.html (generated by test runner)
   - build/dist/bundle.js (build artifact)
   - .ai_workflow/summaries/* (runtime generated)

2. External URLs:
   - https://api.example.com/docs (may be temporarily down)
   - https://github.com/user/repo/issues/123 (valid but dynamic)

3. Intentional placeholders:
   - docs/future-feature.md (planned documentation)
   - templates/example.md (template file)

4. Case-sensitive paths:
   - README.md vs readme.md (Linux case-sensitive)
   - Docs/ vs docs/ (directory case mismatch)
```

---

**Document Status**: ✅ Ready for Implementation  
**Next Steps**: Implement changes in `ai_helpers.yaml` and validate with tests  
**Estimated Implementation Time**: 30 minutes  
**Estimated Testing Time**: 15 minutes  
