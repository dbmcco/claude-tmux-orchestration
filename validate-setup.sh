#!/bin/bash
# ABOUTME: Validates Claude TMUX Orchestration installation and configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=0
WARNINGS=0

echo "🔍 Claude TMUX Orchestration Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
echo "📦 Prerequisites:"
echo ""

# Check tmux
if command -v tmux >/dev/null 2>&1; then
    echo "  ✅ tmux: $(tmux -V)"
else
    echo "  ❌ tmux: NOT FOUND"
    ((ERRORS++))
fi

# Check git
if command -v git >/dev/null 2>&1; then
    echo "  ✅ git: $(git --version | head -1)"
else
    echo "  ❌ git: NOT FOUND"
    ((ERRORS++))
fi

# Check Node.js (optional)
if command -v node >/dev/null 2>&1; then
    echo "  ✅ Node.js: $(node --version)"
else
    echo "  ⚠️  Node.js: NOT FOUND (optional)"
    ((WARNINGS++))
fi

# Check npm (optional)
if command -v npm >/dev/null 2>&1; then
    echo "  ✅ npm: $(npm --version)"
else
    echo "  ⚠️  npm: NOT FOUND (optional)"
    ((WARNINGS++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Directory Structure:"
echo ""

# Check directories
DIRS=("hooks" "scripts" "config" "tests")
for dir in "${DIRS[@]}"; do
    if [ -d "${SCRIPT_DIR}/$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ NOT FOUND"
        ((ERRORS++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Configuration:"
echo ""

# Check configuration file
CONFIG_FILE="${SCRIPT_DIR}/config/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    echo "  ✅ config/config.sh exists"

    # Source and validate configuration
    source "$CONFIG_FILE"

    # Validate required variables
    if [ -n "$PROJECT_NAME" ]; then
        echo "  ✅ PROJECT_NAME: $PROJECT_NAME"
    else
        echo "  ❌ PROJECT_NAME not set"
        ((ERRORS++))
    fi

    if [ -n "$PROJECT_ROOT" ]; then
        if [ -d "$PROJECT_ROOT" ]; then
            echo "  ✅ PROJECT_ROOT: $PROJECT_ROOT (exists)"
        else
            echo "  ⚠️  PROJECT_ROOT: $PROJECT_ROOT (does not exist)"
            ((WARNINGS++))
        fi
    else
        echo "  ❌ PROJECT_ROOT not set"
        ((ERRORS++))
    fi

    if [ -n "$TMUX_SESSION_NAME" ]; then
        echo "  ✅ TMUX_SESSION_NAME: $TMUX_SESSION_NAME"
    else
        echo "  ❌ TMUX_SESSION_NAME not set"
        ((ERRORS++))
    fi
else
    echo "  ❌ config/config.sh NOT FOUND"
    echo "  💡 Run setup.sh to create configuration"
    ((ERRORS++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Scripts:"
echo ""

# Check hook scripts
HOOKS=("quality-gates.sh" "pre-commit.sh" "post-commit.sh")
for hook in "${HOOKS[@]}"; do
    HOOK_PATH="${SCRIPT_DIR}/hooks/$hook"
    if [ -f "$HOOK_PATH" ]; then
        if [ -x "$HOOK_PATH" ]; then
            echo "  ✅ hooks/$hook (executable)"
        else
            echo "  ⚠️  hooks/$hook (not executable)"
            ((WARNINGS++))
        fi
    else
        echo "  ❌ hooks/$hook NOT FOUND"
        ((ERRORS++))
    fi
done

# Check orchestration scripts
SCRIPTS=("tmux-spawn-session.sh" "tmux-monitor.sh" "tmux-delegate.sh" "agent-orchestrator.sh")
for script in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="${SCRIPT_DIR}/scripts/$script"
    if [ -f "$SCRIPT_PATH" ]; then
        if [ -x "$SCRIPT_PATH" ]; then
            echo "  ✅ scripts/$script (executable)"
        else
            echo "  ⚠️  scripts/$script (not executable)"
            ((WARNINGS++))
        fi
    else
        echo "  ❌ scripts/$script NOT FOUND"
        ((ERRORS++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 TMUX Sessions:"
echo ""

# Check for active tmux sessions
if command -v tmux >/dev/null 2>&1; then
    if tmux list-sessions >/dev/null 2>&1; then
        echo "  Active sessions:"
        tmux list-sessions | while read -r line; do
            echo "    - $line"
        done
    else
        echo "  ℹ️  No active tmux sessions"
    fi
else
    echo "  ⚠️  Cannot check sessions (tmux not available)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary:"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "  ✅ All checks passed - system ready!"
    echo ""
    echo "  Next steps:"
    echo "    1. ./scripts/tmux-spawn-session.sh --attach"
    echo "    2. ./scripts/agent-orchestrator.sh brief 'Your task'"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "  ⚠️  Passed with $WARNINGS warning(s)"
    echo ""
    echo "  System is operational but some optional components are missing."
    exit 0
else
    echo "  ❌ Failed with $ERRORS error(s) and $WARNINGS warning(s)"
    echo ""
    echo "  Please fix errors before using the system."
    echo "  Run ./setup.sh to configure the system."
    exit 1
fi
