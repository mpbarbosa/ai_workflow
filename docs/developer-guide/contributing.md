# Contributing Guide

Thank you for your interest in contributing to AI Workflow Automation!

## Getting Started

1. **Fork the Repository**: Create your own fork on GitHub
2. **Clone Your Fork**: `git clone https://github.com/YOUR_USERNAME/ai_workflow.git`
3. **Set Up Development Environment**: See [Development Setup](development-setup.md)
4. **Review Architecture**: Read [Architecture Overview](architecture.md

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Follow these guidelines:
- **Code Style**: Follow shell script best practices (see [Architecture](architecture.md)
- **Testing**: Add tests for new functionality (see [Testing Guide](testing.md)
- **Documentation**: Update relevant documentation
- **Commits**: Use clear, descriptive commit messages

### 3. Test Your Changes

```bash
# Run library tests
cd src/workflow/lib
./test_enhancements.sh

# Run module tests
cd ..
./test_modules.sh

# Test on sample project
./execute_tests_docs_workflow.sh --target examples/nodejs-api --dry-run
```

### 4. Submit Pull Request

- Ensure all tests pass
- Update documentation
- Reference any related issues
- Provide clear description of changes

## Code Standards

### Shell Script Guidelines

- Use `#!/usr/bin/env bash` shebang
- Set `-euo pipefail` for error handling
- Use `local` for function variables
- Quote all variable expansions: `"${var}"`
- Use `[[ ]]` for conditionals
- Follow single responsibility principle

### Documentation Standards

See [Documentation Style Guide](../reference/documentation-style-guide.md).

### Testing Requirements

- Add unit tests for library modules
- Add integration tests for step modules
- Maintain 100% test coverage for new code
- Update existing tests if behavior changes

## Adding Features

### Adding a New Step

1. Create step script in `src/workflow/steps/step_XX_name.sh`
2. Implement required functions: `validate_step()`, `execute_step()`
3. Update dependency graph in `dependency_graph.sh`
4. Add tests
5. Update documentation

### Adding a New Library Module

1. Create module in `src/workflow/lib/`
2. Add header comment with purpose and API
3. Export functions with clear names
4. Write unit tests
5. Update [API Reference](api-reference.md

### Working with AI Helpers

See [API Reference](api-reference.md) for AI integration patterns.

## Review Process

1. **Automated Checks**: CI/CD runs tests automatically
2. **Code Review**: Maintainers review changes
3. **Documentation Review**: Check for documentation updates
4. **Testing Verification**: Ensure tests pass and coverage maintained

## Getting Help

- Open an issue for questions
- Join discussions on GitHub
- See [MAINTAINERS.md](../MAINTAINERS.md) for contact information
- Review [FAQ](../user-guide/faq.md)

## Code of Conduct

See [CODE_OF_CONDUCT.md](../../CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
