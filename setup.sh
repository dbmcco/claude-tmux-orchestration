#!/bin/bash
# ABOUTME: Installation and setup script for Claude TMUX Orchestration

set -e

echo "🚀 Claude TMUX Orchestration Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check for tmux
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found"
    echo "💡 Install with: brew install tmux (macOS) or apt-get install tmux (Linux)"
    exit 1
fi
echo "✅ tmux installed: $(tmux -V)"

# Check for git
if ! command -v git >/dev/null 2>&1; then
    echo "❌ git not found"
    exit 1
fi
echo "✅ git installed: $(git --version | head -1)"

# Check for Node.js (optional but recommended)
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js installed: $(node --version)"
else
    echo "⚠️  Node.js not found (optional - needed for JavaScript projects)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Configuration Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Prompt for project configuration
read -p "Enter project name [default: my-project]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-my-project}

read -p "Enter project root path [default: $(pwd)]: " PROJECT_ROOT
PROJECT_ROOT=${PROJECT_ROOT:-$(pwd)}

# Expand tilde in path
PROJECT_ROOT="${PROJECT_ROOT/#\~/$HOME}"

# Validate project root exists
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "❌ Project root does not exist: $PROJECT_ROOT"
    read -p "Create directory? (y/n): " CREATE_DIR
    if [ "$CREATE_DIR" = "y" ]; then
        mkdir -p "$PROJECT_ROOT"
        echo "✅ Created directory: $PROJECT_ROOT"
    else
        exit 1
    fi
fi

# Generate configuration file
CONFIG_FILE="${SCRIPT_DIR}/config/config.sh"

echo ""
echo "📄 Creating configuration file: $CONFIG_FILE"

cat > "$CONFIG_FILE" <<EOF
#!/bin/bash
# ABOUTME: Configuration for Claude TMUX Orchestration (auto-generated)
# Generated: $(date)

# Project Configuration
PROJECT_NAME="$PROJECT_NAME"
PROJECT_ROOT="$PROJECT_ROOT"

# TMUX Configuration
TMUX_SESSION_NAME="\${PROJECT_NAME}-dev"
TMUX_IMPLEMENTER_WINDOW="0"
TMUX_MANAGER_WINDOW="1"
TMUX_TESTING_WINDOW="2"

# Quality Gate Configuration
ENABLE_ESLINT=true
ENABLE_TYPESCRIPT=true
ENABLE_TESTS=true
ENABLE_COVERAGE=true

# Coverage Thresholds
COVERAGE_THRESHOLD=80

# NPM Scripts (customize to match your package.json)
LINT_SCRIPT="lint"
TYPE_CHECK_SCRIPT="type-check"
TEST_SCRIPT="test"
COVERAGE_SCRIPT="test:coverage"

# Git Configuration
AUTO_COMMIT=false
COMMIT_MESSAGE_PREFIX="🤖"

# Journal MCP Configuration (optional)
ENABLE_JOURNAL_MCP=false
JOURNAL_MCP_PATH=""

# Claude Configuration
CLAUDE_CLI_PATH="claude"

# Deployment Configuration (optional)
DEPLOYMENT_URL=""
ENABLE_E2E_TESTS=false
EOF

chmod +x "$CONFIG_FILE"
echo "✅ Configuration file created"

# Make scripts executable
echo ""
echo "🔧 Setting script permissions..."
chmod +x "${SCRIPT_DIR}/hooks/"*.sh 2>/dev/null || true
chmod +x "${SCRIPT_DIR}/scripts/"*.sh 2>/dev/null || true
echo "✅ Script permissions set"

# Optional: Install git hooks
echo ""
read -p "Install git hooks in project? (y/n): " INSTALL_HOOKS
if [ "$INSTALL_HOOKS" = "y" ]; then
    if [ -d "$PROJECT_ROOT/.git" ]; then
        GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

        # Create .claude directory if it doesn't exist
        mkdir -p "$PROJECT_ROOT/.claude/hooks"

        # Copy hooks to project
        cp "${SCRIPT_DIR}/hooks/pre-commit.sh" "$PROJECT_ROOT/.claude/hooks/"
        cp "${SCRIPT_DIR}/hooks/post-commit.sh" "$PROJECT_ROOT/.claude/hooks/"
        cp "${SCRIPT_DIR}/hooks/quality-gates.sh" "$PROJECT_ROOT/.claude/hooks/"

        # Link hooks to git
        ln -sf "$PROJECT_ROOT/.claude/hooks/pre-commit.sh" "$GIT_HOOKS_DIR/pre-commit"
        ln -sf "$PROJECT_ROOT/.claude/hooks/post-commit.sh" "$GIT_HOOKS_DIR/post-commit"

        chmod +x "$PROJECT_ROOT/.claude/hooks/"*.sh
        chmod +x "$GIT_HOOKS_DIR/pre-commit"
        chmod +x "$GIT_HOOKS_DIR/post-commit"

        echo "✅ Git hooks installed in $PROJECT_ROOT"
    else
        echo "⚠️  $PROJECT_ROOT is not a git repository"
        echo "💡 Initialize git first with: cd $PROJECT_ROOT && git init"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Review configuration:"
echo "   cat config/config.sh"
echo ""
echo "2. Create tmux session:"
echo "   ./scripts/tmux-spawn-session.sh --attach"
echo ""
echo "3. Use orchestration commands:"
echo "   ./scripts/agent-orchestrator.sh brief 'Implement feature X'"
echo "   ./scripts/agent-orchestrator.sh monitor 0"
echo "   ./scripts/agent-orchestrator.sh validate"
echo "   ./scripts/agent-orchestrator.sh commit 'feat: add feature X'"
echo ""
echo "4. Read documentation:"
echo "   cat README.md"
echo "   cat INSTALLATION.md"
echo ""
echo "🎉 Ready to orchestrate Claude agents via TMUX!"
echo ""
