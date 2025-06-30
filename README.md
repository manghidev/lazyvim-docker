# LazyVim Docker Environment

A professional Dockerized environment for LazyVim (advanced Neovim configuration) with essential developer tools. Perfect for development without installing anything on your host machine!

---

## 🚀 Quick Start

### One-Line Installation (Recommended)
```bash
git clone https://github.com/manghidev/lazyvim-docker.git && cd lazyvim-docker && make quick
```

### Manual Installation
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
- **Easy Management**: Simple make commands for all operations
- **Persistent Configuration**: All changes are saved between sessions
- **Cross-Platform**: Works on macOS and Linux

---

## 🎯 Main Commands

```bash
make help          # Show all available commands
make enter         # 🔥 DAILY USE: Enter container (starts automatically if stopped)
make start         # Start existing container (preserves all data)
make stop          # Stop container (saves all data and plugins)
make status        # Check container status
make build         # ⚠️  ONLY for first time or major updates
make destroy       # ⚠️  DANGEROUS: Removes everything
```

> 💡 **For daily development**: Just use `make enter` - it handles everything!

For detailed workflow and troubleshooting: **[📖 Container Lifecycle Guide](docs/CONTAINER_LIFECYCLE.md)**

---

## 🔧 Configuration

### Timezone Configuration
Configure your local timezone to match the container time. Edit the `docker-compose.yml` file:

```yaml
# In docker-compose.yml, modify these lines:
services:
  code-editor:
    build:
      args:
        VERSION: x.x.x
        TIMEZONE: America/Mexico_City  # Change to your timezone
    environment:
      - TZ=America/Mexico_City         # Change to your timezone
```

Common timezones:
- `America/Mexico_City` (UTC-6)
- `America/New_York` (UTC-5/-4)
- `America/Los_Angeles` (UTC-8/-7)
- `Europe/Madrid` (UTC+1/+2)
- `Europe/London` (UTC+0/+1)
- `Asia/Tokyo` (UTC+9)

After changing the timezone, rebuild the container:
```bash
make build
```

Check the current timezone configuration:
```bash
make timezone
```

### Volume Mounting
By default, your `Documents` folder is mounted. Edit `docker-compose.yml` to add more directories:

```yaml
volumes:
  # Already included
  - $HOME/Documents:/home/developer/Documents
  
  # Add your project directories
  - $HOME/Projects:/home/developer/Projects
  - $HOME/Developer:/home/developer/Developer
```

### Initial Setup
Run the interactive setup for personalized configuration:
```bash
make build  # First build the environment
```

---

## 📁 Project Structure

```
lazyvim-docker/
├── Makefile                 # Main command interface
├── docker-compose.yml       # Docker configuration
├── Dockerfile              # Container definition
├── VERSION                 # Current version
├── docs/                   # Documentation
│   ├── COMMANDS.md         # Complete command reference
│   └── CHANGELOG.md        # Version history
├── scripts/                # Internal scripts (always use make commands instead)
│   ├── build.sh           # Build script
│   ├── init.sh            # Init script
│   ├── destroy.sh         # Destroy script
│   ├── setup.sh           # Interactive setup
│   ├── health-check.sh    # Environment diagnostics
│   └── bump-version.sh    # Version management
└── .dotfiles/             # Persistent configuration
    ├── .zshrc            # Shell configuration
    ├── .p10k.zsh         # Theme configuration
    └── .config/          # App configurations
        ├── nvim/         # Neovim/LazyVim
        └── lazygit/      # Git TUI
```

---

## 🛠️ Included Tools

**Core Development:**
- Neovim with LazyVim configuration
- Git + Lazygit (Git TUI)
- Node.js LTS + npm
- Python 3 + pip with dev packages

**Terminal Enhancement:**
- Zsh with Oh My Zsh + Powerlevel10k
- fzf (fuzzy finder), ripgrep (fast search)
- bat (better cat), exa (better ls), fd (better find)
- tmux (terminal multiplexer)

**System Tools:**
- htop, tree, curl, wget
- make, cmake, g++
- jq, yq (JSON/YAML processors)

---

## 🩺 Health & Maintenance

```bash
make status               # Check container status
make health               # Run comprehensive diagnostics
make backup               # Backup configurations
make clean                # Clean up Docker resources
```

---

## 🔄 Version Management

```bash
make version                    # Show current version
make bump-version TYPE=patch    # Bump version (patch/minor/major)
```

---

## 🐛 Troubleshooting

**Container won't start:**
```bash
make status       # Check what's wrong
make destroy      # Nuclear option: rebuild everything
make build
```

**Need fresh start:**
```bash
make destroy && make build
```

**Performance issues:**
```bash
make clean        # Free up disk space
```

---

## 📚 Documentation

- **[📖 Complete Commands Reference](docs/COMMANDS.md)** - All available commands and workflows
- **[📝 Changelog](docs/CHANGELOG.md)** - Version history and updates

---

**Ready to code? Run `make quick` and start developing! 🚀**

## 💡 Usage Tips

### First Time Setup
1. Run the container: `make build`
2. Configure Powerlevel10k theme: `p10k configure`
3. Customize Neovim as needed
4. Set up git: `git config --global user.name "Your Name"`

### Daily Workflow
1. Start container: `make start` or `make enter`
2. Work on your projects in mounted directories
3. All changes in .dotfiles are persisted
4. Stop when done: `make stop`

### Accessing Your Files
- Documents: `/home/developer/Documents`
- Projects: `/home/developer/Projects` (if configured)
- Custom mounts: As configured in docker-compose.yml

### Terminal Features
- **Auto-suggestions**: Start typing, get suggestions from history
- **Syntax highlighting**: Commands are highlighted as you type
- **Fast search**: Use `Ctrl+R` for history search with fzf
- **Git integration**: Lazygit with `lg` command or `lazygit`

---

## 🤝 Contributions

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Development Guidelines
- Follow existing code style
- Add appropriate documentation
- Test your changes
- Update version number if needed

---

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## 👨‍💻 Author

Created by **ManghiDev**  
🌐 Website: [Personal Web](https://manghi.dev)  
📧 Contact: [GitHub Issues](https://github.com/manghidev/lazyvim-docker/issues)

---

## ⭐ Support

If you find this project helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 📖 Improving documentation

---

## 📚 Additional Resources

- [LazyVim Documentation](https://lazyvim.github.io/)
- [Neovim Documentation](https://neovim.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)