# Claude TMUX Orchestration

**Multi-agent AI development orchestration using TMUX and Claude Code CLI**

This project documents an architecture for coordinating multiple Claude Code CLI and Codex instances via TMUX for automated, TDD-enforced development workflows. The system enables Claude to act as a project manager, delegating tasks to specialized sub-agents running in dedicated TMUX windows while maintaining strict quality gates.

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

### Prerequisites

- TMUX installed (`brew install tmux` on macOS)
- Claude Code CLI configured
- Git repository with quality gate scripts

### Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/claude-tmux-orchestration.git
cd claude-tmux-orchestration
```

2. Review the architecture documentation:
```bash
cat TMUX_CLAUDE_CICD_ARCHITECTURE.md
```

3. Set up your project with quality gates:
```bash
# Example package.json scripts
{
  "scripts": {
    "quality:check": "npm run lint && npm run type-check && npm test && npm run test:coverage",
    "lint": "eslint src --max-warnings 0",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:coverage": "jest --coverage --coverageThreshold='{\"global\":{\"lines\":80}}'"
  }
}
```

## Usage

### Manual Workflow (Current Implementation)

1. **Start TMUX session**:
```bash
tmux new-session -s project
tmux new-window -t project:1 -n manager
tmux new-window -t project:2 -n testing
```

2. **Initialize agents in each window**:
- Window 0: Start implementer Claude/Codex session
- Window 1: Start manager Claude Code CLI (this becomes the coordinator)
- Window 2: Start testing Claude Code CLI

3. **Manager coordinates development**:
```bash
# From window 1 (manager)
tmux send-keys -t project:0 "Implement feature X following TDD" Enter

# Monitor progress
tmux capture-pane -t project:0 -p | tail -50
```

### Proposed Git Hook Integration (Future)

The architecture document outlines future `.claude/hooks/` integration:

- `pre-push.sh`: Spawn TMUX session, verify quality gates
- `post-deployment.sh`: Trigger E2E tests on deployment
- `agent-orchestrator.sh`: Core TMUX coordination logic

See `TMUX_CLAUDE_CICD_ARCHITECTURE.md` for complete integration specs.

## Configuration

### Project Structure (Proposed)

```
your-project/
├── .claude/
│   ├── hooks/
│   │   ├── pre-commit.sh
│   │   ├── pre-push.sh
│   │   ├── post-deployment.sh
│   │   └── agent-orchestrator.sh
│   │
│   ├── agents/
│   │   ├── manager.md
│   │   ├── implementer.md
│   │   └── testing-manager.md
│   │
│   └── scripts/
│       ├── tmux-spawn-implementer.sh
│       ├── tmux-spawn-testing.sh
│       └── tmux-monitor.sh
│
└── package.json (with quality gate scripts)
```

### Quality Gate Script Example

```bash
#!/bin/bash
# .claude/hooks/quality-gates.sh

echo "🔍 Running quality gates..."

npm run lint || exit 1
npm run type-check || exit 1
npm test || exit 1
npm run test:coverage || exit 1

echo "✅ All quality gates passed"
```

## Testing Status

### Current Phase: Prompt Testing

- ✅ Architecture documented
- ⏳ Testing manager prompt behavior
- ⏳ Validating TDD enforcement
- ⏳ Measuring TMUX coordination reliability

### Success Metrics

- ✅ **Prioritization**: Manager confers with developer before work starts
- ✅ **TDD Compliance**: 100% RED→GREEN→REFACTOR adherence
- ✅ **Quality Gates**: 0 commits with ESLint/TypeScript errors
- ✅ **TMUX Stability**: No communication failures or hangs
- ✅ **E2E Validation**: Reliable post-deployment testing

## Roadmap

### Phase 1: Validate Manager Prompt (Current)
- Test TMUX coordination in real workflows
- Validate TDD enforcement effectiveness
- Measure quality gate compliance

### Phase 2: Integrate with Git Hooks
- Implement `pre-push.sh` TMUX session spawning
- Implement `post-deployment.sh` E2E triggering
- Add agent monitoring scripts

### Phase 3: Scale to Multiple Agents
- Add specialized agents (architect, quality) in dedicated windows
- Test parallel agent coordination
- Validate complex multi-agent workflows

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

**Status**: Experimental architecture - Ready for prompt testing and validation

**Version**: 1.0 (October 2025)
