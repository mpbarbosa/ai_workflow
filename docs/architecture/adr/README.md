# Architecture Decision Records (ADR)

**Version**: v3.2.7  
**Last Updated**: 2026-02-08

## What are ADRs?

Architecture Decision Records (ADRs) document significant architectural decisions made during the development of the AI Workflow Automation system. Each ADR captures the context, decision, and consequences of architectural choices.

## ADR Format

Each ADR follows this structure:
- **Title**: Short descriptive name
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Date**: Decision date
- **Context**: Background and problem statement
- **Decision**: The change we're proposing or have made
- **Consequences**: Expected outcomes (positive and negative)
- **Alternatives Considered**: Other options evaluated

## Index of ADRs

### Core Architecture

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](./001-modular-architecture.md) | Adopt Modular Architecture | Accepted | 2025-12-18 |
| [ADR-002](./002-bash-as-primary-language.md) | Use Bash as Primary Language | Accepted | 2025-12-18 |
| [ADR-003](./003-functional-core-imperative-shell.md) | Functional Core, Imperative Shell Pattern | Accepted | 2025-12-18 |
| [ADR-004](./004-yaml-configuration.md) | YAML for Configuration and Prompts | Accepted | 2025-12-19 |

### AI Integration

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-005](./005-github-copilot-cli.md) | GitHub Copilot CLI as AI Provider | Accepted | 2025-12-18 |
| [ADR-006](./006-specialized-personas.md) | 15 Specialized AI Personas | Accepted | 2025-12-19 |
| [ADR-007](./007-ai-response-caching.md) | AI Response Caching Strategy | Accepted | 2025-12-20 |

### Performance Optimization

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-008](./008-smart-execution.md) | Change-Based Smart Execution | Accepted | 2025-12-22 |
| [ADR-009](./009-parallel-execution.md) | Fork-Join Parallel Execution | Accepted | 2025-12-22 |
| [ADR-010](./010-ml-optimization.md) | ML-Based Workflow Optimization | Accepted | 2025-12-25 |
| [ADR-011](./011-multi-stage-pipeline.md) | Multi-Stage Progressive Pipeline | Accepted | 2025-12-26 |

### Developer Experience

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-012](./012-checkpoint-resume.md) | Automatic Checkpoint Resume | Accepted | 2025-12-21 |
| [ADR-013](./013-auto-commit.md) | Intelligent Auto-Commit Workflow | Accepted | 2025-12-24 |
| [ADR-014](./014-workflow-templates.md) | Workflow Templates for Common Use Cases | Accepted | 2025-12-24 |
| [ADR-015](./015-pre-commit-hooks.md) | Pre-Commit Validation Hooks | Accepted | 2026-01-15 |

### Data Management

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-016](./016-file-based-state.md) | File-Based State Management | Accepted | 2025-12-18 |
| [ADR-017](./017-metrics-collection.md) | Comprehensive Metrics Collection | Accepted | 2025-12-22 |

## How to Create a New ADR

1. Copy the [ADR template](./000-template.md)
2. Use the next available ADR number
3. Fill in all sections thoroughly
4. Submit for review as part of your PR
5. Update this index

## Related Documentation

- [System Architecture](../SYSTEM_ARCHITECTURE.md) - High-level architecture overview
- [Architecture Deep Dive](../ARCHITECTURE_DEEP_DIVE.md) - Detailed component analysis
- [Module Architecture](../MODULE_ARCHITECTURE.md) - Module design patterns
- [Project Reference](../../PROJECT_REFERENCE.md) - Project statistics and features

## Decision Process

Architectural decisions follow this process:
1. **Identify Problem**: Document the architectural challenge
2. **Research Options**: Investigate alternative approaches
3. **Evaluate Trade-offs**: Analyze pros/cons of each option
4. **Make Decision**: Select approach based on project principles
5. **Document**: Create ADR with full context
6. **Review**: Get team feedback
7. **Implement**: Apply the decision
8. **Monitor**: Track outcomes and adjust if needed

## Review Schedule

ADRs are reviewed quarterly to ensure they remain relevant and aligned with project goals. Outdated ADRs are marked as "Deprecated" or "Superseded" with references to newer decisions.
