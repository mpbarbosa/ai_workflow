# YAML Parsing in Shell Scripts - Comprehensive Guide

**Date**: 2025-12-19  
**Purpose**: Guide for extracting structured data from YAML files in Bash scripts  
**Context**: AI Workflow Automation Project

> **Note**: This guide contains `awk` and `sed` regex patterns for text processing.  
> Patterns like `/^[^:]*:[[:space:]]*/, ""` and `/"/, ""` are regex substitution expressions,  
> not file paths or broken references.

---

## Overview

This guide demonstrates multiple approaches to parsing YAML files in shell scripts, from simple grep/sed/awk patterns to using dedicated YAML parsers like `yq`.

---

## Methods for YAML Parsing

### Method 1: Using `yq` (Recommended)

**yq** is a lightweight command-line YAML processor. There are two main versions:

1. **mikefarah/yq** (Go-based, v3/v4) - Most feature-rich
2. **kislyuk/yq** (Python-based, jq wrapper) - Most common

#### Installation

```bash
# mikefarah yq (recommended)
## macOS
brew install yq

## Linux
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# kislyuk yq (Python)
pip install yq
```

#### Version Detection

```bash
# Detect which yq version is installed
detect_yq_version() {
    if ! command -v yq &> /dev/null; then
        echo "none"
        return
    fi
    
    local version_output
    version_output=$(yq --version 2>&1 || echo "")
    
    # Check for kislyuk/yq (jq wrapper)
    if [[ "${version_output}" == *"jq wrapper"* ]] || [[ "${version_output}" == *"kislyuk"* ]]; then
        echo "kislyuk"
    # Check for mikefarah yq v4
    elif [[ "${version_output}" == *"version 4"* ]] || [[ "${version_output}" == *"mikefarah"* ]]; then
        echo "v4"
    # Check for mikefarah yq v3
    elif [[ "${version_output}" == *"version 3"* ]]; then
        echo "v3"
    else
        echo "unknown"
    fi
}

YQ_VERSION=$(detect_yq_version)
```

#### Basic Usage Examples

**YAML File Example** (`config.yaml`):
```yaml
project:
  name: "My Project"
  version: "1.0.0"
  
tech_stack:
  primary_language: "bash"
  test_framework: "bats"
  dependencies:
    - shellcheck
    - bats
    - git

quality:
  linters:
    - name: "shellcheck"
      enabled: true
      command: "shellcheck"
    - name: "shfmt"
      enabled: false
      command: "shfmt"
```

**Extract Simple Values**:
```bash
# mikefarah yq v4
project_name=$(yq eval '.project.name' config.yaml)
primary_lang=$(yq eval '.tech_stack.primary_language' config.yaml)

# kislyuk yq
project_name=$(yq -r '.project.name' config.yaml)
primary_lang=$(yq -r '.tech_stack.primary_language' config.yaml)

# mikefarah yq v3 (legacy)
project_name=$(yq r config.yaml 'project.name')
primary_lang=$(yq r config.yaml 'tech_stack.primary_language')
```

**Extract Array Values**:
```bash
# mikefarah yq v4
dependencies=$(yq eval '.tech_stack.dependencies[]' config.yaml)

# kislyuk yq
dependencies=$(yq -r '.tech_stack.dependencies[]' config.yaml)

# mikefarah yq v3
dependencies=$(yq r config.yaml 'tech_stack.dependencies[*]')
```

**Extract Nested Object Values**:
```bash
# mikefarah yq v4 - Get first enabled linter name
linter=$(yq eval '.quality.linters[] | select(.enabled == true) | .name' config.yaml | head -1)

# kislyuk yq
linter=$(yq -r '.quality.linters[] | select(.enabled == true) | .name' config.yaml | head -1)

# mikefarah yq v3 - More complex with iteration
linter_count=$(yq r config.yaml 'quality.linters' -l)
for ((i=0; i<linter_count; i++)); do
    enabled=$(yq r config.yaml "quality.linters[$i].enabled")
    if [[ "$enabled" == "true" ]]; then
        name=$(yq r config.yaml "quality.linters[$i].name")
        echo "$name"
        break
    fi
done
```

---

### Method 2: Using sed/awk/grep (No Dependencies)

For simple YAML files when `yq` is not available:

#### Extract Simple Key-Value Pairs

```bash
#!/bin/bash

# Extract a simple value
get_yaml_value() {
    local yaml_file="$1"
    local key="$2"
    
    grep "^${key}:" "$yaml_file" | \
        sed 's/^[^:]*:[[:space:]]*"\?\([^"]*\)"\?[[:space:]]*$/\1/'
}

# Usage
project_name=$(get_yaml_value "config.yaml" "name")
echo "Project: $project_name"
```

#### Extract Nested Values

```bash
#!/bin/bash

# Extract nested value with dot notation (e.g., "tech_stack.primary_language")
get_nested_yaml_value() {
    local yaml_file="$1"
    local key_path="$2"
    
    # Split key path (tech_stack.primary_language -> section: tech_stack, key: primary_language)
    local section="${key_path%%.*}"
    local field="${key_path#*.}"
    
    # Find value in section
    awk -v section="$section" -v field="$field" '
        $0 ~ "^" section ":" { in_section=1; next }
        in_section && $1 ~ "^" field ":" {
            # Regex: Remove key prefix and colons
            sub(/^[^:]*:[[:space:]]*/, "")
            # Regex: Remove surrounding quotes
            gsub(/"/, "")
            print
            exit
        }
        in_section && /^[a-z_]+:/ { exit }
    ' "$yaml_file"
}

# Usage
primary_lang=$(get_nested_yaml_value "config.yaml" "tech_stack.primary_language")
echo "Language: $primary_lang"
```

#### Extract Array Values

```bash
#!/bin/bash

# Extract array values
get_yaml_array() {
    local yaml_file="$1"
    local array_path="$2"
    
    # Split path for nested arrays
    local section="${array_path%%.*}"
    local array_name="${array_path#*.}"
    
    awk -v section="$section" -v array="$array_name" '
        $0 ~ "^" section ":" { in_section=1; next }
        in_section && $1 ~ "^" array ":" { in_array=1; next }
        in_section && in_array && /^[[:space:]]+-[[:space:]]/ {
            sub(/^[[:space:]]+-[[:space:]]*/, "")
            print
            next
        }
        in_section && in_array && /^[[:space:]]*[a-z_]+:/ { exit }
        in_section && /^[a-z_]+:/ && !in_array { exit }
    ' "$yaml_file"
}

# Usage
dependencies=$(get_yaml_array "config.yaml" "tech_stack.dependencies")
echo "Dependencies:"
echo "$dependencies"
```

#### Extract Multi-line Values

```bash
#!/bin/bash

# Extract multi-line value (with | or >)
get_multiline_yaml_value() {
    local yaml_file="$1"
    local key="$2"
    
    awk -v key="$key" '
        $0 ~ "^" key ":[[:space:]]*[|>]" { multiline=1; next }
        multiline && /^[[:space:]]{2,}/ {
            sub(/^[[:space:]]+/, "")
            print
            next
        }
        multiline && /^[a-z_]+:/ { exit }
    ' "$yaml_file"
}

# Usage
description=$(get_multiline_yaml_value "config.yaml" "description")
echo "Description: $description"
```

---

### Method 3: Version-Agnostic Wrapper Function

Create a universal function that works with any yq version or falls back to awk:

```bash
#!/bin/bash

# Universal YAML value extractor
get_yaml_value_universal() {
    local yaml_file="$1"
    local yaml_path="$2"  # e.g., "tech_stack.primary_language"
    local default_value="${3:-}"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo "$default_value"
        return 1
    fi
    
    local value=""
    
    # Try yq if available
    if command -v yq &> /dev/null; then
        local yq_version
        yq_version=$(yq --version 2>&1)
        
        # kislyuk yq (Python)
        if [[ "$yq_version" == *"jq wrapper"* ]]; then
            value=$(yq -r ".${yaml_path} // empty" "$yaml_file" 2>/dev/null || echo "")
        # mikefarah yq v4
        elif [[ "$yq_version" == *"version 4"* ]]; then
            value=$(yq eval ".${yaml_path}" "$yaml_file" 2>/dev/null | grep -v "^null$" || echo "")
        # mikefarah yq v3
        elif [[ "$yq_version" == *"version 3"* ]]; then
            local clean_path="${yaml_path//./|}"
            value=$(yq r "$yaml_file" "$clean_path" 2>/dev/null || echo "")
        fi
    fi
    
    # Fallback to awk if yq failed or not available
    if [[ -z "$value" ]]; then
        local section="${yaml_path%%.*}"
        local field="${yaml_path#*.}"
        
        value=$(awk -v section="$section" -v field="$field" '
            $0 ~ "^" section ":" { in_section=1; next }
            in_section && $1 ~ "^" field ":" {
                # Regex: Remove key prefix and colons
                sub(/^[^:]*:[[:space:]]*/, "")
                # Regex: Remove surrounding quotes
                gsub(/"/, "")
                print
                exit
            }
            in_section && /^[a-z_]+:/ { exit }
        ' "$yaml_file")
    fi
    
    # Return value or default
    if [[ -z "$value" ]] || [[ "$value" == "null" ]]; then
        echo "$default_value"
    else
        echo "$value"
    fi
}

# Usage
primary_lang=$(get_yaml_value_universal "config.yaml" "tech_stack.primary_language" "unknown")
echo "Language: $primary_lang"
```

---

## Real-World Examples from AI Workflow

### Example 1: Loading Project Configuration

```bash
#!/bin/bash
# From: src/workflow/lib/project_kind_config.sh

load_project_kind_config() {
    local kind="$1"
    local yaml_file="config/project_kinds.yaml"
    
    # Check yq version
    local yq_version=$(detect_yq_version)
    
    if [[ "$yq_version" == "none" ]]; then
        echo "Warning: yq not found" >&2
        return 1
    fi
    
    # Load configuration based on yq version
    if [[ "$yq_version" == "v4" ]]; then
        # Get all values for the project kind
        local name=$(yq eval ".project_kinds.${kind}.name" "$yaml_file")
        local description=$(yq eval ".project_kinds.${kind}.description" "$yaml_file")
        local test_framework=$(yq eval ".project_kinds.${kind}.testing.test_framework" "$yaml_file")
        
        echo "Project Kind: $name"
        echo "Description: $description"
        echo "Test Framework: $test_framework"
        
    elif [[ "$yq_version" == "kislyuk" ]]; then
        local name=$(yq -r ".project_kinds.${kind}.name" "$yaml_file")
        local description=$(yq -r ".project_kinds.${kind}.description" "$yaml_file")
        local test_framework=$(yq -r ".project_kinds.${kind}.testing.test_framework" "$yaml_file")
        
        echo "Project Kind: $name"
        echo "Description: $description"
        echo "Test Framework: $test_framework"
    fi
    
    return 0
}

# Usage
load_project_kind_config "shell_script_automation"
```

### Example 2: Extracting Array of Linters

```bash
#!/bin/bash
# From: src/workflow/lib/project_kind_config.sh

get_enabled_linters() {
    local kind="$1"
    local yaml_file="config/project_kinds.yaml"
    
    if [[ "$YQ_VERSION" == "v4" ]]; then
        # Extract names of enabled linters
        yq eval ".project_kinds.${kind}.quality.linters[] | select(.enabled == true) | .name" \
            "$yaml_file" 2>/dev/null | tr '\n' ' '
            
    elif [[ "$YQ_VERSION" == "kislyuk" ]]; then
        yq -r ".project_kinds.${kind}.quality.linters[]? | select(.enabled == true) | .name" \
            "$yaml_file" 2>/dev/null | tr '\n' ' '
            
    else
        # yq v3 - iterate through array
        local linter_count
        linter_count=$(yq r "$yaml_file" "project_kinds.${kind}.quality.linters" -l)
        
        for ((i=0; i<linter_count; i++)); do
            local enabled=$(yq r "$yaml_file" "project_kinds.${kind}.quality.linters[$i].enabled")
            if [[ "$enabled" == "true" ]]; then
                local name=$(yq r "$yaml_file" "project_kinds.${kind}.quality.linters[$i].name")
                echo -n "$name "
            fi
        done
    fi
}

# Usage
enabled=$(get_enabled_linters "shell_script_automation")
echo "Enabled linters: $enabled"
```

### Example 3: Multi-line Template Extraction

```bash
#!/bin/bash
# From: src/workflow/lib/ai_helpers.sh

extract_yaml_template() {
    local yaml_file="$1"
    local section_name="$2"
    local template_field="$3"  # e.g., "task_template"
    
    # Extract multi-line template using awk
    awk -v section="$section_name" -v field="$template_field" '
        # Find the section
        $0 ~ "^" section ":" { in_section=1; next }
        
        # Find the field within section
        in_section && $0 ~ "^[[:space:]]+" field ":[[:space:]]*\\|" { 
            in_field=1
            next
        }
        
        # Collect lines that are part of the multi-line value
        in_section && in_field && /^[[:space:]]{4}/ {
            sub(/^[[:space:]]{4}/, "")
            print
            next
        }
        
        # Stop when we hit the next field
        in_section && in_field && /^[[:space:]]+[a-z_]+:/ {
            exit
        }
        
        # Stop when we hit the next section
        in_section && /^[a-z_]+:/ {
            exit
        }
    ' "$yaml_file"
}

# Usage
task_template=$(extract_yaml_template "ai_helpers.yaml" "doc_analysis_prompt" "task_template")
echo "Template: $task_template"
```

---

## Best Practices

### 1. Always Check File Existence

```bash
if [[ ! -f "$yaml_file" ]]; then
    echo "Error: YAML file not found: $yaml_file" >&2
    return 1
fi
```

### 2. Provide Defaults for Missing Values

```bash
primary_lang=$(get_yaml_value "config.yaml" "tech_stack.primary_language")
primary_lang="${primary_lang:-javascript}"  # Default to javascript
```

### 3. Handle Null Values

```bash
value=$(yq eval '.some.path' config.yaml)
if [[ "$value" == "null" ]] || [[ -z "$value" ]]; then
    value="default"
fi
```

### 4. Quote Variable Expansions

```bash
# Always quote to prevent word splitting
config_value=$(yq eval ".project.name" "$yaml_file")
echo "Value: ${config_value}"
```

### 5. Use Version Detection for Portability

```bash
# Detect and adapt to available yq version
YQ_VERSION=$(detect_yq_version)

case "$YQ_VERSION" in
    v4)
        value=$(yq eval ".path.to.value" "$file")
        ;;
    kislyuk)
        value=$(yq -r ".path.to.value" "$file")
        ;;
    v3)
        value=$(yq r "$file" "path.to.value")
        ;;
    none)
        # Fallback to awk/sed
        value=$(grep "value:" "$file" | sed 's/.*: //')
        ;;
esac
```

### 6. Cache Parsed Values

```bash
# Use associative array to cache parsed values
declare -g -A CONFIG_CACHE

get_cached_config() {
    local key="$1"
    
    if [[ -n "${CONFIG_CACHE[$key]:-}" ]]; then
        echo "${CONFIG_CACHE[$key]}"
        return 0
    fi
    
    local value=$(yq eval ".${key}" config.yaml)
    CONFIG_CACHE["$key"]="$value"
    echo "$value"
}
```

---

## Complete Working Example

```bash
#!/usr/bin/env bash
set -euo pipefail

################################################################################
# YAML Configuration Loader
# Purpose: Load and parse YAML configuration files
################################################################################

# Detect yq version
detect_yq() {
    if ! command -v yq &> /dev/null; then
        echo "none"
        return
    fi
    
    local ver=$(yq --version 2>&1)
    if [[ "$ver" == *"jq wrapper"* ]]; then
        echo "kislyuk"
    elif [[ "$ver" == *"version 4"* ]]; then
        echo "v4"
    elif [[ "$ver" == *"version 3"* ]]; then
        echo "v3"
    else
        echo "unknown"
    fi
}

# Get YAML value with fallback
get_config() {
    local file="$1"
    local path="$2"
    local default="${3:-}"
    local yq_type=$(detect_yq)
    local value=""
    
    case "$yq_type" in
        v4)
            value=$(yq eval ".${path}" "$file" 2>/dev/null || echo "")
            ;;
        kislyuk)
            value=$(yq -r ".${path}" "$file" 2>/dev/null || echo "")
            ;;
        v3)
            local clean_path="${path//.//}"
            value=$(yq r "$file" "$clean_path" 2>/dev/null || echo "")
            ;;
        *)
            # Fallback to awk
            local section="${path%%.*}"
            local field="${path#*.}"
            value=$(awk -v s="$section" -v f="$field" '
                $0 ~ "^" s ":" { in_s=1; next }
                in_s && $1 ~ "^" f ":" {
                    # Regex: Remove key prefix and colons
                    sub(/^[^:]*:[[:space:]]*/, "")
                    # Regex: Remove surrounding quotes
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

# Example usage
main() {
    local config_file="config.yaml"
    
    # Load configuration
    local project_name=$(get_config "$config_file" "project.name" "Unknown Project")
    local primary_lang=$(get_config "$config_file" "tech_stack.primary_language" "unknown")
    local test_framework=$(get_config "$config_file" "tech_stack.test_framework" "none")
    
    # Display configuration
    echo "Project: $project_name"
    echo "Language: $primary_lang"
    echo "Test Framework: $test_framework"
}

main "$@"
```

---

## Troubleshooting

### Issue: yq not found

**Solution**: Install yq or use awk/sed fallback patterns

### Issue: Different yq versions produce different output

**Solution**: Use version detection and adapt syntax

### Issue: Multi-line values not parsing correctly

**Solution**: Check indentation (YAML is whitespace-sensitive)

### Issue: Special characters in values

**Solution**: Use `-r` flag (kislyuk) or proper quoting

---

## References

- **mikefarah/yq**: https://github.com/mikefarah/yq
- **kislyuk/yq**: https://github.com/kislyuk/yq
- **Project Examples**:
  - `src/workflow/lib/project_kind_config.sh` - Complete yq implementation
  - `src/workflow/lib/ai_helpers.sh` - Multi-line template extraction
  - `src/workflow/lib/tech_stack.sh` - Simple awk-based parsing

---

## Summary

**Recommended Approach**:
1. Use `yq` (mikefarah v4) for new projects
2. Detect version and adapt for portability
3. Provide awk/sed fallback for simple cases
4. Cache parsed values for performance
5. Always handle null/missing values gracefully

This ensures your shell scripts can reliably parse YAML across different environments.
