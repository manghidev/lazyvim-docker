#!/bin/bash

# LazyVim Docker Global Commands Installer
# This script installs global commands to use LazyVim Docker from anywhere

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the absolute path of the lazyvim-docker directory
LAZYVIM_DOCKER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Remove the /scripts part from the path
LAZYVIM_DOCKER_PATH="$(dirname "$LAZYVIM_DOCKER_PATH")"

log_info "LazyVim Docker Global Commands Installer"
echo ""
log_info "This will install global 'lazy' commands that you can use from anywhere:"
echo "  lazy start      -> make start"
echo "  lazy enter      -> make enter"
echo "  lazy stop       -> make stop"
echo "  lazy status     -> make status"
echo "  lazy build      -> make build"
echo "  lazy health     -> make health"
echo "  lazy help       -> make help"
echo "  lazy uninstall  -> Complete uninstall"
echo ""

# Check if we're in the correct directory
if [[ ! -f "$LAZYVIM_DOCKER_PATH/Makefile" ]] || [[ ! -f "$LAZYVIM_DOCKER_PATH/docker-compose.yml" ]]; then
    log_error "LazyVim Docker project not found at: $LAZYVIM_DOCKER_PATH"
    exit 1
fi

# Function to install for Zsh
install_zsh() {
    local shell_config="$HOME/.zshrc"
    local marker_start="# LazyVim Docker Global Commands - START"
    local marker_end="# LazyVim Docker Global Commands - END"
    
    # Remove existing installation if present
    if grep -q "$marker_start" "$shell_config" 2>/dev/null; then
        log_info "Removing existing installation from Zsh..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/$marker_start/,/$marker_end/d" "$shell_config"
        else
            sed -i "/$marker_start/,/$marker_end/d" "$shell_config"
        fi
    fi
    
    log_info "Installing global commands for Zsh..."
    
    # Add the new configuration
    cat >> "$shell_config" << EOF

$marker_start
# LazyVim Docker - Global Commands
# Use 'lazy <command>' from anywhere to control LazyVim Docker
lazyvim_docker_path="$LAZYVIM_DOCKER_PATH"

lazy() {
    if [[ \$# -eq 0 ]]; then
        echo "LazyVim Docker - Global Commands"
        echo ""
        echo "Usage: lazy <command>"
        echo ""
        echo "Available commands:"
        echo "  help      Show all available commands"
        echo "  start     Start the container"
        echo "  enter     Enter the container (starts if stopped)"
        echo "  stop      Stop the container"
        echo "  status    Show container status"
        echo "  health    Run health diagnostics"
        echo "  build     Build/rebuild the container"
        echo "  restart   Restart the container"
        echo "  destroy   Destroy everything"
        echo "  clean     Clean up Docker resources"
        echo "  quick     Quick start (build + enter)"
        echo "  logs      Show container logs"
        echo "  backup    Backup configurations"
        echo "  version   Show version"
        echo "  configure Reconfigure directories and timezone"
        echo "  uninstall Remove global commands"
        echo ""
        echo "Examples:"
        echo "  lazy enter     # Enter LazyVim from anywhere"
        echo "  lazy build     # Build the environment"
        return 0
    fi
    
    local cmd="\$1"
    shift
    
    case "\$cmd" in
        help|start|enter|stop|status|health|build|restart|destroy|clean|quick|logs|backup|configure|version)
            echo "🚀 Running: make \$cmd \$@"
            (cd "\$lazyvim_docker_path" && make "\$cmd" "\$@")
            ;;
        uninstall)
            echo "🗑️  Running uninstaller..."
            (cd "\$lazyvim_docker_path" && ./scripts/uninstall-global-commands.sh)
            ;;
        *)
            echo "❌ Unknown command: \$cmd"
            echo "💡 Use 'lazy' to see available commands"
            return 1
            ;;
    esac
}

# Tab completion for lazy command (Zsh)
_lazy_zsh_completion() {
    local commands=(help start enter stop status health build restart destroy clean quick logs backup configure version uninstall)
    _describe 'lazy commands' commands
}

compdef _lazy_zsh_completion lazy
$marker_end
EOF

    log_success "Zsh configuration updated!"
}

# Function to install for Bash
install_bash() {
    local shell_config="$HOME/.bashrc"
    local marker_start="# LazyVim Docker Global Commands - START"
    local marker_end="# LazyVim Docker Global Commands - END"
    
    # Remove existing installation if present
    if grep -q "$marker_start" "$shell_config" 2>/dev/null; then
        log_info "Removing existing installation from Bash..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/$marker_start/,/$marker_end/d" "$shell_config"
        else
            sed -i "/$marker_start/,/$marker_end/d" "$shell_config"
        fi
    fi
    
    log_info "Installing global commands for Bash..."
    
    # Add the new configuration
    cat >> "$shell_config" << EOF

$marker_start
# LazyVim Docker - Global Commands
# Use 'lazy <command>' from anywhere to control LazyVim Docker
lazyvim_docker_path="$LAZYVIM_DOCKER_PATH"

lazy() {
    if [[ \$# -eq 0 ]]; then
        echo "LazyVim Docker - Global Commands"
        echo ""
        echo "Usage: lazy <command>"
        echo ""
        echo "Available commands:"
        echo "  help      Show all available commands"
        echo "  start     Start the container"
        echo "  enter     Enter the container (starts if stopped)"
        echo "  stop      Stop the container"
        echo "  status    Show container status"
        echo "  health    Run health diagnostics"
        echo "  build     Build/rebuild the container"
        echo "  restart   Restart the container"
        echo "  destroy   Destroy everything"
        echo "  clean     Clean up Docker resources"
        echo "  quick     Quick start (build + enter)"
        echo "  logs      Show container logs"
        echo "  backup    Backup configurations"
        echo "  version   Show version"
        echo "  configure Reconfigure directories and timezone"
        echo "  uninstall Remove global commands"
        echo ""
        echo "Examples:"
        echo "  lazy enter     # Enter LazyVim from anywhere"
        echo "  lazy build     # Build the environment"
        return 0
    fi
    
    local cmd="\$1"
    shift
    
    case "\$cmd" in
        help|start|enter|stop|status|health|build|restart|destroy|clean|quick|logs|backup|configure|version)
            echo "🚀 Running: make \$cmd \$@"
            (cd "\$lazyvim_docker_path" && make "\$cmd" "\$@")
            ;;
        uninstall)
            echo "🗑️  Running uninstaller..."
            (cd "\$lazyvim_docker_path" && ./scripts/uninstall-global-commands.sh)
            ;;
        *)
            echo "❌ Unknown command: \$cmd"
            echo "💡 Use 'lazy' to see available commands"
            return 1
            ;;
    esac
}

# Tab completion for lazy command (Bash)
_lazy_completion() {
    local cur="\${COMP_WORDS[COMP_CWORD]}"
    local commands="help start enter stop status health build restart destroy clean quick logs backup configure version uninstall"
    COMPREPLY=(\$(compgen -W "\$commands" -- "\$cur"))
}

complete -F _lazy_completion lazy
$marker_end
EOF

    log_success "Bash configuration updated!"
}

# Main installation function
install_global_commands() {
    log_info "Installing global commands for both Bash and Zsh..."
    
    # Ensure shell config files exist
    touch "$HOME/.bashrc" "$HOME/.zshrc"
    
    # Install for both shells
    install_bash
    install_zsh
    
    echo ""
    log_success "✓ Global 'lazy' commands installed!"
    echo ""
    log_info "Commands installed for both Bash and Zsh:"
    echo "  • Bash: $HOME/.bashrc"
    echo "  • Zsh: $HOME/.zshrc"
    echo ""
    log_info "Usage:"
    echo "  lazy enter     # Enter LazyVim development environment"
    echo "  lazy help      # Show all available commands"
    echo ""
    log_info "To activate:"
    echo "  • Restart your terminal, or"
    echo "  • Run: source ~/.bashrc   (for Bash)"
    echo "  • Run: source ~/.zshrc    (for Zsh)"
    echo ""
    
    # Detect current shell and provide specific activation command
    local current_shell=""
    if [[ -n "$ZSH_VERSION" ]]; then
        current_shell="zsh"
        echo -e "${GREEN}For your current Zsh session, run: source ~/.zshrc${NC}"
    elif [[ -n "$BASH_VERSION" ]]; then
        current_shell="bash"
        echo -e "${GREEN}For your current Bash session, run: source ~/.bashrc${NC}"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        current_shell="zsh"
        echo -e "${GREEN}For your current Zsh session, run: source ~/.zshrc${NC}"
    else
        current_shell="bash"
        echo -e "${GREEN}For your current Bash session, run: source ~/.bashrc${NC}"
    fi
    
    echo ""
}

# Run the installation
install_global_commands
