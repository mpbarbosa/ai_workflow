# YAML Parsing in Shell - Quick Reference

**Full Guide**: `docs/YAML_PARSING_IN_SHELL_SCRIPTS.md`

---

## Quick Start

### Using yq (Recommended)

```bash
# Install
brew install yq  # macOS
pip install yq   # Python version

# Extract simple value
value=$(yq eval '.key.subkey' file.yaml)      # mikefarah v4
value=$(yq -r '.key.subkey' file.yaml)        # kislyuk

# Extract array
items=$(yq eval '.array[]' file.yaml)         # mikefarah v4
items=$(yq -r '.array[]' file.yaml)           # kislyuk

# Filter array
item=$(yq eval '.array[] | select(.enabled == true) | .name' file.yaml)
```

### Using awk/sed (No Dependencies)

```bash
# Simple value
get_value() {
    grep "^$1:" "$2" | sed 's/^[^:]*:[[:space:]]*"\?\([^"]*\)"\?$/\1/'
}
value=$(get_value "key" "file.yaml")

# Nested value
get_nested() {
    local section="${1%%.*}"
    local field="${1#*.}"
    awk -v s="$section" -v f="$field" '
        $0 ~ "^" s ":" { in_s=1; next }
        in_s && $1 ~ "^" f ":" {
            sub(/^[^:]*:[[:space:]]*/, "")
            gsub(/"/, "")
            print
            exit
        }
    ' "$2"
}
value=$(get_nested "tech_stack.language" "file.yaml")
```

---

## Common Patterns

### Extract from this YAML:
```yaml
project:
  name: "My Project"
  version: "1.0.0"

tech_stack:
  primary_language: "bash"
  dependencies:
    - shellcheck
    - bats

quality:
  linters:
    - name: "shellcheck"
      enabled: true
    - name: "shfmt"
      enabled: false
```

### Commands:

```bash
# Project name
yq eval '.project.name' config.yaml                    # mikefarah
yq -r '.project.name' config.yaml                      # kislyuk

# Language
yq eval '.tech_stack.primary_language' config.yaml     # mikefarah
yq -r '.tech_stack.primary_language' config.yaml       # kislyuk

# All dependencies
yq eval '.tech_stack.dependencies[]' config.yaml       # mikefarah
yq -r '.tech_stack.dependencies[]' config.yaml         # kislyuk

# Enabled linters only
yq eval '.quality.linters[] | select(.enabled == true) | .name' config.yaml
```

---

## Version Detection

```bash
detect_yq_version() {
    if ! command -v yq &> /dev/null; then
        echo "none"
        return
    fi
    
    local ver=$(yq --version 2>&1)
    if [[ "$ver" == *"jq wrapper"* ]]; then
        echo "kislyuk"
    elif [[ "$ver" == *"version 4"* ]]; then
        echo "v4"
    else
        echo "v3"
    fi
}

YQ_VERSION=$(detect_yq_version)
```

---

## Universal Wrapper

```bash
get_yaml_value() {
    local file="$1"
    local path="$2"
    local default="${3:-}"
    
    local value=""
    local yq_type=$(detect_yq_version)
    
    case "$yq_type" in
        v4)
            value=$(yq eval ".${path}" "$file" 2>/dev/null || echo "")
            ;;
        kislyuk)
            value=$(yq -r ".${path}" "$file" 2>/dev/null || echo "")
            ;;
        *)
            # awk fallback
            local section="${path%%.*}"
            local field="${path#*.}"
            value=$(awk -v s="$section" -v f="$field" '
                $0 ~ "^" s ":" { in_s=1; next }
                in_s && $1 ~ "^" f ":" {
                    sub(/^[^:]*:[[:space:]]*/, "")
                    gsub(/"/, "")
                    print
                    exit
                }
            ' "$file")
            ;;
    esac
    
    [[ -z "$value" || "$value" == "null" ]] && value="$default"
    echo "$value"
}

# Usage
lang=$(get_yaml_value "config.yaml" "tech_stack.primary_language" "unknown")
```

---

## Best Practices

✅ **Always check file existence**
```bash
[[ ! -f "$yaml_file" ]] && return 1
```

✅ **Provide defaults**
```bash
value="${value:-default}"
```

✅ **Handle null values**
```bash
[[ "$value" == "null" ]] && value="default"
```

✅ **Quote expansions**
```bash
config_value=$(yq eval ".path" "$file")
```

✅ **Cache parsed values**
```bash
declare -g -A CONFIG_CACHE
```

---

## Real Examples

### From project_kind_config.sh
```bash
get_project_kind_config() {
    local kind="$1"
    local config_path="$2"
    
    if [[ "$YQ_VERSION" == "v4" ]]; then
        yq eval ".project_kinds.${kind}${config_path}" "$CONFIG_FILE"
    elif [[ "$YQ_VERSION" == "kislyuk" ]]; then
        yq -r ".project_kinds.${kind}${config_path}" "$CONFIG_FILE"
    fi
}

name=$(get_project_kind_config "shell_script_automation" ".name")
```

### From ai_helpers.sh
```bash
extract_multiline_template() {
    awk -v section="$1" -v field="$2" '
        $0 ~ "^" section ":" { in_section=1; next }
        in_section && $0 ~ "^[[:space:]]+" field ":[[:space:]]*\\|" { 
            in_field=1; next
        }
        in_section && in_field && /^[[:space:]]{4}/ {
            sub(/^[[:space:]]{4}/, "")
            print
        }
        in_section && in_field && /^[[:space:]]+[a-z_]+:/ { exit }
    ' "$3"
}
```

---

## See Also

- **Full Guide**: `docs/YAML_PARSING_IN_SHELL_SCRIPTS.md` (17KB)
- **Live Examples**:
  - `src/workflow/lib/project_kind_config.sh`
  - `src/workflow/lib/ai_helpers.sh`
  - `src/workflow/lib/tech_stack.sh`
