# LazyVim Docker - Makefile
# Provides easy-to-use commands for managing the LazyVim Docker environment

.PHONY: help build start enter stop destroy clean status update logs backup restore dev quick version bump-version restart install-global uninstall remote-install remote-uninstall remote-update configure configure

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
	@CONTAINER_STATE=$$(docker inspect $(CONTAINER_NAME) 2>/dev/null | grep '"Status"' | cut -d'"' -f4 || echo "missing"); \
	if [ "$$CONTAINER_STATE" = "missing" ]; then \
		echo "$(RED)Container not found. Please build first with 'make build'$(NC)"; \
		exit 1; \
	elif [ "$$CONTAINER_STATE" = "running" ]; then \
		echo "$(GREEN)Container is already running$(NC)"; \
	else \
		echo "$(YELLOW)Starting existing container...$(NC)"; \
		if docker compose start; then \
			echo "$(GREEN)Container started successfully$(NC)"; \
		else \
			echo "$(RED)Failed to start container$(NC)"; \
			exit 1; \
		fi \
	fi

enter: ## Enter the running container
	@echo "$(BLUE)Entering LazyVim container...$(NC)"
	@CONTAINER_STATE=$$(docker inspect $(CONTAINER_NAME) 2>/dev/null | grep '"Status"' | cut -d'"' -f4 || echo "missing"); \
	if [ "$$CONTAINER_STATE" = "missing" ]; then \
		echo "$(RED)Container not found. Please build first with 'make build'$(NC)"; \
		exit 1; \
	elif [ "$$CONTAINER_STATE" = "running" ]; then \
		docker exec -it $(CONTAINER_NAME) zsh; \
	else \
		echo "$(YELLOW)Container not running. Starting it first...$(NC)"; \
		if docker compose start; then \
			sleep 2; \
			docker exec -it $(CONTAINER_NAME) zsh; \
		else \
			echo "$(RED)Failed to start container$(NC)"; \
			exit 1; \
		fi \
	fi

stop: ## Stop the container (keeps volumes)
	@echo "$(YELLOW)Stopping LazyVim container...$(NC)"
	@docker compose stop
	@echo "$(GREEN)Container stopped$(NC)"

restart: ## Restart the container (stop and start)
	@echo "$(BLUE)Restarting LazyVim container...$(NC)"
	@docker compose restart
	@echo "$(GREEN)Container restarted$(NC)"

destroy: ## Destroy everything (container, images, and volumes)
	@echo "$(RED)Destroying LazyVim environment...$(NC)"
	@./scripts/destroy.sh

clean: ## Clean up unused Docker resources
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	@docker system prune -f
	@docker volume prune -f
	@echo "$(GREEN)Cleanup completed$(NC)"

health: ## Run comprehensive health diagnostics
	@echo "$(BLUE)Running LazyVim environment health check...$(NC)"
	@./scripts/health-check.sh

status: ## Show container status
	@echo "$(BLUE)Container Status:$(NC)"
	@CONTAINER_STATE=$$(docker inspect $(CONTAINER_NAME) 2>/dev/null | grep '"Status"' | cut -d'"' -f4 || echo "missing"); \
	if [ "$$CONTAINER_STATE" = "missing" ]; then \
		echo "$(RED)✗ Container does not exist$(NC)"; \
		echo "$(BLUE)Use 'make build' to create the container$(NC)"; \
	elif [ "$$CONTAINER_STATE" = "running" ]; then \
		echo "$(GREEN)✓ Container exists and is running$(NC)"; \
		docker compose ps; \
	else \
		echo "$(YELLOW)⚠ Container exists but is stopped ($$CONTAINER_STATE)$(NC)"; \
		echo "$(BLUE)Use 'make start' to start the container$(NC)"; \
		docker compose ps; \
	fi

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

quick: ## Quick start - start container and enter (build only if needed)
	@echo "$(BLUE)Quick start...$(NC)"
	@CONTAINER_STATE=$$(docker inspect $(CONTAINER_NAME) 2>/dev/null | grep '"Status"' | cut -d'"' -f4 || echo "missing"); \
	if [ "$$CONTAINER_STATE" = "missing" ]; then \
		echo "$(YELLOW)Container not found. Building first...$(NC)"; \
		make build && make enter; \
	elif [ "$$CONTAINER_STATE" = "running" ]; then \
		make enter; \
	else \
		make start && make enter; \
	fi

version: ## Show current version
	@echo "$(GREEN)Current version: $(VERSION)$(NC)"

timezone: ## Check timezone configuration in container
	@echo "$(BLUE)Checking timezone configuration...$(NC)"
	@./scripts/check-timezone.sh

bump-version: ## Bump version (patch, minor, major)
	@if [ -z "$(TYPE)" ]; then \
		echo "$(RED)Please specify TYPE. Example: make bump-version TYPE=patch$(NC)"; \
		exit 1; \
	fi
	@./scripts/bump-version.sh $(TYPE)

install-global: ## Install global 'lazy' commands to use from anywhere
	@echo "$(BLUE)Installing LazyVim Docker global commands...$(NC)"
	@./scripts/install-global-commands.sh

uninstall: ## Uninstall LazyVim Docker and remove global commands
	@echo "$(BLUE)Uninstalling LazyVim Docker...$(NC)"
	@./scripts/uninstall-global-commands.sh

install-remote: ## Show remote installation command
	@echo "$(BLUE)LazyVim Docker - Remote Installation$(NC)"
	@echo ""
	@echo "To install LazyVim Docker remotely (recommended):"
	@echo "$(GREEN)curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash$(NC)"
	@echo ""
	@echo "This will:"
	@echo "  • Download and install LazyVim Docker to ~/.local/share/lazyvim-docker"
	@echo "  • Create global 'lazy' command"
	@echo "  • Build Docker environment"
	@echo "  • No repository cloning required - everything is automated"

remote-install: install-remote ## Alias for install-remote

test-remote-scripts: ## Test remote installation scripts locally
	@echo "$(BLUE)Testing remote installation scripts...$(NC)"
	@bash -n scripts/remote-install.sh && echo "$(GREEN)✓ remote-install.sh syntax OK$(NC)"
	@bash -n scripts/remote-uninstall.sh && echo "$(GREEN)✓ remote-uninstall.sh syntax OK$(NC)"  
	@bash -n scripts/remote-update.sh && echo "$(GREEN)✓ remote-update.sh syntax OK$(NC)"
	@echo "$(GREEN)All remote scripts passed syntax check!$(NC)"

configure: ## Reconfigure directories and timezone
	@echo "$(BLUE)Reconfiguring LazyVim Docker environment...$(NC)"
	@./scripts/configure.sh
