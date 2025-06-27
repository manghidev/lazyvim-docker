#!/bin/bash

# LazyVim Docker Destroy Script
# This script completely removes the LazyVim Docker environment
#
# RECOMMENDATION: Use 'make destroy' instead of running this script directly
# The make command provides better error handling and user feedback

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

# Confirmation prompt
log_warning "This will completely destroy the LazyVim Docker environment!"
log_warning "This includes:"
echo "  - Stopping and removing containers"
echo "  - Removing Docker images"
echo "  - Removing Docker volumes (configuration will be lost!)"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Operation cancelled"
    exit 0
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log_error "Docker is not running. Cannot destroy environment."
    exit 1
fi

# Stop and remove containers, images, and volumes
log_info "Stopping and removing containers, images, and volumes..."
if docker compose down --rmi all --volumes; then
    log_success "Environment destroyed successfully"
else
    log_warning "Some resources might not have been removed"
fi

# Clean up any remaining resources
log_info "Cleaning up any remaining Docker resources..."
docker system prune -f >/dev/null 2>&1 || true

# Check if everything was removed
if docker compose ps | grep -q "$CONTAINER_NAME"; then
    log_warning "Some containers might still be running"
else
    log_success "All containers removed"
fi

log_success "LazyVim Docker environment has been completely destroyed"
log_info "To rebuild the environment, run 'make build'"