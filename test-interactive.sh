#!/bin/bash

# Test Script - Test interactive configuration functions
# This script tests the interactive parts of the remote installer

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Test timezone configuration
test_configure_timezone() {
    print_step "Testing timezone configuration..."
    
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
    read user_tz
    user_tz=${user_tz:-$default_tz}
    
    print_success "Timezone selected: $user_tz"
}

# Test directories configuration
test_configure_directories() {
    print_step "Testing directories configuration..."
    
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
    echo "Testing directory mounting configuration..."
    echo ""
    
    # Test Documents directory
    echo "📁 Documents Directory:"
    if [[ -d "$default_docs" ]]; then
        printf "Mount Documents directory ($default_docs)? (Y/n): "
        read -r reply
        if [[ ! $reply =~ ^[Nn]$ ]]; then
            print_info "Documents directory would be mounted at /home/developer/Documents"
        else
            print_info "Documents directory mounting would be disabled"
        fi
    fi
    
    # Test Projects directory
    echo ""
    echo "💻 Projects Directory:"
    printf "Do you want to mount a Projects directory? (Y/n): "
    read -r reply
    if [[ ! $reply =~ ^[Nn]$ ]]; then
        printf "Enter path to your projects directory [$default_projects]: "
        read projects_dir
        projects_dir=${projects_dir:-$default_projects}
        
        if [[ -d "$projects_dir" ]]; then
            print_success "Projects directory would be added: $projects_dir -> /home/developer/Projects"
        else
            print_info "Directory $projects_dir does not exist, but would be configured anyway"
        fi
    fi
    
    # Test additional directories
    echo ""
    echo "📂 Additional Directories:"
    printf "Do you want to mount any additional directories? (y/N): "
    read -r reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        while true; do
            echo ""
            printf "Enter directory path (or 'done' to finish): "
            read custom_dir
            if [[ "$custom_dir" == "done" ]]; then
                break
            fi
            
            if [[ -d "$custom_dir" ]]; then
                local mount_name=$(basename "$custom_dir")
                printf "Mount as [/home/developer/$mount_name]: "
                read container_path
                container_path=${container_path:-"/home/developer/$mount_name"}
                print_success "Would mount: $custom_dir -> $container_path"
            else
                print_info "Directory $custom_dir does not exist, but would be configured anyway"
            fi
        done
    fi
}

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    LazyVim Docker - Test                    ║${NC}"
echo -e "${CYAN}║                Interactive Configuration Test               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_info "This script tests the interactive configuration functions"
print_info "Testing input compatibility for your shell: $(basename "$SHELL")"
echo ""

test_configure_timezone
echo ""
test_configure_directories

echo ""
print_success "✅ All interactive functions work correctly!"
print_info "The configuration prompts are functioning properly in your shell."
