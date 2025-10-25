## Installation Guide

**Complete step-by-step installation instructions for Claude TMUX Orchestration**

---

### Prerequisites

Before installing, ensure you have:

1. **TMUX** - Terminal multiplexer
   ```bash
   # macOS
   brew install tmux

   # Linux (Ubuntu/Debian)
   sudo apt-get install tmux

   # Linux (Fedora/RHEL)
   sudo dnf install tmux
   ```

2. **Git** - Version control
   ```bash
   git --version  # Should show git version
   ```

3. **Node.js** (optional, for JavaScript/TypeScript projects)
   ```bash
   node --version  # Should show Node version
   npm --version   # Should show npm version
   ```

4. **Claude Code CLI** (optional, for AI agent integration)
   ```bash
   claude --version  # Should show Claude CLI version
   ```

---

### Installation Steps

#### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/tmux-agent-orchestration.git
cd tmux-agent-orchestration
```

#### Step 2: Run Setup Script

The interactive setup script will guide you through configuration:

```bash
./setup.sh
```

You'll be prompted for:
- **Project name**: Your project identifier (e.g., "my-app")
- **Project root path**: Absolute path to your project directory
- **Git hooks installation**: Whether to install hooks in your project

#### Step 3: Verify Installation

Validate the setup completed successfully:

```bash
./validate-setup.sh
```

Expected output:
```
✅ All checks passed - system ready!
```

---

### Manual Configuration (Alternative)

If you prefer manual setup:

#### 1. Create Configuration File

```bash
cp config/config.sh.example config/config.sh
```

#### 2. Edit Configuration

Open `config/config.sh` and customize:

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

#### 3. Make Scripts Executable

```bash
chmod +x hooks/*.sh
chmod +x scripts/*.sh
chmod +x setup.sh
chmod +x validate-setup.sh
```

#### 4. Install Git Hooks (Optional)

```bash
# Create .claude directory in your project
mkdir -p /path/to/your/project/.claude/hooks

# Copy hooks
cp hooks/*.sh /path/to/your/project/.claude/hooks/

# Link to git hooks
ln -sf /path/to/your/project/.claude/hooks/pre-commit.sh /path/to/your/project/.git/hooks/pre-commit
ln -sf /path/to/your/project/.claude/hooks/post-commit.sh /path/to/your/project/.git/hooks/post-commit

# Make executable
chmod +x /path/to/your/project/.claude/hooks/*.sh
chmod +x /path/to/your/project/.git/hooks/pre-commit
chmod +x /path/to/your/project/.git/hooks/post-commit
```

---

### Testing the Installation

#### 1. Run Basic Tests

```bash
./tests/test-tmux-basic.sh
```

Expected output:
```
✅ All basic tests passed!
```

#### 2. Create Test TMUX Session

```bash
./scripts/tmux-spawn-session.sh --attach
```

You should see 3 windows:
- Window 0: implementer
- Window 1: manager
- Window 2: testing

Use `Ctrl+b` then `w` to see all windows, or `Ctrl+b` then `0/1/2` to switch between them.

#### 3. Test Orchestration Commands

From the manager window (window 1):

```bash
# Brief the implementer
./scripts/agent-orchestrator.sh brief "Test task"

# Monitor implementer progress
./scripts/agent-orchestrator.sh monitor 0

# Run quality gates
./scripts/agent-orchestrator.sh validate
```

---

### Project Integration

To use Claude TMUX Orchestration in your project:

#### 1. Update package.json Scripts

Add these scripts to your `package.json`:

```json
{
  "scripts": {
    "lint": "eslint src --max-warnings 0",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:coverage": "jest --coverage --coverageThreshold='{\"global\":{\"lines\":80}}'",
    "quality:check": "npm run lint && npm run type-check && npm test && npm run test:coverage"
  }
}
```

#### 2. Configure ESLint (if using)

Create `.eslintrc.json`:

```json
{
  "extends": ["eslint:recommended"],
  "parserOptions": {
    "ecmaVersion": 2021,
    "sourceType": "module"
  },
  "env": {
    "node": true,
    "es2021": true
  }
}
```

#### 3. Configure TypeScript (if using)

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

### Verification Checklist

After installation, verify:

- [ ] `./validate-setup.sh` passes all checks
- [ ] `./tests/test-tmux-basic.sh` passes all tests
- [ ] `./scripts/tmux-spawn-session.sh` creates session successfully
- [ ] Configuration file exists at `config/config.sh`
- [ ] All scripts are executable (`ls -la hooks/` and `ls -la scripts/`)
- [ ] Git hooks are linked (if installed): `ls -la /path/to/project/.git/hooks/`

---

### Troubleshooting

#### Issue: "tmux not found"

**Solution**: Install tmux using your package manager:
```bash
# macOS
brew install tmux

# Linux
sudo apt-get install tmux
```

#### Issue: "Session already exists"

**Solution**: Kill existing session:
```bash
tmux kill-session -t your-session-name
```

Or attach to existing session:
```bash
tmux attach-session -t your-session-name
```

#### Issue: "Permission denied" when running scripts

**Solution**: Make scripts executable:
```bash
chmod +x hooks/*.sh scripts/*.sh
```

#### Issue: "Config file not found"

**Solution**: Run setup script:
```bash
./setup.sh
```

Or copy example config:
```bash
cp config/config.sh.example config/config.sh
```

#### Issue: Quality gates fail in pre-commit hook

**Solution**: Run quality checks manually to see errors:
```bash
./hooks/quality-gates.sh
```

Fix reported issues, then commit again.

---

### Next Steps

After successful installation:

1. **Read Documentation**
   - `README.md` - Overview and architecture
   - `TMUX_CLAUDE_CICD_ARCHITECTURE.md` - Detailed architecture

2. **Try Example Workflow**
   - Create tmux session: `./scripts/tmux-spawn-session.sh --attach`
   - Brief implementer: `./scripts/agent-orchestrator.sh brief "Add README file"`
   - Monitor progress: `./scripts/agent-orchestrator.sh monitor`
   - Validate quality: `./scripts/agent-orchestrator.sh validate`

3. **Customize Configuration**
   - Edit `config/config.sh` to match your project
   - Update npm scripts in `package.json`
   - Configure quality gates as needed

---

### Uninstallation

To remove Claude TMUX Orchestration:

```bash
# Remove configuration
rm config/config.sh

# Remove git hooks (if installed)
rm /path/to/project/.git/hooks/pre-commit
rm /path/to/project/.git/hooks/post-commit
rm -rf /path/to/project/.claude/hooks

# Kill any running tmux sessions
tmux kill-session -t your-session-name

# Remove repository
cd ..
rm -rf tmux-agent-orchestration
```

---

### Getting Help

If you encounter issues:

1. Check troubleshooting section above
2. Run `./validate-setup.sh` to diagnose problems
3. Review configuration in `config/config.sh`
4. Open an issue on GitHub with error messages and system info
