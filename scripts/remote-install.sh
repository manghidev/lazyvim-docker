#!/bin/bash

# LazyVim Docker - Remote Installation Script
# This script downloads and installs LazyVim Docker environment directly from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/USER/lazyvim-docker/main/scripts/remote-install.sh | bash

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

# Print functions
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║             LazyVim Docker - Remote Installer               ║${NC}"
    echo -e "${CYAN}║                   Easy One-Command Setup                    ║${NC}"
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

# Create necessary directories
create_directories() {
    print_step "Creating installation directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$TEMP_DIR"
    
    print_success "Directories created successfully"
}

# Download the repository
download_repository() {
    print_step "Downloading LazyVim Docker repository..."
    
    # Remove temp directory if it exists
    rm -rf "$TEMP_DIR"
    
    # Clone the repository to temp directory
    if git clone --depth 1 "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1; then
        print_success "Repository downloaded successfully"
    else
        print_error "Failed to download repository from $REPO_URL"
        exit 1
    fi
}

# Install the application
install_application() {
    print_step "Installing LazyVim Docker..."
    
    # Remove existing installation
    if [ -d "$INSTALL_DIR" ]; then
        print_info "Removing existing installation..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Move from temp to install directory
    mv "$TEMP_DIR" "$INSTALL_DIR"
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/scripts/"*.sh
    chmod +x "$INSTALL_DIR/Makefile"
    
    print_success "Application installed to $INSTALL_DIR"
}

# Create global commands
create_global_commands() {
    print_step "Creating global commands..."
    
    # Create the main lazy command
    cat > "$BIN_DIR/lazy" << 'EOF'
#!/bin/bash

# LazyVim Docker - Global Command
# This script provides global access to LazyVim Docker functionality

LAZYVIM_INSTALL_DIR="$HOME/.local/share/lazyvim-docker"

# Check if installation exists
if [ ! -d "$LAZYVIM_INSTALL_DIR" ]; then
    echo "❌ LazyVim Docker not found. Please reinstall:"
    echo "   curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash"
    exit 1
fi

# Change to install directory and run make command
cd "$LAZYVIM_INSTALL_DIR"

# Handle special commands
case "$1" in
    uninstall)
        echo "🗑️  Uninstalling LazyVim Docker..."
        bash "$LAZYVIM_INSTALL_DIR/scripts/remote-uninstall.sh"
        ;;
    update)
        echo "🔄 Updating LazyVim Docker..."
        bash "$LAZYVIM_INSTALL_DIR/scripts/remote-update.sh"
        ;;
    *)
        # Pass all other commands to make
        make "$@"
        ;;
esac
EOF

    chmod +x "$BIN_DIR/lazy"
    
    # Add bin directory to PATH if not already there
    add_to_path
    
    print_success "Global command 'lazy' created"
}

# Add bin directory to PATH
add_to_path() {
    local shell_config=""
    local path_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    
    # Determine shell config file
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        shell_config="$HOME/.bashrc"
        # Also check .bash_profile on macOS
        if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "$HOME/.bash_profile" ]]; then
            shell_config="$HOME/.bash_profile"
        fi
    else
        # Default to .bashrc
        shell_config="$HOME/.bashrc"
    fi
    
    # Add to PATH if not already there
    if ! grep -q "$HOME/.local/bin" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# LazyVim Docker - Add local bin to PATH" >> "$shell_config"
        echo "$path_line" >> "$shell_config"
        print_info "Added $HOME/.local/bin to PATH in $shell_config"
    fi
}

# Initial setup
initial_setup() {
    print_step "Running initial setup..."
    
    cd "$INSTALL_DIR"
    
    # Build the Docker environment
    print_info "Building Docker environment (this may take a few minutes)..."
    if make build; then
        print_success "Docker environment built successfully"
    else
        print_warning "Docker build failed, but installation completed. You can run 'lazyvim build' later."
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
    
    print_info "Starting LazyVim Docker remote installation..."
    print_info "Installation directory: $INSTALL_DIR"
    print_info "Binary directory: $BIN_DIR"
    echo ""
    
    check_requirements
    create_directories
    download_repository
    install_application
    create_global_commands
    initial_setup
    cleanup
    
    echo ""
    print_success "🎉 LazyVim Docker installed successfully!"
    echo ""
    print_info "Usage:"
    echo "  ${GREEN}lazy enter${NC}     # Enter LazyVim development environment"
    echo "  ${GREEN}lazy start${NC}     # Start the container"
    echo "  ${GREEN}lazy stop${NC}      # Stop the container"
    echo "  ${GREEN}lazy status${NC}    # Check container status"
    echo "  ${GREEN}lazy update${NC}    # Update to latest version"
    echo "  ${GREEN}lazy uninstall${NC} # Uninstall everything"
    echo "  ${GREEN}lazy help${NC}      # Show all available commands"
    echo ""
    print_info "To get started:"
    echo "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC} (or ~/.bashrc)"
    echo "  2. Run: ${GREEN}lazy enter${NC}"
    echo ""
    print_info "Happy coding! 🚀"
}

# Run main function
main "$@"
