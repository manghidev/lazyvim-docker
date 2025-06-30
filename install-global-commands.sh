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

log_info "LazyVim Docker Global Commands Installer"
echo ""
log_info "This will install global 'lazy' commands that you can use from anywhere:"
echo "  lazy start    -> make start"
echo "  lazy enter    -> make enter"
echo "  lazy stop     -> make stop"
echo "  lazy status   -> make status"
echo "  lazy build    -> make build"
echo "  lazy health   -> make health"
echo "  lazy help     -> make help"
echo ""

# Check if we're in the correct directory
if [[ ! -f "Makefile" ]] || [[ ! -f "docker-compose.yml" ]]; then
    log_error "This script must be run from the lazyvim-docker directory"
    exit 1
fi

# Function to install for Zsh
install_zsh() {
    local shell_config="$HOME/.zshrc"
    local marker_start="# LazyVim Docker Global Commands - START"
    local marker_end="# LazyVim Docker Global Commands - END"
    
    # Remove existing installation if present
    if grep -q "$marker_start" "$shell_config" 2>/dev/null; then
        log_info "Removing existing installation..."
        sed -i.bak "/$marker_start/,/$marker_end/d" "$shell_config"
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
        echo ""
        echo "Examples:"
        echo "  lazy enter     # Enter LazyVim from anywhere"
        echo "  lazy status    # Check container status"
        echo "  lazy health    # Run full diagnostics"
        echo ""
        return 0
    fi
    
    local cmd="\$1"
    shift
    
    case "\$cmd" in
        help|start|enter|stop|status|health|build|restart|destroy|clean|quick|logs|backup|version)
            echo "🚀 Running: make \$cmd \$@"
            (cd "\$lazyvim_docker_path" && make "\$cmd" "\$@")
            ;;
        *)
            echo "❌ Unknown command: \$cmd"
            echo "💡 Use 'lazy' to see available commands"
            return 1
            ;;
    esac
}

# Tab completion for lazy command
_lazy_completion() {
    local commands=(help start enter stop status health build restart destroy clean quick logs backup version)
    _describe 'commands' commands
}

if [[ -n "\$ZSH_VERSION" ]]; then
    compdef _lazy_completion lazy
fi
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
        log_info "Removing existing installation..."
        sed -i.bak "/$marker_start/,/$marker_end/d" "$shell_config"
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
        echo ""
        echo "Examples:"
        echo "  lazy enter     # Enter LazyVim from anywhere"
        echo "  lazy status    # Check container status"
        echo "  lazy health    # Run full diagnostics"
        echo ""
        return 0
    fi
    
    local cmd="\$1"
    shift
    
    case "\$cmd" in
        help|start|enter|stop|status|health|build|restart|destroy|clean|quick|logs|backup|version)
            echo "🚀 Running: make \$cmd \$@"
            (cd "\$lazyvim_docker_path" && make "\$cmd" "\$@")
            ;;
        *)
            echo "❌ Unknown command: \$cmd"
            echo "💡 Use 'lazy' to see available commands"
            return 1
            ;;
    esac
}

# Tab completion for lazy command (basic)
_lazy_completion() {
    local cur="\${COMP_WORDS[COMP_CWORD]}"
    local commands="help start enter stop status health build restart destroy clean quick logs backup version"
    COMPREPLY=(\$(compgen -W "\$commands" -- "\$cur"))
}

complete -F _lazy_completion lazy
$marker_end
EOF

    log_success "Bash configuration updated!"
}

# Detect current shell and install accordingly
if [[ -n "$ZSH_VERSION" ]]; then
    install_zsh
elif [[ -n "$BASH_VERSION" ]]; then
    install_bash
else
    log_warning "Unsupported shell. Installing for Zsh by default..."
    install_zsh
fi

echo ""
log_success "Global commands installed successfully!"
echo ""
log_info "To start using the commands:"
echo ""
if [[ -n "$ZSH_VERSION" ]]; then
    echo "  source ~/.zshrc"
else
    echo "  source ~/.bashrc"
fi
echo ""
log_info "Or restart your terminal."
echo ""
log_info "Then you can use from anywhere:"
echo "  ${GREEN}lazy enter${NC}     # Enter LazyVim"
echo "  ${GREEN}lazy status${NC}    # Check status"
echo "  ${GREEN}lazy health${NC}    # Run diagnostics"
echo "  ${GREEN}lazy${NC}           # Show all commands"
echo ""
log_warning "Note: The 'lazy' command will always execute from:"
echo "  $LAZYVIM_DOCKER_PATH"
