# API Reference

This directory contains comprehensive API documentation for all AI Workflow Automation modules.

## Quick Navigation

- **[Core Modules](core/)** - Essential workflow infrastructure (12 modules)
- **[Supporting Modules](supporting/)** - Specialized functionality (50 modules)
- **[Step Modules](../reference/API_STEP_MODULES.md)** - Workflow execution steps (18 modules)
- **[Orchestrators](../reference/API_ORCHESTRATORS.md)** - Workflow coordination (4 modules)

## Module Categories

### Core Modules (12)

High-level infrastructure that forms the backbone of the workflow system:

| Module | Size | Purpose |
|--------|------|---------|
| [ai_helpers.sh](core/ai_helpers.md) | 102K | AI integration with 15 personas |
| [tech_stack.sh](core/tech_stack.md) | 47K | Technology stack detection |
| [workflow_optimization.sh](core/workflow_optimization.md) | 31K | Smart execution & parallel processing |
| [project_kind_config.sh](core/project_kind_config.md) | 26K | Project kind configuration |
| [change_detection.sh](core/change_detection.md) | 17K | Git diff analysis |
| [metrics.sh](core/metrics.md) | 16K | Performance tracking |
| [performance.sh](core/performance.md) | 16K | Timing utilities |
| [step_adaptation.sh](core/step_adaptation.md) | 16K | Dynamic step behavior |
| [config_wizard.sh](core/config_wizard.md) | 16K | Interactive configuration |
| [dependency_graph.sh](core/dependency_graph.md) | 15K | Execution dependencies |
| [health_check.sh](core/health_check.md) | 15K | System validation |
| [file_operations.sh](core/file_operations.md) | 15K | Safe file operations |

### Supporting Modules (50)

Specialized functionality organized by category:

#### AI & Prompt Management (5 modules)
- [ai_cache.sh](supporting/ai_cache.md) - AI response caching
- [ai_prompt_builder.sh](supporting/ai_prompt_builder.md) - Prompt construction
- [ai_personas.sh](supporting/ai_personas.md) - Persona management
- ai_error_handler.sh - AI error handling
- ai_rate_limiter.sh - API rate limiting

#### File & Edit Operations (8 modules)
- [edit_operations.sh](supporting/edit_operations.md) - File editing
- [validation.sh](supporting/validation.md) - Input validation
- file_diff.sh - Diff generation
- file_merger.sh - Merge operations
- backup_manager.sh - Backup handling
- path_resolver.sh - Path resolution
- template_engine.sh - Template processing
- yaml_parser.sh - YAML handling

#### Process & Session Management (6 modules)
- [session_manager.sh](supporting/session_manager.md) - Process management
- step_execution.sh - Step lifecycle
- checkpoint_manager.sh - Resume functionality
- signal_handler.sh - Signal handling
- cleanup_handler.sh - Resource cleanup
- error_handler.sh - Error management

#### Project Analysis & Detection (7 modules)
- [project_kind_detection.sh](supporting/project_kind_detection.md) - Project type detection
- doc_template_validator.sh - Template validation
- third_party_exclusion.sh - File filtering
- code_analyzer.sh - Code analysis
- dependency_scanner.sh - Dependency detection
- test_framework_detector.sh - Test framework identification
- build_system_detector.sh - Build system detection

#### Metrics & Reporting (5 modules)
- metrics_validation.sh - Metrics validation
- report_generator.sh - Report creation
- summary_builder.sh - Summary generation
- chart_generator.sh - Chart creation
- export_formatter.sh - Export formatting

#### CLI & Configuration (6 modules)
- [argument_parser.sh](supporting/argument_parser.md) - CLI parsing
- config_loader.sh - Configuration loading
- env_validator.sh - Environment validation
- option_validator.sh - Option validation
- flag_parser.sh - Flag parsing
- help_generator.sh - Help text generation

#### Utilities & Helpers (13 modules)
- [utils.sh](supporting/utils.md) - Common utilities
- logging.sh - Logging system
- color_output.sh - Terminal colors
- spinner.sh - Progress indicators
- progress_bar.sh - Progress bars
- notification.sh - Desktop notifications
- git_helpers.sh - Git operations
- jq_wrapper.sh - JSON processing
- date_helpers.sh - Date utilities
- string_helpers.sh - String operations
- array_helpers.sh - Array operations
- math_helpers.sh - Math operations
- debug_helpers.sh - Debugging tools

## API Documentation Standards

All module documentation follows this structure:

1. **Overview** - Module purpose and key features
2. **Dependencies** - Required modules and external tools
3. **Configuration** - Environment variables and settings
4. **Functions** - Complete API reference with:
   - Function signature
   - Description
   - Parameters (with types)
   - Return values
   - Exit codes
   - Examples
5. **Usage Patterns** - Common usage scenarios
6. **Error Handling** - Error conditions and recovery
7. **Testing** - How to test the module
8. **Related Modules** - Cross-references

## Quick Reference Guide

### Common Patterns

#### Sourcing Modules
```bash
# Source from workflow directory
source "$(dirname "$0")/lib/module_name.sh"

# Source with error handling
if [[ -f "${WORKFLOW_LIB}/module_name.sh" ]]; then
    source "${WORKFLOW_LIB}/module_name.sh"
else
    echo "ERROR: Required module not found" >&2
    exit 1
fi
```

#### Error Handling
```bash
# All modules use consistent error codes
# 0   = Success
# 1   = General error
# 2   = Missing dependency
# 3   = Invalid input
# 4   = Operation failed
# 5   = Configuration error

# Example
if ! validate_input "$param"; then
    return 3  # Invalid input
fi
```

#### Logging
```bash
# Standard logging functions (from utils.sh)
print_info "Information message"
print_warning "Warning message"
print_error "Error message"
print_success "Success message"
```

## Module Development Guide

See [Developer Guide: Module Development](../developer-guide/MODULE_DEVELOPMENT.md) for:
- How to create a new module
- Module structure templates
- Testing requirements
- Documentation requirements
- Code review checklist

## Related Documentation

- [Architecture Overview](../architecture/OVERVIEW.md) - System architecture
- [Module Architecture](../architecture/MODULE_ARCHITECTURE.md) - Module design patterns
- [Step Modules API](../reference/API_STEP_MODULES.md) - Workflow steps
- [Developer Guide](../developer-guide/ONBOARDING.md) - Contributing to modules
- [Project Reference](../PROJECT_REFERENCE.md) - Single source of truth

## Contributing

To contribute module documentation:

1. Follow the [Documentation Style Guide](../reference/documentation-style-guide.md)
2. Include working code examples
3. Test all examples before submitting
4. Add cross-references to related modules
5. Update this index when adding new modules

## Version Information

- **Documentation Version**: v3.1.0
- **Last Updated**: 2026-02-04
- **Module Count**: 62 library + 18 steps + 4 orchestrators = 84 total modules
- **Coverage**: Complete API documentation for all modules
