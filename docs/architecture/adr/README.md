# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the AI Workflow Automation project.

## What is an ADR?

An Architecture Decision Record (ADR) is a document that captures an important architectural decision made along with its context and consequences.

## ADR Format

Each ADR follows this structure:

- **Title**: Short, descriptive title
- **Status**: Proposed, Accepted, Deprecated, Superseded
- **Date**: When the decision was made
- **Context**: What is the issue that we're seeing that is motivating this decision?
- **Decision**: What is the change that we're proposing and/or doing?
- **Consequences**: What becomes easier or more difficult to do because of this change?

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](001-modular-architecture.md) | Adopt Modular Architecture | Accepted | 2025-12-14 |
| [ADR-002](002-yaml-configuration-externalization.md) | Externalize Configuration to YAML | Accepted | 2025-12-15 |
| [ADR-003](003-orchestrator-module-split.md) | Split Orchestrator into Sub-modules | Accepted | 2025-12-20 |
| [ADR-004](004-ai-response-caching.md) | Implement AI Response Caching | Accepted | 2025-12-18 |
| [ADR-005](005-smart-execution-optimization.md) | Smart Execution with Change Detection | Accepted | 2025-12-18 |
| [ADR-006](006-parallel-execution.md) | Parallel Step Execution | Accepted | 2025-12-18 |

## Creating a New ADR

1. Copy the template: `cp template.md XXX-title.md`
2. Fill in the sections
3. Update this index
4. Submit for review

## References

- [ADR GitHub Organization](https://adr.github.io/)
- [Architecture Decision Records](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR Tools](https://github.com/npryce/adr-tools)

---

**Last Updated**: 2025-12-23  
**Total ADRs**: 6
