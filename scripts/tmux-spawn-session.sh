#!/bin/bash
# ABOUTME: Creates tmux session with implementer, manager, and testing windows

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "💡 Copy config/config.sh.example to config/config.sh and customize"
    exit 1
fi

# Validate configuration
if [ -z "$TMUX_SESSION_NAME" ]; then
    echo "❌ TMUX_SESSION_NAME not set in configuration"
    exit 1
fi

if [ -z "$PROJECT_ROOT" ]; then
    echo "❌ PROJECT_ROOT not set in configuration"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session '$TMUX_SESSION_NAME' already exists"
    echo "Would you like to attach to it? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        tmux attach-session -t "$TMUX_SESSION_NAME"
        exit 0
    else
        echo "❌ Aborting. Use 'tmux kill-session -t $TMUX_SESSION_NAME' to remove it."
        exit 1
    fi
fi

echo "🚀 Creating tmux session: $TMUX_SESSION_NAME"

# Create new session with implementer window
tmux new-session -d -s "$TMUX_SESSION_NAME" -n "implementer" -c "$PROJECT_ROOT"

# Create manager window
tmux new-window -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW" -n "manager" -c "$PROJECT_ROOT"

# Create testing window
tmux new-window -t "$TMUX_SESSION_NAME:$TMUX_TESTING_WINDOW" -n "testing" -c "$PROJECT_ROOT"

# Set up implementer window (window 0)
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_IMPLEMENTER_WINDOW" "clear" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_IMPLEMENTER_WINDOW" "echo '🔧 Implementer Agent'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_IMPLEMENTER_WINDOW" "echo 'Role: Write tests first, then implement code following TDD'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_IMPLEMENTER_WINDOW" "echo 'Waiting for instructions from manager...'" Enter

# Set up manager window (window 1)
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW" "clear" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW" "echo '📋 Manager Agent'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW" "echo 'Role: Coordinate agents, enforce quality gates, manage git'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW" "echo 'Ready to coordinate development...'" Enter

# Set up testing window (window 2)
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_TESTING_WINDOW" "clear" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_TESTING_WINDOW" "echo '🧪 Testing Agent'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_TESTING_WINDOW" "echo 'Role: Run E2E tests on deployments'" Enter
tmux send-keys -t "$TMUX_SESSION_NAME:$TMUX_TESTING_WINDOW" "echo 'Waiting for deployment to test...'" Enter

# Select manager window as default
tmux select-window -t "$TMUX_SESSION_NAME:$TMUX_MANAGER_WINDOW"

echo "✅ Session created successfully"
echo ""
echo "📊 Session Layout:"
echo "  Window $TMUX_IMPLEMENTER_WINDOW: implementer (TDD development)"
echo "  Window $TMUX_MANAGER_WINDOW: manager (coordination)"
echo "  Window $TMUX_TESTING_WINDOW: testing (E2E validation)"
echo ""
echo "To attach: tmux attach-session -t $TMUX_SESSION_NAME"
echo "To list windows: tmux list-windows -t $TMUX_SESSION_NAME"
echo "To send command: tmux send-keys -t $TMUX_SESSION_NAME:0 'your command' Enter"
echo ""

# Optionally attach to session
if [ "$1" = "--attach" ] || [ "$1" = "-a" ]; then
    tmux attach-session -t "$TMUX_SESSION_NAME"
fi
