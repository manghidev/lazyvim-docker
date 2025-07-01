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

# Configure timezone
configure_timezone() {
    print_step "Configuring timezone..."
    
    # Detect system timezone
    local system_tz=""
    if command -v timedatectl >/dev/null 2>&1; then
        system_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
    elif [[ -f /etc/timezone ]]; then
        system_tz=$(cat /etc/timezone 2>/dev/null || echo "")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        system_tz=$(ls -la /etc/localtime 2>/dev/null | sed 's/.*zoneinfo\///' || echo "")
    fi
    
    # Default timezone if detection fails
    local default_tz="${system_tz:-America/Mexico_City}"
    
    echo "Current system timezone detected: ${system_tz:-"Could not detect"}"
    echo "Available timezone examples:"
    echo "  - America/New_York"
    echo "  - America/Los_Angeles"
    echo "  - America/Mexico_City"
    echo "  - Europe/London"
    echo "  - Europe/Madrid"
    echo "  - Asia/Tokyo"
    echo ""
    
    printf "Enter your timezone [$default_tz]: "
    read user_tz </dev/tty
    user_tz=${user_tz:-$default_tz}
    
    # Update timezone in docker-compose.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/TIMEZONE: .*/TIMEZONE: $user_tz/" docker-compose.yml
        sed -i '' "s/TZ=.*/TZ=$user_tz/" docker-compose.yml
    else
        sed -i "s/TIMEZONE: .*/TIMEZONE: $user_tz/" docker-compose.yml
        sed -i "s/TZ=.*/TZ=$user_tz/" docker-compose.yml
    fi
    
    print_success "Timezone configured: $user_tz"
}

# Configure directories
configure_directories() {
    print_step "Configuring directories to mount..."
    
    # Detect OS
    local os_type=""
    local default_docs="$HOME/Documents"
    local default_projects=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macOS"
        default_projects="$HOME/Developer"
    else
        os_type="Linux"
        default_projects="$HOME/Projects"
    fi
    
    echo "Detected OS: $os_type"
    echo "The container will mount directories so you can access your files inside the development environment."
    echo ""
    
    # Configure Documents directory
    echo "📁 Documents Directory:"
    if [[ -d "$default_docs" ]]; then
        printf "Mount Documents directory ($default_docs)? (Y/n): "
        read -r reply </dev/tty
        if [[ ! $reply =~ ^[Nn]$ ]]; then
            print_info "Documents directory will be mounted at /home/developer/Documents"
        else
            # Comment out the Documents line
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            else
                sed -i 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            fi
            print_info "Documents directory mounting disabled"
        fi
    fi
    
    # Configure Projects directory
    echo ""
    echo "💻 Projects Directory:"
    printf "Do you want to mount a Projects directory? (Y/n): "
    read -r reply </dev/tty
    if [[ ! $reply =~ ^[Nn]$ ]]; then
        printf "Enter path to your projects directory [$default_projects]: "
        read projects_dir </dev/tty
        projects_dir=${projects_dir:-$default_projects}
        
        if [[ -d "$projects_dir" ]]; then
            # Add projects directory to docker-compose.yml
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/\$HOME\/Documents:/a\\
      - $projects_dir:/home/developer/Projects" docker-compose.yml
            else
                sed -i "/\$HOME\/Documents:/a\\
      - $projects_dir:/home/developer/Projects" docker-compose.yml
            fi
            print_success "Projects directory added: $projects_dir -> /home/developer/Projects"
        else
            print_warning "Directory $projects_dir does not exist, you can add it later"
        fi
    fi
    
    # Configure additional directories
    echo ""
    echo "📂 Additional Directories:"
    printf "Do you want to mount any additional directories? (y/N): "
    read -r reply </dev/tty
    if [[ $reply =~ ^[Yy]$ ]]; then
        local counter=1
        while true; do
            echo ""
            printf "Enter directory path (or 'done' to finish): "
            read custom_dir </dev/tty
            if [[ "$custom_dir" == "done" ]]; then
                break
            fi
            
            if [[ -d "$custom_dir" ]]; then
                local mount_name=$(basename "$custom_dir")
                printf "Mount as [/home/developer/$mount_name]: "
                read container_path </dev/tty
                container_path=${container_path:-"/home/developer/$mount_name"}
                
                # Add custom directory to docker-compose.yml
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "/\$HOME\/Documents:/a\\
      - $custom_dir:$container_path" docker-compose.yml
                else
                    sed -i "/\$HOME\/Documents:/a\\
      - $custom_dir:$container_path" docker-compose.yml
                fi
                print_success "Added: $custom_dir -> $container_path"
            else
                print_warning "Directory $custom_dir does not exist, skipping"
            fi
            
            counter=$((counter + 1))
            if [[ $counter -gt 5 ]]; then
                print_info "Maximum directories reached"
                break
            fi
        done
    fi
    
    print_success "Directory configuration completed"
}

# Initial setup
initial_setup() {
    print_step "Running initial setup..."
    
    cd "$INSTALL_DIR"
    
    echo ""
    print_info "Let's configure your LazyVim Docker environment..."
    echo ""
    
    # Ask for configuration
    configure_timezone
    echo ""
    configure_directories
    echo ""
    
    # Build the Docker environment
    print_info "Building Docker environment (this may take a few minutes)..."
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
    echo "  ${GREEN}lazy configure${NC} # Reconfigure directories and timezone"
    echo "  ${GREEN}lazy update${NC}    # Update to latest version"
    echo "  ${GREEN}lazy uninstall${NC} # Uninstall everything"
    echo "  ${GREEN}lazy help${NC}      # Show all available commands"
    echo ""
    print_info "To get started:"
    echo "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC} (or ~/.bashrc)"
    echo "  2. Run: ${GREEN}lazy enter${NC}"
    echo ""
    print_info "To reconfigure directories or timezone later:"
    echo "  Run: ${GREEN}lazy configure${NC}"
    echo ""
    print_info "Happy coding! 🚀"
}

# Run main function
main "$@"
