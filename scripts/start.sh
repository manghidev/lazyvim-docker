#!/bin/bash

# LazyVim Docker - One-Command Setup
# Automatic installation with smart defaults - no questions asked!
# Usage: curl -fsSL https://raw.githubusercontent.com/USER/lazyvim-docker/main/scripts/start.sh | bash

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
REPO_NAME="lazyvim-docker"
INSTALL_DIR="$HOME/.local/share/lazyvim-docker"
BIN_DIR="$HOME/.local/bin"
TEMP_DIR="/tmp/lazyvim-docker-install"
BRANCH="${LAZYVIM_BRANCH:-develop}"

# Print functions
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                LazyVim Docker - Quick Start                 ║${NC}"
    echo -e "${CYAN}║             One Command, Instant Development               ║${NC}"
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

# Smart terminal restart with helper script
restart_terminal() {
    print_step "Setting up terminal restart..."
    
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
    local helper_script="/tmp/lazyvim_restart_terminal.sh"
    cat > "$helper_script" << 'EOF'
#!/bin/bash
echo "🔄 Restarting terminal to activate LazyVim Docker commands..."
echo ""
EOF
    echo "exec $current_shell" >> "$helper_script"
    chmod +x "$helper_script"
    
    echo ""
    print_warning "🔄 To activate 'lazy' commands, choose the EASIEST option:"
    echo ""
    echo "  ${GREEN}Option 1 (Easiest):${NC}"
    echo "    ${GREEN}$helper_script${NC}"
    echo ""
    echo "  ${GREEN}Option 2 (Manual):${NC}"
    echo "    ${GREEN}exec $current_shell${NC}"
    echo ""
    echo "  ${GREEN}Option 3 (Alternative):${NC}"
    echo "    ${GREEN}source ~/.${current_shell}rc${NC}"
    echo ""
    
    # Try to detect if we can restart directly
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ $- == *i* ]]; then
        print_info "✨ Auto-restart available!"
        local choice
        printf "Press ENTER to restart now, or 'n' to do it manually: "
        read -r choice
        
        if [[ "$choice" != "n" ]] && [[ "$choice" != "N" ]]; then
            print_info "Restarting terminal..."
            exec "$current_shell"
        else
            print_info "Manual restart chosen - use the commands above"
        fi
    else
        print_info "💡 Copy and paste the first command to restart your terminal"
        print_info "Then run: ${GREEN}lazy enter${NC}"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    local missing_deps=()
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists docker; then
        missing_deps+=("docker")
    fi
    
    if ! command_exists docker && ! docker compose version >/dev/null 2>&1; then
        print_warning "Docker or Docker Compose not found."
        if ! docker compose version >/dev/null 2>&1; then
            missing_deps+=("docker")
        fi
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Please install the missing dependencies and try again:"
        echo ""
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install ${missing_deps[*]}"
        elif [[ "$OSTYPE" == "linux"* ]]; then
            echo "  # Ubuntu/Debian:"
            echo "  sudo apt-get update && sudo apt-get install -y ${missing_deps[*]}"
            echo ""
            echo "  # CentOS/RHEL:"
            echo "  sudo yum install -y ${missing_deps[*]}"
        fi
        echo ""
        exit 1
    fi
    
    print_success "All requirements satisfied!"
}

# Create installation directories
create_directories() {
    print_step "Creating installation directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$TEMP_DIR"
    
    print_success "Directories created successfully"
}

# Download repository
download_repository() {
    print_step "Downloading LazyVim Docker repository..."
    
    cd "$TEMP_DIR"
    
    if command_exists git; then
        git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$REPO_NAME" >/dev/null 2>&1
    else
        curl -fsSL "${REPO_URL}/archive/${BRANCH}.tar.gz" | tar -xz --strip-components=1 -C "$REPO_NAME" 2>/dev/null
    fi
    
    print_success "Repository downloaded successfully"
}

# Install application
install_application() {
    print_step "Installing LazyVim Docker..."
    
    if [ -d "$INSTALL_DIR" ]; then
        print_info "Removing existing installation..."
        rm -rf "$INSTALL_DIR"
    fi
    
    cp -r "$TEMP_DIR/$REPO_NAME" "$INSTALL_DIR"
    
    print_success "Application installed to $INSTALL_DIR"
}

# Setup PATH for local bin directory
setup_local_bin_path() {
    local shell_config="$1"
    local path_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    
    # Create config file if it doesn't exist
    touch "$shell_config"
    
    # Add to PATH if not already there
    if ! grep -q "$HOME/.local/bin" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# LazyVim Docker - Add local bin to PATH" >> "$shell_config"
        echo "$path_line" >> "$shell_config"
        print_info "Added $HOME/.local/bin to PATH in $shell_config"
    fi
}

# Create global commands
create_global_commands() {
    print_step "Installing global commands..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$BIN_DIR"
    
    # Run the installer script from the project
    cd "$INSTALL_DIR"
    chmod +x ./scripts/install-global-commands.sh
    if ./scripts/install-global-commands.sh; then
        print_success "Global commands installed successfully"
    else
        print_error "Failed to install global commands"
        exit 1
    fi
    
    # Ensure .local/bin is in PATH for both shells
    setup_local_bin_path "$HOME/.bashrc"
    setup_local_bin_path "$HOME/.zshrc"
    
    print_success "Global 'lazy' command is now available"
}

# Auto-configure with smart defaults
auto_configure() {
    print_step "Auto-configuring with smart defaults..."
    
    cd "$INSTALL_DIR"
    
    # Detect and set timezone
    local system_tz=""
    if command -v timedatectl >/dev/null 2>&1; then
        system_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
    elif [[ -f /etc/timezone ]]; then
        system_tz=$(cat /etc/timezone 2>/dev/null || echo "")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        system_tz=$(ls -la /etc/localtime 2>/dev/null | sed 's/.*zoneinfo\///' || echo "")
    fi
    
    local default_tz="${system_tz:-America/Mexico_City}"
    
    # Update timezone in docker-compose.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|TIMEZONE: .*|TIMEZONE: $default_tz|" docker-compose.yml
        sed -i '' "s|TZ=.*|TZ=$default_tz|" docker-compose.yml
    else
        sed -i "s|TIMEZONE: .*|TIMEZONE: $default_tz|" docker-compose.yml
        sed -i "s|TZ=.*|TZ=$default_tz|" docker-compose.yml
    fi
    
    print_success "Timezone configured: $default_tz"
    
    # Auto-configure directories
    local default_docs="$HOME/Documents"
    local default_projects=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        default_projects="$HOME/Developer"
    else
        default_projects="$HOME/Projects"
    fi
    
    # Configure Documents automatically if exists
    if [[ -d "$default_docs" ]]; then
        print_success "Documents directory will be mounted: $default_docs"
    else
        # Comment out the Documents line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
        else
            sed -i 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
        fi
        print_info "Documents directory not found, mounting disabled"
    fi
    
    # Configure Projects automatically if exists
    if [[ -d "$default_projects" ]]; then
        # Add projects directory to docker-compose.yml
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/\$HOME\/Documents:/a\\
      - $default_projects:/home/developer/Projects" docker-compose.yml
        else
            sed -i "/\$HOME\/Documents:/a\\
      - $default_projects:/home/developer/Projects" docker-compose.yml
        fi
        print_success "Projects directory added: $default_projects"
    else
        print_info "Projects directory not found: $default_projects"
    fi
    
    print_success "Auto-configuration completed with smart defaults"
}

# Build environment
build_environment() {
    print_step "Building Docker environment..."
    
    cd "$INSTALL_DIR"
    
    print_info "This may take a few minutes..."
    if make build; then
        print_success "Docker environment built successfully"
    else
        print_warning "Docker build failed, but installation completed. You can run 'lazy build' later."
    fi
}

# Cleanup
cleanup() {
    print_step "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    print_success "Cleanup completed"
}

# Main installation process
main() {
    print_header
    
    print_info "Starting LazyVim Docker simple installation..."
    print_info "Installation directory: $INSTALL_DIR"
    print_info "Binary directory: $BIN_DIR"
    print_info "Using smart defaults (no interactive input required)"
    echo ""
    
    check_requirements
    create_directories
    download_repository
    install_application
    create_global_commands
    auto_configure
    build_environment
    cleanup
    
    echo ""
    print_success "🎉 LazyVim Docker installed successfully!"
    echo ""
    print_info "Configuration applied:"
    echo "  • Timezone: Auto-detected from system"
    echo "  • Documents: Auto-mounted if exists"
    echo "  • Projects: Auto-mounted if exists"
    echo ""
    print_info "Usage:"
    echo "  ${GREEN}lazy enter${NC}     # Enter LazyVim development environment"
    echo "  ${GREEN}lazy start${NC}     # Start the container"
    echo "  ${GREEN}lazy stop${NC}      # Stop the container"
    echo "  ${GREEN}lazy status${NC}    # Check container status"
    echo "  ${GREEN}lazy configure${NC} # Reconfigure directories and timezone"
    echo "  ${GREEN}lazy update${NC}    # Update to latest version"
    echo "  ${GREEN}lazy uninstall${NC} # Uninstall everything"
    echo "  ${GREEN}lazy help${NC}      # Show all available commands"
    echo ""
    print_info "To customize configuration later:"
    echo "  Run: ${GREEN}lazy configure${NC}"
    echo ""
    print_info "Happy coding! 🚀"
    echo ""
    
    # Restart terminal to make commands available immediately
    restart_terminal
}

# Run main function
main "$@"
