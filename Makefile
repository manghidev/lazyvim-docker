# LazyVim Docker - Makefile
# Provides easy-to-use commands for managing the LazyVim Docker environment

.PHONY: help build start enter stop destroy clean status update logs backup restore dev quick version bump-version

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Read version from VERSION file
VERSION := $(shell cat VERSION 2>/dev/null || echo "1.0.0")
CONTAINER_NAME := lazyvim
COMPOSE_FILE := docker-compose.yml

help: ## Show this help message
	@echo "$(BLUE)LazyVim Docker Environment - Available Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Current version: $(VERSION)$(NC)"

build: ## Build the Docker environment (clean build)
	@echo "$(BLUE)Building LazyVim Docker environment v$(VERSION)...$(NC)"
	@./scripts/build.sh

start: ## Start the container (if already built)
	@echo "$(BLUE)Starting LazyVim container...$(NC)"
	@./scripts/init.sh

enter: ## Enter the running container
	@echo "$(BLUE)Entering LazyVim container...$(NC)"
	@docker exec -it $(CONTAINER_NAME) zsh 2>/dev/null || { \
		echo "$(RED)Container not running. Starting it first...$(NC)"; \
		make start; \
	}

stop: ## Stop the container (keeps volumes)
	@echo "$(YELLOW)Stopping LazyVim container...$(NC)"
	@docker compose stop
	@echo "$(GREEN)Container stopped$(NC)"

destroy: ## Destroy everything (container, images, and volumes)
	@echo "$(RED)Destroying LazyVim environment...$(NC)"
	@./scripts/destroy.sh

clean: ## Clean up unused Docker resources
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	@docker system prune -f
	@docker volume prune -f
	@echo "$(GREEN)Cleanup completed$(NC)"

status: ## Show container status
	@echo "$(BLUE)Container Status:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(BLUE)Container Info:$(NC)"
	@docker inspect $(CONTAINER_NAME) --format='{{.State.Status}}' 2>/dev/null | \
		sed 's/running/$(GREEN)Running$(NC)/' | \
		sed 's/exited/$(RED)Stopped$(NC)/' || echo "$(RED)Not found$(NC)"

logs: ## Show container logs
	@echo "$(BLUE)Container Logs:$(NC)"
	@docker compose logs -f --tail=50

update: ## Update to latest version and rebuild
	@echo "$(BLUE)Updating LazyVim environment...$(NC)"
	@git pull origin main || echo "$(YELLOW)Could not pull latest changes$(NC)"
	@make build

backup: ## Backup dotfiles and configuration
	@echo "$(BLUE)Creating backup of configuration...$(NC)"
	@mkdir -p backups
	@tar -czf backups/dotfiles-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz .dotfiles/
	@echo "$(GREEN)Backup created in backups/ directory$(NC)"

restore: ## Restore from backup (requires BACKUP_FILE variable)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Please specify BACKUP_FILE. Example: make restore BACKUP_FILE=backups/dotfiles-backup-20231201-120000.tar.gz$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring from $(BACKUP_FILE)...$(NC)"
	@tar -xzf $(BACKUP_FILE)
	@echo "$(GREEN)Restore completed$(NC)"

quick: ## Quick start - build and enter in one command
	@echo "$(BLUE)Quick start: building and entering container...$(NC)"
	@make build && make enter

version: ## Show current version
	@echo "$(GREEN)Current version: $(VERSION)$(NC)"

bump-version: ## Bump version (patch, minor, major)
	@if [ -z "$(TYPE)" ]; then \
		echo "$(RED)Please specify TYPE. Example: make bump-version TYPE=patch$(NC)"; \
		exit 1; \
	fi
	@./scripts/bump-version.sh $(TYPE)
