#!/bin/bash

# LazyVim Docker Setup Script
# This script helps with initial setup and configuration

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

print_header() {
    echo -e "${BLUE}=== LazyVim Docker Setup ===${NC}"
    echo "This script will help you set up your LazyVim Docker environment"
    echo ""
}

# Create dotfiles structure
create_dotfiles_structure() {
    log_info "Creating dotfiles structure..."
    
    mkdir -p .dotfiles/.config/{nvim,lazygit}
    mkdir -p .dotfiles/.cache/{nvim,zsh}
    mkdir -p .dotfiles/.local/share
    
    # Create basic .zshrc if it doesn't exist
    if [[ ! -f ".dotfiles/.zshrc" ]]; then
        cat > .dotfiles/.zshrc << 'EOF'
# LazyVim Docker Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

source $ZSH/oh-my-zsh.sh

# Custom aliases
alias ll="exa -la"
alias cat="bat"
alias find="fd"
alias vim="nvim"
alias vi="nvim"
alias lg="lazygit"

# Environment variables
export EDITOR=nvim
export VISUAL=nvim
export PAGER=bat

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
        log_success "Created basic .zshrc"
    fi
    
    # Create basic .p10k.zsh if it doesn't exist
    if [[ ! -f ".dotfiles/.p10k.zsh" ]]; then
        touch .dotfiles/.p10k.zsh
        log_info "Created empty .p10k.zsh (will be configured on first run)"
    fi
    
    log_success "Dotfiles structure created"
}

# Configure git settings
configure_git() {
    log_info "Git configuration setup"
    echo "Let's configure git for your container environment"
    echo ""
    
    read -p "Enter your git username: " GIT_USER
    read -p "Enter your git email: " GIT_EMAIL
    
    if [[ -n "$GIT_USER" && -n "$GIT_EMAIL" ]]; then
        mkdir -p .dotfiles/.config/git
        cat > .dotfiles/.config/git/config << EOF
[user]
    name = $GIT_USER
    email = $GIT_EMAIL

[init]
    defaultBranch = main

[core]
    editor = nvim
    pager = bat

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --decorate
    last = log -1 HEAD
    unstage = reset HEAD --
EOF
        log_success "Git configuration created"
    else
        log_warning "Skipping git configuration"
    fi
}

# Configure volumes in docker-compose.yml
configure_volumes() {
    log_info "Volume configuration"
    echo "Let's configure the directories you want to mount in your container"
    echo ""
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        DEFAULT_DOCS="$HOME/Documents"
        DEFAULT_PROJECTS="$HOME/Developer"
    else
        OS="Linux"
        DEFAULT_DOCS="$HOME/Documents"
        DEFAULT_PROJECTS="$HOME/Projects"
    fi
    
    echo "Detected OS: $OS"
    echo ""
    
    echo "Current default mounts:"
    echo "  - Documents: $DEFAULT_DOCS"
    echo ""
    
    read -p "Do you want to add a Projects directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter the path to your projects directory [$DEFAULT_PROJECTS]: " PROJECTS_DIR
        PROJECTS_DIR=${PROJECTS_DIR:-$DEFAULT_PROJECTS}
        
        if [[ -d "$PROJECTS_DIR" ]]; then
            # Add projects directory to docker-compose.yml
            sed -i.bak "/Documents:/a\\
      - $PROJECTS_DIR:/home/developer/Projects" docker-compose.yml
            log_success "Added Projects directory: $PROJECTS_DIR"
        else
            log_warning "Directory $PROJECTS_DIR does not exist, skipping"
        fi
    fi
    
    read -p "Do you want to add any other custom directories? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while true; do
            read -p "Enter local directory path (or 'done' to finish): " CUSTOM_DIR
            if [[ "$CUSTOM_DIR" == "done" ]]; then
                break
            fi
            
            if [[ -d "$CUSTOM_DIR" ]]; then
                MOUNT_NAME=$(basename "$CUSTOM_DIR")
                read -p "Mount as [/home/developer/$MOUNT_NAME]: " CONTAINER_PATH
                CONTAINER_PATH=${CONTAINER_PATH:-"/home/developer/$MOUNT_NAME"}
                
                # Add custom directory to docker-compose.yml
                sed -i.bak "/Documents:/a\\
      - $CUSTOM_DIR:$CONTAINER_PATH" docker-compose.yml
                log_success "Added custom directory: $CUSTOM_DIR -> $CONTAINER_PATH"
            else
                log_warning "Directory $CUSTOM_DIR does not exist, skipping"
            fi
        done
    fi
}

# Main setup function
main() {
    print_header
    
    # Check if we're in the right directory
    if [[ ! -f "docker-compose.yml" ]]; then
        log_error "This script must be run from the lazyvim-docker directory"
        exit 1
    fi
    
    # Create dotfiles structure
    create_dotfiles_structure
    echo ""
    
    # Configure git
    read -p "Do you want to configure git settings? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_git
        echo ""
    fi
    
    # Configure volumes
    read -p "Do you want to configure volume mounts? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_volumes
        echo ""
    fi
    
    # Make scripts executable
    log_info "Making scripts executable..."
    chmod +x *.sh scripts/*.sh
    log_success "Scripts are now executable"
    echo ""
    
    # Final message
    log_success "Setup completed!"
    echo ""
    echo "Next steps:"
    echo "  1. Run 'make build' or './build.sh' to build the environment"
    echo "  2. Run 'make enter' or './init.sh' to start and enter the container"
    echo "  3. Configure Neovim and other tools as needed"
    echo ""
    echo "Useful commands:"
    echo "  - 'make help' - Show all available commands"
    echo "  - 'make status' - Check environment status"
    echo "  - './scripts/health-check.sh' - Run health check"
}

# Run main function
main "$@"
