# Development Setup

## Prerequisites

- **Bash**: Version 4.0 or higher
- **Git**: Version 2.0 or higher
- **Node.js**: Version 25.2.1 or higher
- **GitHub Copilot CLI**: For AI features
- **Code Editor**: VS Code recommended with ShellCheck extension

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/mpbarbosa/ai_workflow.git
cd ai_workflow
```

### 2. Verify Environment

```bash
# Run health check
./src/workflow/lib/health_check.sh

# Verify versions
bash --version
git --version
node --version
gh copilot --version
```

### 3. Install Development Tools

```bash
# Install ShellCheck (optional but recommended)
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck
```

### 4. Run Tests

```bash
# Run all tests
cd src/workflow
./test_modules.sh

# Run library tests
cd lib
./test_enhancements.sh
```

## Development Tools

### Code Editor Setup (VS Code)

Recommended extensions:
- **ShellCheck**: Linting for shell scripts
- **Bash IDE**: IntelliSense and debugging
- **YAML**: YAML file support

### Testing Setup

```bash
# Set up test environment
cd src/workflow
export TEST_MODE=1

# Run specific tests
cd lib
./test_batch_operations.sh
```

### Debugging

```bash
# Enable debug mode
export DEBUG=1

# Run with trace
bash -x ./execute_tests_docs_workflow.sh --dry-run
```

## Project Structure

See [Architecture Overview](architecture.md) for detailed structure.

## Next Steps

- Review [Architecture Overview](architecture.md)
- Read [Contributing Guide](contributing.md)
- Check [Testing Guide](testing.md)
- Start with a small issue or enhancement
