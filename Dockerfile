#* Set the base image to Node.js LTS on Alpine
FROM node:lts-alpine

ARG VERSION

#* Set metadata for image
LABEL maintainer="ManghiDev <https://manghi.dev>" \
    description="Dockerfile for LazyVim and Zsh with oh-my-zsh" \
    version=$VERSION

#* Install necessary dependencies and development tools
RUN apk add --no-cache \
    # Core tools
    git lazygit fzf curl neovim ripgrep alpine-sdk zsh sudo \
    # Additional development tools
    tmux tree htop unzip zip \
    # Language tools
    python3 py3-pip \
    # Network tools
    openssh-client wget \
    # Build tools
    make cmake g++ \
    # Text processing
    jq yq sed gawk grep \
    # Terminal enhancements
    bat exa fd github-cli \
    # Python packages via apk (more stable on Alpine)
    && apk add --no-cache py3-requests py3-beautifulsoup4 \
    # Install some Python tools that need pip
    && pip3 install --break-system-packages --no-cache-dir \
    black flake8 mypy pytest pandas

#* Create a new user 'developer' with home directory and grant sudo privileges
RUN adduser -D -s /bin/zsh developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#* Switch to the 'developer' user for the rest of the setup
USER developer
WORKDIR /home/developer

#* Install Oh My Zsh for the 'developer' user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

#* Install useful zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/developer/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/developer/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-completions /home/developer/.oh-my-zsh/custom/plugins/zsh-completions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' /home/developer/.zshrc

#* Install the Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/developer/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/developer/.zshrc

#* Clone LazyVim for the 'developer' user
RUN git clone https://github.com/LazyVim/starter /home/developer/.config/nvim

#* Remove the .git folder, so you can add it to your own repo later
RUN rm -rf /home/developer/.config/nvim/.git

#* Create useful aliases in .zshrc
RUN echo 'alias ll="exa -la"' >> /home/developer/.zshrc && \
    echo 'alias cat="bat"' >> /home/developer/.zshrc && \
    echo 'alias find="fd"' >> /home/developer/.zshrc && \
    echo 'alias vim="nvim"' >> /home/developer/.zshrc && \
    echo 'alias vi="nvim"' >> /home/developer/.zshrc && \
    echo 'alias lg="lazygit"' >> /home/developer/.zshrc

#* Add helpful environment variables
RUN echo 'export EDITOR=nvim' >> /home/developer/.zshrc && \
    echo 'export VISUAL=nvim' >> /home/developer/.zshrc && \
    echo 'export PAGER=bat' >> /home/developer/.zshrc

#* Switch back to root to fix permissions and create directories
USER root

#* Create cache directories and ensure proper permissions
RUN mkdir -p /home/developer/.cache /home/developer/.local/share && \
    chown -R developer:developer /home/developer

#* Switch back to developer user
USER developer

#* Set the default working directory
WORKDIR /home/developer

#* Set the default shell to Zsh
CMD ["/bin/zsh"]