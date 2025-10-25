#!/bin/bash
# ABOUTME: Pre-commit hook enforcing quality gates for Claude TMUX Orchestration

set -e

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

echo "🔍 Running pre-commit quality gates..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Check if there are staged files
if ! git diff --cached --quiet; then
    echo "📋 Found staged changes, running quality checks..."

    # Run quality gates script
    QUALITY_GATES_SCRIPT="${SCRIPT_DIR}/quality-gates.sh"
    if [ -f "$QUALITY_GATES_SCRIPT" ]; then
        bash "$QUALITY_GATES_SCRIPT"
    elif [ -f ".claude/hooks/quality-gates.sh" ]; then
        bash .claude/hooks/quality-gates.sh
    else
        echo "⚠️  Quality gates script not found, skipping quality checks"
    fi
else
    echo "📋 No staged changes found"
fi

echo "✅ Pre-commit checks completed successfully"