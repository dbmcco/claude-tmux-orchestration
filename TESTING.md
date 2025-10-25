# Testing Guide

**Manual testing procedures for Claude TMUX Orchestration**

---

## Automated Tests

### Run All Tests

```bash
./tests/test-tmux-basic.sh
```

Expected output:
```
🧪 Testing Basic TMUX Operations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test 1: Verify tmux is installed...
  ✅ PASS: tmux found (tmux 3.x)
Test 2: Verify scripts exist...
  ✅ PASS: scripts/tmux-spawn-session.sh exists
  ... (all tests pass)
✅ All basic tests passed!
```

---

## Manual Testing Checklist

### Phase 1: Installation Validation

- [ ] Clone repository successfully
- [ ] Run `./setup.sh` without errors
- [ ] Run `./validate-setup.sh` - all checks pass
- [ ] Configuration file created at `config/config.sh`
- [ ] All scripts are executable

### Phase 2: TMUX Session Management

#### Test 1: Create Session

```bash
./scripts/tmux-spawn-session.sh
```

**Expected outcome**:
- Session created successfully
- 3 windows visible (implementer, manager, testing)
- No error messages

**Verification**:
```bash
tmux list-sessions  # Should show your session
tmux list-windows -t <session-name>  # Should show 3 windows
```

#### Test 2: Attach to Session

```bash
./scripts/tmux-spawn-session.sh --attach
```

**Expected outcome**:
- Attached to manager window (window 1)
- Can see initialization messages in each window
- Can switch windows with `Ctrl+b` then `0/1/2`

**Verification**:
- Press `Ctrl+b` then `w` to see all windows
- Navigate between windows using arrow keys

### Phase 3: Orchestration Commands

#### Test 3: Brief Implementer

```bash
./scripts/agent-orchestrator.sh brief "Test task: Write hello world function"
```

**Expected outcome**:
```
📋 Briefing implementer with task...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Task: Test task: Write hello world function
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Implementer briefed
```

**Verification**:
```bash
./scripts/tmux-monitor.sh 0
```

Should show task message in implementer window.

#### Test 4: Monitor Progress

```bash
./scripts/agent-orchestrator.sh monitor 0
```

**Expected outcome**:
- Displays last 50 lines from implementer window
- Shows task briefing message
- No errors

#### Test 5: Validate Quality Gates (without project)

```bash
./scripts/agent-orchestrator.sh validate
```

**Expected outcome**:
- Runs quality-gates.sh
- Shows warnings about missing package.json (if not in a Node project)
- Completes without fatal errors

### Phase 4: Git Hook Integration

#### Test 6: Install Git Hooks

**Prerequisites**: Be in a git repository

```bash
cd /path/to/your/project
git init  # If not already a repo
```

Run setup again and choose to install hooks when prompted.

**Verification**:
```bash
ls -la .git/hooks/pre-commit
ls -la .git/hooks/post-commit
ls -la .claude/hooks/
```

All should exist and be executable.

#### Test 7: Pre-commit Hook

```bash
# Make a change
echo "test" > test.txt
git add test.txt

# Try to commit
git commit -m "test commit"
```

**Expected outcome**:
- Pre-commit hook runs
- Quality gates execute
- If quality gates pass, commit proceeds
- If quality gates fail, commit is blocked

#### Test 8: Post-commit Hook

After successful commit:

**Expected outcome**:
```
📝 Post-commit workflow...
✅ Commit <hash> completed
📄 Message: test commit
🎉 Post-commit workflow completed
```

### Phase 5: Quality Gates

#### Test 9: Quality Gates with Node Project

**Prerequisites**: Have a Node.js project with package.json

```bash
cd /path/to/node/project
./path/to/tmux-orchestration/hooks/quality-gates.sh
```

**Expected outcome**:
```
🚪 Running quality gates...
🔍 Checking project structure...
📝 Running ESLint...
✅ ESLint passed
🔍 Running TypeScript type check...
✅ TypeScript type check passed
🧪 Running tests...
✅ Tests passed
📊 Checking test coverage...
✅ Coverage requirements met
✅ All quality gates passed!
```

#### Test 10: Quality Gates Failure

Intentionally break a test or add a lint error, then run:

```bash
./hooks/quality-gates.sh
```

**Expected outcome**:
- Quality gate fails at appropriate check
- Displays helpful error message
- Suggests fix command (e.g., "npm run lint:fix")
- Exits with error code

### Phase 6: Delegation and Monitoring

#### Test 11: Delegate Command

```bash
./scripts/tmux-delegate.sh 0 "echo 'Hello from manager'"
```

**Expected outcome**:
```
📤 Delegating to implementer (window 0)
📝 Command: echo 'Hello from manager'
✅ Command sent successfully
💡 Monitor output with: scripts/tmux-monitor.sh 0
```

**Verification**:
```bash
./scripts/tmux-monitor.sh 0
```

Should show "Hello from manager" in output.

#### Test 12: Monitor Different Window

```bash
./scripts/tmux-delegate.sh 2 "echo 'Testing window'"
./scripts/tmux-monitor.sh 2
```

**Expected outcome**:
- Message sent to testing window
- Monitor shows correct output from window 2

---

## Performance Testing

### Test 13: Session Creation Time

```bash
time ./scripts/tmux-spawn-session.sh
```

**Expected**: Should complete in < 1 second

### Test 14: Command Delegation Latency

```bash
time ./scripts/tmux-delegate.sh 0 "echo test"
```

**Expected**: Should complete in < 0.5 seconds

### Test 15: Monitor Capture Speed

```bash
time ./scripts/tmux-monitor.sh 0 50
```

**Expected**: Should complete in < 0.5 seconds

---

## Error Handling Tests

### Test 16: Invalid Session Name

```bash
# Temporarily change config to invalid session
./scripts/tmux-spawn-session.sh
```

**Expected**: Clear error message about session existence

### Test 17: Missing Configuration

```bash
mv config/config.sh config/config.sh.backup
./scripts/tmux-spawn-session.sh
```

**Expected outcome**:
```
❌ Configuration file not found: config/config.sh
💡 Copy config/config.sh.example to config/config.sh and customize
```

**Cleanup**:
```bash
mv config/config.sh.backup config/config.sh
```

### Test 18: Invalid Window Number

```bash
./scripts/tmux-delegate.sh 99 "test"
```

**Expected outcome**:
```
❌ Window 99 not found in session '<session-name>'
💡 Available windows:
[list of available windows]
```

---

## Integration Testing

### Test 19: Full TDD Workflow

**Prerequisites**: Node.js project with tests

1. Create session:
   ```bash
   ./scripts/tmux-spawn-session.sh --attach
   ```

2. Brief implementer (from manager window):
   ```bash
   ./scripts/agent-orchestrator.sh brief "Add sum function following TDD"
   ```

3. Monitor progress:
   ```bash
   ./scripts/agent-orchestrator.sh monitor 0
   ```

4. Validate quality:
   ```bash
   ./scripts/agent-orchestrator.sh validate
   ```

5. Commit (if quality passes):
   ```bash
   ./scripts/agent-orchestrator.sh commit "feat: add sum function"
   ```

**Expected outcome**:
- All steps complete successfully
- Commit created with standard format
- Quality gates pass before commit

---

## Rollback Procedures

### If Session Gets Stuck

```bash
tmux kill-session -t <session-name>
./scripts/tmux-spawn-session.sh
```

### If Git Hooks Cause Issues

```bash
# Temporarily disable hooks
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
mv .git/hooks/post-commit .git/hooks/post-commit.disabled

# Make your commit
git commit -m "your message"

# Re-enable hooks
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
mv .git/hooks/post-commit.disabled .git/hooks/post-commit
```

### If Configuration Breaks

```bash
# Reset to example
cp config/config.sh.example config/config.sh

# Re-run setup
./setup.sh
```

---

## Success Criteria

All tests pass if:

- ✅ Automated test suite passes
- ✅ TMUX session creates successfully
- ✅ All 3 windows are functional
- ✅ Commands delegate correctly
- ✅ Monitoring captures output
- ✅ Quality gates execute properly
- ✅ Git hooks work (if installed)
- ✅ No permission errors
- ✅ Error messages are clear and helpful
- ✅ Performance is acceptable (< 1s for session creation)

---

## Reporting Issues

If any test fails, provide:

1. **Test number** that failed
2. **Expected outcome** vs **actual outcome**
3. **Error messages** (full output)
4. **System information**:
   ```bash
   tmux -V
   git --version
   node --version  # If applicable
   uname -a
   ```
5. **Configuration** (sanitized):
   ```bash
   cat config/config.sh
   ```
