# AI Personas Reference

The workflow system uses 14 specialized AI personas for different validation and enhancement tasks.

## Overview

AI personas are implemented through:
- 9 base prompt templates in `.workflow_core/config/ai_helpers.yaml`
- 4 project-kind specific personas in `.workflow_core/config/ai_prompts_project_kinds.yaml`
- Language-aware enhancements based on `PRIMARY_LANGUAGE` setting

## Core Personas

### documentation_specialist
- **Purpose**: Validate and enhance documentation
- **Used in**: Steps 2, 3
- **Expertise**: Documentation standards, clarity, completeness
- **Project-aware**: Yes (references project_kinds.yaml)

### code_reviewer
- **Purpose**: Review code quality and standards
- **Used in**: Steps 5, 6
- **Expertise**: Code quality, best practices, security
- **Language-aware**: Yes

### test_engineer
- **Purpose**: Validate testing coverage and quality
- **Used in**: Steps 7, 8
- **Expertise**: Testing frameworks, coverage analysis
- **Project-aware**: Yes

### ux_designer
- **Purpose**: Analyze user experience and accessibility
- **Used in**: Step 14
- **Expertise**: WCAG 2.1, usability, accessibility
- **New in**: v2.4.0

## Supporting Personas

### change_analyzer
- **Purpose**: Analyze code and documentation changes
- **Used in**: Steps 0, 1
- **Expertise**: Impact analysis, change detection

### security_auditor
- **Purpose**: Security vulnerability assessment
- **Used in**: Step 9
- **Expertise**: Security best practices, vulnerability detection

### architecture_reviewer
- **Purpose**: Architecture and design review
- **Used in**: Step 10
- **Expertise**: Design patterns, architecture principles

### performance_analyzer
- **Purpose**: Performance optimization analysis
- **Used in**: Step 11
- **Expertise**: Performance bottlenecks, optimization

### integration_specialist
- **Purpose**: Integration and compatibility review
- **Used in**: Step 12
- **Expertise**: API design, integration patterns

### deployment_engineer
- **Purpose**: Deployment and operations review
- **Used in**: Step 13
- **Expertise**: DevOps, deployment strategies

## Language-Aware Enhancements

When `PRIMARY_LANGUAGE` is set in `.workflow-config.yaml`, personas automatically adapt with:
- Language-specific documentation standards
- Testing framework conventions
- Code quality rules
- Best practices

### Supported Languages

- JavaScript/TypeScript
- Python
- Shell/Bash
- Java
- Go
- Ruby
- PHP
- C/C++

## Project-Kind Awareness

Personas reference `.workflow_core/config/project_kinds.yaml` for:
- Quality standards by project type
- Testing framework requirements
- Documentation requirements

### Supported Project Kinds

- shell_script_automation
- nodejs_api
- nodejs_cli
- nodejs_library
- static_website
- client_spa
- react_spa
- vue_spa
- python_api
- python_cli
- python_library
- documentation

## Customization

Personas can be customized through:
- `.workflow-config.yaml` - Project-specific settings
- `ai_helpers.yaml` - Prompt template modifications
- `ai_prompts_project_kinds.yaml` - Project-kind specific prompts

## See Also

- [Configuration Schema](configuration.md)
- [API Reference](../developer-guide/api-reference.md)
- [Project Kind Framework](../design/project-kind-framework.md)
