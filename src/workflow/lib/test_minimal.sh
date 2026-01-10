#!/bin/bash
set -euo pipefail
echo "Test 1"
TEST_DIR=$(mktemp -d)
echo "Test 2: ${TEST_DIR}"
rm -rf "${TEST_DIR}"
echo "Done"
