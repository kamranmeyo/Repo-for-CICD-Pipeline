#!/bin/bash

# Test script for PR Description Generation
# This script tests the generate-pr-description.sh script locally

set -e

echo "🧪 Testing PR Description Generation Script"
echo "=========================================="

# Test with current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📝 Current branch: $CURRENT_BRANCH"

# Get the last few commits for testing
COMMITS=$(git log --oneline -5)
echo "📋 Recent commits:"
echo "$COMMITS"
echo ""

# Test if the script exists and is executable
SCRIPT_PATH=".github/scripts/generate-pr-description.sh"
if [[ -f "$SCRIPT_PATH" && -x "$SCRIPT_PATH" ]]; then
    echo "✅ Script found and executable: $SCRIPT_PATH"
else
    echo "❌ Script not found or not executable: $SCRIPT_PATH"
    exit 1
fi

# Test with dummy commit range (using HEAD~2..HEAD as example)
echo "🔍 Testing script with commit range HEAD~2..HEAD"
echo "================================================"

if git rev-parse HEAD~2 >/dev/null 2>&1; then
    HEAD_SHA=$(git rev-parse HEAD)
    BASE_SHA=$(git rev-parse HEAD~2)
    
    echo "📊 Base SHA: $BASE_SHA"
    echo "📊 Head SHA: $HEAD_SHA"
    echo ""
    
    echo "🚀 Generated PR Description:"
    echo "============================"
    $SCRIPT_PATH "$BASE_SHA" "$HEAD_SHA"
    echo ""
    echo "✅ Script executed successfully!"
else
    echo "⚠️  Not enough commits for testing. Need at least 2 commits."
    echo "📋 Available commits: $(git log --oneline | wc -l)"
fi

echo ""
echo "🎉 PR Description Generation test completed!"