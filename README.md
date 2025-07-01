# LazyVim Docker Environment

A professional Dockerized environment for LazyVim (advanced Neovim configuration) with essential developer tools. Perfect for development without installing anything on your host machine!

---

## 🚀 Quick Start

### 🌐 Remote Installation (Recommended)
Install directly without cloning the repository - no manual setup needed:

```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash

# Then use from anywhere
lazy enter      # Enter LazyVim development environment
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
lazy help       # Show all available commands
```

### 📁 Local Commands (Traditional Installation)
From the project directory:
```bash
make help          # Show all available commands
make enter         # 🔥 DAILY USE: Enter container (starts automatically if stopped)
make start         # Start existing container (preserves all data)
make stop          # Stop container (saves all data and plugins)
make status        # Check container status
make build         # ⚠️  ONLY for first time or major updates
make destroy       # ⚠️  DANGEROUS: Removes everything
```

> 💡 **For daily development**: Use `lazy enter` (remote) or `make enter` (traditional)

---

## 🌐 Remote Installation Scripts

LazyVim Docker provides three main remote scripts for easy management:

### 📥 Installation Script
**`remote-install.sh`** - Complete setup in one command

```bash
# Full installation with Docker build
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash
```

**What it does:**
- ✅ Checks system requirements (Docker, git, curl)
- ✅ Downloads LazyVim Docker to `~/.local/share/lazyvim-docker`
- ✅ Creates global `lazy` command in `~/.local/bin`
- ✅ Adds `~/.local/bin` to your PATH automatically
- ✅ Builds Docker environment (may take a few minutes)
- ✅ Creates shell configuration backups

### 🔄 Update Script
**`remote-update.sh`** - Keep your installation up to date

```bash
# Update to latest version
lazy update

# Or run directly
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-update.sh | bash
```

**What it does:**
- ✅ Checks current vs latest version
- ✅ Creates backup of current installation
- ✅ Downloads latest version
- ✅ Preserves user configurations (.dotfiles, backups)
- ✅ Updates installation while keeping your settings
- ✅ Optionally rebuilds Docker containers

### 🗑️ Uninstallation Script
**`remote-uninstall.sh`** - Complete cleanup

```bash
# Uninstall everything with prompts
lazy uninstall

# Or run directly
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-uninstall.sh | bash
```

**What it does:**
- ✅ Stops and removes Docker containers/images
- ✅ Removes installation directory (`~/.local/share/lazyvim-docker`)
- ✅ Removes global `lazy` command
- ✅ Optionally cleans PATH modifications from shell configs
- ✅ Creates backups before making changes
- ✅ Interactive prompts for safety

---

## 🔬 Script Details & Technical Info

### 📥 remote-install.sh
**Purpose**: Complete LazyVim Docker setup without repository cloning

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

### 🔄 remote-update.sh
**Purpose**: Update existing remote installation to latest version

**Update Process:**
1. Checks current version vs latest GitHub release
2. Creates backup of current installation
3. Downloads latest version to temp directory
4. Preserves user configurations (.dotfiles, backups)
5. Replaces system files while keeping user data
6. Optionally rebuilds Docker containers
7. Cleans up temporary files

**Preserved Data:**
- `.dotfiles/` (your Neovim, shell configs)
- `backups/` (configuration backups)
- Docker volumes (development data)

**Safe Rollback:**
- Backup created before update in `~/.local/share/lazyvim-docker-backup-[timestamp]`

### 🗑️ remote-uninstall.sh
**Purpose**: Complete removal of LazyVim Docker installation

**Removal Process:**
1. Stops all running containers
2. Removes Docker containers and images
3. Removes Docker volumes
4. Removes installation directory
5. Removes global `lazy` command
6. Optionally cleans PATH from shell configs
7. Creates backups before deletion

**Interactive Prompts:**
- Confirm complete uninstall
- Choose to remove PATH modifications
- Option to keep or remove project files

**Cleanup Scope:**
- Docker: containers, images, volumes
- Files: installation directory, global command
- Config: PATH modifications (optional)

---

## 📋 Installation Methods Comparison

| Method | Command | Best For | Global Access |
|--------|---------|----------|---------------|
| **Remote Install** | `curl ... \| bash` | End users, daily use | ✅ `lazy` anywhere |
| **Traditional** | `git clone ...` | Developers, customization | ❌ Must `cd` to directory |
| **Quick Install** | `curl quick-install.sh` | Fast setup | ✅ `lazy` anywhere |

### Switching Between Methods

**From Traditional to Remote:**
```bash
# From your existing repo directory
make destroy && cd .. && rm -rf lazyvim-docker
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash
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
# 1. Install once (5-10 minutes)
curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash

# 2. Daily usage from anywhere
cd ~/Projects/my-project
lazy enter       # Start coding immediately

# 3. Management commands
lazy status      # Check if running
lazy stop        # Stop when done
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

## 🔧 Advanced Configuration

## 🔧 Advanced Configuration

### Timezone Configuration
Configure your timezone in `docker-compose.yml`:

```yaml
services:
  code-editor:
    build:
      args:
        TIMEZONE: America/Mexico_City  # Change this
    environment:
      - TZ=America/Mexico_City         # And this
```

**Common timezones:** Mexico_City, New_York, Los_Angeles, Madrid, London, Tokyo

**Apply changes:**
```bash
lazy build    # Remote installation
make build       # Traditional installation
```

### Volume Mounting
Add your project directories in `docker-compose.yml`:

```yaml
volumes:
  - $HOME/Documents:/home/developer/Documents     # Default
  - $HOME/Projects:/home/developer/Projects       # Add this
  - $HOME/Developer:/home/developer/Developer     # Or this
```

---

## 🩺 Maintenance & Troubleshooting

### Health Check Commands
```bash
lazy status     # Container status
lazy help       # Available commands  
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

# Nuclear option
lazy uninstall && curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash
```

---

## � Documentation & Support

**Main Documentation:**
- **[📖 Complete Commands Reference](docs/COMMANDS.md)** - All available commands
- **[📝 Changelog](docs/CHANGELOG.md)** - Version history
- **[� Container Lifecycle Guide](docs/CONTAINER_LIFECYCLE.md)** - Detailed workflows

**Quick Start:**
- Remote: `curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh | bash`
- Traditional: `git clone ... && make quick`

**Support:**
- 🐛 [Report Issues](https://github.com/manghidev/lazyvim-docker/issues)
- 💡 [Feature Requests](https://github.com/manghidev/lazyvim-docker/issues)
- ⭐ [Star the Project](https://github.com/manghidev/lazyvim-docker)

---

## 👨‍💻 About

**Created by ManghiDev**  
🌐 [Personal Website](https://manghi.dev)  
📧 [GitHub Issues](https://github.com/manghidev/lazyvim-docker/issues)

**License:** MIT - See [LICENSE](LICENSE) file

**Additional Resources:**
- [LazyVim Docs](https://lazyvim.github.io/) | [Neovim Docs](https://neovim.io/doc/)
- [Docker Docs](https://docs.docker.com/) | [Oh My Zsh](https://ohmyz.sh/)

---

## 📚 Quick Reference

### 🚀 Remote Scripts Commands

| Action | Command | Description |
|--------|---------|-------------|
| **Install** | `curl -fsSL https://raw.githubusercontent.com/manghidev/lazyvim-docker/main/scripts/remote-install.sh \| bash` | Complete setup |
| **Update** | `lazy update` | Update to latest version |
| **Uninstall** | `lazy uninstall` | Remove everything |

### 💻 Daily Commands (After Remote Install)

| Command | Description | Usage |
|---------|-------------|-------|
| `lazy enter` | Enter development environment | Daily coding |
| `lazy status` | Check container status | Debugging |
| `lazy start` | Start containers | If stopped |
| `lazy stop` | Stop containers | End of day |
| `lazy build` | Rebuild environment | After updates |
| `lazy help` | Show all commands | Reference |

### 🛠️ Troubleshooting Commands

```bash
# Check what's running
lazy status

# Full restart
lazy stop && lazy start

# Nuclear option - rebuild everything
lazy build

# Update to latest version
lazy update

# Complete removal
lazy uninstall
```