#!/bin/bash

# LazyVim Docker - Remote Uninstall Script
# This script completely removes LazyVim Docker from the system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.local/share/lazyvim-docker"
BIN_DIR="$HOME/.local/bin"

# Print functions
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║             LazyVim Docker - Uninstaller                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
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

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Stop and remove Docker containers
cleanup_docker() {
    print_step "Cleaning up Docker containers and images..."
    
    if [ -d "$INSTALL_DIR" ]; then
        cd "$INSTALL_DIR"
        
        # Try to run make destroy first
        if command -v make >/dev/null 2>&1; then
            print_info "Running make destroy..."
            make destroy 2>/dev/null || {
                print_warning "make destroy failed, attempting manual cleanup..."
            }
        fi
        
        # Manual Docker cleanup
        if command -v docker >/dev/null 2>&1; then
            print_info "Removing Docker containers and images..."
            
            # Stop and remove containers
            docker stop lazyvim 2>/dev/null || true
            docker rm lazyvim 2>/dev/null || true
            
            # Remove images
            docker rmi lazyvim-docker_code-editor 2>/dev/null || true
            docker rmi $(docker images | grep lazyvim | awk '{print $3}') 2>/dev/null || true
            
            # Remove volumes
            docker volume rm lazyvim-docker_lazyvim-data 2>/dev/null || true
            docker volume rm $(docker volume ls | grep lazyvim | awk '{print $2}') 2>/dev/null || true
            
            print_success "Docker cleanup completed"
        else
            print_warning "Docker not found, skipping Docker cleanup"
        fi
    fi
}

# Remove installation directory
remove_installation() {
    print_step "Removing installation directory..."
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_success "Installation directory removed: $INSTALL_DIR"
    else
        print_warning "Installation directory not found: $INSTALL_DIR"
    fi
}

# Remove global commands from shell configurations
remove_shell_commands() {
    print_step "Removing global commands from shell configurations..."
    
    local configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile")
    local marker_start="# LazyVim Docker Global Commands - START"
    local marker_end="# LazyVim Docker Global Commands - END"
    local removed_any=false
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]] && grep -q "$marker_start" "$config" 2>/dev/null; then
            print_info "Removing commands from: $config"
            
            # Create backup
            cp "$config" "${config}.backup.$(date +%Y%m%d-%H%M%S)"
            
            # Remove the section between markers
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/$marker_start/,/$marker_end/d" "$config"
            else
                sed -i "/$marker_start/,/$marker_end/d" "$config"
            fi
            
            removed_any=true
        fi
    done
    
    if [[ "$removed_any" == true ]]; then
        print_success "Global commands removed from shell configurations"
    else
        print_info "No global commands found in shell configurations"
    fi
}

# Remove global command
remove_global_command() {
    print_step "Removing global command..."
    
    if [ -f "$BIN_DIR/lazy" ]; then
        rm -f "$BIN_DIR/lazy"
        print_success "Global 'lazy' command removed"
    else
        print_warning "Global command not found: $BIN_DIR/lazy"
    fi
}

# Remove PATH modifications (optional)
remove_path_modifications() {
    echo ""
    printf "Do you want to remove PATH modifications from shell config? [y/N]: "
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            print_step "Removing PATH modifications..."
            
            local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
            
            for config in "${shell_configs[@]}"; do
                if [ -f "$config" ]; then
                    # Create backup
                    cp "$config" "${config}.backup.$(date +%Y%m%d-%H%M%S)"
                    
                    # Remove LazyVim Docker PATH modifications
                    sed -i.tmp '/# LazyVim Docker - Add local bin to PATH/d' "$config" 2>/dev/null || true
                    sed -i.tmp '/export PATH=.*\.local\/bin.*PATH/d' "$config" 2>/dev/null || true
                    rm -f "${config}.tmp"
                    
                    print_info "Cleaned PATH modifications from: $config"
                fi
            done
            
            print_success "PATH modifications removed"
            ;;
        *)
            print_info "PATH modifications preserved"
            ;;
    esac
}

# Confirm uninstallation
confirm_uninstall() {
    echo ""
    print_warning "This will completely remove LazyVim Docker from your system:"
    echo "  • Docker containers and images"
    echo "  • Installation directory ($INSTALL_DIR)"
    echo "  • Global 'lazy' command"
    echo "  • All data and configurations"
    echo ""
    printf "Are you sure you want to continue? [y/N]: "
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            print_info "Uninstallation cancelled"
            exit 0
            ;;
    esac
}

# Main uninstallation process
main() {
    print_header
    
    print_info "LazyVim Docker Uninstaller"
    echo ""
    
    confirm_uninstall
    
    cleanup_docker
    remove_installation
    remove_global_command
    remove_shell_commands
    remove_path_modifications
    
    echo ""
    print_success "🗑️  LazyVim Docker has been completely uninstalled!"
    echo ""
    print_info "What was removed:"
    print_info "  ✓ Docker containers and images"
    print_info "  ✓ Installation directory"
    print_info "  ✓ Global commands"
    echo ""
    print_info "Thank you for using LazyVim Docker! 🚀"
    echo ""
    print_info "To reinstall later, run:"
    echo "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash${NC}"
    echo ""
}

# Run main function
main "$@"
