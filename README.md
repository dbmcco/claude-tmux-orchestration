# Claude TMUX Orchestration

**Multi-agent AI development orchestration using TMUX and Claude Code CLI**

[![Status](https://img.shields.io/badge/status-ready%20for%20testing-green)]()
[![Version](https://img.shields.io/badge/version-1.0-blue)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()

This project provides a complete, working implementation for coordinating multiple Claude Code CLI instances via TMUX for automated, TDD-enforced development workflows. The system enables Claude to act as a project manager, delegating tasks to specialized sub-agents running in dedicated TMUX windows while maintaining strict quality gates.

**Status**: ✅ **Implementation complete** - Extracted from production use in lfw-draftforge-v1, generalized for any project, and ready for testing.

## Overview

Claude TMUX Orchestration is an experimental architecture where:

- **Claude Code CLI (Manager)** acts as a project coordinator
- **Specialized sub-agents** (implementers, testers) work in isolated TMUX windows
- **Quality gates** enforce TDD cycles (RED → GREEN → REFACTOR)
- **CI/CD integration** validates deployments automatically

### Key Features

- **TDD-Enforced Development**: Manager blocks implementation-before-test attempts
- **Quality Gate Automation**: ESLint, TypeScript, test coverage, E2E validation
- **Multi-Agent Coordination**: Parallel agent deployment with domain separation
- **Human-in-the-Loop**: Critical decision points escalated to developers
- **State Monitoring**: Manager tracks agent progress via TMUX capture-pane

## Architecture

```
MacBook (Development Machine)
└── tmux session: project
    ├── window 0: implementer (Claude/Codex)
    │   └── Role: Write tests first, implement code following TDD
    │
    ├── window 1: manager (Claude Code CLI - YOU)
    │   └── Role: Coordinate agents, enforce quality gates, manage git
    │
    └── window 2: testing (Claude Code CLI)
        └── Role: Run E2E tests on deployments
```

### Agent Roles

#### Manager Agent (Window 1)
- Confers with developer on session priorities
- Briefs implementer agents with TDD requirements
- Monitors progress via `tmux capture-pane` every 30-60s
- Enforces quality gates before commits
- Coordinates E2E testing after deployments
- **Constraint**: Does NOT write code directly - only coordinates

#### Implementer Agent (Window 0)
- Follows strict TDD: RED → GREEN → REFACTOR
- Writes failing tests first, then minimal implementation
- Runs quality checks before requesting commit approval
- **Constraint**: Cannot commit without Manager approval

#### Testing Agent (Window 2)
- Dedicated E2E testing agent
- Validates production deployments
- Reports performance regressions
- **Scope**: Full test suite validation

## Workflow Example

```bash
# 1. Manager briefs implementer
tmux send-keys -t project:0 "Task: Implement user authentication following TDD..." Enter

# 2. Manager monitors progress
tmux capture-pane -t project:0 -p | tail -50

# 3. Implementer requests commit (after quality gates pass)
# Manager validates output

# 4. Manager executes commit
git add .
git commit -m "feat: user authentication

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# 5. Manager briefs testing agent
tmux send-keys -t project:2 "Run E2E tests on production..." Enter

# 6. Manager reports results
# "✅ Deployment validated. E2E tests: 13/13 passed."
```

## Quality Gates

Every commit must pass:

1. **ESLint**: 0 errors, 0 warnings
2. **TypeScript**: 0 errors (strict mode)
3. **Unit Tests**: All tests pass
4. **Coverage**: >80% test coverage

Manager blocks commits if ANY gate fails.

## TDD Enforcement

Manager strictly enforces the TDD cycle:

### RED Phase
```
Manager: "Write a failing test for [feature]. Show me RED output."
Implementer: [writes test, runs it, shows failure]
Manager: [validates test fails for correct reason] "Proceed to GREEN."
```

### GREEN Phase
```
Manager: "Implement minimal code to make test pass. Show me GREEN."
Implementer: [writes code, runs test, shows pass]
Manager: [validates test passes] "Proceed to REFACTOR if needed."
```

### REFACTOR Phase
```
Manager: "Refactor for clarity. Ensure tests stay GREEN."
Implementer: [improves code, reruns tests]
Manager: [validates tests still pass] "Run quality gates."
```

**Intervention Protocol:**
- If implementer writes code before test → **STOP IMMEDIATELY**
- If implementer wants to commit without quality gates → **BLOCK**
- Manager enforces TDD without exceptions

## Installation

### Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/tmux-agent-orchestration.git
cd tmux-agent-orchestration

# Run interactive setup
./setup.sh

# Validate installation
./validate-setup.sh

# Create tmux session
./scripts/tmux-spawn-session.sh --attach
```

**Full installation guide**: See [INSTALLATION.md](INSTALLATION.md)

### Prerequisites

- TMUX installed (`brew install tmux` on macOS)
- Git version control
- Node.js and npm (optional, for JavaScript/TypeScript projects)
- Claude Code CLI (optional, for AI agent integration)

## Usage

### Orchestration Commands

The agent orchestrator provides a simple CLI for coordinating agents:

```bash
# Brief implementer with task
./scripts/agent-orchestrator.sh brief "Implement user authentication following TDD"

# Monitor implementer progress
./scripts/agent-orchestrator.sh monitor 0

# Validate quality gates
./scripts/agent-orchestrator.sh validate

# Execute commit (after quality gates pass)
./scripts/agent-orchestrator.sh commit "feat: add user authentication"

# Request E2E tests
./scripts/agent-orchestrator.sh e2e https://your-deployment.com

# Show help
./scripts/agent-orchestrator.sh help
```

### TMUX Session Management

```bash
# Create new session
./scripts/tmux-spawn-session.sh

# Create and attach immediately
./scripts/tmux-spawn-session.sh --attach

# Monitor specific window
./scripts/tmux-monitor.sh 0 50  # Window 0, last 50 lines

# Delegate command to window
./scripts/tmux-delegate.sh 0 "npm test"
```

### Git Hook Integration

The setup script can install pre-commit and post-commit hooks:

- `pre-commit.sh`: Runs quality gates before every commit
- `post-commit.sh`: Logs commit information and triggers post-commit workflows
- `quality-gates.sh`: Validates ESLint, TypeScript, tests, and coverage

Hooks are installed in `.claude/hooks/` and linked to `.git/hooks/`.

## Configuration

### Project Structure

```
claude-tmux-orchestration/
├── config/
│   ├── config.sh.example      # ✅ Configuration template
│   └── config.sh              # ✅ Your configuration (created by setup)
│
├── hooks/
│   ├── quality-gates.sh       # ✅ Quality gate enforcement
│   ├── pre-commit.sh          # ✅ Pre-commit validation
│   └── post-commit.sh         # ✅ Post-commit workflow
│
├── scripts/
│   ├── tmux-spawn-session.sh  # ✅ Create tmux session
│   ├── tmux-monitor.sh        # ✅ Monitor window output
│   ├── tmux-delegate.sh       # ✅ Send commands to windows
│   └── agent-orchestrator.sh  # ✅ Core coordination logic
│
├── tests/
│   └── test-tmux-basic.sh     # ✅ Basic functionality tests
│
├── setup.sh                   # ✅ Interactive setup script
├── validate-setup.sh          # ✅ Installation validator
├── README.md                  # This file
├── INSTALLATION.md            # ✅ Detailed installation guide
├── TESTING.md                 # ✅ Testing procedures
└── TMUX_CLAUDE_CICD_ARCHITECTURE.md  # Architecture documentation
```

**Legend**: ✅ = Implemented and working

### Configuration Example

The `config/config.sh` file controls all behavior:

```bash
# Project Configuration
PROJECT_NAME="your-project-name"
PROJECT_ROOT="/path/to/your/project"

# TMUX Configuration
TMUX_SESSION_NAME="${PROJECT_NAME}-dev"
TMUX_IMPLEMENTER_WINDOW="0"
TMUX_MANAGER_WINDOW="1"
TMUX_TESTING_WINDOW="2"

# Quality Gate Configuration
ENABLE_ESLINT=true
ENABLE_TYPESCRIPT=true
ENABLE_TESTS=true
ENABLE_COVERAGE=true

# NPM Scripts (match your package.json)
LINT_SCRIPT="lint"
TYPE_CHECK_SCRIPT="type-check"
TEST_SCRIPT="test"
COVERAGE_SCRIPT="test:coverage"
```

## Testing Status

### Implementation Complete ✅

- ✅ **Architecture documented** - Complete specification in TMUX_CLAUDE_CICD_ARCHITECTURE.md
- ✅ **Working scripts extracted** - Quality gates, hooks, and orchestration from lfw-draftforge-v1
- ✅ **Scripts generalized** - Configuration system for any project
- ✅ **Setup automation** - Interactive installer and validator
- ✅ **Documentation complete** - Installation, testing, and usage guides
- ✅ **Test suite created** - Basic functionality validation

### Testing Available

Run comprehensive testing:

```bash
# Validate installation
./validate-setup.sh

# Run automated tests
./tests/test-tmux-basic.sh

# Follow manual testing guide
cat TESTING.md
```

### Success Metrics

- ✅ **Installation**: Automated setup with validation
- ✅ **Quality Gates**: ESLint, TypeScript, tests, coverage enforcement
- ✅ **TMUX Coordination**: Session creation, monitoring, delegation
- ✅ **Git Integration**: Pre-commit and post-commit hooks
- ✅ **Configuration**: Flexible config system for any project
- ⏳ **Production Use**: Ready for real-world testing

## Roadmap

### Phase 1: Core Implementation ✅ (Complete)
- ✅ Extract working scripts from lfw-draftforge-v1
- ✅ Generalize for any project with configuration system
- ✅ Create orchestration and coordination scripts
- ✅ Implement setup and validation automation
- ✅ Complete documentation (installation, testing, usage)

### Phase 2: Production Testing ⏳ (Next)
- ⏳ Test with real-world projects
- ⏳ Validate TDD enforcement effectiveness
- ⏳ Measure quality gate compliance
- ⏳ Gather user feedback and iterate

### Phase 3: Advanced Features (Future)
- 🔮 Add specialized agent windows (architect, quality)
- 🔮 Implement deployment webhooks and E2E triggers
- 🔮 Add Journal MCP integration for cross-session learning
- 🔮 Create agent coordination patterns library

## Contributing

This is an experimental architecture project. Contributions welcome for:

- Testing the architecture with different project types
- Improving TMUX coordination scripts
- Enhancing quality gate enforcement
- Adding new agent coordination patterns

## Credits

**Architecture Design**: Braydon Fuller + Claude Code CLI

**Inspiration**:
- [Claude Code CLI](https://claude.ai/claude-code) by Anthropic
- [obra/superpowers](https://github.com/obra/superpowers) - Agent coordination patterns
- Claude's sub-agent and output style system
- TDD and quality gate best practices

**Related Projects**:
- [claude-workspace](https://github.com/yourusername/claude-workspace) - Modular memory system for Claude Code CLI

## License

MIT License - See LICENSE file for details

## Architectural Questions

This project explores several open questions:

1. **CI/CD Triggers**: Manual vs Git Hooks vs Hybrid?
2. **Agent Persistence**: Long-running vs On-demand vs Hybrid?
3. **Deployment Workflow**: Polling vs Webhooks vs Hybrid?
4. **Error Recovery**: Auto-retry vs Immediate escalation vs Tiered?
5. **State Management**: File-based vs Logs vs Database?

See `TMUX_CLAUDE_CICD_ARCHITECTURE.md` for detailed analysis of each.

## Resources

- [TMUX Manual](https://man.openbsd.org/tmux)
- [Claude Code Documentation](https://docs.claude.com/claude-code)
- Full architecture specification: `TMUX_CLAUDE_CICD_ARCHITECTURE.md`

---

**Status**: ✅ Implementation Complete - Extracted from production, ready for testing

**Version**: 1.0 (October 2025)

**Source**: Extracted from lfw-draftforge-v1 production environment
