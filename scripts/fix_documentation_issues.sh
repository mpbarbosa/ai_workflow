#!/usr/bin/env bash
# Quick Fix Script for Documentation Issues
# Generated: 2026-02-08
# Based on: DOCUMENTATION_CONSISTENCY_ANALYSIS_20260208.md

set -euo pipefail

# Change to repository root
cd "$(dirname "$0")/.."

echo "🔧 Applying documentation fixes..."
echo "📁 Working directory: $(pwd)"
echo ""

# Fix 1: Update COOKBOOK.md version
echo "📝 Updating COOKBOOK.md version..."
sed -i 's/Workflow Version.*: v3\.2\.7/Workflow Version: v4.0.0/' docs/COOKBOOK.md
echo "✅ COOKBOOK.md version updated"

# Fix 2: Standardize "See Also" sections
echo "📝 Standardizing 'See Also' sections..."
find docs/ -name "*.md" -type f -exec sed -i 's/^## See also$/## See Also/' {} \;
echo "✅ 'See Also' sections standardized"

# Fix 3: Remove reference to non-existent MIGRATION_REPORT
echo "📝 Removing broken MIGRATION_REPORT references..."
find docs/ -name "*.md" -type f -exec sed -i '/MIGRATION_REPORT_20260208_160759\.md/d' {} \;
echo "✅ Broken MIGRATION_REPORT references removed"

# Fix 4: Update relative paths to PROJECT_REFERENCE.md
echo "📝 Fixing PROJECT_REFERENCE.md paths..."
find docs/ -name "*.md" -type f -exec sed -i 's|../../../docs/PROJECT_REFERENCE.md|../PROJECT_REFERENCE.md|g' {} \;
find docs/ -name "*.md" -type f -exec sed -i 's|../../../../PROJECT_REFERENCE.md|PROJECT_REFERENCE.md|g' {} \;
echo "✅ PROJECT_REFERENCE.md paths fixed"

# Fix 5: Create docs/api/core structure with redirects
echo "📝 Creating API core structure..."
mkdir -p docs/api/core
cat > docs/api/core/README.md << 'EOF'
# API Core Documentation

This section has been consolidated into the comprehensive API reference.

Please see: [Complete API Reference](../LIBRARY_MODULES_COMPLETE_API.md)

## Core Modules Covered

- [ai_helpers.sh](../LIBRARY_MODULES_COMPLETE_API.md#ai_helperssh)
- [change_detection.sh](../LIBRARY_MODULES_COMPLETE_API.md#change_detectionsh)
- [workflow_optimization.sh](../LIBRARY_MODULES_COMPLETE_API.md#workflow_optimizationsh)
- [All 81 modules](../LIBRARY_MODULES_COMPLETE_API.md)

---

**See**: [Complete API Reference](../LIBRARY_MODULES_COMPLETE_API.md)
EOF
echo "✅ API core structure created with redirects"

# Fix 6: Update references to point to comprehensive guide instead of non-existent core files
echo "📝 Updating api/core/ references..."
find docs/ -name "*.md" -type f -exec sed -i 's|api/core/ai_helpers\.md|api/LIBRARY_MODULES_COMPLETE_API.md#ai_helperssh|g' {} \;
find docs/ -name "*.md" -type f -exec sed -i 's|api/core/change_detection\.md|api/LIBRARY_MODULES_COMPLETE_API.md#change_detectionsh|g' {} \;
find docs/ -name "*.md" -type f -exec sed -i 's|api/core/workflow_optimization\.md|api/LIBRARY_MODULES_COMPLETE_API.md#workflow_optimizationsh|g' {} \;
echo "✅ API core references updated"

# Fix 7: Add archive notices to old version documentation
echo "📝 Adding archive notices..."
for file in docs/DOCUMENTATION_ISSUES_2025-12-24.md docs/DOCUMENTATION_FIXES_APPLIED_2025-12-24.md; do
  if [ -f "$file" ] && ! grep -q "ARCHIVED" "$file"; then
    # Insert at line 1
    sed -i '1i> ⚠️ **ARCHIVED**: This document reflects analysis from an earlier date. See [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) for current information.\n' "$file"
  fi
done
echo "✅ Archive notices added"

# Fix 8: Remove broken architecture references or create redirects
echo "📝 Handling architecture doc references..."
if [ ! -f "docs/architecture/AI_INTEGRATION.md" ]; then
  cat > docs/architecture/AI_INTEGRATION.md << 'EOF'
# AI Integration Architecture

This topic is now covered in the comprehensive architecture guide.

Please see: [System Architecture Guide - AI Integration](COMPREHENSIVE_ARCHITECTURE_GUIDE.md#ai-integration-modules)

---

**Redirect to**: [Comprehensive Architecture Guide](COMPREHENSIVE_ARCHITECTURE_GUIDE.md)
EOF
fi

if [ ! -f "docs/architecture/CHANGE_DETECTION.md" ]; then
  cat > docs/architecture/CHANGE_DETECTION.md << 'EOF'
# Change Detection Architecture

This topic is now covered in the comprehensive architecture guide.

Please see: [System Architecture Guide - Change Detection](COMPREHENSIVE_ARCHITECTURE_GUIDE.md#change-detectionsh)

---

**Redirect to**: [Comprehensive Architecture Guide](COMPREHENSIVE_ARCHITECTURE_GUIDE.md)
EOF
fi
echo "✅ Architecture redirects created"

# Fix 9: Remove references to MIGRATION_README.md if it doesn't exist
if [ ! -f "docs/MIGRATION_README.md" ]; then
  echo "📝 Removing broken MIGRATION_README references..."
  find docs/ -name "*.md" -type f -exec sed -i '/MIGRATION_README\.md/d' {} \;
  echo "✅ MIGRATION_README references removed"
fi

# Fix 10: Check and report remaining issues
echo ""
echo "🔍 Checking for remaining broken links..."
remaining_issues=0

# Check for common broken patterns
for pattern in "STEP_15_VERSION_UPDATE_IMPLEMENTATION" "MULTI_STAGE_PIPELINE_GUIDE" "STEP1_OPTIMIZATION_GUIDE"; do
  if grep -r "$pattern\.md" docs/ 2>/dev/null | grep -v "Binary" | grep -q .; then
    echo "⚠️  Still has references to: $pattern.md"
    remaining_issues=$((remaining_issues + 1))
  fi
done

if [ $remaining_issues -eq 0 ]; then
  echo "✅ All major broken links fixed!"
else
  echo "⚠️  $remaining_issues potential issues remain (see above)"
fi

echo ""
echo "✨ Documentation fixes completed!"
echo ""
echo "📊 Summary:"
echo "  ✅ Version numbers updated"
echo "  ✅ 'See Also' sections standardized"
echo "  ✅ Broken link references removed"
echo "  ✅ API core structure created"
echo "  ✅ Archive notices added"
echo "  ✅ Architecture redirects created"
echo ""
echo "📝 Next steps:"
echo "  1. Review changes: git diff docs/"
echo "  2. Test documentation: open docs/README.md"
echo "  3. Commit changes: git add docs/ && git commit -m 'fix: documentation consistency issues'"
echo ""
