# Deprecated Test Scripts

This directory contains deprecated test scripts kept for historical reference only.

## Contents

These scripts were used during development for specific bug fixes and optimizations:
- `test_prompt_builder_fix.sh` - Prompt builder validation (v2.x)
- `test_step15_integration.sh` - Step 15 UX analysis integration testing (v2.x)
- `test_step1_log_fix.sh` - Step 1 logging fix validation (v3.x)
- `test_step1_optimization.sh` - Step 1 optimization testing (v3.2.0)
- `verify_step1_fix.sh` - Step 1 fix verification script (v3.x)

## Status

**DEPRECATED** - These scripts are no longer actively maintained.

For current testing:
- Use `tests/` directory for active test suites
- See `src/workflow/lib/test_*.sh` for library module tests
- Run `./src/workflow/test_modules.sh` for module testing

## Retention

Kept for historical reference. May be removed in future cleanup (v5.0.0+).

**Last Updated**: 2026-02-09
