# LazyVim Docker Environment

This repository provides a Dockerized environment for using LazyVim, Zsh with Oh My Zsh, and additional tools for development. It is designed to simplify the setup of a powerful and customizable code editor environment.

## Features

- **LazyVim**: Pre-configured Neovim setup with LazyVim.
- **Zsh with Oh My Zsh**: Includes plugins like `zsh-autosuggestions` and the `Powerlevel10k` theme.
- **Essential Tools**: Includes `git`, `lazygit`, `fzf`, `curl`, `neovim`, `ripgrep`, and more.
- **Persistent Configuration**: Root configuration is persisted using Docker volumes.
- **Customizable**: Easily extend or modify the setup to suit your needs.

## Requirements

- Docker
- Docker Compose

## Setup

1. Clone this repository:
```sh
git clone https://github.com/manghidev/lazyvim-docker.git
cd lazyvim-docker
```

2. Build and start the container:
```sh
docker compose up -d
```

3. Access the container:
```sh
docker exec -it lazyvim /bin/zsh
```

## Directory Structure

- `$HOME/Documents` is mounted to `/home/develop/Documents` inside the container.
- `/Volumes/ExternalSSD/Work` is mounted to `/home/develop/Work`.
- `/Volumes/ExternalSSD/Personal` is mounted to `/home/develop/Personal`.

## Persistent Configuration

The root configuration is stored in a Docker volume named `root-config`. This ensures that your Zsh and LazyVim configurations persist across container restarts.

## Customization

- **Oh My Zsh Plugins**: Modify the `.zshrc` file to add or remove plugins.
- **LazyVim Configuration**: Edit the files in `/root/.config/nvim` to customize LazyVim.

## Included Tools

- **LazyVim**: A pre-configured Neovim setup.
- **Oh My Zsh**: A framework for managing Zsh configuration.
- **Powerlevel10k**: A fast and customizable Zsh theme.
- **fzf**: A command-line fuzzy finder.
- **lazygit**: A simple terminal UI for Git commands.
- **ripgrep**: A fast search tool.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Created by ManghiDev. For more information, visit [https://manghi.dev](https://manghi.dev).