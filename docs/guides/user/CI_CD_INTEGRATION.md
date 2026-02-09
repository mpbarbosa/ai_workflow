# CI/CD Integration Guide - AI Workflow Automation

**Version**: 4.0.1  
**Last Updated**: 2026-02-09  
**Maintainer**: AI Workflow Team

> 🔄 **Purpose**: Complete guide for integrating AI Workflow Automation into CI/CD pipelines

## Table of Contents

1. [Overview](#overview)
2. [GitHub Actions](#github-actions)
3. [GitLab CI](#gitlab-ci)
4. [Jenkins](#jenkins)
5. [Docker Integration](#docker-integration)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### Integration Benefits

- **Automated Quality Checks**: Run validation on every commit/PR
- **Consistent Enforcement**: Same quality standards across all contributions
- **Early Detection**: Catch issues before merge
- **Documentation Sync**: Keep docs updated automatically
- **Test Coverage**: Maintain high test coverage

### Prerequisites

- Git repository with AI Workflow installed
- CI/CD platform account and configuration access
- GitHub Copilot CLI authentication (for AI features)
- Node.js 25.2.1+ (for test execution)
- Bash 4.0+ environment

### Performance Considerations

| Execution Mode | Duration | Use Case |
|---------------|----------|----------|
| Quick validation (`--steps 0,2`) | 2-3 min | PR checks |
| Documentation only | 3-4 min | Doc PRs |
| Smart execution | 5-15 min | Regular commits |
| Full workflow | 20-30 min | Release builds |

---

## GitHub Actions

### Basic Workflow

Create `.github/workflows/ai-workflow.yml`:

```yaml
name: AI Workflow Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  validate:
    name: Run AI Workflow
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for change detection
          submodules: true  # Include .workflow_core
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '25.2.1'
          cache: 'npm'
      
      - name: Install dependencies
        run: |
          npm ci
          # Install BATS for testing
          sudo apt-get update
          sudo apt-get install -y bats
      
      - name: Run AI Workflow
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          cd ai_workflow
          ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --auto \
            --no-resume
      
      - name: Upload artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: workflow-results
          path: |
            ai_workflow/src/workflow/backlog/
            ai_workflow/src/workflow/logs/
            ai_workflow/src/workflow/metrics/
          retention-days: 30
```

### Pull Request Validation

Optimized for fast PR feedback:

```yaml
name: PR Validation

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  quick-validation:
    name: Quick Validation
    runs-on: ubuntu-latest
    timeout-minutes: 10
    
    steps:
      - name: Checkout PR
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ github.event.pull_request.head.sha }}
      
      - name: Detect changes
        id: changes
        run: |
          # Check what changed
          git diff --name-only origin/${{ github.base_ref }}...HEAD > changed_files.txt
          
          if grep -q "^docs/" changed_files.txt; then
            echo "docs_changed=true" >> $GITHUB_OUTPUT
          fi
          
          if grep -q "^src/" changed_files.txt; then
            echo "code_changed=true" >> $GITHUB_OUTPUT
          fi
          
          if grep -q "^tests/" changed_files.txt; then
            echo "tests_changed=true" >> $GITHUB_OUTPUT
          fi
      
      - name: Run targeted validation
        run: |
          cd ai_workflow
          
          # Determine which steps to run
          STEPS="0"  # Always run analysis
          
          if [[ "${{ steps.changes.outputs.docs_changed }}" == "true" ]]; then
            STEPS="${STEPS},documentation_updates,git_status_check"
          fi
          
          if [[ "${{ steps.changes.outputs.code_changed }}" == "true" ]]; then
            STEPS="${STEPS},code_review,test_execution"
          fi
          
          if [[ "${{ steps.changes.outputs.tests_changed }}" == "true" ]]; then
            STEPS="${STEPS},test_execution,test_review"
          fi
          
          ./src/workflow/execute_tests_docs_workflow.sh \
            --steps "$STEPS" \
            --parallel \
            --auto
      
      - name: Comment PR
        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('ai_workflow/src/workflow/backlog/latest/EXECUTION_SUMMARY.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## AI Workflow Validation Results\n\n${summary}`
            });
```

### Scheduled Full Validation

Run complete workflow nightly:

```yaml
name: Nightly Full Validation

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
  workflow_dispatch:

jobs:
  full-validation:
    name: Complete Workflow
    runs-on: ubuntu-latest
    timeout-minutes: 45
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          submodules: true
      
      - name: Setup environment
        uses: actions/setup-node@v4
        with:
          node-version: '25.2.1'
      
      - name: Install dependencies
        run: |
          npm ci
          sudo apt-get update
          sudo apt-get install -y bats yq
      
      - name: Run full workflow with ML optimization
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          cd ai_workflow
          ./src/workflow/execute_tests_docs_workflow.sh \
            --smart-execution \
            --parallel \
            --ml-optimize \
            --multi-stage \
            --auto \
            --generate-docs \
            --update-changelog
      
      - name: Auto-commit results
        if: success()
        run: |
          cd ai_workflow
          git config user.name "AI Workflow Bot"
          git config user.email "ai-workflow@users.noreply.github.com"
          
          git add docs/ CHANGELOG.md
          git commit -m "chore: automated documentation update [skip ci]" || true
          git push
      
      - name: Upload metrics
        uses: actions/upload-artifact@v4
        with:
          name: nightly-metrics
          path: ai_workflow/src/workflow/metrics/
          retention-days: 90
      
      - name: Notify on failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Nightly workflow failed - ${new Date().toISOString().split('T')[0]}`,
              body: 'The nightly AI Workflow validation has failed. Please review the logs.',
              labels: ['automated', 'ci-failure']
            });
```

### Caching Strategy

Optimize build times with smart caching:

```yaml
      - name: Cache AI responses
        uses: actions/cache@v4
        with:
          path: ai_workflow/src/workflow/.ai_cache
          key: ai-cache-${{ hashFiles('ai_workflow/src/**/*.sh') }}
          restore-keys: |
            ai-cache-
      
      - name: Cache metrics history
        uses: actions/cache@v4
        with:
          path: ai_workflow/src/workflow/metrics/history.jsonl
          key: metrics-${{ github.run_number }}
          restore-keys: |
            metrics-
      
      - name: Cache ML model data
        uses: actions/cache@v4
        with:
          path: ai_workflow/.ml_data
          key: ml-data-${{ hashFiles('ai_workflow/src/**/*.sh') }}
          restore-keys: |
            ml-data-
```

---

## GitLab CI

### Basic Pipeline

Create `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - test
  - deploy

variables:
  AI_WORKFLOW_DIR: "ai_workflow"
  GIT_STRATEGY: fetch
  GIT_SUBMODULE_STRATEGY: recursive

cache:
  key: "${CI_COMMIT_REF_SLUG}"
  paths:
    - ${AI_WORKFLOW_DIR}/src/workflow/.ai_cache/
    - ${AI_WORKFLOW_DIR}/.ml_data/
    - node_modules/

before_script:
  - apt-get update -qq
  - apt-get install -y -qq bats yq
  - node --version
  - npm ci

ai-workflow-validation:
  stage: validate
  image: node:25-alpine
  timeout: 30 minutes
  
  script:
    - cd ${AI_WORKFLOW_DIR}
    - |
      ./src/workflow/execute_tests_docs_workflow.sh \
        --smart-execution \
        --parallel \
        --auto \
        --no-resume
  
  artifacts:
    name: "workflow-results-${CI_COMMIT_SHORT_SHA}"
    when: always
    expire_in: 30 days
    paths:
      - ${AI_WORKFLOW_DIR}/src/workflow/backlog/
      - ${AI_WORKFLOW_DIR}/src/workflow/logs/
      - ${AI_WORKFLOW_DIR}/src/workflow/metrics/
    reports:
      junit: ${AI_WORKFLOW_DIR}/test-results/*.xml
  
  only:
    - merge_requests
    - main
    - develop
```

### Merge Request Pipeline

```yaml
mr-quick-check:
  stage: validate
  image: node:25-alpine
  timeout: 10 minutes
  
  script:
    - cd ${AI_WORKFLOW_DIR}
    
    # Detect changes
    - |
      git diff --name-only ${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}...HEAD > /tmp/changes.txt
      
      STEPS="0"  # Always analyze
      
      if grep -q "^docs/" /tmp/changes.txt; then
        STEPS="${STEPS},documentation_updates"
      fi
      
      if grep -q "^src/" /tmp/changes.txt; then
        STEPS="${STEPS},code_review,test_execution"
      fi
    
    # Run targeted validation
    - |
      ./src/workflow/execute_tests_docs_workflow.sh \
        --steps "${STEPS}" \
        --parallel \
        --auto
  
  only:
    - merge_requests
  
  except:
    - main
    - develop
```

### Scheduled Pipeline

```yaml
nightly-full-validation:
  stage: validate
  image: node:25-alpine
  timeout: 45 minutes
  
  script:
    - cd ${AI_WORKFLOW_DIR}
    - |
      ./src/workflow/execute_tests_docs_workflow.sh \
        --smart-execution \
        --parallel \
        --ml-optimize \
        --multi-stage \
        --auto \
        --generate-docs \
        --update-changelog
    
    # Auto-commit if successful
    - |
      if [ $? -eq 0 ]; then
        git config user.name "AI Workflow Bot"
        git config user.email "bot@example.com"
        git add docs/ CHANGELOG.md
        git commit -m "chore: automated documentation update [skip ci]" || true
        git push "https://oauth2:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" HEAD:${CI_COMMIT_REF_NAME}
      fi
  
  only:
    - schedules
  
  artifacts:
    expire_in: 90 days
    paths:
      - ${AI_WORKFLOW_DIR}/src/workflow/metrics/
```

---

## Jenkins

### Declarative Pipeline

Create `Jenkinsfile`:

```groovy
pipeline {
    agent {
        docker {
            image 'node:25-alpine'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
    }
    
    environment {
        AI_WORKFLOW_DIR = 'ai_workflow'
        HOME = "${WORKSPACE}"
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    sh '''
                        apk add --no-cache bash git bats yq
                        git submodule update --init --recursive
                        npm ci
                    '''
                }
            }
        }
        
        stage('Validate') {
            steps {
                dir("${AI_WORKFLOW_DIR}") {
                    script {
                        sh '''
                            ./src/workflow/execute_tests_docs_workflow.sh \
                                --smart-execution \
                                --parallel \
                                --auto \
                                --no-resume
                        '''
                    }
                }
            }
        }
        
        stage('Analyze Results') {
            steps {
                script {
                    // Parse metrics
                    def metrics = readJSON file: "${AI_WORKFLOW_DIR}/src/workflow/metrics/current_run.json"
                    
                    echo "Duration: ${metrics.total_duration}s"
                    echo "Steps completed: ${metrics.steps_completed}/${metrics.total_steps}"
                    echo "Cache hit rate: ${metrics.cache_hit_rate}"
                    
                    // Fail if workflow failed
                    if (metrics.status != 'completed') {
                        error("AI Workflow validation failed")
                    }
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: "${AI_WORKFLOW_DIR}/src/workflow/backlog/**/*", allowEmptyArchive: true
            archiveArtifacts artifacts: "${AI_WORKFLOW_DIR}/src/workflow/logs/**/*", allowEmptyArchive: true
            archiveArtifacts artifacts: "${AI_WORKFLOW_DIR}/src/workflow/metrics/**/*", allowEmptyArchive: true
        }
        
        failure {
            emailext(
                subject: "AI Workflow Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Check console output at ${env.BUILD_URL}",
                recipientProviders: [developers(), requestor()]
            )
        }
        
        success {
            script {
                if (env.BRANCH_NAME == 'main') {
                    // Auto-commit documentation updates
                    dir("${AI_WORKFLOW_DIR}") {
                        sh '''
                            git config user.name "Jenkins AI Workflow"
                            git config user.email "jenkins@example.com"
                            git add docs/ CHANGELOG.md
                            git commit -m "chore: automated documentation update [skip ci]" || true
                            git push origin main
                        '''
                    }
                }
            }
        }
    }
}
```

### Multibranch Pipeline

```groovy
pipeline {
    agent any
    
    stages {
        stage('Detect Changes') {
            steps {
                script {
                    def changedFiles = sh(
                        script: 'git diff --name-only HEAD~1',
                        returnStdout: true
                    ).trim()
                    
                    env.DOCS_CHANGED = changedFiles.contains('docs/') ? 'true' : 'false'
                    env.CODE_CHANGED = changedFiles.contains('src/') ? 'true' : 'false'
                    env.TESTS_CHANGED = changedFiles.contains('tests/') ? 'true' : 'false'
                }
            }
        }
        
        stage('Targeted Validation') {
            steps {
                dir("${AI_WORKFLOW_DIR}") {
                    script {
                        def steps = '0'  // Always analyze
                        
                        if (env.DOCS_CHANGED == 'true') {
                            steps += ',documentation_updates'
                        }
                        if (env.CODE_CHANGED == 'true') {
                            steps += ',code_review,test_execution'
                        }
                        if (env.TESTS_CHANGED == 'true') {
                            steps += ',test_execution,test_review'
                        }
                        
                        sh """
                            ./src/workflow/execute_tests_docs_workflow.sh \
                                --steps '${steps}' \
                                --parallel \
                                --auto
                        """
                    }
                }
            }
        }
    }
}
```

---

## Docker Integration

### Dockerfile

Create a containerized environment:

```dockerfile
FROM node:25-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    jq \
    yq \
    bats

# Install workflow
WORKDIR /opt/ai-workflow
COPY . .

# Install npm dependencies
RUN npm ci

# Initialize submodules
RUN git submodule update --init --recursive

# Create cache directories
RUN mkdir -p \
    src/workflow/.ai_cache \
    src/workflow/metrics \
    src/workflow/backlog \
    src/workflow/logs

# Set environment
ENV PATH="/opt/ai-workflow/src/workflow:${PATH}"
ENV AI_WORKFLOW_HOME="/opt/ai-workflow"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bash /opt/ai-workflow/src/workflow/lib/health_check.sh || exit 1

ENTRYPOINT ["/opt/ai-workflow/src/workflow/execute_tests_docs_workflow.sh"]
CMD ["--smart-execution", "--parallel", "--auto"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  ai-workflow:
    build: .
    container_name: ai-workflow-validator
    volumes:
      - ./:/workspace
      - ai-cache:/opt/ai-workflow/src/workflow/.ai_cache
      - ml-data:/opt/ai-workflow/.ml_data
    environment:
      - CI=true
      - AUTO_MODE=true
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    command: >
      --smart-execution
      --parallel
      --auto
      --no-resume
    networks:
      - ci-network

volumes:
  ai-cache:
  ml-data:

networks:
  ci-network:
    driver: bridge
```

### Running in Docker

```bash
# Build image
docker build -t ai-workflow:latest .

# Run validation
docker run --rm \
  -v $(pwd):/workspace \
  -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
  ai-workflow:latest \
  --smart-execution \
  --parallel \
  --auto

# Interactive mode
docker run -it --rm \
  -v $(pwd):/workspace \
  ai-workflow:latest \
  bash

# With Docker Compose
docker-compose up --abort-on-container-exit
```

---

## Best Practices

### 1. Choose the Right Execution Mode

```bash
# Pull requests - fast feedback (5-10 min)
--steps 0,documentation_updates,code_review,test_execution

# Pre-merge validation (10-15 min)
--smart-execution --parallel

# Release builds - comprehensive (20-30 min)
--smart-execution --parallel --ml-optimize --multi-stage --generate-docs
```

### 2. Cache Strategically

```yaml
# GitHub Actions
- uses: actions/cache@v4
  with:
    path: |
      src/workflow/.ai_cache
      .ml_data
      node_modules
    key: ${{ runner.os }}-${{ hashFiles('**/package-lock.json', 'src/**/*.sh') }}
```

### 3. Fail Fast

```bash
# Enable strict error handling
./execute_tests_docs_workflow.sh \
  --fail-fast \
  --auto \
  --no-resume
```

### 4. Monitor Performance

```bash
# Track execution metrics
cat src/workflow/metrics/current_run.json

# Analyze trends
python3 scripts/analyze_metrics.py \
  src/workflow/metrics/history.jsonl \
  --days 30
```

### 5. Secure Secrets

```yaml
# GitHub Actions secrets
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  COPILOT_TOKEN: ${{ secrets.COPILOT_TOKEN }}

# Never log sensitive data
run: |
  export GITHUB_TOKEN="${{ secrets.GITHUB_TOKEN }}"
  echo "::add-mask::${GITHUB_TOKEN}"
```

### 6. Handle Artifacts

```yaml
# Upload for debugging
- uses: actions/upload-artifact@v4
  if: failure()
  with:
    name: failure-logs
    path: |
      src/workflow/logs/
      src/workflow/backlog/
    retention-days: 7
```

---

## Troubleshooting

### Common Issues

#### 1. Timeout Errors

**Symptom**: Workflow times out in CI

**Solution**:
```yaml
# Increase timeout
timeout-minutes: 45

# Use smart execution
run: ./execute_tests_docs_workflow.sh --smart-execution --parallel
```

#### 2. Cache Misses

**Symptom**: Poor cache hit rate

**Solution**:
```bash
# Verify cache key
cat src/workflow/.ai_cache/index.json | jq '.stats.hit_rate'

# Clear stale cache
rm -rf src/workflow/.ai_cache/*

# Warm up cache
./execute_tests_docs_workflow.sh --smart-execution --auto
```

#### 3. Authentication Failures

**Symptom**: Copilot CLI authentication fails

**Solution**:
```yaml
# Provide token
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# Or disable AI features
run: ./execute_tests_docs_workflow.sh --no-ai --auto
```

#### 4. Resource Exhaustion

**Symptom**: Out of memory or disk space

**Solution**:
```yaml
# Limit parallel jobs
run: ./execute_tests_docs_workflow.sh --parallel --max-jobs 2

# Clean artifacts
- run: find src/workflow/backlog -mtime +7 -delete
```

#### 5. Git Issues

**Symptom**: Submodule or checkout problems

**Solution**:
```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Full history
    submodules: recursive  # Include .workflow_core
    clean: true  # Clean working tree
```

### Getting Help

- **Documentation**: `docs/guides/user/TROUBLESHOOTING.md`
- **Logs**: `src/workflow/logs/`
- **Metrics**: `src/workflow/metrics/`
- **GitHub Issues**: Report bugs with full logs
- **Health Check**: `./src/workflow/lib/health_check.sh`

---

## Additional Resources

- [Performance Tuning Guide](../user-guide/PERFORMANCE_TUNING.md)
- [Troubleshooting Guide](../user-guide/TROUBLESHOOTING.md)
- [Command Line Reference](../user-guide/COMMAND_LINE_REFERENCE.md)
- [Project Reference](../PROJECT_REFERENCE.md)

---

**Last Updated**: 2026-02-09  
**Version**: 4.0.1
