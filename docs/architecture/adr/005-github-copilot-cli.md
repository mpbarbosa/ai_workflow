# ADR-005: GitHub Copilot CLI as AI Provider

**Status**: Accepted  
**Date**: 2025-12-18  
**Author**: Marcelo Pereira Barbosa

## Context

The workflow automation system requires AI assistance for multiple tasks:
- Documentation analysis and generation
- Code quality review
- Test strategy recommendations
- Consistency checking
- Issue extraction and prioritization

We needed to choose an AI provider that would:
1. Integrate seamlessly with our bash-based workflow
2. Provide high-quality, context-aware responses
3. Be accessible to developers
4. Support our specific use cases (code review, documentation, testing)
5. Have reasonable cost and performance characteristics

Available options included OpenAI API, Anthropic Claude API, local LLMs, and GitHub Copilot CLI.

## Decision

We will use **GitHub Copilot CLI** as our primary AI provider with the following architecture:

1. **Integration Layer**: `ai_helpers.sh` module wraps all Copilot CLI interactions
2. **Persona System**: 15 specialized AI personas for different workflow tasks
3. **Prompt Templates**: YAML-based templates in `.workflow_core/config/ai_helpers.yaml`
4. **Caching Layer**: AI response caching to reduce token usage (60-80% reduction)
5. **Fallback Strategy**: Graceful degradation when Copilot CLI is unavailable

## Rationale

**Why GitHub Copilot CLI:**

1. **CLI-First Design**: Built for command-line workflows, perfect for bash integration
2. **GitHub Integration**: Seamless authentication with GitHub accounts developers already have
3. **Context Awareness**: Understands code context and repository structure
4. **Model Selection**: Supports multiple models (Claude Sonnet, GPT-4, etc.)
5. **Developer Experience**: Familiar to most developers already using GitHub Copilot
6. **No API Key Management**: Uses GitHub authentication instead of separate API keys
7. **Cost Model**: Included with GitHub Copilot subscription (no per-token charges)

**Technical advantages:**

```bash
# Simple, reliable integration
copilot "$prompt" > output.md

# Built-in error handling
if ! is_copilot_available; then
    # Graceful fallback
fi
```

## Consequences

### Positive
- **Zero API Key Management**: No need to manage OpenAI/Anthropic keys
- **Developer Adoption**: Most developers already have Copilot access
- **Consistent Experience**: Same AI used in IDE and workflow
- **Cost Predictable**: No per-token surprise charges
- **Rich Context**: CLI provides repository context automatically
- **Multiple Models**: Can switch between Claude, GPT-4, etc.
- **Active Development**: Regular updates and improvements from GitHub

### Negative
- **Vendor Lock-in**: Dependent on GitHub's Copilot service
- **Authentication Required**: Requires GitHub authentication setup
- **Network Dependency**: Requires internet connection
- **Rate Limiting**: Subject to GitHub's rate limits
- **No Self-Hosting**: Cannot run locally or on-premise
- **Model Selection Limited**: Only models GitHub supports

### Neutral
- **Installation Required**: Developers must install `@githubnext/github-copilot-cli`
- **GitHub Account**: Requires GitHub account with Copilot access
- **Subscription Cost**: Requires GitHub Copilot subscription ($10-19/month per user)

## Alternatives Considered

### Alternative 1: OpenAI API Direct
- **Description**: Integrate directly with OpenAI API (GPT-4)
- **Pros**: 
  - Most powerful models available
  - Fine-grained control
  - Well-documented API
  - Predictable pricing
- **Cons**: 
  - API key management complexity
  - Per-token costs can be high
  - Additional billing to track
  - Requires separate authentication
- **Why not chosen**: API key management overhead; developers already have Copilot

### Alternative 2: Anthropic Claude API
- **Description**: Use Claude API directly
- **Pros**: 
  - Excellent at long-form analysis
  - Strong reasoning capabilities
  - Competitive pricing
- **Cons**: 
  - Yet another API key to manage
  - Less familiar to developers
  - Separate billing
  - Less GitHub integration
- **Why not chosen**: Similar to OpenAI but less integrated with developer workflow

### Alternative 3: Local LLM (Ollama, LLaMA)
- **Description**: Run open-source LLMs locally
- **Pros**: 
  - No API costs
  - Complete control
  - Privacy (no data sent externally)
  - No rate limits
  - Works offline
- **Cons**: 
  - Significant hardware requirements (GPU)
  - Model quality lower than GPT-4/Claude
  - Complex setup and maintenance
  - Slower inference
  - Each developer needs powerful hardware
- **Why not chosen**: Hardware requirements unrealistic for most developers

### Alternative 4: Multiple Provider Support
- **Description**: Support multiple AI providers with adapter pattern
- **Pros**: 
  - Flexibility to choose best model for task
  - No vendor lock-in
  - Fallback options
- **Cons**: 
  - Significant implementation complexity
  - Testing complexity (multiple providers)
  - Inconsistent results across providers
  - More maintenance burden
- **Why not chosen**: Over-engineering; Copilot CLI sufficient for our needs

## Implementation Notes

### Module Structure
```bash
# ai_helpers.sh provides clean abstraction
validate_copilot_cli          # Check availability and auth
build_ai_prompt              # Construct prompts
trigger_ai_step              # Execute AI task with persona
```

### Persona System
15 specialized personas implemented:
- documentation_specialist
- code_reviewer
- test_engineer
- ux_designer
- technical_writer
- prompt_engineer
- software_quality_engineer
- ... and 8 more

### Caching Strategy
```bash
# Automatic caching with SHA256 keys
# 24-hour TTL
# 60-80% token reduction
```

### Error Handling
```bash
if ! validate_copilot_cli; then
    print_warning "AI features disabled"
    # Continue workflow without AI
fi
```

### Testing Requirements
- Mock Copilot CLI for unit tests
- Integration tests with real API (optional)
- Fallback path testing
- Error handling testing

## References

- Related ADRs: 
  - [ADR-006: 15 Specialized AI Personas](./006-specialized-personas.md)
  - [ADR-007: AI Response Caching Strategy](./007-ai-response-caching.md)
- Documentation:
  - [ai_helpers.sh API](../../api/core/ai_helpers.md)
  - [AI Integration Guide](../../guides/ai-integration.md)
- External Resources:
  - [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli)
  - [GitHub Copilot Documentation](https://docs.github.com/copilot)
- Implementation: `src/workflow/lib/ai_helpers.sh` (117K lines)

## Review History

| Date | Reviewer | Decision | Notes |
|------|----------|----------|-------|
| 2025-12-18 | Core Team | Approved | After evaluating all alternatives |
| 2025-12-20 | Security Review | Approved | Auth model reviewed and approved |
| 2026-01-15 | Core Team | Reaffirmed | After 1 month of usage, excellent results |
| 2026-02-08 | Documentation Review | Approved | Historical record created |
