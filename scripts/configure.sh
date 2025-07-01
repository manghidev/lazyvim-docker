#!/bin/bash

# LazyVim Docker - Configuration Script
# This script helps reconfigure directories and timezone

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                LazyVim Docker - Configuration               ║${NC}"
    echo -e "${CYAN}║              Reconfigure Directories & Timezone             ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Configure timezone
configure_timezone() {
    log_info "Configuring timezone..."
    
    # Detect system timezone
    local system_tz=""
    if command -v timedatectl >/dev/null 2>&1; then
        system_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
    elif [[ -f /etc/timezone ]]; then
        system_tz=$(cat /etc/timezone 2>/dev/null || echo "")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        system_tz=$(ls -la /etc/localtime 2>/dev/null | sed 's/.*zoneinfo\///' || echo "")
    fi
    
    # Get current timezone from docker-compose.yml
    local current_tz=$(grep "TIMEZONE:" docker-compose.yml | awk '{print $2}' || echo "")
    
    # Default timezone if detection fails
    local default_tz="${system_tz:-${current_tz:-America/Mexico_City}}"
    
    echo "Current system timezone: ${system_tz:-"Could not detect"}"
    echo "Current container timezone: ${current_tz:-"Not set"}"
    echo ""
    echo "Available timezone examples:"
    echo "  - America/New_York (EST/EDT)"
    echo "  - America/Los_Angeles (PST/PDT)"
    echo "  - America/Chicago (CST/CDT)"
    echo "  - America/Mexico_City (CST/CDT)"
    echo "  - Europe/London (GMT/BST)"
    echo "  - Europe/Madrid (CET/CEST)"
    echo "  - Europe/Paris (CET/CEST)"
    echo "  - Asia/Tokyo (JST)"
    echo "  - Asia/Shanghai (CST)"
    echo ""
    
    read -p "Enter your timezone [$default_tz]: " user_tz
    user_tz=${user_tz:-$default_tz}
    
    # Update timezone in docker-compose.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/TIMEZONE: .*/TIMEZONE: $user_tz/" docker-compose.yml
        sed -i '' "s/TZ=.*/TZ=$user_tz/" docker-compose.yml
    else
        sed -i "s/TIMEZONE: .*/TIMEZONE: $user_tz/" docker-compose.yml
        sed -i "s/TZ=.*/TZ=$user_tz/" docker-compose.yml
    fi
    
    log_success "Timezone configured: $user_tz"
}

# Configure directories
configure_directories() {
    log_info "Configuring directories to mount..."
    
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
    
    # Show current mounts
    echo "Current volume mounts in docker-compose.yml:"
    grep -E "^\s*-\s+.*:.*$" docker-compose.yml | grep -v "cache\|npm\|pip" | sed 's/^/  /'
    echo ""
    
    # Configure Documents directory
    echo "📁 Documents Directory:"
    if [[ -d "$default_docs" ]]; then
        read -p "Mount Documents directory ($default_docs)? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # Ensure Documents is enabled
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's|^      # - \$HOME/Documents:|      - \$HOME/Documents:|' docker-compose.yml
            else
                sed -i 's|^      # - \$HOME/Documents:|      - \$HOME/Documents:|' docker-compose.yml
            fi
            log_info "Documents directory will be mounted at /home/developer/Documents"
        else
            # Comment out the Documents line
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            else
                sed -i 's|^      - \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            fi
            log_info "Documents directory mounting disabled"
        fi
    fi
    
    # Configure Projects directory
    echo ""
    echo "💻 Projects Directory:"
    local has_projects=$(grep -c "Projects:/home/developer/Projects" docker-compose.yml || echo "0")
    
    if [[ $has_projects -gt 0 ]]; then
        local current_projects=$(grep "Projects:/home/developer/Projects" docker-compose.yml | sed 's/.*- //' | sed 's/:.*//')
        echo "Current Projects directory: $current_projects"
        read -p "Keep current Projects directory? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            # Remove current projects line
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/Projects:\/home\/developer\/Projects/d' docker-compose.yml
            else
                sed -i '/Projects:\/home\/developer\/Projects/d' docker-compose.yml
            fi
            has_projects=0
        fi
    fi
    
    if [[ $has_projects -eq 0 ]]; then
        read -p "Do you want to mount a Projects directory? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            read -p "Enter path to your projects directory [$default_projects]: " projects_dir
            projects_dir=${projects_dir:-$default_projects}
            
            if [[ -d "$projects_dir" ]]; then
                # Add projects directory to docker-compose.yml after Documents line
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "/\$HOME\/Documents:/a\\
      - $projects_dir:/home/developer/Projects" docker-compose.yml
                else
                    sed -i "/\$HOME\/Documents:/a\\
      - $projects_dir:/home/developer/Projects" docker-compose.yml
                fi
                log_success "Projects directory added: $projects_dir -> /home/developer/Projects"
            else
                log_warning "Directory $projects_dir does not exist, you can create it and rebuild later"
            fi
        fi
    fi
    
    # Configure additional directories
    echo ""
    echo "📂 Additional Directories:"
    read -p "Do you want to add/modify additional directories? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Options:"
        echo "  1. Add a new directory"
        echo "  2. Remove a directory mount"
        echo "  3. Done"
        echo ""
        
        while true; do
            read -p "Select option (1-3): " -n 1 -r
            echo
            case $REPLY in
                1)
                    read -p "Enter directory path to mount: " custom_dir
                    if [[ -d "$custom_dir" ]]; then
                        local mount_name=$(basename "$custom_dir")
                        read -p "Mount as [/home/developer/$mount_name]: " container_path
                        container_path=${container_path:-"/home/developer/$mount_name"}
                        
                        # Add custom directory to docker-compose.yml
                        if [[ "$OSTYPE" == "darwin"* ]]; then
                            sed -i '' "/\$HOME\/Documents:/a\\
      - $custom_dir:$container_path" docker-compose.yml
                        else
                            sed -i "/\$HOME\/Documents:/a\\
      - $custom_dir:$container_path" docker-compose.yml
                        fi
                        log_success "Added: $custom_dir -> $container_path"
                    else
                        log_warning "Directory $custom_dir does not exist"
                    fi
                    ;;
                2)
                    echo "Current custom mounts (excluding system directories):"
                    grep -E "^\s*-\s+.*:.*$" docker-compose.yml | grep -v -E "(cache|npm|pip|Documents|\.dotfiles)" | nl
                    read -p "Enter line number to remove (or 'cancel'): " line_num
                    if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        # This is complex, let's just show instructions
                        log_info "Please manually edit docker-compose.yml to remove unwanted mounts"
                    fi
                    ;;
                3)
                    break
                    ;;
                *)
                    echo "Invalid option. Please select 1, 2, or 3."
                    ;;
            esac
            echo ""
        done
    fi
    
    log_success "Directory configuration completed"
}

# Main function
main() {
    print_header
    
    # Check if we're in the right directory
    if [[ ! -f "docker-compose.yml" ]]; then
        log_error "This script must be run from the lazyvim-docker directory"
        echo "If you installed remotely, use: lazy configure"
        exit 1
    fi
    
    log_info "This will help you reconfigure your LazyVim Docker environment."
    echo ""
    
    # Show current configuration
    local current_tz=$(grep "TIMEZONE:" docker-compose.yml | awk '{print $2}' || echo "Not set")
    echo "Current Configuration:"
    echo "  Timezone: $current_tz"
    echo "  Container: $(docker ps -q -f name=lazyvim >/dev/null 2>&1 && echo "Running" || echo "Stopped")"
    echo ""
    
    # Ask what to configure
    echo "What would you like to configure?"
    echo "  1. Timezone only"
    echo "  2. Directory mounts only"
    echo "  3. Both timezone and directories"
    echo "  4. Exit"
    echo ""
    
    read -p "Select option (1-4): " -n 1 -r
    echo
    case $REPLY in
        1)
            configure_timezone
            ;;
        2)
            configure_directories
            ;;
        3)
            configure_timezone
            echo ""
            configure_directories
            ;;
        4)
            log_info "Configuration cancelled"
            exit 0
            ;;
        *)
            log_error "Invalid option selected"
            exit 1
            ;;
    esac
    
    echo ""
    log_success "Configuration completed!"
    echo ""
    echo "Next steps:"
    echo "  1. Rebuild container: make build"
    echo "  2. Or restart if already built: make restart"
    echo "  3. Enter container: make enter"
    echo ""
    echo "Changes will take effect after rebuilding/restarting the container."
}

# Run main function
main "$@"
