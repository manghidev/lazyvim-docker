#!/bin/bash
# Example development setup script for LazyVim Docker
# This is a test script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Running LazyVim Docker development setup...${NC}"

# Create common development directories
mkdir -p ~/dev/{projects,scripts,temp}
mkdir -p ~/.config
mkdir -p ~/.local/bin

# Set up Git hooks directory
mkdir -p ~/.git-templates/hooks

echo -e "${GREEN}✅ Development directories created!${NC}"

# Display environment info
echo -e "\n${BLUE}📋 Environment Information:${NC}"
echo "Current user: $(whoami)"
echo "Home directory: $HOME"
echo "Shell: $SHELL"
echo "Editor: $EDITOR"

if [[ "$DOTFILES_LOADED" == "true" ]]; then
    echo -e "${GREEN}✅ Custom dotfiles are loaded${NC}"
else
    echo "ℹ️  No custom dotfiles detected"
fi

echo -e "\n${GREEN}🚀 Development environment is ready!${NC}"
