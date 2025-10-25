# TMUX + Claude Code CLI: Multi-Agent CI/CD Architecture

**Project**: DraftForge V1 (lfw-draftforge-v1)
**Purpose**: Document TMUX-based multi-agent orchestration for CI/CD with Claude Code CLI and Codex
**Status**: Experimental - Testing prompt model before implementation
**Created**: October 8, 2025

---

## Executive Summary

This document outlines an architecture where **Claude Code CLI (Prime)** acts as a project manager coordinating specialized sub-agents (Codex, Claude Code CLI instances) running in dedicated TMUX windows. The system enables:

- **TDD-enforced development** with RED→GREEN→REFACTOR cycle
- **Quality gate automation** (ESLint, TypeScript, test coverage, E2E)
- **CI/CD integration** via git hooks and Vercel deployment monitoring
- **Human-in-the-loop** at critical decision points

**Key Innovation**: Claude Code CLI delegates to specialized sub-agents via TMUX, monitoring their progress and enforcing strict quality standards before allowing commits and deployments.

---

## Current Implementation (DraftForge V1)

### **TMUX Architecture**

```
MacBook Air (Development Machine)
└── tmux session: lfw
    ├── window 0: implementer (Codex or Claude Code CLI)
    │   └── Role: Write tests, implement code, follow TDD
    │
    ├── window 1: manager (Claude Code CLI Prime - YOU)
    │   └── Role: Coordinate agents, enforce quality gates, manage git
    │
    └── window 2: e2e-testing (Claude Code CLI - Testing Manager)
        └── Role: Run Playwright tests on Vercel deployments
```

### **Agent Roles & Responsibilities**

#### **Window 0: Implementer Agent**
- Follows strict TDD: RED → GREEN → REFACTOR
- Writes failing tests first, then minimal implementation
- Runs quality checks before requesting commit approval
- **Tools**: Read, Write, Edit, Bash, TodoWrite
- **Constraints**: Cannot commit without Manager approval

#### **Window 1: Manager Claude (Prime)**
- Confers with Braydon on session priorities
- Briefs implementer agents with clear TDD requirements
- Monitors progress via `tmux capture-pane` every 30-60 seconds
- Enforces quality gates before every commit
- Coordinates E2E testing after deployments
- **Tools**: Bash (tmux commands), Read (monitoring), Write (logs)
- **Constraints**: Does NOT write code directly - only coordinates

#### **Window 2: Testing Manager**
- Dedicated Playwright E2E testing agent
- Runs smoke tests before deployments
- Validates production deployments on Vercel
- Reports performance regressions
- **Tools**: Bash (npm test:e2e), Read (test files)
- **Scope**: 123 E2E tests across 9 test files

### **Workflow Example**

```bash
# 1. Manager briefs implementer
tmux send-keys -t lfw:0 "Task: Implement user authentication following TDD..." Enter

# 2. Manager monitors progress
tmux capture-pane -t lfw:0 -p | tail -50

# 3. Implementer requests commit (after quality:check passes)
# Manager validates quality gates output

# 4. Manager executes commit
git add .
git commit -m "feat: user authentication

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin main

# 5. Manager briefs testing agent (after 60-90s for Vercel)
tmux send-keys -t lfw:2 "Run E2E tests on production..." Enter

# 6. Manager monitors E2E results
tmux capture-pane -t lfw:2 -p | tail -100

# 7. Manager reports to Braydon
# "✅ Deployment validated. E2E tests: 13/13 passed."
```

---

## Quality Gate Enforcement

### **Mandatory Before Every Commit**

```bash
npm run quality:check
```

**What it runs:**
1. **ESLint**: `npm run lint` → Must be 0 errors, 0 warnings
2. **TypeScript**: `npm run type-check` → Must be 0 errors (strict mode)
3. **Jest Tests**: `npm test` → All tests must pass
4. **Coverage**: `npm run test:coverage` → Must be >80%

**Manager's Role:**
- Reviews full `quality:check` output from implementer
- Only approves commit if all 4 gates pass
- If ANY gate fails: blocks commit, instructs implementer to fix

### **TDD Cycle Enforcement**

Manager strictly enforces:

**RED Phase:**
```
Manager: "Write a failing test for [feature]. Show me RED output."
Implementer: [writes test, runs it, shows failure]
Manager: [validates test fails for correct reason] "Proceed to GREEN."
```

**GREEN Phase:**
```
Manager: "Implement minimal code to make test pass. Show me GREEN."
Implementer: [writes code, runs test, shows pass]
Manager: [validates test passes] "Proceed to REFACTOR if needed."
```

**REFACTOR Phase:**
```
Manager: "Refactor for clarity. Ensure tests stay GREEN."
Implementer: [improves code, reruns tests]
Manager: [validates tests still pass] "Run quality:check."
```

**Intervention Protocol:**
- If implementer writes code before test → **STOP IMMEDIATELY**
- If implementer wants to commit without quality:check → **BLOCK**
- If implementer suggests mocking database → **REFUSE (core principle)**

---

## Proposed `.claude/hooks/` Integration

### **Directory Structure**

```
lfw-draftforge-v1/.claude/
├── hooks/
│   ├── pre-commit.sh              # Existing - quality gates
│   ├── post-commit.sh             # Existing - notifications
│   ├── quality-gates.sh           # Existing - comprehensive checks
│   ├── pre-push.sh                # NEW - TMUX orchestration trigger
│   ├── post-deployment.sh         # NEW - Vercel webhook handler
│   └── agent-orchestrator.sh      # NEW - Core TMUX coordination
│
├── agents/
│   ├── architect.md               # Existing
│   ├── implementer.md             # Existing
│   ├── quality.md                 # Existing
│   ├── git.md                     # Existing
│   ├── manager.md                 # NEW - MANAGER_CONTINUATION.md
│   └── testing-manager.md         # NEW - TESTING_MANAGER_PROMPT.md
│
└── scripts/
    ├── tmux-spawn-implementer.sh  # NEW - Spawn implementer window
    ├── tmux-spawn-testing.sh      # NEW - Spawn testing window
    ├── tmux-monitor.sh            # NEW - Progress monitoring loop
    ├── tmux-agent-status.sh       # NEW - Agent health checks
    └── vercel-wait-deploy.sh      # NEW - Poll for deployment completion
```

### **Hook Integration Points**

#### **1. pre-push.sh (Git Hook)**

```bash
#!/bin/bash
# Triggered: Before git push
# Purpose: Ensure TMUX session exists and quality gates passed

# Check if TMUX session exists
if ! tmux has-session -t lfw 2>/dev/null; then
    echo "🚀 Spawning TMUX agent session..."
    .claude/scripts/tmux-spawn-session.sh
fi

# Verify quality gates passed (redundant check)
if ! .claude/hooks/quality-gates.sh; then
    echo "❌ Quality gates failed. Fix issues before pushing."
    exit 1
fi

echo "✅ Quality gates passed. Proceeding with push..."
```

#### **2. post-deployment.sh (Vercel Webhook)**

```bash
#!/bin/bash
# Triggered: Vercel deployment webhook or polling
# Purpose: Spawn Testing Manager to validate production

# Wait for Vercel deployment to be ready
.claude/scripts/vercel-wait-deploy.sh

# Send E2E test command to testing window
tmux send-keys -t lfw:2 "npm run test:e2e:prod" Enter

# Monitor for results
.claude/scripts/tmux-monitor.sh lfw:2 "test:e2e:prod"
```

#### **3. agent-orchestrator.sh (Core Logic)**

```bash
#!/bin/bash
# Purpose: Core TMUX agent coordination logic

function brief_implementer() {
    local task_description="$1"
    tmux send-keys -t lfw:0 "$task_description" Enter
}

function monitor_progress() {
    local window="$1"
    tmux capture-pane -t "$window" -p | tail -50
}

function check_quality_gates() {
    # Parse implementer output for quality:check results
    local output=$(tmux capture-pane -t lfw:0 -p | tail -100)

    if echo "$output" | grep -q "✅.*ESLint.*0 warnings"; then
        return 0
    else
        return 1
    fi
}

function coordinate_commit() {
    if check_quality_gates; then
        echo "✅ Quality gates passed. Executing commit..."
        # Manager executes git commit with proper attribution
        git commit -m "feat: $1

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
    else
        echo "❌ Quality gates failed. Blocking commit."
        return 1
    fi
}
```

---

## Architectural Questions (Open for Testing)

### **1. CI/CD Trigger Points**

**Options:**
- **A. Manual Only**: Triggered by commands like `/deploy`, `/test`
- **B. Git Hooks**: Automatic on pre-push, post-merge
- **C. Hybrid**: Manual for dev, automatic for main branch

**Testing Priority**: Start with **Manual (A)**, validate prompt behavior

### **2. Agent Persistence**

**Options:**
- **A. Long-running**: Agents stay alive between tasks
- **B. On-demand**: Spawn/kill per task
- **C. Hybrid**: Manager persists, workers spawn on-demand

**Testing Priority**: Current implementation uses **Long-running (A)**

### **3. Deployment Workflow**

**Options:**
- **A. Polling**: Current approach (wait 60-90s, poll Vercel)
- **B. Webhooks**: Vercel webhook → instant E2E trigger
- **C. Hybrid**: Webhooks primary, polling fallback

**Testing Priority**: Test **Polling (A)** first (already implemented)

### **4. Error Recovery**

**Options:**
- **A. Auto-retry**: Manager retries with refined instructions (max 3 attempts)
- **B. Immediate escalation**: All failures escalate to Braydon
- **C. Tiered**: Auto-retry linting/tests, escalate architectural issues

**Testing Priority**: Current uses **Immediate escalation (B)**

### **5. State Management**

**Options:**
- **A. File-based**: `.claude/status/*.json` for agent state
- **B. Logs**: Simple `.claude/logs/*.log` files
- **C. Database**: SQLite for structured state tracking

**Testing Priority**: Test with **Logs (B)** first (simplest)

---

## Testing Protocol

### **Phase 1: Validate Manager Prompt** (Current Focus)

**Objective**: Test MANAGER_CONTINUATION.md prompt in real workflow

**Test Cases:**

1. **Session Start Protocol**
   - Manager reviews SESSION_HANDOFF.md
   - Manager confers with Braydon on priorities
   - Manager briefs implementer with TDD requirements
   - **Success Criteria**: Clear prioritization dialogue before any work

2. **TDD Enforcement**
   - Manager enforces RED → GREEN → REFACTOR
   - Manager blocks implementation-before-test attempts
   - Manager validates each phase before proceeding
   - **Success Criteria**: 100% TDD compliance, no shortcuts

3. **Quality Gate Validation**
   - Manager reviews quality:check output
   - Manager blocks commits on any failures
   - Manager only approves after clean gates
   - **Success Criteria**: 0 commits with warnings/errors

4. **TMUX Coordination**
   - Manager monitors implementer via `tmux capture-pane`
   - Manager sends commands via `tmux send-keys`
   - Manager tracks progress every 30-60 seconds
   - **Success Criteria**: Smooth TMUX communication, no hangs

5. **E2E Deployment Testing**
   - Manager waits for Vercel deployment
   - Manager briefs testing agent
   - Manager monitors E2E results
   - Manager reports pass/fail to Braydon
   - **Success Criteria**: Reliable post-deployment validation

### **Phase 2: Integrate with Git Hooks** (Future)

After validating manager prompt:
- Implement `pre-push.sh` TMUX spawning
- Implement `post-deployment.sh` E2E triggering
- Test full CI/CD cycle end-to-end

### **Phase 3: Scale to Multiple Agents** (Future)

- Add specialized agents (architect, quality) in dedicated windows
- Test parallel agent coordination
- Validate complex multi-agent workflows

---

## Success Metrics

### **For Manager Prompt Testing:**

- ✅ **Prioritization**: Manager confers with Braydon before work starts
- ✅ **TDD Compliance**: 100% RED→GREEN→REFACTOR adherence
- ✅ **Quality Gates**: 0 commits with ESLint/TypeScript errors
- ✅ **TMUX Stability**: No communication failures or hangs
- ✅ **E2E Validation**: Reliable post-deployment testing

### **For CI/CD Integration:**

- ✅ **Automation**: Hooks trigger TMUX orchestration automatically
- ✅ **Reliability**: 95%+ successful deployments with E2E validation
- ✅ **Performance**: <5 minute cycle time (commit → deployed → validated)
- ✅ **Error Recovery**: Clear escalation paths when agents fail

---

## Key Implementation Files

### **Current Working Prompts:**
- `/lfw-draftforge-v1/docs/MANAGER_CONTINUATION.md` - Manager Claude prompt
- `/lfw-draftforge-v1/docs/testing/TESTING_MANAGER_PROMPT.md` - Testing agent prompt

### **Architecture Documents:**
- `/lfw-draftforge-v1/docs/AI_DEVELOPMENT_PIPELINE_SPEC.md` - Full AI pipeline
- `/lfw-draftforge-v1/docs/specifications/AGENT_SPECIFICATIONS.md` - 17+ agent specs
- `/lfw-draftforge-v1/docs/specifications/TDD_AUTOMATION_VISION.md` - End-state vision

### **Existing Infrastructure:**
- `.claude/hooks/quality-gates.sh` - Quality validation script
- `scripts/get-vercel-url.sh` - Deployment URL retrieval
- `playwright.config.ts` - E2E test configuration

---

## Next Steps

### **Immediate (Testing Phase):**

1. ✅ **Document architecture** (this file)
2. ⏳ **Exercise manager prompt** with real tasks
3. ⏳ **Validate TDD enforcement** in practice
4. ⏳ **Test TMUX coordination** reliability
5. ⏳ **Measure success metrics** against criteria

### **Short-term (Hook Integration):**

1. Implement `pre-push.sh` TMUX session spawning
2. Implement `post-deployment.sh` E2E triggering
3. Create agent monitoring scripts (`tmux-monitor.sh`)
4. Add state tracking (`.claude/logs/`)

### **Long-term (Full Orchestration):**

1. Multi-agent parallel coordination
2. Vercel webhook integration
3. Auto-retry with refined instructions
4. Advanced error recovery strategies

---

## Open Questions

### **For Prompt Testing:**

- How does Manager handle ambiguous priorities from Braydon?
- Does Manager effectively enforce TDD without being heavy-handed?
- Are TMUX monitoring intervals (30-60s) optimal?
- How does Manager handle implementer getting stuck?

### **For CI/CD Integration:**

- Should hooks spawn TMUX sessions or require pre-existing?
- What's the right balance of automation vs human control?
- How to handle network failures during Vercel polling?
- Should we log all agent communications for debugging?

### **For Multi-Agent Scaling:**

- How many concurrent TMUX windows can we manage effectively?
- Should agents communicate with each other or only via Manager?
- How to prevent resource conflicts (file locks, git operations)?
- What's the optimal agent → task mapping strategy?

---

## References

### **Related Projects:**
- [claude-workspace](../../claude-workspace) - Modular memory system
- [lfw-draftforge-v1](../../work/lfw/lfw-draftforge-v1) - Implementation project

### **Claude Code Documentation:**
- [Agent System](https://docs.claude.com/claude-code/agents)
- [Hook Integration](https://docs.claude.com/claude-code/hooks)
- [TMUX Workflows](https://docs.claude.com/claude-code/tmux)

### **TMUX Resources:**
- `man tmux` - TMUX manual
- `tmux list-commands` - Available commands
- `tmux capture-pane` - Output monitoring

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-10-08 | 1.0 | Initial architecture documentation | Braydon + Claude Code |

---

**Status**: Ready for prompt testing. This document will be updated as we validate the manager prompt and refine the architecture based on real-world behavior.
