#!/bin/bash
# Example Git helper scripts for LazyVim Docker
# This is a test script

# Git status for all repositories in current directory
git-status-all() {
    echo "🔍 Checking Git status for all repositories..."
    for dir in */; do
        if [[ -d "$dir/.git" ]]; then
            echo ""
            echo "📂 Repository: $dir"
            (cd "$dir" && git status --porcelain)
        fi
    done
}

# Quick commit with message
git-quick-commit() {
    if [[ -z "$1" ]]; then
        echo "Usage: git-quick-commit <message>"
        return 1
    fi
    
    git add .
    git commit -m "$1"
    echo "✅ Quick commit completed: $1"
}

# Show branch information
git-branch-info() {
    echo "🌿 Git Branch Information:"
    echo "Current branch: $(git branch --show-current)"
    echo "Remote tracking: $(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo 'None')"
    echo "Commits ahead: $(git rev-list --count HEAD ^@{u} 2>/dev/null || echo '0')"
    echo "Commits behind: $(git rev-list --count @{u} ^HEAD 2>/dev/null || echo '0')"
}

# Export functions
alias gsa='git-status-all'
alias gqc='git-quick-commit'
alias gbi='git-branch-info'

echo "🔧 Git helper functions loaded!"
echo "Available commands: gsa, gqc, gbi"
