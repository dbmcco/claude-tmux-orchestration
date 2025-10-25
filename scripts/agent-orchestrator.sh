#!/bin/bash
# ABOUTME: Core agent coordination logic for Claude TMUX orchestration

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Brief function - sends task to implementer
brief_implementer() {
    local task="$1"

    if [ -z "$task" ]; then
        echo "❌ Task description required"
        return 1
    fi

    echo "📋 Briefing implementer with task..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 Task: $task"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Send task to implementer window
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo ''"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo '📋 NEW TASK FROM MANAGER'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo '$task'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo ''"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo '✅ Follow TDD: RED → GREEN → REFACTOR'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo '✅ Run quality gates before requesting commit'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_IMPLEMENTER_WINDOW" "echo ''"

    echo "✅ Implementer briefed"
}

# Monitor function - checks progress of implementer
monitor_progress() {
    local window="${1:-$TMUX_IMPLEMENTER_WINDOW}"
    local lines="${2:-50}"

    echo "👀 Monitoring agent progress..."
    "${SCRIPT_DIR}/tmux-monitor.sh" "$window" "$lines"
}

# Validate function - runs quality gates
validate_quality() {
    echo "🔍 Running quality gates validation..."

    QUALITY_GATES="${SCRIPT_DIR}/../hooks/quality-gates.sh"

    if [ -f "$QUALITY_GATES" ]; then
        if bash "$QUALITY_GATES"; then
            echo "✅ Quality gates passed - ready for commit"
            return 0
        else
            echo "❌ Quality gates failed - cannot commit"
            return 1
        fi
    else
        echo "⚠️  Quality gates script not found"
        return 1
    fi
}

# Execute commit function - performs git commit
execute_commit() {
    local message="$1"

    if [ -z "$message" ]; then
        echo "❌ Commit message required"
        return 1
    fi

    # First validate quality gates
    if ! validate_quality; then
        echo "❌ Cannot commit - quality gates failed"
        return 1
    fi

    echo "📝 Executing commit..."

    # Stage all changes
    git add .

    # Create commit with standard format
    git commit -m "$message

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

    echo "✅ Commit completed"
    git log -1 --oneline
}

# Request E2E tests function
request_e2e() {
    local deployment_url="${1:-$DEPLOYMENT_URL}"

    if [ -z "$deployment_url" ]; then
        echo "⚠️  No deployment URL configured"
        return 1
    fi

    echo "🧪 Requesting E2E tests on deployment..."

    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_TESTING_WINDOW" "echo ''"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_TESTING_WINDOW" "echo '🧪 NEW E2E TEST REQUEST'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_TESTING_WINDOW" "echo 'Deployment: $deployment_url'"
    "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_TESTING_WINDOW" "echo ''"

    if [ "$ENABLE_E2E_TESTS" = "true" ]; then
        "${SCRIPT_DIR}/tmux-delegate.sh" "$TMUX_TESTING_WINDOW" "npm run test:e2e"
    else
        echo "⚠️  E2E tests disabled in configuration"
    fi

    echo "✅ E2E test request sent"
}

# Main function - provides CLI interface
main() {
    local command="$1"
    shift

    case "$command" in
        brief)
            brief_implementer "$@"
            ;;
        monitor)
            monitor_progress "$@"
            ;;
        validate)
            validate_quality
            ;;
        commit)
            execute_commit "$@"
            ;;
        e2e)
            request_e2e "$@"
            ;;
        help|--help|-h)
            echo "Claude TMUX Orchestrator - Agent Coordination"
            echo ""
            echo "Usage: $0 <command> [args]"
            echo ""
            echo "Commands:"
            echo "  brief <task>        Brief implementer with new task"
            echo "  monitor [window]    Monitor agent progress (default: implementer)"
            echo "  validate            Run quality gates validation"
            echo "  commit <message>    Execute git commit (after validation)"
            echo "  e2e [url]           Request E2E tests on deployment"
            echo "  help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 brief 'Implement user authentication'"
            echo "  $0 monitor 0"
            echo "  $0 validate"
            echo "  $0 commit 'feat: add user login'"
            echo "  $0 e2e https://myapp.com"
            ;;
        *)
            echo "❌ Unknown command: $command"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Export functions for use in other scripts
export -f brief_implementer
export -f monitor_progress
export -f validate_quality
export -f execute_commit
export -f request_e2e

# Run main if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ -z "$1" ]; then
        main help
    else
        main "$@"
    fi
fi
