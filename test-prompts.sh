#!/bin/bash

# Test script to verify prompt formatting consistency

echo "Testing prompt formats..."
echo ""

echo "=== Installation-style prompts ==="
printf "Enter your timezone [America/Mexico_City]: "
echo "America/New_York"

printf "Mount Documents directory (/Users/user/Documents)? [Y/n]: "
echo "Y"

printf "Do you want to mount a Projects directory? [Y/n]: "
echo "Y"

printf "Enter path to your projects directory [/Users/user/Projects]: "
echo "/Users/user/Code"

printf "Do you want to mount any additional directories? [y/N]: "
echo "N"

echo ""
echo "=== Uninstallation-style prompts ==="
printf "Do you want to remove PATH modifications from shell config? [y/N]: "
echo "Y"

printf "Are you sure you want to continue? [y/N]: "
echo "Y"

echo ""
echo "All prompts use the same format: question on same line with clear brackets!"
