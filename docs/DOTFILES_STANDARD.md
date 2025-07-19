# LazyVim Docker - Dotfiles Integration Standard

## Overview
LazyVim Docker supports importing your personal dotfiles configuration to make the container environment feel like your native system. This document defines the standard structure and integration process.

## Standard Directory Structure

Your dotfiles repository or ZIP file should follow this structure:

```
dotfiles/
├── .lazyvim-docker-dotfiles       # Configuration file (REQUIRED)
├── nvim/                          # Neovim configuration
│   ├── init.lua
│   └── lua/
├── zsh/                           # Zsh configuration
│   ├── .zshrc
│   ├── .zsh_aliases
│   └── .zsh_exports
├── git/                           # Git configuration
│   ├── .gitconfig
│   └── .gitignore_global
├── tmux/                          # Tmux configuration
│   └── .tmux.conf
├── scripts/                       # Custom scripts
│   └── *.sh
└── README.md                      # Optional documentation
```

## Required Configuration File

Your dotfiles **MUST** include a `.lazyvim-docker-dotfiles` file in the root directory:

```ini
# .lazyvim-docker-dotfiles
# LazyVim Docker Dotfiles Configuration

[metadata]
name=My Personal Dotfiles
version=1.0.0
author=Your Name
description=My personalized development environment

[nvim]
enabled=true
source_path=nvim
target_path=/home/developer/.config/nvim
backup_original=true

[zsh]
enabled=true
source_path=zsh
target_path=/home/developer
backup_original=true
files=.zshrc,.zsh_aliases,.zsh_exports

[git]
enabled=true
source_path=git
target_path=/home/developer
backup_original=true
files=.gitconfig,.gitignore_global

[tmux]
enabled=false
source_path=tmux
target_path=/home/developer
backup_original=true
files=.tmux.conf

[scripts]
enabled=true
source_path=scripts
target_path=/home/developer/bin
backup_original=false
make_executable=true

[custom]
# Add custom directory mappings
# format: source_path=target_path
# example: my_configs=/home/developer/.config/my_app
```

## Configuration Options

### Section: metadata
- `name`: Display name for your dotfiles
- `version`: Version of your dotfiles
- `author`: Your name or handle
- `description`: Brief description

### Section: [category] (nvim, zsh, git, tmux, scripts)
- `enabled`: true/false - Whether to install this category
- `source_path`: Path within your dotfiles directory
- `target_path`: Where to install in the container
- `backup_original`: Whether to backup existing files
- `files`: Comma-separated list of specific files (optional)
- `make_executable`: Make files executable (for scripts)

## Usage Examples

### Option 1: Git Repository
```bash
# When prompted for dotfiles source, choose "Git Repository"
# Enter your repository URL:
https://github.com/yourusername/dotfiles.git
https://gitlab.com/yourusername/dotfiles.git
https://gitbucket.yourserver.com/yourusername/dotfiles.git
```

### Option 2: Local ZIP File
```bash
# When prompted for dotfiles source, choose "Local ZIP File"
# Enter the full path to your ZIP file:
/Users/yourname/Documents/my-dotfiles.zip
/home/yourname/Downloads/dotfiles-backup.zip

# Tip: Use $(pwd)/dotfiles.zip if the file is in current directory
```

## Validation Rules

1. **Required file**: `.lazyvim-docker-dotfiles` must exist
2. **Valid sections**: Only recognized sections are processed
3. **Path validation**: All source paths must exist in your dotfiles
4. **Safe targets**: Target paths are validated for security
5. **Backup safety**: Original files are backed up before replacement

## Best Practices

1. **Keep it minimal**: Only include essential configurations
2. **Test locally**: Ensure your dotfiles work in a clean environment
3. **Document changes**: Use README.md to explain customizations
4. **Version control**: Tag releases for stable configurations
5. **Security**: Never include sensitive information (passwords, tokens)

## Example Repository Structure

Here's a complete example of a properly structured dotfiles repository:

```
my-dotfiles/
├── .lazyvim-docker-dotfiles
├── README.md
├── nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/
├── zsh/
│   ├── .zshrc
│   ├── .zsh_aliases
│   └── .zsh_exports
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
└── scripts/
    ├── dev-setup.sh
    └── git-helpers.sh
```

## Troubleshooting

### Common Issues

1. **Missing configuration file**
   - Error: "No .lazyvim-docker-dotfiles found"
   - Solution: Add the required configuration file

2. **Invalid source paths**
   - Error: "Source path 'xyz' not found"
   - Solution: Verify paths in your configuration match actual directories

3. **Permission issues**
   - Error: "Cannot create target directory"
   - Solution: Ensure target paths are writable

### Validation Commands

After installation, verify your dotfiles:

```bash
# Check installed files
ls -la ~/.config/nvim
ls -la ~/bin

# Verify Neovim configuration
nvim --version
nvim +checkhealth

# Test Zsh configuration
echo $ZSH_VERSION
alias
```

## Migration from Existing Dotfiles

If you have existing dotfiles, here's how to adapt them:

1. Create the `.lazyvim-docker-dotfiles` configuration file
2. Organize files into the standard directory structure
3. Test the configuration in a clean environment
4. Create a ZIP file or push to a Git repository

## Security Considerations

- Never include sensitive files (.ssh keys, passwords, tokens)
- Review all scripts before making them executable
- Use environment variables for sensitive configuration
- Regularly audit your dotfiles for security issues

For detailed implementation examples, see the test dotfiles in this repository.
