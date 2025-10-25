#!/bin/bash
# ABOUTME: Sends commands to specific tmux panes for task delegation

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
WINDOW="${1}"
COMMAND="${2}"

# Validate arguments
if [ -z "$WINDOW" ] || [ -z "$COMMAND" ]; then
    echo "Usage: $0 <window> <command>"
    echo ""
    echo "Examples:"
    echo "  $0 0 'npm test'                    # Run tests in implementer window"
    echo "  $0 2 'npm run test:e2e'            # Run E2E in testing window"
    echo "  $0 0 'Task: Implement feature X'   # Brief implementer with task"
    echo ""
    exit 1
fi

# Validate session exists
if ! tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then
    echo "❌ Session '$TMUX_SESSION_NAME' not found"
    echo "💡 Create session first with: scripts/tmux-spawn-session.sh"
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

echo "📤 Delegating to $WINDOW_NAME (window $WINDOW)"
echo "📝 Command: $COMMAND"

# Send command to window
tmux send-keys -t "$TMUX_SESSION_NAME:$WINDOW" "$COMMAND" Enter

echo "✅ Command sent successfully"
echo "💡 Monitor output with: scripts/tmux-monitor.sh $WINDOW"
