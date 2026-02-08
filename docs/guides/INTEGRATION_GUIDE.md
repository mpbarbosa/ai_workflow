# Integration Guide - CI/CD and Automation

**Version**: 3.1.0  
**Last Updated**: 2026-02-08  
**Audience**: DevOps Engineers, CI/CD Administrators

## Overview

This guide covers integrating AI Workflow Automation into your CI/CD pipelines, pre-commit hooks, and custom automation scripts.

## Table of Contents

- [GitHub Actions](#github-actions)
- [GitLab CI](#gitlab-ci)
- [Jenkins](#jenkins)
- [Pre-Commit Hooks](#pre-commit-hooks)
- [Custom Automation](#custom-automation)
- [Docker Integration](#docker-integration)
- [Best Practices](#best-practices)

---

## GitHub Actions

### Basic Integration

```yaml
# .github/workflows/ai-workflow.yml
name: AI Workflow Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for change detection
          submodules: recursive
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install GitHub Copilot CLI
        run: npm install -g @githubnext/github-copilot-cli
      
      - name: Run AI Workflow
        run: |
          ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: workflow-reports
          path: |
            src/workflow/backlog/
            src/workflow/metrics/
            src/workflow/logs/
          retention-days: 30
```

### Advanced: Auto-Commit Results

```yaml
name: AI Workflow with Auto-Commit

on:
  push:
    branches: [ develop ]

jobs:
  workflow:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          submodules: recursive
          token: ${{ secrets.PAT_TOKEN }}  # Personal Access Token
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install GitHub Copilot CLI
        run: npm install -g @githubnext/github-copilot-cli
      
      - name: Configure Git
        run: |
          git config user.name "AI Workflow Bot"
          git config user.email "ai-workflow@example.com"
      
      - name: Run Workflow with Auto-Commit
        run: |
          ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto-commit \
            --ml-optimize
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Push changes
        if: success()
        run: |
          git push origin develop
```

### Matrix Strategy (Multiple Projects)

```yaml
name: Multi-Project Validation

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        project:
          - path: ./backend
            type: nodejs_api
          - path: ./frontend
            type: react_spa
          - path: ./scripts
            type: shell_automation
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Copilot CLI
        run: npm install -g @githubnext/github-copilot-cli
      
      - name: Validate ${{ matrix.project.path }}
        run: |
          ./src/workflow/execute_tests_docs_workflow.sh \
            --target ${{ matrix.project.path }} \
            --smart-execution \
            --parallel
        env:
          PROJECT_KIND: ${{ matrix.project.type }}
```

---

## GitLab CI

### Basic Pipeline

```yaml
# .gitlab-ci.yml
image: node:20

stages:
  - validate
  - test
  - deploy

variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_DEPTH: 0

ai_workflow:
  stage: validate
  before_script:
    - npm install -g @githubnext/github-copilot-cli
  script:
    - |
      ./src/workflow/execute_tests_docs_workflow.sh \
        --smart-execution \
        --parallel \
        --auto
  artifacts:
    when: always
    paths:
      - src/workflow/backlog/
      - src/workflow/metrics/
      - src/workflow/logs/
    expire_in: 30 days
  only:
    - main
    - develop
    - merge_requests
```

### Advanced: Parallel Jobs

```yaml
workflow_validation:
  stage: validate
  parallel:
    matrix:
      - STEP_GROUP: [pre-analysis, documentation, testing, quality]
  script:
    - |
      case $STEP_GROUP in
        pre-analysis)
          STEPS="0,1"
          ;;
        documentation)
          STEPS="2,3,4"
          ;;
        testing)
          STEPS="5,6,7"
          ;;
        quality)
          STEPS="8,9,10,11,12,13,14,15"
          ;;
      esac
      
      ./src/workflow/execute_tests_docs_workflow.sh \
        --steps $STEPS \
        --parallel
```

---

## Jenkins

### Pipeline Script

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        NODE_VERSION = '20'
        WORKFLOW_DIR = "${WORKSPACE}/ai_workflow"
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    // Install Node.js
                    sh """
                        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
                        apt-get install -y nodejs
                    """
                    
                    // Install GitHub Copilot CLI
                    sh 'npm install -g @githubnext/github-copilot-cli'
                }
            }
        }
        
        stage('Validate') {
            steps {
                script {
                    sh """
                        ${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh \
                            --smart-execution \
                            --parallel \
                            --auto
                    """
                }
            }
        }
        
        stage('Archive Results') {
            steps {
                archiveArtifacts artifacts: 'src/workflow/backlog/**/*', allowEmptyArchive: true
                archiveArtifacts artifacts: 'src/workflow/metrics/**/*', allowEmptyArchive: true
                archiveArtifacts artifacts: 'src/workflow/logs/**/*', allowEmptyArchive: true
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "AI Workflow Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Check console output at ${env.BUILD_URL}",
                to: "team@example.com"
            )
        }
    }
}
```

### Declarative Pipeline with Parameters

```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'OPTIMIZATION_LEVEL',
            choices: ['basic', 'smart', 'ml'],
            description: 'Optimization level'
        )
        booleanParam(
            name: 'AUTO_COMMIT',
            defaultValue: false,
            description: 'Automatically commit changes'
        )
    }
    
    stages {
        stage('Run Workflow') {
            steps {
                script {
                    def opts = '--parallel'
                    
                    switch(params.OPTIMIZATION_LEVEL) {
                        case 'smart':
                            opts += ' --smart-execution'
                            break
                        case 'ml':
                            opts += ' --smart-execution --ml-optimize'
                            break
                    }
                    
                    if (params.AUTO_COMMIT) {
                        opts += ' --auto-commit'
                    }
                    
                    sh "./src/workflow/execute_tests_docs_workflow.sh ${opts} --auto"
                }
            }
        }
    }
}
```

---

## Pre-Commit Hooks

### Installation

```bash
# Install pre-commit hooks (one-time setup)
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --install-hooks

# Hooks are installed to:
# - .git/hooks/pre-commit (fast validation)
# - .git/hooks/commit-msg (message validation)
```

### Custom Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

set -e

WORKFLOW_DIR="/path/to/ai_workflow"

echo "🔍 Running AI Workflow validation..."

# Fast validation (< 1 second)
"${WORKFLOW_DIR}/src/workflow/lib/precommit_hooks.sh" || {
    echo "❌ Validation failed. Commit blocked."
    exit 1
}

# Optional: Run specific checks
if git diff --cached --name-only | grep -q "\.md$"; then
    echo "📝 Validating documentation..."
    "${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh" \
        --steps 2 \
        --dry-run
fi

echo "✅ Validation passed"
```

### Pre-Push Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

set -e

WORKFLOW_DIR="/path/to/ai_workflow"

echo "🚀 Running pre-push validation..."

# Run comprehensive validation before push
"${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh" \
    --smart-execution \
    --parallel \
    --dry-run || {
    echo "❌ Pre-push validation failed"
    echo "Run workflow manually to see details:"
    echo "  ${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh"
    exit 1
}

echo "✅ Ready to push"
```

---

## Custom Automation

### Bash Script Integration

```bash
#!/bin/bash
# custom_workflow.sh

set -euo pipefail

WORKFLOW_DIR="/path/to/ai_workflow"

# Source workflow libraries
source "${WORKFLOW_DIR}/src/workflow/lib/change_detection.sh"
source "${WORKFLOW_DIR}/src/workflow/lib/metrics.sh"
source "${WORKFLOW_DIR}/src/workflow/lib/utils.sh"

# Initialize
init_metrics
log_info "Starting custom workflow"

# Analyze changes
analyze_changes
if has_code_changes; then
    log_info "Code changes detected"
    
    # Run specific steps
    "${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh" \
        --steps 0,2,5,7 \
        --auto
else
    log_info "No code changes, skipping"
fi

# Finalize
finalize_metrics
log_success "Custom workflow completed"
```

### Python Wrapper

```python
#!/usr/bin/env python3
# workflow_wrapper.py

import subprocess
import sys
from pathlib import Path

class AIWorkflow:
    def __init__(self, workflow_dir: str):
        self.workflow_dir = Path(workflow_dir)
        self.script = self.workflow_dir / "src/workflow/execute_tests_docs_workflow.sh"
    
    def run(self, **kwargs):
        """Run workflow with options."""
        cmd = [str(self.script)]
        
        if kwargs.get('smart_execution'):
            cmd.append('--smart-execution')
        if kwargs.get('parallel'):
            cmd.append('--parallel')
        if kwargs.get('auto_commit'):
            cmd.append('--auto-commit')
        if kwargs.get('target'):
            cmd.extend(['--target', kwargs['target']])
        if kwargs.get('steps'):
            cmd.extend(['--steps', kwargs['steps']])
        
        cmd.append('--auto')
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

# Usage
if __name__ == '__main__':
    workflow = AIWorkflow('/path/to/ai_workflow')
    success = workflow.run(
        smart_execution=True,
        parallel=True,
        auto_commit=False
    )
    sys.exit(0 if success else 1)
```

### Node.js Integration

```javascript
// workflow.js
const { spawn } = require('child_process');
const path = require('path');

class AIWorkflow {
  constructor(workflowDir) {
    this.workflowDir = workflowDir;
    this.script = path.join(workflowDir, 'src/workflow/execute_tests_docs_workflow.sh');
  }
  
  async run(options = {}) {
    const args = [];
    
    if (options.smartExecution) args.push('--smart-execution');
    if (options.parallel) args.push('--parallel');
    if (options.autoCommit) args.push('--auto-commit');
    if (options.target) args.push('--target', options.target);
    if (options.steps) args.push('--steps', options.steps);
    
    args.push('--auto');
    
    return new Promise((resolve, reject) => {
      const proc = spawn(this.script, args, { stdio: 'inherit' });
      
      proc.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Workflow failed with code ${code}`));
        }
      });
    });
  }
}

// Usage
(async () => {
  const workflow = new AIWorkflow('/path/to/ai_workflow');
  
  try {
    await workflow.run({
      smartExecution: true,
      parallel: true,
      autoCommit: false
    });
    console.log('✅ Workflow completed successfully');
  } catch (error) {
    console.error('❌ Workflow failed:', error.message);
    process.exit(1);
  }
})();
```

---

## Docker Integration

### Dockerfile

```dockerfile
# Dockerfile
FROM node:20-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub Copilot CLI
RUN npm install -g @githubnext/github-copilot-cli

# Copy workflow
COPY . /workspace/ai_workflow
WORKDIR /workspace

# Set entrypoint
ENTRYPOINT ["/workspace/ai_workflow/src/workflow/execute_tests_docs_workflow.sh"]
CMD ["--smart-execution", "--parallel", "--auto"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  ai-workflow:
    build: .
    volumes:
      - ./project:/workspace/project:rw
      - ./ai_workflow:/workspace/ai_workflow:ro
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    command: >
      --target /workspace/project
      --smart-execution
      --parallel
      --auto-commit
```

### Usage

```bash
# Build image
docker build -t ai-workflow:latest .

# Run on project
docker run --rm \
  -v $(pwd):/workspace/project \
  -e GITHUB_TOKEN=${GITHUB_TOKEN} \
  ai-workflow:latest \
  --target /workspace/project \
  --smart-execution \
  --parallel
```

---

## Best Practices

### Performance Optimization

```bash
# Always use smart execution for faster runs
--smart-execution

# Enable parallel execution for independent steps
--parallel

# Use ML optimization after 10+ historical runs
--ml-optimize

# Combine for maximum speed
--smart-execution --parallel --ml-optimize
```

### Error Handling

```bash
#!/bin/bash
set -euo pipefail

WORKFLOW="${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh"

# Run with error handling
if ! "${WORKFLOW}" --smart-execution --parallel --auto; then
    echo "❌ Workflow failed"
    
    # Check logs
    LATEST_LOG=$(ls -t "${WORKFLOW_DIR}/src/workflow/logs" | head -1)
    echo "See logs: ${WORKFLOW_DIR}/src/workflow/logs/${LATEST_LOG}"
    
    # Send notification
    notify-send "Workflow Failed" "Check logs for details"
    
    exit 1
fi
```

### Caching Strategies

```bash
# Enable AI response caching (default)
# Responses cached for 24 hours

# Disable caching if needed
--no-ai-cache

# Clear cache manually
rm -rf "${WORKFLOW_DIR}/src/workflow/.ai_cache"
```

### Monitoring

```bash
# Collect metrics
"${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh" \
    --smart-execution \
    --parallel

# Parse metrics
METRICS="${WORKFLOW_DIR}/src/workflow/metrics/current_run.json"
DURATION=$(jq -r '.total_duration' "$METRICS")
STEPS_SKIPPED=$(jq -r '.steps_skipped' "$METRICS")

echo "Duration: ${DURATION}s"
echo "Steps skipped: ${STEPS_SKIPPED}"

# Alert if duration too high
if [ "$DURATION" -gt 600 ]; then
    echo "⚠️  Workflow taking too long"
fi
```

### Security

```bash
# Use environment variables for sensitive data
export GITHUB_TOKEN="ghp_xxx"

# Don't commit tokens
echo "GITHUB_TOKEN" >> .gitignore

# Use CI/CD secrets
# GitHub Actions: ${{ secrets.GITHUB_TOKEN }}
# GitLab CI: $CI_JOB_TOKEN
# Jenkins: credentials()
```

## Troubleshooting

### Common Issues

**Issue**: Workflow fails with "Copilot CLI not found"
```bash
# Solution: Install Copilot CLI
npm install -g @githubnext/github-copilot-cli
```

**Issue**: Permission denied
```bash
# Solution: Make script executable
chmod +x src/workflow/execute_tests_docs_workflow.sh
```

**Issue**: Git submodule errors
```bash
# Solution: Initialize submodules
git submodule update --init --recursive
```

### Debugging

```bash
# Enable verbose logging
export DEBUG=1
./src/workflow/execute_tests_docs_workflow.sh --smart-execution

# Dry run mode (preview without changes)
./src/workflow/execute_tests_docs_workflow.sh --dry-run

# Test specific steps
./src/workflow/execute_tests_docs_workflow.sh --steps 0,2 --dry-run
```

## Next Steps

- [Performance Tuning Guide](PERFORMANCE_TUNING.md)
- [Advanced Configuration](../developer-guide/architecture.md)
- [Troubleshooting Guide](../user-guide/troubleshooting.md)
- [API Reference](../api/API_REFERENCE.md)
