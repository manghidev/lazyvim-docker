FROM node:22.15.0-alpine

#* Set metadata for image
LABEL maintainer="ManghiDev <https://manghi.dev>" \
    description="Dockerfile for LazyVim and Zsh with Oh My Zsh" \
    version="0.1.0"

#* Install necessary dependencies
RUN apk add --no-cache git lazygit fzf curl neovim ripgrep alpine-sdk zsh shadow

#* Create a new user 'develop' with home directory and grant sudo privileges
RUN useradd -m -s /bin/zsh develop && \
    echo "develop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#* Force removal of any existing .zshrc directory (just in case)
RUN rm -rf /home/develop/.zshrc

#* Switch to the 'develop' user for the rest of the setup
USER develop
WORKDIR /home/develop

#* Install Oh My Zsh for the 'develop' user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

#* Install the zsh-autosuggestions plugin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/develop/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/develop/.zshrc

#* Install the Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/develop/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/develop/.zshrc

#* Clone LazyVim for the 'develop' user
RUN git clone https://github.com/LazyVim/starter /home/develop/.config/nvim

#* Remove the .git folder, so you can add it to your own repo later
RUN rm -rf /home/develop/.config/nvim/.git

#* Ensure proper permissions for the 'develop' user
RUN chown -R develop:develop /home/develop

#* Set the default working directory
WORKDIR /home/develop

#* Set the default shell to Zsh
CMD ["/bin/zsh"]