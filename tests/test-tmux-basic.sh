#!/bin/bash
# ABOUTME: Basic tmux operations testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

echo "🧪 Testing Basic TMUX Operations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Check tmux is available
echo "Test 1: Verify tmux is installed..."
if command -v tmux >/dev/null 2>&1; then
    echo "  ✅ PASS: tmux found ($(tmux -V))"
else
    echo "  ❌ FAIL: tmux not found"
    exit 1
fi

# Test 2: Check scripts exist
echo ""
echo "Test 2: Verify scripts exist..."
SCRIPTS=(
    "scripts/tmux-spawn-session.sh"
    "scripts/tmux-monitor.sh"
    "scripts/tmux-delegate.sh"
    "scripts/agent-orchestrator.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "${PROJECT_ROOT}/$script" ]; then
        echo "  ✅ PASS: $script exists"
    else
        echo "  ❌ FAIL: $script not found"
        exit 1
    fi
done

# Test 3: Check scripts are executable
echo ""
echo "Test 3: Verify scripts are executable..."
for script in "${SCRIPTS[@]}"; do
    if [ -x "${PROJECT_ROOT}/$script" ]; then
        echo "  ✅ PASS: $script is executable"
    else
        echo "  ❌ FAIL: $script is not executable"
        exit 1
    fi
done

# Test 4: Verify configuration example exists
echo ""
echo "Test 4: Verify configuration template..."
if [ -f "${PROJECT_ROOT}/config/config.sh.example" ]; then
    echo "  ✅ PASS: config.sh.example exists"
else
    echo "  ❌ FAIL: config.sh.example not found"
    exit 1
fi

# Test 5: Verify hooks exist
echo ""
echo "Test 5: Verify git hooks..."
HOOKS=(
    "hooks/quality-gates.sh"
    "hooks/pre-commit.sh"
    "hooks/post-commit.sh"
)

for hook in "${HOOKS[@]}"; do
    if [ -f "${PROJECT_ROOT}/$hook" ]; then
        echo "  ✅ PASS: $hook exists"
    else
        echo "  ❌ FAIL: $hook not found"
        exit 1
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All basic tests passed!"
echo ""
