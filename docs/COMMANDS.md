# LazyVim Docker - Command Reference

This document provides a comprehensive guide to all available commands in the LazyVim Docker environment.

> **💡 Recommendation**: Always use `make` commands instead of running scripts directly. They provide better error handling, validation, and user feedback.

## Make Commands (Recommended)

### Basic Operations

| Command | Description | Example |
|---------|-------------|---------|
| `make` | Show all available commands with descriptions (default target) | `make` |
| `make version` | Show current project version | `make version` |
| `make status` | Show container and environment status | `make status` |
| `make health` | Run comprehensive health diagnostics | `make health` |

### Container Management

| Command | Description | Example |
|---------|-------------|---------|
| `make build` | Build the Docker environment (clean build) | `make build` |
| `make start` | Start the container (if already built) | `make start` |
| `make enter` | Enter the running container | `make enter` |
| `make stop` | Stop the container (keeps volumes) | `make stop` |
| `make destroy` | Destroy everything (container, images, volumes) | `make destroy` |
| `make quick` | Quick start - build and enter in one command | `make quick` |

### Development

| Command | Description | Example |
|---------|-------------|---------|
| `make dev` | Start in development mode with workspace mounted | `make dev` |
| `make update` | Update to latest version and rebuild | `make update` |

### Maintenance

| Command | Description | Example |
|---------|-------------|---------|
| `make clean` | Clean up unused Docker resources | `make clean` |
| `make backup` | Backup dotfiles and configuration | `make backup` |
| `make restore` | Restore from backup | `make restore BACKUP_FILE=backup.tar.gz` |

### Version Management

| Command | Description | Example |
|---------|-------------|---------|
| `make bump-version TYPE=patch` | Bump patch version (1.0.0 → 1.0.1) | `make bump-version TYPE=patch` |
| `make bump-version TYPE=minor` | Bump minor version (1.0.0 → 1.1.0) | `make bump-version TYPE=minor` |
| `make bump-version TYPE=major` | Bump major version (1.0.0 → 2.0.0) | `make bump-version TYPE=major` |

### Configuration

| Command | Description | Example |
|---------|-------------|---------|
| `make configure` | Interactive configuration menu | `make configure` |
| `lazy configure` | Configure from anywhere (remote installation) | `lazy configure` |

#### Configuration Options Available:

1. **Directory Management**
   - Add/remove custom directory mounts
   - Configure Documents and Projects directories
   - Batch directory addition

2. **Dotfiles Integration** 
   - Import personal configuration files
   - Support for Git repositories and ZIP files
   - Automated backup of existing configurations

3. **Timezone Configuration**
   - Set container timezone to match your system
   - Common timezone detection and selection

> 📖 **Dotfiles Documentation**: See [`docs/DOTFILES_STANDARD.md`](DOTFILES_STANDARD.md) for detailed information about importing your personal configurations.

## Shell Scripts (Not Recommended - Use Make Instead)

> **⚠️ Warning**: These scripts are for internal use. Use `make` commands instead for better experience.

### Primary Scripts

| Script | Make Alternative | Description |
|--------|------------------|-------------|
| `./scripts/build.sh` | `make build` | Build and start environment |
| `./scripts/init.sh` | `make start` | Start and enter container |
| `./scripts/destroy.sh` | `make destroy` | Remove environment |

### Utility Scripts

| Script | Make Alternative | Description |
|--------|------------------|-------------|
| `./scripts/setup.sh` | *No alternative* | Interactive initial configuration |
| `./scripts/health-check.sh` | `make status` | Environment diagnostics |
| `./scripts/bump-version.sh` | `make bump-version TYPE=patch` | Version management |

## Docker Compose Commands

For advanced users who prefer direct Docker Compose commands:

```bash
# Basic operations
docker compose up -d                    # Start container in background
docker compose down                     # Stop and remove container
docker compose ps                       # Show container status
docker compose logs -f                  # Follow logs

# Development mode
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Build operations
docker compose build --no-cache         # Clean build
docker compose up --force-recreate -d   # Force recreate container
```

## Direct Docker Commands

```bash
# Enter running container
docker exec -it lazyvim zsh

# Check container status
docker inspect lazyvim

# View container logs
docker logs lazyvim

# Copy files to/from container
docker cp file.txt lazyvim:/home/developer/
docker cp lazyvim:/home/developer/file.txt ./
```

## Environment Variables

Set these in your `.env` file (copy from `.env.example`):

```bash
# Container configuration
CONTAINER_NAME=lazyvim
COMPOSE_PROJECT_NAME=lazyvim

# Volume paths
DOCUMENTS_PATH=$HOME/Documents
PROJECTS_PATH=$HOME/Projects

# Development mode
DEV_MODE=false
ENABLE_PORTS=false

# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
```

## Common Workflows

### First Time Setup
```bash
git clone https://github.com/manghidev/lazyvim-docker.git
cd lazyvim-docker
./scripts/setup.sh    # Interactive configuration
make build            # Build environment
```

### Daily Development
```bash
make enter            # Start and enter container
# Work on your projects
make stop             # Stop when done
```

### Maintenance
```bash
make status           # Check health
make backup           # Backup configuration
make clean            # Clean up Docker resources
make update           # Update to latest
```

### Troubleshooting
```bash
./scripts/health-check.sh    # Diagnose issues
make destroy && make build   # Nuclear option - rebuild everything
```

## Tips and Best Practices

1. **Use make commands**: They provide better error handling and user feedback
2. **Regular backups**: Run `make backup` before major changes
3. **Health checks**: Use `make status` or `./scripts/health-check.sh` for diagnostics
4. **Version control**: Use `make bump-version` for proper semantic versioning
5. **Clean up**: Run `make clean` periodically to free up disk space
6. **Development mode**: Use `make dev` when working on the Docker configuration itself

## Keyboard Shortcuts in Container

Once inside the container, these keyboard shortcuts are available:

- `Ctrl+R` - Fuzzy search command history with fzf
- `Ctrl+T` - Fuzzy file finder with fzf
- `Alt+C` - Fuzzy directory changer with fzf
- `Ctrl+L` - Clear screen
- `Ctrl+D` - Exit container

## Aliases Available in Container

- `ll` - Enhanced ls with exa
- `cat` - Better cat with bat
- `find` - Better find with fd
- `vim`/`vi` - Opens neovim
- `lg` - Opens lazygit

## Dotfiles Integration

LazyVim Docker supports importing your personal dotfiles to customize the container environment. This feature allows you to bring your familiar development setup into the container.

### Quick Start

1. **Run configuration**:
   ```bash
   make configure  # or lazy configure
   ```

2. **Choose option 5** for dotfiles integration

3. **Select your source**:
   - **Option 1**: Git Repository (GitHub, GitLab, GitBucket)
   - **Option 2**: Local ZIP file

### Git Repository Method

When prompted, enter your repository URL:
```bash
# Examples:
https://github.com/yourusername/dotfiles.git
https://gitlab.com/yourusername/dotfiles.git
https://gitbucket.yourserver.com/yourusername/dotfiles.git
```

The system will:
1. Clone your repository
2. Validate the configuration file
3. Install configurations according to your settings
4. Create backups of existing files

### ZIP File Method

When prompted, enter the full path to your ZIP file:
```bash
# Examples:
/Users/yourname/Documents/my-dotfiles.zip
$(pwd)/dotfiles.zip  # If in current directory
```

**Tip**: Use `pwd` to get your current directory path.

### Required Structure

Your dotfiles repository or ZIP must include a `.lazyvim-docker-dotfiles` configuration file. Example:

```ini
[metadata]
name=My Personal Dotfiles
version=1.0.0
author=Your Name

[nvim]
enabled=true
source_path=nvim
target_path=/home/developer/.config/nvim
backup_original=true

[zsh]
enabled=true
source_path=zsh
target_path=/home/developer
files=.zshrc,.zsh_aliases,.zsh_exports

[git]
enabled=true
source_path=git
target_path=/home/developer
files=.gitconfig,.gitignore_global
```

### Supported Configurations

| Category | Description | Target Location |
|----------|-------------|----------------|
| **nvim** | Neovim/LazyVim configuration | `~/.config/nvim` |
| **zsh** | Shell aliases, exports, customizations | `~/` |
| **git** | Git user settings and global gitignore | `~/` |
| **tmux** | Terminal multiplexer configuration | `~/` |
| **scripts** | Custom development tools | `~/bin` |

### Testing Your Setup

After installation, verify your dotfiles:

```bash
# Check if dotfiles are loaded
echo $DOTFILES_LOADED

# Test custom aliases (if you have them)
alias

# Check Neovim configuration
nvim +checkhealth

# List installed scripts
ls -la ~/bin
```

### Creating Test Dotfiles

LazyVim Docker includes example dotfiles for testing:

```bash
# Location of test dotfiles
ls -la test-dotfiles/

# Create test ZIP
cd test-dotfiles && zip -r ../test-dotfiles.zip .

# Use in configuration
make configure  # Option 5 -> Option 2 -> Enter ZIP path
```

### Best Practices

1. **Keep it minimal**: Only include essential configurations
2. **Test locally**: Ensure your dotfiles work in a clean environment  
3. **Version control**: Use Git tags for stable releases
4. **Security**: Never include sensitive information (passwords, tokens)
5. **Documentation**: Include README.md explaining your setup

### Troubleshooting

**Missing configuration file**:
```
Error: No .lazyvim-docker-dotfiles found
```
- Solution: Add the required configuration file to your dotfiles root

**Invalid source paths**:
```
Error: Source path 'xyz' not found
```
- Solution: Verify paths in configuration match actual directories

**Permission issues**:
```
Error: Cannot create target directory
```
- Solution: Ensure target paths are writable in the container

### Complete Documentation

For detailed information about the dotfiles standard, structure requirements, and advanced configuration options, see:

📖 **[`docs/DOTFILES_STANDARD.md`](DOTFILES_STANDARD.md)**

This includes:
- Complete configuration file format
- Directory structure requirements
- Security considerations
- Migration guide for existing dotfiles
- Validation rules and best practices
