#!/bin/bash

# LazyVim Docker Build Script
# This script builds and starts the LazyVim Docker environment
# 
# RECOMMENDATION: Use 'make build' instead of running this script directly
# The make command provides better error handling and user feedback

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
VERSION_FILE="VERSION"
CONTAINER_NAME="lazyvim"
DOTFILES_DIR=".dotfiles"

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

# Check if VERSION file exists
if [[ ! -f "$VERSION_FILE" ]]; then
    log_error "VERSION file not found!"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE")
log_info "Building LazyVim Docker environment v$VERSION"

# Create .dotfiles directory if it doesn't exist
if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_warning "Creating $DOTFILES_DIR directory..."
    mkdir -p "$DOTFILES_DIR/.config/"{nvim,lazygit}
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Clean up existing environment
log_info "Cleaning up existing environment..."
docker compose down --rmi all --volumes 2>/dev/null || true

# Pull latest base images
log_info "Pulling latest base images..."
docker compose pull || log_warning "Could not pull some images, continuing..."

# Build the container
log_info "Building container with version $VERSION..."
if docker compose build --build-arg VERSION="$VERSION" --no-cache; then
    log_success "Container built successfully"
else
    log_error "Failed to build container"
    exit 1
fi

# Start the container
log_info "Starting the container..."
if docker compose up --force-recreate -d; then
    log_success "Container started successfully"
else
    log_error "Failed to start container"
    exit 1
fi

# Wait for container to be ready
log_info "Waiting for container to be ready..."
sleep 3

# Check if container is running
if docker compose ps | grep -q "Up"; then
    log_success "Container is running!"
    log_info "Opening shell in the container..."
    docker exec -it "$CONTAINER_NAME" zsh
else
    log_error "Container failed to start properly"
    docker compose logs
    exit 1
fi

log_success "Build process completed successfully!"
log_info "Use 'make enter' or './init.sh' to access the container again"
