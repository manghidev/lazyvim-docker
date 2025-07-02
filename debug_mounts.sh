#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'

# Test get_current_mounts with numbers
get_current_mounts_test() {
    local show_numbers="${1:-false}"
    local counter=1
    local mounts_found=false
    local mounts_data=()
    
    printf "${CYAN}📁 Current Directory Mounts (Test):${NC}\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    # Parse docker-compose.yml for volume mounts - look in volumes section
    local in_volumes_section=false
    while IFS= read -r line; do
        # Debug output
        echo "DEBUG: Processing line: $line" >&2
        
        # Check if we're entering volumes section
        if [[ "$line" =~ ^[[:space:]]*volumes:[[:space:]]*$ ]]; then
            in_volumes_section=true
            echo "DEBUG: Entered volumes section" >&2
            continue
        fi
        
        # Check if we're leaving volumes section (next main section)
        if [[ "$in_volumes_section" == "true" ]] && [[ "$line" =~ ^[[:space:]]*[a-zA-Z_-]+:[[:space:]]*$ ]] && [[ ! "$line" =~ volumes: ]]; then
            in_volumes_section=false
            echo "DEBUG: Left volumes section" >&2
            continue
        fi
        
        # Process volume mounts only within volumes section
        if [[ "$in_volumes_section" == "true" ]] && [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([^:]+):([^:]+)$ ]]; then
            local host_path="${BASH_REMATCH[1]}"
            local container_path="${BASH_REMATCH[2]}"
            
            echo "DEBUG: Found mount: $host_path -> $container_path" >&2
            
            # Skip ONLY system caches and configs, NOT user dotfiles
            if [[ "$container_path" =~ (/root/\.cache|/home/developer/\.cache|/tmp|cache|\.npm|\.pip|\.yarn) ]]; then
                echo "DEBUG: Skipping system mount: $container_path" >&2
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
            printf "\n"
            
            counter=$((counter + 1))
            mounts_found=true
        fi
    done < docker-compose.yml
    
    if [[ "$mounts_found" != "true" ]]; then
        printf "  ${GRAY}No custom directory mounts configured${NC}\n"
        printf "\n"
    fi
    
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    # Export mounts data for removal function
    export CURRENT_MOUNTS_DATA="${mounts_data[*]}"
    echo "DEBUG: Total mounts found: $((counter - 1))" >&2
    echo "DEBUG: Mounts data: $CURRENT_MOUNTS_DATA" >&2
    return $((counter - 1))  # Return total count
}

echo "Testing get_current_mounts with show_numbers=true"
get_current_mounts_test "true"
