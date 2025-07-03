#!/bin/bash

# LazyVim Docker - Remote Uninstall Script
# This script completely removes LazyVim Docker from the system

set -e

# Colors for output using tput (more compatible)
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED=$(tput setaf 1 2>/dev/null || echo '')
    GREEN=$(tput setaf 2 2>/dev/null || echo '')
    YELLOW=$(tput setaf 3 2>/dev/null || echo '')
    BLUE=$(tput setaf 4 2>/dev/null || echo '')
    PURPLE=$(tput setaf 5 2>/dev/null || echo '')
    CYAN=$(tput setaf 6 2>/dev/null || echo '')
    NC=$(tput sgr0 2>/dev/null || echo '')
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    NC=''
fi

# Configuration
INSTALL_DIR="$HOME/.local/share/lazyvim-docker"
BIN_DIR="$HOME/.local/bin"

# Print functions
print_header() {
    printf "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║             LazyVim Docker - Uninstaller                    ║${NC}\n"
    printf "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
}

print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

print_step() {
    printf "${PURPLE}[STEP]${NC} %s\n" "$1"
}

# Smart terminal restart for clean environment
restart_terminal() {
    print_step "Setting up terminal cleanup..."
    
    # Detect current shell
    local current_shell=""
    if [ -n "$SHELL" ]; then
        case "$SHELL" in
            */zsh) current_shell="zsh" ;;
            */bash) current_shell="bash" ;;
            *) current_shell="bash" ;;
        esac
    else
        current_shell="bash"
    fi
    
    print_info "Detected shell: $current_shell"
    
    # Create a helper script for easy restart
    local helper_script="/tmp/lazyvim_cleanup_terminal.sh"
    cat > "$helper_script" << 'EOF'
#!/bin/bash
echo "🧹 Restarting terminal to complete LazyVim Docker cleanup..."
echo ""
EOF
    echo "exec $current_shell" >> "$helper_script"
    chmod +x "$helper_script"
    
    echo ""
    print_warning "🧹 To complete cleanup and remove any traces:"
    echo ""
    printf "  ${GREEN}Option 1 (Easiest):${NC}\n"
    printf "    ${GREEN}%s${NC}\n" "$helper_script"
    echo ""
    printf "  ${GREEN}Option 2 (Manual):${NC}\n"
    printf "    ${GREEN}exec %s${NC}\n" "$current_shell"
    echo ""
    
    # Check if we can actually read from terminal (not piped)
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ ! -p /dev/stdin ]]; then
        # Interactive mode - try to read from terminal directly
        print_info "✨ Auto-cleanup available!"
        printf "Press ENTER to restart now, or 'n' to skip cleanup: "
        local choice
        if read -r choice < /dev/tty 2>/dev/null; then
            if [[ "$choice" != "n" ]] && [[ "$choice" != "N" ]]; then
                print_info "Restarting terminal for clean environment..."
                exec "$current_shell"
            else
                print_info "Cleanup skipped - environment may show command traces"
            fi
        else
            print_info "💡 Copy and paste the first command to clean your terminal"
            print_info "This ensures no traces of 'lazy' commands remain"
        fi
    else
        # Non-interactive mode (piped or redirected)
        print_info "💡 Copy and paste the first command to clean your terminal"
        print_info "This ensures no traces of 'lazy' commands remain"
    fi
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
    
    # Check if we can actually read from terminal (not piped)
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ ! -p /dev/stdin ]]; then
        # Interactive mode - try to read from terminal directly
        printf "Do you want to remove PATH modifications from shell config? [y/N]: "
        local response
        if read -r response < /dev/tty 2>/dev/null; then
            # Successfully read from terminal
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
        else
            # Failed to read from terminal - treat as non-interactive
            if [[ "${LAZYVIM_REMOVE_PATH:-}" == "true" ]]; then
                print_info "Non-interactive mode: removing PATH modifications (LAZYVIM_REMOVE_PATH=true)"
                # Remove PATH logic here...
                print_step "Removing PATH modifications..."
                local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
                for config in "${shell_configs[@]}"; do
                    if [ -f "$config" ]; then
                        cp "$config" "${config}.backup.$(date +%Y%m%d-%H%M%S)"
                        sed -i.tmp '/# LazyVim Docker - Add local bin to PATH/d' "$config" 2>/dev/null || true
                        sed -i.tmp '/export PATH=.*\.local\/bin.*PATH/d' "$config" 2>/dev/null || true
                        rm -f "${config}.tmp"
                        print_info "Cleaned PATH modifications from: $config"
                    fi
                done
                print_success "PATH modifications removed"
            else
                print_info "Non-interactive mode: keeping PATH modifications"
            fi
        fi
    else
        # Non-interactive mode (piped or redirected)
        if [[ "${LAZYVIM_REMOVE_PATH:-}" == "true" ]]; then
            print_info "Non-interactive mode: removing PATH modifications (LAZYVIM_REMOVE_PATH=true)"
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
        else
            print_info "Non-interactive mode: keeping PATH modifications"
        fi
    fi
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
    
    # Check if we can actually read from terminal (not piped)
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ ! -p /dev/stdin ]]; then
        # Interactive mode - try to read from terminal directly
        printf "Are you sure you want to continue? [y/N]: "
        local response
        if read -r response < /dev/tty 2>/dev/null; then
            # Successfully read from terminal
            case "$response" in
                [yY][eE][sS]|[yY])
                    return 0
                    ;;
                *)
                    print_info "Uninstallation cancelled"
                    exit 0
                    ;;
            esac
        else
            # Failed to read from terminal - treat as non-interactive
            print_info "Cannot read from terminal - treating as non-interactive"
            if [[ "${LAZYVIM_FORCE_UNINSTALL:-}" == "true" ]]; then
                print_info "Proceeding with forced uninstall (LAZYVIM_FORCE_UNINSTALL=true)"
                return 0
            else
                print_info "Uninstallation cancelled - to force, set: LAZYVIM_FORCE_UNINSTALL=true"
                exit 0
            fi
        fi
    else
        # Non-interactive mode (piped or redirected)
        if [[ "${LAZYVIM_FORCE_UNINSTALL:-}" == "true" ]]; then
            print_info "Non-interactive mode: proceeding with forced uninstall (LAZYVIM_FORCE_UNINSTALL=true)"
            return 0
        else
            print_info "Non-interactive mode: uninstallation cancelled for safety"
            print_info "To force uninstall via pipe, set: LAZYVIM_FORCE_UNINSTALL=true"
            print_info ""
            print_info "Examples:"
            printf "  ${GREEN}LAZYVIM_FORCE_UNINSTALL=true curl -fsSL [URL] | bash${NC}\n"
            printf "  ${GREEN}curl -fsSL [URL] | LAZYVIM_FORCE_UNINSTALL=true bash${NC}\n"
            exit 0
        fi
    fi
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
    printf "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash${NC}\n"
    echo ""
    
    # Restart terminal to clean up environment
    restart_terminal
}

# Run main function
main "$@"
