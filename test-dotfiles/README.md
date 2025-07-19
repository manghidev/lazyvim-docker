# Test Dotfiles for LazyVim Docker

This directory contains example dotfiles that follow the LazyVim Docker dotfiles standard.

## Structure

- `.lazyvim-docker-dotfiles` - Configuration file (required)
- `nvim/` - Neovim configuration
- `zsh/` - Zsh shell configuration  
- `git/` - Git configuration
- `scripts/` - Custom scripts

## Testing

To test these dotfiles:

1. Create a ZIP file:
   ```bash
   cd test-dotfiles
   zip -r ../test-dotfiles.zip .
   ```

2. Run the configuration:
   ```bash
   make configure
   # or
   lazy configure
   ```

3. Choose option 5 for dotfiles, then option 2 for ZIP file

4. Enter the path to the ZIP file when prompted

## What gets installed

- **Neovim**: Custom init.lua with basic settings
- **Zsh**: Custom prompt, aliases, and environment variables
- **Git**: User configuration and global gitignore
- **Scripts**: Development helper scripts in ~/bin

## Verification

After installation, you can verify the dotfiles are working:

```bash
# Check aliases
test-dotfiles

# Check environment variables
echo $DOTFILES_LOADED

# Check scripts
dev-setup.sh
```
