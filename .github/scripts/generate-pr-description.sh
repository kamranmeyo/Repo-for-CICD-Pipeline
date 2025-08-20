#!/bin/bash

# PR Description Generator Script
# This script analyzes git changes and generates a comprehensive PR description

set -e

BASE_SHA="$1"
HEAD_SHA="$2"

if [[ -z "$BASE_SHA" || -z "$HEAD_SHA" ]]; then
    echo "Usage: $0 <base_sha> <head_sha>"
    exit 1
fi

echo "## 🚀 Pull Request Description"
echo ""

# Get commit count
COMMIT_COUNT=$(git rev-list --count "$BASE_SHA..$HEAD_SHA")
echo "### 📋 Overview"
echo "This PR contains **$COMMIT_COUNT commit(s)** with the following changes:"
echo ""

# Analyze changed files by type
declare -A file_types
while IFS= read -r file; do
    if [[ -n "$file" ]]; then
        extension="${file##*.}"
        if [[ "$extension" == "$file" ]]; then
            extension="no-extension"
        fi
        file_types["$extension"]=$((${file_types["$extension"]} + 1))
    fi
done < <(git diff --name-only "$BASE_SHA..$HEAD_SHA")

if [[ ${#file_types[@]} -gt 0 ]]; then
    echo "### 📁 Files Changed by Type"
    for ext in "${!file_types[@]}"; do
        count=${file_types[$ext]}
        case $ext in
            "html"|"htm")
                echo "- 🌐 **HTML files**: $count file(s)"
                ;;
            "css")
                echo "- 🎨 **CSS files**: $count file(s)"
                ;;
            "js")
                echo "- ⚡ **JavaScript files**: $count file(s)"
                ;;
            "yml"|"yaml")
                echo "- ⚙️ **YAML files**: $count file(s)"
                ;;
            "md")
                echo "- 📖 **Markdown files**: $count file(s)"
                ;;
            "json")
                echo "- 🔧 **JSON files**: $count file(s)"
                ;;
            *)
                echo "- 📄 **$ext files**: $count file(s)"
                ;;
        esac
    done
    echo ""
fi

# Get detailed commit information
echo "### 📝 Commit Details"
while IFS= read -r commit; do
    if [[ -n "$commit" ]]; then
        echo "- $commit"
    fi
done < <(git log --oneline "$BASE_SHA..$HEAD_SHA")
echo ""

# Get changed files with status
echo "### 🔄 Changed Files"
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        status=$(echo "$line" | cut -c1)
        file=$(echo "$line" | cut -c3-)
        case $status in
            "A")
                echo "- ➕ **Added**: \`$file\`"
                ;;
            "M")
                echo "- ✏️ **Modified**: \`$file\`"
                ;;
            "D")
                echo "- ❌ **Deleted**: \`$file\`"
                ;;
            "R")
                echo "- 🔄 **Renamed**: \`$file\`"
                ;;
            *)
                echo "- 📄 **Changed**: \`$file\`"
                ;;
        esac
    fi
done < <(git diff --name-status "$BASE_SHA..$HEAD_SHA")
echo ""

# Get diff statistics
echo "### 📊 Statistics"
echo '```'
git diff --stat "$BASE_SHA..$HEAD_SHA"
echo '```'
echo ""

# Check for specific patterns in commits
echo "### 🏷️ Change Categories"
COMMIT_MESSAGES=$(git log --pretty=format:"%s" "$BASE_SHA..$HEAD_SHA")

if echo "$COMMIT_MESSAGES" | grep -qi "fix\|bug\|error\|issue"; then
    echo "- 🐛 **Bug Fixes**: Contains bug fixes or error corrections"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "feat\|add\|new\|implement"; then
    echo "- ✨ **New Features**: Contains new functionality or features"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "update\|modify\|change\|improve"; then
    echo "- 🔄 **Updates**: Contains improvements or modifications"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "refactor\|cleanup\|clean"; then
    echo "- 🧹 **Refactoring**: Contains code cleanup or refactoring"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "doc\|readme\|comment"; then
    echo "- 📚 **Documentation**: Contains documentation updates"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "test\|spec"; then
    echo "- 🧪 **Testing**: Contains test-related changes"
fi

if echo "$COMMIT_MESSAGES" | grep -qi "config\|setup\|workflow\|ci\|cd"; then
    echo "- ⚙️ **Configuration**: Contains configuration or workflow changes"
fi

echo ""

# Add timestamp and branch info
echo "---"
echo "*Auto-generated on $(date -u '+%Y-%m-%d %H:%M:%S UTC')*"