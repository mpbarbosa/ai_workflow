# Frequently Asked Questions (FAQ)

**Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Maintained By**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))

---

## Table of Contents

- [General Questions](#general-questions)
- [Installation & Setup](#installation--setup)
- [Usage & Operation](#usage--operation)
- [Features & Capabilities](#features--capabilities)
- [Performance & Optimization](#performance--optimization)
- [AI Integration](#ai-integration)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Comparison with Other Tools](#comparison-with-other-tools)

---

## General Questions

### What is AI Workflow Automation?

AI Workflow Automation is a comprehensive, modular workflow system that validates and enhances documentation, code, and tests using AI support. It provides a 15-step automated pipeline with features like smart execution, parallel processing, AI response caching, and UX analysis.

**Key Features**:
- 15-step automated pipeline
- 28 library modules + 15 step modules
- 14 AI personas using GitHub Copilot CLI
- 100% test coverage with 37+ automated tests

### Who is this tool for?

**Primary Users**:
- **Developers**: Automate code quality and testing workflows
- **Technical Writers**: Validate and enhance documentation
- **DevOps Engineers**: Integrate into CI/CD pipelines
- **Project Maintainers**: Ensure consistent project quality
- **Open Source Contributors**: Improve contribution quality

### What makes it different from other workflow tools?

**Key Differentiators**:
1. **AI-Native**: 14 specialized AI personas for intelligent analysis
2. **Comprehensive**: Covers docs, code, tests, and UX in one pipeline
3. **Performance-Optimized**: Smart execution (40-85% faster), parallel processing (33% faster)
4. **Modular Architecture**: 43 modules (24K+ lines) for extensibility
5. **Local-First**: Runs on your machine, optional CI/CD integration
6. **Shell-Based**: Bash scripts with minimal dependencies

See [Related Projects](../../README.md) for detailed comparisons.

### Is it free to use?

**Yes!** AI Workflow is open source under the MIT License.

**What this means**:
- ✅ Free for commercial use
- ✅ Modify the source code
- ✅ Distribute copies
- ✅ Use privately
- ℹ️ Include license and copyright notice

See [LICENSE](../../LICENSE) for full details.

### What are the system requirements?

**Minimum Requirements**:
- **OS**: Linux, macOS, or WSL on Windows
- **Bash**: Version 4.0 or higher
- **Git**: Any recent version
- **Disk Space**: ~50MB for the repository

**Optional (for full features)**:
- **Node.js**: v25.2.1+ (for test execution)
- **GitHub Copilot CLI**: For AI-powered analysis
- **Internet Connection**: For AI features and CI/CD

**Check your system**:
```bash
bash --version    # Should be 4.0+
git --version     # Any recent version
node --version    # 25.2.1+ if using
```

---

## Installation & Setup

### How do I install AI Workflow?

**Quick Install**:
```bash
# Clone the repository
git clone git@github.com:mpbarbosa/ai_workflow.git
cd ai_workflow

# Run health check
./src/workflow/lib/health_check.sh

# Test on itself (recommended first step)
./src/workflow/execute_tests_docs_workflow.sh --smart-execution
```

See [Quick Start](../../README.md) for detailed instructions.

### Do I need GitHub Copilot CLI?

**Not required, but recommended.**

**Without Copilot CLI**:
- Basic validation still works
- Scripts execute normally
- No AI-powered analysis

**With Copilot CLI**:
- Full AI-powered analysis
- 14 specialized AI personas
- Intelligent suggestions
- AI response caching (60-80% token savings)

**Install Copilot CLI**:
```bash
npm install -g @githubnext/github-copilot-cli
gh copilot --version
```

### How do I configure it for my project?

**Method 1: Interactive Wizard** (Recommended)
```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

**Method 2: Manual Configuration**
Create `.workflow-config.yaml` in your project root:
```yaml
project:
  kind: nodejs_api  # or shell_automation, react_spa, etc.
  
tech_stack:
  primary_language: javascript
  test_command: npm test
  
workflow:
  skip_steps: []
```

See [Configuration Schema](../reference/configuration.md) for all options.

### Can I use it with existing projects?

**Yes!** AI Workflow works with any project.

**Usage Patterns**:

**Pattern 1**: Run from project directory (default)
```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
```

**Pattern 2**: Use `--target` flag
```bash
cd ai_workflow
./src/workflow/execute_tests_docs_workflow.sh --target /path/to/project
```

**Pattern 3**: Copy workflow to project
```bash
cp -r ai_workflow/src/workflow /path/to/project/src/
cd /path/to/project
./src/workflow/execute_tests_docs_workflow.sh
```

See [Target Project Feature](../reference/target-project-feature.md) for details.

---

## Usage & Operation

### How do I run the workflow?

**Basic Usage**:
```bash
./src/workflow/execute_tests_docs_workflow.sh
```

**Recommended (Optimized)**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel --auto
```

**Common Options**:
- `--smart-execution`: Skip unnecessary steps (40-85% faster)
- `--parallel`: Run independent steps simultaneously (33% faster)
- `--auto`: Accept all prompts automatically
- `--target DIR`: Run on different project
- `--steps N,M,...`: Run specific steps only
- `--dry-run`: Preview without execution

See [Complete Feature Guide](feature-guide.md).

### What does each step do?

**15-Step Pipeline**:

| Step | Name | Purpose |
|------|------|---------|
| 0 | Pre-Analysis | Initial validation and setup |
| 1 | Documentation | Updates and validation with AI |
| 2 | Consistency | Cross-reference consistency checks |
| 3 | Script References | Script reference validation |
| 4 | Directory | Directory structure validation |
| 5 | Test Review | Test coverage review |
| 6 | Test Generation | AI-powered test case generation |
| 7 | Test Execution | Test suite execution |
| 8 | Dependencies | Dependency validation |
| 9 | Code Quality | Code quality checks |
| 10 | Context | Context analysis |
| 11 | Git | Git operations and finalization |
| 12 | Markdown Linting | Markdown formatting validation |
| 13 | Prompt Engineering | AI prompt analysis (ai_workflow only) |
| 14 | UX Analysis | UI/UX and accessibility checking |

See [Comprehensive Workflow Analysis](../archive/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md).

### How long does it take to run?

**Baseline**: ~23 minutes (all steps, no optimization)

**With Optimization**:
- **Documentation only**: 2.3 min (90% faster)
- **Code changes**: 10 min (57% faster)
- **Full changes**: 15.5 min (33% faster)

**Optimization Features**:
- Smart execution: Skips 0-9 steps based on changes
- Parallel execution: 6 parallel groups
- AI caching: 60-80% token reduction
- Checkpoint resume: Continue from failures

See [Performance Benchmarks](../reference/performance-benchmarks.md).

### Can I run only specific steps?

**Yes!** Use the `--steps` flag:

```bash
# Run only documentation steps
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2

# Run only test steps
./src/workflow/execute_tests_docs_workflow.sh --steps 5,6,7

# Run git finalization only
./src/workflow/execute_tests_docs_workflow.sh --steps 11
```

### What happens if a step fails?

**Checkpoint Resume** (automatic):
- Workflow saves progress after each step
- Automatically resumes from last completed step
- Use `--no-resume` to force fresh start

**Example**:
```bash
# First run - fails at step 7
./src/workflow/execute_tests_docs_workflow.sh

# Fix the issue, then resume automatically
./src/workflow/execute_tests_docs_workflow.sh  # Continues from step 7

# Force fresh start if needed
./src/workflow/execute_tests_docs_workflow.sh --no-resume
```

---

## Features & Capabilities

### What AI personas are available?

**14 Specialized AI Personas**:

1. **documentation_specialist** - Documentation updates (context-aware)
2. **consistency_analyst** - Cross-reference checks
3. **code_reviewer** - Code quality review
4. **test_engineer** - Test generation and validation
5. **dependency_analyst** - Dependency analysis
6. **git_specialist** - Git operations
7. **performance_analyst** - Performance optimization
8. **security_analyst** - Security scanning
9. **markdown_linter** - Markdown validation
10. **context_analyst** - Context analysis
11. **script_validator** - Shell script validation
12. **directory_validator** - Directory validation
13. **test_execution_analyst** - Test execution analysis
14. **ux_designer** - UX/UI analysis (NEW v2.4.0)

Each persona is specialized for specific tasks with tailored prompts.

### Does it support multiple programming languages?

**Primary Support**: Shell scripts (Bash)

**Project Support** (through configuration):
- **JavaScript/TypeScript**: Node.js projects (APIs, SPAs, CLIs)
- **Python**: Python applications and libraries
- **Static Sites**: HTML/CSS/JavaScript
- **Documentation**: Markdown-based docs

**Language-Aware Features**:
- Adaptive test execution (Jest, BATS, pytest)
- Project kind detection (12+ types)
- Tech stack configuration
- Framework-specific validation

See [Tech Stack Framework](../design/tech-stack-framework.md).

### Can it generate tests automatically?

**Yes!** Step 6 uses AI to generate test cases.

**How it works**:
1. Analyzes code coverage gaps
2. Uses test_engineer AI persona
3. Generates tests based on project type
4. Outputs test files to review/integrate

**Supported Frameworks**:
- BATS (Bash Automated Testing System)
- Jest (JavaScript)
- pytest (Python)
- Custom frameworks (configurable)

**Example**:
```bash
# Run test generation step
./src/workflow/execute_tests_docs_workflow.sh --steps 5,6,7
```

### Does it check accessibility?

**Yes!** Step 14 (NEW in v2.4.0) provides UX analysis.

**Features**:
- **UI Detection**: Automatic detection of React, Vue, Static sites
- **WCAG 2.1 Compliance**: Accessibility checking
- **UX Designer Persona**: AI-powered analysis
- **Smart Skipping**: Skips for non-UI projects (APIs, libraries)

**What it checks**:
- Color contrast ratios
- ARIA attributes
- Keyboard navigation
- Screen reader compatibility
- Semantic HTML
- Focus management

See [Step 14 Documentation](../archive/STEP_14_UX_ANALYSIS.md).

---

## Performance & Optimization

### How does smart execution work?

**Smart Execution** analyzes changes and skips unnecessary steps.

**How it works**:
1. Detects changes using git diff
2. Classifies changes (docs, code, tests, config)
3. Determines which steps are required
4. Skips steps that won't find issues

**Example Skipping**:
- **Documentation-only changes**: Skips steps 5-10 (test/code analysis)
- **Code-only changes**: Skips step 1 (documentation)
- **Config-only changes**: Skips most validation steps

**Results**:
- Documentation changes: 85% faster
- Code changes: 40% faster
- No false negatives (all issues caught)

See [Smart Execution Guide](../reference/smart-execution.md).

### What is parallel execution?

**Parallel Execution** runs independent steps simultaneously.

**How it works**:
- Groups steps by dependencies
- Runs groups in parallel
- Up to 6 concurrent steps

**Parallel Groups**:
- **Group 1**: Steps 1, 3, 4, 5, 8, 13, 14 (documentation, validation)
- **Group 2**: Step 2 (consistency)
- **Group 3**: Steps 6, 10 (test gen, context)
- **Group 4**: Step 7 (test execution)
- **Group 5**: Step 9, 12 (quality, markdown)
- **Group 6**: Step 11 (git finalization)

**Results**: 33% faster on average

See [Parallel Execution Guide](../reference/parallel-execution.md).

### How does AI response caching work?

**AI Response Caching** stores AI responses to avoid redundant API calls.

**How it works**:
1. Caches responses with SHA256 keys
2. 24-hour TTL (time-to-live)
3. Automatic cleanup
4. Hit rate tracking

**Benefits**:
- 60-80% token usage reduction
- Faster repeated executions
- Lower API costs
- Automatic expiration

**Configuration**:
```bash
# Caching enabled by default
./src/workflow/execute_tests_docs_workflow.sh

# Disable if needed
./src/workflow/execute_tests_docs_workflow.sh --no-ai-cache
```

See [AI Cache Configuration](../reference/ai-cache-configuration.md).

---

## AI Integration

### Do I need an OpenAI API key?

**No!** AI Workflow uses GitHub Copilot CLI, which has its own authentication.

**Authentication**:
```bash
# One-time setup
gh copilot auth login

# Verify authentication
gh copilot --version
```

### How much does it cost to run with AI?

**Cost depends on GitHub Copilot subscription**:

**GitHub Copilot Individual**: $10/month or $100/year
- Includes Copilot CLI access
- Unlimited usage (fair use policy)

**GitHub Copilot Business**: $19/user/month
- Team features
- Enterprise support

**With AI Caching**: 60-80% token reduction means lower effective costs.

### Can I run it without AI features?

**Yes!** All validation steps work without AI.

**What works without AI**:
- Script validation
- Directory structure checks
- Test execution
- Markdown linting
- Git operations
- Code quality checks (if tools available)

**What requires AI**:
- Documentation enhancement
- Test generation
- Context analysis
- UX analysis
- AI-powered suggestions

---

## Configuration

### What configuration files are supported?

**Project Configuration**:
- `.workflow-config.yaml` - Project-specific settings (in project root)

**System Configuration**:
- `src/workflow/config/paths.yaml` - Path configuration
- `src/workflow/config/ai_helpers.yaml` - AI prompt templates
- `src/workflow/config/project_kinds.yaml` - Project type definitions
- `src/workflow/config/step_relevance.yaml` - Step applicability

See [Configuration Schema](../reference/configuration.md).

### How do I skip certain steps?

**Method 1**: Use `--steps` flag
```bash
# Run only specific steps
./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2,11
```

**Method 2**: Configure in `.workflow-config.yaml`
```yaml
workflow:
  skip_steps: [6, 9, 13]  # Skip test generation, quality, prompt analysis
```

**Method 3**: Project kind configuration
Some steps automatically skip based on project type (e.g., UX analysis skips for APIs).

### Can I customize AI prompts?

**Yes!** Prompts are externalized in YAML files.

**Base Prompts**: `src/workflow/config/ai_helpers.yaml`
**Project-Specific**: `src/workflow/config/ai_prompts_project_kinds.yaml`

**Customization**:
1. Copy template from config files
2. Modify for your needs
3. Reference in `.workflow-config.yaml`

**Example** custom prompt:
```yaml
personas:
  documentation_specialist:
    base_prompt: |
      You are a technical writer specializing in...
      (your custom instructions)
```

---

## Troubleshooting

### The workflow runs too slowly

**Try these optimizations**:

1. **Enable smart execution**:
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --smart-execution
   ```

2. **Enable parallel execution**:
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --parallel
   ```

3. **Combine optimizations**:
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --smart-execution --parallel --auto
   ```

4. **Skip unnecessary steps**:
   ```bash
   ./src/workflow/execute_tests_docs_workflow.sh --steps 0,1,2,11
   ```

5. **Check AI cache hit rate**:
   ```bash
   ls -lh src/workflow/.ai_cache/
   ```

### GitHub Copilot CLI isn't working

**Check authentication**:
```bash
gh copilot --version
gh copilot auth status
```

**Re-authenticate if needed**:
```bash
gh copilot auth login
```

**Verify subscription**:
- Visit https://github.com/settings/copilot
- Ensure Copilot subscription is active

### Tests are failing in Step 7

**Common causes**:

1. **Wrong directory**: Step 7 uses `TARGET_DIR`
   ```bash
   # Verify target directory
   cd /path/to/your/project
   /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh
   ```

2. **Missing test framework**:
   ```bash
   # Install test framework
   npm install    # For Jest
   pip install pytest  # For pytest
   ```

3. **Test command not configured**:
   ```yaml
   # .workflow-config.yaml
   tech_stack:
     test_command: npm test  # or pytest, bats, etc.
   ```

### How do I reset everything?

**Clear caches and checkpoints**:
```bash
# Remove AI cache
rm -rf src/workflow/.ai_cache/

# Remove checkpoints
rm -f src/workflow/.checkpoint

# Remove backlog
rm -rf src/workflow/backlog/

# Remove metrics
rm -rf src/workflow/metrics/

# Force fresh start
./src/workflow/execute_tests_docs_workflow.sh --no-resume --no-ai-cache
```

### Where are execution logs stored?

**Log Locations**:
```
src/workflow/logs/workflow_YYYYMMDD_HHMMSS/
├── workflow_execution.log       # Main log
├── step0_*.log                   # Step-specific logs
├── step1_*.log
└── ...
```

**View logs**:
```bash
# Latest workflow log
tail -f src/workflow/logs/workflow_*/workflow_execution.log

# Specific step
cat src/workflow/logs/workflow_*/step7_test_execution.log
```

---

## Contributing

### How can I contribute?

**Ways to contribute**:
1. **Code**: Bug fixes, features, optimizations
2. **Documentation**: Improvements, translations, examples
3. **Testing**: Test coverage, edge cases
4. **Issues**: Bug reports, feature requests
5. **Discussion**: Share use cases, provide feedback

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for detailed guidelines.

### How do I report bugs?

**Create a GitHub Issue**:
1. Visit [Issues](https://github.com/mpbarbosa/ai_workflow/issues)
2. Click "New Issue"
3. Choose "Bug Report" template
4. Provide:
   - System information (OS, Bash version)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs

### Can I request features?

**Yes!** Use GitHub Issues with "Feature Request" template.

**Good feature requests include**:
- **Use case**: Why you need it
- **Current workaround**: What you do now
- **Proposed solution**: How it might work
- **Alternatives**: Other approaches considered

### How do I become a maintainer?

See [MAINTAINERS.md](../MAINTAINERS.md) for:
- Maintainer responsibilities
- Requirements for maintainership
- Nomination process
- Onboarding steps

---

## Comparison with Other Tools

### AI Workflow vs. pre-commit

| Feature | AI Workflow | pre-commit |
|---------|-------------|------------|
| Scope | Comprehensive (15 steps) | Pre-commit hooks only |
| AI-Powered | ✅ 14 personas | ❌ No |
| Test Generation | ✅ Yes | ❌ No |
| Documentation | ✅ AI-enhanced | ⚠️ Basic checks |
| UX Analysis | ✅ WCAG 2.1 | ❌ No |
| Performance | ✅ Optimized | ⚠️ Basic |

**Use Together**: pre-commit for immediate checks, AI Workflow for comprehensive validation.

### AI Workflow vs. GitHub Actions

| Feature | AI Workflow | GitHub Actions |
|---------|-------------|----------------|
| Execution | Local-first | Cloud-based |
| AI Integration | ✅ Native | ⚠️ Manual setup |
| Cost | One-time + Copilot | Free (public) / Paid (private) |
| Dependencies | Minimal | Marketplace actions |
| Customization | ✅ Highly modular | ⚠️ YAML workflows |

**Use Together**: Run AI Workflow in GitHub Actions for automated CI/CD.

### AI Workflow vs. MkDocs/Vale

| Feature | AI Workflow | MkDocs | Vale |
|---------|-------------|--------|------|
| Purpose | Validation + Enhancement | Publishing | Style checking |
| AI-Powered | ✅ Yes | ❌ No | ❌ No |
| Scope | Full project | Docs only | Prose only |
| Integration | Pipeline | Output | Input |

**Use Together**: AI Workflow validates → Vale checks style → MkDocs publishes.

See [Related Projects](../../README.md) for comprehensive comparisons.

---

## Additional Resources

### Documentation

- **[README.md](../../README.md)**: Project overview and quick start
- **[Complete Feature Guide](feature-guide.md)**: All features
- **[Project Reference](../PROJECT_REFERENCE.md)**: Single source of truth
- **[Documentation Changelog](../archive/DOCUMENTATION_CHANGELOG.md)**: Change history

### Guides

- **[Quick Start Guide](quick-start.md)**: Get started quickly
- **[Target Project Feature](../reference/target-project-feature.md)**: Use with other projects
- **[Smart Execution](../reference/smart-execution.md)**: Optimization guide
- **[Parallel Execution](../reference/parallel-execution.md)**: Concurrent processing

### Community

- **[GitHub Issues](https://github.com/mpbarbosa/ai_workflow/issues)**: Bug reports, features
- **[GitHub Discussions](https://github.com/mpbarbosa/ai_workflow/discussions)**: Q&A, ideas
- **[Contributing Guidelines](../../CONTRIBUTING.md)**: How to contribute
- **[Code of Conduct](../../CODE_OF_CONDUCT.md)**: Community standards

### Contact

- **Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
- **Email**: mpbarbosa@gmail.com
- **Security**: See [SECURITY.md](../../SECURITY.md)

---

**Have a question not answered here?** 

Open a [GitHub Discussion](https://github.com/mpbarbosa/ai_workflow/discussions) or [create an issue](https://github.com/mpbarbosa/ai_workflow/issues)!

---

**Last Updated**: 2025-12-23  
**Version**: 1.0.0  
**Maintainer**: [@mpbarbosa](https://github.com/mpbarbosa)
