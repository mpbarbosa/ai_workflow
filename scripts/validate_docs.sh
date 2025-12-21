#!/usr/bin/env bash
set -euo pipefail

# Documentation Validation Script v1.0.0
# Last Updated: 2025-12-20

cd "$(dirname "$0")/.."

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

ERRORS=0; WARNINGS=0; CHECKS=0

error() { echo -e "${RED}✗ ERROR${NC}: $*" >&2; ((ERRORS++)); }
warning() { echo -e "${YELLOW}⚠ WARNING${NC}: $*" >&2; ((WARNINGS++)); }
success() { echo -e "${GREEN}✓${NC} $*"; }
info() { echo -e "${BLUE}ℹ${NC} $*"; }

echo "╔════════════════════════════════════════════════════════╗"
echo "║      Documentation Validation Script v1.0.0           ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. Verify actual module counts
echo "═══ Module Count Verification ═══"
LIB_SH=$(find src/workflow/lib -name "*.sh" ! -name "test_*" 2>/dev/null | wc -l)
LIB_YAML=$(find src/workflow/lib -name "*.yaml" 2>/dev/null | wc -l)
LIB_TOTAL=$((LIB_SH + LIB_YAML))
STEPS=$(find src/workflow/steps -name "step_*.sh" 2>/dev/null | wc -l)

info "Actual counts: $LIB_TOTAL library modules ($LIB_SH .sh + $LIB_YAML .yaml), $STEPS steps"

((CHECKS++))
if [[ $LIB_TOTAL -eq 28 ]]; then
    success "Library module count: 28 (correct)"
else
    error "Library module count: $LIB_TOTAL (expected 28)"
fi

((CHECKS++))
if [[ $STEPS -eq 14 ]]; then
    success "Step module count: 14 (correct)"
else
    error "Step module count: $STEPS (expected 14)"
fi

# 2. Check version consistency
echo ""
echo "═══ Version Consistency ═══"
CANON_VER=$(grep -oP 'v\d+\.\d+\.\d+' PROJECT_STATISTICS.md | head -1)
info "Canonical version: $CANON_VER"

for file in README.md .github/copilot-instructions.md MIGRATION_README.md; do
    ((CHECKS++))
    if grep -q "$CANON_VER" "$file" 2>/dev/null; then
        success "$file has version $CANON_VER"
    else
        error "$file missing version $CANON_VER"
    fi
done

# 3. Check module count references
echo ""
echo "═══ Module Count References ═══"
for file in README.md .github/copilot-instructions.md MIGRATION_README.md; do
    ((CHECKS++))
    if grep -qi "28.*library.*modules\|library.*modules.*28" "$file" 2>/dev/null; then
        success "$file references 28 library modules"
    else
        error "$file does not reference 28 library modules"
    fi
done

# 4. Check line count references or PROJECT_STATISTICS.md mention
echo ""
echo "═══ Line Count References ═══"
for file in README.md .github/copilot-instructions.md MIGRATION_README.md; do
    ((CHECKS++))
    if grep -q "24,146\|PROJECT_STATISTICS.md" "$file" 2>/dev/null; then
        success "$file references canonical line count or PROJECT_STATISTICS.md"
    else
        warning "$file may have outdated line count"
    fi
done

# 5. Check PROJECT_STATISTICS.md timestamp
echo ""
echo "═══ Timestamp Check ═══"
((CHECKS++))
if grep -q "Last Updated.*2025-" PROJECT_STATISTICS.md 2>/dev/null; then
    success "PROJECT_STATISTICS.md has Last Updated timestamp"
else
    warning "PROJECT_STATISTICS.md missing Last Updated timestamp"
fi

# Summary
echo ""
echo "═══ Summary ═══"
echo "Total checks: $CHECKS"
echo -e "${GREEN}Passed: $((CHECKS - ERRORS - WARNINGS))${NC}"
[[ $WARNINGS -gt 0 ]] && echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
[[ $ERRORS -gt 0 ]] && echo -e "${RED}Errors: $ERRORS${NC}"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    error "Validation failed"
    exit 1
else
    success "Validation passed!"
    exit 0
fi
