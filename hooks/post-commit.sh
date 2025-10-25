#!/bin/bash
# ABOUTME: Post-commit hook for Claude TMUX Orchestration workflow tracking

set -e

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

echo "📝 Post-commit workflow..."

# Get commit information
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

echo "✅ Commit $COMMIT_HASH completed"
echo "📄 Message: $COMMIT_MESSAGE"

# Log to project journal if MCP is available
if [ "$ENABLE_JOURNAL_MCP" = "true" ] && command -v claude >/dev/null 2>&1; then
    echo "📊 Logging commit to project journal..."
    # This would integrate with journal MCP when available
    # Example: claude journal log --project "$PROJECT_NAME" --commit "$COMMIT_HASH"
fi

echo "🎉 Post-commit workflow completed"