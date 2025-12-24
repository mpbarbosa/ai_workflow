# Step 8: Dependency_Validation

**Workflow Run ID:** workflow_20251214_225414
**Timestamp:** 2025-12-14 23:24:29
**Status:** Issues Found

---

## Issues and Findings

### Dependency Validation Issues

**Total Issues:** 1
**Total Dependencies:** 3
**Vulnerabilities:** 16
**Outdated Packages:** 0

### npm audit Output

```
{
  "auditReportVersion": 2,
  "vulnerabilities": {
    "anymatch": {
      "name": "anymatch",
      "severity": "moderate",
      "isDirect": false,
      "via": [
        "micromatch"
      ],
      "effects": [
        "chokidar"
      ],
      "range": "1.2.0 - 2.0.0",
      "nodes": [
        "node_modules/chokidar/node_modules/anymatch"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    },
    "braces": {
      "name": "braces",
      "severity": "high",
      "isDirect": false,
      "via": [
        {
          "source": 1098094,
          "name": "braces",
          "dependency": "braces",
          "title": "Uncontrolled resource consumption in braces",
          "url": "https://github.com/advisories/GHSA-grv7-fg5c-xmjg",
          "severity": "high",
          "cwe": [
            "CWE-400",
            "CWE-1050"
          ],
          "cvss": {
            "score": 7.5,
            "vectorString": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H"
          },
          "range": "<3.0.3"
        }
      ],
      "effects": [
        "chokidar",
        "micromatch"
      ],
      "range": "<3.0.3",
      "nodes": [
        "node_modules/braces"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    },
    "chokidar": {
      "name": "chokidar",
      "severity": "high",
      "isDirect": false,
      "via": [
        "anymatch",
        "braces",
        "readdirp"
      ],
      "effects": [
        "live-server"
      ],
      "range": "1.3.0 - 2.1.8",
      "nodes": [
        "node_modules/chokidar"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    },
    "glob": {
      "name": "glob",
      "severity": "high",
      "isDirect": false,
      "via": [
        {
          "source": 1109842,
          "name": "glob",
          "dependency": "glob",
          "title": "glob CLI: Command injection via -c/--cmd executes matches with shell:true",
          "url": "https://github.com/advisories/GHSA-5j98-mcp5-4vw2",
          "severity": "high",
          "cwe": [
            "CWE-78"
          ],
          "cvss": {
            "score": 7.5,
            "vectorString": "CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H"
          },
          "range": ">=10.2.0 <10.5.0"
        }
      ],
      "effects": [],
      "range": "10.2.0 - 10.4.5",
      "nodes": [
        "node_modules/glob"
      ],
      "fixAvailable": true
    },
    "js-yaml": {
      "name": "js-yaml",
      "severity": "moderate",
      "isDirect": false,
      "via": [
        {
          "source": 1109801,
          "name": "js-yaml",
          "dependency": "js-yaml",
          "title": "js-yaml has prototype pollution in merge (<<)",
          "url": "https://github.com/advisories/GHSA-mh29-5h37-fv8m",
          "severity": "moderate",
          "cwe": [
            "CWE-1321"
          ],
          "cvss": {
            "score": 5.3,
            "vectorString": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:N"
          },
          "range": "<3.14.2"
        }
      ],
      "effects": [],
      "range": "<3.14.2",
      "nodes": [
        "node_modules/js-yaml"
      ],
      "fixAvailable": true
    },
    "live-server": {
      "name": "live-server",
      "severity": "high",
      "isDirect": true,
      "via": [
        "chokidar"
      ],
      "effects": [],
      "range": ">=1.2.1",
      "nodes": [
        "node_modules/live-server"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    },
    "micromatch": {
      "name": "micromatch",
      "severity": "high",
      "isDirect": false,
      "via": [
        {
          "source": 1098681,
          "name": "micromatch",
          "dependency": "micromatch",
          "title": "Regular Expression Denial of Service (ReDoS) in micromatch",
          "url": "https://github.com/advisories/GHSA-952p-6rrq-rcjv",
          "severity": "moderate",
          "cwe": [
            "CWE-1333"
          ],
          "cvss": {
            "score": 5.3,
            "vectorString": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:L"
          },
          "range": "<4.0.8"
        },
        "braces"
      ],
      "effects": [
        "anymatch",
        "readdirp"
      ],
      "range": "<=4.0.7",
      "nodes": [
        "node_modules/chokidar/node_modules/micromatch",
        "node_modules/readdirp/node_modules/micromatch"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    },
    "readdirp": {
      "name": "readdirp",
      "severity": "moderate",
      "isDirect": false,
      "via": [
        "micromatch"
      ],
      "effects": [
        "chokidar"
      ],
      "range": "2.2.0 - 2.2.1",
      "nodes": [
        "node_modules/readdirp"
      ],
      "fixAvailable": {
        "name": "live-server",
        "version": "1.2.0",
        "isSemVerMajor": true
      }
    }
  },
  "metadata": {
    "vulnerabilities": {
      "info": 0,
      "low": 0,
      "moderate": 3,
      "high": 5,
      "critical": 0,
      "total": 8
    },
    "dependencies": {
      "prod": 1,
      "dev": 569,
      "optional": 31,
      "peer": 5,
      "peerOptional": 0,
      "total": 569
    }
  }
}
```
### Outdated Packages

```

```

---

**Generated by:** Tests & Documentation Workflow Automation v2.0.0
