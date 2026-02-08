# AI Workflow Automation - Documentation Hub

**Version**: 4.0.0  
**Last Updated**: 2026-02-08  
**Maintainer**: Marcelo Pereira Barbosa (@mpbarbosa)

> 📋 **Quick Navigation**: This is your central hub for all AI Workflow documentation. Start here to find what you need.

## 🚀 Getting Started

**New to AI Workflow?** Start here:
1. [README](../README.md) - Project overview and quick start
2. [Getting Started Guide](GETTING_STARTED.md) - Detailed setup instructions
3. [Quick Reference](QUICK_REFERENCE.md) - Command cheat sheet
4. [Tutorials](TUTORIALS.md) - Step-by-step walkthroughs

**Migration from v3.x?**
- [Migration Guide v4.0](MIGRATION_GUIDE_v4.0.md) - Configuration-driven step execution

## 📚 Documentation Categories

### For Users

#### Essential Guides
- **[Quick Reference](QUICK_REFERENCE.md)** - Command-line options and common patterns
- **[API Quick Reference](API_QUICK_REFERENCE.md)** - Function signatures at a glance
- **[Cookbook](COOKBOOK.md)** - Recipes for common tasks
- **[Tutorials](TUTORIALS.md)** - Hands-on learning paths
- **[Workflow Profiles](WORKFLOW_PROFILES.md)** - Pre-configured workflow templates

#### Configuration & Setup
- **[Configuration Reference](CONFIGURATION_REFERENCE.md)** - Complete config options
- **[Model Selection](MODEL_SELECTION.md)** - Choosing the right AI model
- **[Workflow Templates](../templates/workflows/README.md)** - Ready-to-use templates
  - [docs-only.sh](../templates/workflows/docs-only.sh) - Documentation updates (3-4 min)
  - [test-only.sh](../templates/workflows/test-only.sh) - Test development (8-10 min)
  - [feature.sh](../templates/workflows/feature.sh) - Full feature workflow (15-20 min)

#### Advanced Features
- **[ML Optimization Guide](ML_OPTIMIZATION_GUIDE.md)** - Machine learning enhancements (v2.7.0+)
- **[Multi-Stage Pipeline](MULTI_STAGE_PIPELINE_GUIDE.md)** - Progressive validation (v2.8.0+)
- **[Step 1 Optimization](STEP1_OPTIMIZATION_GUIDE.md)** - Fast documentation analysis (v3.2.0+)
- **[JQ Wrapper Documentation](JQ_WRAPPER_DOCUMENTATION.md)** - JSON processing utilities

#### User Guides (By Topic)
- **[Performance Tuning](user-guide/PERFORMANCE_TUNING.md)** - Optimization techniques
- **[Troubleshooting](user-guide/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Security Best Practices](user-guide/SECURITY.md)** - Secure usage patterns
- **[CI/CD Integration](user-guide/CICD_INTEGRATION.md)** - Automation examples

### For Developers

#### Getting Started as Contributor
- **[Developer Onboarding](developer-guide/DEVELOPER_ONBOARDING_GUIDE.md)** - Start here!
- **[Contributing Guide](../CONTRIBUTING.md)** - Contribution workflow
- **[Development Setup](developer-guide/development-setup.md)** - Local environment setup
- **[Code of Conduct](../CODE_OF_CONDUCT.md)** - Community guidelines

#### Architecture & Design
- **[Architecture Overview](ARCHITECTURE_OVERVIEW.md)** - High-level system design
- **[Comprehensive Architecture Guide](architecture/COMPREHENSIVE_ARCHITECTURE_GUIDE.md)** - Deep dive
- **[Architecture Deep Dive](architecture/ARCHITECTURE_DEEP_DIVE.md)** - Implementation details
- **[Workflow Diagrams](reference/workflow-diagrams.md)** - Visual system diagrams (17 Mermaid diagrams)
- **[Architecture Decision Records](architecture/adr/)** - Design decisions

#### API Documentation
- **[Unified API Reference](UNIFIED_API_REFERENCE.md)** - Complete API documentation
- **[Module API Reference](MODULE_API_REFERENCE.md)** - Library module APIs
- **[API Examples](API_EXAMPLES.md)** - Practical usage examples
- **[Step Modules API](api/STEP_MODULES.md)** - Step-specific APIs
- **[Library API Reference](api/LIBRARY_API_REFERENCE.md)** - Core library functions

#### Development Guides
- **[Extending the Workflow](developer-guide/EXTENDING_THE_WORKFLOW.md)** - Add new features
- **[Module Development](developer-guide/MODULE_DEVELOPMENT.md)** - Creating new modules
- **[Testing Guide](developer-guide/testing.md)** - Writing and running tests
- **[Testing Strategy](testing/TESTING_STRATEGY.md)** - Test coverage approach

### Reference Documentation

#### Project Information
- **[Project Reference](PROJECT_REFERENCE.md)** ⭐ **Authoritative source** - Complete project stats
  - 81 Library Modules + 21 Step Modules + 4 Orchestrators
  - 15 AI Personas
  - Version history and changelogs
  - Module inventory with line counts
- **[Roadmap](ROADMAP.md)** - Planned features and timeline
- **[Changelog](../CHANGELOG.md)** - Version history and release notes
- **[Release Notes v2.6.0](RELEASE_NOTES_v2.6.0.md)** - Auto-commit feature details

#### Technical Reference
- **[Automated Version Bump](AUTOMATED_VERSION_BUMP.md)** - Version management
- **[Workflow Module Inventory](workflow-automation/WORKFLOW_MODULE_INVENTORY.md)** - Complete module list
- **[Comprehensive Workflow Analysis](workflow-automation/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md)** - Execution deep dive
- **[Phase 2 Completion](workflow-automation/PHASE2_COMPLETION.md)** - Recent enhancements
- **[Version Evolution](workflow-automation/WORKFLOW_AUTOMATION_VERSION_EVOLUTION.md)** - Historical development

## 📊 Project Statistics (v4.0.0)

> See [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) for authoritative statistics

### Codebase
- **Total Modules**: 110 (81 library + 21 steps + 4 configs + 4 orchestrators)
- **Lines of Code**: 24,000+ across all modules
- **Test Coverage**: 100% (37+ automated tests)
- **Code Quality**: B+ (87/100)
- **Documentation**: 239 markdown files, 16,000+ lines

### Performance
- **Smart Execution**: 40-85% faster
- **Parallel Execution**: 33% faster
- **ML Optimization**: 15-30% additional improvement
- **AI Caching**: 60-80% token reduction
- **Step 1 Optimization**: 75-85% faster (v3.2.0+)

### Features
- **Pipeline Steps**: 20 automated steps
- **AI Personas**: 15 specialized roles
- **Workflow Templates**: 3 pre-configured
- **IDE Integration**: VS Code tasks
- **Pre-Commit Hooks**: Fast validation (&lt;1 second)

## 🔍 Finding What You Need

### By Use Case

**"I want to run the workflow quickly"**
→ [Quick Reference](QUICK_REFERENCE.md) → [Workflow Templates](../templates/workflows/)

**"I need to configure the workflow for my project"**
→ [Configuration Reference](CONFIGURATION_REFERENCE.md) → [Getting Started](GETTING_STARTED.md)

**"I want to contribute code"**
→ [Developer Onboarding](developer-guide/DEVELOPER_ONBOARDING_GUIDE.md) → [Contributing Guide](../CONTRIBUTING.md)

**"I'm experiencing issues"**
→ [Troubleshooting Guide](user-guide/TROUBLESHOOTING.md) → [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)

**"I want to understand the architecture"**
→ [Architecture Overview](ARCHITECTURE_OVERVIEW.md) → [Workflow Diagrams](reference/workflow-diagrams.md)

**"I need to optimize performance"**
→ [Performance Tuning Guide](user-guide/PERFORMANCE_TUNING.md) → [ML Optimization Guide](ML_OPTIMIZATION_GUIDE.md)

**"I want API documentation"**
→ [Unified API Reference](UNIFIED_API_REFERENCE.md) → [API Examples](API_EXAMPLES.md)

### By Topic

| Topic | Documentation |
|-------|--------------|
| **Installation** | [Getting Started](GETTING_STARTED.md), [Developer Setup](developer-guide/development-setup.md) |
| **Configuration** | [Configuration Reference](CONFIGURATION_REFERENCE.md), [Model Selection](MODEL_SELECTION.md) |
| **Usage** | [Quick Reference](QUICK_REFERENCE.md), [Cookbook](COOKBOOK.md), [Tutorials](TUTORIALS.md) |
| **Performance** | [Performance Tuning](user-guide/PERFORMANCE_TUNING.md), [ML Optimization](ML_OPTIMIZATION_GUIDE.md) |
| **Architecture** | [Architecture Overview](ARCHITECTURE_OVERVIEW.md), [Deep Dive](architecture/ARCHITECTURE_DEEP_DIVE.md) |
| **API** | [Unified API](UNIFIED_API_REFERENCE.md), [Module API](MODULE_API_REFERENCE.md) |
| **Testing** | [Testing Guide](developer-guide/testing.md), [Testing Strategy](testing/TESTING_STRATEGY.md) |
| **Troubleshooting** | [Troubleshooting Guide](user-guide/TROUBLESHOOTING.md), [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues) |
| **Contributing** | [Contributing](../CONTRIBUTING.md), [Developer Onboarding](developer-guide/DEVELOPER_ONBOARDING_GUIDE.md) |
| **Security** | [Security Guide](user-guide/SECURITY.md), [Code of Conduct](../CODE_OF_CONDUCT.md) |

## 🎯 Documentation Standards

All documentation in this project follows these standards:

1. **Clarity**: Written for the target audience (users vs. developers)
2. **Completeness**: Covers common use cases and edge cases
3. **Currency**: Updated with each version release
4. **Examples**: Includes practical, working examples
5. **Cross-referencing**: Links to related documentation
6. **Versioning**: Documents version-specific features

## 📝 Documentation Versions

- **Current**: v4.0.0 - Configuration-driven step execution
- **Recent**: v3.x - Pre-commit hooks, audio notifications, Step 1 optimization
- **Legacy**: v2.x - ML optimization, multi-stage pipeline, auto-commit

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.

## 🤝 Contributing to Documentation

Found a gap or error? Help us improve!

1. Check if documentation exists in this hub
2. If missing, create an [issue](https://github.com/mpbarbosa/ai_workflow/issues)
3. Follow [Contributing Guide](../CONTRIBUTING.md)
4. Submit a pull request

See [MAINTAINERS.md](MAINTAINERS.md) for documentation maintainers.

## 📖 External Resources

- **GitHub Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
- **Issue Tracker**: [GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mpbarbosa/ai_workflow/discussions)
- **License**: [MIT License](../LICENSE)

## 🆘 Need Help?

1. **Check this hub** for relevant documentation
2. **Search** existing [issues](https://github.com/mpbarbosa/ai_workflow/issues)
3. **Create an issue** if you can't find an answer
4. **Read** [Troubleshooting Guide](user-guide/TROUBLESHOOTING.md)

---

**Last Updated**: 2026-02-08  
**Documentation Version**: v4.0.0  
**Maintainer**: Marcelo Pereira Barbosa (@mpbarbosa)
