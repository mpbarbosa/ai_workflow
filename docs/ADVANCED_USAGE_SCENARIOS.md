# Advanced Usage Scenarios

**Version**: 1.0.0  
**Last Updated**: 2026-02-10  
**Audience**: Experienced users seeking advanced workflow configurations

This guide covers advanced usage patterns, custom configurations, and complex scenarios for AI Workflow Automation.

## Table of Contents

- [Overview](#overview)
- [Custom Workflow Pipelines](#custom-workflow-pipelines)
- [Multi-Project Workflows](#multi-project-workflows)
- [Advanced Optimization](#advanced-optimization)
- [Custom AI Personas](#custom-ai-personas)
- [Selective Step Execution](#selective-step-execution)
- [Conditional Workflows](#conditional-workflows)
- [Performance Tuning](#performance-tuning)
- [Enterprise Integration](#enterprise-integration)
- [Custom Reporting](#custom-reporting)
- [Advanced Git Integration](#advanced-git-integration)

---

## Overview

This guide assumes familiarity with:
- Basic workflow execution
- Configuration files
- Command-line options
- Project structure

For basics, see [Getting Started Guide](getting-started/GETTING_STARTED.md).

---

## Custom Workflow Pipelines

### Creating Custom Workflow Templates

**Example: API Development Workflow**

```bash
#!/usr/bin/env bash
# templates/workflows/api-development.sh
# Custom workflow for API development projects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${SCRIPT_DIR}/../../src/workflow"

echo "API Development Workflow"
echo "========================"

# Configuration
export WORKFLOW_MODE="api-development"
export SMART_EXECUTION=true
export PARALLEL_EXECUTION=true

# Custom step selection for API projects
STEPS=(
    "pre_analyze"              # Step 0: Pre-flight checks
    "documentation_updates"    # Step 2: Update API docs
    "test_execution"           # Step 3: Run API tests
    "code_quality"             # Step 5: Code quality checks
    "security_scan"            # Step 8: Security analysis
    "api_validation"           # Custom: Validate API contracts
    "performance_test"         # Custom: API performance tests
    "git_finalization"         # Step 12: Git operations
)

# Join array into comma-separated list
IFS=','
step_list="${STEPS[*]}"

# Execute workflow
"${WORKFLOW_DIR}/execute_tests_docs_workflow.sh" \
    --steps "$step_list" \
    --smart-execution \
    --parallel \
    --auto-commit \
    "$@"
```

**Example: Documentation Sprint Workflow**

```bash
#!/usr/bin/env bash
# templates/workflows/documentation-sprint.sh
# Intensive documentation review and update workflow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${SCRIPT_DIR}/../../src/workflow"

echo "Documentation Sprint Workflow"
echo "============================="

# Run documentation analysis first
"${WORKFLOW_DIR}/execute_tests_docs_workflow.sh" \
    --steps pre_analyze,documentation_analysis \
    --verbose

# Review results
echo ""
echo "Review documentation analysis in backlog/"
read -p "Continue with updates? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Run full documentation workflow
    "${WORKFLOW_DIR}/execute_tests_docs_workflow.sh" \
        --steps bootstrap_docs,documentation_updates,link_validation,accessibility_review \
        --auto-commit \
        --generate-docs \
        "$@"
fi
```

### Pipeline Configuration

Create custom pipeline in `.workflow-config.yaml`:

```yaml
workflows:
  custom_pipelines:
    # Microservices workflow
    microservice:
      stages:
        - name: "validate"
          steps: [pre_analyze, documentation_analysis]
          parallel: false
        - name: "test"
          steps: [test_execution, test_coverage]
          parallel: true
        - name: "quality"
          steps: [code_quality, security_scan]
          parallel: true
        - name: "deploy"
          steps: [version_update, git_finalization]
          parallel: false
      
    # Frontend workflow
    frontend:
      stages:
        - name: "analyze"
          steps: [pre_analyze, front_end_analysis]
        - name: "validate"
          steps: [documentation_updates, ux_analysis]
        - name: "test"
          steps: [test_execution, visual_regression]
        - name: "finalize"
          steps: [git_finalization]
      
    # Data pipeline workflow
    data_pipeline:
      stages:
        - name: "validate"
          steps: [pre_analyze, data_validation]
        - name: "test"
          steps: [integration_tests, data_quality_tests]
        - name: "document"
          steps: [documentation_updates, schema_docs]
```

Use custom pipeline:

```bash
./src/workflow/execute_tests_docs_workflow.sh \
    --pipeline microservice \
    --auto
```

---

## Multi-Project Workflows

### Managing Multiple Projects

**Workflow orchestrator for multiple projects:**

```bash
#!/usr/bin/env bash
# scripts/multi_project_workflow.sh
# Run workflows across multiple projects

set -euo pipefail

# Project list
PROJECTS=(
    "/path/to/project1"
    "/path/to/project2"
    "/path/to/project3"
)

# Workflow directory
WORKFLOW_DIR="/path/to/ai_workflow/src/workflow"

# Results tracking
declare -A RESULTS
FAILED_PROJECTS=()

function run_project_workflow() {
    local project_path="$1"
    local project_name
    project_name=$(basename "$project_path")
    
    echo ""
    echo "========================================"
    echo "Processing: $project_name"
    echo "========================================"
    
    cd "$project_path"
    
    # Check for changes
    if ! git diff --quiet; then
        echo "⚠ Uncommitted changes in $project_name, skipping"
        RESULTS["$project_name"]="SKIPPED"
        return 0
    fi
    
    # Run workflow
    if "${WORKFLOW_DIR}/execute_tests_docs_workflow.sh" \
        --smart-execution \
        --parallel \
        --auto \
        --target "$project_path"; then
        echo "✅ $project_name: SUCCESS"
        RESULTS["$project_name"]="SUCCESS"
    else
        echo "❌ $project_name: FAILED"
        RESULTS["$project_name"]="FAILED"
        FAILED_PROJECTS+=("$project_name")
    fi
}

# Process each project
for project in "${PROJECTS[@]}"; do
    run_project_workflow "$project"
done

# Summary report
echo ""
echo "========================================"
echo "Multi-Project Workflow Summary"
echo "========================================"

for project_name in "${!RESULTS[@]}"; do
    echo "$project_name: ${RESULTS[$project_name]}"
done

if [[ ${#FAILED_PROJECTS[@]} -gt 0 ]]; then
    echo ""
    echo "Failed projects:"
    for project in "${FAILED_PROJECTS[@]}"; do
        echo "  - $project"
    done
    exit 1
else
    echo ""
    echo "✅ All projects processed successfully"
    exit 0
fi
```

### Project Group Configuration

Create project groups in `.workflow-config.yaml`:

```yaml
project_groups:
  backend_services:
    - /path/to/api-service
    - /path/to/auth-service
    - /path/to/data-service
    
  frontend_apps:
    - /path/to/web-app
    - /path/to/mobile-app
    - /path/to/admin-panel
    
  libraries:
    - /path/to/shared-lib
    - /path/to/ui-components
    - /path/to/utils-lib

group_settings:
  backend_services:
    workflow: api-development
    parallel_projects: 2
    
  frontend_apps:
    workflow: frontend
    parallel_projects: 1
```

Run workflow on group:

```bash
./scripts/run_project_group.sh backend_services
```

---

## Advanced Optimization

### ML-Powered Optimization

**Training the ML model with historical data:**

```bash
# Run workflow with ML training enabled
./src/workflow/execute_tests_docs_workflow.sh \
    --ml-optimize \
    --ml-train \
    --smart-execution \
    --parallel

# After 10+ runs, ML predictions become accurate
./src/workflow/execute_tests_docs_workflow.sh --show-ml-status
```

**Custom ML configuration:**

```yaml
# .workflow-config.yaml
ml_optimization:
  enabled: true
  min_training_runs: 10
  prediction_confidence: 0.85
  
  features:
    - file_count
    - change_size
    - test_coverage
    - previous_duration
    
  optimizations:
    - skip_prediction
    - duration_estimation
    - resource_allocation
```

### Custom Caching Strategies

**Configure AI response caching:**

```yaml
ai_caching:
  enabled: true
  ttl: 86400  # 24 hours
  max_size: 1GB
  
  cache_keys:
    - prompt_hash
    - file_content_hash
    - project_context
    
  strategies:
    documentation: 
      ttl: 604800  # 7 days (docs change less)
    code_review:
      ttl: 3600    # 1 hour (code changes often)
    tests:
      ttl: 86400   # 1 day
```

### Performance Profiling

**Enable detailed performance metrics:**

```bash
# Run with profiling
export PROFILE_EXECUTION=true
export PROFILE_DETAIL=high

./src/workflow/execute_tests_docs_workflow.sh \
    --smart-execution \
    --parallel

# View profile report
cat src/workflow/metrics/current_run.json | jq .performance_profile
```

**Custom performance thresholds:**

```yaml
performance:
  thresholds:
    step_duration_warning: 300    # 5 minutes
    step_duration_error: 900      # 15 minutes
    total_duration_target: 600    # 10 minutes
    
  alerts:
    slow_steps: true
    memory_usage: true
    cache_hit_rate: true
```

---

## Custom AI Personas

### Creating Custom Personas

**Define custom persona in `.workflow_core/config/ai_helpers.yaml`:**

```yaml
# Custom AI personas
custom_personas:
  database_expert:
    role: "Database Architecture Expert"
    expertise:
      - Database schema design
      - Query optimization
      - Index strategies
      - Migration planning
    focus:
      - Performance
      - Scalability
      - Data integrity
    
  devops_engineer:
    role: "DevOps and Infrastructure Expert"
    expertise:
      - CI/CD pipelines
      - Container orchestration
      - Infrastructure as Code
      - Monitoring and alerting
    focus:
      - Reliability
      - Automation
      - Observability
```

### Using Custom Personas

**In custom step:**

```bash
#!/usr/bin/env bash
# steps/database_review.sh

source "$(dirname "$0")/../lib/ai_helpers.sh"

function execute_step() {
    print_header "Database Schema Review"
    
    # Call custom persona
    ai_call "database_expert" \
        "Review database schema in db/schema.sql for optimization opportunities" \
        "${BACKLOG_DIR}/database_review.md"
    
    # Second opinion from devops
    ai_call "devops_engineer" \
        "Review database deployment and monitoring setup" \
        "${BACKLOG_DIR}/database_ops_review.md"
}
```

### Persona Chaining

**Sequential AI analysis with multiple personas:**

```bash
function multi_persona_review() {
    local file="$1"
    local output_dir="${BACKLOG_DIR}/multi_review"
    
    mkdir -p "$output_dir"
    
    # Pass 1: Code review
    ai_call "code_reviewer" \
        "Review code quality in $file" \
        "${output_dir}/01_code_review.md"
    
    # Pass 2: Security review
    ai_call "security_analyst" \
        "Review security implications in $file" \
        "${output_dir}/02_security_review.md"
    
    # Pass 3: Performance review
    ai_call "performance_engineer" \
        "Review performance characteristics in $file" \
        "${output_dir}/03_performance_review.md"
    
    # Pass 4: Synthesis
    ai_call "technical_lead" \
        "Synthesize reviews from ${output_dir}/* and provide recommendations" \
        "${output_dir}/04_recommendations.md"
}
```

---

## Selective Step Execution

### Dynamic Step Selection

**Based on file changes:**

```bash
#!/usr/bin/env bash
# scripts/smart_workflow.sh
# Dynamically select steps based on changes

source src/workflow/lib/change_detection.sh

# Analyze changes
analyze_changes

# Determine which steps to run
STEPS=()

if has_doc_changes; then
    STEPS+=(documentation_analysis documentation_updates)
fi

if has_code_changes; then
    STEPS+=(code_quality test_execution)
fi

if has_config_changes; then
    STEPS+=(config_validation)
fi

if has_test_changes; then
    STEPS+=(test_execution test_coverage)
fi

# Always run pre-analyze and git finalization
STEPS=(pre_analyze "${STEPS[@]}" git_finalization)

# Execute
IFS=','
./src/workflow/execute_tests_docs_workflow.sh --steps "${STEPS[*]}"
```

### Conditional Step Execution

**Configuration-based conditions:**

```yaml
conditional_steps:
  security_scan:
    condition: "has_code_changes && is_production_branch"
    
  performance_test:
    condition: "has_code_changes && day_of_week == 'Friday'"
    
  full_integration_test:
    condition: "is_release_candidate"
    
  visual_regression:
    condition: "has_frontend_changes"
```

---

## Conditional Workflows

### Branch-Based Workflows

**Different workflows for different branches:**

```bash
#!/usr/bin/env bash
# scripts/branch_workflow.sh

CURRENT_BRANCH=$(git branch --show-current)

case "$CURRENT_BRANCH" in
    main|master)
        echo "Production branch - full workflow"
        ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --ml-optimize \
            --multi-stage \
            --auto
        ;;
    
    develop)
        echo "Development branch - standard workflow"
        ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto
        ;;
    
    feature/*)
        echo "Feature branch - quick validation"
        ./src/workflow/execute_tests_docs_workflow.sh \
            --steps pre_analyze,test_execution,code_quality \
            --auto
        ;;
    
    hotfix/*)
        echo "Hotfix branch - critical checks only"
        ./src/workflow/execute_tests_docs_workflow.sh \
            --steps test_execution,security_scan \
            --auto
        ;;
    
    *)
        echo "Unknown branch - minimal workflow"
        ./src/workflow/execute_tests_docs_workflow.sh \
            --steps pre_analyze,test_execution \
            --auto
        ;;
esac
```

### Time-Based Workflows

**Different workflows based on time:**

```bash
#!/usr/bin/env bash
# scripts/scheduled_workflow.sh

DAY_OF_WEEK=$(date +%u)  # 1 (Monday) to 7 (Sunday)
HOUR=$(date +%H)

if [[ $DAY_OF_WEEK -eq 1 ]] && [[ $HOUR -eq 9 ]]; then
    # Monday morning - comprehensive review
    echo "Weekly comprehensive review"
    ./src/workflow/execute_tests_docs_workflow.sh \
        --steps pre_analyze,documentation_analysis,test_execution,code_quality,security_scan \
        --generate-docs \
        --update-changelog
        
elif [[ $DAY_OF_WEEK -eq 5 ]] && [[ $HOUR -eq 17 ]]; then
    # Friday evening - prepare for next week
    echo "Weekly cleanup and summary"
    ./src/workflow/execute_tests_docs_workflow.sh \
        --steps documentation_updates,git_finalization \
        --auto-commit \
        --generate-docs
        
else
    # Regular workflow
    ./src/workflow/execute_tests_docs_workflow.sh \
        --smart-execution \
        --parallel \
        --auto
fi
```

---

## Performance Tuning

### Resource Allocation

**Configure parallel execution limits:**

```yaml
# .workflow-config.yaml
performance:
  parallel_execution:
    max_jobs: 4
    max_memory_per_job: "2GB"
    cpu_limit: 80  # Percent
    
  resource_allocation:
    ai_calls: 
      max_concurrent: 2
      timeout: 300
    file_processing:
      batch_size: 100
      max_workers: 8
```

### Custom Timeout Configuration

```yaml
timeouts:
  steps:
    test_execution: 600      # 10 minutes
    documentation: 300       # 5 minutes
    code_quality: 900        # 15 minutes
    
  ai_operations:
    default: 180
    complex_analysis: 300
    
  git_operations:
    clone: 600
    push: 300
```

### Memory Management

```bash
# Enable memory monitoring
export MONITOR_MEMORY=true
export MEMORY_LIMIT="8GB"
export MEMORY_WARNING_THRESHOLD="6GB"

./src/workflow/execute_tests_docs_workflow.sh \
    --smart-execution \
    --parallel \
    --auto
```

---

## Enterprise Integration

### LDAP/AD Integration

```yaml
# .workflow-config.yaml
enterprise:
  authentication:
    type: "ldap"
    server: "ldap://company.com"
    base_dn: "dc=company,dc=com"
    
  authorization:
    admin_group: "cn=devops,ou=groups,dc=company,dc=com"
    developer_group: "cn=developers,ou=groups,dc=company,dc=com"
```

### Audit Logging

**Enhanced audit logging:**

```yaml
audit:
  enabled: true
  log_level: "detailed"
  
  events:
    - workflow_start
    - workflow_complete
    - step_execution
    - ai_calls
    - file_modifications
    - git_operations
    
  output:
    file: "logs/audit.log"
    format: "json"
    rotation: "daily"
    retention_days: 90
```

### Compliance Reporting

```bash
#!/usr/bin/env bash
# Generate compliance report

./src/workflow/execute_tests_docs_workflow.sh \
    --generate-compliance-report \
    --compliance-standard "SOC2" \
    --report-format "pdf"
```

---

## Custom Reporting

### Custom Report Templates

**Create custom report template:**

```bash
#!/usr/bin/env bash
# templates/reports/executive_summary.sh

cat > "${BACKLOG_DIR}/executive_summary.md" << EOF
# Executive Summary
**Date**: $(date +%Y-%m-%d)
**Project**: $PROJECT_NAME

## Key Metrics
- Test Coverage: ${TEST_COVERAGE}%
- Code Quality: ${CODE_QUALITY_SCORE}
- Documentation Status: ${DOC_STATUS}
- Security Issues: ${SECURITY_ISSUES}

## Highlights
$(summarize_highlights)

## Recommendations
$(generate_recommendations)

## Next Steps
$(outline_next_steps)
EOF
```

### Automated Reporting

**Schedule automated reports:**

```bash
#!/usr/bin/env bash
# cron job: 0 9 * * 1  # Every Monday at 9 AM

./src/workflow/execute_tests_docs_workflow.sh \
    --generate-report weekly_summary \
    --email-to team@company.com \
    --format html
```

---

## Advanced Git Integration

### Git Hook Integration

**Advanced pre-commit hook:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run fast validation
./src/workflow/execute_tests_docs_workflow.sh \
    --test-hooks \
    --quick-mode

# Check for sensitive data
if grep -r "API_KEY\|PASSWORD\|SECRET" .; then
    echo "⚠ Possible sensitive data detected"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Auto-format code
./scripts/format_code.sh --staged-only

exit 0
```

### Branch Protection Workflows

**Enforce workflows on protected branches:**

```bash
#!/usr/bin/env bash
# .git/hooks/pre-push

BRANCH=$(git branch --show-current)

if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    echo "Pushing to protected branch - running full validation"
    
    # Run comprehensive workflow
    if ! ./src/workflow/execute_tests_docs_workflow.sh \
        --smart-execution \
        --parallel \
        --auto; then
        echo "❌ Workflow failed - push aborted"
        exit 1
    fi
    
    echo "✅ Validation passed - proceeding with push"
fi

exit 0
```

---

## Resources

- [Module Development Guide](MODULE_DEVELOPMENT_GUIDE.md)
- [Testing Best Practices](TESTING_BEST_PRACTICES.md)
- [Configuration Reference](CONFIGURATION_REFERENCE.md)
- [Project Reference](PROJECT_REFERENCE.md)

---

**Questions or Advanced Scenarios?**

- GitHub Issues: [github.com/mpbarbosa/ai_workflow/issues](https://github.com/mpbarbosa/ai_workflow/issues)
- Email: mpbarbosa@gmail.com

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
