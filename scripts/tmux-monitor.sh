#!/bin/bash
# ABOUTME: Monitors specified tmux window and captures output

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    TMUX_SESSION_NAME="project"
fi

# Parse arguments
WINDOW="${1:-0}"
LINES="${2:-50}"

# Validate session exists
if ! tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then
    echo "❌ Session '$TMUX_SESSION_NAME' not found"
    echo "💡 Available sessions:"
    tmux list-sessions 2>/dev/null || echo "  (no sessions)"
    exit 1
fi

# Validate window exists
if ! tmux list-windows -t "$TMUX_SESSION_NAME" | grep -q "^$WINDOW:"; then
    echo "❌ Window $WINDOW not found in session '$TMUX_SESSION_NAME'"
    echo "💡 Available windows:"
    tmux list-windows -t "$TMUX_SESSION_NAME"
    exit 1
fi

# Get window name
WINDOW_NAME=$(tmux list-windows -t "$TMUX_SESSION_NAME" | grep "^$WINDOW:" | awk -F: '{print $2}' | awk '{print $1}')

echo "👀 Monitoring $TMUX_SESSION_NAME:$WINDOW ($WINDOW_NAME) - Last $LINES lines"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Capture pane output
tmux capture-pane -t "$TMUX_SESSION_NAME:$WINDOW" -p | tail -n "$LINES"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Captured output from $WINDOW_NAME (window $WINDOW)"
