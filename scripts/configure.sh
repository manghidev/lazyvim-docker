#!/bin/bash

# LazyVim Docker - Enhanced Configuration Script v2.0
# Features:
# - Prevents duplicate directory mounts
# - Allows easy unmounting of directories from menu
# - Remembers user decisions (won't ask again for Documents if already configured)
# - Shows clear numbered list of mounted directories
# - Persistent preferences management

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'

# Configuration file to store user preferences
CONFIG_FILE=".lazyvim-docker-config"

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ ${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${NC} $1"
}

log_error() {
    echo -e "${RED}❌ ${NC} $1"
}

log_step() {
    echo -e "${PURPLE}🔧 ${NC} $1"
}

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           LazyVim Docker - Smart Configuration Tool         ║${NC}"
    echo -e "${CYAN}║       Improved Directory & Timezone Manager v2.0           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Load user preferences
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_info "Loaded previous configuration"
    else
        log_info "First time configuration"
    fi
}

# Save user preferences
save_config() {
    cat > "$CONFIG_FILE" << EOF
# LazyVim Docker Configuration - Auto-generated
# Last updated: $(date)
DOCUMENTS_DECISION="${DOCUMENTS_DECISION:-}"
PROJECTS_DECISION="${PROJECTS_DECISION:-}"
PROJECTS_PATH="${PROJECTS_PATH:-}"
LAST_TIMEZONE="${LAST_TIMEZONE:-}"
EOF
    log_info "Configuration saved to $CONFIG_FILE"
}

# Check if a directory mount already exists in docker-compose.yml
is_mount_exists() {
    local host_path="$1"
    
    # Normalize path for comparison (resolve $HOME, relative paths, etc.)
    local normalized_path="$host_path"
    if [[ "$host_path" =~ ^\$HOME ]]; then
        normalized_path="${host_path/\$HOME/$HOME}"
    fi
    
    # Check if mount exists (non-commented line)
    if grep -v "^[[:space:]]*#" docker-compose.yml | grep -q "- $host_path:" || \
       grep -v "^[[:space:]]*#" docker-compose.yml | grep -q "- $normalized_path:"; then
        return 0  # Mount exists
    else
        return 1  # Mount doesn't exist
    fi
}

# Get all current mounts in a structured way
get_current_mounts() {
    local show_numbers="${1:-false}"
    local counter=1
    local mounts_found=false
    local mounts_data=()
    
    echo -e "${CYAN}📁 Current Directory Mounts:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Parse docker-compose.yml for volume mounts
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([^:]+):([^:]+)$ ]]; then
            local host_path="${BASH_REMATCH[1]}"
            local container_path="${BASH_REMATCH[2]}"
            
            # Skip system mounts (cache, npm, etc.)
            if [[ "$container_path" =~ (cache|npm|pip|yarn|\.dotfiles|\.ssh|config/nvim) ]]; then
                continue
            fi
            
            # Expand environment variables for display
            local display_host_path="$host_path"
            if [[ "$host_path" =~ ^\$HOME ]]; then
                display_host_path="${host_path/\$HOME/$HOME}"
            fi
            
            # Store mount data for potential removal
            mounts_data+=("$host_path:$container_path")
            
            # Show numbered list if requested
            if [[ "$show_numbers" == "true" ]]; then
                printf "${YELLOW}%2d.${NC} " "$counter"
            else
                printf "    ${PURPLE}•${NC} "
            fi
            
            printf "${GREEN}Host:${NC} %s\n" "$display_host_path"
            printf "      ${CYAN}→${NC} Container: %s\n" "$container_path"
            
            # Check if directory exists
            if [[ -d "$display_host_path" ]]; then
                printf "      ${BLUE}Status:${NC} ${GREEN}✅ Exists${NC}\n"
            else
                printf "      ${BLUE}Status:${NC} ${RED}❌ Missing${NC}\n"
            fi
            echo ""
            
            counter=$((counter + 1))
            mounts_found=true
        fi
    done < <(grep -v "^[[:space:]]*#" docker-compose.yml | grep -E "^\s*-\s+.*:.*$")
    
    if [[ "$mounts_found" != "true" ]]; then
        echo "  ${GRAY}No custom directory mounts configured${NC}"
        echo ""
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Export mounts data for removal function
    export CURRENT_MOUNTS_DATA="${mounts_data[*]}"
    return $((counter - 1))  # Return total count
}

# Add a directory mount (prevents duplicates)
add_directory_mount() {
    local host_path="$1"
    local container_path="$2"
    
    # Check if mount already exists
    if is_mount_exists "$host_path"; then
        log_warning "Mount already exists: $host_path"
        return 1
    fi
    
    # Check if directory exists
    if [[ ! -d "$host_path" ]]; then
        log_error "Directory does not exist: $host_path"
        return 1
    fi
    
    # Add mount after the Documents line or at the end of volumes section
    if grep -q "Documents:" docker-compose.yml; then
        # Add after Documents line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/\$HOME\/Documents:/a\\
      - $host_path:$container_path" docker-compose.yml
        else
            sed -i "/\$HOME\/Documents:/a\\
      - $host_path:$container_path" docker-compose.yml
        fi
    else
        # Find volumes section and add there
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/volumes:/a\\
      - $host_path:$container_path" docker-compose.yml
        else
            sed -i "/volumes:/a\\
      - $host_path:$container_path" docker-compose.yml
        fi
    fi
    
    log_success "Added mount: $host_path → $container_path"
    return 0
}

# Remove a directory mount by line number
remove_directory_mount() {
    local selection="$1"
    
    # Get current mounts data
    get_current_mounts "false" > /dev/null
    
    if [[ -z "$CURRENT_MOUNTS_DATA" ]]; then
        log_warning "No mounts available to remove"
        return 1
    fi
    
    # Convert space-separated data to array
    IFS=' ' read -ra mounts_array <<< "$CURRENT_MOUNTS_DATA"
    
    # Validate selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt "${#mounts_array[@]}" ]]; then
        log_error "Invalid selection: $selection"
        return 1
    fi
    
    # Get the mount to remove (1-indexed to 0-indexed)
    local mount_to_remove="${mounts_array[$((selection - 1))]}"
    local host_path="${mount_to_remove%:*}"
    local container_path="${mount_to_remove#*:}"
    
    # Remove the mount line from docker-compose.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "\|^[[:space:]]*- $host_path:$container_path|d" docker-compose.yml
    else
        sed -i "\|^[[:space:]]*- $host_path:$container_path|d" docker-compose.yml
    fi
    
    log_success "Removed mount: $host_path → $container_path"
    return 0
}

# Configure timezone with memory
configure_timezone() {
    log_step "Configuring timezone..."
    
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
    local current_tz=$(grep "TIMEZONE:" docker-compose.yml | awk '{print $2}' 2>/dev/null || echo "")
    local default_tz="${system_tz:-America/Mexico_City}"
    
    echo "🌍 Timezone Configuration:"
    echo "  Current in container: ${current_tz:-"Not set"}"
    echo "  System timezone: ${system_tz:-"Could not detect"}"
    echo ""
    
    # If we have a previous timezone decision and it matches current, skip
    if [[ -n "$LAST_TIMEZONE" ]] && [[ "$LAST_TIMEZONE" == "$current_tz" ]]; then
        log_info "Timezone already configured: $current_tz"
        return 0
    fi
    
    echo "Available timezone examples:"
    echo "  - America/New_York"
    echo "  - America/Los_Angeles"  
    echo "  - America/Mexico_City"
    echo "  - Europe/London"
    echo "  - Europe/Madrid"
    echo "  - Asia/Tokyo"
    echo ""
    
    read -p "Enter timezone [$default_tz]: " timezone
    timezone=${timezone:-$default_tz}
    
    # Update docker-compose.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|TIMEZONE:.*|TIMEZONE: $timezone|" docker-compose.yml
    else
        sed -i "s|TIMEZONE:.*|TIMEZONE: $timezone|" docker-compose.yml
    fi
    
    LAST_TIMEZONE="$timezone"
    log_success "Timezone set to: $timezone"
}

# Configure Documents directory with smart state
configure_documents_directory() {
    local default_docs="$HOME/Documents"
    
    echo "📄 Documents Directory Configuration:"
    
    # Check if Documents directory exists
    if [[ ! -d "$default_docs" ]]; then
        log_warning "Documents directory not found: $default_docs"
        return 0
    fi
    
    # Check current state in docker-compose.yml
    local is_enabled=$(grep -v "^[[:space:]]*#" docker-compose.yml | grep -q "\$HOME/Documents:" && echo "yes" || echo "no")
    
    # If we have a previous decision and current state matches, skip asking
    if [[ -n "$DOCUMENTS_DECISION" ]]; then
        if [[ "$DOCUMENTS_DECISION" == "yes" ]] && [[ "$is_enabled" == "yes" ]]; then
            log_info "Documents directory already enabled: $default_docs"
            return 0
        elif [[ "$DOCUMENTS_DECISION" == "no" ]] && [[ "$is_enabled" == "no" ]]; then
            log_info "Documents directory already disabled (user preference)"
            return 0
        fi
    fi
    
    echo "  Path: $default_docs"
    echo "  Status: $([ "$is_enabled" == "yes" ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo ""
    
    local reply
    read -p "Mount Documents directory? [Y/n]: " reply
    
    case "$reply" in
        [nN][oO]|[nN])
            # Disable Documents mounting
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's|^[[:space:]]*- \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            else
                sed -i 's|^[[:space:]]*- \$HOME/Documents:|      # - \$HOME/Documents:|' docker-compose.yml
            fi
            DOCUMENTS_DECISION="no"
            log_success "Documents directory mounting disabled"
            ;;
        *)
            # Enable Documents mounting
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' 's|^[[:space:]]*#[[:space:]]*- \$HOME/Documents:|      - \$HOME/Documents:|' docker-compose.yml
            else
                sed -i 's|^[[:space:]]*#[[:space:]]*- \$HOME/Documents:|      - \$HOME/Documents:|' docker-compose.yml
            fi
            DOCUMENTS_DECISION="yes"
            log_success "Documents directory mounting enabled"
            ;;
    esac
}

# Configure Projects directory with smart state
configure_projects_directory() {
    local default_projects=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        default_projects="$HOME/Developer"
    else
        default_projects="$HOME/Projects"
    fi
    
    echo ""
    echo "💻 Projects Directory Configuration:"
    
    # Get current Projects mount if exists
    local current_projects=$(grep -v "^[[:space:]]*#" docker-compose.yml | grep "Projects:/home/developer/Projects" | sed 's/.*- //' | sed 's/:.*//' || echo "")
    
    # If we have a previous decision and current state matches, skip asking
    if [[ -n "$PROJECTS_DECISION" ]]; then
        if [[ "$PROJECTS_DECISION" == "yes" ]] && [[ -n "$current_projects" ]]; then
            log_info "Projects directory already configured: $current_projects"
            return 0
        elif [[ "$PROJECTS_DECISION" == "no" ]] && [[ -z "$current_projects" ]]; then
            log_info "Projects directory already disabled (user preference)"
            return 0
        fi
    fi
    
    if [[ -n "$current_projects" ]]; then
        echo "  Current: $current_projects"
        echo "  Status: ✅ Enabled"
    else
        echo "  Default: $default_projects"
        echo "  Status: ❌ Not configured"
    fi
    echo ""
    
    local reply
    read -p "Mount Projects directory? [Y/n]: " reply
    
    case "$reply" in
        [nN][oO]|[nN])
            # Remove Projects mounting
            if [[ -n "$current_projects" ]]; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "\|$current_projects.*Projects|d" docker-compose.yml
                else
                    sed -i "\|$current_projects.*Projects|d" docker-compose.yml
                fi
                log_success "Projects directory mounting removed"
            fi
            PROJECTS_DECISION="no"
            ;;
        *)
            local projects_path
            if [[ -n "$current_projects" ]]; then
                read -p "Projects directory path [$current_projects]: " projects_path
                projects_path=${projects_path:-$current_projects}
            else
                read -p "Projects directory path [$default_projects]: " projects_path
                projects_path=${projects_path:-$default_projects}
            fi
            
            if [[ -d "$projects_path" ]]; then
                # Remove existing Projects mount first
                if [[ -n "$current_projects" ]]; then
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        sed -i '' "\|$current_projects.*Projects|d" docker-compose.yml
                    else
                        sed -i "\|$current_projects.*Projects|d" docker-compose.yml
                    fi
                fi
                
                # Add new Projects mount
                add_directory_mount "$projects_path" "/home/developer/Projects"
                
                PROJECTS_DECISION="yes"
                PROJECTS_PATH="$projects_path"
                log_success "Projects directory configured: $projects_path"
            else
                log_error "Directory does not exist: $projects_path"
                PROJECTS_DECISION="no"
            fi
            ;;
    esac
}

# Interactive menu for additional directories
configure_additional_directories() {
    echo ""
    echo "📂 Additional Directory Management:"
    echo ""
    
    while true; do
        echo "Choose an option:"
        echo "  ${GREEN}1.${NC} Add custom directory mount"
        echo "  ${YELLOW}2.${NC} Remove directory mount"
        echo "  ${BLUE}3.${NC} List current mounts"
        echo "  ${RED}4.${NC} Continue with configuration"
        echo ""
        
        read -p "Select option (1-4): " choice
        echo ""
        
        case "$choice" in
            1)
                read -p "Enter directory path to mount: " custom_dir
                if [[ -z "$custom_dir" ]]; then
                    log_warning "No directory specified"
                    continue
                fi
                
                # Expand ~ to $HOME
                if [[ "$custom_dir" =~ ^~ ]]; then
                    custom_dir="${custom_dir/#\~/$HOME}"
                fi
                
                if [[ ! -d "$custom_dir" ]]; then
                    log_error "Directory does not exist: $custom_dir"
                    continue
                fi
                
                local mount_name=$(basename "$custom_dir")
                read -p "Mount as [/home/developer/$mount_name]: " container_path
                container_path=${container_path:-"/home/developer/$mount_name"}
                
                if add_directory_mount "$custom_dir" "$container_path"; then
                    echo ""
                    log_success "Mount added successfully!"
                else
                    echo ""
                    log_error "Failed to add mount"
                fi
                ;;
            2)
                echo "Select directory mount to remove:"
                echo ""
                local mount_count
                mount_count=$(get_current_mounts "true")
                
                if [[ "$mount_count" -eq 0 ]]; then
                    echo ""
                    log_warning "No mounts available to remove"
                    continue
                fi
                
                echo ""
                read -p "Enter number to remove (or 'cancel'): " selection
                
                if [[ "$selection" == "cancel" ]] || [[ "$selection" == "c" ]]; then
                    log_info "Removal cancelled"
                    continue
                fi
                
                if remove_directory_mount "$selection"; then
                    echo ""
                    log_success "Mount removed successfully!"
                else
                    echo ""
                    log_error "Failed to remove mount"
                fi
                ;;
            3)
                get_current_mounts "false"
                ;;
            4)
                break
                ;;
            *)
                log_warning "Invalid option. Please select 1-4."
                ;;
        esac
        echo ""
    done
}

# Main configuration flow
main() {
    print_header
    
    # Load previous configuration
    load_config
    
    log_step "Starting LazyVim Docker configuration..."
    echo ""
    
    # Configure timezone
    configure_timezone
    echo ""
    
    # Configure directories
    log_step "Configuring directory mounts..."
    echo ""
    
    # Configure Documents directory (with memory)
    configure_documents_directory
    
    # Configure Projects directory (with memory)
    configure_projects_directory
    
    # Configure additional directories (interactive menu)
    configure_additional_directories
    
    # Save configuration
    save_config
    
    echo ""
    log_success "Configuration completed!"
    echo ""
    echo "Next steps:"
    echo "  ${CYAN}1.${NC} Run: ${GREEN}make build${NC} or ${GREEN}lazy build${NC} to rebuild the container"
    echo "  ${CYAN}2.${NC} Run: ${GREEN}make start${NC} or ${GREEN}lazy start${NC} to start LazyVim"
    echo ""
    echo "Your mounted directories will be available inside the container at:"
    get_current_mounts "false"
    echo ""
}

# Run main function
main "$@"
