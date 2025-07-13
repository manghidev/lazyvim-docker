#!/bin/bash

# LazyVim Docker - Smart Update Script
# Interactive update with version checking and user prompts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/manghidev/lazyvim-docker"
CURRENT_DIR="$(pwd)"
BACKUP_DIR="./backups"

# Print functions
print_header() {
    printf "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║           LazyVim Docker - Smart Updater                    ║${NC}\n"
    printf "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
}

print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[✓]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[⚠]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[✗]${NC} %s\n" "$1"
}

print_step() {
    printf "${PURPLE}[STEP]${NC} %s\n" "$1"
}

# Ask yes/no question with default
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"
    local prompt
    
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    printf "${BOLD}${CYAN}[?]${NC} %s %s: " "$question" "$prompt"
    read -r response
    
    case "$response" in
        "")
            [ "$default" = "y" ]
            ;;
        [yY][eE][sS]|[yY])
            return 0
            ;;
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            printf "${YELLOW}Por favor responde 'y' o 'n'${NC}\n"
            ask_yes_no "$question" "$default"
            ;;
    esac
}

# Check if we're in a git repository
check_git_repo() {
    if [ ! -d ".git" ]; then
        print_error "No estás en un repositorio git de LazyVim Docker"
        print_info "Este script debe ejecutarse desde la carpeta del proyecto"
        exit 1
    fi
}

# Get current version
get_current_version() {
    if [ -f "VERSION" ]; then
        cat "VERSION" | tr -d '\n'
    else
        echo "unknown"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    if command -v curl >/dev/null 2>&1; then
        local latest=$(curl -s "https://api.github.com/repos/manghidev/lazyvim-docker/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "")
        
        if [ -z "$latest" ]; then
            # Fallback: check the remote main branch for latest commit
            local remote_commit=$(git ls-remote origin main 2>/dev/null | cut -f1 | cut -c1-7 || echo "")
            if [ -n "$remote_commit" ]; then
                latest="main-$remote_commit"
            else
                latest="main"
            fi
        fi
        
        echo "$latest"
    else
        echo "unknown"
    fi
}

# Get remote commit info
get_remote_commit_info() {
    local current_commit=$(git rev-parse HEAD 2>/dev/null | cut -c1-7 || echo "unknown")
    local remote_commit=$(git ls-remote origin main 2>/dev/null | cut -f1 | cut -c1-7 || echo "unknown")
    
    printf "  🔹 Commit actual:  ${CYAN}%s${NC}\n" "$current_commit"
    printf "  🔹 Commit remoto:  ${GREEN}%s${NC}\n" "$remote_commit"
    
    # Check if there are new commits
    if [ "$current_commit" != "$remote_commit" ] && [ "$remote_commit" != "unknown" ]; then
        return 0  # New commits available
    else
        return 1  # No new commits
    fi
}

# Compare versions
version_is_newer() {
    local current="$1"
    local latest="$2"
    
    # If latest version is unknown, can't update
    [ "$latest" = "unknown" ] && return 1
    
    # If current version is unknown or dev, consider latest newer
    [ "$current" = "unknown" ] || [ "$current" = "dev" ] && return 0
    
    # Normalize versions (remove 'v' prefix if present)
    current=$(echo "$current" | sed 's/^v//')
    latest=$(echo "$latest" | sed 's/^v//')
    
    # If versions are exactly the same, check git commits
    if [ "$current" = "$latest" ]; then
        # Check if there are new commits even with same version
        get_remote_commit_info >/dev/null 2>&1
        return $?
    fi
    
    # Different versions, consider it newer
    return 0
}

# Create backup
create_backup() {
    local backup_name="lazyvim-docker-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    print_step "Creando backup de la configuración actual..."
    
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$backup_path"
    
    # Backup important directories and files
    if [ -d ".dotfiles" ]; then
        cp -r ".dotfiles" "$backup_path/"
        print_info "✓ Backup de .dotfiles"
    fi
    
    if [ -f "VERSION" ]; then
        cp "VERSION" "$backup_path/"
        print_info "✓ Backup de VERSION"
    fi
    
    # Backup any user configurations
    for config_file in "docker-compose.override.yml" ".env.local"; do
        if [ -f "$config_file" ]; then
            cp "$config_file" "$backup_path/"
            print_info "✓ Backup de $config_file"
        fi
    done
    
    # Store backup path for reference
    echo "$backup_path" > /tmp/lazyvim-last-backup
    
    print_success "Backup creado: $backup_name"
    return 0
}

# Update from git
update_from_git() {
    print_step "Descargando últimos cambios desde GitHub..."
    
    # Fetch latest changes
    if git fetch origin main >/dev/null 2>&1; then
        print_info "✓ Cambios descargados desde origin/main"
    else
        print_warning "No se pudieron descargar los cambios remotos"
        return 1
    fi
    
    # Check if there are actually new changes
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    
    if [ "$local_commit" = "$remote_commit" ]; then
        print_info "No hay cambios nuevos en el repositorio remoto"
        return 2  # No changes available
    fi
    
    # Stash any local changes (excluding .git)
    local stash_created=false
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_info "Guardando cambios locales temporalmente..."
        git stash push -m "Smart update: temporary stash $(date)" >/dev/null 2>&1
        stash_created=true
    fi
    
    # Merge the changes
    if git merge origin/main --no-edit >/dev/null 2>&1; then
        print_success "Cambios aplicados exitosamente"
        
        # Restore stash if it was created
        if [ "$stash_created" = true ]; then
            print_info "Restaurando cambios locales..."
            if git stash pop >/dev/null 2>&1; then
                print_info "✓ Cambios locales restaurados"
            else
                print_warning "Revisa posibles conflictos en tus cambios locales"
            fi
        fi
        
        return 0
    else
        print_error "Error al aplicar los cambios"
        
        # Restore stash if it was created
        if [ "$stash_created" = true ]; then
            git stash pop >/dev/null 2>&1
        fi
        
        return 1
    fi
}

# Ask about container restart
ask_container_restart() {
    printf "\n"
    
    if ask_yes_no "¿Quieres recargar el contenedor para usar los nuevos cambios?" "y"; then
        print_step "Recargando contenedor con los nuevos cambios..."
        
        # Stop current containers
        if make stop >/dev/null 2>&1; then
            print_info "✓ Contenedor detenido"
        fi
        
        # Rebuild and start with new changes
        if make build; then
            print_success "Contenedor reconstruido e iniciado con los nuevos cambios"
        else
            print_error "Error al reconstruir el contenedor"
            print_info "Puedes intentar manualmente con: ${GREEN}make build${NC}"
            return 1
        fi
    else
        print_info "El contenedor no se recargará."
        print_info "Los cambios estarán disponibles la próxima vez que uses ${GREEN}make build${NC}"
    fi
}

# Main update process
main() {
    print_header
    
    # Check if we're in a git repo
    check_git_repo
    
    # Get current version
    local current_version=$(get_current_version)
    
    # Get latest version and check for updates
    print_info "Verificando actualizaciones desde GitHub..."
    local latest_version=$(get_latest_version)
    
    # Display version information
    printf "${BOLD}Información de versiones:${NC}\n"
    printf "  📦 Versión actual:  ${CYAN}%s${NC}\n" "$current_version"
    printf "  🚀 Última versión:  ${GREEN}%s${NC}\n" "$latest_version"
    printf "\n"
    
    # Check commit information
    printf "${BOLD}Información de commits:${NC}\n"
    local has_new_commits=false
    if get_remote_commit_info; then
        has_new_commits=true
    fi
    printf "\n"
    
    # Determine if update is needed
    local needs_update=false
    
    if version_is_newer "$current_version" "$latest_version"; then
        needs_update=true
    elif [ "$has_new_commits" = true ]; then
        needs_update=true
    fi
    
    # Check if update is needed
    if [ "$needs_update" = false ]; then
        print_success "¡Ya tienes la última versión y los últimos cambios!"
        printf "\n"
        
        if ask_yes_no "¿Quieres forzar la actualización de todas formas?" "n"; then
            print_info "Procediendo con actualización forzada..."
        else
            print_info "Actualización cancelada"
            exit 0
        fi
    else
        printf "${GREEN}🎉 ¡Nuevos cambios disponibles!${NC}\n"
        printf "\n"
        
        if ! ask_yes_no "¿Quieres descargar e instalar los nuevos cambios?" "y"; then
            print_info "Actualización cancelada por el usuario"
            exit 0
        fi
    fi
    
    printf "\n"
    
    # Create backup
    if ! create_backup; then
        print_error "Error al crear backup"
        if ! ask_yes_no "¿Continuar sin backup?" "n"; then
            exit 1
        fi
    fi
    
    printf "\n"
    
    # Update from git
    local update_result=0
    if [ "$has_new_commits" = true ]; then
        update_from_git
        update_result=$?
    else
        print_info "No hay cambios remotos para descargar (actualización forzada de versión local)"
        update_result=2
    fi
    
    if [ $update_result -eq 1 ]; then
        print_error "Error al actualizar desde git"
        exit 1
    elif [ $update_result -eq 2 ]; then
        print_info "No había cambios para descargar"
        # When forcing update, still consider it successful
    fi
    
    printf "\n"
    print_success "🎉 ¡LazyVim Docker actualizado exitosamente!"
    
    local new_version=$(get_current_version)
    printf "\n"
    printf "  📦 Versión anterior: ${CYAN}%s${NC}\n" "$current_version"
    printf "  🚀 Versión actual:   ${GREEN}%s${NC}\n" "$new_version"
    printf "\n"
    
    # Ask about container restart
    ask_container_restart
    
    printf "\n"
    print_info "Para usar LazyVim en cualquier momento: ${GREEN}lazy enter${NC}"
    printf "\n"
}

# Handle interruption (preserve .git)
cleanup() {
    print_info "Limpieza interrumpida por el usuario"
    exit 1
}

trap cleanup INT TERM

# Run main function
main "$@"
