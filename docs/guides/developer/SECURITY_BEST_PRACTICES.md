# Security Best Practices Guide

**Version**: 1.0.0  
**Last Updated**: 2026-02-10  
**Status**: Complete

## Table of Contents

- [Overview](#overview)
- [Security Principles](#security-principles)
- [Secrets Management](#secrets-management)
- [API Key Protection](#api-key-protection)
- [Git Security](#git-security)
- [File System Security](#file-system-security)
- [AI Integration Security](#ai-integration-security)
- [Code Review Security](#code-review-security)
- [CI/CD Security](#cicd-security)
- [Incident Response](#incident-response)
- [Security Checklist](#security-checklist)

## Overview

The AI Workflow Automation system handles sensitive data including API keys, Git credentials, and project source code. This guide outlines security best practices to protect your projects and credentials.

### Security Scope

| Area | Risk Level | Mitigation |
|------|------------|------------|
| API Keys (GitHub Copilot) | HIGH | Environment variables, never committed |
| Git Credentials | HIGH | SSH keys, credential helpers |
| Source Code | MEDIUM | Access controls, audit logs |
| AI Responses | MEDIUM | Cache encryption, TTL limits |
| File Operations | MEDIUM | Permission checks, safe paths |
| External Commands | LOW | Input validation, safe execution |

## Security Principles

### 1. Defense in Depth

**Multiple layers of security controls**:

```bash
# Layer 1: Input validation
validate_input() {
    local input="$1"
    
    # Check for path traversal
    [[ "${input}" =~ \.\. ]] && return 1
    
    # Check for command injection
    [[ "${input}" =~ [';|&$`] ]] && return 1
    
    return 0
}

# Layer 2: Sanitization
sanitize_input() {
    local input="$1"
    # Remove dangerous characters
    echo "${input//[^a-zA-Z0-9_-]/}"
}

# Layer 3: Safe execution
safe_execute() {
    local command="$1"
    validate_input "${command}" || return 1
    local sanitized=$(sanitize_input "${command}")
    
    # Execute with minimal privileges
    "${sanitized}"
}
```

### 2. Least Privilege

**Run with minimum necessary permissions**:

```bash
# ✅ Good: Check before destructive operations
safe_delete() {
    local file="$1"
    
    # Verify file is in safe location
    [[ "${file}" =~ ^"${PROJECT_ROOT}" ]] || {
        echo "Error: File outside project root"
        return 1
    }
    
    # Check write permissions
    [[ -w "${file}" ]] || {
        echo "Error: No write permission"
        return 1
    }
    
    rm "${file}"
}

# ❌ Bad: Unrestricted deletion
rm -rf "$1"  # Dangerous!
```

### 3. Secure by Default

**Default to secure configuration**:

```bash
# ✅ Good: Opt-in to risky features
ALLOW_EXTERNAL_SCRIPTS=${ALLOW_EXTERNAL_SCRIPTS:-false}

execute_script() {
    local script="$1"
    
    if [[ "${ALLOW_EXTERNAL_SCRIPTS}" != "true" ]]; then
        echo "Error: External scripts disabled by default"
        echo "Set ALLOW_EXTERNAL_SCRIPTS=true to enable"
        return 1
    fi
    
    # ... execute script
}

# ❌ Bad: Opt-out of security
DISABLE_VALIDATION=${DISABLE_VALIDATION:-false}
```

### 4. Fail Securely

**Handle errors safely**:

```bash
# ✅ Good: Fail closed
load_credentials() {
    local cred_file="$1"
    
    if [[ ! -f "${cred_file}" ]]; then
        echo "Error: Credentials file not found"
        return 1  # Fail - don't proceed without credentials
    fi
    
    if [[ ! -r "${cred_file}" ]]; then
        echo "Error: Cannot read credentials file"
        return 1
    fi
    
    # Load credentials
}

# ❌ Bad: Fail open
load_credentials() {
    [[ -f "$1" ]] && source "$1"
    # Continues even if file doesn't exist!
}
```

## Secrets Management

### Environment Variables

**NEVER commit secrets to Git**:

```bash
# ✅ Good: Use environment variables
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxx"

# In code
github_api_call() {
    local token="${GITHUB_TOKEN:?GitHub token not set}"
    curl -H "Authorization: Bearer ${token}" ...
}

# ❌ Bad: Hardcoded secrets
GITHUB_TOKEN="ghp_abc123def456"  # NEVER DO THIS
```

### .env Files

**Use .env files for local development**:

```bash
# .env (add to .gitignore!)
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxx
DATABASE_URL=postgresql://user:pass@localhost/db

# Load in scripts
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
fi

# Verify environment
require_env_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [[ -z "${var_value}" ]]; then
        echo "Error: ${var_name} not set"
        echo "Set it in .env file or environment"
        return 1
    fi
}

require_env_var "GITHUB_TOKEN"
require_env_var "OPENAI_API_KEY"
```

### .gitignore Configuration

**Prevent accidental commits**:

```gitignore
# .gitignore - Essential entries

# Environment files
.env
.env.local
.env.*.local

# API keys and credentials
*_credentials.json
*_key.txt
*.pem
*.key

# AI cache may contain sensitive responses
.ai_cache/

# Temporary files that might contain secrets
*.tmp
*.temp
/tmp/

# IDE-specific files that might store secrets
.vscode/settings.json
.idea/workspace.xml

# System files
.DS_Store
Thumbs.db
```

### Secret Detection

**Scan for accidentally committed secrets**:

```bash
#!/usr/bin/env bash
# scripts/detect_secrets.sh

# Check for common secret patterns
check_for_secrets() {
    echo "Scanning for secrets..."
    
    # GitHub tokens
    if git grep -E 'ghp_[0-9a-zA-Z]{36}' HEAD; then
        echo "❌ Found GitHub token!"
        return 1
    fi
    
    # API keys
    if git grep -E 'api[_-]?key["\s:=]+[0-9a-zA-Z]{20,}' HEAD; then
        echo "❌ Found API key pattern!"
        return 1
    fi
    
    # AWS keys
    if git grep -E 'AKIA[0-9A-Z]{16}' HEAD; then
        echo "❌ Found AWS access key!"
        return 1
    fi
    
    # Private keys
    if git grep -E '-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----' HEAD; then
        echo "❌ Found private key!"
        return 1
    fi
    
    echo "✅ No secrets detected"
    return 0
}

check_for_secrets
```

### Pre-commit Hook for Secrets

**Prevent commits with secrets**:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

echo "Checking for secrets..."

# Scan staged files
SECRETS_FOUND=false

# Check for GitHub tokens
if git diff --cached | grep -E 'ghp_[0-9a-zA-Z]{36}'; then
    echo "❌ GitHub token found in staged changes!"
    SECRETS_FOUND=true
fi

# Check for common secret patterns
if git diff --cached | grep -iE '(password|secret|token|api[_-]?key)\s*[:=]\s*["\047][^"\047]{8,}'; then
    echo "❌ Potential secret found in staged changes!"
    SECRETS_FOUND=true
fi

if [[ "${SECRETS_FOUND}" == "true" ]]; then
    echo
    echo "Commit aborted to prevent secret exposure."
    echo "Review staged changes and remove secrets."
    exit 1
fi

echo "✅ No secrets detected"
exit 0
```

## API Key Protection

### GitHub Copilot CLI

**Secure usage of GitHub Copilot**:

```bash
# ✅ Good: Use GitHub CLI authentication
check_github_auth() {
    if ! gh auth status &>/dev/null; then
        echo "Error: Not authenticated with GitHub"
        echo "Run: gh auth login"
        return 1
    fi
}

ai_call() {
    check_github_auth || return 1
    
    # GitHub CLI handles authentication securely
    gh copilot suggest "$@"
}

# ❌ Bad: Manual token handling
ai_call() {
    curl -H "Authorization: Bearer ${GITHUB_TOKEN}" ...
}
```

### Token Rotation

**Regularly rotate API keys**:

```bash
# Automated token age check
check_token_age() {
    local token_file="${HOME}/.config/gh/hosts.yml"
    
    if [[ -f "${token_file}" ]]; then
        local token_age=$(($(date +%s) - $(stat -f %m "${token_file}" 2>/dev/null || stat -c %Y "${token_file}")))
        local days_old=$((token_age / 86400))
        
        if [[ ${days_old} -gt 90 ]]; then
            echo "⚠️  GitHub token is ${days_old} days old"
            echo "Consider rotating: gh auth refresh"
        fi
    fi
}
```

### Token Scopes

**Use minimum required scopes**:

```bash
# GitHub token scopes needed:
# - repo (if accessing private repos)
# - read:user (for user info)
# 
# NOT needed:
# - admin:org
# - delete_repo
# - admin:gpg_key

# Verify token scopes
check_token_scopes() {
    local token="${GITHUB_TOKEN:?Token not set}"
    
    # Query GitHub API for token scopes
    local scopes=$(curl -sI \
        -H "Authorization: Bearer ${token}" \
        https://api.github.com/user \
        | grep -i '^x-oauth-scopes:' \
        | cut -d: -f2 \
        | tr ',' '\n' \
        | sed 's/^ //')
    
    echo "Token has scopes:"
    echo "${scopes}"
    
    # Warn about excessive permissions
    if echo "${scopes}" | grep -q 'delete_repo'; then
        echo "⚠️  Token has delete_repo scope (not recommended)"
    fi
}
```

## Git Security

### SSH Keys

**Use SSH for Git operations**:

```bash
# ✅ Good: SSH URLs
git clone git@github.com:user/repo.git

# ✅ Good: Check SSH key
if [[ ! -f "${HOME}/.ssh/id_ed25519" ]] && [[ ! -f "${HOME}/.ssh/id_rsa" ]]; then
    echo "No SSH key found. Generate one:"
    echo "  ssh-keygen -t ed25519 -C 'your_email@example.com'"
fi

# ❌ Bad: HTTPS with embedded credentials
git clone https://username:password@github.com/user/repo.git
```

### Signed Commits

**Sign commits with GPG**:

```bash
# Configure Git to sign commits
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# Verify signature
git log --show-signature

# Check commit is signed
verify_commit_signed() {
    local commit="${1:-HEAD}"
    
    if git verify-commit "${commit}" 2>/dev/null; then
        echo "✅ Commit is signed"
        return 0
    else
        echo "⚠️  Commit is not signed"
        return 1
    fi
}
```

### Git Hooks for Security

**Prevent sensitive file commits**:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

# Block sensitive files
SENSITIVE_FILES=(
    ".env"
    "*.pem"
    "*.key"
    "*_credentials.json"
    "id_rsa"
    "id_ed25519"
)

echo "Checking for sensitive files..."

for pattern in "${SENSITIVE_FILES[@]}"; do
    if git diff --cached --name-only | grep -E "${pattern}"; then
        echo "❌ Blocked: Attempting to commit sensitive file matching '${pattern}'"
        exit 1
    fi
done

echo "✅ No sensitive files detected"
```

### Branch Protection

**Workflow security settings**:

```bash
# Check for branch protection
check_branch_protection() {
    local branch="${1:-main}"
    local repo_url=$(git remote get-url origin)
    
    # Extract owner/repo from URL
    local repo_path=$(echo "${repo_url}" | sed -E 's|.*github\.com[:/](.*)\.git|\1|')
    
    echo "Checking branch protection for ${repo_path}:${branch}"
    
    gh api "repos/${repo_path}/branches/${branch}/protection" \
        --jq '.required_status_checks.strict'
}
```

## File System Security

### Path Validation

**Prevent path traversal attacks**:

```bash
# ✅ Good: Validate paths
validate_path() {
    local path="$1"
    local base_dir="${PROJECT_ROOT}"
    
    # Resolve to absolute path
    local resolved_path=$(realpath -m "${path}" 2>/dev/null || echo "${path}")
    
    # Check if path is within base directory
    if [[ "${resolved_path}" != "${base_dir}"* ]]; then
        echo "Error: Path outside project root: ${path}"
        return 1
    fi
    
    # Check for directory traversal attempts
    if [[ "${path}" =~ \.\. ]]; then
        echo "Error: Path traversal detected: ${path}"
        return 1
    fi
    
    return 0
}

# Use in file operations
safe_read_file() {
    local file="$1"
    
    validate_path "${file}" || return 1
    
    [[ -f "${file}" ]] || {
        echo "Error: File not found: ${file}"
        return 1
    }
    
    [[ -r "${file}" ]] || {
        echo "Error: File not readable: ${file}"
        return 1
    }
    
    cat "${file}"
}

# ❌ Bad: No validation
cat "$1"  # Dangerous!
```

### File Permissions

**Set appropriate permissions**:

```bash
# ✅ Good: Secure file creation
create_secure_file() {
    local file="$1"
    local content="$2"
    
    # Create with restricted permissions
    umask 077  # Owner read/write only
    echo "${content}" > "${file}"
    chmod 600 "${file}"
    
    echo "Created secure file: ${file} (permissions: 600)"
}

# Create sensitive directories
create_secure_dir() {
    local dir="$1"
    mkdir -p "${dir}"
    chmod 700 "${dir}"
}

# ❌ Bad: World-readable sensitive files
echo "${SECRET}" > /tmp/secret.txt  # World-readable by default!
```

### Temporary Files

**Secure temporary file handling**:

```bash
# ✅ Good: Secure temp file creation
create_temp_file() {
    local temp_file
    temp_file=$(mktemp) || return 1
    
    # Set restrictive permissions
    chmod 600 "${temp_file}"
    
    # Register for cleanup
    trap "rm -f '${temp_file}'" EXIT
    
    echo "${temp_file}"
}

# Use secure temp files
process_sensitive_data() {
    local temp_file
    temp_file=$(create_temp_file) || return 1
    
    # Process data
    echo "sensitive data" > "${temp_file}"
    
    # File automatically cleaned up on exit
}

# ❌ Bad: Predictable temp file names
temp_file="/tmp/myapp_${USER}.tmp"  # Predictable, insecure
```

## AI Integration Security

### Prompt Injection Prevention

**Sanitize AI inputs**:

```bash
# ✅ Good: Sanitize user input before AI
sanitize_ai_prompt() {
    local prompt="$1"
    
    # Remove potential injection attempts
    # - Command execution attempts
    # - System prompts override
    # - Data exfiltration attempts
    
    # Remove shell command patterns
    prompt="${prompt//\$(/}"
    prompt="${prompt//\`/}"
    
    # Remove AI system prompt override attempts
    prompt="${prompt//system:/}"
    prompt="${prompt//SYSTEM:/}"
    
    # Limit length to prevent resource exhaustion
    prompt="${prompt:0:10000}"
    
    echo "${prompt}"
}

ai_call_safe() {
    local persona="$1"
    local user_prompt="$2"
    
    # Sanitize user input
    local safe_prompt=$(sanitize_ai_prompt "${user_prompt}")
    
    # Call AI with sanitized input
    gh copilot suggest -t shell "${safe_prompt}"
}

# ❌ Bad: Unsanitized user input to AI
ai_call() {
    gh copilot suggest -t shell "$1"  # User input directly to AI!
}
```

### AI Response Validation

**Validate AI-generated content**:

```bash
# ✅ Good: Validate AI responses before execution
execute_ai_suggestion() {
    local suggestion="$1"
    
    # Validate suggestion
    if [[ "${suggestion}" =~ rm[[:space:]]+-rf[[:space:]]+/ ]]; then
        echo "Error: AI suggested dangerous command"
        return 1
    fi
    
    # Check for suspicious patterns
    if [[ "${suggestion}" =~ (curl|wget).*\|[[:space:]]*sh ]]; then
        echo "Error: AI suggested piping to shell"
        return 1
    fi
    
    # Show suggestion to user for approval
    echo "AI suggests:"
    echo "${suggestion}"
    read -p "Execute? (yes/no): " confirm
    
    if [[ "${confirm}" == "yes" ]]; then
        eval "${suggestion}"
    fi
}
```

### AI Cache Security

**Secure AI response caching**:

```bash
# ✅ Good: Secure cache directory
init_ai_cache() {
    local cache_dir="${HOME}/.ai_workflow_cache"
    
    # Create with restrictive permissions
    mkdir -p "${cache_dir}"
    chmod 700 "${cache_dir}"
    
    # Set cache file permissions
    touch "${cache_dir}/index.json"
    chmod 600 "${cache_dir}/index.json"
}

# Encrypt sensitive cache entries
cache_set_secure() {
    local key="$1"
    local value="$2"
    
    # Encrypt value before caching
    local encrypted
    encrypted=$(echo "${value}" | openssl enc -aes-256-cbc -pbkdf2 -pass pass:"${CACHE_ENCRYPTION_KEY}")
    
    cache_set "${key}" "${encrypted}"
}

# ❌ Bad: World-readable cache
mkdir /tmp/ai_cache  # World-readable!
```

### Data Minimization

**Don't send unnecessary data to AI**:

```bash
# ✅ Good: Send only necessary context
prepare_ai_context() {
    local file="$1"
    
    # Extract only relevant sections
    # Remove sensitive comments
    grep -v '^#.*SECRET' "${file}" | \
    grep -v '^#.*PASSWORD' | \
    head -n 100  # Limit size
}

ai_analyze_code() {
    local file="$1"
    local context=$(prepare_ai_context "${file}")
    
    ai_call "code_reviewer" "Analyze this code: ${context}"
}

# ❌ Bad: Send entire files including secrets
ai_analyze_code() {
    ai_call "code_reviewer" "Analyze: $(cat $1)"
}
```

## Code Review Security

### Security-Focused Review

**Checklist for code reviews**:

```bash
# Security review checklist
security_review_checklist() {
    local file="$1"
    
    echo "🔒 Security Review Checklist for ${file}"
    echo
    
    # Check 1: Hardcoded secrets
    if grep -E '(password|secret|token|api_key)\s*=\s*["\047]' "${file}"; then
        echo "❌ Possible hardcoded secrets found"
    else
        echo "✅ No hardcoded secrets"
    fi
    
    # Check 2: SQL injection risk
    if grep -E 'SELECT.*\$[{]?' "${file}"; then
        echo "⚠️  Possible SQL injection risk - verify parameterization"
    else
        echo "✅ No obvious SQL injection risks"
    fi
    
    # Check 3: Command injection risk
    if grep -E 'eval|system|exec|`' "${file}"; then
        echo "⚠️  Command execution found - verify input sanitization"
    else
        echo "✅ No command execution"
    fi
    
    # Check 4: Path traversal risk
    if grep -E 'realpath|readlink' "${file}"; then
        echo "✅ Path normalization found"
    elif grep -E '\.\.' "${file}"; then
        echo "⚠️  Path traversal risk - verify validation"
    fi
    
    # Check 5: Insecure temp files
    if grep -E '/tmp/[a-z]+\.txt' "${file}"; then
        echo "⚠️  Predictable temp file names - use mktemp"
    else
        echo "✅ No predictable temp files"
    fi
    
    echo
    echo "Review complete. Address any ⚠️  or ❌ items above."
}
```

### Automated Security Scans

**Integrate security tools**:

```bash
# Run ShellCheck for security issues
shellcheck_security() {
    local file="$1"
    
    # Run ShellCheck with security focus
    shellcheck --severity=warning --format=gcc "${file}" | \
        grep -E '(SC2086|SC2046|SC2006|SC2116)'  # Security-relevant codes
}

# Scan for common vulnerabilities
vulnerability_scan() {
    local dir="${1:-.}"
    
    echo "Running vulnerability scan..."
    
    # Check for known vulnerable patterns
    grep -rn 'eval.*\$' "${dir}" --include='*.sh' || echo "✅ No eval with variables"
    grep -rn 'rm -rf \$' "${dir}" --include='*.sh' || echo "✅ No dangerous rm"
    grep -rn '>[[:space:]]*/dev/null.*2>&1' "${dir}" --include='*.sh' && \
        echo "⚠️  Error suppression found - verify intentional"
}
```

## CI/CD Security

### GitHub Actions Security

**Secure workflow configuration**:

```yaml
# .github/workflows/secure.yml
name: Secure Workflow

on:
  pull_request:
  push:
    branches: [main]

# Limit permissions
permissions:
  contents: read
  pull-requests: read

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          # Don't persist credentials
          persist-credentials: false
      
      - name: Run security scan
        run: |
          # Scan for secrets
          ./scripts/detect_secrets.sh
      
      - name: Run tests
        run: |
          ./tests/run_all_tests.sh
        env:
          # Use GitHub secrets for sensitive data
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      # Don't expose secrets in logs
      - name: Process results
        run: |
          # Sanitize output
          ./scripts/process_results.sh | \
            sed 's/ghp_[0-9a-zA-Z]*/***REDACTED***/g'
```

### Secret Management in CI

**Use GitHub Secrets**:

```bash
# In CI environment
use_github_secrets() {
    # Secrets are automatically masked in logs
    local api_key="${API_KEY:?API_KEY not set in secrets}"
    
    # Use secret securely
    curl -H "Authorization: Bearer ${api_key}" ...
    
    # Don't echo secrets
    # echo "${api_key}"  # DON'T DO THIS
}

# Verify secrets are set
check_required_secrets() {
    local required_secrets=(
        "GITHUB_TOKEN"
        "API_KEY"
    )
    
    for secret in "${required_secrets[@]}"; do
        if [[ -z "${!secret}" ]]; then
            echo "Error: Required secret '${secret}' not set"
            return 1
        fi
    done
}
```

## Incident Response

### Compromised Credentials

**Immediate actions if credentials are leaked**:

```bash
# 1. Revoke compromised credentials immediately
revoke_github_token() {
    echo "🚨 Revoking GitHub token..."
    
    # Revoke via GitHub API
    gh api -X DELETE /applications/{client_id}/token \
        -f access_token="${GITHUB_TOKEN}"
    
    echo "✅ Token revoked"
}

# 2. Rotate all related credentials
rotate_credentials() {
    echo "🔄 Rotating credentials..."
    
    # Generate new GitHub token
    echo "1. Generate new token: https://github.com/settings/tokens"
    echo "2. Update secrets in GitHub Actions"
    echo "3. Update local .env file"
    echo "4. Restart services"
}

# 3. Audit access logs
audit_access() {
    echo "📋 Auditing access logs..."
    
    # Check GitHub audit log
    gh api /user/events | \
        jq '.[] | select(.type == "PushEvent") | .created_at, .repo.name'
}

# 4. Remove from Git history
remove_from_history() {
    local pattern="$1"
    
    echo "🗑️  Removing from Git history..."
    echo "⚠️  This will rewrite history!"
    
    read -p "Continue? (yes/no): " confirm
    [[ "${confirm}" != "yes" ]] && return 1
    
    # Use git-filter-repo (preferred) or BFG
    git filter-repo --invert-paths --path-glob "${pattern}"
    
    # Force push
    git push --force --all origin
}
```

### Security Incident Template

```markdown
# Security Incident Report

**Date**: YYYY-MM-DD HH:MM  
**Severity**: [CRITICAL/HIGH/MEDIUM/LOW]  
**Status**: [DETECTED/CONTAINED/RESOLVED]

## Incident Summary

Brief description of what happened.

## Timeline

- **HH:MM** - Incident detected
- **HH:MM** - Credentials revoked
- **HH:MM** - Audit completed
- **HH:MM** - Remediation applied
- **HH:MM** - Incident resolved

## Impact Assessment

- **Affected Systems**: List systems/repos affected
- **Data Exposure**: What data was potentially exposed
- **Access Logs**: Summary of unauthorized access

## Actions Taken

1. Revoked compromised credentials
2. Rotated all related credentials
3. Removed secrets from Git history
4. Notified affected parties
5. Updated security controls

## Root Cause

What caused the incident?

## Remediation

- [ ] Revoke old credentials
- [ ] Generate new credentials
- [ ] Update all systems
- [ ] Remove from Git history
- [ ] Notify stakeholders
- [ ] Update security procedures

## Prevention

How to prevent similar incidents:

1. Implement automated secret scanning
2. Add pre-commit hooks
3. Regular security training
4. Improved access controls

## Lessons Learned

What we learned from this incident.
```

## Security Checklist

### Pre-Deployment Checklist

```bash
# Run before deploying or releasing
pre_deployment_security_check() {
    local issues=0
    
    echo "🔒 Pre-Deployment Security Checklist"
    echo "===================================="
    
    # 1. Secrets check
    echo -n "1. Checking for secrets... "
    if ./scripts/detect_secrets.sh &>/dev/null; then
        echo "✅"
    else
        echo "❌"
        ((issues++))
    fi
    
    # 2. Dependency vulnerabilities
    echo -n "2. Checking dependencies... "
    if npm audit --audit-level=high &>/dev/null; then
        echo "✅"
    else
        echo "⚠️  Vulnerabilities found"
        ((issues++))
    fi
    
    # 3. Permissions check
    echo -n "3. Checking file permissions... "
    if find . -type f -name "*.sh" ! -perm 755 | grep -q .; then
        echo "⚠️  Incorrect permissions"
        ((issues++))
    else
        echo "✅"
    fi
    
    # 4. .gitignore check
    echo -n "4. Checking .gitignore... "
    if grep -q ".env" .gitignore && grep -q "*.pem" .gitignore; then
        echo "✅"
    else
        echo "❌ Missing entries"
        ((issues++))
    fi
    
    # 5. Test coverage
    echo -n "5. Running security tests... "
    if ./tests/run_all_tests.sh --security &>/dev/null; then
        echo "✅"
    else
        echo "❌"
        ((issues++))
    fi
    
    # Summary
    echo
    if [[ ${issues} -eq 0 ]]; then
        echo "✅ All security checks passed!"
        return 0
    else
        echo "❌ ${issues} security issue(s) found"
        echo "   Address issues before deploying"
        return 1
    fi
}
```

### Regular Security Audit

```bash
# Run monthly
monthly_security_audit() {
    echo "📅 Monthly Security Audit - $(date +%Y-%m)"
    echo "========================================"
    
    # 1. Credential rotation check
    echo "1. Checking credential age..."
    check_token_age
    
    # 2. Access review
    echo "2. Reviewing repository access..."
    gh repo list --json name,visibility,permissions
    
    # 3. Dependency audit
    echo "3. Auditing dependencies..."
    npm audit
    
    # 4. Git history scan
    echo "4. Scanning Git history..."
    ./scripts/detect_secrets.sh --scan-history
    
    # 5. Permission review
    echo "5. Reviewing file permissions..."
    find . -type f -perm -002 | head -10  # World-writable files
    
    # 6. Log review
    echo "6. Reviewing security logs..."
    # Review audit logs for suspicious activity
    
    echo
    echo "Audit complete. Review findings above."
}
```

### Security Training Checklist

**For team members**:

- [ ] Understand secrets management
- [ ] Know how to use .env files
- [ ] Familiar with .gitignore patterns
- [ ] Can detect secret leaks
- [ ] Know incident response procedure
- [ ] Understand secure coding practices
- [ ] Can review code for security issues
- [ ] Know how to rotate credentials

## Summary

Security is a shared responsibility. Follow these practices:

### Quick Security Rules

1. **NEVER** commit secrets to Git
2. **ALWAYS** use environment variables for secrets
3. **ALWAYS** validate and sanitize inputs
4. **ALWAYS** use least privilege principle
5. **NEVER** trust user input
6. **ALWAYS** use secure defaults
7. **ALWAYS** handle errors securely
8. **NEVER** log sensitive data

### When in Doubt

- Ask for security review
- Consult this guide
- Run security checks
- Choose the more secure option

### Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)

---

**Related Documentation**:
- [Testing Guide](COMPREHENSIVE_TESTING_GUIDE.md)
- [Contributing Guide](../../CONTRIBUTING.md)
- [Incident Response Plan](INCIDENT_RESPONSE.md) (internal)

**Version History**:
- 1.0.0 (2026-02-10): Initial security guide
