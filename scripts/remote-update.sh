#!/bin/bash

# LazyVim Docker - Remote Update Script
# This script updates LazyVim Docker to the latest version

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
REPO_URL="https://github.com/manghidev/lazyvim-docker"
INSTALL_DIR="$HOME/.local/share/lazyvim-docker"
TEMP_DIR="/tmp/lazyvim-docker-update"
BACKUP_DIR="$HOME/.local/share/lazyvim-docker-backup-$(date +%Y%m%d-%H%M%S)"

# Print functions
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║             LazyVim Docker - Updater                        ║${NC}"
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

# Check if installation exists
check_installation() {
    if [ ! -d "$INSTALL_DIR" ]; then
        print_error "LazyVim Docker installation not found at: $INSTALL_DIR"
        print_info "Please install first:"
        echo "  curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash"
        exit 1
    fi
}

# Get current version
get_current_version() {
    if [ -f "$INSTALL_DIR/VERSION" ]; then
        cat "$INSTALL_DIR/VERSION"
    else
        echo "unknown"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    if command -v curl >/dev/null 2>&1; then
        curl -s "https://api.github.com/repos/manghidev/lazyvim-docker/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Backup current installation
backup_installation() {
    print_step "Creating backup of current installation..."
    
    cp -r "$INSTALL_DIR" "$BACKUP_DIR"
    print_success "Backup created at: $BACKUP_DIR"
}

# Download latest version
download_latest() {
    print_step "Downloading latest version..."
    
    # Remove temp directory if it exists
    rm -rf "$TEMP_DIR"
    
    # Clone the repository to temp directory
    if git clone --depth 1 "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1; then
        print_success "Latest version downloaded"
    else
        print_error "Failed to download latest version"
        exit 1
    fi
}

# Update installation
update_installation() {
    print_step "Updating installation..."
    
    # Stop containers first
    cd "$INSTALL_DIR"
    print_info "Stopping containers..."
    make stop 2>/dev/null || true
    
    # Preserve user configurations
    local preserve_dirs=("backups" ".dotfiles")
    local temp_preserve="/tmp/lazyvim-preserve-$$"
    mkdir -p "$temp_preserve"
    
    for dir in "${preserve_dirs[@]}"; do
        if [ -d "$INSTALL_DIR/$dir" ]; then
            cp -r "$INSTALL_DIR/$dir" "$temp_preserve/"
            print_info "Preserved: $dir"
        fi
    done
    
    # Remove old installation (except preserved items)
    find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name "backups" ! -name ".dotfiles" -exec rm -rf {} +
    
    # Copy new files
    cp -r "$TEMP_DIR"/* "$INSTALL_DIR/"
    
    # Restore preserved configurations
    for dir in "${preserve_dirs[@]}"; do
        if [ -d "$temp_preserve/$dir" ]; then
            cp -r "$temp_preserve/$dir" "$INSTALL_DIR/"
        fi
    done
    
    # Cleanup temp preserve
    rm -rf "$temp_preserve"
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/scripts/"*.sh
    chmod +x "$INSTALL_DIR/Makefile"
    
    print_success "Installation updated successfully"
}

# Rebuild if needed
rebuild_containers() {
    echo ""
    echo -n "Do you want to rebuild Docker containers with the latest changes? [Y/n]: "
    read -r response
    
    case "$response" in
        [nN][oO]|[nN])
            print_info "Skipping container rebuild"
            ;;
        *)
            print_step "Rebuilding Docker containers..."
            cd "$INSTALL_DIR"
            if make build; then
                print_success "Containers rebuilt successfully"
            else
                print_warning "Container rebuild failed. You can try 'lazyvim build' later."
            fi
            ;;
    esac
}

# Cleanup
cleanup() {
    print_step "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    print_success "Cleanup completed"
}

# Main update process
main() {
    print_header
    
    check_installation
    
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    print_info "Current version: $current_version"
    print_info "Latest version: $latest_version"
    echo ""
    
    if [ "$current_version" = "$latest_version" ] && [ "$current_version" != "unknown" ]; then
        print_success "You already have the latest version!"
        echo ""
        echo -n "Do you want to force update anyway? [y/N]: "
        read -r response
        case "$response" in
            [yY][eE][sS]|[yY])
                print_info "Proceeding with forced update..."
                ;;
            *)
                print_info "Update cancelled"
                exit 0
                ;;
        esac
    fi
    
    backup_installation
    download_latest
    update_installation
    rebuild_containers
    cleanup
    
    echo ""
    print_success "🎉 LazyVim Docker updated successfully!"
    echo ""
    print_info "Updated to version: $(get_current_version)"
    print_info "Backup available at: $BACKUP_DIR"
    echo ""
    print_info "To start using the updated version:"
    printf "  ${GREEN}lazyvim enter${NC}\n"
    echo ""
}

# Run main function
main "$@"
