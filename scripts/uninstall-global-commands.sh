#!/bin/bash

# uninstall-global-commands.sh
# Script to remove LazyVim Docker global commands from shell configuration files

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FUNCTION_NAME="lazy"
START_MARKER="# LazyVim Docker Global Commands - START"
END_MARKER="# LazyVim Docker Global Commands - END"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to remove commands from a specific shell config file
remove_from_config() {
    local config_file="$1"
    local shell_name="$2"
    
    if [[ ! -f "$config_file" ]]; then
        print_warning "$shell_name config file not found: $config_file"
        return 0
    fi
    
    # Check if our commands are present
    if ! grep -q "$START_MARKER" "$config_file" 2>/dev/null; then
        print_warning "LazyVim Docker commands not found in $config_file"
        return 0
    fi
    
    print_status "Removing LazyVim Docker commands from $config_file..."
    
    # Create a backup
    cp "$config_file" "${config_file}.bak.$(date +%Y%m%d-%H%M%S)"
    print_status "Backup created: ${config_file}.bak.$(date +%Y%m%d-%H%M%S)"
    
    # Remove the section between markers (including the markers)
    if sed -i.tmp "/$START_MARKER/,/$END_MARKER/d" "$config_file" 2>/dev/null; then
        rm -f "${config_file}.tmp"
        print_success "Successfully removed LazyVim Docker commands from $shell_name config"
        return 0
    else
        print_error "Failed to remove commands from $config_file"
        return 1
    fi
}

# Function to remove global commands from shell configs
remove_global_commands() {
    local removed_any=false
    
    print_status "Removing LazyVim Docker global commands from shell configurations..."
    
    # Remove from Zsh
    if remove_from_config "$HOME/.zshrc" "Zsh"; then
        removed_any=true
    fi
    
    # Remove from Bash
    if remove_from_config "$HOME/.bashrc" "Bash"; then
        removed_any=true
    fi
    
    # Also check ~/.bash_profile (macOS)
    if remove_from_config "$HOME/.bash_profile" "Bash Profile"; then
        removed_any=true
    fi
    
    if [[ "$removed_any" == true ]]; then
        print_success "Global commands have been removed from shell configurations"
        print_status "Please restart your terminal or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"
        return 0
    else
        print_warning "No LazyVim Docker commands were found in any shell configuration files"
        return 1
    fi
}

# Function to optionally remove the project directory
remove_project_directory() {
    local project_dir
    project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo
    print_status "Current project directory: $project_dir"
    echo
    echo -n "Do you want to remove the entire LazyVim Docker project directory? [y/N]: "
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            print_status "Removing project directory: $project_dir"
            
            # Stop and remove containers first
            if command -v docker-compose >/dev/null 2>&1 || command -v docker >/dev/null 2>&1; then
                print_status "Stopping and removing Docker containers..."
                cd "$project_dir"
                make destroy 2>/dev/null || {
                    print_warning "Could not run 'make destroy'. Attempting manual cleanup..."
                    docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true
                    docker rmi lazyvim-docker_code-editor 2>/dev/null || true
                }
            fi
            
            # Remove the directory
            cd "$HOME"
            if rm -rf "$project_dir"; then
                print_success "Project directory removed successfully"
            else
                print_error "Failed to remove project directory. You may need to remove it manually:"
                print_error "  rm -rf '$project_dir'"
            fi
            ;;
        *)
            print_status "Project directory preserved: $project_dir"
            print_status "You can manually remove it later if needed"
            ;;
    esac
}

# Main function
main() {
    echo
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                LazyVim Docker - Uninstaller                  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Remove global commands
    if remove_global_commands; then
        echo
        print_success "✓ Global 'lazy' commands removed from shell configurations"
    else
        echo
        print_warning "⚠ No global commands were found to remove"
    fi
    
    # Ask about removing project directory
    remove_project_directory
    
    echo
    print_success "Uninstallation completed!"
    echo
    print_status "What was removed:"
    print_status "  • Global 'lazy' command and tab completion"
    print_status "  • LazyVim Docker functions from shell configs"
    echo
    print_status "If you removed the project directory, all Docker containers and images were also cleaned up."
    echo
    print_status "Thank you for using LazyVim Docker! 🚀"
    echo
}

# Run main function
main "$@"
