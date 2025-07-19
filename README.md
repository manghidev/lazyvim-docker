# LazyVim Docker Environment

A professional Dockerized environment for LazyVim (advanced Neovim configuration) with essential developer tools. Perfect for development without installing anything on your host machine!

---

## 🚀 Quick Start

### 🌐 Remote Installation (Recommended)
Install directly without cloning the repository - automatic setup with smart defaults:

```bash
# One-line installation with automatic configuration
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash

# Then use from anywhere
lazy enter      # Enter LazyVim development environment
lazy configure  # Customize your setup (optional)
```

### 📦 Traditional Installation
If you prefer to clone the repository manually:
```bash
git clone https://github.com/manghidev/lazyvim-docker.git && cd lazyvim-docker && make quick
```

### 🔧 Manual Installation
```bash
git clone https://github.com/manghidev/lazyvim-docker.git
cd lazyvim-docker
make build    # Build the environment
make enter    # Enter the container
```

### 🗑️ Uninstallation
Complete removal when you no longer need LazyVim Docker:

```bash
# Interactive uninstall (asks for confirmation)
lazy uninstall

# Or run directly 
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/uninstall.sh | bash
```

**Removes everything**: Docker containers, installation files, global commands, and shell configurations in one step.

---

## ✨ Features

- **LazyVim**: Predefined Neovim configuration for maximum productivity
- **Dockerized**: Fully isolated and reproducible environment
- **Rich Terminal**: Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins
- **40+ Developer Tools**: git, lazygit, tmux, python, node.js, and many more
- **Easy Remote Setup**: No need to clone repository manually - just one command
- **Simple Management**: Easy commands for all operations
- **Persistent Configuration**: All changes are saved between sessions
- **Cross-Platform**: Works on macOS and Linux
- **Auto-Updates**: Built-in update mechanism

---

## 🎯 Commands Overview

### 🌐 Global Commands (Remote Installation)
After remote installation, use these commands from anywhere:
```bash
lazy enter      # 🔥 Enter LazyVim development environment
lazy start      # Start the container
lazy stop       # Stop the container
lazy status     # Check container status
lazy build      # Build/rebuild environment
lazy update     # Update to latest version
lazy uninstall  # Complete removal
```

### 📁 Local Commands (Traditional Installation)
From the project directory:
```bash
make              # Show all available commands (default target)
make enter        # 🔥 DAILY USE: Enter container (starts automatically if stopped)
make start        # Start existing container (preserves all data)
make stop         # Stop container (saves all data and plugins)
make status       # Check container status
make build        # ⚠️  ONLY for first time or major updates
make destroy      # ⚠️  DANGEROUS: Removes everything
```

> 💡 **For daily development**: Use `lazy enter` (remote) or `make enter` (traditional)

---

## 🌐 Remote Installation Scripts

LazyVim Docker provides three main remote scripts for easy management:

### 📥 Installation Script
**`start.sh`** - Automatic setup with smart defaults

```bash
# Full installation with automatic configuration
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash
```

**What it does:**
- ✅ Checks system requirements (Docker, git, curl)
- ✅ Downloads LazyVim Docker to `~/.local/share/lazyvim-docker`
- ✅ Creates global `lazy` command in `~/.local/bin`
- ✅ Adds `~/.local/bin` to your PATH automatically
- ✅ Builds Docker environment (may take a few minutes)
- ✅ Uses smart defaults for timezone and directories
- ✅ Creates shell configuration backups

### 🔄 Update Script
**Smart Update System** - Keep your installation up to date

```bash
# Update to latest version (recommended)
lazy update

# Or from project directory
make update
```

**What it does:**
- ✅ Checks current vs latest version
- ✅ Creates backup of current installation
- ✅ Downloads latest version
- ✅ Preserves user configurations (.dotfiles, backups)
- ✅ Updates installation while keeping your settings
- ✅ Optionally rebuilds Docker containers

### 🗑️ Uninstallation Script
**Smart Uninstaller** - Complete and safe cleanup

```bash
# Interactive uninstall with confirmation prompt
lazy uninstall

# Or run directly with prompts
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/uninstall.sh | bash
```

**What it does when you confirm:**
- ✅ Stops and removes all Docker containers and images
- ✅ Removes installation directory (`~/.local/share/lazyvim-docker`) 
- ✅ Removes global `lazy` command
- ✅ Removes shell configuration entries (`.zshrc`, `.bashrc`, etc.)
- ✅ Removes PATH modifications automatically
- ✅ Creates timestamped backups before making changes
- ✅ **Everything is removed in one confirmation** - no additional prompts

**Safety Features:**
- 🛡️ **Interactive confirmation** - Shows exactly what will be removed
- 🛡️ **Non-interactive safety** - Cancels by default when piped unless forced
- 🛡️ **Automatic backups** - Creates backups of modified configuration files  
- 🛡️ **Clear messaging** - Shows progress and results of each step

---

## 🔬 Script Details & Technical Info

### 📥 start.sh
**Purpose**: Complete LazyVim Docker setup with automatic configuration

**Requirements Check:**
- Docker (with compose support)
- Git (for downloading)
- Curl (for execution)
- Supported OS: macOS, Linux

**Installation Process:**
1. Creates `~/.local/share/lazyvim-docker` directory
2. Downloads latest repository to temp location
3. Moves files to installation directory
4. Creates global `lazy` command in `~/.local/bin`
5. Updates shell PATH in `.zshrc`/`.bashrc`
6. Builds Docker environment (5-10 minutes)
7. Cleans up temporary files

**Files Modified:**
- `~/.zshrc` or `~/.bashrc` (adds PATH)
- Creates `~/.local/bin/lazy`
- Creates `~/.local/share/lazyvim-docker/`

### 🔄 Smart Update System
**Purpose**: Update existing installation to latest version with intelligent version checking

**Update Process:**
1. Checks current version vs latest GitHub release
2. Compares local and remote git commits
3. Interactive prompts for user confirmation
4. Creates backup of current installation
5. Downloads latest version preserving development setup
6. Preserves user configurations (.dotfiles, backups)
7. Offers container rebuild options
6. Optionally rebuilds Docker containers
7. Cleans up temporary files

**Preserved Data:**
- `.dotfiles/` (your Neovim, shell configs)
- `backups/` (configuration backups)
- Docker volumes (development data)

**Safe Rollback:**
- Backup created before update in `~/.local/share/lazyvim-docker-backup-[timestamp]`

### 🗑️ Smart Uninstaller
**Purpose**: Complete and safe removal of LazyVim Docker installation

**Removal Process:**
1. Shows exactly what will be removed
2. **Single confirmation prompt** - no additional questions
3. Stops all running containers
4. Removes Docker containers, images, and volumes
5. Removes installation directory (`~/.local/share/lazyvim-docker`)
6. Removes global `lazy` command and shell integrations
7. Removes PATH modifications automatically
8. Creates timestamped backups before any changes

**Smart Detection:**
- **Interactive mode**: Shows confirmation prompt when run manually
- **Automatic backup**: Creates `.backup.[timestamp]` files before modifying shell configs

**Complete Cleanup:**
- ✅ Docker: containers, images, volumes  
- ✅ Files: installation directory, global command
- ✅ Config: shell entries and PATH modifications
- ✅ **Everything removed in one confirmation** - streamlined process

---

## 📋 Installation Methods Comparison

| Method | Command | Best For | Global Access |
|--------|---------|----------|---------------|
| **Remote Install** | `curl ... \| bash` | End users, daily use | ✅ `lazy` anywhere |
| **Traditional** | `git clone ...` | Developers, customization | ❌ Must `cd` to directory |

### Switching Between Methods

**From Traditional to Remote:**
```bash
# From your existing repo directory
make destroy && cd .. && rm -rf lazyvim-docker
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash
```

**From Remote to Traditional:**
```bash
lazy uninstall
git clone https://github.com/manghidev/lazyvim-docker.git && cd lazyvim-docker && make quick
```

---

## 🎯 Daily Usage Guide

### Remote Installation Workflow (Recommended)
```bash
# 1. Install once (5-10 minutes) - automatic setup
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash

# 2. Daily usage from anywhere
cd ~/Projects/my-project
lazy enter       # Start coding immediately

# 3. Management commands
lazy status      # Check if running
lazy stop        # Stop when done
lazy configure   # Customize setup (optional)
lazy update      # Update weekly/monthly
```

### Traditional Installation Workflow
```bash
# 1. Install once
git clone https://github.com/manghidev/lazyvim-docker.git && cd lazyvim-docker && make quick

# 2. Daily usage (must be in project directory)
cd path/to/lazyvim-docker
make enter          # Start coding

# 3. Management
make status && make stop
```

For detailed workflow and troubleshooting: **[📖 Container Lifecycle Guide](docs/CONTAINER_LIFECYCLE.md)**

---

## 🔧 Configuration

### 🎯 Easy Configuration (Recommended)
After installation, you can easily reconfigure directories and timezone:

```bash
# Reconfigure interactively - works from anywhere
lazy configure

# Traditional installation
make configure    # (from project directory)
```

**What you can configure:**
- ✅ **Timezone**: Automatically detects your system timezone with common options
- ✅ **Directories**: Choose which local directories to mount in the container
- ✅ **Projects Folder**: Set up your main development directory
- ✅ **Custom Mounts**: Add any additional directories you need
- ✅ **Dotfiles Integration**: Import your personal configuration files

### 🎨 Dotfiles Integration
Bring your personal development environment into the container:

```bash
# Import dotfiles during configuration
lazy configure  # Choose option 5 for dotfiles integration
```

**Supported sources:**
- **Git Repository**: Clone from GitHub, GitLab, or GitBucket
- **Local ZIP file**: Import from a local archive

**Supported configurations:**
- Neovim (nvim) - Custom LazyVim configurations
- Zsh - Shell aliases, exports, and customizations  
- Git - User settings and global gitignore
- Tmux - Terminal multiplexer configuration
- Scripts - Custom development tools

> 📖 **Important**: Your dotfiles must follow the LazyVim Docker standard.  
> See detailed documentation: [`docs/DOTFILES_STANDARD.md`](docs/DOTFILES_STANDARD.md)

### 📁 Directory Configuration Examples

**During `lazy configure` you can set up:**
```bash
# Common setups that will be offered
~/Documents     → /home/developer/Documents    # Default
~/Projects      → /home/developer/Projects     # Development projects
~/Developer     → /home/developer/Developer    # macOS default
~/Desktop       → /home/developer/Desktop      # Quick access files
/Volumes/USB    → /home/developer/usb          # External drives
```

### 🕒 Timezone Configuration
Configure your timezone in `docker-compose.yml`:

**Automated (Easy):**
```bash
lazy configure    # Interactive timezone selection
```

**Manual (Traditional):**
```yaml
services:
  code-editor:
    build:
      args:
        TIMEZONE: America/Mexico_City  # Change this
    environment:
      - TZ=America/Mexico_City         # And this
```

**Common timezones:** 
- `America/New_York` (EST/EDT)
- `America/Los_Angeles` (PST/PDT) 
- `America/Mexico_City` (CST/CDT)
- `Europe/London` (GMT/BST)
- `Europe/Madrid` (CET/CEST)
- `Asia/Tokyo` (JST)

**Apply changes:**
```bash
lazy build       # Remote installation
make build       # Traditional installation
```

### 📂 Advanced Volume Mounting
Add your project directories in `docker-compose.yml`:

```yaml
volumes:
  - $HOME/Documents:/home/developer/Documents     # Default
  - $HOME/Projects:/home/developer/Projects       # Add this
  - $HOME/Developer:/home/developer/Developer     # Or this
  - /path/to/custom:/home/developer/custom        # Custom paths
```

---

## 🩺 Maintenance & Troubleshooting

### Health Check Commands
```bash
lazy status     # Container status
lazy            # Available commands  
make health        # Comprehensive diagnostics (traditional)
```

### Common Solutions
```bash
# Container won't start
lazy stop && lazy start

# Need fresh environment
lazy build

# Update to fix issues
lazy update

# Nuclear option - complete reinstall
lazy uninstall && curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/start.sh | bash
```

---

## 📑 Documentation & Support

**Main Documentation:**
- **[📖 Complete Commands Reference](docs/COMMANDS.md)** - All available commands
- **[🔁 Container Lifecycle Guide](docs/CONTAINER_LIFECYCLE.md)** - Detailed workflows

**Support:**
- 🐛 [Report Issues](https://github.com/manghidev/lazyvim-docker/issues)
- 💡 [Feature Requests](https://github.com/manghidev/lazyvim-docker/issues)
- ⭐ [Star the Project](https://github.com/manghidev/lazyvim-docker)

---

## 👨‍💻 About

**Created by ManghiDev**  
🌐 [Personal Website](https://manghi.dev)  
📧 [GitHub Issues](https://github.com/manghidev/lazyvim-docker/issues)

**License:** GPLv3 - See [LICENSE](LICENSE) file

**Additional Resources:**
- [LazyVim Docs](https://lazyvim.github.io/) | [Neovim Docs](https://neovim.io/doc/)
- [Docker Docs](https://docs.docker.com/) | [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k Theme](https://github.com/romkatv/powerlevel10k) | [Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)