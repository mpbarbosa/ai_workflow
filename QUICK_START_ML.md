# Quick Start: Machine Learning Optimization (v2.7.0)

## ⚡ TL;DR

```bash
# Enable ML optimization
./src/workflow/execute_tests_docs_workflow.sh --ml-optimize --smart-execution --parallel

# Check ML status
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status
```

## 📊 What It Does

- **Predicts** workflow duration before execution
- **Recommends** optimal parallelization strategy
- **Suggests** which steps to skip based on change patterns
- **Detects** performance anomalies
- **Learns** from each execution (improves over time)

## 🚀 Quick Commands

```bash
# Your original command
./src/workflow/execute_tests_docs_workflow.sh \
  --target "/home/mpb/Documents/GitHub/guia_js" \
  --smart-execution \
  --parallel \
  --auto-commit \
  --auto

# Now with ML optimization
./src/workflow/execute_tests_docs_workflow.sh \
  --target "/home/mpb/Documents/GitHub/guia_js" \
  --ml-optimize \
  --smart-execution \
  --parallel \
  --auto-commit \
  --auto
```

## 📈 Performance Gains

| Without ML | With ML | Combined (ML + Smart + Parallel) |
|------------|---------|----------------------------------|
| 23 minutes | 18 min  | 2-12 min (depending on changes)  |

## ⚠️ Requirements

- **Training Data**: 10+ historical workflow runs
- **Dependencies**: `jq`, `bc` (already installed)
- **Storage**: ~1-5 MB in `.ml_data/`

## 📚 Full Documentation

See [docs/ML_OPTIMIZATION_GUIDE.md](docs/ML_OPTIMIZATION_GUIDE.md)

---

**Version**: 2.7.0 | **Released**: 2026-01-01
