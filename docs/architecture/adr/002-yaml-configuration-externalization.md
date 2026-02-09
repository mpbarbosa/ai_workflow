# ADR-002: Externalize Configuration to YAML

**Status**: Accepted  
**Date**: 2025-12-15  
**Deciders**: Project maintainers  
**Related**: ADR-001

## Context

After modularization (ADR-001), configuration was still embedded in shell scripts:
- Hardcoded paths in multiple files
- AI prompt templates in shell variables
- Repetitive configuration across modules
- Difficult to modify without code changes
- No centralized configuration management

## Decision

Externalize all configuration to YAML files:

```
src/workflow/config/
├── paths.yaml                      # Path configuration (85 lines)
├── project_kinds.yaml              # Project type definitions (730 lines)
├── ai_prompts_project_kinds.yaml   # AI prompt templates (468 lines)
├── step_relevance.yaml             # Step relevance matrix (559 lines)
├── tech_stack_definitions.yaml     # Tech stack metadata (568 lines)
└── workflow_config_schema.yaml     # Schema validation (306 lines)
```

**Total**: 2,716 lines of externalized configuration

### Configuration Loading

Implemented `config.sh` module to:
- Load YAML files using Python/Node.js
- Support variable interpolation (`${var}`)
- Validate configuration schema
- Cache parsed configuration

## Consequences

### Positive

✅ **Separation of Configuration and Code**
- Configuration changes don't require code changes
- Non-developers can modify configuration
- Version control for configuration separate from logic

✅ **Centralized Management**
- All paths in one file (`paths.yaml`)
- All AI prompts in one file
- Easy to find and update

✅ **Flexibility**
- Users can customize without forking
- Project-specific configuration via `.workflow-config.yaml`
- Environment-specific overrides possible

✅ **Maintainability**
- 2,716 lines of config out of code
- Reduces code complexity
- Clear configuration ownership

### Negative

⚠️ **External Dependency**
- Requires YAML parser (Python/Node.js)
- Additional runtime dependency
- Parsing overhead (~50ms)

⚠️ **Configuration Complexity**
- 6 YAML files to understand
- Variable interpolation syntax to learn
- Schema validation needed

### Neutral

ℹ️ **Documentation Required**
- Schema documentation created (CONFIGURATION_SCHEMA.md)
- Examples provided for each config type
- Migration guide for v1.x users

## Implementation

### Phase 1: Path Externalization
- Create `paths.yaml`
- Implement variable interpolation
- Migrate hardcoded paths

### Phase 2: AI Prompts
- Extract prompt templates to YAML
- Support project kind-specific prompts
- Language-aware enhancements

### Phase 3: Project Metadata
- Create project kind definitions
- Define step relevance matrix
- Tech stack definitions

## Alternatives Considered

### Alternative 1: Environment Variables
- **Pros**: No parsing needed, standard approach
- **Cons**: Limited structure, no nesting, hard to manage 100+ config values
- **Rejected**: Too many configuration values

### Alternative 2: JSON Configuration
- **Pros**: Standard, well-supported
- **Cons**: Less human-readable, no comments
- **Rejected**: YAML more user-friendly

### Alternative 3: Shell Source Files
- **Pros**: No parser needed, native to shell
- **Cons**: Security risk (code execution), less structured
- **Rejected**: Security and maintainability concerns

## Related Decisions

- **ADR-001**: Modular architecture (enables configuration separation)

## References

- [`CONFIGURATION_SCHEMA.md`](../../reference/configuration.md)
- [YAML Specification](https://yaml.org/spec/)

---

**Outcome**: Successfully implemented in v2.1.0. 2,716 lines of configuration externalized with comprehensive schema documentation.
