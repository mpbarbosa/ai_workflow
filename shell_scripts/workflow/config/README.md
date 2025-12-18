# Workflow Configuration Directory

This directory contains configuration files for the workflow automation system.

## Files

### paths.yaml
Centralized path configuration for improved portability and maintainability.

**Purpose**:
- Eliminates hardcoded absolute paths in scripts and documentation
- Enables easy deployment to different environments
- Provides single source of truth for all project paths

**Usage in Shell Scripts**:
```bash
# Load YAML configuration using yq or grep
PROJECT_ROOT=$(grep "^  root:" shell_scripts/workflow/config/paths.yaml | cut -d' ' -f4)
SRC_DIR="${PROJECT_ROOT}/src"
PUBLIC_DIR="${PROJECT_ROOT}/public"

# Alternative: Use yq for complex path resolution
if command -v yq &> /dev/null; then
  PROJECT_ROOT=$(yq eval '.project.root' shell_scripts/workflow/config/paths.yaml)
  SRC_DIR=$(yq eval '.directories.src' shell_scripts/workflow/config/paths.yaml)
fi

# From workflow scripts, use relative path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/paths.yaml"
```

**Usage in Node.js/JavaScript**:
```javascript
import { readFileSync } from 'fs';
import yaml from 'js-yaml';

const config = yaml.load(readFileSync('shell_scripts/workflow/config/paths.yaml', 'utf8'));
const projectRoot = config.project.root;
const srcDir = config.directories.src;
```

**Deployment**:
When deploying to a new environment:
1. Update `project.root` in `paths.yaml`
2. Update `environment.current` to match deployment environment
3. Verify all interpolated paths resolve correctly

**Path Interpolation**:
The YAML file uses `${variable.path}` syntax for path composition. Scripts must expand these variables when loading the configuration.

## Integration with Workflow System

The workflow automation system (`execute_tests_docs_workflow.sh`) can load this configuration:

```bash
# Load configuration at workflow startup
source shell_scripts/workflow/lib/config.sh

# Access paths
echo "Project root: ${PROJECT_ROOT}"
echo "Source directory: ${SRC_DIR}"
echo "Workflow directory: ${WORKFLOW_DIR}"
```

## Configuration Loading Best Practices

1. **Always use relative paths from script location** - Improves portability
2. **Load paths.yaml at script startup** - Centralized configuration
3. **Validate paths exist** - Check before operations
4. **Support environment overrides** - Allow ENV variables to override YAML
5. **Cache loaded configuration** - Avoid repeated file reads

## Environment-Specific Configuration

For environment-specific settings, use the `environment.current` field:
- `development`: Local development machine
- `staging`: Testing/staging server (if available)
- `production`: Live production server

Scripts can check this value to adjust behavior accordingly.

## Security Considerations

- **Never commit secrets** to paths.yaml or any config file
- **Use environment variables** for sensitive data (API keys, tokens)
- **Restrict permissions** on production config files
- **Document required secrets** without exposing values

## Directory Structure

```
shell_scripts/workflow/config/
├── README.md        # This file
└── paths.yaml       # Centralized path configuration
```

## Related Documentation

- Workflow README: `shell_scripts/workflow/README.md`
- Main README: `/README.md`
- Deployment guides: `/docs/deployment-architecture/`
- Root config directory: `/config/README.md`
