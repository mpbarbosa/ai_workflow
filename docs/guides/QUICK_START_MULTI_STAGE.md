# Quick Start: Multi-Stage Pipeline (v2.8.0)

## ⚡ TL;DR

```bash
# Enable multi-stage pipeline
./src/workflow/execute_tests_docs_workflow.sh --multi-stage --smart-execution --parallel

# View pipeline configuration
./src/workflow/execute_tests_docs_workflow.sh --show-pipeline
```

## 📊 What It Does

- **Stage 1**: Fast validation (2 min) - Always runs
- **Stage 2**: Targeted checks (5 min) - If docs/scripts changed
- **Stage 3**: Full validation (15 min) - If code changed or manual trigger
- **Result**: 80%+ of runs complete in Stages 1-2 only

## 🚀 Quick Commands

```bash
# Your original command
./src/workflow/execute_tests_docs_workflow.sh \
  --target "/home/mpb/Documents/GitHub/guia_js" \
  --smart-execution \
  --parallel \
  --auto-commit \
  --auto

# Now with multi-stage pipeline
./src/workflow/execute_tests_docs_workflow.sh \
  --target "/home/mpb/Documents/GitHub/guia_js" \
  --multi-stage \
  --smart-execution \
  --parallel \
  --auto-commit \
  --auto

# Ultimate optimization stack (v2.8.0)
./src/workflow/execute_tests_docs_workflow.sh \
  --target "/home/mpb/Documents/GitHub/guia_js" \
  --multi-stage \
  --ml-optimize \
  --smart-execution \
  --parallel \
  --auto-commit \
  --auto
```

## 📈 Performance Gains

| Change Type | Without Multi-Stage | With Multi-Stage | Speedup |
|-------------|---------------------|------------------|---------|
| Docs Only | 23 min | 5 min | 78% faster |
| Scripts | 23 min | 7 min | 70% faster |
| Code | 23 min | 18 min | 22% faster |

## 🎯 When Each Stage Runs

- **Stage 1**: Always (baseline check)
- **Stage 2**: Docs, scripts, or structure changed
- **Stage 3**: Code changed, 10+ files, or `--manual-trigger`

## 📚 Full Documentation

See [docs/MULTI_STAGE_PIPELINE_GUIDE.md](docs/MULTI_STAGE_PIPELINE_GUIDE.md)

---

**Version**: 2.8.0 | **Released**: 2026-01-01
