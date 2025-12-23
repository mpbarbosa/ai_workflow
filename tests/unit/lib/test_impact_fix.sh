#!/bin/bash
# Quick validation test for impact calibration fix

source "$(dirname "$0")/change_detection.sh"

test_case() {
    git() {
        case "$*" in
            "diff --name-only HEAD") echo "$1" ;;
            "diff --cached --name-only") echo "" ;;
            "ls-files --others --exclude-standard") echo "" ;;
            *) return 0 ;;
        esac
    }
    export -f git FILES="$2"
    
    local result=$(assess_change_impact)
    unset -f git
    
    if [[ "$result" == "$3" ]]; then
        echo "✓ $1 → $result"
        return 0
    else
        echo "✗ $1 → expected $3, got $result"
        return 1
    fi
}

echo "=== Impact Calibration Tests (v2.3.1) ==="
failures=0

# Core bug fix: 35 docs + 2 code files should be Medium
git() {
    case "$*" in
        "diff --name-only HEAD") printf 'docs/f%d.md\n' {1..35}; echo 'src/a.js'; echo 'src/b.js' ;;
        "diff --cached --name-only") echo "" ;;
        "ls-files --others --exclude-standard") echo "" ;;
        *) return 0 ;;
    esac
}
export -f git
result=$(assess_change_impact)
if [[ "$result" == "medium" ]]; then
    echo "✓ CORE FIX: 2 code + 35 docs → medium"
else
    echo "✗ CORE FIX FAILED: 2 code + 35 docs → expected medium, got $result"
    ((failures++))
fi
unset -f git

# Additional validation tests
git() { case "$*" in "diff --name-only HEAD") printf 'docs/f%d.md\n' {1..35} ;; "diff --cached --name-only") echo "" ;; "ls-files --others --exclude-standard") echo "" ;; *) return 0 ;; esac; }
export -f git
[[ $(assess_change_impact) == "low" ]] && echo "✓ 35 docs only → low" || { echo "✗ 35 docs failed"; ((failures++)); }
unset -f git

git() { case "$*" in "diff --name-only HEAD") echo 'src/a.js' ;; "diff --cached --name-only") echo "" ;; "ls-files --others --exclude-standard") echo "" ;; *) return 0 ;; esac; }
export -f git
[[ $(assess_change_impact) == "medium" ]] && echo "✓ 1 code file → medium" || { echo "✗ 1 code failed"; ((failures++)); }
unset -f git

git() { case "$*" in "diff --name-only HEAD") printf 'src/f%d.js\n' {1..6} ;; "diff --cached --name-only") echo "" ;; "ls-files --others --exclude-standard") echo "" ;; *) return 0 ;; esac; }
export -f git
[[ $(assess_change_impact) == "high" ]] && echo "✓ 6 code files → high" || { echo "✗ 6 code failed"; ((failures++)); }
unset -f git

echo
if [[ $failures -eq 0 ]]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ $failures test(s) failed"
    exit 1
fi
