# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 2.4.x   | :white_check_mark: |
| 2.3.x   | :white_check_mark: |
| < 2.3   | :x:                |

## Reporting a Vulnerability

We take the security of AI Workflow Automation seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Where to Report

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of these methods:

1. **GitHub Security Advisories** (Preferred)
   - Navigate to the Security tab
   - Click "Report a vulnerability"
   - Fill out the security advisory form

2. **Direct Contact**
   - Open a **private** issue mentioning @mpbarbosa with "SECURITY" in the title
   - Contact the project maintainer directly via GitHub

3. **Email** (If available)
   - If project owner email is available, use that with subject "SECURITY: [Brief Description]"

### What to Include

Please include the following information in your report:

- **Type of vulnerability** (e.g., code injection, authentication bypass, etc.)
- **Full paths of source file(s)** related to the vulnerability
- **Location of the affected source code** (tag/branch/commit or direct URL)
- **Step-by-step instructions** to reproduce the issue
- **Proof-of-concept or exploit code** (if possible)
- **Impact of the vulnerability** (what an attacker could do)
- **Suggested fix** (if you have one)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within **48 hours**
- **Initial Assessment**: We will provide an initial assessment within **5 business days**
- **Updates**: We will keep you informed of progress toward fixing the vulnerability
- **Disclosure**: We will work with you to understand the issue and develop a fix
- **Credit**: We will credit you for the discovery (unless you prefer to remain anonymous)

### Security Update Process

1. **Confirmation**: We confirm the vulnerability and determine its severity
2. **Fix Development**: We develop a fix in a private repository
3. **Testing**: We thoroughly test the fix
4. **Release**: We release a security patch
5. **Disclosure**: We publish a security advisory
6. **Credit**: We credit the reporter in the advisory

### Preferred Languages

We prefer all communications to be in English.

---

## Security Best Practices

When using AI Workflow Automation, follow these security best practices:

### For Users

**1. Keep Updated**
- Always use the latest supported version (v2.4.x)
- Subscribe to repository releases for security updates
- Review release notes for security fixes

**2. Secure Your Environment**
- Run with minimum necessary permissions
- Don't run as root unless absolutely necessary
- Use dedicated service accounts when possible

**3. Protect Credentials**
- Never commit API keys or tokens to version control
- Use environment variables for sensitive data
- Rotate credentials regularly

**4. Input Validation**
- Validate all external inputs
- Be cautious with user-supplied file paths
- Sanitize data before processing

**5. File Permissions**
- Set appropriate permissions on workflow files
- Protect configuration files (644 for read, 600 for sensitive)
- Secure log directories

### For Developers

**1. Code Review**
- All code changes require review
- Security-sensitive changes require extra scrutiny
- Use ShellCheck to catch common vulnerabilities

**2. Dependency Management**
- Keep dependencies updated
- Review dependency security advisories
- Minimize third-party dependencies

**3. Secure Coding**
- Always quote variables in shell scripts
- Use `set -euo pipefail` for error handling
- Validate and sanitize all inputs
- Avoid `eval` and dynamic command execution
- Use absolute paths when possible

**4. Testing**
- Write tests for security-relevant functionality
- Test edge cases and error conditions
- Include security regression tests

**5. Documentation**
- Document security considerations
- Update SECURITY.md with new risks
- Provide secure usage examples

---

## Known Security Considerations

### Shell Script Execution

**Risk**: Shell scripts can be vulnerable to command injection if not properly written.

**Mitigation**:
- All variables are quoted: `"${variable}"`
- Input validation on all external inputs
- No use of `eval` or unquoted command substitution
- ShellCheck used to catch vulnerabilities

### File System Access

**Risk**: Improper file operations could lead to unauthorized access or data loss.

**Mitigation**:
- Validation of all file paths
- Checks for path traversal attempts
- Proper file permission handling
- Atomic file operations where possible

### AI Integration

**Risk**: AI responses could potentially contain malicious content.

**Mitigation**:
- AI outputs are sanitized before use
- No automatic execution of AI-generated code
- User review required for AI suggestions
- Caching prevents repeated malicious responses

### Configuration Files

**Risk**: Malicious configuration could alter workflow behavior.

**Mitigation**:
- Configuration validation before use
- YAML parsing with safe loader
- No code execution from config
- Clear documentation of config options

### Third-Party Dependencies

**Risk**: Vulnerabilities in dependencies could affect the workflow.

**Mitigation**:
- Minimal dependencies (primarily system tools)
- Regular review of dependency security
- Version pinning for Node.js (v25.2.1+)
- No installation of unverified packages

---

## Security Disclosure Policy

### Coordinated Disclosure

We follow a coordinated disclosure process:

1. **Private Reporting**: Report vulnerability privately (not via public issues)
2. **Acknowledgment**: We acknowledge within 48 hours
3. **Investigation**: We investigate and develop a fix
4. **Fix Release**: We release a patched version
5. **Public Disclosure**: We publish security advisory
6. **Credit**: We credit the reporter

### Disclosure Timeline

- **Day 0**: Vulnerability reported
- **Day 2**: Acknowledgment sent
- **Day 7**: Initial assessment complete
- **Day 30**: Target for fix release (varies by severity)
- **Day 30+**: Public disclosure after fix is available

### Embargo Period

We request a **90-day embargo** for critical vulnerabilities to allow users time to update. We're happy to work with you on a disclosure timeline that works for everyone.

---

## Security Updates

### How to Stay Informed

- **GitHub Security Advisories**: Watch the repository for security updates
- **Release Notes**: Check RELEASE_NOTES for security fixes
- **Changelog**: Review CHANGELOG.md for security-related changes
- **GitHub Releases**: Subscribe to release notifications

### Security Patch Versions

Security fixes are released as:
- **Critical/High**: Patch release (e.g., 2.4.1) within 7 days
- **Medium**: Patch release within 30 days
- **Low**: Next minor release

---

## Scope

### In Scope

The following are in scope for security vulnerability reports:

- ✅ Command injection vulnerabilities
- ✅ Path traversal vulnerabilities
- ✅ Arbitrary code execution
- ✅ Privilege escalation
- ✅ Authentication/authorization bypass
- ✅ Sensitive data exposure
- ✅ Denial of service (if practical to exploit)

### Out of Scope

The following are out of scope:

- ❌ Social engineering attacks
- ❌ Physical attacks
- ❌ Issues in third-party dependencies (report to them directly)
- ❌ Issues requiring physical access
- ❌ Issues requiring malicious or intentionally misconfigured environments
- ❌ Self-XSS or issues requiring user to execute malicious commands

---

## Recognition

We believe in recognizing security researchers who help us keep our project secure.

### Hall of Fame

Security researchers who responsibly disclose vulnerabilities will be:
- Credited in the security advisory (unless they prefer anonymity)
- Listed in our Security Hall of Fame (coming soon)
- Thanked in release notes

### No Bug Bounty Program

Currently, we do not have a bug bounty program. However, we deeply appreciate responsible disclosure and will recognize contributions.

---

## Security-Related Configuration

### Recommended Settings

```yaml
# .workflow-config.yaml - Security recommendations

# Use specific versions, not latest
tech_stack:
  primary_language: "bash"
  
# Limit directory access
structure:
  exclude_dirs:
    - ".git"
    - "node_modules"
    - ".env"
    - "secrets"
```

### Environment Variables

Sensitive data should use environment variables:

```bash
# Don't do this (hardcoded secrets)
API_KEY="secret123"

# Do this (environment variable)
API_KEY="${GITHUB_TOKEN}"
```

---

## Questions?

If you have questions about this security policy:

1. Check the [FAQ](#faq) below
2. Review our [documentation](docs/)
3. Open a discussion (not for vulnerabilities)
4. Contact maintainers (for security clarifications)

---

## FAQ

### Q: What qualifies as a security vulnerability?

**A**: Any issue that could allow an attacker to:
- Execute arbitrary code
- Access unauthorized data
- Bypass security controls
- Cause denial of service
- Escalate privileges

### Q: How long until you fix a reported vulnerability?

**A**: Depends on severity:
- Critical/High: 7 days target
- Medium: 30 days target
- Low: Next minor release

### Q: Will my name be public?

**A**: Only if you want it to be. We credit reporters in security advisories, but you can request anonymity.

### Q: Can I discuss the vulnerability publicly after reporting?

**A**: Please wait for our fix to be released and users to have time to update (typically 90 days or coordinated timeline).

### Q: What if I find a vulnerability in a dependency?

**A**: Report it to the dependency's maintainers. We'll track and update once a fix is available.

### Q: Do you have a bug bounty program?

**A**: Not currently, but we recognize and credit security researchers.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-23 | Initial security policy |

---

## Contact

For security-related questions (not vulnerabilities):
- GitHub Discussions: [ai_workflow/discussions](https://github.com/mpbarbosa/ai_workflow/discussions)
- Maintainer: @mpbarbosa

For security vulnerabilities:
- Use GitHub Security Advisories (preferred)
- Private issue with "SECURITY" in title

---

**Last Updated**: 2025-12-23  
**Status**: ✅ Official Security Policy  
**Version**: 1.0.0
