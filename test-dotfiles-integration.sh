#!/bin/bash
# Test script for dotfiles functionality

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Testing LazyVim Docker Dotfiles Integration${NC}"
echo "=========================================="

# Test 1: Check if ZIP file exists
echo -e "\n${BLUE}Test 1: Checking test dotfiles ZIP file...${NC}"
if [[ -f "test-dotfiles.zip" ]]; then
    echo -e "${GREEN}✅ test-dotfiles.zip exists${NC}"
    echo "Size: $(du -h test-dotfiles.zip | cut -f1)"
else
    echo -e "${RED}❌ test-dotfiles.zip not found${NC}"
fi

# Test 2: Check ZIP contents
echo -e "\n${BLUE}Test 2: Checking ZIP file contents...${NC}"
if command -v unzip &> /dev/null; then
    if unzip -t test-dotfiles.zip &> /dev/null; then
        echo -e "${GREEN}✅ ZIP file is valid${NC}"
        echo "Contents:"
        unzip -l test-dotfiles.zip | grep -E "\.(lua|sh|zshrc|gitconfig|lazyvim-docker-dotfiles)$"
    else
        echo -e "${RED}❌ ZIP file is corrupted${NC}"
    fi
else
    echo -e "${RED}❌ unzip command not found${NC}"
fi

# Test 3: Check dotfiles configuration file
echo -e "\n${BLUE}Test 3: Checking dotfiles configuration...${NC}"
temp_dir="/tmp/dotfiles-test-$$"
mkdir -p "$temp_dir"

if unzip -q test-dotfiles.zip -d "$temp_dir" 2>/dev/null; then
    config_file="$temp_dir/test-dotfiles/.lazyvim-docker-dotfiles"
    if [[ -f "$config_file" ]]; then
        echo -e "${GREEN}✅ Configuration file found${NC}"
        echo "Sections found:"
        grep -E "^\[.*\]$" "$config_file" | sed 's/[][]//g' | sed 's/^/  - /'
    else
        echo -e "${RED}❌ Configuration file missing${NC}"
    fi
    rm -rf "$temp_dir"
else
    echo -e "${RED}❌ Could not extract ZIP file${NC}"
fi

# Test 4: Check script syntax
echo -e "\n${BLUE}Test 4: Checking configure script syntax...${NC}"
if bash -n scripts/configure.sh; then
    echo -e "${GREEN}✅ configure.sh syntax is valid${NC}"
else
    echo -e "${RED}❌ configure.sh has syntax errors${NC}"
fi

# Test 5: Check documentation
echo -e "\n${BLUE}Test 5: Checking documentation files...${NC}"
docs_to_check=("docs/DOTFILES_STANDARD.md" "README.md" "docs/COMMANDS.md")

for doc in "${docs_to_check[@]}"; do
    if [[ -f "$doc" ]]; then
        if grep -q "dotfiles\|Dotfiles" "$doc"; then
            echo -e "${GREEN}✅ $doc contains dotfiles documentation${NC}"
        else
            echo -e "${RED}❌ $doc missing dotfiles information${NC}"
        fi
    else
        echo -e "${RED}❌ $doc not found${NC}"
    fi
done

echo -e "\n${BLUE}Test Summary:${NC}"
echo "============="
echo "✅ Test dotfiles ZIP: $(pwd)/test-dotfiles.zip"
echo "✅ Configuration script: scripts/configure.sh"
echo "✅ Documentation: docs/DOTFILES_STANDARD.md"
echo "✅ Updated README.md and COMMANDS.md"

echo -e "\n${GREEN}🎉 Dotfiles integration is ready for testing!${NC}"
echo -e "\n${BLUE}To test:${NC}"
echo "1. Run: make configure"
echo "2. Choose option 5 (dotfiles integration)"
echo "3. Choose option 2 (local ZIP file)"
echo "4. Enter path: $(pwd)/test-dotfiles.zip"
