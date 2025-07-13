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
    git lazygit fzf curl neovim ripgrep alpine-sdk bash zsh sudo \
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
    # Timezone support
    tzdata \
    # Python packages via apk (more stable on Alpine)
    && apk add --no-cache py3-requests py3-beautifulsoup4 \
    # Install some Python tools that need pip
    && pip3 install --break-system-packages --no-cache-dir \
    black flake8 mypy pytest pandas

#* Configure timezone (default to America/Mexico_City, can be overridden with build arg)
ARG TIMEZONE=America/Mexico_City
ENV TZ=$TIMEZONE
RUN cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo $TIMEZONE > /etc/timezone

#* Create a developer user with dynamic UID/GID for Linux compatibility
ARG USER_UID=1000
ARG USER_GID=1000
RUN set -eux; \
    echo "Setting up user with UID: $USER_UID, GID: $USER_GID"; \
    # Handle group creation/selection
    if getent group $USER_GID >/dev/null 2>&1; then \
        GROUP_NAME=$(getent group $USER_GID | cut -d: -f1); \
        echo "Using existing group: $GROUP_NAME (GID: $USER_GID)"; \
    else \
        # Check if developer group exists with different GID
        if getent group developer >/dev/null 2>&1; then \
            # Remove existing developer group if it has different GID
            delgroup developer || true; \
        fi; \
        addgroup -g $USER_GID developer; \
        GROUP_NAME="developer"; \
        echo "Created group: $GROUP_NAME (GID: $USER_GID)"; \
    fi; \
    # Handle user creation/modification
    if getent passwd $USER_UID >/dev/null 2>&1; then \
        # User with this UID already exists
        EXISTING_USER=$(getent passwd $USER_UID | cut -d: -f1); \
        echo "User with UID $USER_UID already exists: $EXISTING_USER"; \
        # Change the user's primary group to our target group
        sed -i "s/^$EXISTING_USER:\([^:]*\):\([^:]*\):\([^:]*\):/$EXISTING_USER:\1:\2:$USER_GID:/" /etc/passwd; \
        # Ensure the user has zsh shell
        sed -i "s|^$EXISTING_USER:\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\(.*\)|$EXISTING_USER:\1:\2:\3:\4:\5:/bin/zsh|" /etc/passwd; \
        # Add to sudoers if not already there
        if ! grep -q "^$EXISTING_USER " /etc/sudoers; then \
            echo "$EXISTING_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
        fi; \
        # Get user's home directory and set environment variable
        USER_HOME=$(getent passwd $EXISTING_USER | cut -d: -f6); \
        echo "export USER_HOME=$USER_HOME" >> /etc/environment; \
        # Create developer symlink if the user isn't named developer
        if [ "$EXISTING_USER" != "developer" ]; then \
            # Create symlink for compatibility
            if [ ! -e /home/developer ]; then \
                ln -sf $USER_HOME /home/developer; \
            fi; \
        fi; \
        echo "Using existing user: $EXISTING_USER with home: $USER_HOME"; \
    else \
        # No user with this UID, create new developer user
        # First, remove any existing developer user with different UID
        if getent passwd developer >/dev/null 2>&1; then \
            deluser developer || true; \
        fi; \
        # Create the developer user
        adduser -D -u $USER_UID -G $GROUP_NAME -s /bin/zsh developer; \
        echo "Created user: developer (UID: $USER_UID, GID: $USER_GID)"; \
        echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
    fi

#* Switch to the developer user for the rest of the setup  
USER $USER_UID:$USER_GID

#* Determine the actual home directory and set up environment
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo "Working with home directory: $USER_HOME" && \
    # Ensure the home directory exists and has proper permissions
    mkdir -p $USER_HOME && \
    chown $USER_UID:$USER_GID $USER_HOME

#* Set dynamic WORKDIR based on actual user home
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo "Setting working directory to: $USER_HOME"
WORKDIR /home/node

#* Install Oh My Zsh for the current user
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    cd $USER_HOME && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

#* Install useful zsh plugins
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    mkdir -p $USER_HOME/.oh-my-zsh/custom/plugins && \
    git clone https://github.com/zsh-users/zsh-autosuggestions $USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $USER_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-completions $USER_HOME/.oh-my-zsh/custom/plugins/zsh-completions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' $USER_HOME/.zshrc

#* Install the Powerlevel10k theme
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    mkdir -p $USER_HOME/.oh-my-zsh/custom/themes && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $USER_HOME/.zshrc

#* Clone LazyVim for the current user
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    mkdir -p $USER_HOME/.config && \
    git clone https://github.com/LazyVim/starter $USER_HOME/.config/nvim

#* Remove the .git folder, so you can add it to your own repo later
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    rm -rf $USER_HOME/.config/nvim/.git

#* Create useful aliases in .zshrc
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo 'alias ll="exa -la"' >> $USER_HOME/.zshrc && \
    echo 'alias cat="bat"' >> $USER_HOME/.zshrc && \
    echo 'alias find="fd"' >> $USER_HOME/.zshrc && \
    echo 'alias vim="nvim"' >> $USER_HOME/.zshrc && \
    echo 'alias vi="nvim"' >> $USER_HOME/.zshrc && \
    echo 'alias lg="lazygit"' >> $USER_HOME/.zshrc

#* Add helpful environment variables
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo 'export EDITOR=nvim' >> $USER_HOME/.zshrc && \
    echo 'export VISUAL=nvim' >> $USER_HOME/.zshrc && \
    echo 'export PAGER=bat' >> $USER_HOME/.zshrc

#* Configure Powerlevel10k to avoid gitstatus issues
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo 'POWERLEVEL9K_DISABLE_GITSTATUS=true' >> $USER_HOME/.zshrc && \
    echo 'POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true' >> $USER_HOME/.zshrc && \
    echo 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet' >> $USER_HOME/.zshrc

#* Switch back to root to fix permissions and create directories
USER root

#* Create cache directories and ensure proper permissions for the actual user home
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && \
    echo "Creating cache directories in: $USER_HOME" && \
    mkdir -p $USER_HOME/.cache/nvim $USER_HOME/.cache/zsh $USER_HOME/.cache/pip \
             $USER_HOME/.local/share/nvim $USER_HOME/.local/state/nvim \
             $USER_HOME/.cache/gitstatus $USER_HOME/.cache/p10k && \
    chown -R $USER_UID:$USER_GID $USER_HOME && \
    chmod -R 755 $USER_HOME/.cache $USER_HOME/.local && \
    # Also ensure the developer symlink has proper permissions if it exists
    if [ -L /home/developer ]; then \
        chown -h $USER_UID:$USER_GID /home/developer; \
    fi

#* Switch back to the container user
USER $USER_UID:$USER_GID

#* Set the default working directory to the actual user home
RUN USER_HOME=$(getent passwd $USER_UID | cut -d: -f6) && echo "Final working directory: $USER_HOME"
WORKDIR /home/node

#* Set the default shell to Zsh
CMD ["/bin/zsh"]