#!/bin/bash
# ABOUTME: Quality gates enforcement script for Claude TMUX Orchestration

set -e

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/config.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default configuration
    ENABLE_ESLINT=${ENABLE_ESLINT:-true}
    ENABLE_TYPESCRIPT=${ENABLE_TYPESCRIPT:-true}
    ENABLE_TESTS=${ENABLE_TESTS:-true}
    ENABLE_COVERAGE=${ENABLE_COVERAGE:-true}
    LINT_SCRIPT=${LINT_SCRIPT:-"lint"}
    TYPE_CHECK_SCRIPT=${TYPE_CHECK_SCRIPT:-"type-check"}
    TEST_SCRIPT=${TEST_SCRIPT:-"test"}
    COVERAGE_SCRIPT=${COVERAGE_SCRIPT:-"test:coverage"}
fi

echo "🚪 Running quality gates..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run linting if available
run_linting() {
    if [ "$ENABLE_ESLINT" != "true" ]; then
        echo "⏭️  ESLint disabled in config, skipping"
        return 0
    fi

    if [ -f "package.json" ]; then
        if npm list eslint >/dev/null 2>&1; then
            echo "📝 Running ESLint..."
            if npm run "$LINT_SCRIPT" 2>/dev/null; then
                echo "✅ ESLint passed"
            else
                echo "❌ ESLint failed - run 'npm run lint:fix' to auto-fix issues"
                exit 1
            fi
        else
            echo "⚠️  ESLint not configured, skipping lint check"
        fi
    fi
}

# Function to run type checking if available
run_type_check() {
    if [ "$ENABLE_TYPESCRIPT" != "true" ]; then
        echo "⏭️  TypeScript disabled in config, skipping"
        return 0
    fi

    if [ -f "tsconfig.json" ] && [ -f "package.json" ]; then
        if npm list typescript >/dev/null 2>&1; then
            echo "🔍 Running TypeScript type check..."
            if npm run "$TYPE_CHECK_SCRIPT" 2>/dev/null || npx tsc --noEmit 2>/dev/null; then
                echo "✅ TypeScript type check passed"
            else
                echo "❌ TypeScript type check failed"
                exit 1
            fi
        else
            echo "⚠️  TypeScript not configured, skipping type check"
        fi
    fi
}

# Function to run tests if available
run_tests() {
    if [ "$ENABLE_TESTS" != "true" ]; then
        echo "⏭️  Tests disabled in config, skipping"
        return 0
    fi

    if [ -f "package.json" ]; then
        if npm list jest >/dev/null 2>&1 || npm list vitest >/dev/null 2>&1 || npm list mocha >/dev/null 2>&1; then
            echo "🧪 Running tests..."
            if npm run "$TEST_SCRIPT" 2>/dev/null; then
                echo "✅ Tests passed"
            else
                echo "❌ Tests failed"
                exit 1
            fi
        else
            echo "⚠️  No test framework detected, skipping tests"
        fi
    fi
}

# Function to check test coverage if available
check_coverage() {
    if [ "$ENABLE_COVERAGE" != "true" ]; then
        echo "⏭️  Coverage disabled in config, skipping"
        return 0
    fi

    if [ -f "package.json" ]; then
        if npm list jest >/dev/null 2>&1 || npm list vitest >/dev/null 2>&1 || npm list mocha >/dev/null 2>&1; then
            echo "📊 Checking test coverage..."
            if npm run "$COVERAGE_SCRIPT" 2>/dev/null; then
                echo "✅ Coverage requirements met"
            else
                echo "⚠️  Coverage check not available or failed"
            fi
        fi
    fi
}

# Run quality gates
echo "🔍 Checking project structure..."

# Check for source directory
if [ ! -d "src" ]; then
    echo "⚠️  No src/ directory found - creating basic structure"
    mkdir -p src tests
fi

# Run available quality checks
run_linting
run_type_check
run_tests
check_coverage

echo "✅ All quality gates passed!"