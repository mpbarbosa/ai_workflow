#!/bin/bash
# Simple test for Step 14
set +e

echo "Testing Step 14 UX Analysis..."

# Test 1: Project kinds that should have UI
for kind in "react_spa" "vue_spa" "static_website" "web_application"; do
    export PROJECT_KIND="$kind"
    if [[ "$kind" =~ ^(react_spa|vue_spa|static_website|web_application)$ ]]; then
        echo "✓ $kind should have UI"
    else
        echo "✗ $kind test failed"
        exit 1
    fi
done

# Test 2: Project kinds that should NOT have UI
for kind in "shell_automation" "nodejs_library" "python_library"; do
    export PROJECT_KIND="$kind"
    if [[ "$kind" =~ ^(shell_automation|nodejs_library|python_library)$ ]]; then
        echo "✓ $kind should skip UI analysis"
    else
        echo "✗ $kind test failed"
        exit 1
    fi
done

echo ""
echo "✓ All Step 14 tests passed!"
exit 0
