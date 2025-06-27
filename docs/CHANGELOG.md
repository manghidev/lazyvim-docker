# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-06-27

### Added
- **Makefile** with intuitive commands for easy container management
- **Enhanced scripts** with error handling, logging, and validation
- **Health check script** (`scripts/health-check.sh`) for environment monitoring
- **Setup script** (`scripts/setup.sh`) for initial configuration
- **Version management script** (`scripts/bump-version.sh`) for semantic versioning
- **Development mode** with `docker-compose.dev.yml` for mounting workspace
- **Named volumes** for better performance (nvim-cache, zsh-cache, npm-cache, pip-cache)
- **Extended Dockerfile** with additional development tools:
  - Python 3 with pip and development packages (black, flake8, mypy, pytest)
  - Enhanced terminal tools (bat, exa, fd, tmux, htop, tree)
  - Additional zsh plugins (syntax-highlighting, completions)
  - Useful aliases and environment variables
  - Network and build tools
- **Backup and restore functionality** for dotfiles
- **Environment configuration** with `.env.example` template
- **Improved .gitignore** with comprehensive exclusions
- **Enhanced documentation** with detailed setup and usage instructions

### Changed
- **Improved `build.sh`** with better error handling and logging
- **Enhanced `init.sh`** with container status validation and auto-build option
- **Better `destroy.sh`** with confirmation prompts and cleanup
- **Updated `docker-compose.yml`** with:
  - Named volumes for performance
  - Better environment variables
  - Container hostname and restart policy
  - Improved volume mount structure
- **Comprehensive README** with:
  - Quick start instructions
  - Detailed command reference
  - Troubleshooting guide
  - Development tips
  - Better organization and formatting

### Fixed
- Container accessibility and health checking
- Permission issues with dotfiles
- Docker resource cleanup
- Script execution permissions

## [1.1.0] - Previous Release

### Added
- Basic LazyVim Docker environment
- Oh My Zsh with Powerlevel10k theme
- Essential development tools
- Volume mounting for Documents directory
- Basic build, init, and destroy scripts

### Features
- LazyVim Neovim configuration
- Zsh with auto-suggestions
- Git and Lazygit integration
- FZF and Ripgrep for fast searching
- Persistent dotfiles configuration
