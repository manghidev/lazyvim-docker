#!/bin/bash

# LazyVim Docker Init Script
# This script starts and enters the LazyVim Docker container
#
# RECOMMENDATION: Use 'make start' or 'make enter' instead of running this script directly
# The make commands provide better error handling and user feedback

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CONTAINER_NAME="lazyvim"

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

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if container exists
if ! docker compose ps | grep -q "$CONTAINER_NAME"; then
    log_warning "Container not found. You may need to build it first."
    read -p "Do you want to build the environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Building environment..."
        ./build.sh
        exit 0
    else
        log_error "Cannot proceed without building the environment first."
        log_info "Run './build.sh' or 'make build' to build the environment."
        exit 1
    fi
fi

# Start the container if it's not running
if ! docker compose ps | grep -q "Up"; then
    log_info "Starting the container..."
    if docker compose up -d; then
        log_success "Container started successfully"
        # Wait a moment for the container to be fully ready
        sleep 2
    else
        log_error "Failed to start container"
        exit 1
    fi
else
    log_info "Container is already running"
fi

# Enter the container
log_info "Entering the LazyVim container..."
if docker exec -it "$CONTAINER_NAME" zsh; then
    log_success "Session ended"
else
    log_error "Failed to enter container"
    log_info "Container status:"
    docker compose ps
    exit 1
fi
