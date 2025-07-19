# Example .zshrc for LazyVim Docker
# This is a test configuration file

# Enable colors
autoload -U colors && colors

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Basic settings
setopt AUTO_CD
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Prompt
PS1="%{$fg[cyan]%}[LazyVim-Docker]%{$reset_color%} %{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "

# Load aliases and exports
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.zsh_exports ]] && source ~/.zsh_exports

# Welcome message
echo "🐳 LazyVim Docker environment loaded with custom dotfiles!"
